# 02 — ggplot2: Grammar of Graphics

> Cheatsheet lengkap pemakaian ggplot2 ada di folder `Data Visualization - ggplot2` (termasuk 73 contoh runnable). File ini fokus pada **fondasi konsep** agar mahir membaca dan merancang grafik apa pun.

## Konsep Inti: Grammar of Graphics

Setiap grafik = gabungan komponen:

1. **Data** — data frame yang berisi variabel
2. **Aesthetics (`aes()`)** — pemetaan variabel → properti visual (x, y, color, fill, size, shape, alpha, linetype)
3. **Geoms** — mark visual: `geom_point()`, `geom_col()`, `geom_line()`, ...
4. **Stats** — transformasi statistik di belakang geom (`count`, `bin`, `smooth`, `density`)
5. **Scales** — cara nilai data dipetakan ke skala visual (`scale_fill_brewer()`, `scale_y_continuous()`)
6. **Facets** — pecah panel per kategori
7. **Coordinates** — sistem koordinat (`coord_cartesian`, `coord_polar`, `coord_flip`)
8. **Theme** — gaya non-data (font, grid, latar)

```r
library(tidyverse)

inspeksi <- read_csv("quality_inspection.csv")

ggplot(data = inspeksi,                       # 1. data
       mapping = aes(x = Line, y = Defect,    # 2. aesthetics
                     fill = DefectType)) +
  geom_col() +                                # 3. geom
  scale_fill_brewer(palette = "Set2") +       # 5. scale
  facet_wrap(~ Product) +                     # 6. facet
  coord_flip() +                              # 7. coordinate
  theme_minimal() +                           # 8. theme
  labs(title = "Defect per Lini", x = "Lini", y = "Total")
```

## Fungsi-Fungsi Paling Penting

| Kategori | Fungsi | Keterangan |
|---|---|---|
| Data→visual | `ggplot()`, `aes()` | fondasi semua plot |
| Geom distribusi | `geom_histogram`, `geom_density`, `geom_boxplot`, `geom_violin` | bentuk sebaran |
| Geom hubungan | `geom_point`, `geom_smooth`, `geom_line`, `geom_col` | korelasi, tren, bar |
| Geom label | `geom_text`, `geom_label`, `annotate` | anotasi langsung |
| Posisi | `position = "dodge"/"stack"/"fill"/"jitter"` | susunan bar/titik |
| Scales | `scale_*_manual`, `scale_*_brewer`, `scale_*_viridis_*` | warna colorblind-safe |
| Facet | `facet_wrap(~var)`, `facet_grid(row~col)` | panel per kategori |
| Coordinate | `coord_cartesian`, `coord_flip`, `coord_polar`, `coord_fixed` | ruang plot |
| Theme | `theme_minimal`, `theme_bw`, `theme()` | tampilan |

## Case Study Mini

```r
library(tidyverse)
inspeksi <- read_csv("quality_inspection.csv")

# Tren bulanan defect rate per lini + target 4%
inspeksi |>
  mutate(Bulan = floor_date(InspectionDate, "month")) |>
  group_by(Bulan, Line) |>
  summarize(Rate = sum(Defect) / sum(Inspected), .groups = "drop") |>
  ggplot(aes(Bulan, Rate, color = Line)) +
  geom_hline(yintercept = 0.04, linetype = "dashed", color = "red") +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  scale_y_continuous(labels = percent) +
  labs(title = "Defect Rate Bulanan vs Target 4%",
       x = NULL, y = "Defect rate") +
  theme_minimal()
```

## Tips

- **Layer bertumpuk dari bawah ke atas** — geom yang ditulis belakangan digambar di atas.
- `aes()` di `ggplot()` berlaku global; pindah ke `geom_()` bila hanya untuk satu layer.
- **Zoom aman**: `coord_cartesian(ylim = ...)` — bukan `ylim()` yang membuang data & mengubah `geom_smooth`.
- **Sorting bar**: `aes(x = reorder(DefectType, -Defect))`.
- `geom_col()` untuk nilai yang sudah dihitung; `geom_bar()` untuk menghitung frekuensi otomatis.
- `after_stat()` untuk memakai hasil statistik: `aes(fill = after_stat(count))`.
- Simpan plot ke objek untuk dipakai ulang: `p <- ggplot(...)`.
- `ggsave("plot.png", width = 7, height = 4.5, dpi = 150)` untuk ekspor.

## Referensi

- Cheatsheet: `data-visualization.pdf` (Posit)
- Folder `Data Visualization - ggplot2` — 73 contoh runnable
- <https://ggplot2.tidyverse.org>
