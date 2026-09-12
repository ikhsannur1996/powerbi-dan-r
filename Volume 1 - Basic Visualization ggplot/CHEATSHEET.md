# 📊 CHEATSHEET Volume 1 — Basic Visualization ggplot2

> Satu halaman referensi cepat untuk **menghafal dan memahami sintaks ggplot2**. Pasangkan dengan `README.md`. Salin-tempel contoh ini langsung di RStudio dan ubah datanya.

---

## 1. Setup & Data

```r
library(ggplot2); library(dplyr); library(lubridate)
library(scales); library(forcats)

inspeksi <- read.csv("data/visualisasi_sample.csv") |>
  mutate(InspectionDate = as.Date(InspectionDate),
         DefectRate = Defect / Inspected,
         Line = factor(Line, levels = c("A", "B", "C")),
         DefectType = factor(DefectType,
                             levels = c("Scratch","Dimension","Crack","Color","NONE")))
```

## 2. Template Dasar (semua grafik dari ini)

```r
ggplot(data = inspeksi,
       mapping = aes(x, y, color, fill, size, shape, alpha, linetype, group)) +
  geom_*() +            # mark visual (layer digambar atas-below)
  scale_*() +           # format label / warna
  coord_*() +           # koordinat
  facet_*() +           # multi-panel
  theme_*() +           # gaya non-data
  labs(...)             # judul, sumbu, legend, caption
```

## 3. Geom — Apa Grafik Kapan (sample nomor)

| Data shape | Geom | Grafik | Sample |
|---|---|---|---|
| 1 numerik | `geom_histogram(binwidth = 1)` | histogram | 01 |
| 1 numerik (kurva) | `geom_density(fill = .., alpha = 0.5)` | density | 02 |
| 1 diskret (count auto) | `geom_bar()` | bar count | 05 |
| 1 kategori (nilai agregat) | `geom_col()` | col | 13 |
| kontinu ~ kategori | `geom_boxplot()` / `geom_violin()` / `geom_jitter()` | box/violin/jitter | 11/12/23 |
| kategori ~ kategori (intensitas) | `geom_tile()` | heatmap | 24 |
| kontinu ~ kontinu | `geom_point()` | scatter | 25 |
| kontinu ~ kontinu + model | `geom_smooth(method = "lm"/"loess")` | regresi | 26/27 |
| kontinu ~ kontinu (3-am variabel) | `geom_point(aes(size = ...))` | bubble | 28 |
| tanggal ~ nilai | `geom_line()` + `geom_point()` | line chart | 38 |
| tanggal ~ nilai (komposisi) | `geom_area()` | area | 40 |
| rentang (>1 serie) | `geom_ribbon(aes(ymin, ymax))` | band | 41 |
| kumulatif | `geom_step()` | step | 42 |
| data padat (10k+ titik) | `geom_bin2d()` / `geom_density_2d()` / `geom_hex()` | bin/contur | 33-36 |
| rata ± SD / min-maks | `geom_errorbar()` / `geom_linerange()` / `geom_pointrange()` | interval | 18-21 |
| pie/donut/radar | `coord_polar()` | polar | 46-49 |

---

## 4. Aesthetics

```r
aes(x, y,                  # sumbu
    color = kategori,      # warna garis/titik
    fill   = kategori,     # warna isi (bar, boxplot, area)
    size   = numerik,      # ukuran titik
    shape  = kategori,     # bentuk titik (<= 6 grup)
    alpha  = numerik,      # transparansi
    linetype = kategori,   # jenis garis
    group  = kategori)     # grup garis (untuk geom_line)
```

Global (`ggplot()`) vs lokal (`geom_()`): global berlaku semua layer.

## 5. Position Bar

```r
geom_col(position = "dodge")   # bar sisalan  (sample 15)
geom_col(position = "stack")   # bar tumpuk   (sample 16)
geom_col(position = "fill")    # bar 100%     (sample 17)
geom_point(position = "jitter")# titik noise  (sample 22-23)
```

## 6. Scales — Format Label & Warna

```r
scale_y_continuous(labels = percent)                      # 0.04 -> 4%
scale_y_continuous(labels = comma)                        # 1234 -> 1,234
scale_y_continuous(breaks = seq(0, .1, .01), limits = c(0, .1),
                   expand = c(0, 0))                      # kontrol tick/rentang
scale_x_date(date_labels = "%b %Y", date_breaks = "1 month")  # label tanggal
scale_fill_brewer(palette = "Blues")                      # ColorBrewer
scale_fill_viridis_d(option = "turbo")                    # diskret colorblind-safe
scale_fill_viridis_c(option = "mako", labels = percent)   # kontinu gradien
scale_fill_gradient2(low = "green", mid = "white", high = "red",
                     midpoint = 0)                        # diverging vs target
scale_fill_manual(values = c(A = "#E69F00", B = "#56B4E9"))  # warna brand
scale_shape_manual(values = c(15, 17, 19))                # bentuk titik
```

**Format tanggal:** `%Y`=2026 `%y`=26 `%b`=Jul `%m`=07 `%d`=01 `%e`=1

## 7. Facet — Multi-Panel

```r
facet_wrap(~ Line)                    # panel otomatis
facet_wrap(~ Line, nrow = 1)
facet_grid(Product ~ Line)            # grid dua arah
facet_wrap(~ Line, scales = "free")   # skala tiap panel sendiri
labeller(Line = c(A = "Lini A"))      # rename label panel
```

## 8. Koordinat

```r
coord_flip()                    # x <-> y (bar horizontal)
coord_polar(theta = "y")        # pie/donut (donut: x = 2 + xlim(0.5, 2.5))
coord_cartesian(ylim = c(0, .1))# ZOOM aman (bukan ylim()!)
coord_fixed(ratio = 1)          # rasio aspek 1:1
coord_transform(y = "log10")    # skala log (lama: coord_trans)
```

---

## 9. Theme & Labs

```r
theme_minimal()  theme_bw()  theme_classic()  theme_light()  theme_dark()  theme_void()

labs(title = "Judul pertanyaan?", subtitle = "...", tag = "Gambar 1",
     x = "Sumbu X", y = "Sumbu Y", caption = "Sumber: ...")

theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold", size = 14),
        panel.grid.major.x = element_blank(),
        legend.position = "bottom",
        axis.text.x = element_text(angle = 45, hjust = 1),
        strip.background = element_rect(fill = "steelblue"))

guides(color = guide_legend(title = "...", nrow = 1, override.aes = list(size = 4)))
guides(fill = guide_colorbar(barheight = 4, barwidth = 0.6, reverse = TRUE))
```

## 10. Annotasi

```r
geom_hline(yintercept = 0.04, linetype = "dashed", color = "red")  # target
geom_vline(xintercept = ...)
annotate("text", x = ..., y = ..., label = "...")                  # teks bebas
annotate("rect", xmin = ..., xmax = ..., ymin = -Inf, ymax = Inf)  # zona
geom_text(aes(label = kolom), vjust = -0.5)                        # label titik
geom_segment(aes(xend = .., yend = ..), arrow = arrow(length = unit(0.25, "cm")))
```

## 11. Stat & after_stat

```r
stat_count(geom = "bar")                        # frekuensi eksplisit
aes(fill = after_stat(count))                   # warna <- hasil stat
geom_histogram(aes(y = after_stat(density)))    # histogram skala densitas
stat_summary(fun = mean, fun.min = ~, fun.max = ~)  # statistik di-grafik
```

## 12. Simpan Hasil

```r
ggsave("output/plot.png", p, width = 8, height = 5, dpi = 300)  # png
ggsave("output/plot.pdf", p, width = 8, height = 5)             # vector
ggsave("output/plot.svg", p)                                    # butuh svglite
write.csv(df, "output/df.csv", row.names = FALSE)               # data agregat

# gabung multiple plot: library(patchwork); (p1 | p2) / (p3 | p4)
```

---

## 13. Problem -> Fix Cepat

| Problem | Fix |
|---|---|
| Grafik kosong / eror `object not found` | `str(df)` + `names(df)`; kolom = character/NA? |
| Persentase tampil 0.04 bukan 4% | `labels = percent` (scales) |
| Bar tidak tersusun oleh nilai | `fct_reorder()`, `geom_col(aes(x = reorder(...)))` |
| Tanggal tampil angka | `as.Date()` dulu + `scale_x_date()` |
| Smooth ubah setelah zoom | `coord_cartesian()`, bukan `ylim()` |
| 10.000 titik bertumpuk | `geom_bin2d()` / `geom_hex()` / agregat / facet |
| `could not find function "geom_col"` | ggplot2 < 3.5 → update |
| `arrow()` error length unit | `arrow(length = unit(0.25, "cm"))` |

## 14. Map Penting: Apa Grafik untuk Apa Pertanyaan?

```text
Pertanyaan Keseluruhan          -> Histogram / Density / Boxplot (01,02,09)
Sebaran per kategori            -> Boxplot / Violin / Jitter (11,12,23)
Perbandingan kategori           -> Col / Dodge / Lollipop (13,14,06)
Komposisi / proporsi            -> Stack / Fill / Pie / Donut (16,17,46,47)
Hubungan dua numerik            -> Scatter + smooth (25-27)
Tren dari waktu ke waktu        -> Line / Area / Step (38,40,42)
Dua kategori intensitas         -> Heatmap (24)
Lini mana terbaik / terburik    -> Bar + target line (44)
Multi-panel kategori            -> Facet (53-55)
Rata ± variasi                  -> Errorbar / pointrange (18-21)
```

---

*CHEATSHEET Volume 1 — salin, tempel, urut: `ggplot(aes()) + geom + scale + coord + facet + theme + labs` menyelesaikan 90% kebutuhan visual.*