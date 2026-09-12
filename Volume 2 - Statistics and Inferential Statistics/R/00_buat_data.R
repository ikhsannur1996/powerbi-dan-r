# ============================================================
# Volume 2 — Statistics & Inferential Statistics
# 00_buat_data.R  —  generator data (reproducible, set.seed)
# ============================================================
# Menghasilkan 2 berkas di folder data/:
#   1. statistik_sample.csv  — data inspeksi (uji t, ANOVA, proporsi,
#                              chi-square, korelasi, regresi)
#   2. pelatihan_sample.csv  — data sebelum/sesudah pelatihan (uji t berpasangan)
#
# PRINSIP: "pola sengaja ditanam" supaya setiap uji menemukan sesuatu
#          yang bisa diinterpretasikan — seperti data lapangan nyata.
# ============================================================

set.seed(20260801)

base <- "/Users/ikhsannur1996/Documents/Power BI dan R/Volume 2 - Statistics and Inferential Statistics/data"

# ------------------------------------------------------------
# 1. DATA INSPEKSI  —  garis produksi x shift x tanggal
# ------------------------------------------------------------
tgl   <- seq(as.Date("2026-07-01"), by = "week", length.out = 40)  # 40 titik inspeksi
line  <- c("A", "B", "C")
shift <- c("Pagi", "Siang", "Malam")
ops   <- sprintf("OP%02d", 1:8)
produk <- c("Bracket", "Panel", "Housing")

df <- expand.grid(Tanggal = tgl, Shift = shift, Line = line,
                  stringsAsFactors = FALSE)
df <- df[order(df$Tanggal, df$Shift, df$Line), ]
n  <- nrow(df)                                   # 40 x 3 x 3 = 360 baris

df$Operator <- sample(ops, n, replace = TRUE)
df$Product  <- sample(produk, n, replace = TRUE, prob = c(0.40, 0.35, 0.25))
df$Inspected <- round(rnorm(n, 130, 12))
df$Inspected <- pmax(df$Inspected, 80)

# --- Efek yang ditanam pada CYCLE TIME (detik) ---
ct_line  <- c(A = 42, B = 49, C = 40)           # Line B paling lambat (+7 s)
ct_shift <- c(Pagi = 0, Siang = 1.5, Malam = 3) # Malam lebih lambat
ct_prod  <- c(Bracket = 0, Panel = 1.5, Housing = 6)
df$CycleTimeSec <- round(
  rnorm(n, ct_line[df$Line] + ct_shift[df$Shift] + ct_prod[df$Product], 2.5), 1
)

# --- Efek yang ditanam pada DEFECT RATE ---
rate_line  <- c(A = 0.025, B = 0.055, C = 0.030)               # Line B paling buruk
rate_shift <- c(Pagi = 1.00, Siang = 1.15, Malam = 1.50)       # Malam paling buruk
rate_op    <- setNames(c(0.70, 1.00, 1.10, 1.30, 0.90, 1.60, 1.00, 0.80), ops)
rate_prod  <- c(Bracket = 1.00, Panel = 1.20, Housing = 0.80)

base_rate <- rate_line[df$Line] * rate_shift[df$Shift] *
  rate_op[df$Operator] * rate_prod[df$Product]
# kaitkan defect dengan cycle time (agar korelasi & regresi bermakna)
base_rate <- base_rate * exp(0.045 * (df$CycleTimeSec - 45))
base_rate <- base_rate * rlnorm(n, 0, 0.15)

df$Defect     <- rbinom(n, df$Inspected, pmin(base_rate, 0.20))
df$DefectRate <- df$Defect / df$Inspected

# Simpan kolom inti
df <- df[, c("Tanggal", "Shift", "Line", "Operator", "Product",
             "Inspected", "Defect", "DefectRate", "CycleTimeSec")]
write.csv(df, file.path(base, "statistik_sample.csv"), row.names = FALSE)

# ------------------------------------------------------------
# 2. DATA PELATIHAN  —  pengukuran sebelum & sesudah (berpasangan)
#    Satu unit operator diukur cycle time sebelum & sesudah pelatihan.
# ------------------------------------------------------------
set.seed(20260802)
m <- 30
unit    <- sprintf("OP%02d", 1:m)
sebelum <- round(rnorm(m, 50, 4), 1)
# pelatihan menurunkan cycle time rata-rata ~4,5 detik (dengan variasi)
sesudah <- round(sebelum - rnorm(m, 4.5, 2.0), 1)

pelatihan <- data.frame(
  Operator     = unit,
  CycleTimeSebelum = sebelum,
  CycleTimeSesudah = sesudah,
  Selisih      = sebelum - sesudah          # positif = makin cepat
)
write.csv(pelatihan, file.path(base, "pelatihan_sample.csv"), row.names = FALSE)

# ------------------------------------------------------------
# Laporan singkat
# ------------------------------------------------------------
cat("statistik_sample.csv :", nrow(df), "baris x", ncol(df), "kolom\n")
cat("pelatihan_sample.csv :", nrow(pelatihan), "baris x", ncol(pelatihan), "kolom\n\n")
cat("Defect rate per lini:\n")
print(round(tapply(df$Defect, df$Line, sum) / tapply(df$Inspected, df$Line, sum), 4))
cat("\nRata-rata cycle time per lini:\n")
print(round(tapply(df$CycleTimeSec, df$Line, mean), 2))
cat("\nRata-rata selisih (Sebelum - Sesudah):",
    round(mean(pelatihan$Selisih), 2), "detik\n")
print(head(df, 3))
