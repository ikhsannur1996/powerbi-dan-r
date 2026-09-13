# ============================================================
# Opsi 3 - Peramalan Permintaan & Perencanaan Produksi
# R/02_visual_ggplot2.R  --  visual (ggplot2) -> output/V*.png
# ============================================================

suppressMessages({ library(dplyr); library(tidyr); library(ggplot2); library(scales) })

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
out  <- file.path(base, "output"); dir.create(out, showWarnings = FALSE)

d      <- read.csv(file.path(base, "data", "permintaan.csv")) |>
  mutate(Bulan = as.Date(Bulan), Produk = factor(Produk))
produk <- read.csv(file.path(base, "data", "produk.csv"))
H      <- readRDS(file.path(out, "hasil_opsi3.rds"))
musiman <- H$musiman; total_bulan <- H$total_bulan; tren_fit <- H$tren_fit
acc     <- H$acc; ma_ewma <- H$ma_ewma; kapasitas <- H$kapasitas

tema <- theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(color = "grey40"))
simpan <- function(nm, p, w = 8, h = 4.6)
  ggsave(file.path(out, nm), p, width = w, height = h, dpi = 150, bg = "white")

warna_produk <- c(Bracket = "#4C72B0", Housing = "#55A868",
                  Shaft = "#C44E52", Panel = "#DD8452")

# --- V1: Tren permintaan bulanan total + garis regresi ---
tb <- total_bulan |> mutate(waktu = as.numeric(Bulan))
p1 <- ggplot(tb, aes(x = waktu, y = Total)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_point(color = "steelblue", size = 1.6) +
  geom_smooth(method = "lm", formula = y ~ x, color = "darkred",
              linetype = "dashed", se = TRUE) +
  scale_x_continuous(labels = function(v) format(as.Date(v, origin = "1970-01-01"), "%Y-%m")) +
  scale_y_continuous(labels = label_comma()) +
  labs(title = "Tren permintaan bulanan (total semua produk)",
       subtitle = sprintf("Slope = +%.0f unit/bulan; R2 = %.2f; p = 1.02e-06",
                          coef(tren_fit)[2], summary(tren_fit)$r.squared),
       x = "Bulan", y = "Total permintaan (unit)") + tema
simpan("V1_tren_permintaan.png", p1)

# --- V2: Permintaan per produk (garis berwarna) ---
p2 <- ggplot(d, aes(x = Bulan, y = Permintaan, color = Produk)) +
  geom_line(linewidth = 0.9) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, linetype = "dotted") +
  scale_color_manual(values = warna_produk) +
  scale_y_continuous(labels = label_comma()) +
  labs(title = "Permintaan bulanan per produk",
       subtitle = "Bracket tumbuh paling cepat; Panel relatif datar/menurun",
       x = "Bulan", y = "Permintaan (unit)", color = "Produk") + tema
simpan("V2_per_produk.png", p2, w = 8.5)

# --- V3: Indeks musiman per bulan kalender ---
musiman$NamaBulan <- factor(musiman$NamaBulan, levels = month.abb)
p3 <- ggplot(musiman, aes(x = NamaBulan, y = Indeks, fill = Indeks > 1)) +
  geom_col(width = 0.7) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "grey40") +
  geom_text(aes(label = sprintf("%.2f", Indeks)), vjust = -0.4, size = 3) +
  scale_fill_manual(values = c(`TRUE` = "#C44E52", `FALSE` = "steelblue"), guide = "none") +
  labs(title = "Indeks musiman bulanan (rata-rata 3 tahun)",
       subtitle = "Nov (1.24) & Des (1.35) = puncak; Jan-Feb = dasar terendah",
       x = NULL, y = "Indeks musiman (1 = rata-rata)") + tema
simpan("V3_musiman.png", p3)

# --- V4: Peramalan vs aktual (Bracket sebagai contoh) ---
ex <- ma_ewma |> filter(Produk == "Bracket")
p4 <- ggplot(ex, aes(x = Bulan)) +
  geom_line(aes(y = Permintaan, color = "Aktual"), linewidth = 1) +
  geom_line(aes(y = MA3, color = "Moving Average (3)"), linewidth = 0.9, linetype = "dashed", na.rm = TRUE) +
  geom_line(aes(y = EWMA06, color = "Exp. Smoothing (0.6)"), linewidth = 0.9, na.rm = TRUE) +
  scale_color_manual(values = c("Aktual" = "grey30",
                                "Moving Average (3)" = "#4C72B0",
                                "Exp. Smoothing (0.6)" = "#C44E52")) +
  scale_y_continuous(labels = label_comma()) +
  labs(title = "Peramalan vs aktual - produk Bracket",
       subtitle = "EWMA(0.6) paling responsif mengikuti fluktuasi",
       x = "Bulan", y = "Permintaan (unit)", color = NULL) + tema
simpan("V4_peramalan_vs_aktual.png", p4, w = 8.5)

# --- V5: Akurasi peramalan (MAPE) ---
p5 <- ggplot(acc, aes(x = reorder(Model, MAPE), y = MAPE, fill = Model)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = sprintf("%.1f%%", MAPE)), hjust = -0.15, size = 3.5) +
  coord_flip() +
  scale_fill_manual(values = c("Moving Average (3)" = "steelblue",
                               "Exp. Smoothing (a=0.3)" = "#DD8452",
                               "Exp. Smoothing (a=0.6)" = "#C44E52"), guide = "none") +
  labs(title = "Akurasi peramalan (MAPE, makin kecil makin baik)",
       subtitle = "EWMA mengalahkan Moving Average; MA(3) MAPE 14.5%",
       x = NULL, y = "MAPE (%)") + tema
simpan("V5_akurasi.png", p5, w = 8)

# --- V6: Kapasitas vs permintaan puncak ---
kap_long <- kapasitas |>
  select(Produk, KapasitasMesin, PuncakBulanan) |>
  pivot_longer(c(KapasitasMesin, PuncakBulanan), names_to = "Seri", values_to = "Unit") |>
  mutate(Seri = factor(Seri, levels = c("KapasitasMesin", "PuncakBulanan"),
                       labels = c("Kapasitas 1 mesin", "Permintaan bulan puncak")))
p6 <- ggplot(kap_long, aes(x = Produk, y = Unit, fill = Seri)) +
  geom_col(position = position_dodge(0.8), width = 0.72) +
  scale_fill_manual(values = c("Kapasitas 1 mesin" = "grey65", "Permintaan bulan puncak" = "#C44E52")) +
  scale_y_continuous(labels = label_comma()) +
  labs(title = "Kapasitas vs permintaan bulan puncak",
       subtitle = "Semua produk butuh > 1 mesin; Shaft paling kritis (utilisasi 2.03)",
       x = "Produk", y = "Unit", fill = NULL) + tema
simpan("V6_kapasitas.png", p6, w = 8)

# --- V7: Heatmap tahun x bulan ---
hm <- d |>
  mutate(Tahun = format(Bulan, "%Y")) |>
  group_by(Tahun, BulanKe = as.integer(format(Bulan, "%m"))) |>
  summarise(Total = sum(Permintaan), .groups = "drop") |>
  mutate(Bulan_nama = factor(month.abb[BulanKe], levels = month.abb))
p7 <- ggplot(hm, aes(x = Bulan_nama, y = Tahun, fill = Total)) +
  geom_tile(color = "white") +
  geom_text(aes(label = label_comma()(Total)), size = 2.6, color = "white") +
  scale_fill_gradient(low = "#c6dbef", high = "#08306b", labels = label_comma()) +
  labs(title = "Heatmap total permintaan: tahun x bulan",
       subtitle = "Kolom Nov-Des konsisten paling gelap di setiap tahun",
       x = NULL, y = NULL, fill = "Unit") + tema
simpan("V7_heatmap.png", p7, w = 9, h = 3.4)

cat("Visual Opsi 3 selesai.\n")
cat(sprintf("Model terbaik (MAPE): %s (%.2f%%)\n",
            acc$Model[which.min(acc$MAPE)], min(acc$MAPE)))

