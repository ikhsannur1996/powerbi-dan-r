# Latihan 08 — Cleaning & Pipeline Lengkap

> Level: ⭐⭐⭐ | Materi: README_Basic_R.md Bab 7, 9.6 & `../quality_inspection_cleaning.R`

## Tujuan

- Menangani missing value dan data invalid.
- Menulis pipeline cleaning end-to-end dengan pipe `|>`.
- Memvalidasi hasil sebelum dan sesudah cleaning.

## Persiapan

Untuk latihan ini, kita buat dulu salinan data yang **sengaja dirusak**:

```r
library(dplyr)
quality <- read.csv("quality_inspection.csv")

set.seed(123)
quality_dirty <- quality
quality_dirty$CycleTimeSec[sample(1:nrow(quality), 3)] <- NA       # 3 NA
quality_dirty$Defect[sample(1:nrow(quality), 2)] <- -1            # defect negatif (salah input)
quality_dirty$Line[sample(1:nrow(quality), 2)] <- " b "           # spasi + huruf kecil
```

## Soal

1. Diagnosis: hitung `sum(is.na(quality_dirty$CycleTimeSec))`, dan tampilkan baris dengan `Defect < 0` atau `Defect > Inspected`.
2. Perbaiki `Line`: terapkan `trimws()` + `toupper()` di dalam `mutate()`, lalu cek `table(quality_dirty$Line)`.
3. Perbaiki `Defect` negatif: ganti menjadi `NA` dengan `ifelse()` (jangan langsung dihapus).
4. Buang baris yang `CycleTimeSec`-nya `NA` dengan `filter(!is.na(...))`. Berapa baris yang tersisa?
5. Tambahkan filter validitas: `Inspected > 0` dan `Defect <= Inspected`.
6. Susun pipeline cleaning lengkap dalam **satu pipe** (langkah 2–5) dan tambahkan kolom `DefectRate` + `QualityFlag` (ambang 5%). Simpan sebagai `quality_clean`.
7. Validasi: bandingkan `nrow()` sebelum vs sesudah, dan pastikan `sum(is.na(quality_clean$CycleTimeSec)) == 0`.
8. Simpan hasil bersih ke CSV: `write.csv(quality_clean, "quality_clean.csv", row.names = FALSE)`.

## Cek pemahaman

- Kenapa nilai negatif dijadikan `NA` dulu, bukan langsung dibuang barisnya?
- Apa risiko kalau pipeline cleaning tidak divalidasi?

## Kunci jawaban

```r
sum(is.na(quality_dirty$CycleTimeSec))   # 3
quality_dirty |> filter(Defect < 0 | Defect > Inspected)

quality_clean <- quality_dirty |>
  mutate(
    Line         = trimws(toupper(Line)),
    Defect       = ifelse(Defect < 0, NA, Defect)
  ) |>
  filter(
    !is.na(CycleTimeSec),
    Inspected > 0,
    Defect <= Inspected
  ) |>
  mutate(
    DefectRate  = round(Defect / Inspected, 4),
    QualityFlag = ifelse(DefectRate > 0.05, "Above", "On target")
  )

nrow(quality_dirty)                    # 48
nrow(quality_clean)                    # 43 — 3 baris NA dihapus filter pertama,
                                       # 2 baris defect negatif (jadi NA) tereliminasi
                                       # oleh filter Defect <= Inspected
sum(is.na(quality_clean$CycleTimeSec)) # 0
table(quality_clean$Line)              # hanya A, B, C

write.csv(quality_clean, "quality_clean.csv", row.names = FALSE)
```

---

[Kembali ke daftar](README.md) | [Lanjut: Latihan 09](latihan-09-ggplot2-dasar.md)
