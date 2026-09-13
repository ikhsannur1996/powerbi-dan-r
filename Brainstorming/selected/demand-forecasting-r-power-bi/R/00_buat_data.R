# ============================================================
# BUAT DATA  —  CV Segar Jaya (data sintetik untuk training)
# R/00_buat_data.R
#
# Jalankan 1x. set.seed -> angka SAMA setiap kali.
#
# PERIODE : 3 tahun penuh (Jan 2023 - Des 2025) = 36 bulan
# GRAIN   : 1 baris = 1 bulan x 1 SKU x 1 lokasi
# DIMENSI : Produk x Rasa x Ukuran (Kecil/Sedang/Besar) x JenisPacking
# OUTLIER : ditanam sengaja agar data realistis:
#             - promo          : +30% s/d +85% (lebih sering Mar-Apr & Nov-Des)
#             - gangguan       : -35% s/d -65% (stok habis / mesin berhenti)
#             - kejadian ekstrem: x2,2 s/d x2,8 (langka, ±0,4% baris)
#
# OUTPUT:
#   data/permintaan.csv  1.152 baris (fakta)
#   data/produk.csv         16 baris (dimensi SKU + ukuran + packing)
#   data/lokasi.csv          2 baris (dimensi pabrik)
# ============================================================

set.seed(20260913)

# --- 1. templat varian: ukuran x jenis packing --------------------------
# Setiap produk punya 4 varian: 3 ukuran (Kecil/Sedang/Besar)
# dan 2 jenis packing (versi reguler + versi premium).
varian <- data.frame(
  KodeUkuran   = c("KEC", "SED", "SED", "BES"),
  Ukuran       = c("Kecil", "Sedang", "Sedang", "Besar"),
  UrutanUkuran = c(1L, 2L, 2L, 3L),
  stringsAsFactors = FALSE
)

varian_teh <- cbind(
  varian,
  KodePack     = c("PET", "PET", "KAC", "KAC"),
  JenisPacking = c("Botol PET", "Botol PET", "Botol Kaca", "Botol Kaca"),
  IsiKemasan   = c("250 ml", "450 ml", "450 ml", "1.000 ml"),
  HargaSatuan  = c(6000, 9000, 12000, 18000),
  IsiPerKarton = c(24L, 12L, 12L, 6L),
  # bobot pangsa tiap varian di dalam produknya (jumlah = 1)
  # base = kondisi awal 2023 ; delta = pergeseran sampai akhir 2025
  wSKU_base    = c(0.26, 0.34, 0.18, 0.22),
  wSKU_delta   = c(-0.08, -0.02, 0.02, 0.08),
  stringsAsFactors = FALSE
)

varian_krip <- cbind(
  varian,
  KodePack     = c("SAC", "SAC", "POU", "POU"),
  JenisPacking = c("Sachet", "Sachet", "Pouch", "Pouch"),
  IsiKemasan   = c("60 g", "120 g", "120 g", "250 g"),
  HargaSatuan  = c(6500, 11000, 15000, 22000),
  IsiPerKarton = c(40L, 24L, 24L, 12L),
  wSKU_base    = c(0.32, 0.28, 0.17, 0.23),
  wSKU_delta   = c(-0.08, -0.02, 0.02, 0.08),
  stringsAsFactors = FALSE
)

# --- 2. tabel rasa (per produk) -----------------------------------------
rasa_tbl <- data.frame(
  KodeProduk     = c("TB", "TB", "KK", "KK"),
  Produk         = c("Teh Botol", "Teh Botol", "Keripik Kentang", "Keripik Kentang"),
  Kategori       = c("Minuman", "Minuman", "Makanan", "Makanan"),
  KodeRasa       = c("JAS", "PCH", "ORI", "PAP"),
  Rasa           = c("Jasmin", "Peach", "Original", "Paprika"),
  wRasa          = c(0.60, 0.40, 0.55, 0.45),
  KapasitasMesin = c(4000L, 4000L, 2200L, 2200L),
  stringsAsFactors = FALSE
)

# --- 3. rakit dimensi produk: 4 rasa x 4 varian = 16 SKU ----------------
dimensi_produk <- do.call(rbind, lapply(seq_len(nrow(rasa_tbl)), function(i) {
  v <- if (rasa_tbl$Produk[i] == "Teh Botol") varian_teh else varian_krip
  data.frame(
    SKU            = sprintf("%s-%s-%s-%s", rasa_tbl$KodeProduk[i],
                             rasa_tbl$KodeRasa[i], v$KodeUkuran, v$KodePack),
    Produk         = rasa_tbl$Produk[i],
    Kategori       = rasa_tbl$Kategori[i],
    Rasa           = rasa_tbl$Rasa[i],
    Ukuran         = v$Ukuran,
    UrutanUkuran   = v$UrutanUkuran,
    JenisPacking   = v$JenisPacking,
    IsiKemasan     = v$IsiKemasan,
    HargaSatuan    = v$HargaSatuan,
    IsiPerKarton   = v$IsiPerKarton,
    KapasitasMesin = rasa_tbl$KapasitasMesin[i],
    wSKU_base      = v$wSKU_base,
    wSKU_delta     = v$wSKU_delta,
    stringsAsFactors = FALSE
  )
}))
rownames(dimensi_produk) <- NULL

# --- 4. tabel lokasi: 2 pabrik ------------------------------------------
lokasi <- data.frame(
  Lokasi = c("Pabrik A", "Pabrik B"),
  Faktor = c(0.60, 0.40),                        # Pabrik A menjual lebih banyak
  stringsAsFactors = FALSE
)

# --- 5. parameter permintaan --------------------------------------------
bulan <- seq(as.Date("2023-01-01"), as.Date("2025-12-01"), by = "month")
base  <- c("Teh Botol" = 6200, "Keripik Kentang" = 3400)    # unit/bulan, kedua pabrik
tren  <- c("Teh Botol" = 0.010, "Keripik Kentang" = 0.004)  # tumbuh % per bulan
musim <- c(0.82, 0.85, 0.93, 1.00, 1.08, 1.15, 1.10,        # ritme bulanan
           1.02, 1.04, 1.12, 1.28, 1.38)                    # 1 = rata-rata
musim <- musim / mean(musim)
wRasa <- setNames(rasa_tbl$wRasa, rasa_tbl$Rasa)

# --- 6. fakta: 36 bulan x 2 lokasi x 16 SKU = 1.152 baris ---------------
df <- merge(expand.grid(Tanggal = bulan, Lokasi = lokasi$Lokasi), dimensi_produk)
df <- df[order(df$Tanggal, df$Produk, df$Rasa, df$Ukuran,
               df$JenisPacking, df$Lokasi), ]

df$Idx     <- (as.integer(format(df$Tanggal, "%Y")) - 2023L) * 12L +
              as.integer(format(df$Tanggal, "%m"))            # 1..36
df$Frac    <- (df$Idx - 1) / 35                             # 0..1 (pergeseran mix)
df$wSKU    <- df$wSKU_base + df$wSKU_delta * df$Frac
df$BulanKe <- as.integer(format(df$Tanggal, "%m"))

# --- 6b. outlier realistis: promo, gangguan, kejadian ekstrem -----------
# Promo lebih sering pada musim ramai (Maret-April dan November-Desember).
n       <- nrow(df)
p_promo <- ifelse(df$BulanKe %in% c(3L, 4L, 11L, 12L), 0.060, 0.015)
u       <- runif(n)
df$Kejadian <- ifelse(u < p_promo, "Promo",
               ifelse(u < p_promo + 0.020, "Gangguan", "Normal"))
df$Kejadian[sample(seq_len(n), size = round(0.004 * n))] <- "Ekstrem"

faktor <- rep(1, n)
faktor <- ifelse(df$Kejadian == "Promo",    runif(n, 1.30, 1.85), faktor)
faktor <- ifelse(df$Kejadian == "Gangguan", runif(n, 0.35, 0.65), faktor)
faktor <- ifelse(df$Kejadian == "Ekstrem",  runif(n, 2.20, 2.80), faktor)

# --- 6c. permintaan = dasar x tren x musiman x bauran x noise x outlier --
df$Permintaan <- round(
  base[df$Produk] *
  wRasa[df$Rasa] *
  df$wSKU *
  lokasi$Faktor[match(df$Lokasi, lokasi$Lokasi)] *
  (1 + tren[df$Produk]) ^ df$Idx *
  musim[df$BulanKe] *
  rnorm(n, 1, 0.07) *
  faktor
)
df$Permintaan <- pmax(df$Permintaan, 5)

# --- 7. tulis CSV: fakta (4 kolom) + 2 dimensi --------------------------
fakta <- df[, c("Tanggal", "SKU", "Lokasi", "Permintaan")]

dimensi_bersih <- dimensi_produk[, c("SKU", "Produk", "Kategori", "Rasa", "Ukuran",
                                     "UrutanUkuran", "JenisPacking", "IsiKemasan",
                                     "HargaSatuan", "IsiPerKarton", "KapasitasMesin")]

write.csv(fakta,          file.path("data", "permintaan.csv"), row.names = FALSE)
write.csv(dimensi_bersih, file.path("data", "produk.csv"),     row.names = FALSE)
write.csv(lokasi,         file.path("data", "lokasi.csv"),     row.names = FALSE)

# --- 8. ringkasan -------------------------------------------------------
cat("permintaan.csv :", nrow(fakta), "baris x", ncol(fakta), "kolom\n")
cat("produk.csv     :", nrow(dimensi_bersih), "SKU ; lokasi.csv :", nrow(lokasi), "baris\n")
cat("Periode        :", format(min(df$Tanggal)), "s/d", format(max(df$Tanggal)), "\n")
cat("Rentang unit   :", min(df$Permintaan), "s/d", max(df$Permintaan), "unit per baris\n\n")

cat("Outlier yang ditanam (jumlah baris):\n")
print(table(df$Kejadian))
cat("Total outlier  :",
    sum(df$Kejadian != "Normal"), sprintf("baris (%.1f%%)\n\n",
    sum(df$Kejadian != "Normal") / nrow(df) * 100))

cat("Total unit per tahun per produk:\n")
print(tapply(df$Permintaan, list(format(df$Tanggal, "%Y"), df$Produk), sum))

cat("\nTotal unit per ukuran (3 tahun):\n")
print(tapply(df$Permintaan, list(df$Produk, df$Ukuran), sum))

cat("\nTotal unit per jenis packing (3 tahun):\n")
print(tapply(df$Permintaan, list(df$Produk, df$JenisPacking), sum))

cat("\nTotal unit per lokasi (3 tahun):\n")
print(tapply(df$Permintaan, df$Lokasi, sum))

cat("\nPangsa ukuran per produk per tahun (%)\n")
df$Tahun <- as.integer(format(df$Tanggal, "%Y"))
pangsa <- function(var) {
  agg <- aggregate(Permintaan ~ Produk + Tahun + df[[var]], data = df, FUN = sum)
  names(agg)[3] <- var
  agg <- do.call(rbind, lapply(split(agg, list(agg$Produk, agg$Tahun), drop = TRUE),
                               function(z) { z$Pangsa <- round(z$Permintaan / sum(z$Permintaan) * 100, 1); z }))
  agg[order(agg$Produk, agg$Tahun, agg[[var]]), c("Produk", "Tahun", var, "Pangsa")]
}
print(pangsa("Ukuran"), row.names = FALSE)

cat("\nPangsa jenis packing per produk per tahun (%)\n")
print(pangsa("JenisPacking"), row.names = FALSE)

cat("\nAngka Bulan (ritme) per produk:\n")
mo  <- as.integer(format(df$Tanggal, "%m"))
gem <- tapply(df$Permintaan, df$Produk, mean)
ab  <- tapply(df$Permintaan, list(mo, df$Produk), mean)
print(round(ab / matrix(gem, nrow = nrow(ab), ncol = ncol(ab), byrow = TRUE), 2))

cat("\nHead (dimensi produk):\n")
print(head(dimensi_bersih, 4))
