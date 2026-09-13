# ============================================================
# Peramalan Permintaan — Versi Super Sederhana (proyek "selected")
# R/00_buat_data.R  --  generator data ringkas
#
# BUSINESS CASE (fikti): "CV Segar Jaya"
#   Pabrik kecil pembuat minuman & makanan ringan. 2 produk:
#     * Teh Botol       (minuman)        -> Tren +1,0%/bulan
#     * Keripik Kentang (makanan ringan) -> Tren +0,4%/bulan
#   Data penjualan aktual 24 bulan (2024-2025), set.seed reproducible.
#   Pola yang ditanam:
#     * TREN naik per produk
#     * MUSIMAN puncak Nov-Des (Angka Bulan tinggi: 1,28 & 1,38)
#     * noise kecil (~7%)
#
# Output: data/permintaan.csv  (Tanggal, Produk, Permintaan)
#         data/produk.csv      (dimensi: Kategori, Harga, Kapasitas, LeadTime)
# ============================================================

set.seed(20260913)

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
dir.create(file.path(base, "data"), showWarnings = FALSE)

bulan   <- seq(as.Date("2024-01-01"), as.Date("2025-12-01"), by = "month")
produk  <- c("Teh Botol", "Keripik Kentang")

# --- parameter dasar ---
base_qty <- c("Teh Botol" = 5000, "Keripik Kentang" = 3000)  # unit/bulan dasar
tren_p   <- c("Teh Botol" = 0.010, "Keripik Kentang" = 0.004)  # tren % per bulan
# Angka Bulan dasar per bulan kalender (1 = rata-rata; puncak Nov & Des)
musim <- c(0.82, 0.85, 0.93, 1.00, 1.08, 1.15, 1.10, 1.02, 1.04, 1.12, 1.28, 1.38)

df <- expand.grid(Tanggal = bulan, Produk = produk, stringsAsFactors = FALSE)
df <- df[order(df$Tanggal, df$Produk), ]

n        <- nrow(df)
bulan_ke <- as.integer(format(df$Tanggal, "%m"))
idx      <- (as.integer(format(df$Tanggal, "%Y")) - 2024) * 12 + bulan_ke

df$Permintaan <- round(
  base_qty[df$Produk] * (1 + tren_p[df$Produk]) ^ idx * musim[bulan_ke] * rnorm(n, 1, 0.07)
)
df$Permintaan <- pmax(df$Permintaan, 200)

# --- dimensi produk ---
produk_dim <- data.frame(
  Produk         = produk,
  Kategori       = c("Minuman", "Makanan Ringan"),
  HargaSatuan    = c(12000, 15000),      # Rp/unit
  KapasitasMesin = c(7000, 3800),        # unit/bulan per mesin
  LeadTimeHari   = c(7, 14),
  stringsAsFactors = FALSE
)

write.csv(df, file.path(base, "data", "permintaan.csv"), row.names = FALSE)
write.csv(produk_dim, file.path(base, "data", "produk.csv"), row.names = FALSE)

cat("permintaan.csv :", nrow(df), "baris x", ncol(df), "kolom\n")
cat("produk.csv     :", nrow(produk_dim), "baris x", ncol(produk_dim), "kolom\n\n")
cat("Total permintaan per tahun:\n")
print(tapply(df$Permintaan, format(df$Tanggal, "%Y"), sum))
cat("\nRata-rata per produk:\n")
print(round(tapply(df$Permintaan, df$Produk, mean)))
cat("\nPuncak musiman (Angka Bulan per bulan kalender):\n")
print(round(tapply(df$Permintaan, bulan_ke, mean) / mean(df$Permintaan), 2))
print(head(df, 4))