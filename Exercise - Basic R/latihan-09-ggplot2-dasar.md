# Latihan 09 — ggplot2 Dasar

> Level: ⭐⭐⭐ | Materi: README_Basic_R.md Bab 8

## Tujuan

- Memahami template `ggplot(data, aes(...)) + geom_xxx()`.
- Membuat 4 grafik inti: bar, line, scatter, boxplot.
- Menambah judul/label dan menyimpan grafik dengan `ggsave()`.

## Persiapan

```r
library(dplyr)
library(ggplot2)
library(scales)

quality <- read.csv("quality_inspection.csv") |>
  mutate(DefectRate = round(Defect / Inspected, 4),
         InspectionDate = as.Date(InspectionDate))
```

## Soal

1. **Bar chart**: jumlah observasi per `DefectType` dengan `geom_bar()`. Beri `fill = "steelblue"`.
2. **Column chart**: defect rate per lini. Petunjuk: ringkasan dulu dengan dplyr (`group_by + summarise`), lalu `geom_col(aes(x = Line, y = DefectRate))` + `scale_y_continuous(labels = percent)`.
3. **Line chart**: tren defect rate harian per tanggal (ringkas per `InspectionDate` dulu), dengan `geom_line()` + `geom_point()`.
4. **Scatter plot**: `CycleTimeSec` (x) vs `Defect` (y) dengan `geom_point()` + `geom_smooth(method = "lm")`. Apa arah hubungannya?
5. **Boxplot**: `CycleTimeSec` per `Line`, `fill = Line` dan `show.legend = FALSE`.
6. Pada grafik soal 2, tambahkan `labs(title = ..., subtitle = ..., x = "Lini", y = "Defect rate")` dan `theme_minimal()`.
7. (Bonus) Salin grafik soal 2, tambahkan `facet_wrap(~ DefectType)` — apa yang terlihat?
8. Simpan grafik soal 6 sebagai PNG: `ggsave("bar_defect_rate.png", width = 7, height = 4.5, dpi = 150)`. Cek file muncul di folder.

## Cek pemahaman

- Kenapa grafik soal 2 pakai `geom_col()` sedangkan soal 1 pakai `geom_bar()`?
- Apa fungsi `aes()` dan kapan argumen diletakkan di luar `aes()` (mis. `fill = "steelblue"`)?

## Kunci jawaban

```r
# 1
ggplot(quality, aes(DefectType)) +
  geom_bar(fill = "steelblue")

# 2
ringkasan <- quality |>
  group_by(Line) |>
  summarise(DefectRate = sum(Defect) / sum(Inspected), .groups = "drop")

p_bar <- ggplot(ringkasan, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  scale_y_continuous(labels = percent)

# 3
harian <- quality |>
  group_by(InspectionDate) |>
  summarise(DefectRate = sum(Defect) / sum(Inspected), .groups = "drop")

ggplot(harian, aes(x = InspectionDate, y = DefectRate)) +
  geom_line() +
  geom_point() +
  scale_y_continuous(labels = percent)

# 4
ggplot(quality, aes(x = CycleTimeSec, y = Defect)) +
  geom_point() +
  geom_smooth(method = "lm")

# 5
ggplot(quality, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot(show.legend = FALSE)

# 6
p_final <- p_bar +
  labs(
    title    = "Defect Rate per Lini Produksi",
    subtitle = "Sumber: quality_inspection.csv",
    x = "Lini", y = "Defect rate"
  ) +
  theme_minimal()

# 7
p_final + facet_wrap(~ DefectType)

# 8
ggsave("bar_defect_rate.png", p_final, width = 7, height = 4.5, dpi = 150)
```

---

[Kembali ke daftar](README.md) | [Lanjut: Latihan 10](latihan-10-mini-project.md)
