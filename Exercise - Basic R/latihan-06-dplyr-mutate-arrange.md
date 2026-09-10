# Latihan 06 — dplyr: mutate & arrange

> Level: ⭐⭐ | Materi: README_Basic_R.md Bab 9.3–9.4

## Tujuan

- Membuat kolom baru dengan `mutate()`, termasuk kolom hasil logika (`ifelse`, `case_when`).
- Mengubah tipe kolom di dalam pipeline.
- Mengurutkan hasil dengan `arrange()` dan `desc()`.

## Persiapan

```r
library(dplyr)
library(lubridate)
quality <- read.csv("quality_inspection.csv") |>
  mutate(InspectionDate = as.Date(InspectionDate))
```

## Soal

1. Buat kolom `DefectRate = Defect / Inspected`, dibulatkan 4 desimal (`round()`).
2. Buat kolom `FirstPassYield = 1 - DefectRate`.
3. Buat kolom `QualityFlag`: `"Above"` jika `DefectRate > 0.05`, selain itu `"On target"` (pakai `ifelse()`).
4. Buat kolom `Bulan` dengan `floor_date(InspectionDate, "month")` dari lubridate. Periksa hasilnya dengan `table()`.
5. Buat kolom `Severity` dengan `case_when()`:
   - `"Tinggi"` jika `Defect >= 8`,
   - `"Sedang"` jika `Defect >= 4`,
   - `"Rendah"` untuk sisanya.
6. Buat kolom `EfisiensiCT`: `"Lambat"` jika `CycleTimeSec > 45`, `"Normal"` jika tidak. Lalu hitung distribusinya dengan `table()`.
7. Urutkan data dari `DefectRate` tertinggi ke terendah, tampilkan 5 baris teratas (gabung `arrange()` + `head()`).
8. Rangkai semua di satu pipeline: `select(Line, Defect, Inspected)` → `mutate` `DefectRate` → `arrange` menurun → simpan sebagai objek `ranking`.

## Cek pemahaman

- Kenapa `mutate()` bisa memakai kolom yang baru dibuat di langkah yang sama?
- Apa beda `arrange(desc(x))` dengan `arrange(-x)`? Kapan `-x` tidak bisa dipakai?

## Kunci jawaban

```r
quality <- quality |>
  mutate(
    DefectRate      = round(Defect / Inspected, 4),
    FirstPassYield  = 1 - DefectRate,
    QualityFlag     = ifelse(DefectRate > 0.05, "Above", "On target"),
    Bulan           = floor_date(InspectionDate, "month"),
    Severity        = case_when(
      Defect >= 8 ~ "Tinggi",
      Defect >= 4 ~ "Sedang",
      TRUE        ~ "Rendah"
    ),
    EfisiensiCT     = ifelse(CycleTimeSec > 45, "Lambat", "Normal")
  )

table(quality$Bulan)
table(quality$EfisiensiCT)

quality |> arrange(desc(DefectRate)) |> head(5)

ranking <- quality |>
  select(Line, Defect, Inspected) |>
  mutate(DefectRate = Defect / Inspected) |>
  arrange(desc(DefectRate))
```

---

[Kembali ke daftar](README.md) | [Lanjut: Latihan 07](latihan-07-dplyr-group-summarise.md)
