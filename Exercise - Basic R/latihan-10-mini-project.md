# Materi 10 — Studi Kasus End-to-End (Mini Project)

> Pendamping Volume 0 · Waktu ±30 menit · Gabungan Materi 04–09 dalam satu alur.
> Brief manajer quality: *"Lini dan jenis defect mana yang paling bermasalah Juli–Agustus 2026, dan apakah cycle time berhubungan dengan defect?"*
> Jawaban berupa: 1 tabel ringkasan (CSV) + 2 grafik (PNG) + 2 kalimat kesimpulan.

---

## 1. Materi singkat — alur analisis baku

```text
import (Materi 04) -> cleaning + validasi (Materi 08) -> transform (Materi 06)
  -> ringkas (Materi 07) -> visualisasi (Materi 09) -> ekspor (CSV + PNG)
```

Syarat script bagus: jalan **top-to-bottom tanpa error** setelah `rm(list = ls())`,
ada tahap cleaning + validasi (bukan langsung plot), dan defect rate memakai `sum/sum`.

---

## 2. Contoh 1 — Import + cleaning + validasi

```r
rm(list = ls())
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)

quality <- read.csv("quality_inspection.csv") |>
  mutate(
    InspectionDate = as.Date(InspectionDate),
    Line = toupper(trimws(Line))
  ) |>
  filter(Inspected > 0, !is.na(Defect), Defect <= Inspected)

nrow(quality)   # 48 (dataset ini bersih — validasi: tetap 48)
```

Output:

```text
[1] 48
```

## 3. Contoh 2 — Transform + tabel ringkasan (jawab brief bagian 1)

```r
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
    MeanCT         = round(mean(CycleTimeSec), 1),
    .groups        = "drop"
  ) |>
  arrange(desc(TotalDefect))

ringkasan |> head(3)   # 3 kombinasi terburuk
```

Output:

```text
# A tibble: 3 × 6
  Line  DefectType TotalInspected TotalDefect DefectRate MeanCT
  <chr> <chr>               <int>       <int>      <dbl>  <dbl>
1 B     Scratch              1027          76    0.0740   49.5
2 B     Crack                 741          56    0.0756   50.3
3 A     Scratch               485          21    0.0433   42.2
```

Jawaban brief (bagian 1): **B-Scratch (76), B-Crack (56), A-Scratch (21)** — dua teratas = 132 dari 250 defect (52.8%).

## 4. Contoh 3 — Dua grafik (jawab brief bagian 2)

```r
# Grafik 1 — stacked bar: total defect per lini, tumpuk per jenis
p1 <- quality |>
  group_by(Line, DefectType) |>
  summarise(TotalDefect = sum(Defect), .groups = "drop") |>
  ggplot(aes(x = Line, y = TotalDefect, fill = DefectType)) +
  geom_col() +
  labs(title = "Total Defect per Lini & Jenis Defect",
       x = "Lini", y = "Total defect", fill = "Jenis")

# Grafik 2 — scatter: cycle time vs defect rate + garis tren
p2 <- ggplot(quality, aes(x = CycleTimeSec, y = DefectRate)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm") +
  scale_y_continuous(labels = percent) +
  labs(title = "Cycle Time vs Defect Rate",
       subtitle = "Tren naik: cycle time lebih tinggi cenderung defect rate lebih tinggi",
       x = "Cycle time (detik)", y = "Defect rate")
```

Jawaban brief (bagian 2): garis tren **menanjak** — cycle time lebih tinggi cenderung defect rate lebih tinggi (korelasi cycle time–defect = 0.935, kuat; korelasi ≠ bukti sebab-akibat — lihat Volume 5 untuk kausalitas).

## 5. Contoh 4 — Ekspor + kesimpulan manajer

```r
ggsave("mini_defect_stack.png", p1, width = 7, height = 4.5, dpi = 150)
ggsave("mini_ct_vs_rate.png",   p2, width = 7, height = 4.5, dpi = 150)
write.csv(ringkasan, "ringkasan_line_defect.csv", row.names = FALSE)
list.files(pattern = "mini_|ringkasan_")   # pastikan 3 file ada
```

Kesimpulan 2 kalimat (contoh): *"Lini B menyumbang 148 dari 250 defect (59%), didominasi Scratch (76) dan Crack (56) — prioritas perbaikan di sana. Cycle time lini B juga tertinggi (median 50 vs 40–42 detik) dan berkorelasi kuat dengan defect, jadi audit proses + preventive maintenance mesin lini B direkomendasikan."*

Checklist mandiri: script jalan top-to-bottom setelah `rm(list = ls())` · ada cleaning + validasi · ringkasan pakai `sum/sum` · 3 kombinasi terburuk tercantum · 2 PNG + 1 CSV terekspor.

---

## 6. Coba sendiri (±10 menit)

1. Ulangi contoh 2 per `Line` saja (bukan `Line × DefectType`). Lini apa teratas total defect-nya? (Acuan: B = `148`.)
2. Grafik 1 versi `position = "fill"` (proporsi, bukan total): `geom_col(position = "fill")`. Lini apa porsi Scratch-nya terbesar?
3. Grafik 2 dengan `y = Defect` (bukan `DefectRate`). Apakah kesimpulan arahnya sama?
4. Tulis kesimpulan versimu sendiri (2 kalimat) memakai 3 angka: total defect lini B, defect B-Scratch, median cycle time lini B.

---

[Kembali ke daftar](README.md) | 🎉 Selesai! Lanjut ke Volume 1 atau folder `Data Transformation - dplyr`.

