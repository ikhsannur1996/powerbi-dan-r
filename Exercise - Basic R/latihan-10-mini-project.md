# Latihan 10 — Mini Project End-to-End

> Level: ⭐⭐⭐ | Materi: gabungan semua latihan sebelumnya

## Tujuan

Mengerjakan siklus analisis lengkap dalam satu script: **import → cleaning → transform → visualisasi → ekspor**. Ini adalah simulasi tugas analisis nyata.

## Brief

Manajer quality menanyakan: *"Lini dan jenis defect mana yang paling bermasalah bulan Juli–Agustus 2026, dan apakah cycle time berhubungan dengan jumlah defect?"*

Anda menjawab dengan satu script R yang menghasilkan: data bersih, 1 tabel ringkasan, dan 2 grafik PNG.

## Persiapan

```r
rm(list = ls())
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)
```

## Soal

**Bagian A — Import & Cleaning**

1. Baca `quality_inspection.csv`, konversi `InspectionDate` ke Date, lini ke huruf besar (`toupper(trimws())`).
2. Filter validitas: `Inspected > 0`, `Defect` tidak `NA`, dan `Defect <= Inspected`.

**Bagian B — Transform**

3. Buat kolom `DefectRate` (4 desimal), `Bulan = floor_date(InspectionDate, "month")`, dan `QualityFlag` (ambang 5%).
4. Buat tabel `ringkasan` per `Line` × `DefectType`: total inspected, total defect, defect rate, rata-rata cycle time — diurutkan dari total defect terbesar.
5. Dari tabel itu, jawab pertanyaan brief: 3 kombinasi terburuk (petunjuk `slice_head(n = 3)` setelah `arrange`).

**Bagian C — Visualisasi & Ekspor**

6. Grafik 1 — stacked bar: total defect per lini, ditumpuk per `DefectType`, beri judul + label sumbu.
7. Grafik 2 — scatter: `CycleTimeSec` vs `DefectRate` + garis tren (`geom_smooth(method = "lm")`). Tulis 1 kalimat kesimpulan hubungannya sebagai `subtitle` atau komentar.
8. Simpan kedua grafik sebagai PNG (dpi 150). Simpan juga `ringkasan` sebagai `ringkasan_line_defect.csv`.

## Rubrik penilaian mandiri

| Kriteria | Selesai? |
| --- | --- |
| Script berjalan top-to-bottom tanpa error setelah `rm(list = ls())` | [ ] |
| Ada tahap cleaning + validasi (bukan langsung visualisasi) | [ ] |
| Ringkasan memakai weighted rate `sum/sum` | [ ] |
| 3 kombinasi terburuk tercantum sebagai jawaban brief | [ ] |
| 2 PNG + 1 CSV berhasil diekspor | [ ] |

## Kunci jawaban (kerangka)

```r
# A
quality <- read.csv("quality_inspection.csv") |>
  mutate(
    InspectionDate = as.Date(InspectionDate),
    Line = toupper(trimws(Line))
  ) |>
  filter(Inspected > 0, !is.na(Defect), Defect <= Inspected)

# B
quality <- quality |>
  mutate(
    DefectRate  = round(Defect / Inspected, 4),
    Bulan       = floor_date(InspectionDate, "month"),
    QualityFlag = ifelse(DefectRate > 0.05, "Above", "On target")
  )

ringkasan <- quality |>
  group_by(Line, DefectType) |>
  summarise(
    TotalInspected = sum(Inspected),
    TotalDefect    = sum(Defect),
    DefectRate     = TotalDefect / TotalInspected,
    MeanCT         = mean(CycleTimeSec, na.rm = TRUE),
    .groups        = "drop"
  ) |>
  arrange(desc(TotalDefect))

top3 <- ringkasan |> slice_head(n = 3)
top3   # B-Scratch (76), B-Crack (56), A-Scratch (21)

# C
p1 <- quality |>
  group_by(Line, DefectType) |>
  summarise(TotalDefect = sum(Defect), .groups = "drop") |>
  ggplot(aes(x = Line, y = TotalDefect, fill = DefectType)) +
  geom_col() +
  labs(title = "Total Defect per Lini & Jenis Defect",
       x = "Lini", y = "Total defect", fill = "Jenis")

p2 <- ggplot(quality, aes(x = CycleTimeSec, y = DefectRate)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm") +
  scale_y_continuous(labels = percent) +
  labs(title = "Cycle Time vs Defect Rate",
       x = "Cycle time (detik)", y = "Defect rate")

ggsave("mini_defect_stack.png", p1, width = 7, height = 4.5, dpi = 150)
ggsave("mini_ct_vs_rate.png",   p2, width = 7, height = 4.5, dpi = 150)
write.csv(ringkasan, "ringkasan_line_defect.csv", row.names = FALSE)

# Kesimpulan contoh: garis tren miring positif tipis — indikasi lemah
# bahwa cycle time lebih tinggi cenderung disertai defect rate lebih tinggi.
```

---

[Kembali ke daftar](README.md) | 🎉 Selesai! Lanjutkan ke Volume 1 atau modul `Data Transformation - dplyr` (100 kasus).
