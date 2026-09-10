# Latihan 07 — dplyr: group_by & summarise

> Level: ⭐⭐ | Materi: README_Basic_R.md Bab 9.5

## Tujuan

- Merangkum data per kelompok dengan `group_by()` + `summarise()`.
- Memakai fungsi agregasi: `n()`, `sum()`, `mean()`, `median()`, `n_distinct()`.
- Memahami weighted rate: `sum(Defect)/sum(Inspected)` vs `mean(DefectRate)`.

## Persiapan

```r
library(dplyr)
quality <- read.csv("quality_inspection.csv")
```

## Soal

1. Hitung jumlah baris data per `Line` (dua cara: `group_by()+summarise(n())` dan `count()`).
2. Ringkas per `Line`: total `Inspected`, total `Defect`, dan **weighted** defect rate `sum(Defect)/sum(Inspected)`. Simpan sebagai `ringkasan_line`.
3. Ulangi soal 2 per kombinasi `Line` dan `DefectType`.
4. Dari `ringkasan_line`, urutkan dari defect rate terbesar. Lini mana yang terburuk?
5. Ringkas per `Line` statistik cycle time: `mean()`, `median()`, `min()`, `max()`. (Gunakan `na.rm = TRUE` agar terbiasa aman.)
6. Ringkas per `Product`: jumlah lini unik (`n_distinct(Line)`), total inspected, dan jumlah jenis defect unik (`n_distinct(DefectType)`).
7. Tantangan: hanya tampilkan kombinasi `Line`–`DefectType` yang total defect-nya di atas 8. (Petunjuk: `filter()` **setelah** summarise.)

## Cek pemahaman

- Kenapa weighted rate (`sum/sum`) lebih adil daripada `mean(DefectRate)`? (Petunjuk: anggap satu baris punya Inspected = 100, lainnya = 1000.)
- Apa fungsi `.groups = "drop"`?

## Kunci jawaban

```r
quality |>
  group_by(Line) |>
  summarise(N = n(), .groups = "drop")

quality |> count(Line)

ringkasan_line <- quality |>
  group_by(Line) |>
  summarise(
    TotalInspected = sum(Inspected),
    TotalDefect    = sum(Defect),
    DefectRate     = sum(Defect) / sum(Inspected),
    .groups        = "drop"
  )

quality |>
  group_by(Line, DefectType) |>
  summarise(TotalDefect = sum(Defect), .groups = "drop")

ringkasan_line |> arrange(desc(DefectRate))

quality |>
  group_by(Line) |>
  summarise(
    MeanCT   = mean(CycleTimeSec, na.rm = TRUE),
    MedianCT = median(CycleTimeSec, na.rm = TRUE),
    MinCT    = min(CycleTimeSec, na.rm = TRUE),
    MaxCT    = max(CycleTimeSec, na.rm = TRUE),
    .groups  = "drop"
  )

quality |>
  group_by(Product) |>
  summarise(
    NLine      = n_distinct(Line),
    Inspected  = sum(Inspected),
    JenisDefect = n_distinct(DefectType),
    .groups    = "drop"
  )

quality |>
  group_by(Line, DefectType) |>
  summarise(TotalDefect = sum(Defect), .groups = "drop") |>
  filter(TotalDefect > 8)
```

---

[Kembali ke daftar](README.md) | [Lanjut: Latihan 08](latihan-08-cleaning-pipeline.md)
