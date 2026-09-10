# Latihan 05 — dplyr: select & filter

> Level: ⭐⭐ | Materi: README_Basic_R.md Bab 9.1–9.2

## Tujuan

- Memilih kolom dengan `select()` + helper (`starts_with`, `ends_with`, dll.).
- Menyaring baris dengan `filter()` + logika multi-kondisi.
- Menggunakan pipe `|>`.

## Persiapan

```r
library(dplyr)
quality <- read.csv("quality_inspection.csv")
```

## Soal

1. Pilih kolom `Line`, `Product`, `DefectType`, `Defect` saja.
2. Pilih semua kolom **kecuali** `CycleTimeSec` (pakai tanda minus).
3. Pilih kolom yang namanya berawalan `"Ins"` (helper `starts_with()`), lalu yang berakhiran `"Sec"` (helper `ends_with()`).
4. Filter: semua baris dengan `Line == "B"`.
5. Filter: `Line == "A"` **dan** `Defect > 5`.
6. Filter: `DefectType` bernilai `"Scratch"` atau `"Crack"` (pakai `%in%`).
7. Filter: `CycleTimeSec` antara 42 dan 48 (pakai `between()`).
8. Gabungkan: dari lini A, ambil kolom `InspectionDate`, `DefectType`, `Defect`, untuk baris dengan `Defect >= 4`, urutkan dari defect terbesar (boleh gabung dengan `arrange()`).

## Cek pemahaman

- Dalam `filter(Condition1, Condition2)`, kondisi digabung dengan operator apa?
- Kenapa `%in%` lebih praktis daripada `==` untuk banyak nilai?

## Kunci jawaban

```r
quality |>
  select(Line, Product, DefectType, Defect)

quality |> select(-CycleTimeSec)

quality |> select(starts_with("Ins"))
quality |> select(ends_with("Sec"))

quality |> filter(Line == "B")

quality |> filter(Line == "A", Defect > 5)

quality |> filter(DefectType %in% c("Scratch", "Crack"))

quality |> filter(between(CycleTimeSec, 42, 48))

quality |>
  filter(Line == "A", Defect >= 4) |>
  select(InspectionDate, DefectType, Defect) |>
  arrange(desc(Defect))
```

---

[Kembali ke daftar](README.md) | [Lanjut: Latihan 06](latihan-06-dplyr-mutate-arrange.md)
