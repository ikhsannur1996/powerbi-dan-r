# ============================================================
# Opsi 4 - Downtime & Preventive Maintenance (TPM)
# R/00_buat_data.R  --  generator data (reproducible, set.seed)
# ============================================================
# Output: data/downtime.csv  (1 baris = 1 mesin x 1 hari x 1 shift)
#         data/mesin.csv     (dimensi mesin: umur, line, kritikalitas)
# Pola sengaja ditanam: mesin tua (M-02, M-04) lebih sering breakdown,
# penyebab dominan tertentu, dan downtime berdampak ke output.
# ============================================================

set.seed(20260904)

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
dir.create(file.path(base, "data"), showWarnings = FALSE)

tgl    <- seq(as.Date("2025-01-01"), as.Date("2026-06-30"), by = "day")
tgl    <- tgl[format(tgl, "%u") != "7"]        # libur tiap Minggu
shift  <- c("Pagi", "Siang", "Malam")
mesin  <- c("M-01", "M-02", "M-03", "M-04", "M-05", "M-06")

# --- dimensi mesin: umur (tahun), line, kritikalitas ---
mesin_dim <- data.frame(
  Mesin        = mesin,
  Line         = c("Line-A", "Line-A", "Line-B", "Line-B", "Line-C", "Line-C"),
  Tipe         = c("CNC", "CNC", "Press", "Press", "Milling", "Milling"),
  UmurTahun    = c(3.5, 11.0, 4.0, 10.5, 6.0, 2.5),
  Kritikalitas  = c("Tinggi", "Tinggi", "Sedang", "Tinggi", "Sedang", "Rendah"),
  JamOperasiHarian = c(16, 16, 16, 16, 8, 8)
)

penyebab <- c("Setup & Adjust", "Bearing Failure", "Kelistrikan",
              "Tool Wear", "Material Jam", "Preventive OK")

df <- expand.grid(Tanggal = tgl, Mesin = mesin, Shift = shift,
                  stringsAsFactors = FALSE)
df <- df[order(df$Tanggal, df$Mesin, df$Shift), ]
n  <- nrow(df)

# --- efek umur mesin: makin tua makin rawan breakdown ---
f_umur <- setNames(c(0.6, 2.2, 0.7, 2.0, 1.0, 0.4), mesin)   # M-02 & M-04 tua
f_shift <- c(Pagi = 1.0, Siang = 0.9, Malam = 1.4)            # malam rawan

# --- probabilitas breakdown per shift ---
p_break <- 0.05 * f_umur[df$Mesin] * f_shift[df$Shift]
df$Breakdown <- rbinom(n, 1, pmin(p_break, 0.6))

# --- durasi perbaikan (menit): lognormal, mesin tua sedikit lebih lama ---
mttr_mean <- 22 * (1 + 0.04 * (mesin_dim$UmurTahun[match(df$Mesin, mesin_dim$Mesin)] - 5))
df$WaktuPerbaikanMenit <- ifelse(
  df$Breakdown == 1,
  round(rlnorm(n, log(mttr_mean), 0.35)),
  0
)
# --- penyebab (hanya saat breakdown) ---
p_peny <- setNames(c(0.22, 0.28, 0.14, 0.18, 0.16, 0.02), penyebab)
# mesin tua lebih sering Bearing Failure / Tool Wear
df$Penyebab <- ifelse(df$Breakdown == 1,
                      sample(penyebab, n, replace = TRUE, prob = p_peny),
                      "Preventive OK")
df$Penyebab[df$Breakdown == 1 & df$Mesin %in% c("M-02", "M-04")] <-
  sample(c("Bearing Failure", "Tool Wear", "Kelistrikan"), 
         sum(df$Breakdown == 1 & df$Mesin %in% c("M-02", "M-04")),
         replace = TRUE, prob = c(0.5, 0.3, 0.2))

# --- downtime terencana (setiap Senin: preventive maintenance 30 menit) ---
df$DowntimeTerencana <- ifelse(format(df$Tanggal, "%u") == "1", 30, 0)

# --- total downtime & output ---
df$DowntimeMenit <- df$WaktuPerbaikanMenit + df$DowntimeTerencana
detail_menit <- ifelse(df$Breakdown == 1, df$WaktuPerbaikanMenit, 0)
jam_ops <- mesin_dim$JamOperasiHarian[match(df$Mesin, mesin_dim$Mesin)]
df$UnitsProduced <- round(
  pmax(jam_ops * 60 - detail_menit, 0) *
    rnorm(n, 0.85, 0.06)
)

df <- df[, c("Tanggal", "Mesin", "Shift", "Breakdown", "Penyebab",
             "WaktuPerbaikanMenit", "DowntimeTerencana", "DowntimeMenit",
             "UnitsProduced")]
write.csv(df, file.path(base, "data", "downtime.csv"), row.names = FALSE)
write.csv(mesin_dim, file.path(base, "data", "mesin.csv"), row.names = FALSE)

cat("downtime.csv :", nrow(df), "baris x", ncol(df), "kolom\n")
cat("mesin.csv    :", nrow(mesin_dim), "baris x", ncol(mesin_dim), "kolom\n\n")
cat("Total downtime per mesin (menit):\n")
print(round(tapply(df$DowntimeMenit, df$Mesin, sum)))
cat("\nJumlah breakdown per mesin:\n")
print(tapply(df$Breakdown, df$Mesin, sum))
cat("\nPenyebab dominan:\n")
print(sort(table(df$Penyebab[df$Breakdown == 1]), decreasing = TRUE))
print(head(df, 4))
