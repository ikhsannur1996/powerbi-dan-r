# Case 04 — OEE & Analisis Downtime

> **Pertanyaan bisnis:** "Seberapa efektif ketiga lini kita, dan di mana kehilangan performa terbesarnya?"
>
> **Alat IE:** Overall Equipment Effectiveness (OEE) = Availability × Performance × Quality. OEE menggabungkan tiga sumber kehilangan — waktu berhenti, kecepatan di bawah standar, dan produk cacat — menjadi satu angka yang bisa dibandingkan dengan benchmark.

## 1. Konsep & Asumsi

| Komponen | Rumus | Sumber kehilangan |
| --- | --- | --- |
| Availability | Running time / Planned time | Downtime (breakdown, setup) |
| Performance | Output aktual / Output ideal saat running | Kecepatan rendah, micro-stops |
| Quality | Unit baik / Total output | Defect & rework |
| **OEE** | ketiganya dikali | — |

Benchmark umum: OEE **85%** = world class (60% = typical, 40% = low).

Asumsi yang dideklarasikan (penting: OEE tanpa asumsi jelas = angka yang menyesatkan):

- Planned time: 76 hari kerja × 2 shift × 480 menit = **72.960 menit** per lini (Juli–Sep 2026, data `qc_hasil_produksi.csv`).
- Standard cycle time: **20 detik/unit** (SOP) → output ideal = 72.960 × 60 / 20 ≈ 218.880 unit per lini.

## 2. Analisis

```r
library(dplyr)
library(ggplot2)
library(scales)

hasil <- read.csv("qc_hasil_produksi.csv")

oee <- hasil |>
  group_by(Lini) |>
  summarise(
    Produksi = sum(UnitsProduced),
    Defect   = sum(UnitsDefect),
    Downtime = sum(DowntimeMin, na.rm = TRUE),
    .groups  = "drop"
  ) |>
  mutate(
    Scheduled    = 76 * 2 * 480,                 # menit
    IdealOutput  = Scheduled * 60 / 20,          # unit
    Availability = 1 - Downtime / Scheduled,
    Performance  = Produksi / IdealOutput,
    Quality      = 1 - Defect / Produksi,
    OEE          = Availability * Performance * Quality
  )

oee |>
  mutate(across(where(is.numeric), \(x) round(x, 3)))
```

## 3. Hasil & Interpretasi

| Lini | Produksi | Downtime (menit) | Availability | Performance | Quality | **OEE** |
| --- | --- | --- | --- | --- | --- | --- |
| A | 180.308 | 4.878 | 93,3% | 82,4% | 96,4% | **74,1%** |
| B | 173.115 | 5.271 | 92,8% | 79,1% | 94,7% | **69,5%** |
| C | 178.054 | 5.328 | 92,7% | 81,3% | 96,8% | **73,0%** |

- Semua lini di bawah benchmark 85%, dengan **Performance sebagai penyumbang loss terbesar** (~17–21%): lini berjalan lebih lambat dari standard cycle 20 detik/unit.
- **Lini B terburuk di semua komponen**: Performance 79,1% dan Quality 94,7% (defect rate 5,3% — konsisten dengan Case 05).
- Availability ~93% tampak sehat, tapi total downtime ±5.200 menit ≈ 87 jam ≈ 11 shift kerja penuh per lini selama 3 bulan — cukup besar untuk dicek penyebabnya.

## 4. Visualisasi: Loss Tree OEE

```r
loss <- oee |>
  select(Lini, Availability, Performance, Quality, OEE) |>
  tidyr::pivot_longer(-Lini, names_to = "Komponen", values_to = "Nilai")

ggplot(loss, aes(x = Lini, y = Nilai, fill = Komponen)) +
  geom_col(position = "dodge") +
  geom_hline(yintercept = 0.85, linetype = "dashed", color = "red") +
  annotate("text", x = 3.45, y = 0.86, label = "World class 85%",
           color = "red", size = 3, hjust = 1) +
  scale_y_continuous(labels = percent, limits = c(0, 1)) +
  labs(title = "Komponen OEE per Lini vs Benchmark 85%",
       x = "Lini", y = "Nilai") +
  theme_minimal()
```

## 5. Rekomendasi

1. **Prioritas 1 — Performance gap (±15–20%)**: time study untuk menemukan gap antara actual vs standard cycle; cek micro-stops, kecepatan operator per shift (data `Shift` tersedia), dan kalibrasi kecepatan mesin.
2. **Prioritas 2 — Lini B**: kombinasi performance & quality terburuk menjadikannya kandidat kaizen event pertama; defect rate-nya juga paling tinggi (Case 05).
3. **Downtime**: kategorikan penyebab (breakdown vs setup vs waiting) — saat ini data hanya total menit; tambahkan kolom penyebab di proses pencatatan agar Pareto downtime bisa dibuat.
4. Awas **data NA**: 12 baris downtime kosong dianggap 0 pada agregasi — deklarasikan asumsi ini di laporan.

## 6. Latihan Mandiri

1. Hitung OEE per **shift** (Pagi vs Sore) per lini — apakah ada shift yang konsisten lebih buruk?
2. Susun **Pareto downtime** per tanggal — tanggal-tanggal apa yang menyumbang 80% downtime?
3. Berapa peningkatan OEE lini B bila Performance dinaikkan ke 85% (komponen lain tetap)? Berapa tambahan unit yang dihasilkan?

## Jawaban ringkas latihan

```r
# 1 — OEE per lini & shift
hasil |>
  group_by(Lini, Shift) |>
  summarise(
    Produksi = sum(UnitsProduced),
    Defect   = sum(UnitsDefect),
    Downtime = sum(DowntimeMin, na.rm = TRUE),
    .groups  = "drop"
  ) |>
  mutate(
    Scheduled    = 38 * 2 * 480,        # setengah periode per shift-group
    Availability = 1 - Downtime / Scheduled,
    Performance  = Produksi / (Scheduled * 60 / 20),
    Quality      = 1 - Defect / Produksi,
    OEE          = Availability * Performance * Quality
  )
# Ekspektasi: shift Sore sedikit lebih rendah (defect rate sore lebih tinggi).

# 3 — dampak performance B ke 85%
b <- oee |> filter(Lini == "B")
oee_baru <- b$Availability * 0.85 * b$Quality     # ± 0,749
unit_tambahan <- (0.85 - b$Performance) * b$IdealOutput
# ≈ 12.900 unit tambahan tanpa menambah jam kerja.
```

---

[← Daftar case](README.md) | [Lanjut: Case 05 — Uji Hipotesis & Regresi](case-05-uji-hipotesis-regresi.md)
