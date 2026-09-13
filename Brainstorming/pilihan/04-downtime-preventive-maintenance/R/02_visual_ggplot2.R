# ============================================================
# Opsi 4 - Downtime & Preventive Maintenance (TPM)
# R/02_visual_ggplot2.R  --  visual eksplorasi (ggplot2) -> output/*.png
# ============================================================

suppressMessages({ library(dplyr); library(tidyr); library(ggplot2); library(scales) })

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
out  <- file.path(base, "output"); dir.create(out, showWarnings = FALSE)

d <- read.csv(file.path(base, "data", "downtime.csv")) |>
  mutate(Tanggal = as.Date(Tanggal),
         Mesin   = factor(Mesin),
         Shift   = factor(Shift, levels = c("Pagi", "Siang", "Malam")),
         Bulan   = format(Tanggal, "%Y-%m"))
mesin <- read.csv(file.path(base, "data", "mesin.csv"))
d <- d |> left_join(mesin, by = "Mesin")

tema <- theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(color = "grey40"))

simpan <- function(nm, p, w = 8, h = 4.6)
  ggsave(file.path(out, nm), p, width = w, height = h, dpi = 150, bg = "white")

# --- V1: Pareto penyebab breakdown + garis kumulatif ---
pareto <- d |> filter(Breakdown == 1, !is.na(Penyebab)) |>
  count(Penyebab, name = "Jumlah") |>
  arrange(desc(Jumlah)) |>
  mutate(Persen = Jumlah / sum(Jumlah),
         Kumulatif = cumsum(Persen),
         Penyebab = factor(Penyebab, levels = Penyebab))

p1 <- ggplot(pareto, aes(x = Penyebab)) +
  geom_col(aes(y = Jumlah), fill = "steelblue", width = 0.7) +
  geom_text(aes(y = Jumlah, label = Jumlah), vjust = -0.3, size = 3) +
  geom_line(aes(y = Kumulatif * max(Jumlah), group = 1), color = "darkred", linewidth = 1) +
  geom_point(aes(y = Kumulatif * max(Jumlah)), color = "darkred", size = 2) +
  geom_hline(aes(yintercept = 0.8 * max(Jumlah)), linetype = "dashed", color = "grey50") +
  scale_y_continuous(sec.axis = sec_axis(~ . / max(pareto$Jumlah),
                                         labels = percent_format(accuracy = 1))) +
  labs(title = "Pareto penyebab breakdown",
       subtitle = "Bearing Failure (41%) + Tool Wear (26%) = 67% dari total breakdown",
       x = NULL, y = "Jumlah breakdown") +
  tema + theme(axis.text.x = element_text(angle = 20, hjust = 1))
simpan("V1_pareto_penyebab.png", p1)

# --- V2: MTBF per mesin (urut naik) ---
mttr_tbl <- d |> filter(Breakdown == 1, !is.na(WaktuPerbaikanMenit)) |>
  group_by(Mesin) |> summarise(MTTR = mean(WaktuPerbaikanMenit), .groups = "drop")

mtbf <- d |> group_by(Mesin) |>
  summarise(Breakdown = sum(Breakdown),
            Ops = sum(JamOperasiHarian / 3 * 60), .groups = "drop") |>
  left_join(mttr_tbl, by = "Mesin") |>
  mutate(MTBF = Ops / Breakdown)

p2 <- ggplot(mtbf, aes(x = reorder(Mesin, MTBF), y = MTBF, fill = MTBF)) +
  geom_col(width = 0.65) +
  geom_text(aes(label = comma(round(MTBF))), hjust = -0.15, size = 3.2) +
  coord_flip() +
  scale_fill_gradient(low = "#C44E52", high = "#55A868") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(title = "MTBF per mesin (menit antar breakdown)",
       subtitle = "Makin tinggi makin andal; M-02 & M-04 (mesin tua) paling rendah",
       x = NULL, y = "MTBF (menit)") +
  tema + theme(legend.position = "none")
simpan("V2_mtbf_mesin.png", p2)
# --- V3: Tren downtime bulanan - terencana vs tak terduga ---
tren <- d |>
  group_by(Bulan) |>
  summarise(Terencana = sum(DowntimeTerencana),
            TakTerduga = sum(WaktuPerbaikanMenit), .groups = "drop") |>
  pivot_longer(c(Terencana, TakTerduga), names_to = "Jenis", values_to = "Menit") |>
  mutate(Bulan = as.Date(paste0(Bulan, "-01")),
         Jenis = factor(Jenis, levels = c("TakTerduga", "Terencana")))

p3 <- ggplot(tren, aes(x = Bulan, y = Menit, fill = Jenis)) +
  geom_col(width = 20) +
  scale_fill_manual(values = c(Terencana = "#55A868", TakTerduga = "#C44E52"),
                    labels = c(Terencana = "Terencana (PM)", TakTerduga = "Tak terduga (breakdown)")) +
  scale_y_continuous(labels = comma_format()) +
  scale_x_date(date_labels = "%b %Y", date_breaks = "2 months") +
  labs(title = "Tren downtime bulanan: terencana vs tak terduga",
       subtitle = "73.6% downtime memang terencana (PM Senin); 26.4% tak terduga = target reduksi",
       x = NULL, y = "Total downtime (menit)", fill = NULL) +
  tema
simpan("V3_tren_downtime.png", p3, w = 9, h = 4.6)

# --- V4: Heatmap downtime Mesin x Shift ---
hm <- d |>
  group_by(Mesin, Shift) |>
  summarise(Downtime = mean(DowntimeMenit), .groups = "drop")

p4 <- ggplot(hm, aes(x = Shift, y = Mesin, fill = Downtime)) +
  geom_tile(color = "white", linewidth = 0.8) +
  geom_text(aes(label = round(Downtime, 1)), size = 3.2, color = "grey15") +
  scale_fill_gradient(low = "#EAF2FB", high = "#C44E52") +
  labs(title = "Rata-rata downtime per mesin x shift (menit)",
       subtitle = "Malam konsisten lebih merah; M-02 & M-04 tertinggi di semua shift",
       x = "Shift", y = NULL, fill = "Menit") +
  tema
simpan("V4_heatmap_mesin_shift.png", p4, w = 7, h = 4.6)

# --- V5: MTTR per mesin (rata-rata waktu perbaikan) + ANOVA ---
mttr <- d |> filter(Breakdown == 1, !is.na(WaktuPerbaikanMenit)) |>
  group_by(Mesin) |>
  summarise(MTTR = mean(WaktuPerbaikanMenit),
            se = sd(WaktuPerbaikanMenit) / sqrt(n()), .groups = "drop") |>
  mutate(lwr = MTTR - 1.96 * se, upr = MTTR + 1.96 * se)

p5 <- ggplot(mttr, aes(x = reorder(Mesin, MTTR), y = MTTR, fill = MTTR)) +
  geom_col(width = 0.65) +
  geom_errorbar(aes(ymin = lwr, ymax = upr), width = 0.18, linewidth = 0.8) +
  geom_text(aes(label = sprintf("%.1f", MTTR)), vjust = -0.4, size = 3.2) +
  coord_flip() +
  scale_fill_gradient(low = "#55A868", high = "#C44E52") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(title = "MTTR per mesin (rata-rata waktu perbaikan, menit)",
       subtitle = "ANOVA antar mesin: F = 13.75; p = 1.11e-12 - berbeda nyata",
       x = NULL, y = "MTTR (menit)") +
  tema + theme(legend.position = "none")
simpan("V5_mttr_mesin.png", p5)
# --- V6: Proporsi breakdown per shift + CI 95% ---
prop_shift <- d |>
  group_by(Shift) |>
  summarise(Breakdown = sum(Breakdown), N = n(), .groups = "drop") |>
  mutate(Rate = Breakdown / N,
         se = sqrt(Rate * (1 - Rate) / N),
         lwr = Rate - 1.96 * se, upr = Rate + 1.96 * se)

p6 <- ggplot(prop_shift, aes(x = Shift, y = Rate, fill = Shift)) +
  geom_col(alpha = 0.85, width = 0.6) +
  geom_errorbar(aes(ymin = lwr, ymax = upr), width = 0.15, linewidth = 0.9) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  scale_fill_manual(values = c(Pagi = "#55A868", Siang = "#DD8452", Malam = "#C44E52")) +
  labs(title = "Proporsi shift dengan breakdown, per shift",
       subtitle = "Uji proporsi Malam vs Pagi: X2 = 18.92; p = 1.36e-05 - Malam signifikan lebih rawan",
       x = "Shift", y = "Proporsi shift breakdown", fill = "Shift") +
  tema
simpan("V6_proporsi_shift.png", p6)

# --- V7: Regresi laju breakdown ~ umur mesin ---
level_mesin <- d |>
  group_by(Mesin, UmurTahun, Line) |>
  summarise(Breakdown = sum(Breakdown), JamOps = sum(JamOperasiHarian / 3),
            .groups = "drop") |>
  mutate(Laju = Breakdown / JamOps * 1000)
reg <- lm(Laju ~ UmurTahun, data = level_mesin)

p7 <- ggplot(level_mesin, aes(x = UmurTahun, y = Laju)) +
  geom_smooth(method = "lm", formula = y ~ x, color = "darkred", fill = "grey85", se = TRUE) +
  geom_point(aes(color = Line), size = 4) +
  geom_text(aes(label = Mesin), vjust = -1.1, size = 3) +
  labs(title = "Laju breakdown vs umur mesin",
       subtitle = sprintf("slope = %.2f breakdown per 1000 jam/tahun; R2 = %.2f; p = %.3f",
                          coef(reg)[2], summary(reg)$r.squared,
                          summary(reg)$coefficients[2, 4]),
       x = "Umur mesin (tahun)", y = "Breakdown per 1000 jam operasi", color = "Line") +
  tema
simpan("V7_regresi_umur.png", p7)

# --- V8: Availability per mesin + target ---
avail <- d |>
  filter(Breakdown == 1, !is.na(WaktuPerbaikanMenit)) |>
  group_by(Mesin) |>
  summarise(Breakdown = n(),
            MTTR = mean(WaktuPerbaikanMenit), .groups = "drop") |>
  left_join(
    d |> group_by(Mesin) |> summarise(OpsMenit = sum(JamOperasiHarian / 3 * 60), .groups = "drop"),
    by = "Mesin"
  ) |>
  mutate(MTBF = OpsMenit / Breakdown,
         Availability = MTBF / (MTBF + MTTR))

p8 <- ggplot(avail, aes(x = reorder(Mesin, Availability), y = Availability, fill = Availability)) +
  geom_col(width = 0.65) +
  geom_hline(yintercept = 0.99, linetype = "dashed", color = "darkred", linewidth = 0.9) +
  geom_text(aes(label = sprintf("%.3f", Availability)), hjust = -0.1, size = 3.2) +
  coord_flip() +
  scale_fill_gradient(low = "#C44E52", high = "#55A868") +
  scale_y_continuous(limits = c(0.96, 1.001), expand = expansion(mult = c(0, 0.05))) +
  labs(title = "Availability per mesin (MTBF / (MTBF + MTTR))",
       subtitle = "Garis putus-putus = target 99.0%; M-02 & M-04 sudah di bawah target",
       x = NULL, y = "Availability") +
  tema + theme(legend.position = "none")
simpan("V8_availability.png", p8)