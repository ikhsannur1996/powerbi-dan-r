# 📗 README Volume 3 — Case Study Industrial Engineering

> **Volume 3** dari rangkaian pelatihan *"Insight to Impact"*. Berbeda dengan Volume 0–2 yang mengajarkan **alat** (sintaks R, dplyr, ggplot2, statistik, Power BI), Volume ini berisi **penerapan** — case study analisis data kualitas produksi dengan cara kerja seorang Industrial Engineer: dari pertanyaan bisnis → metode IE yang tepat → analisis R → interpretasi → rekomendasi tindakan.

---

## 1. Gambaran Umum

| Komponen | Keterangan |
| --- | --- |
| **Nama proyek** | Volume 3 — Case Study Industrial Engineering |
| **Topik** | Penerapan alat IE (SPC, Pareto, capability, OEE, uji hipotesis, regresi) pada data nyata |
| **Bahasa** | R (dplyr, ggplot2, lubridate, scales) |
| **Dataset** | `quality_inspection.csv`, `qc_hasil_produksi.csv`, `qc_operator.csv`, `qc_produk.csv` |
| **Luaran** | Skrip analisis lengkap + grafik + rekomendasi tindakan (actionable insight) |
| **Prasyarat** | Volume 0 (Basic R) dan Volume 1 (Statistik & Visualisasi), atau folder `Core Tidyverse` |

## 2. Alur Case Study

Setiap case mengikuti struktur yang sama — pola berpikir IE:

```text
Pertanyaan bisnis
  -> Metode/alat IE yang tepat
  -> Persiapan & pembersihan data
  -> Analisis dengan R
  -> Interpretasi hasil (angka -> makna)
  -> Rekomendasi tindakan (actionable)
```

## 3. Daftar Case Study

| No | File | Alat IE | Pertanyaan Bisnis |
| --- | --- | --- | --- |
| 1 | [case-01-pareto.md](case-01-pareto.md) | **Analisis Pareto (80/20)** | Jenis defect mana yang harus ditangani lebih dulu? |
| 2 | [case-02-spc-control-chart.md](case-02-spc-control-chart.md) | **SPC — P-Chart & Xbar-Chart** | Apakah proses stabil secara statistik? Kapan proses "out of control"? |
| 3 | [case-03-process-capability.md](case-03-process-capability.md) | **Process Capability (Cp/Cpk)** | Apakah proses mampu memenuhi spesifikasi (target defect rate ≤ 4%)? |
| 4 | [case-04-oee-downtime.md](case-04-oee-downtime.md) | **OEE & Analisis Downtime** | Seberapa efektif tiap lini, dan apa penyebab utama kehilangan waktu? |
| 5 | [case-05-uji-hipotesis-regresi.md](case-05-uji-hipotesis-regresi.md) | **Uji t, ANOVA, Regresi** | Apakah perbedaan antar lini nyata (bukan kebetulan)? Apa faktor yang mendorong defect? |

## 4. Dataset

| File | Isi |
| --- | --- |
| `../../quality_inspection.csv` | 48 baris inspeksi kualitas (Juli–Agustus 2026): tanggal, lini, produk, jenis defect, jumlah inspeksi, defect, cycle time |
| `../../qc_hasil_produksi.csv` | 458 baris transaksi produksi harian: 3 lini × 2 shift, dengan downtime, suhu, kelembaban, energi (ada NA & data invalid untuk latihan cleaning) |
| `../../qc_operator.csv` | Master 8 operator |
| `../../qc_produk.csv` | Master produk + harga satuan + target defect rate |

Jika file `qc_*.csv` belum ada, buat dengan:

```r
source("Data Transformation - dplyr/buat_data_latihan.R")   # dari root project
```

## 5. Package

```r
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)

# Opsional (untuk control chart otomatis — case 2 punya versi manual tanpa package ini)
# install.packages("qcc")   # Quality Control Charts
```

Semua analisis dirancang berjalan dengan tidyverse murni; fungsi statistik (`t.test`, `aov`, `lm`) bawaan R via package `stats`.

## 6. Cara Belajar

1. Baca **README Volume 1** dulu bila belum familier dengan uji t/ANOVA/regresi dan pembacaan p-value.
2. Buka file case, kerjakan **sendiri** bagian "Latihan mandiri" di akhir tiap case sebelum membaca jawabannya.
3. Perhatikan bagian **Interpretasi** — di situlah nilai seorang IE: mengubah angka menjadi keputusan.
4. Lanjutkan hasil analisis ke dashboard Power BI (Volume 2) sebagai portofolio akhir.

## 7. Referensi

- Montgomery, D.C. — *Introduction to Statistical Quality Control* (SPC, capability, control chart)
- Heizer & Render — *Operations Management* (OEE, productivity)
- Cheatsheet: `../../data-transformation.pdf`, `../../data-visualization.pdf`
- Materi pendukung: `../../Volume 2 - Statistics and Inferential Statistics/README.md` (statistik), `../../Core Tidyverse/` (referensi fungsi)

---

*Volume 3 — dari alat menjadi keputusan: case study Industrial Engineering berbasis R.*
