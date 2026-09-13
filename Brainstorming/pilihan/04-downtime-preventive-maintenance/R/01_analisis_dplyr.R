# ============================================================
# Opsi 4 - Downtime & Preventive Maintenance (TPM)
# R/01_analisis_dplyr.R  --  statistik & agregasi (dplyr) -> output/*.csv
# ============================================================
# MTBF  = total waktu operasi / jumlah breakdown
# MTTR  = rata-rata waktu perbaikan (hanya saat breakdown)
# Availability = MTBF / (MTBF + MTTR)
# ============================================================

suppressMessages({ library(dplyr); library(tidyr); library(broom) })

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
out  <- file.path(base, "output"); dir.create(out, showWarnings = FALSE)

d     <- read.csv(file.path(base, "data", "downtime.csv")) |>
  mutate(Tanggal = as.Date(Tanggal),
         Mesin   = factor(Mesin),
         Shift   = factor(Shift, levels = c("Pagi", "Siang", "Malam")),
         Bulan   = format(Tanggal, "%Y-%m"))
mesin <- read.csv(file.path(base, "data", "mesin.csv"))

d <- d |> left_join(mesin, by = "Mesin") |>
  mutate(JamOps = JamOperasiHarian / 3,          # tiap baris = 1 shift
         KelompokUmur = ifelse(UmurTahun >= 8, "Tua (>=8 th)", "Muda (<8 th)"))

# ------------------------------------------------------------
# 1. AGREGASI DASAR
# ------------------------------------------------------------
cat("=== TOTAL DOWNTIME PER MESIN ===\n")
mttr_tbl <- d |> filter(Breakdown == 1) |>
  group_by(Mesin) |>
  summarise(MTTR = mean(WaktuPerbaikanMenit), .groups = "drop")

per_mesin <- d |>
  group_by(Mesin, Line, UmurTahun, JamOps) |>
  summarise(TotalDowntime = sum(DowntimeMenit),
            Breakdown     = sum(Breakdown),
            TotalOpsMenit = sum(JamOps * 60),
            .groups = "drop") |>
  left_join(mttr_tbl, by = "Mesin") |>
  mutate(MTBF         = TotalOpsMenit / Breakdown,
         Availability = MTBF / (MTBF + MTTR))
print(as.data.frame(per_mesin |> mutate(across(where(is.numeric), ~ round(.x, 4)))))
write.csv(per_mesin, file.path(out, "tbl_per_mesin.csv"), row.names = FALSE)

cat("\n=== DOWNTIME PER LINE ===\n")
per_line <- d |> group_by(Line) |>
  summarise(TotalDowntime = sum(DowntimeMenit), Breakdown = sum(Breakdown),
            UnitProduksi = sum(UnitsProduced), .groups = "drop")
print(as.data.frame(per_line))
write.csv(per_line, file.path(out, "tbl_per_line.csv"), row.names = FALSE)

# ------------------------------------------------------------
# 2. PARETO PENYEBAB
# ------------------------------------------------------------
cat("\n=== PARETO PENYEBAB BREAKDOWN ===\n")
pareto <- d |> filter(Breakdown == 1) |>
  count(Penyebab, name = "Jumlah") |>
  arrange(desc(Jumlah)) |>
  mutate(Persen = Jumlah / sum(Jumlah) * 100,
         Kumulatif = cumsum(Persen))
print(as.data.frame(pareto |> mutate(across(where(is.numeric), ~ round(.x, 2)))))
write.csv(pareto, file.path(out, "tbl_pareto_penyebab.csv"), row.names = FALSE)

# ------------------------------------------------------------
# 3. UJI STATISTIK
# ------------------------------------------------------------
cat("\n=== UJI STATISTIK ===\n")
# 3a. Proporsi breakdown: shift Malam vs Pagi
malam <- d |> filter(Shift == "Malam"); pagi <- d |> filter(Shift == "Pagi")
pt <- prop.test(c(sum(malam$Breakdown), sum(pagi$Breakdown)),
                c(nrow(malam), nrow(pagi)))
cat(sprintf("Proporsi breakdown Malam vs Pagi: X2 = %.2f, p = %.3g\n",
            pt$statistic, pt$p.value))

# 3b. ANOVA: downtime perbaikan antar mesin
aov_fit <- aov(WaktuPerbaikanMenit ~ Mesin, data = d |> filter(Breakdown == 1))
aov_tab <- tidy(aov_fit)
cat(sprintf("ANOVA MTTR antar mesin: F = %.2f, p = %.3g\n",
            aov_tab$statistic[1], aov_tab$p.value[1]))

# 3c. Uji t: mesin tua vs muda (downtime harian, hanya hari breakdown)
tt <- t.test(DowntimeMenit ~ KelompokUmur, data = d |> filter(Breakdown == 1),
             var.equal = TRUE)
cat(sprintf("Uji t mesin tua vs muda (downtime per breakdown): selisih = %.1f menit, t = %.2f, p = %.3g\n",
            diff(rev(tt$estimate)), tt$statistic, tt$p.value))

# 3d. Regresi (level mesin): umur -> laju breakdown per 1000 jam operasi
level_mesin <- d |>
  group_by(Mesin, UmurTahun) |>
  summarise(Breakdown = sum(Breakdown), JamOps = sum(JamOps), .groups = "drop") |>
  mutate(Laju = Breakdown / JamOps * 1000)
reg_umur <- lm(Laju ~ UmurTahun, data = level_mesin)
r2 <- summary(reg_umur)$r.squared
cat(sprintf("Regresi laju breakdown ~ umur mesin: slope = %.3f per tahun, R2 = %.3f, p = %.3g\n",
            coef(reg_umur)[2], r2, tidy(reg_umur)$p.value[2]))

# 3e. Korelasi downtime vs output (hanya mesin jam operasi sama: Line-A & Line-B)
sub4 <- d |> filter(Line %in% c("Line-A", "Line-B"))
ct <- cor.test(sub4$DowntimeMenit, sub4$UnitsProduced)
cat(sprintf("Korelasi downtime vs output (Line-A/B): r = %.3f, p = %.3g\n", ct$estimate, ct$p.value))

# ------------------------------------------------------------
# 4. TREN BULANAN & DOWNTIME TERENCANA
# ------------------------------------------------------------
cat("\n=== TREN BULANAN ===\n")
tren <- d |> group_by(Bulan) |>
  summarise(Downtime = sum(DowntimeMenit), Breakdown = sum(Breakdown),
            Terencana = sum(DowntimeTerencana), .groups = "drop") |>
  mutate(Bulan = as.Date(paste0(Bulan, "-01")))
print(tail(as.data.frame(tren), 4))
write.csv(tren, file.path(out, "tbl_tren_bulanan.csv"), row.names = FALSE)

ringkasan_pm <- d |> summarise(
  DowntimeTotal     = sum(DowntimeMenit),
  DowntimeTerencana = sum(DowntimeTerencana),
  DowntimeTakTerduga = sum(WaktuPerbaikanMenit))
cat(sprintf("\nDowntime terencana: %.0f menit (%.1f%%); tak terduga: %.0f menit (%.1f%%)\n",
            ringkasan_pm$DowntimeTerencana,
            ringkasan_pm$DowntimeTerencana / ringkasan_pm$DowntimeTotal * 100,
            ringkasan_pm$DowntimeTakTerduga,
            ringkasan_pm$DowntimeTakTerduga / ringkasan_pm$DowntimeTotal * 100))

saveRDS(list(per_mesin = per_mesin, per_line = per_line, pareto = pareto,
             tren = tren, d = d, mesin = mesin, aov_tab = aov_tab,
             tt = tt, reg_umur = reg_umur, ringkasan_pm = ringkasan_pm),
        file.path(out, "hasil_opsi4.rds"))
cat("\nAnalisis Opsi 4 selesai. Tabel tersimpan di output/.\n")
