# ============================================================
# Opsi 3 - Peramalan Permintaan & Perencanaan Produksi
# R/00_buat_data.R  --  generator data (reproducible, set.seed)
# ============================================================
# Output: data/permintaan.csv   (1 baris = 1 bulan x 1 produk)
#         data/produk.csv       (dimensi produk: harga, kapasitas)
# Pola sengaja ditanam: TREN naik + MUSIMAN (puncak Q4 & lebaran) + noise.
# ============================================================

set.seed(20260903)

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
dir.create(file.path(base, "data"), showWarnings = FALSE)

bulan <- seq(as.Date("2024-01-01"), as.Date("2026-12-01"), by = "month")
produk <- c("Bracket", "Housing", "Shaft", "Panel")

# --- demand dasar per produk (unit/bulan) ---
base_qty <- c(Bracket = 4200, Housing = 3100, Shaft = 2400, Panel = 1800)

# --- tren pertumbuhan bulanan (% per bulan) ---
tren <- c(Bracket = 0.012, Housing = 0.006, Shaft = 0.018, Panel = -0.004)

# --- faktor musiman per bulan kalender (1 = tanpa musiman) ---
musim <- c(0.90, 0.92, 1.00, 1.05, 1.12, 1.08, 0.95, 0.97, 1.02, 1.10, 1.25, 1.35)

df <- expand.grid(Bulan = bulan, Produk = produk, stringsAsFactors = FALSE)
df <- df[order(df$Bulan, df$Produk), ]
df$Bulan <- as.Date(df$Bulan)

# --- bangun permintaan ---
n <- nrow(df)
bulan_ke <- as.integer(format(df$Bulan, "%m"))
bulan_idx <- (as.integer(format(df$Bulan, "%Y")) - 2024) * 12 + bulan_ke

df$Permintaan <- round(
  base_qty[df$Produk] *
    (1 + tren[df$Produk]) ^ bulan_idx *
    musim[bulan_ke] *
    rnorm(n, 1, 0.07)
)
df$Permintaan <- pmax(df$Permintaan, 200)

# --- dimensi produk ---
produk_dim <- data.frame(
  Produk         = produk,
  Kategori       = c("Komponen", "Komponen", "Presisi", "Rangkaian"),
  HargaSatuan    = c(125000, 185000, 240000, 95000),
  KapasitasMesin = c(5200, 3800, 3000, 2400),
  LeadTimeHari   = c(14, 21, 28, 10)
)

write.csv(df, file.path(base, "data", "permintaan.csv"), row.names = FALSE)
write.csv(produk_dim, file.path(base, "data", "produk.csv"), row.names = FALSE)

cat("permintaan.csv :", nrow(df), "baris x", ncol(df), "kolom\n")
cat("produk.csv     :", nrow(produk_dim), "baris x", ncol(produk_dim), "kolom\n\n")
cat("Total permintaan per tahun:\n")
print(tapply(df$Permintaan, format(df$Bulan, "%Y"), sum))
cat("\nRata-rata permintaan per produk:\n")
print(round(tapply(df$Permintaan, df$Produk, mean)))
print(head(df, 4))
