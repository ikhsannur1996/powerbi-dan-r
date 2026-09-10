# =====================================================================
# Contoh Visualisasi Lengkap dengan ggplot2
# =====================================================================
# File   : contoh_visualisasi_ggplot2.R
# Data   : quality_inspection.csv (inspeksi kualitas produksi)
# Output : folder output/ — satu file PNG untuk tiap contoh
#
# Cara pakai : jalankan seluruh script (atau per-bagian). Di RStudio
#              grafik tampil di panel Plots; setiap grafik juga otomatis
#              disimpan ke output/ lewat ggsave().
# Catatan    : contoh geom_hex() dan geom_quantile() butuh package
#              tambahan (hexbin, quantreg) dan dilewati otomatis bila
#              belum terpasang.
#
# Daftar isi:
#   Bagian 1  : Distribusi satu variabel        (01-10)
#   Bagian 2  : Diskret vs kontinu              (11-24)
#   Bagian 3  : Kontinu vs kontinu              (25-37)
#   Bagian 4  : Data waktu / tren               (38-45)
#   Bagian 5  : Koordinat khusus                (46-52)
#   Bagian 6  : Facet                           (53-55)
#   Bagian 7  : Scales & palet warna            (56-62)
#   Bagian 8  : Tema & kustomisasi tampilan     (63-65)
#   Bagian 9  : Guides (kontrol legenda)        (66-67)
#   Bagian 10 : Stat & after_stat               (68-70)
#   Bagian 11 : Label, layout gabungan, ggsave  (71-73)
# =====================================================================

library(ggplot2)
library(dplyr)
library(lubridate)
library(scales)
library(forcats)

# ---- 0.1 Path & helper ----------------------------------------------
# Path adaptif: bisa dijalankan dari root project maupun dari folder ini.
root <- if (file.exists("quality_inspection.csv")) "." else ".."

dir_output <- file.path(root, "Data Visualization - ggplot2", "output")
dir.create(dir_output, showWarnings = FALSE)

# Tampilkan di RStudio (jika interaktif) + simpan PNG via ggsave().
simpan <- function(p, nama, w = 7, h = 4.5) {
  if (interactive()) print(p)
  ggsave(file.path(dir_output, paste0(nama, ".png")), p,
         width = w, height = h, dpi = 150, bg = "white")
  invisible(p)
}

# Gabungkan beberapa plot dalam satu kanvas — memakai grid + ggplotGrob
# (tanpa package tambahan; alternatif modern yang lebih ringkas: patchwork).
gabung_grid <- function(..., ncol = 2) {
  plots <- list(...)
  n_br  <- ceiling(length(plots) / ncol)
  grid::grid.newpage()
  grid::pushViewport(grid::viewport(layout = grid::grid.layout(n_br, ncol)))
  for (i in seq_along(plots)) {
    baris <- ceiling(i / ncol)
    kolom <- ((i - 1L) %% ncol) + 1L
    grid::pushViewport(grid::viewport(layout.pos.row = baris,
                                      layout.pos.col = kolom))
    grid::grid.draw(ggplotGrob(plots[[i]]))
    grid::popViewport()
  }
}
simpan_grid <- function(nama, w = 12, h = 8, ncol = 2, ...) {
  if (interactive()) gabung_grid(ncol = ncol, ...)
  png(file.path(dir_output, paste0(nama, ".png")),
      width = w, height = h, units = "in", res = 150)
  gabung_grid(ncol = ncol, ...)
  dev.off()
  invisible(NULL)
}

# ---- 0.2 Data utama --------------------------------------------------
inspeksi <- read.csv(file.path(root, "quality_inspection.csv")) |>
  mutate(
    InspectionDate = as.Date(InspectionDate),
    DefectRate = Defect / Inspected,
    Line       = factor(Line,       levels = c("A", "B", "C")),
    Product    = factor(Product),
    DefectType = factor(DefectType,
                        levels = c("Scratch", "Dimension", "Crack", "Color", "NONE"))
  )

# ---- 0.3 Tabel ringkasan (agregasi dplyr) ----------------------------
ringkas_tipe <- inspeksi |>                        # per jenis defect
  group_by(DefectType) |>
  summarize(TotalDefect = sum(Defect), .groups = "drop") |>
  mutate(
    Proporsi   = TotalDefect / sum(TotalDefect),
    DefectType = fct_reorder(DefectType, TotalDefect)
  )

per_line_tipe <- inspeksi |>                       # per lini x jenis defect
  group_by(Line, DefectType) |>
  summarize(TotalDefect = sum(Defect), .groups = "drop")

ringkas_line <- inspeksi |>                        # per bulan x lini
  group_by(Bulan = floor_date(InspectionDate, "month"), Line) |>
  summarize(
    Inspected = sum(Inspected),
    Defect    = sum(Defect),
    RataCT    = mean(CycleTimeSec),
    .groups   = "drop"
  ) |>
  mutate(DefectRate = Defect / Inspected)

per_bulan <- inspeksi |>                           # per bulan, semua lini
  group_by(Bulan = floor_date(InspectionDate, "month")) |>
  summarize(
    DefectRate  = sum(Defect) / sum(Inspected),
    DR_min      = min(Defect / Inspected),
    DR_maks     = max(Defect / Inspected),
    TotalDefect = sum(Defect),
    .groups     = "drop"
  )

kumulatif <- inspeksi |>                           # defect kumulatif harian
  group_by(InspectionDate) |>
  summarize(TotalDefect = sum(Defect), .groups = "drop") |>
  arrange(InspectionDate) |>
  mutate(Kumulatif = cumsum(TotalDefect))

ringkas_ct <- inspeksi |>                          # cycle time per lini
  group_by(Line) |>
  summarize(
    rata    = mean(CycleTimeSec),
    sd      = sd(CycleTimeSec),
    minim   = min(CycleTimeSec),
    maks    = max(CycleTimeSec),
    .groups = "drop"
  )

target <- data.frame(Line = c("A", "B", "C"), TargetDR = c(0.03, 0.04, 0.035))

# ---- 0.4 Data sintetis (untuk contoh yang butuh banyak titik) --------
set.seed(42)
awan <- data.frame(                                # awan titik utk density 2D
  x = c(rnorm(1500, 120, 8),  rnorm(600, 132, 6)),
  y = c(rnorm(1500, 42, 2.5), rnorm(600, 48, 2))
)
walk <- data.frame(                                # random walk utk geom_path
  langkah = 1:60,
  posisi  = cumsum(rnorm(60))
)
profil <- data.frame(                              # profil utk radar chart
  Kriteria = c("Kualitas", "Kecepatan", "Biaya", "Keandalan", "Fleksibilitas"),
  Skor     = c(85, 70, 60, 90, 75)
)

cat("Setup selesai — grafik akan tersimpan di:", normalizePath(dir_output), "\n")

# =====================================================================
# BAGIAN 1 — DISTRIBUSI SATU VARIABEL
# =====================================================================

# 01 Histogram — distribusi variabel numerik
p <- ggplot(inspeksi, aes(x = CycleTimeSec)) +
  geom_histogram(binwidth = 2, fill = "steelblue", color = "white") +
  labs(title = "01. Histogram", x = "Cycle time (detik)", y = "Frekuensi")
simpan(p, "01_histogram")

# 02 Density — estimasi kepadatan kontinu
p <- ggplot(inspeksi, aes(x = Defect)) +
  geom_density(fill = "darkorange", alpha = 0.5) +
  labs(title = "02. Density plot", x = "Jumlah defect", y = "Kepadatan")
simpan(p, "02_density")

# 03 Freqpoly — bandingkan distribusi antar lini
p <- ggplot(inspeksi, aes(x = Defect, color = Line)) +
  geom_freqpoly(binwidth = 1, linewidth = 1) +
  labs(title = "03. Frequency polygon per lini", x = "Jumlah defect", y = "Frekuensi")
simpan(p, "03_freqpoly")

# 04 Dotplot — alternatif histogram untuk data kecil
p <- ggplot(inspeksi, aes(x = Defect)) +
  geom_dotplot(binwidth = 1, fill = "seagreen") +
  labs(title = "04. Dotplot", x = "Jumlah defect", y = NULL)
simpan(p, "04_dotplot")

# 05 Bar chart — frekuensi kategori diskret (stat "count" otomatis)
p <- ggplot(inspeksi, aes(x = DefectType)) +
  geom_bar(fill = "darkorange") +
  labs(title = "05. Bar chart (count)", x = "Jenis defect", y = "Jumlah inspeksi")
simpan(p, "05_bar_count")

# 06 Lollipop — segmen + titik, alternatif bar yang ringkas
p <- ggplot(ringkas_tipe, aes(x = DefectType, y = TotalDefect)) +
  geom_segment(aes(xend = DefectType, yend = 0), color = "grey55", linewidth = 1) +
  geom_point(size = 5, color = "steelblue") +
  labs(title = "06. Lollipop chart", x = "Jenis defect", y = "Total defect")
simpan(p, "06_lollipop")

# 07 ECDF — proporsi kumulatif data
p <- ggplot(inspeksi, aes(x = CycleTimeSec)) +
  stat_ecdf(geom = "step", color = "steelblue", linewidth = 1) +
  labs(title = "07. Empirical CDF", x = "Cycle time (detik)", y = "Proporsi kumulatif")
simpan(p, "07_ecdf")

# 08 Q-Q plot — cek normalitas
p <- ggplot(inspeksi, aes(sample = Defect)) +
  stat_qq(color = "steelblue") +
  stat_qq_line(color = "darkorange") +
  labs(title = "08. Q-Q plot (normal)", x = "Kuantil teoretis", y = "Kuantil sampel")
simpan(p, "08_qqplot")

# 09 Boxplot satu variabel
p <- ggplot(inspeksi, aes(x = "", y = Defect)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "09. Boxplot (satu variabel)", x = NULL, y = "Jumlah defect")
simpan(p, "09_boxplot_satu")

# 10 Violin satu variabel
p <- ggplot(inspeksi, aes(x = "", y = CycleTimeSec)) +
  geom_violin(fill = "lightgreen") +
  labs(title = "10. Violin plot (satu variabel)", x = NULL, y = "Cycle time (detik)")
simpan(p, "10_violin_satu")

# =====================================================================
# BAGIAN 2 — DISKRET (X) vs KONTINU (Y)
# =====================================================================

# 11 Boxplot berkelompok
p <- ggplot(inspeksi, aes(x = Line, y = CycleTimeSec, fill = Product)) +
  geom_boxplot() +
  labs(title = "11. Boxplot per lini & produk", x = "Lini",
       y = "Cycle time (detik)", fill = "Produk")
simpan(p, "11_boxplot_grup")

# 12 Violin berkelompok (dodge)
p <- ggplot(inspeksi, aes(x = Line, y = CycleTimeSec, fill = Product)) +
  geom_violin(position = position_dodge(width = 0.8), scale = "width") +
  labs(title = "12. Violin plot per lini & produk", x = "Lini",
       y = "Cycle time (detik)", fill = "Produk")
simpan(p, "12_violin_grup")

# 13 Column chart — nilai yang SUDAH dihitung (geom_col, bukan geom_bar)
p <- ggplot(ringkas_tipe, aes(x = DefectType, y = TotalDefect)) +
  geom_col(fill = "steelblue", width = 0.7) +
  labs(title = "13. Column chart (geom_col)", x = "Jenis defect", y = "Total defect")
simpan(p, "13_col")

# 14 Bar horizontal + label angka
p <- ggplot(ringkas_tipe, aes(x = TotalDefect, y = DefectType)) +
  geom_col(fill = "steelblue") +
  geom_text(aes(label = TotalDefect), hjust = -0.3, size = 3.5) +
  scale_x_continuous(limits = c(0, max(ringkas_tipe$TotalDefect) * 1.15)) +
  labs(title = "14. Bar horizontal + label nilai",
       x = "Total defect", y = "Jenis defect")
simpan(p, "14_col_horizontal")

# 15 Grouped bar — berdampingan
p <- ggplot(per_line_tipe, aes(x = Line, y = TotalDefect, fill = DefectType)) +
  geom_col(position = "dodge") +
  labs(title = "15. Grouped bar (position = 'dodge')",
       x = "Lini", y = "Total defect", fill = "Jenis defect")
simpan(p, "15_dodge")

# 16 Stacked bar — menumpuk
p <- ggplot(per_line_tipe, aes(x = Line, y = TotalDefect, fill = DefectType)) +
  geom_col(position = "stack") +
  labs(title = "16. Stacked bar (position = 'stack')",
       x = "Lini", y = "Total defect", fill = "Jenis defect")
simpan(p, "16_stack")

# 17 100% stacked — ternormalisasi jadi proporsi
p <- ggplot(per_line_tipe, aes(x = Line, y = TotalDefect, fill = DefectType)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = percent) +
  labs(title = "17. Stacked 100% (position = 'fill')",
       x = "Lini", y = "Proporsi", fill = "Jenis defect")
simpan(p, "17_fill")

# 18 Error bar — rata-rata ± 1 SD cycle time per lini & produk
rata_cp <- inspeksi |>
  group_by(Line, Product) |>
  summarize(rata = mean(CycleTimeSec), sd = sd(CycleTimeSec), .groups = "drop")

p <- ggplot(rata_cp, aes(x = Line, y = rata, fill = Product)) +
  geom_col(position = position_dodge(0.7), width = 0.6,
           fill = "grey85", color = "grey40") +
  geom_errorbar(aes(ymin = rata - sd, ymax = rata + sd),
                position = position_dodge(0.7), width = 0.2) +
  labs(title = "18. Error bar (rata-rata ± 1 SD)",
       x = "Lini", y = "Cycle time (detik)", fill = "Produk")
simpan(p, "18_errorbar")

# 19 Pointrange — rata-rata ± SD per lini
p <- ggplot(ringkas_ct,
            aes(x = Line, y = rata, ymin = rata - sd, ymax = rata + sd)) +
  geom_pointrange(color = "steelblue", linewidth = 1) +
  coord_flip() +
  labs(title = "19. Pointrange", x = "Lini", y = "Cycle time (detik)")
simpan(p, "19_pointrange")

# 20 Crossbar — min / rata-rata / maks
p <- ggplot(ringkas_ct,
            aes(x = Line, y = rata, ymin = minim, ymax = maks, middle = rata)) +
  geom_crossbar(fill = "lightblue", color = "steelblue", width = 0.5) +
  labs(title = "20. Crossbar (min / rata / maks)",
       x = "Lini", y = "Cycle time (detik)")
simpan(p, "20_crossbar")

# 21 Linerange + titik rata-rata
p <- ggplot(ringkas_ct, aes(x = Line, ymin = minim, ymax = maks)) +
  geom_linerange(color = "darkorange", linewidth = 2) +
  geom_point(aes(y = rata), size = 3, color = "black") +
  labs(title = "21. Linerange min-maks + rata-rata",
       x = "Lini", y = "Cycle time (detik)")
simpan(p, "21_linerange")

# 22 stat_summary — ringkasan langsung di dalam ggplot
p <- ggplot(inspeksi, aes(x = Line, y = Defect)) +
  stat_summary(fun = mean, geom = "point", size = 3.5, color = "steelblue") +
  stat_summary(fun.data = function(z) c(ymin = mean(z) - 2 * sd(z),
                                        y    = mean(z),
                                        ymax = mean(z) + 2 * sd(z)),
               geom = "errorbar", width = 0.2, color = "steelblue") +
  labs(title = "22. stat_summary (mean ± 2 SD)", x = "Lini", y = "Jumlah defect")
simpan(p, "22_stat_summary")

# 23 Boxplot + jitter — tampilkan titik asli di atas box
p <- ggplot(inspeksi, aes(x = Line, y = CycleTimeSec)) +
  geom_boxplot(fill = "lightblue", outlier.shape = NA) +
  geom_jitter(width = 0.15, alpha = 0.6, color = "steelblue") +
  labs(title = "23. Boxplot + jitter", x = "Lini", y = "Cycle time (detik)")
simpan(p, "23_boxplot_jitter")

# 24 Heatmap (geom_tile) — tanggal x jenis defect
panas <- inspeksi |>
  group_by(InspectionDate, DefectType) |>
  summarize(TotalDefect = sum(Defect), .groups = "drop")

p <- ggplot(panas, aes(x = InspectionDate, y = DefectType, fill = TotalDefect)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "#FFF5EB", high = "#D94801", na.value = "grey92") +
  scale_x_date(date_labels = "%d %b", date_breaks = "2 week") +
  labs(title = "24. Heatmap defect (tanggal x jenis)",
       x = "Tanggal inspeksi", y = "Jenis defect", fill = "Total") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
simpan(p, "24_heatmap")

# =====================================================================
# BAGIAN 3 — KONTINU (X) vs KONTINU (Y)
# =====================================================================

# 25 Scatter plot dasar
p <- ggplot(inspeksi, aes(x = Inspected, y = Defect)) +
  geom_point(color = "steelblue", size = 2.5, alpha = 0.8) +
  labs(title = "25. Scatter plot", x = "Unit diinspeksi", y = "Jumlah defect")
simpan(p, "25_scatter")

# 26 Scatter + garis tren linear + interval keyakinan
p <- ggplot(inspeksi, aes(x = Inspected, y = Defect)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", fill = "lightblue") +
  labs(title = "26. Scatter + geom_smooth(method = 'lm')",
       x = "Unit diinspeksi", y = "Jumlah defect")
simpan(p, "26_smooth_lm")

# 27 Bandingkan lm vs loess
p <- ggplot(inspeksi, aes(x = Inspected, y = Defect)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm",    aes(color = "Linear"), se = FALSE) +
  geom_smooth(method = "loess", aes(color = "Loess"),  se = FALSE) +
  scale_color_manual(name = "Model",
                     values = c(Linear = "tomato", Loess = "seagreen")) +
  labs(title = "27. Perbandingan lm vs loess",
       x = "Unit diinspeksi", y = "Jumlah defect")
simpan(p, "27_smooth_loess")

# 28 Bubble chart — ukuran titik proporsional nilai
p <- ggplot(inspeksi, aes(x = Inspected, y = CycleTimeSec, size = Defect)) +
  geom_point(color = "steelblue", alpha = 0.6) +
  scale_size_area(max_size = 10) +
  labs(title = "28. Bubble chart", x = "Unit diinspeksi",
       y = "Cycle time (detik)", size = "Defect")
simpan(p, "28_bubble")

# 29 Multi-aesthetics: warna, bentuk, dan transparansi sekaligus
p <- ggplot(inspeksi,
            aes(x = Inspected, y = Defect, color = Line,
                shape = Product, alpha = CycleTimeSec)) +
  geom_point(size = 3) +
  scale_alpha(range = c(0.3, 1)) +
  labs(title = "29. Multi-aesthetics (color, shape, alpha)",
       x = "Unit diinspeksi", y = "Jumlah defect")
simpan(p, "29_multi_aes")

# 30 geom_count — ukuran otomatis dari banyaknya titik bertumpuk
p <- ggplot(inspeksi, aes(x = Inspected, y = CycleTimeSec)) +
  geom_count(color = "steelblue") +
  scale_size_area() +
  labs(title = "30. geom_count (frekuensi = ukuran)",
       x = "Unit diinspeksi", y = "Cycle time (detik)")
simpan(p, "30_geom_count")

# 31 Rug — strip sebaran di pinggir sumbu
p <- ggplot(inspeksi, aes(x = Inspected, y = Defect)) +
  geom_point(alpha = 0.5) +
  geom_rug(color = "darkorange") +
  labs(title = "31. Scatter + rug", x = "Unit diinspeksi", y = "Jumlah defect")
simpan(p, "31_rug")

# 32 Label titik (untuk bebas tumpang tindih: package ggrepel)
p <- ggplot(filter(inspeksi, Defect >= 10), aes(x = Inspected, y = Defect)) +
  geom_point(color = "steelblue", size = 3) +
  geom_text(aes(label = paste0("Lini ", Line, " - ", format(InspectionDate, "%d %b"))),
            vjust = -0.9, size = 3, check_overlap = TRUE) +
  labs(title = "32. geom_text pada titik",
       x = "Unit diinspeksi", y = "Jumlah defect")
simpan(p, "32_text")

# 33 Bin 2D — data padat dibagi kotak frekuensi
p <- ggplot(awan, aes(x = x, y = y)) +
  geom_bin2d(bins = 25) +
  scale_fill_viridis_c() +
  labs(title = "33. geom_bin2d", x = NULL, y = NULL)
simpan(p, "33_bin2d")

# 34 Kontur density 2D + titik asli
p <- ggplot(awan, aes(x = x, y = y)) +
  geom_point(alpha = 0.2, color = "grey40") +
  geom_density_2d(color = "darkorange") +
  labs(title = "34. geom_density_2d", x = NULL, y = NULL)
simpan(p, "34_density2d")

# 35 Density 2D terisi (filled)
p <- ggplot(awan, aes(x = x, y = y)) +
  stat_density_2d_filled(aes(fill = after_stat(level)), geom = "polygon") +
  scale_fill_viridis_d(option = "inferno") +
  labs(title = "35. stat_density_2d_filled", x = NULL, y = NULL)
simpan(p, "35_density2d_filled")

# 36 Hex binning — butuh package hexbin
if (requireNamespace("hexbin", quietly = TRUE)) {
  p <- ggplot(awan, aes(x = x, y = y)) +
    geom_hex(bins = 25) +
    scale_fill_viridis_c() +
    labs(title = "36. geom_hex", x = NULL, y = NULL)
  simpan(p, "36_hex")
} else {
  message("36 dilewati: install.packages('hexbin') untuk contoh geom_hex()")
}

# 37 Quantile regression — butuh package quantreg
if (requireNamespace("quantreg", quietly = TRUE)) {
  p <- ggplot(inspeksi, aes(x = Inspected, y = Defect)) +
    geom_point(alpha = 0.5) +
    geom_quantile(quantiles = c(0.1, 0.5, 0.9),
                  color = "darkorange", linewidth = 1) +
    labs(title = "37. geom_quantile (kuantil 10/50/90%)",
         x = "Unit diinspeksi", y = "Jumlah defect")
  simpan(p, "37_quantile")
} else {
  message("37 dilewati: install.packages('quantreg') untuk contoh geom_quantile()")
}

# =====================================================================
# BAGIAN 4 — DATA WAKTU / TREN
# =====================================================================

# 38 Multi-line chart — tren defect rate per lini
p <- ggplot(ringkas_line, aes(x = Bulan, y = DefectRate, color = Line)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_y_continuous(labels = percent) +
  scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +
  labs(title = "38. Line chart per lini", x = "Bulan",
       y = "Defect rate", color = "Lini") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
simpan(p, "38_line")

# 39 Line chart dengan linetype mapping
p <- ggplot(ringkas_line,
            aes(x = Bulan, y = RataCT, color = Line, linetype = Line)) +
  geom_line(linewidth = 1) +
  scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  labs(title = "39. Line chart (linetype per lini)", x = "Bulan",
       y = "Rata-rata cycle time (detik)")
simpan(p, "39_line_linetype")

# 40 Area chart — total defect per bulan
p <- ggplot(per_bulan, aes(x = Bulan, y = TotalDefect)) +
  geom_area(fill = "steelblue", alpha = 0.6) +
  scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +
  labs(title = "40. Area chart", x = "Bulan", y = "Total defect") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
simpan(p, "40_area")

# 41 Ribbon — band min-maks defect rate antar lini + garis rata-rata
p <- ggplot(per_bulan, aes(x = Bulan, y = DefectRate)) +
  geom_ribbon(aes(ymin = DR_min, ymax = DR_maks),
              fill = "steelblue", alpha = 0.25) +
  geom_line(color = "steelblue", linewidth = 1) +
  scale_y_continuous(labels = percent) +
  scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  labs(title = "41. Ribbon (rentang min-maks antar lini)",
       x = "Bulan", y = "Defect rate")
simpan(p, "41_ribbon")

# 42 Step chart — defect kumulatif
p <- ggplot(kumulatif, aes(x = InspectionDate, y = Kumulatif)) +
  geom_step(color = "seagreen", linewidth = 1, direction = "hv") +
  geom_point(size = 2, color = "seagreen") +
  scale_x_date(date_labels = "%d %b", date_breaks = "2 week") +
  labs(title = "42. Step chart (defect kumulatif)",
       x = "Tanggal inspeksi", y = "Defect kumulatif") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
simpan(p, "42_step")

# 43 Path — lintasan mengikuti urutan data (contoh: random walk)
p <- ggplot(walk, aes(x = langkah, y = posisi, color = langkah)) +
  geom_path(linewidth = 1) +
  scale_color_viridis_c(option = "plasma") +
  labs(title = "43. geom_path (urutan = warna)",
       x = "Langkah", y = "Posisi", color = "Langkah")
simpan(p, "43_path")

# 44 Garis referensi + anotasi
rata_ct <- mean(inspeksi$CycleTimeSec)
p <- ggplot(inspeksi, aes(x = InspectionDate, y = CycleTimeSec)) +
  geom_line(aes(group = Line), color = "grey60") +
  geom_point(aes(color = Line), size = 2.5) +
  geom_hline(yintercept = rata_ct, linetype = "dashed", color = "tomato") +
  annotate("text", x = min(inspeksi$InspectionDate), y = rata_ct + 0.45,
           label = paste0("Rata-rata: ", round(rata_ct, 1), " dtk"),
           hjust = 0, color = "tomato", size = 3.3) +
  annotate("rect", xmin = as.Date("2026-08-01"),
           xmax = max(inspeksi$InspectionDate),
           ymin = -Inf, ymax = Inf, alpha = 0.08) +
  scale_x_date(date_labels = "%d %b", date_breaks = "2 week") +
  labs(title = "44. geom_hline + annotate", x = "Tanggal",
       y = "Cycle time (detik)", color = "Lini") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
simpan(p, "44_anotasi")

# 45 Segment + panah — pergerakan cycle time antar bulan per lini
tren_ct <- ringkas_line |>
  group_by(Line) |>
  mutate(Bulan_lalu = lag(Bulan), CT_lalu = lag(RataCT)) |>
  ungroup() |>
  filter(!is.na(CT_lalu))

p <- ggplot(tren_ct,
            aes(x = Bulan_lalu, y = CT_lalu, xend = Bulan, yend = RataCT)) +
  geom_segment(aes(color = Line), linewidth = 1,
               arrow = grid::arrow(length = grid::unit(3, "mm"))) +
  scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  labs(title = "45. geom_segment + panah", x = "Dari bulan",
       y = "Rata-rata cycle time (detik)", color = "Lini")
simpan(p, "45_segment")

# =====================================================================
# BAGIAN 5 — KOORDINAT KHUSUS: POLAR, ZOOM, TRANSFORMASI
# =====================================================================

# 46 Pie chart — geom_col + coord_polar(theta = "y")
p <- ggplot(ringkas_tipe, aes(x = "", y = Proporsi, fill = DefectType)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  scale_fill_brewer(palette = "Set2") +
  scale_y_continuous(labels = percent) +
  labs(title = "46. Pie chart", fill = "Jenis defect", x = NULL, y = NULL) +
  theme_void()
simpan(p, "46_pie")

# 47 Donut chart — pie dengan lubang tengah
p <- ggplot(ringkas_tipe, aes(x = 2, y = Proporsi, fill = DefectType)) +
  geom_col(width = 1, color = "white") +
  geom_text(aes(label = percent(Proporsi, 1)),
            position = position_stack(vjust = 0.5), size = 3.2) +
  coord_polar(theta = "y") +
  xlim(0.5, 2.5) +
  scale_fill_brewer(palette = "Set2") +
  scale_y_continuous(labels = percent) +
  labs(title = "47. Donut chart", fill = "Jenis defect") +
  theme_void()
simpan(p, "47_donut")

# 48 Coxcomb / rose chart — polar dengan theta = "x"
p <- ggplot(ringkas_tipe,
            aes(x = DefectType, y = TotalDefect, fill = DefectType)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "x") +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "48. Coxcomb (rose) chart", x = NULL, y = NULL,
       fill = "Jenis defect") +
  theme_minimal() +
  theme(axis.text.y = element_blank())
simpan(p, "48_rose")

# 49 Radar chart — polygon + coord_polar
p <- ggplot(profil, aes(x = Kriteria, y = Skor, group = 1)) +
  geom_polygon(fill = "steelblue", alpha = 0.3) +
  geom_polygon(fill = NA, color = "steelblue", linewidth = 1) +
  geom_point(color = "steelblue", size = 2.5) +
  coord_polar() +
  ylim(0, 100) +
  labs(title = "49. Radar chart", x = NULL, y = NULL)
simpan(p, "49_radar")

# 50 coord_cartesian — zoom TANPA membuang data (bandingkan kiri vs kanan)
dasar_zoom <- ggplot(inspeksi,
                     aes(x = InspectionDate, y = DefectRate, color = Line)) +
  geom_point(size = 2.5) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.8) +
  scale_y_continuous(labels = percent) +
  labs(x = "Tanggal", y = "Defect rate", color = "Lini") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
p_full <- dasar_zoom + labs(title = "50a. Tanpa zoom (rentang penuh)")
p_zoom <- dasar_zoom +
  coord_cartesian(ylim = c(0.02, 0.06)) +
  labs(title = "50b. coord_cartesian(ylim = c(0.02, 0.06))")
simpan_grid("50_coord_zoom", w = 11, h = 4.2, ncol = 2, p_full, p_zoom)

# 51 coord_fixed — rasio aspek sumbu x dan y sama
p <- ggplot(awan, aes(x = x, y = y)) +
  geom_point(alpha = 0.2, color = "steelblue") +
  coord_fixed(ratio = 1) +
  labs(title = "51. coord_fixed (1:1)", x = NULL, y = NULL)
simpan(p, "51_coord_fixed")

# 52 coord_trans — transformasi skala sumbu
p <- ggplot(inspeksi, aes(x = Inspected, y = Defect + 1)) +
  geom_point(color = "steelblue") +
  coord_trans(y = "log10") +
  scale_y_continuous(breaks = c(1, 2, 4, 8, 16), labels = c(0, 1, 3, 7, 15)) +
  labs(title = "52. coord_trans(y = 'log10')",
       x = "Unit diinspeksi", y = "Jumlah defect")
simpan(p, "52_coord_trans")

# =====================================================================
# BAGIAN 6 — FACET: PANEL PER KATEGORI
# =====================================================================

# 53 facet_wrap — panel otomatis
p <- ggplot(inspeksi, aes(x = Inspected, y = Defect)) +
  geom_point(color = "steelblue") +
  geom_smooth(method = "lm", fill = "lightblue") +
  facet_wrap(~ Line, nrow = 1) +
  labs(title = "53. facet_wrap(~ Line)",
       x = "Unit diinspeksi", y = "Jumlah defect")
simpan(p, "53_facet_wrap")

# 54 facet_grid — grid dua arah
p <- ggplot(inspeksi, aes(x = DefectType)) +
  geom_bar(fill = "steelblue") +
  facet_grid(Product ~ Line) +
  labs(title = "54. facet_grid(Product ~ Line)",
       x = "Jenis defect", y = "Jumlah inspeksi") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
simpan(p, "54_facet_grid")

# 55 Free scales + labeller kustom
p <- ggplot(inspeksi, aes(x = Defect)) +
  geom_histogram(binwidth = 1, fill = "steelblue", color = "white") +
  facet_wrap(~ Line, scales = "free",
             labeller = labeller(Line = c(A = "Lini A", B = "Lini B", C = "Lini C"))) +
  labs(title = "55. Facet: scales = 'free' + labeller",
       x = "Jumlah defect", y = "Frekuensi")
simpan(p, "55_facet_free")

# =====================================================================
# BAGIAN 7 — SCALES & PALET WARNA
# =====================================================================

# 56 scale_*_manual — warna kustom, label & urutan legenda
p <- ggplot(per_line_tipe, aes(x = Line, y = TotalDefect, fill = DefectType)) +
  geom_col(position = "stack") +
  scale_fill_manual(
    values = c(Scratch = "#E69F00", Dimension = "#56B4E9", Crack = "#009E73",
               Color = "#F0E442", NONE = "#999999"),
    limits = c("Scratch", "Dimension", "Crack", "Color", "NONE"),
    name = "Jenis defect"
  ) +
  scale_y_continuous(name = "Jumlah defect", breaks = pretty_breaks()) +
  scale_x_discrete(name = "Lini", labels = c("Lini A", "Lini B", "Lini C")) +
  labs(title = "56. scale_manual + label sumbu")
simpan(p, "56_scale_manual")

# 57 scale_fill_brewer — palet ColorBrewer
p <- ggplot(per_line_tipe, aes(x = DefectType, y = TotalDefect, fill = Line)) +
  geom_col(position = "dodge") +
  scale_fill_brewer(palette = "Blues") +
  labs(title = "57. scale_fill_brewer('Blues')",
       x = "Jenis defect", y = "Total defect", fill = "Lini")
simpan(p, "57_brewer")

# 58 Viridis diskret — colorblind-safe
p <- ggplot(per_line_tipe, aes(x = Line, y = TotalDefect, fill = DefectType)) +
  geom_col(position = "dodge") +
  scale_fill_viridis_d(option = "turbo", name = "Jenis defect") +
  labs(title = "58. scale_fill_viridis_d", x = "Lini", y = "Total defect")
simpan(p, "58_viridis_d")

# 59 Viridis kontinu — gradien defect rate per bulan & lini
panas_rate <- inspeksi |>
  group_by(Bulan = floor_date(InspectionDate, "month"), Line) |>
  summarize(DefectRate = sum(Defect) / sum(Inspected), .groups = "drop")

p <- ggplot(panas_rate, aes(x = Bulan, y = Line, fill = DefectRate)) +
  geom_tile(color = "white") +
  scale_fill_viridis_c(option = "mako", labels = percent, name = "Defect rate") +
  scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  labs(title = "59. scale_fill_viridis_c (gradien)", x = "Bulan") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
simpan(p, "59_viridis_c")

# 60 Gradien diverging — selisih defect rate terhadap target
vs_target <- panas_rate |>
  left_join(target, by = "Line") |>
  mutate(Selisih = DefectRate - TargetDR)

p <- ggplot(vs_target, aes(x = Bulan, y = Line, fill = Selisih)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "seagreen", mid = "white", high = "tomato",
                       midpoint = 0, labels = percent, name = "Selisih vs target") +
  scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  labs(title = "60. scale_fill_gradient2 (diverging)", x = "Bulan") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
simpan(p, "60_gradient2")

# 61 Kontrol breaks, limits, dan expand
p <- ggplot(ringkas_line, aes(x = Bulan, y = DefectRate, color = Line)) +
  geom_line(linewidth = 1) +
  scale_y_continuous(labels = percent, breaks = seq(0.02, 0.08, 0.01),
                     limits = c(0.015, 0.09), expand = c(0, 0)) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b %y",
               expand = expansion(mult = c(0.02, 0.02))) +
  labs(title = "61. Kontrol breaks / limits / expand",
       x = "Bulan", y = "Defect rate", color = "Lini")
simpan(p, "61_axis_control")

# 62 Skala bentuk manual
p <- ggplot(ringkas_line,
            aes(x = Bulan, y = RataCT, color = Line, shape = Line)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 3) +
  scale_shape_manual(values = c(15, 17, 19)) +
  scale_color_brewer(palette = "Dark2") +
  labs(title = "62. scale_shape_manual + brewer", x = "Bulan",
       y = "Rata-rata cycle time (detik)")
simpan(p, "62_shape_manual")

# =====================================================================
# BAGIAN 8 — TEMA & KUSTOMISASI TAMPILAN
# =====================================================================

# 63 Galeri theme siap pakai
dasar_bar <- ggplot(inspeksi, aes(x = Line, y = Defect, fill = Line)) +
  geom_col()
tanpa_legenda <- function(p) p + theme(legend.position = "none")

simpan_grid("63_tema", w = 10, h = 7, ncol = 3,
  tanpa_legenda(dasar_bar + theme_bw())      + labs(title = "theme_bw()"),
  tanpa_legenda(dasar_bar + theme_minimal()) + labs(title = "theme_minimal()"),
  tanpa_legenda(dasar_bar + theme_classic()) + labs(title = "theme_classic()"),
  tanpa_legenda(dasar_bar + theme_light())   + labs(title = "theme_light()"),
  tanpa_legenda(dasar_bar + theme_dark())    + labs(title = "theme_dark()"),
  tanpa_legenda(dasar_bar + theme_void())    + labs(title = "theme_void()")
)

# 64 Tema kustom lengkap dengan theme() + element_*
tema_qc <- theme_minimal(base_size = 11) +
  theme(
    plot.title         = element_text(face = "bold", size = 14, color = "grey15"),
    plot.subtitle      = element_text(color = "grey40", margin = margin(b = 8)),
    plot.caption       = element_text(color = "grey50", size = 8),
    axis.title         = element_text(face = "bold", color = "grey30"),
    axis.text          = element_text(color = "grey30"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    legend.position    = "bottom",
    legend.title       = element_text(face = "bold"),
    strip.text         = element_text(face = "bold", color = "white"),
    strip.background   = element_rect(fill = "steelblue")
  )

p <- ggplot(ringkas_line, aes(x = Bulan, y = DefectRate, color = Line)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_y_continuous(labels = percent) +
  labs(
    title    = "Profil Defect Rate per Lini Produksi",
    subtitle = "Bulan Juli-Agustus 2026",
    x = "Bulan", y = "Defect rate", color = "Lini",
    caption  = "Sumber: quality_inspection.csv"
  ) +
  tema_qc
simpan(p, "64_tema_kustom")

# 65 Detail tema: strip, grid minor, ukuran kunci legenda
p <- ggplot(inspeksi, aes(x = DefectType, y = Defect, fill = Line)) +
  geom_col(position = "dodge") +
  facet_wrap(~ Product) +
  labs(title = "65. Detail tema: strip, grid, legenda",
       x = "Jenis defect", y = "Jumlah defect", fill = "Lini") +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "darkorange"),
    strip.text       = element_text(face = "bold"),
    panel.grid.minor = element_line(color = "grey90", linewidth = 0.2),
    legend.key.size  = grid::unit(0.4, "cm")
  )
simpan(p, "65_tema_detail")

# =====================================================================
# BAGIAN 9 — GUIDES (KONTROL LEGENDA & COLORBAR)
# =====================================================================

# 66 guide_legend — posisi, jumlah baris, urutan, override
p <- ggplot(per_line_tipe, aes(x = Line, y = TotalDefect, fill = DefectType)) +
  geom_col(position = "dodge") +
  guides(fill = guide_legend(
    title = "Jenis defect", title.position = "top",
    nrow = 2, reverse = TRUE, override.aes = list(alpha = 0.7)
  )) +
  theme(legend.position = "bottom") +
  labs(title = "66. guide_legend: bawah, 2 baris, urutan terbalik",
       x = "Lini", y = "Total defect")
simpan(p, "66_guide_legend")

# 67 guide_colourbar — colorbar untuk skala kontinu
p <- ggplot(panas_rate, aes(x = Bulan, y = Line, fill = DefectRate)) +
  geom_tile(color = "white") +
  scale_fill_viridis_c(labels = percent) +
  guides(fill = guide_colourbar(
    title = "Defect rate", barwidth = 12, barheight = 1.5,
    frame.colour = "grey30", ticks.colour = "grey30"
  )) +
  scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  theme(legend.position = "bottom") +
  labs(title = "67. guide_colourbar", x = "Bulan") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
simpan(p, "67_guide_colorbar")

# =====================================================================
# BAGIAN 10 — STAT & after_stat
# =====================================================================

# 68 stat_count — stat eksplisit di belakang geom_bar
p <- ggplot(inspeksi, aes(x = DefectType)) +
  stat_count(geom = "bar", fill = "steelblue", width = 0.6) +
  labs(title = "68. stat_count(geom = 'bar')",
       x = "Jenis defect", y = "Frekuensi")
simpan(p, "68_stat_count")

# 69 Map hasil stat ke aesthetic: warna bar mengikuti frekuensi
p <- ggplot(inspeksi, aes(x = DefectType, fill = after_stat(count))) +
  geom_bar() +
  scale_fill_viridis_c(name = "Frekuensi") +
  labs(title = "69. after_stat(count) sebagai fill",
       x = "Jenis defect", y = "Frekuensi")
simpan(p, "69_after_stat_count")

# 70 Histogram density + kurva density menempel
p <- ggplot(inspeksi, aes(x = CycleTimeSec)) +
  geom_histogram(aes(y = after_stat(density)), binwidth = 2,
                 fill = "lightblue", color = "white") +
  geom_density(color = "tomato", linewidth = 1) +
  labs(title = "70. after_stat(density) + geom_density",
       x = "Cycle time (detik)", y = "Densitas")
simpan(p, "70_after_stat_density")

# =====================================================================
# BAGIAN 11 — LABEL, LAYOUT GABUNGAN, & PENYIMPANAN
# =====================================================================

# 71 labs lengkap: tag, title, subtitle, caption
p <- ggplot(inspeksi, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_brewer(palette = "Blues") +
  labs(
    tag      = "Gambar 1",
    title    = "Cycle Time per Lini Produksi",
    subtitle = "Median dan rentang antar-kuartil, Juli-Agustus 2026",
    x = "Lini", y = "Cycle time (detik)",
    caption  = "Sumber: quality_inspection.csv"
  ) +
  tema_qc
simpan(p, "71_labs")

# 72 Dashboard 2x2 — gabungkan empat grafik dalam satu kanvas (grid)
p_box <- ggplot(inspeksi, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_brewer(palette = "Blues") +
  labs(title = "Cycle time per lini", x = NULL, y = "detik")

p_stack <- ggplot(per_line_tipe,
                  aes(x = Line, y = TotalDefect, fill = DefectType)) +
  geom_col(position = "stack") +
  labs(title = "Defect per lini & jenis", x = NULL, y = "total defect",
       fill = "Jenis")

p_scatter <- ggplot(inspeksi, aes(x = Inspected, y = Defect)) +
  geom_point(color = "steelblue") +
  geom_smooth(method = "lm", fill = "lightblue") +
  labs(title = "Inspeksi vs defect", x = NULL, y = "defect")

p_tren <- ggplot(ringkas_line, aes(x = Bulan, y = DefectRate, color = Line)) +
  geom_line(linewidth = 1) +
  scale_y_continuous(labels = percent) +
  labs(title = "Tren defect rate", x = NULL, y = NULL, color = "Lini")

simpan_grid("72_dashboard_2x2", w = 11, h = 8, ncol = 2,
            p_box, p_stack, p_scatter, p_tren)

# Alternatif modern yang lebih ringkas:
#   install.packages("patchwork")
#   library(patchwork)
#   (p_box | p_stack) / (p_scatter | p_tren)

# 73 ggsave — simpan ke berbagai format
p <- ggplot(inspeksi, aes(x = DefectType, y = Defect)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Contoh ggsave multi-format",
       x = "Jenis defect", y = "Jumlah defect")

ggsave(file.path(dir_output, "73_ggsave.png"), p, width = 7, height = 4.5,
       dpi = 150, bg = "white")
ggsave(file.path(dir_output, "73_ggsave.pdf"), p, width = 7, height = 4.5)
if (requireNamespace("svglite", quietly = TRUE)) {
  ggsave(file.path(dir_output, "73_ggsave.svg"), p, width = 7, height = 4.5)
} else {
  message("SVG dilewati: install.packages('svglite') untuk ekspor SVG")
}

cat("\nSelesai! Semua contoh tersimpan di:", normalizePath(dir_output), "\n")
