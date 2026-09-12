# =====================================================================
# 00_buat_data.R — Generator data sample visualisasi (Volume 1)
# =====================================================================
# File   : 00_buat_data.R
# Luaran : data/visualisasi_sample.csv  (~900 baris, 9 kolom)
# Cara   : source("Volume 1 - Basic Visualization ggplot/R/00_buat_data.R")
#          dari root repo "Power BI dan R" (atau buka-run di RStudio).
#
# Desain sengaja (planted patterns) so contoh ggplot2 "menemukan" sesuatu,
# sama filosofi volume 4 & 5:
#   - Line B defect rate lebih tinggi (~5,5%)
#   - Product Housing cycle time +6 detik
#   - Shift Malam cycle time +2 detik
#   - DefectType Scratch & Crack lebih sering di Line B
# =====================================================================

set.seed(20260701)  # reproducible

library(dplyr)      # %>% / |>
library(lubridate)  # floor_date

# ---- 1. Grid tanggal x lini -----------------------------------------
# 20 minggu, tiap Miyerkules (2026-07-01 s.d. 2026-11-12)
tgl <- seq(as.Date("2026-07-01"), as.Date("2026-11-12"), by = "week")
lini   <- c("A", "B", "C")
produk <- c("Bracket", "Panel", "Housing")
tipe   <- c("Scratch", "Dimension", "Crack", "Color", "NONE")
ops    <- paste0("OP", sprintf("%02d", 1:8))
shift  <- c("Pagi", "Siang", "Malam")

# ---------------------------------------------------------------------
# 2. Grid base: tiap minggu, tiap lini, 15 inspeksi => 20*3*15 = 900
# ---------------------------------------------------------------------
df <- expand.grid(
  InspectionDate = tgl,
  Line           = lini,
  idx            = 1:15,
  stringsAsFactors = FALSE
)
n <- nrow(df)
df$idx <- NULL

# Kolom kategori
df$Product    <- sample(produk, n, replace = TRUE, prob = c(0.40, 0.35, 0.25))
df$Operator   <- sample(ops,   n, replace = TRUE)
df$Shift      <- sample(shift, n, replace = TRUE, prob = c(0.35, 0.35, 0.30))

# DefectType: line B lebih sering Scratch/Crack
prob_tipe <- list(
  A = c(0.18, 0.18, 0.10, 0.12, 0.42),
  B = c(0.26, 0.14, 0.22, 0.08, 0.30),
  C = c(0.14, 0.20, 0.06, 0.12, 0.48)
)
df$DefectType <- sapply(as.character(df$Line),
                        function(ln) sample(tipe, 1, prob = prob_tipe[[ln]]))

# ---- 3. Kolom numerik --------------------------------------------------
# Inspected ~ 110-150
df$Inspected <- round(rnorm(n, 125, 9))
df$Inspected <- pmax(df$Inspected, 90)

# Defect rate dasar per lini (planted pattern!) + noise lognormal
rate_line <- c(A = 0.035, B = 0.055, C = 0.025)
df$Defect  <- rbinom(n, df$Inspected,
                     pmin(rate_line[df$Line] * rlnorm(n, 0, 0.35), 0.15))

# Cycle time: base 42 + per lini + per produk + shift Malam + noise
ct_line   <- c(A = 0, B = 2, C = 1)
ct_produk <- c(Bracket = 0, Panel = 1, Housing = 6)
df$CycleTimeSec <- round(
  42 + ct_line[df$Line] + ct_produk[df$Product] +
    ifelse(df$Shift == "Malam", 2, 0) + rnorm(n, 0, 2.2), 1)

# ---- 4. Tipe final + simpan ------------------------------------------
df$InspectionDate <- as.Date(df$InspectionDate)
df$Line    <- factor(df$Line,    levels = lini)
df$Product <- factor(df$Product, levels = produk)
df$DefectType <- factor(df$DefectType, levels = tipe)

# Path relatif terhadap root repo "Power BI dan R" agar portabel
ROOT <- "Volume 1 - Basic Visualization ggplot"
out  <- file.path(ROOT, "data", "visualisasi_sample.csv")
dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
write.csv(df, out, row.names = FALSE)

cat("baris:", nrow(df), " kolom:", ncol(df), "\n")
cat("simpan  :", out, "\n")
print(df |>
  mutate(DefectRate = Defect / Inspected) |>
  group_by(Line) |>
  summarise(DefectRate = sum(Defect) / sum(Inspected),
            RataCT = mean(CycleTimeSec), .groups = "drop"))