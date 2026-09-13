# ============================================================
# Peramalan Permintaan - Versi Compact (proyek "selected")
# R/00_buat_data.R  --  generator data ringkas
#
# Case sederhana: 2 produk x 24 bulan (2024-2025) = 48 baris.
# Pola yang ditanam (set.seed):
#   * TREN naik per produk (Produk A +1,0%/bulan; Produk B +0,4%/bulan)
#   * MUSIMAN puncak Nov-Des (indeks 1,28 & 1,38) vs dasar Jan-Feb (0,82)
#   * noise normal ~ 7%
#
# Output: data/permintaan.csv  (fakta: Tanggal, Produk, Permintaan)
#         data/produk.csv      (dimensi: Kategori, Harga, Kapasitas, LeadTime)
# ============================================================

set.seed(20260913)

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
dir.create(file.path(base, "data"), showWarnings = FALSE)

bulan   <- seq(as.Date("2024-01-01"), as.Date("2025-12-01"), by = "month")
produk  <- c("Produk A", "Produk B")

# --- parameter dasar ---
base_qty <- c("Produk A" = 5000, "Produk B" = 3000)      # unit/bulan dasar
tren_p   <- c("Produk A" = 0.010, "Produk B" = 0.004)    # tren % per bulan
# indeks musiman per bulan kalender (1 = rata-rata; puncak Nov & Des)
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
  Kategori       = c("Minuman", "Makanan"),
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
cat("\nPuncak musiman (indeks per bulan kalender):\n")
print(round(tapply(df$Permintaan, bulan_ke, mean) / mean(df$Permintaan), 2))
print(head(df, 4))