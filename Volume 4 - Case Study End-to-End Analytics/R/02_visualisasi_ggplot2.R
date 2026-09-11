# ============================================================
# 02_visualisasi_ggplot2.R
# Volume 4 - 8 visual eksplorasi (cermin dashboard Power BI)
# Cara jalan (dari root repo):
#   Rscript "Volume 4 - Case Study End-to-End Analytics/R/02_visualisasi_ggplot2.R"
# ============================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(scales)
  library(lubridate)
})

ROOT <- "Volume 4 - Case Study End-to-End Analytics"
OUT  <- file.path(ROOT, "output")
dir.create(OUT, showWarnings = FALSE)

df <- read.csv(file.path(ROOT, "data/produksi.csv"), stringsAsFactors = FALSE) %>%
  mutate(Tanggal = as.Date(Tanggal))

tema <- theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", size = 14),
        plot.subtitle = element_text(colour = "grey40"))

simpan <- function(p, nama, lebar = 9, tinggi = 5) {
  ggsave(file.path(OUT, nama), p, width = lebar, height = tinggi, dpi = 150)
  cat("tersimpan:", nama, "\n")
}

# ---------- V1: Tren produksi harian (line) ----------
tren <- df %>%
  group_by(Tanggal) %>%
  summarise(Produksi = sum(AktualProduksi), .groups = "drop")
p1 <- ggplot(tren, aes(Tanggal, Produksi)) +
  geom_line(linewidth = 1, colour = "#1f77b4") +
  geom_smooth(method = "loess", se = FALSE, linetype = "dashed", colour = "grey40") +
  labs(title = "V1 - Tren Produksi Harian", subtitle = "Jan-Jun 2026 (tanpa Minggu)",
       x = NULL, y = "Unit") + tema
simpan(p1, "V1_tren_harian.png")

# ---------- V2: Defect rate per operator (bar, terurut) ----------
per_op <- df %>%
  group_by(Operator) %>%
  summarise(Rate = sum(JumlahCacat) / sum(AktualProduksi) * 100, .groups = "drop")
p2 <- ggplot(per_op, aes(reorder(Operator, Rate), Rate)) +
  geom_col(fill = "#d62728") +
  geom_hline(yintercept = mean(per_op$Rate), linetype = "dashed", colour = "grey30") +
  coord_flip() +
  labs(title = "V2 - Defect Rate per Operator",
       subtitle = "Garis putus-putus = rata-rata. OP06 & OP04 tertinggi",
       x = NULL, y = "Defect rate (%)") + tema
simpan(p2, "V2_defect_operator.png")

# ---------- V3: Scatter pencapaian vs defect (bubble) ----------
p3 <- df %>%
  mutate(Pencapaian = AktualProduksi / TargetProduksi * 100,
         Rate = JumlahCacat / AktualProduksi * 100) %>%
  ggplot(aes(Pencapaian, Rate, size = DowntimeMenit, colour = Shift)) +
  geom_point(alpha = 0.5) +
  geom_vline(xintercept = 100, linetype = "dashed", colour = "grey40") +
  labs(title = "V3 - Pencapaian Target vs Defect Rate",
       subtitle = "Ukuran titik = downtime. Kuadran bahaya: kanan-atas",
       x = "Pencapaian target (%)", y = "Defect rate (%)", size = "Downtime (mnt)") + tema
simpan(p3, "V3_scatter_pencapaian_defect.png")

# ---------- V4: Pareto cacat per produk ----------
par <- df %>%
  group_by(Produk) %>%
  summarise(Cacat = sum(JumlahCacat), .groups = "drop") %>%
  arrange(desc(Cacat)) %>%
  mutate(Kum = cumsum(Cacat) / sum(Cacat) * 100)
p4 <- ggplot(par, aes(reorder(Produk, -Cacat), Cacat)) +
  geom_col(fill = "#2ca02c") +
  geom_line(aes(y = Kum / 100 * max(Cacat), group = 1), colour = "#ff7f0e", linewidth = 1) +
  geom_point(aes(y = Kum / 100 * max(Cacat)), colour = "#ff7f0e", size = 3) +
  scale_y_continuous(sec.axis = sec_axis(~ . / max(par$Cacat) * 100, name = "Kumulatif (%)")) +
  labs(title = "V4 - Pareto Cacat per Produk", x = NULL, y = "Total cacat") + tema
simpan(p4, "V4_pareto_produk.png")

# ---------- V5: Boxplot cycle time per produk ----------
p5 <- ggplot(df, aes(Produk, CycleTimeDetik, fill = Produk)) +
  geom_boxplot(alpha = 0.8, show.legend = FALSE) +
  labs(title = "V5 - Distribusi Cycle Time per Produk",
       subtitle = "Shaft paling lambat (~53 dtk) - peluang SMED/kaizen",
       x = NULL, y = "Cycle time (detik)") + tema
simpan(p5, "V5_boxplot_cycletime.png")

# ---------- V6: Heatmap defect Line x Shift ----------
ls <- df %>%
  group_by(Line, Shift) %>%
  summarise(Rate = sum(JumlahCacat) / sum(AktualProduksi) * 100, .groups = "drop") %>%
  mutate(Shift = factor(Shift, levels = c("Pagi", "Siang", "Malam")))
p6 <- ggplot(ls, aes(Shift, Line, fill = Rate)) +
  geom_tile(colour = "white", linewidth = 1) +
  geom_text(aes(label = paste0(round(Rate, 2), "%")), colour = "white",
            fontface = "bold", size = 5) +
  scale_fill_gradient(low = "#2ca02c", high = "#d62728") +
  labs(title = "V6 - Heatmap Defect Rate: Line x Shift",
       subtitle = "Shift Malam konsisten lebih merah di kedua line",
       x = NULL, y = NULL) + tema
simpan(p6, "V6_heatmap_line_shift.png", lebar = 7, tinggi = 4)

# ---------- V7: Downtime per mesin (bar) ----------
dm <- df %>%
  group_by(Mesin) %>%
  summarise(Total = sum(DowntimeMenit), .groups = "drop")
p7 <- ggplot(dm, aes(reorder(Mesin, -Total), Total)) +
  geom_col(fill = "#9467bd") +
  geom_text(aes(label = comma(Total)), vjust = -0.4) +
  labs(title = "V7 - Total Downtime per Mesin",
       subtitle = "M-02 & M-04 dominan - prioritas preventive maintenance",
       x = NULL, y = "Menit") + tema
simpan(p7, "V7_downtime_mesin.png")

# ---------- V8: Komposisi output per produk (donut) ----------
komp <- df %>%
  group_by(Produk) %>%
  summarise(Unit = sum(AktualProduksi), .groups = "drop") %>%
  mutate(Pct = Unit / sum(Unit) * 100,
         label = paste0(Produk, "\n", round(Pct, 1), "%"))
p8 <- ggplot(komp, aes(x = 2, y = Pct, fill = Produk)) +
  geom_col(width = 1, colour = "white") +
  geom_text(aes(label = label), position = position_stack(vjust = 0.5)) +
  coord_polar(theta = "y") + xlim(0.5, 2.5) +
  labs(title = "V8 - Komposisi Output per Produk") +
  theme_void() + theme(plot.title = element_text(face = "bold", hjust = 0.5))
simpan(p8, "V8_donut_produk.png", lebar = 6, tinggi = 5)

cat("OK - 8 visual tersimpan di", OUT, "\n")
