# ============================================================
# Opsi 2 - Pengendalian Kualitas Statistik (SPC)
# R/02_visual_ggplot2.R  --  visual (ggplot2) -> output/V*.png
# ============================================================

suppressMessages({ library(dplyr); library(tidyr); library(ggplot2); library(scales) })

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
out  <- file.path(base, "output"); dir.create(out, showWarnings = FALSE)

d <- read.csv(file.path(base, "data", "qc_karakteristik.csv")) |>
  mutate(Karakteristik = factor(Karakteristik),
         Shift = factor(Shift, levels = c("Pagi", "Sore", "Malam")),
         Mesin = factor(Mesin))
spek <- read.csv(file.path(base, "data", "spesifikasi.csv"))
H <- readRDS(file.path(out, "hasil_opsi2.rds"))
peta <- H$peta; capability <- H$capability

tema <- theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(color = "grey40"))
simpan <- function(nm, p, w = 8, h = 4.6)
  ggsave(file.path(out, nm), p, width = w, height = h, dpi = 150, bg = "white")

# --- V1: X-bar control chart (Diameter) ---
px <- peta |> filter(Karakteristik == "Diameter")
p1 <- ggplot(px, aes(x = Subgroup, y = Xbar)) +
  geom_hline(yintercept = px$Xbarbar[1], color = "grey40") +
  geom_hline(yintercept = px$UCL_x[1], color = "darkred", linetype = "dashed") +
  geom_hline(yintercept = px$LCL_x[1], color = "darkred", linetype = "dashed") +
  geom_line(color = "grey60") +
  geom_point(aes(color = OutOfControl), size = 2.2) +
  scale_color_manual(values = c(`FALSE` = "steelblue", `TRUE` = "red"), guide = "none") +
  annotate("rect", xmin = 17.5, xmax = 21.5, ymin = -Inf, ymax = Inf,
           alpha = 0.08, fill = "red") +
  labs(title = "Peta kendali X-bar - Diameter (n = 5)",
       subtitle = "Garis merah = UCL/LCL; area merah = shift Malam (subgroup 18-21)",
       x = "Nomor subgroup", y = "Rata-rata subgroup (mm)") + tema
simpan("V1_peta_xbar.png", p1)

# --- V2: R chart (Diameter) ---
p2 <- ggplot(px, aes(x = Subgroup, y = R)) +
  geom_hline(yintercept = px$Rbar[1], color = "grey40") +
  geom_hline(yintercept = px$UCL_r[1], color = "darkred", linetype = "dashed") +
  geom_line(color = "grey60") + geom_point(color = "steelblue", size = 1.8) +
  labs(title = "Peta kendali R - Diameter",
       subtitle = "Memantau variasi dalam subgroup (terkendali bila dalam batas)",
       x = "Nomor subgroup", y = "Range subgroup (mm)") + tema
simpan("V2_peta_R.png", p2)

# --- V3: Capability histogram + spec limits (Diameter) ---
sp_d <- spek |> filter(Karakteristik == "Diameter")
cd   <- capability |> filter(Karakteristik == "Diameter")
p3 <- ggplot(d |> filter(Karakteristik == "Diameter"), aes(x = Pengukuran)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30,
                 fill = "steelblue", color = "white", alpha = 0.8) +
  stat_function(fun = dnorm, args = list(mean = cd$mean, sd = cd$sd),
                color = "darkblue", linewidth = 1) +
  geom_vline(xintercept = c(sp_d$LSL, sp_d$USL), color = "darkred",
             linetype = "dashed", linewidth = 1) +
  labs(title = sprintf("Process capability - Diameter (Cp = %.2f, Cpk = %.2f)",
                       cd$Cp, cd$Cpk),
       subtitle = "Garis merah putus-putus = batas spesifikasi (LSL/USL)",
       x = "Diameter (mm)", y = "Kepadatan") + tema
simpan("V3_capability.png", p3)

# --- V4: Cp & Cpk per karakteristik ---
cap_long <- capability |>
  select(Karakteristik, Cp, Cpk) |>
  pivot_longer(c(Cp, Cpk), names_to = "Indeks", values_to = "Nilai")
p4 <- ggplot(cap_long, aes(x = Karakteristik, y = Nilai, fill = Indeks)) +
  geom_col(position = position_dodge(0.75), width = 0.65) +
  geom_text(aes(label = sprintf("%.2f", Nilai)),
            position = position_dodge(0.75), vjust = -0.4, size = 3.2) +
  geom_hline(yintercept = 1.33, linetype = "dashed", color = "darkred") +
  annotate("text", x = 0.7, y = 1.38, label = "Target Cpk >= 1.33",
           color = "darkred", size = 3.2, hjust = 0) +
  scale_fill_manual(values = c(Cp = "steelblue", Cpk = "darkorange")) +
  labs(title = "Perbandingan Cp & Cpk antar karakteristik mutu",
       subtitle = "Semua < 1.33 - proses belum capable",
       x = "Karakteristik", y = "Nilai indeks", fill = NULL) + tema
simpan("V4_cp_cpk.png", p4)

# --- V5: Boxplot pengukuran per shift ---
p5 <- ggplot(d, aes(x = Shift, y = Pengukuran, fill = Shift)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.4) +
  facet_wrap(~ Karakteristik, scales = "free_y") +
  scale_fill_manual(values = c(Pagi = "#55A868", Sore = "#DD8452", Malam = "#C44E52")) +
  labs(title = "Sebaran pengukuran per shift untuk tiap karakteristik",
       subtitle = "Skala sumbu Y bebas tiap panel",
       x = NULL, y = "Pengukuran", fill = "Shift") + tema
simpan("V5_boxplot_shift.png", p5, w = 9, h = 4)

# --- V6: Run chart pengukuran individual (Diameter) ---
p6 <- ggplot(d |> filter(Karakteristik == "Diameter"),
             aes(x = Subgroup, y = Pengukuran)) +
  geom_point(alpha = 0.4, color = "steelblue") +
  geom_smooth(method = "loess", formula = y ~ x, color = "darkred", se = FALSE) +
  geom_hline(yintercept = sp_d$Target, linetype = "dotted", color = "grey40") +
  labs(title = "Run chart - pengukuran individual Diameter",
       subtitle = "Garis merah = tren loess; titik = tiap unit terukur",
       x = "Nomor subgroup", y = "Diameter (mm)") + tema
simpan("V6_run_chart.png", p6)

# --- V7: Proporsi di luar spesifikasi per karakteristik ---
oos <- d |> left_join(spek, by = "Karakteristik") |>
  group_by(Karakteristik) |>
  summarise(OutOfSpec = mean(Pengukuran < LSL | Pengukuran > USL), .groups = "drop")
p7 <- ggplot(oos, aes(x = Karakteristik, y = OutOfSpec, fill = Karakteristik)) +
  geom_col(width = 0.6, alpha = 0.85) +
  geom_text(aes(label = percent(OutOfSpec, accuracy = 0.01)), vjust = -0.4, size = 3.5) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "Proporsi pengukuran di luar spesifikasi",
       subtitle = "Makin tinggi makin banyak produk berisiko reject",
       x = "Karakteristik", y = "Proporsi out-of-spec", fill = "Karakteristik") + tema
simpan("V7_out_of_spec.png", p7)

cat("Visual Opsi 2 selesai.\n")
print(as.data.frame(oos))
cat(sprintf("Out-of-spec keseluruhan: %.2f%%\n", mean(oos$OutOfSpec) * 100))

