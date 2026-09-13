# ============================================================
# Opsi 1 - OEE & Mutu Lini Produksi
# R/00_buat_data.R  --  generator data (reproducible, set.seed)
# ============================================================
# Output: data/produksi.csv  (1 baris = 1 shift x 1 line)
# Pola sengaja ditanam supaya analisis "menemukan" sesuatu.
# ============================================================

set.seed(20260901)

# --- folder kerja relatif terhadap lokasi script ini ---
args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
dir.create(file.path(base, "data"), showWarnings = FALSE)

tgl <- seq(as.Date("2026-06-01"), as.Date("2026-08-31"), by = "day")
tgl <- tgl[format(tgl, "%u") != "7"]              # libur tiap Minggu

line  <- c("Line-A", "Line-B", "Line-C")
shift <- c("Pagi", "Sore", "Malam")
mesin <- c("M-01", "M-02", "M-03", "M-04", "M-05", "M-06")
op    <- sprintf("OP%02d", 1:10)
produk <- c("Bracket", "Housing", "Shaft")

df <- expand.grid(Tanggal = tgl, Shift = shift, Line = line,
                  stringsAsFactors = FALSE)
df <- df[order(df$Tanggal, df$Shift, df$Line), ]
n  <- nrow(df)

# --- mesin per line ---
mesin_line <- list(`Line-A` = c("M-01", "M-02"),
                   `Line-B` = c("M-03", "M-04"),
                   `Line-C` = c("M-05", "M-06"))
df$MachineID <- vapply(df$Line, function(l) sample(mesin_line[[l]], 1), character(1))
df$OperatorID <- sample(op, n, replace = TRUE)
df$Product    <- sample(produk, n, replace = TRUE, prob = c(0.4, 0.35, 0.25))

# --- Waktu (menit) ---
df$PlannedTime <- ifelse(df$Shift == "Malam", 420, 450)

# Downtime: M-02 & M-04 paling sering (pola ditanam)
faktor_mesin <- setNames(c(1.0, 2.6, 1.0, 2.4, 0.9, 1.2), mesin)
df$DowntimeMin <- round(rexp(n, 1 / 14) * faktor_mesin[df$MachineID] +
                          ifelse(df$Shift == "Malam", 6, 0))
df$DowntimeMin <- pmin(df$DowntimeMin, df$PlannedTime - 100)
df$RunTime     <- df$PlannedTime - df$DowntimeMin

# Ideal cycle time & output
df$IdealCycleSec <- ifelse(df$Product == "Shaft", 2.2,
                    ifelse(df$Product == "Housing", 2.0, 1.8))
# Performance turun bila shift Malam / mesin M-02 & M-04
perf <- 0.95 *
  ifelse(df$Shift == "Malam", 0.90, 1) *
  ifelse(df$MachineID %in% c("M-02", "M-04"), 0.94, 1)
df$Output <- round(df$RunTime * 60 / df$IdealCycleSec * perf * rnorm(n, 1, 0.03))
df$Output <- pmax(df$Output, 500)

# Cycle time aktual (detik)
df$CycleTimeSec <- round(df$RunTime * 60 / df$Output, 2)

# Defect: shift Malam x1.5, mesin bermasalah, operator skill rendah
skill <- setNames(c(1.0, 1.0, 1.1, 0.8, 1.0, 1.3, 0.9, 1.0, 1.0, 0.85), op)
rate <- 0.02 *
  ifelse(df$Shift == "Malam", 1.5, 1) *
  ifelse(df$MachineID %in% c("M-02", "M-04"), 1.35, 1) *
  skill[df$OperatorID] *
  ifelse(df$Product == "Housing", 1.2, 1)
rate <- rate * rlnorm(n, 0, 0.18)
df$Defect <- rbinom(n, df$Output, pmin(rate, 0.15))

df$ProductionID <- sprintf("PRD-%05d", seq_len(n))
df <- df[, c("ProductionID", "Tanggal", "Shift", "Line", "MachineID", "OperatorID",
             "Product", "PlannedTime", "RunTime", "DowntimeMin", "Output",
             "Defect", "IdealCycleSec", "CycleTimeSec")]

write.csv(df, file.path(base, "data", "produksi.csv"), row.names = FALSE)

# --- dimensi mesin & operator ---
mesin_dim <- data.frame(
  MachineID     = mesin,
  JenisMesin    = c("CNC", "Press", "CNC", "Press", "Milling", "Milling"),
  TahunInstalasi = c(2018, 2015, 2020, 2016, 2021, 2019),
  LineDefault   = c("Line-A", "Line-A", "Line-B", "Line-B", "Line-C", "Line-C")
)
write.csv(mesin_dim, file.path(base, "data", "mesin.csv"), row.names = FALSE)

operator_dim <- data.frame(
  OperatorID   = op,
  NamaSamaran  = paste0("Operator-", LETTERS[1:10]),
  LevelSkill   = c("Ahli", "Ahli", "Menengah", "Pemula", "Ahli",
                   "Pemula", "Menengah", "Ahli", "Ahli", "Menengah"),
  TanggalMasuk = as.Date("2026-01-01") - sample(200:1500, 10)
)
write.csv(operator_dim, file.path(base, "data", "operator.csv"), row.names = FALSE)

# --- OEE ringkas ---
oee <- with(df, mean(RunTime / PlannedTime) *
              mean(Output * IdealCycleSec / 60 / RunTime) *
              (1 - sum(Defect) / sum(Output)))
cat("produksi.csv :", nrow(df), "baris x", ncol(df), "kolom\n")
cat("OEE keseluruhan :", round(oee * 100, 2), "%\n")
cat("Defect rate     :", round(sum(df$Defect) / sum(df$Output) * 100, 2), "%\n")
cat("\nDowntime total per mesin (menit):\n")
print(round(tapply(df$DowntimeMin, df$MachineID, sum)))
print(head(df, 3))
