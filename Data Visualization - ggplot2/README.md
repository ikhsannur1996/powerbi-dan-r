# Data Visualization dengan ggplot2

> Disarikan dari cheatsheet resmi Posit: **Data visualization with ggplot2** (`data-visualization.pdf`). ggplot2 dibangun di atas *grammar of graphics* — setiap grafik tersusun dari data, koordinat, dan *geom* (mark visual).

## Prasyarat

```r
library(ggplot2)
inspeksi <- read.csv("quality_inspection.csv")
```

## Contoh Chart Lengkap (73 contoh siap jalan)

Script [`contoh_visualisasi_ggplot2.R`](contoh_visualisasi_ggplot2.R) mendemokan hampir seluruh geom & komponen ggplot2 memakai `quality_inspection.csv`. Setiap grafik otomatis tersimpan sebagai PNG di [`output/`](output/), jadi bisa dipakai sebagai galeri referensi visual.

Jalankan dari root project (atau buka dan run per-bagian di RStudio):

```r
source("Data Visualization - ggplot2/contoh_visualisasi_ggplot2.R")
```

| Bagian | Isi | Contoh chart |
|---|---|---|
| 1 | Distribusi 1 variabel | histogram, density, freqpoly, dotplot, bar, lollipop, ECDF, Q-Q, box, violin |
| 2 | Diskret vs kontinu | boxplot/violin grup, col, grouped/stacked/100% bar, errorbar, pointrange, crossbar, linerange, stat_summary, jitter, heatmap |
| 3 | Kontinu vs kontinu | scatter, smooth lm/loess, bubble, multi-aes, geom_count, rug, text, bin2d, density 2D, hex\*, quantile\* |
| 4 | Waktu / tren | line, linetype, area, ribbon, step, path, garis referensi + annotate, segment + panah |
| 5 | Koordinat khusus | pie, donut, coxcomb (rose), radar, coord_cartesian / fixed / trans |
| 6–7 | Facet & scales | facet_wrap, facet_grid, free scales + labeller, manual/brewer/viridis/gradient2, kontrol breaks-limits-expand |
| 8–10 | Gaya & mesin plot | galeri tema, tema kustom, guides (legenda & colorbar), stat_count, after_stat |
| 11 | Produksi | labs lengkap, dashboard 2×2, ggsave multi-format |

\* butuh package opsional (`hexbin`, `quantreg`, `svglite`) — contoh terkait dilewati otomatis bila package belum terpasang.

## Template Dasar

```r
ggplot(data = <DATA>) +
  <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>), stat = <STAT>, position = <POSITION>) +
  <COORDINATE_FUNCTION> +
  <FACET_FUNCTION> +
  <SCALE_FUNCTION> +
  <THEME_FUNCTION>
```

Semua grafik dibangun dari komponen yang sama — tinggal ditambah layer demi layer dengan `+`.

## Materi

### 1. Geom satu variabel

```r
ggplot(inspeksi, aes(x = Defect)) +
  geom_histogram(binwidth = 1, fill = "steelblue")   # distribusi numerik

ggplot(inspeksi, aes(x = DefectType)) +
  geom_bar(fill = "darkorange")                      # distribusi diskret
```

Geoms lain: `geom_dotplot()`, `geom_density()`, `geom_freqpoly()`.

### 2. Dua variabel — x diskret, y kontinu

```r
ggplot(inspeksi, aes(x = Line, y = CycleTimeSec)) +
  geom_boxplot(fill = "lightblue")

ggplot(inspeksi, aes(x = DefectType, y = Defect)) +
  geom_col() + coord_flip()                          # bar horizontal
```

Geoms lain: `geom_violin()`, `geom_jitter()`, `geom_errorbar()`.

### 3. Dua variabel — keduanya kontinu

```r
ggplot(inspeksi, aes(x = Inspected, y = Defect)) +
  geom_point() +
  geom_smooth(method = lm)                           # scatter + garis tren
```

Geoms lain: `geom_label()`, `geom_quantile()`, `geom_rug()`, `geom_bin2d()`, `geom_density_2d()`, `geom_hex()`.

### 4. Visualisasi error

```r
ggplot(df, aes(x = grp, y = fit, ymin = fit - se, ymax = fit + se)) +
  geom_pointrange()
```

### 5. Aesthetics — memetakan variabel ke properti visual

```r
ggplot(inspeksi, aes(x = Line, y = CycleTimeSec, fill = DefectType)) +
  geom_boxplot()                                     # warna isi per jenis defect

ggplot(inspeksi, aes(x = Inspected, y = Defect, color = Line, size = Defect)) +
  geom_point(alpha = 0.6)
```

Aesthetics umum: `x`, `y`, `alpha`, `color`, `fill`, `linetype`, `size`, `shape`, `stroke`, `group`.

### 6. Faceting — panel per kategori

```r
ggplot(inspeksi, aes(x = Defect)) +
  geom_histogram(binwidth = 1) +
  facet_grid(Line ~ .)          # baris per Line

ggplot(inspeksi, aes(x = Inspected, y = Defect)) +
  geom_point() +
  facet_wrap(~ Product)         # wrap otomatis
```

### 7. Scales — kontrol legenda & sumbu

```r
ggplot(inspeksi, aes(x = DefectType, fill = Line)) +
  geom_bar() +
  scale_fill_manual(
    values = c("skyblue", "royalblue", "navy"),
    name   = "Lini",
    limits = c("A", "B", "C"),
    labels = c("Lini A", "Lini B", "Lini C")
  ) +
  scale_y_continuous(name = "Jumlah Defect")
```

Jenis scale: `scale_*_continuous()`, `scale_*_discrete()`, `scale_*_manual()`, `scale_fill_brewer()`, `scale_size_area()`.

### 8. Coordinate system

```r
+ coord_flip()                        # tukar sumbu x-y
+ coord_polar(theta = "x")            # koordinat polar / pie
+ coord_trans(y = "sqrt")             # transformasi skala
+ coord_cartesian(xlim = c(0, 100))   # zoom TANPA membuang data (disarankan)
```

### 9. Stat — mengubah stat default geom

```r
ggplot(inspeksi, aes(x = DefectType)) +
  stat_count(geom = "bar")                    # ekuivalen geom_bar(stat = "count")

ggplot(inspeksi, aes(x = Line, y = Defect)) +
  geom_col(aes(fill = after_stat(count)))     # map variabel hasil stat
```

### 10. Labels & themes

```r
ggplot(inspeksi, aes(x = Line, y = Defect, fill = DefectType)) +
  geom_col() +
  labs(
    title    = "Profil Defect per Lini Produksi",
    subtitle = "Sumber: quality_inspection.csv",
    x = "Lini", y = "Jumlah Defect", fill = "Jenis Defect"
  ) +
  theme_minimal() +
  theme(plot.title.position = "plot")
```

Themes siap pakai: `theme_minimal()`, `theme_bw()`, `theme_classic()`, `theme_light()`; kustomisasi via `theme()` + `element_rect()`, `element_text()`, `element_line()`.

## Exercise

Kerjakan dengan `quality_inspection.csv`:

1. **Histogram**: distribusi `CycleTimeSec` dengan `binwidth` yang wajar, beri judul + label sumbu.
2. **Boxplot**: `CycleTimeSec` per `Line`, warnai berdasarkan `Product`.
3. **Stacked bar**: jumlah defect per `Line`, ditumpuk per `DefectType` (gunakan `geom_bar` + `fill`).
4. **Scatter + smooth**: `Inspected` vs `Defect` dengan garis tren `geom_smooth(method = lm)`.
5. **Facet**: ulangi nomor 4 tetapi dipecah per `Line` menggunakan `facet_wrap`.
6. **Scales**: pada nomor 3, atur warna manual + label legenda berbahasa Indonesia.
7. **Tantangan dashboard**: gabungkan hasil nomor 2–5 menjadi satu layout 2×2 dengan `patchwork` atau `gridExtra`.

## Tips & Tricks

- Zoom dengan `coord_cartesian(xlim = ...)` **bukan** `xlim()` — `xlim()` membuang data di luar rentang sehingga garis `geom_smooth` ikut berubah.
- `aes()` di dalam `ggplot()` berlaku untuk semua layer; pindahkan ke dalam `geom_*()` bila hanya berlaku untuk satu layer.
- `alpha = 0.5` pada `geom_point`/`geom_bar` untuk mengatasi titik/bar yang bertumpuk.
- `reorder()` untuk mengurutkan kategori berdasarkan nilai: `aes(x = reorder(DefectType, -Defect))` — bar chart langsung urut dari besar ke kecil.
- `position = "dodge"` (berdampingan), `"stack"` (menumpuk), `"fill"` (normalisasi 100%) pada `geom_bar`/`geom_col`.
- `geom_col()` untuk nilai yang sudah dihitung; `geom_bar()` untuk hitung frekuensi otomatis — jangan tertukar.
- Gunakan `after_stat()` (bukan `..count..`) untuk memetakan variabel hasil stat pada ggplot2 modern.
- `scale_fill_brewer(palette = "Blues")` / `scale_color_viridis_c()` untuk palet yang *colorblind-safe*.
- Simpan grafik sebagai objek (`p1 <- ggplot(...)`) lalu tampilkan/gabungkan — penting untuk layout dashboard.
- Untuk Power BI: pastikan visual ggplot2 dibangun dari data frame yang dikirim Power BI, dan gunakan `theme()` konsisten agar tampilan menyatu dengan dashboard.
- Render lebih tajam di R Markdown/Quarto dengan `fig.width`, `fig.height`, dan `dpi = 150`+ di chunk options.

## Referensi

- Cheatsheet: `data-visualization.pdf` (Posit, ggplot2 4.0.3, Aug 2026)
- <https://ggplot2.tidyverse.org>


