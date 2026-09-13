# Case 01 — Analisis Pareto: Prioritas Penanganan Defect

> **Pertanyaan bisnis:** "Jenis defect mana yang harus ditangani lebih dulu agar dampaknya paling besar?"
>
> **Alat IE:** Analisis Pareto — prinsip 80/20. Umumnya sebagian kecil jenis defect menyumbang sebagian besar total kejadian. Menangani "the vital few" jauh lebih efektif daripada menangani semuanya sekaligus.

## 1. Persiapan Data

```r
library(dplyr)
library(ggplot2)
library(scales)

inspeksi <- read.csv("quality_inspection.csv")

pareto <- inspeksi |>
  group_by(DefectType) |>
  summarise(
    Jumlah     = sum(Defect),
    Frekuensi  = n(),
    .groups    = "drop"
  ) |>
  arrange(desc(Jumlah)) |>
  mutate(
    Persen    = Jumlah / sum(Jumlah),
    PersenKum = cumsum(Persen)
  )

pareto
```

## 2. Visualisasi Pareto (bar + garis kumulatif)

```r
p_pareto <- ggplot(pareto, aes(x = reorder(DefectType, -Jumlah))) +
  geom_col(aes(y = Jumlah), fill = "steelblue") +
  geom_text(aes(y = Jumlah, label = Jumlah), vjust = -0.5, size = 3.5) +
  geom_line(aes(y = PersenKum * max(pareto$Jumlah), group = 1),
            color = "tomato", linewidth = 1) +
  geom_point(aes(y = PersenKum * max(pareto$Jumlah)),
             color = "tomato", size = 3) +
  scale_y_continuous(
    name   = "Jumlah defect",
    sec.axis = sec_axis(~ . / max(pareto$Jumlah),
                        name = "Persen kumulatif", labels = percent)
  ) +
  labs(title    = "Pareto Chart Jenis Defect",
       subtitle = "Garis merah: kontribusi kumulatif",
       x = "Jenis defect") +
  theme_minimal()

p_pareto
```

## 3. Interpretasi

Berdasarkan data (dijalankan pada `quality_inspection.csv`, total 250 defect):

| DefectType | Jumlah | Persen | Kumulatif |
| --- | --- | --- | --- |
| Scratch | 97 | 38,8% | 38,8% |
| Crack | 64 | 25,6% | 64,4% |
| Dimension | 52 | 20,8% | 85,2% |
| NONE | 19 | 7,6% | 92,8% |
| Color | 18 | 7,2% | 100,0% |

- **Scratch + Crack + Dimension = 85,2%** dari seluruh defect → inilah *the vital few*.
- Menangani 3 jenis ini secara potensial mengurangi ±85% masalah dengan fokus pada 3 penyebab saja.

## 4. Rekomendasi Tindakan

1. **Scratch (38,8%)** — cek penanganan material & gesekan saat transfer antar proses; tambahkan pelindung permukaan.
2. **Crack (25,6%)** — periksa parameter proses (tekanan/suhu) dan kualitas bahan baku.
3. **Dimension (20,8%)** — audit kalibrasi jig/dies, terutama pada lini B (case 5 menunjukkan lini B paling bermasalah); jadwalkan preventive maintenance.

Catatan penting: baris `NONE` adalah inspeksi yang lolos — jumlah defect-nya kecil (19 dari 250), sehingga tidak masuk vital few walaupun banyak muncul di data.

## 5. Latihan Mandiri

1. Buat Pareto per **lini** (Line) — apakah vital few-nya juga 3 kategori?
2. Buat Pareto yang **berbobot nilai kerugian** (join dengan `qc_produk.csv`, `Kerugian = Defect × HargaSatuan`). Apakah urutan prioritas berubah? Mengapa berbobot uang lebih relevan untuk manajemen?
3. Tambahkan aturan visual: garis horizontal putus-putus pada 80% kumulatif.

## Jawaban ringkas latihan

```r
# 1 — Pareto per lini
inspeksi |>
  group_by(Line, DefectType) |>
  summarise(Jumlah = sum(Defect), .groups = "drop") |>
  group_by(Line) |>
  mutate(Persen = Jumlah / sum(Jumlah), PersenKum = cumsum(Persen))

# 2 — berbobot kerugian
produk <- read.csv("qc_produk.csv")

inspeksi |>
  left_join(produk, by = c("Product" = "Produk")) |>
  mutate(Kerugian = Defect * HargaSatuan) |>
  group_by(DefectType) |>
  summarise(Rugi = sum(Kerugian, na.rm = TRUE), .groups = "drop") |>
  arrange(desc(Rugi)) |>
  mutate(Persen = Rugi / sum(Rugi), PersenKum = cumsum(Persen))
# Jawaban yang diharapkan: ya, urutan berubah — produk berharga tinggi
# (mis. Sensor) mengangkat jenis defect pada produk tersebut ke urutan atas,
# walau frekuensinya lebih kecil.
```

---

[← Daftar case](README.md) | [Lanjut: Case 02 — SPC Control Chart](case-02-spc-control-chart.md)
