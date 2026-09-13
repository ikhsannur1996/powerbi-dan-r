# ============================================================
# Opsi 1 - OEE & Mutu Lini Produksi
# R/01_analisis_dplyr.R  --  statistik & agregasi (dplyr) -> output/*.csv
# ============================================================

suppressMessages({ library(dplyr); library(tidyr); library(broom) })

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
out  <- file.path(base, "output"); dir.create(out, showWarnings = FALSE)

d <- read.csv(file.path(base, "data", "produksi.csv")) |>
  mutate(Tanggal = as.Date(Tanggal),
         Line    = factor(Line, levels = c("Line-A", "Line-B", "Line-C")),
         Shift   = factor(Shift, levels = c("Pagi", "Sore", "Malam")),
         Product = factor(Product))

# --- fungsi OEE (A x P x Q) ---
oee_calc <- function(df) {
  A <- sum(df$RunTime) / sum(df$PlannedTime)
  P <- sum(df$Output * df$IdealCycleSec / 60) / sum(df$RunTime)
  Q <- 1 - sum(df$Defect) / sum(df$Output)
  c(Availability = A, Performance = P, Quality = Q, OEE = A * P * Q)
}

cat("=== OEE KESELURUHAN ===\n")
print(round(oee_calc(d) * 100, 2))

# --- OEE per lini (tabel) ---
oee_line <- d |> group_by(Line) |>
  summarise(Availability = sum(RunTime) / sum(PlannedTime),
            Performance  = sum(Output * IdealCycleSec / 60) / sum(RunTime),
            Quality      = 1 - sum(Defect) / sum(Output),
            OEE = Availability * Performance * Quality,
            DefectRate = sum(Defect) / sum(Output),
            .groups = "drop")
print(as.data.frame(round(oee_line[, -1] * 100, 2)))
write.csv(oee_line, file.path(out, "tbl_oee_line.csv"), row.names = FALSE)

# --- OEE harian (tren) ---
oee_harian <- d |> group_by(Tanggal) |>
  summarise(OEE = (sum(RunTime) / sum(PlannedTime)) *
              (sum(Output * IdealCycleSec / 60) / sum(RunTime)) *
              (1 - sum(Defect) / sum(Output)), .groups = "drop") |>
  mutate(MA7 = stats::filter(OEE, rep(1 / 7, 7), sides = 1))
write.csv(oee_harian, file.path(out, "tbl_oee_harian.csv"), row.names = FALSE)

# --- Pareto downtime per mesin ---
pareto <- d |> group_by(MachineID) |>
  summarise(Downtime = sum(DowntimeMin), .groups = "drop") |>
  arrange(desc(Downtime)) |>
  mutate(Kumulatif = cumsum(Downtime) / sum(Downtime))
print(as.data.frame(pareto))
write.csv(pareto, file.path(out, "tbl_pareto_downtime.csv"), row.names = FALSE)

# --- Kartu kontrol defect rate harian (X-bar, 3 sigma) ---
kk <- d |> group_by(Tanggal) |>
  summarise(DefectRate = sum(Defect) / sum(Output), .groups = "drop") |>
  mutate(CL  = mean(DefectRate),
         UCL = CL + 3 * sd(DefectRate),
         LCL = pmax(0, CL - 3 * sd(DefectRate)),
         Sinyal = DefectRate > UCL | DefectRate < LCL)
cat("\nDefect rate out-of-control:", sum(kk$Sinyal), "dari", nrow(kk), "hari\n")
write.csv(kk, file.path(out, "tbl_kontrol_defect.csv"), row.names = FALSE)

# --- Process capability cycle time ---
LSL <- 1.8; USL <- 2.6
ct  <- d$CycleTimeSec
Cp  <- (USL - LSL) / (6 * sd(ct))
Cpk <- min(USL - mean(ct), mean(ct) - LSL) / (3 * sd(ct))
cat(sprintf("\nProcess capability: Cp = %.2f, Cpk = %.2f, mean = %.2f\n", Cp, Cpk, mean(ct)))
write.csv(data.frame(Cp = Cp, Cpk = Cpk, Mean = mean(ct), SD = sd(ct), LSL = LSL, USL = USL),
          file.path(out, "tbl_capability.csv"), row.names = FALSE)

# --- Uji hipotesis: cycle time Line-A vs Line-B, dan ANOVA 3 lini ---
cat("\n=== UJI HIPOTESIS ===\n")
ct_a <- d$CycleTimeSec[d$Line == "Line-A"]; ct_b <- d$CycleTimeSec[d$Line == "Line-B"]
tt <- t.test(ct_a, ct_b, var.equal = TRUE)
cat(sprintf("t-test A vs B : t = %.2f, p = %.3g\n", tt$statistic, tt$p.value))
av <- aov(CycleTimeSec ~ Line, data = d)
cat(sprintf("ANOVA 3 lini  : F = %.2f, p = %.3g\n",
            summary(av)[[1]][["F value"]][1], summary(av)[[1]][["Pr(>F)"]][1]))
prop_ab <- prop.test(c(sum(d$Defect[d$Line == "Line-A"]), sum(d$Defect[d$Line == "Line-B"])),
                     c(sum(d$Output[d$Line == "Line-A"]), sum(d$Output[d$Line == "Line-B"])))
cat(sprintf("prop.test A/B : X2 = %.2f, p = %.3g\n", prop_ab$statistic, prop_ab$p.value))

# --- Regresi: apakah cycle time memprediksi defect rate? ---
reg <- lm(DefectRate ~ CycleTimeSec, data = d |> mutate(DefectRate = Defect / Output))
cat(sprintf("Regresi defect ~ cycle time: R2 = %.3f, slope p = %.3g\n",
            summary(reg)$r.squared, tidy(reg)$p.value[2]))
saveRDS(list(oee = oee_calc(d), oee_line = oee_line, pareto = pareto, kk = kk,
             Cp = Cp, Cpk = Cpk, LSL = LSL, USL = USL,
             oee_harian = oee_harian, d = d),
        file.path(out, "hasil_opsi1.rds"))
cat("\n[semua tabel tersimpan di output/]\n")
