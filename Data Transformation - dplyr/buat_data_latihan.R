# =====================================================================
# buat_data_latihan.R
# Generator dataset latihan dplyr untuk EXERCISE.md (100 kasus)
# =====================================================================
# Membuat 3 file CSV di root project:
#   qc_hasil_produksi.csv : transaksi produksi harian (±450 baris)
#   qc_operator.csv       : master operator (8 baris)
#   qc_produk.csv         : master produk (6 baris)
#
# Deterministik (set.seed(2026)) — aman dijalankan ulang.
# Ciri data yang sengaja ditanam untuk latihan:
#   - NA pada DowntimeMin / TempC / HumidityPct
#   - DowntimeMin negatif (salah input)
#   - Produk "Casing" tidak dikenal master
#   - Produk master "Kabel" tidak pernah diproduksi
#   - Operator OP08 tidak pernah muncul di transaksi
#   - 2 baris duplikat persis
# =====================================================================

set.seed(2026)
root <- if (file.exists("quality_inspection.csv")) "." else ".."

# ---- Master produk (key: Produk — sengaja beda nama dari transaksi) --
produk <- data.frame(
  Produk           = c("Bracket", "Housing", "Terminal", "Panel", "Sensor", "Kabel"),
  Kategori         = c("Mekanik", "Mekanik", "Elektrik",
                       "Elektronik", "Elektronik", "Elektrik"),
  HargaSatuan      = c(15000, 22000, 9000, 48000, 125000, 12000),
  TargetDefectRate = c(0.030, 0.035, 0.050, 0.040, 0.020, 0.045)
)

# ---- Master operator (ada nama berantakan untuk latihan string) ------
operator <- data.frame(
  OperatorID = paste0("OP", sprintf("%02d", 1:8)),
  Nama = c("Budi Santoso ", "Siti Rahma", "Andi Wijaya", "Rina Marlina",
           "Dedi Kurniawan", "maya anggraini", "Fajar Nugroho",
           "Lestari Wulandari"),
  Lini       = c("A", "A", "B", "B", "C", "C", "Rotasi", "Rotasi"),
  ShiftUtama = c("Pagi", "Sore", "Pagi", "Sore", "Pagi", "Sore", "Pagi", "Sore"),
  TahunMasuk = c(2019, 2021, 2018, 2020, 2017, 2022, 2023, 2024)
)

# ---- Kerangka transaksi: hari kerja x lini x shift -------------------
tgl <- seq(as.Date("2026-07-01"), as.Date("2026-09-26"), by = "day")
tgl <- tgl[format(tgl, "%u") != "7"]                    # buang hari Minggu

sel <- expand.grid(Tanggal = tgl, Lini = c("A", "B", "C"),
                   Shift = c("Pagi", "Sore"), stringsAsFactors = FALSE)
sel$Tanggal <- as.Date(sel$Tanggal)
sel <- sel[order(sel$Tanggal, sel$Lini, sel$Shift), ]
n <- nrow(sel)

# Produk per lini + sisipan "Casing" (tidak dikenal master)
produk_lini <- list(A = c("Bracket", "Housing"), B = c("Bracket", "Terminal"),
                    C = c("Panel", "Sensor"))
sel$Product <- NA_character_
for (ln in names(produk_lini)) {
  idx <- sel$Lini == ln
  sel$Product[idx] <- sample(produk_lini[[ln]], sum(idx), replace = TRUE)
}
sel$Product[sample(which(sel$Lini == "A"), 6)] <- "Casing"

# Operator tetap per (lini, shift) + OP07 relief ±5%; OP08 tidak muncul
pasangan <- data.frame(
  Lini  = rep(c("A", "B", "C"), each = 2),
  Shift = rep(c("Pagi", "Sore"), 3),
  Utama = c("OP01", "OP02", "OP03", "OP04", "OP05", "OP06")
)
sel$OperatorID <- NA_character_
for (i in seq_len(nrow(pasangan))) {
  idx <- sel$Lini == pasangan$Lini[i] & sel$Shift == pasangan$Shift[i]
  sel$OperatorID[idx] <- pasangan$Utama[i]
}
sel$OperatorID[sample(n, round(n * 0.05))] <- "OP07"

# Volume produksi & defect (lini B lebih bermasalah, sore sedikit lebih buruk)
sel$UnitsProduced <- round(runif(n, 700, 1600))
p_dasar <- c(0.032, 0.036, 0.048, 0.041, 0.019, 0.055)
names(p_dasar) <- c("Bracket", "Housing", "Terminal", "Panel", "Sensor", "Casing")
p <- p_dasar[sel$Product] *
     ifelse(sel$Shift == "Sore", 1.15, 1.00) *
     ifelse(sel$Lini == "B", 1.20, 1.00)
sel$UnitsDefect <- rbinom(n, sel$UnitsProduced, pmin(p, 0.20))

# Downtime: distribusi eksponensial, 12 NA, 3 nilai negatif (salah input)
dt <- round(rexp(n, rate = 1 / 35))
dt[sample(n, 12)] <- NA
idx_neg <- sample(which(!is.na(dt)), 3)
dt[idx_neg] <- -c(5, 12, 8)
sel$DowntimeMin <- dt

# Kondisi ruang produksi (dengan NA) & konsumsi energi
offset <- c(A = 0, B = 1.5, C = -0.8)[sel$Lini]
temp <- round(rnorm(n, 26.5 + offset, 1.1), 1)
temp[sample(n, 20)] <- NA
sel$TempC <- temp

hum <- round(rnorm(n, 72, 4))
hum[sample(n, 20)] <- NA
sel$HumidityPct <- hum

sel$EnergyKWh <- round(sel$UnitsProduced * runif(n, 0.018, 0.032), 1)

# 2 baris duplikat persis (untuk latihan distinct)
hasil <- rbind(sel, sel[sample(n, 2), ])
hasil <- hasil[, c("Tanggal", "Lini", "Shift", "OperatorID", "Product",
                   "UnitsProduced", "UnitsDefect", "DowntimeMin",
                   "TempC", "HumidityPct", "EnergyKWh")]

# ---- Simpan ke root project ------------------------------------------
write.csv(produk,   file.path(root, "qc_produk.csv"),         row.names = FALSE)
write.csv(operator, file.path(root, "qc_operator.csv"),       row.names = FALSE)
write.csv(hasil,    file.path(root, "qc_hasil_produksi.csv"), row.names = FALSE)

cat("Dataset latihan dibuat di:", normalizePath(root), "\n")
cat("  qc_hasil_produksi.csv :", nrow(hasil),    "baris\n")
cat("  qc_operator.csv       :", nrow(operator), "baris\n")
cat("  qc_produk.csv         :", nrow(produk),   "baris\n")
