# Materi 09 — Visualisasi ggplot2 Dasar

> Pendamping Volume 0 · Waktu baca ±15 menit · Dataset `quality_inspection.csv`.
> Awali: `library(dplyr); library(ggplot2); library(scales)` + contoh persiapan di bawah.
> Semua kode di bawah lolos `ggplot_build()` (render OK).

---

## 1. Materi singkat

Template ggplot2 selalu tiga lapis:

```text
ggplot(data, aes(x = ..., y = ...)) + geom_xxx() + pelengkap (labs, scale, theme)
```

`aes()` = pemetaan data → visual (sumbu, warna). Di **dalam** `aes()` = dari kolom; di **luar** = tetap (mis. `fill = "steelblue"`).

| Geom | Kapan | Contoh |
| --- | --- | --- |
| `geom_bar()` | hitung jumlah baris per kategori (stat = count) | jumlah inspeksi per DefectType |
| `geom_col(aes(x, y))` | nilai y sudah dihitung (ringkasan dplyr) | defect rate per lini |
| `geom_line() + geom_point()` | tren waktu | defect rate harian |
| `geom_point() + geom_smooth(method = "lm")` | hubungan 2 angka | cycle time vs defect |
| `geom_boxplot()` | sebaran per grup | cycle time per lini |

Aturan: agregat dulu dengan dplyr (Materi 07), baru plot — kecuali `geom_bar()` yang menghitung sendiri.

---

## 2. Contoh 1 — Persiapan data

```r
library(dplyr)
library(ggplot2)
library(scales)

quality <- read.csv("quality_inspection.csv") |>
  mutate(DefectRate = round(Defect / Inspected, 4),
         InspectionDate = as.Date(InspectionDate))
```

## 3. Contoh 2 — Bar chart (dihitung ggplot) vs column chart (dihitung dplyr)

```r
# BAR: ggplot yang menghitung (5 jenis defect)
ggplot(quality, aes(DefectType)) +
  geom_bar(fill = "steelblue")

# COLUMN: kita ringkas dulu, ggplot tinggal gambar (3 lini)
ringkasan <- quality |>
  group_by(Line) |>
  summarise(DefectRate = sum(Defect) / sum(Inspected), .groups = "drop")

p_bar <- ggplot(ringkasan, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  scale_y_continuous(labels = percent)
p_bar
```

Output ringkasan:

```text
# A tibble: 3 × 2
  Line  DefectRate
  <chr>      <dbl>
1 A         0.0297
2 B         0.0732
3 C         0.0201
```

Penjelasan: `geom_bar()` tanpa `y` = hitung baris. `geom_col()` butuh `y` = nilai jadi.
`scale_y_continuous(labels = percent)` mengubah 0.0732 → "7.3%" di sumbu. Batang B ~2.5× A — sama dengan temuan Materi 07.

## 4. Contoh 3 — Line chart tren harian

```r
harian <- quality |>
  group_by(InspectionDate) |>
  summarise(DefectRate = sum(Defect) / sum(Inspected), .groups = "drop")

harian   # 8 tanggal inspeksi

ggplot(harian, aes(x = InspectionDate, y = DefectRate)) +
  geom_line() +
  geom_point() +
  scale_y_continuous(labels = percent)
```

Output `harian`:

```text
# A tibble: 8 × 2
  InspectionDate DefectRate
  <date>              <dbl>
1 2026-07-01         0.0353
2 2026-07-08         0.0336
3 2026-07-15         0.0428
4 2026-07-22         0.0416
5 2026-08-01         0.0436
6 2026-08-08         0.0399
7 2026-08-15         0.0469
8 2026-08-22         0.0402
```

Penjelasan: pola mirip `V1_tren_harian` Volume 4 — ringkas per tanggal dulu, lalu `geom_line()` + `geom_point()`.

## 5. Contoh 4 — Scatter + boxplot (baca hubungan & sebaran)

```r
# Scatter: makin lama cycle time, makin banyak defect? (korelasi +0.935 = kuat)
ggplot(quality, aes(x = CycleTimeSec, y = Defect)) +
  geom_point() +
  geom_smooth(method = "lm")

# Boxplot: sebaran cycle time per lini
ggplot(quality, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot(show.legend = FALSE)
```

Penjelasan: titik menanjak ke kanan + garis `lm` miring naik = hubungan positif kuat (korelasi cycle time–defect = 0.935).
Boxplot: kotak B jauh di atas A/C (median 50 vs 42/40) — visual dari angka Materi 07 contoh 4.

## 6. Contoh 5 — Finalisasi: judul, tema, facet, simpan

```r
p_final <- p_bar +
  labs(
    title    = "Defect Rate per Lini Produksi",
    subtitle = "Sumber: quality_inspection.csv (n = 48)",
    x = "Lini", y = "Defect rate"
  ) +
  theme_minimal()

p_final + facet_wrap(~ DefectType)   # butuh kolom DefectType di data plot!
```

Catatan facet: `p_bar` datanya `ringkasan` (tanpa `DefectType`) → facet contoh di atas **error**.
Versi benar — facet dari data mentah per lini × jenis:

```r
quality |>
  group_by(Line, DefectType) |>
  summarise(DefectRate = sum(Defect) / sum(Inspected), .groups = "drop") |>
  ggplot(aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  scale_y_continuous(labels = percent) +
  facet_wrap(~ DefectType) +
  theme_minimal()
```

Simpan grafik:

```r
ggsave("bar_defect_rate.png", p_final, width = 7, height = 4.5, dpi = 150)
```

Cek file muncul di working directory (`list.files(pattern = "bar_defect")`).

---

## 7. Coba sendiri (±5 menit)

1. Ubah `fill = "steelblue"` contoh 2 menjadi `"firebrick"`. Apa yang berubah? Lalu pindahkan ke dalam `aes(fill = Line)` — apa bedanya?
2. Line chart contoh 3 + `facet_wrap(~ Line)` — error atau jalan? Kenapa? (Petunjuk: kolom apa yang ada di `harian`?)
3. Scatter contoh 4 dengan `y = DefectRate` (bukan `Defect`). Apakah arah hubungannya sama?
4. Simpan boxplot contoh 4 sebagai `box_ct_line.png` (lebar 7, tinggi 4.5, dpi 150). Cek filenya.

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 10](latihan-10-mini-project.md)

