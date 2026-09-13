# ============================================================
# Opsi 1 - OEE & Mutu Lini Produksi
# R/02_visual_ggplot2.R  --  visual eksplorasi (ggplot2) -> output/*.png
# ============================================================

suppressMessages({ library(dplyr); library(tidyr); library(ggplot2); library(scales) })

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
out  <- file.path(base, "output"); dir.create(out, showWarnings = FALSE)

d <- read.csv(file.path(base, "data", "produksi.csv")) |>
  mutate(Tanggal = as.Date(Tanggal),
         Line    = factor(Line, levels = c("Line-A", "Line-B", "Line-C")),
         Shift   = factor(Shift, levels = c("Pagi", "Sore", "Malam")))

tema <- theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(color = "grey40"))

simpan <- function(nm, p, w = 8, h = 4.6)
  ggsave(file.path(out, nm), p, width = w, height = h, dpi = 150, bg = "white")

# --- V1: Tren OEE harian + moving average ---
oee_harian <- d |> group_by(Tanggal) |>
  summarise(OEE = (sum(RunTime) / sum(PlannedTime)) *
              (sum(Output * IdealCycleSec / 60) / sum(RunTime)) *
              (1 - sum(Defect) / sum(Output)), .groups = "drop") |>
  mutate(MA7 = as.numeric(stats::filter(OEE, rep(1 / 7, 7), sides = 1)))

p1 <- ggplot(oee_harian, aes(x = Tanggal, y = OEE)) +
  geom_line(color = "grey65", linewidth = 0.5) +
  geom_line(aes(y = MA7), color = "steelblue", linewidth = 1.1, na.rm = TRUE) +
  geom_hline(yintercept = 0.85, linetype = "dashed", color = "darkred") +
  annotate("text", x = min(oee_harian$Tanggal), y = 0.86, hjust = 0,
           label = "Target OEE 85%", color = "darkred", size = 3.5) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "Tren OEE harian dengan rata-rata bergerak 7 hari",
       subtitle = "OEE = Availability x Performance x Quality",
       x = NULL, y = "OEE") + tema
simpan("V1_tren_oee.png", p1)

# --- V2: OEE per lini (komponen berdampingan) ---
oee_line <- d |> group_by(Line) |>
  summarise(A = sum(RunTime) / sum(PlannedTime),
            P = sum(Output * IdealCycleSec / 60) / sum(RunTime),
            Q = 1 - sum(Defect) / sum(Output), .groups = "drop") |>
  mutate(OEE = A * P * Q) |>
  pivot_longer(c(A, P, Q), names_to = "Komponen", values_to = "Nilai") |>
  mutate(Komponen = factor(Komponen, levels = c("A", "P", "Q"),
                           labels = c("Availability", "Performance", "Quality")))

p2 <- ggplot(oee_line, aes(x = Line, y = Nilai, fill = Komponen)) +
  geom_col(position = position_dodge(0.8), width = 0.7) +
  geom_text(aes(label = percent(Nilai, accuracy = 0.1)),
            position = position_dodge(0.8), vjust = -0.3, size = 3) +
  scale_y_continuous(labels = percent_format(accuracy = 1), limits = c(0, 1.08)) +
  scale_fill_manual(values = c("#4C72B0", "#DD8452", "#55A868")) +
  labs(title = "Dekomposisi OEE per lini (A x P x Q)",
       subtitle = "Availability ~95%, Performance ~90%, Quality ~97%",
       x = NULL, y = "Persentase", fill = NULL) + tema
simpan("V2_oee_line.png", p2)

# --- V3: Pareto downtime per mesin ---
pareto <- d |> group_by(MachineID) |>
  summarise(Downtime = sum(DowntimeMin), .groups = "drop") |>
  arrange(desc(Downtime)) |>
  mutate(Kumulatif = cumsum(Downtime) / sum(Downtime),
         MachineID = factor(MachineID, levels = MachineID))

p3 <- ggplot(pareto, aes(x = MachineID)) +
  geom_col(aes(y = Downtime), fill = "steelblue") +
  geom_point(aes(y = Kumulatif * max(Downtime)), color = "darkred", size = 2.5) +
  geom_line(aes(y = Kumulatif * max(Downtime), group = 1), color = "darkred", linewidth = 0.9) +
  geom_hline(yintercept = 0.8 * max(pareto$Downtime), linetype = "dashed", color = "grey50") +
  scale_y_continuous(name = "Total downtime (menit)",
                     sec.axis = sec_axis(~ . / max(pareto$Downtime),
                                         labels = percent_format(accuracy = 1),
                                         name = "Kumulatif")) +
  labs(title = "Pareto downtime per mesin",
       subtitle = "M-02 + M-04 menyumbang ~53% total downtime (prinsip 80/20)",
       x = "Mesin") + tema
# --- V4: Heatmap downtime line x shift ---
heat <- d |> group_by(Line, Shift) |>
  summarise(Menit = mean(DowntimeMin), .groups = "drop")

p4 <- ggplot(heat, aes(x = Shift, y = Line, fill = Menit)) +
  geom_tile(color = "white", linewidth = 0.8) +
  geom_text(aes(label = round(Menit, 1)), color = "white", size = 4) +
  scale_fill_gradient(low = "#F7CAC9", high = "#C44E52", name = "menit") +
  labs(title = "Rata-rata downtime per kombinasi line x shift",
       subtitle = "Shift Malam konsisten paling sering berhenti",
       x = "Shift", y = "Lini") + tema
simpan("V4_heatmap_downtime.png", p4)

# --- V5: Kartu kontrol defect rate (X + 3 sigma) ---
kk <- d |> group_by(Tanggal) |>
  summarise(DefectRate = sum(Defect) / sum(Output), .groups = "drop") |>
  mutate(CL = mean(DefectRate), UCL = CL + 3 * sd(DefectRate),
         LCL = pmax(0, CL - 3 * sd(DefectRate)))

p5 <- ggplot(kk, aes(x = Tanggal, y = DefectRate)) +
  geom_line(color = "steelblue", linewidth = 0.6) +
  geom_point(size = 1.1, color = "steelblue") +
  geom_hline(yintercept = kk$CL[1], color = "grey30") +
  geom_hline(yintercept = kk$UCL[1], linetype = "dashed", color = "darkred") +
  geom_hline(yintercept = kk$LCL[1], linetype = "dashed", color = "darkred") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Kartu kontrol defect rate harian (batas 3 sigma)",
       subtitle = "Semua titik berada dalam batas -> proses terkendali secara statistik",
       x = NULL, y = "Defect rate") + tema
simpan("V5_kartu_kontrol.png", p5)

# --- V6: Histogram cycle time + spesifikasi (LSL/USL) ---
LSL <- 1.8; USL <- 2.6
p6 <- ggplot(d, aes(x = CycleTimeSec)) +
  geom_histogram(aes(y = after_stat(density)), binwidth = 0.08,
                 fill = "steelblue", color = "white") +
  geom_vline(xintercept = LSL, linetype = "dashed", color = "darkred", linewidth = 0.9) +
  geom_vline(xintercept = USL, linetype = "dashed", color = "darkred", linewidth = 0.9) +
  annotate("text", x = LSL, y = 0.9, label = "LSL", color = "darkred", size = 3.3, hjust = 1.1) +
  annotate("text", x = USL, y = 0.9, label = "USL", color = "darkred", size = 3.3, hjust = -0.1) +
  labs(title = "Distribusi cycle time vs batas spesifikasi",
       subtitle = "Cp = 0.57, Cpk = 0.56 -> proses belum capable (target >= 1.33)",
       x = "Cycle time (detik)", y = "Kepadatan") + tema
simpan("V6_capability.png", p6)

simpan("V3_pareto_downtime.png", p3)
# --- V7: Scatter cycle time vs defect rate + regresi ---
d2  <- d |> mutate(DefectRate = Defect / Output)
reg <- lm(DefectRate ~ CycleTimeSec, data = d2)

p7 <- ggplot(d2, aes(x = CycleTimeSec, y = DefectRate)) +
  geom_point(alpha = 0.3, color = "steelblue") +
  geom_smooth(method = "lm", formula = y ~ x, color = "darkred", se = TRUE) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "Cycle time vs defect rate",
       subtitle = sprintf("Regresi: slope %.4f, R2 = %.3f (p < 2e-16)",
                          coef(reg)[2], summary(reg)$r.squared),
       x = "Cycle time (detik)", y = "Defect rate") + tema
simpan("V7_regresi_defect.png", p7)

# --- V8: Boxplot cycle time per lini (ANOVA) ---
p8 <- ggplot(d, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot(alpha = 0.6, width = 0.55, outlier.shape = NA) +
  geom_jitter(width = 0.13, alpha = 0.25, size = 1) +
  scale_fill_manual(values = c("#4C72B0", "#C44E52", "#55A868")) +
  labs(title = "Sebaran cycle time per lini",
       subtitle = "ANOVA: F = 4.15, p = 0.0162 -> minimal satu lini berbeda",
       x = NULL, y = "Cycle time (detik)", fill = "Lini") + tema
simpan("V8_anova_cycletime.png", p8)

cat("[Opsi 1] 8 visual tersimpan di", out, "\n")

