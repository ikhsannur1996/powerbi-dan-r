# =====================================================================
# 01_visualisasi_ggplot2.R — Galeri lengkap sample Basic Visualization
# =====================================================================
# File   : 01_visualisasi_ggplot2.R
# Data   : data/visualisasi_sample.csv (900 baris, 9 kolom)
# Luaran : output/V01_*.png s.d. V73_*.png (galeri 73 contoh ggplot2)
# Cara   : source("Volume 1 - Basic Visualization ggplot/R/01_visualisasi_ggplot2.R")
# Catatan: semua contoh = "all samples" yang dicita di README.md Volume 1.
#          Bagan 1..11 di bawah berkoresponden satu-untu-k satu dengan
#          Bab 6..15 README.md, jadi galeri PNG = cermin dokumen.
# =====================================================================

library(ggplot2)   # grafik
library(dplyr)     # manipulasi data
library(lubridate) # floor_date / tanggal
library(scales)    # percent, comma, pretty_breaks
library(forcats)   # fct_reorder
library(grid)      # layout gabungan (dashboard)

# ---- 0.1 Path & helper -------------------------------------------------
# Adaptif: bisa dijalankan dari root repo ATAU dari folder skrip di RStudio.
base <- "Volume 1 - Basic Visualization ggplot"
if (!dir.exists(base)) base <- ".."

dir_output <- file.path(base, "output")
dir.create(dir_output, showWarnings = FALSE)

# Tampilkan di RStudio (interaktif) + simpan PNG via ggsave().
simpan <- function(p, nama, w = 7, h = 4.5) {
  if (interactive()) print(p)
  ggsave(file.path(dir_output, paste0("V", nama, ".png")), p,
         width = w, height = h, dpi = 150, bg = "white")
  invisible(p)
}

# Gabungkan beberapa plot dalam satu kanvas (tanpa package tambahan).
# Alternatif modern yang lebih ringkas: package `patchwork`.
gabung_grid <- function(..., ncol = 2) {
  plots <- list(...)
  n_br  <- ceiling(length(plots) / ncol)
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(n_br, ncol)))
  for (i in seq_along(plots)) {
    baris <- ceiling(i / ncol)
    kolom <- ((i - 1L) %% ncol) + 1L
    pushViewport(viewport(layout.pos.row = baris, layout.pos.col = kolom))
    grid.draw(ggplotGrob(plots[[i]]))
    popViewport()
  }
  popViewport()
}
simpan_grid <- function(nama, w = 12, h = 8, ncol = 2, ...) {
  if (interactive()) gabung_grid(ncol = ncol, ...)
  png(file.path(dir_output, paste0("V", nama, ".png")),
      width = w, height = h, units = "in", res = 150)
  gabung_grid(ncol = ncol, ...)
  dev.off()
  invisible(NULL)
}

# ---- 0.2 Data utama ------------------------------------------------------
inspeksi <- read.csv(file.path(base, "data", "visualisasi_sample.csv")) |>
  mutate(
    InspectionDate = as.Date(InspectionDate),
    DefectRate = Defect / Inspected,
    Line       = factor(Line,       levels = c("A", "B", "C")),
    Product    = factor(Product),
    DefectType = factor(DefectType,
                        levels = c("Scratch", "Dimension", "Crack", "Color", "NONE"))
  )

# ---- 0.3 Tabel ringkasan (agregasi dplyr) --------------------------------
ringkas_tipe <- inspeksi |>
  group_by(DefectType) |>
  summarize(TotalDefect = sum(Defect), .groups = "drop") |>
  mutate(
    Proporsi   = TotalDefect / sum(TotalDefect),
    DefectType = fct_reorder(DefectType, TotalDefect)
  )

per_line_tipe <- inspeksi |>
  group_by(Line, DefectType) |>
  summarize(TotalDefect = sum(Defect), .groups = "drop")

ringkas_line <- inspeksi |>
  group_by(Bulan = floor_date(InspectionDate, "month"), Line) |>
  summarize(
    Inspected = sum(Inspected),
    Defect    = sum(Defect),
    RataCT    = mean(CycleTimeSec),
    .groups   = "drop"
  ) |>
  mutate(DefectRate = Defect / Inspected)

per_bulan <- inspeksi |>
  group_by(Bulan = floor_date(InspectionDate, "month")) |>
  summarize(
    DefectRate  = sum(Defect) / sum(Inspected),
    DR_min      = min(Defect / Inspected),
    DR_maks     = max(Defect / Inspected),
    TotalDefect = sum(Defect),
    .groups     = "drop"
  )

kumulatif <- inspeksi |>
  group_by(InspectionDate) |>
  summarize(TotalDefect = sum(Defect), .groups = "drop") |>
  arrange(InspectionDate) |>
  mutate(Kumulatif = cumsum(TotalDefect))

ringkas_ct <- inspeksi |>
  group_by(Line) |>
  summarize(
    rata    = mean(CycleTimeSec),
    sd      = sd(CycleTimeSec),
    minim   = min(CycleTimeSec),
    maks    = max(CycleTimeSec),
    .groups = "drop"
  )

target <- data.frame(Line = c("A", "B", "C"), TargetDR = c(0.03, 0.04, 0.035))

# ---- 0.4 Data sintetis (untuk contoh yang butuh banyak titik) ------------
set.seed(42)
awan <- data.frame(
  x = c(rnorm(1500, 120, 8),  rnorm(600, 132, 6)),
  y = c(rnorm(1500, 42, 2.5), rnorm(600, 48, 2))
)
walk <- data.frame(
  langkah = 1:60,
  posisi  = cumsum(rnorm(60))
)
profil <- data.frame(
  Kriteria = factor(c("Kualitas", "Kecepatan", "Biaya", "Keandalan", "Fleksibilitas"),
                    levels = c("Kualitas", "Kecepatan", "Biaya", "Keandalan", "Fleksibilitas")),
  Skor     = c(85, 70, 60, 90, 75)
)

cat("Setup selesai — grafik akan tersimpan di:", normalizePath(dir_output), "\n")

# =====================================================================
# BAGIAN 1 — DISTRIBUSI SATU VARIABEL  (README Bab 6)
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
# BAGIAN 2 — DISKRET vs KONTINU  (README Bab 7)
# =====================================================================

# 11 Boxplot grup — sebaran variabel kontinu per kategori
p <- ggplot(inspeksi, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot() +
  labs(title = "11. Boxplot per lini", x = "Lini", y = "Cycle time (detik)")
simpan(p, "11_boxplot_grup")

# 12 Violin grup — bentuk sebaran + boxplot dalam
p <- ggplot(inspeksi, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_violin() +
  geom_boxplot(width = 0.15, fill = "white") +
  labs(title = "12. Violin + boxplot per lini", x = "Lini", y = "Cycle time (detik)")
simpan(p, "12_violin_grup")

# 13 Col chart — bar dari nilai yang diagregat dulu (stat "identity")
p <- ggplot(ringkas_tipe, aes(x = DefectType, y = TotalDefect)) +
  geom_col(fill = "steelblue") +
  labs(title = "13. Col chart (nilai agregat)", x = "Jenis defect", y = "Total defect")
simpan(p, "13_col")

# 14 Bar horizontal — coord_flip untuk nama kategori panjang
p <- ggplot(ringkas_tipe, aes(x = DefectType, y = TotalDefect)) +
  geom_col(fill = "tomato") +
  coord_flip() +
  labs(title = "14. Col horizontal (coord_flip)", x = NULL, y = "Total defect")
simpan(p, "14_col_horizontal")

# 15 Dodge — bar per kategori SISALAN bukan tumpuk
p <- ggplot(per_line_tipe, aes(x = Line, y = TotalDefect, fill = DefectType)) +
  geom_col(position = "dodge") +
  labs(title = "15. Col dodge", x = "Lini", y = "Total defect", fill = "Jenis")
simpan(p, "15_dodge")

# 16 Stack — bar tumpuk (komposisi)
p <- ggplot(per_line_tipe, aes(x = Line, y = TotalDefect, fill = DefectType)) +
  geom_col(position = "stack") +
  labs(title = "16. Col stack", x = "Lini", y = "Total defect", fill = "Jenis")
simpan(p, "16_stack")

# 17 Fill — bar 100% (proporsi per kategori)
p <- ggplot(per_line_tipe, aes(x = Line, y = TotalDefect, fill = DefectType)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = percent) +
  labs(title = "17. Col fill (100%)", x = "Lini", y = "Proporsi", fill = "Jenis")
simpan(p, "17_fill")

# 18 Errorbar — rata-rata + rentang SD (ringkas_ct)
p <- ggplot(ringkas_ct, aes(x = Line, y = rata)) +
  geom_col(fill = "steelblue", alpha = 0.6) +
  geom_errorbar(aes(ymin = rata - sd, ymax = rata + sd), width = 0.3) +
  labs(title = "18. Col + errorbar (SD)", x = "Lini", y = "Rata-rata cycle time")
simpan(p, "18_errorbar")

# 19 Pointrange — titik rata-rata dengan rentang min-maks
p <- ggplot(ringkas_ct, aes(x = Line, y = rata)) +
  geom_pointrange(aes(ymin = minim, ymax = maks), color = "seagreen", size = 1.2) +
  labs(title = "19. Pointrange (min-maks)", x = "Lini", y = "Rata-rata cycle time")
simpan(p, "19_pointrange")

# 20 Crossbar — kotak median + rentang kuartil
p <- ggplot(ringkas_ct, aes(x = Line, y = rata,
                            ymin = rata - sd, ymax = rata + sd)) +
  geom_crossbar(fill = "lightblue") +
  labs(title = "20. Crossbar (rata ± SD)", x = "Lini", y = "Cycle time")
simpan(p, "20_crossbar")

# 21 Linerange — garis rentang tanpa dekorasi
p <- ggplot(ringkas_ct, aes(x = Line, y = rata,
                            ymin = minim, ymax = maks)) +
  geom_linerange(color = "steelblue", linewidth = 2) +
  geom_point(size = 3, color = "tomato") +
  labs(title = "21. Linerange (min-maks) + titik", x = "Lini", y = "Cycle time")
simpan(p, "21_linerange")

# 22 stat_summary — agregasi otomatis per kategori (rata-rata ± SD)
p <- ggplot(inspeksi, aes(x = Line, y = CycleTimeSec)) +
  geom_jitter(width = 0.2, alpha = 0.3, color = "grey40") +
  stat_summary(fun = mean,
               fun.min = function(x) mean(x) - sd(x),
               fun.max = function(x) mean(x) + sd(x),
               geom = "linerange", color = "tomato", linewidth = 1.2) +
  labs(title = "22. stat_summary (rata-rata ± SD)", x = "Lini", y = "Cycle time (detik)")
simpan(p, "22_stat_summary")

# 23 Boxplot + jitter — titik asli atas kotak
p <- ggplot(inspeksi, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.2, alpha = 0.4) +
  labs(title = "23. Boxplot + jitter", x = "Lini", y = "Cycle time (detik)")
simpan(p, "23_boxplot_jitter")

# 24 Heatmap — intensitas relasi dua kategori (geom_tile)
p <- ggplot(per_line_tipe, aes(x = Line, y = DefectType, fill = TotalDefect)) +
  geom_tile(color = "white") +
  scale_fill_viridis_c(option = "plasma", name = "Total defect") +
  labs(title = "24. Heatmap (geom_tile)", x = "Lini", y = "Jenis defect")
simpan(p, "24_heatmap")

# =====================================================================
# BAGIAN 3 — KONTINU vs KONTINU  (README Bab 8)
# =====================================================================

# 25 Scatter — hubungan dua variabel numerik
p <- ggplot(inspeksi, aes(x = Inspected, y = Defect, color = Line)) +
  geom_point(size = 3, alpha = 0.6) +
  labs(title = "25. Scatter plot", x = "Unit diinspeksi", y = "Jumlah defect",
       color = "Lini")
simpan(p, "25_scatter")

# 26 Smooth lm — garis regresi linear + band kepercayaan
p <- ggplot(inspeksi, aes(x = Inspected, y = Defect)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm", fill = "lightblue") +
  labs(title = "26. Scatter + smooth (lm)", x = "Unit diinspeksi", y = "Jumlah defect")
simpan(p, "26_smooth_lm")

# 27 Bandingkan lm vs loess
p <- ggplot(inspeksi, aes(x = Inspected, y = Defect)) +
  geom_point(alpha = 0.5) +
  geom_smooth(aes(color = "Linear"), method = "lm",    se = FALSE) +
  geom_smooth(aes(color = "Loess"),  method = "loess", se = FALSE) +
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
# BAGIAN 4 — DATA WAKTU / TREN  (README Bab 8.14-8.21)
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
               arrow = arrow(length = unit(0.25, "cm"), type = "closed")) +
  labs(title = "45. Segment + panah (pergerakan antar bulan)",
       x = "Bulan", y = "Cycle time (detik)", color = "Lini")
simpan(p, "45_segment_arrow")

# =====================================================================
# BAGIAN 5 — KOORDINAT KUNSU  (README Bab 9)
# =====================================================================

# 46 Pie — komposisi kategori (coord_polar theta = "y")
p <- ggplot(ringkas_tipe, aes(x = "", y = TotalDefect, fill = DefectType)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "46. Pie chart", x = NULL, y = NULL, fill = "Jenis defect")
simpan(p, "46_pie")

# 47 Donut — pie dengan lubang tengah (x = 2, xlim mulai > 0)
p <- ggplot(ringkas_tipe, aes(x = 2, y = TotalDefect, fill = DefectType)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  xlim(0.5, 2.5) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "47. Donut chart", x = NULL, y = NULL, fill = "Jenis defect")
simpan(p, "47_donut")

# 48 Rose (coxcomb) — bar radian per kategori (coord_polar theta = "x")
p <- ggplot(per_line_tipe, aes(x = DefectType, y = TotalDefect, fill = Line)) +
  geom_col(width = 1) +
  coord_polar() +
  scale_fill_brewer(palette = "Dark2") +
  labs(title = "48. Rose chart (coxcomb)", x = NULL, y = NULL, fill = "Lini")
simpan(p, "48_rose")

# 49 Radar — profil multi-kriteria (coord_polar + geom_path)
p <- ggplot(profil, aes(x = Kriteria, y = Skor, group = 1)) +
  geom_path(linewidth = 1.2, color = "tomato") +
  geom_point(size = 3, color = "tomato") +
  coord_polar(direction = 1) +
  ylim(0, 100) +
  labs(title = "49. Radar chart (profil)",
       x = NULL, y = "Skor (0-100)")
simpan(p, "49_radar")

# 50 coord_cartesian — zoom tehnis x/y limits (tanpa buang data)
dasar_zoom <- ggplot(ringkas_line, aes(x = Bulan, y = DefectRate, color = Line)) +
  geom_line(linewidth = 1) +
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

# 52 coord_transform — transformasi skala sumbu (log10 pada y)
#   (nama lama di ggplot2 < 4.0: coord_trans())
p <- ggplot(inspeksi, aes(x = Inspected, y = Defect + 1)) +
  geom_point(color = "steelblue") +
  coord_transform(y = "log10") +
  scale_y_continuous(breaks = c(1, 2, 4, 8, 16), labels = c(0, 1, 3, 7, 15)) +
  labs(title = "52. coord_transform(y = 'log10')",
       x = "Unit diinspeksi", y = "Jumlah defect")
simpan(p, "52_coord_trans")

# =====================================================================
# BAGIAN 6 — FACET: PANEL PER KATEGORI  (README Bab 10)
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
# BAGIAN 7 — SCALES & PALET WARNA  (README Bab 11)
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
# BAGIAN 8 — TEMA & KUSTOMISASI TAMPILAN  (README Bab 12)
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
    title    = "Profil Defect Rate Bulanan",
    subtitle = "Per lini produksi — Juli–November 2026",
    x        = "Bulan", y = "Defect rate", color = "Lini"
  ) +
  tema_qc
simpan(p, "64_tema_kustom", w = 8, h = 4.5)

# 65 Detail tema: grid, sumbu, garisan kotak, strip facet
p <- ggplot(ringkas_line, aes(x = Bulan, y = DefectRate, color = Line)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_y_continuous(labels = percent) +
  facet_wrap(~ Line, nrow = 1) +
  labs(title = "65. Detail tema (facet per lini)", x = "Bulan",
       y = "Defect rate") +
  theme_minimal(base_size = 10) +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    axis.text.x        = element_text(angle = 45, hjust = 1, size = 8),
    panel.border       = element_rect(color = "grey60", fill = NA),
    strip.background   = element_rect(fill = "lightblue"),
    strip.text         = element_text(face = "bold", color = "grey20")
  )
simpan(p, "65_tema_detail")

# =====================================================================
# BAGIAN 9 — GUIDES: KONTROL LEGENDA  (README Bab 13)
# =====================================================================

# 66 Guide legenda — posisi, urutan, susunan multi-kolom
p <- ggplot(inspeksi, aes(x = InspectionDate, y = Defect, color = Line)) +
  geom_line(aes(group = Line), color = "grey60") +
  geom_point(size = 2.5) +
  scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  guides(color = guide_legend(
    title = "Lini produksi",
    override.aes = list(size = 4, shape = 21),
    nrow = 1, byrow = TRUE,
    theme = theme(legend.background = element_rect(fill = "grey90"))
  )) +
  theme(legend.position = "top") +
  labs(title = "66. guide_legend (kontrol)", x = "Bulan", y = "Jumlah defect")
simpan(p, "66_guide_legend")

# 67 Guide colorbar — kontrol bar gradien
p <- ggplot(panas_rate, aes(x = Bulan, y = Line, fill = DefectRate)) +
  geom_tile(color = "white") +
  scale_fill_viridis_c(name = "Defect rate", labels = percent) +
  guides(fill = guide_colorbar(barheight = 4, barwidth = 0.6,
                               title.position = "top",
                               theme = theme(legend.title = element_text(angle = 90)),
                               reverse = TRUE)) +
  scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  theme(legend.position = "bottom") +
  labs(title = "67. guide_colourbar", x = "Bulan") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
simpan(p, "67_guide_colorbar")

# =====================================================================
# BAGIAN 10 — STAT & after_stat  (README Bab 14)
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
# BAGIAN 11 — LABEL, LAYOUT GABUNGAN, & PENYIMPANAN  (README Bab 15)
# =====================================================================

# 71 labs lengkap: tag, title, subtitle, caption
p <- ggplot(inspeksi, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_brewer(palette = "Blues") +
  labs(
    tag      = "Gambar 1",
    title    = "Cycle Time per Lini Produksi",
    subtitle = "Median dan rentang antar-kuartil, Juli-November 2026",
    x = "Lini", y = "Cycle time (detik)",
    caption  = "Sumber: visualisasi_sample.csv"
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

# Alternatif modern yang lebih ringkas (package patchwork):
#   install.packages("patchwork"); library(patchwork)
#   (p_box | p_stack) / (p_scatter | p_tren)

# 73 ggsave — simpan ke berbagai format
p <- ggplot(inspeksi, aes(x = DefectType, y = Defect)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Contoh ggsave multi-format",
       x = "Jenis defect", y = "Jumlah defect")

ggsave(file.path(dir_output, "V73_ggsave.png"), p, width = 7, height = 4.5,
       dpi = 150, bg = "white")
ggsave(file.path(dir_output, "V73_ggsave.pdf"), p, width = 7, height = 4.5)
if (requireNamespace("svglite", quietly = TRUE)) {
  ggsave(file.path(dir_output, "V73_ggsave.svg"), p, width = 7, height = 4.5)
} else {
  message("SVG dilewati: install.packages('svglite') untuk ekspor SVG")
}

cat("\nSelesai! Semua contoh tersimpan di:", normalizePath(dir_output), "\n")
cat("Total file PNG:", length(list.files(dir_output, pattern = "\\.png$")), "\n")