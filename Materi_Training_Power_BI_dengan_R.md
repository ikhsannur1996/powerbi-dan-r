# Materi Training
## Insight to Impact: Elevating Power BI with R

**Durasi:** 120 menit (10.00-12.00 WIB)  
**Peserta:** Asisten Laboratorium ADRK dan peserta Teknik Industri  
**Level:** Power BI dasar-menengah, statistik dasar-menengah, pengantar R  
**Metode:** Demonstrasi singkat, praktik terpandu, diskusi berbasis kasus

## 1. Tujuan Pembelajaran

Pada akhir sesi, peserta mampu:

1. Menjelaskan posisi R dan Power BI dalam alur kerja analitik end-to-end.
2. Menjalankan R script di Power Query untuk membersihkan dan membentuk data.
3. Membuat visualisasi `ggplot2` yang menerima filter dari Power BI.
4. Menggabungkan visual native Power BI dan visual R dalam satu halaman dashboard.
5. Menyusun insight yang dapat ditindaklanjuti untuk pengambilan keputusan.

## 2. Skenario Kasus

Laboratorium ingin memantau hasil inspeksi kualitas beberapa lini produksi. Pertanyaan bisnisnya:

- Lini mana yang memiliki defect rate paling tinggi?
- Apakah variasi proses meningkat pada lini tertentu?
- Bagaimana pola defect berubah menurut bulan dan jenis defect?
- Tindakan perbaikan mana yang perlu diprioritaskan?

KPI yang digunakan:

| KPI | Definisi |
| --- | --- |
| Total inspected | Jumlah unit yang diperiksa |
| Total defect | Jumlah unit cacat |
| Defect rate | Total defect / total inspected |
| Average cycle time | Rata-rata waktu siklus dalam detik |
| First pass yield | (Inspected - Defect) / Inspected |

## 3. Alur Kerja Power BI dan R

```text
CSV/Excel -> Power Query + R (cleaning/features) -> Data model ->
Visual native Power BI + R visual -> Insight dan keputusan
```

### Kapan memakai Power Query + R?

Gunakan untuk transformasi yang lebih nyaman ditulis sebagai kode: standardisasi nama, pembuatan kolom turunan, pengelompokan, deteksi nilai ekstrem, atau transformasi berulang.

### Kapan memakai R visual?

Gunakan ketika visual yang dibutuhkan tidak tersedia secara native atau ketika `ggplot2` memberi kontrol statistik dan estetika yang lebih baik. R visual tetap mengikuti filter dan cross-filter Power BI selama kolom yang relevan dimasukkan ke bidang visual.

### Batasan penting

- R visual dirender sebagai gambar; interaktivitasnya mengikuti filter Power BI, bukan interaksi di dalam gambar.
- Kolom yang digunakan R visual harus dimasukkan ke bagian **Values** visual tersebut.
- Power BI Desktop harus menemukan instalasi R dan paket yang digunakan.
- Untuk distribusi laporan, uji ulang dependensi R pada lingkungan publikasi/gateway organisasi.

## 4. Konsep Inti yang Disampaikan

### 4.1 Data preparation dengan prinsip reproducibility

Transformasi harus dapat diulang dan ditelusuri. Hindari cleaning manual di spreadsheet untuk langkah yang akan dilakukan berkali-kali. Contoh langkah yang aman:

1. Validasi tipe tanggal, numerik, dan kategori.
2. Hapus baris tanpa ID inspeksi atau dengan jumlah inspeksi tidak valid.
3. Normalisasi label lini dan jenis defect.
4. Buat metrik turunan secara eksplisit.
5. Simpan nama output yang jelas, misalnya `CleanData`.

### 4.2 Desain data model sederhana

Untuk latihan, gunakan satu tabel fakta inspeksi. Dalam proyek nyata, pisahkan tabel fakta dari dimensi tanggal, produk, dan lini bila kebutuhan analisis berkembang. Pastikan satu baris memiliki grain yang jelas: satu baris mewakili satu kombinasi inspeksi harian, lini, dan jenis defect.

### 4.3 Visualisasi yang menjawab pertanyaan

- KPI card: kondisi terkini.
- Column chart: perbandingan antar lini.
- Line chart: tren bulanan.
- Scatter plot `ggplot2`: hubungan cycle time dan defect rate.
- Tooltip dan filter: memberi konteks tanpa memenuhi halaman.

## 5. R Script untuk Power Query

Power Query meneruskan tabel input ke R sebagai data frame bernama `dataset`. Contoh transformasi:

```r
library(dplyr)
library(lubridate)

CleanData <- dataset |>
  mutate(
    InspectionDate = as.Date(InspectionDate),
    Line = trimws(toupper(Line)),
    DefectType = if_else(is.na(DefectType) | DefectType == "", "NONE", DefectType),
    Defect = as.integer(Defect),
    Inspected = as.integer(Inspected),
    DefectRate = Defect / Inspected,
    FirstPassYield = 1 - DefectRate,
    Month = floor_date(InspectionDate, unit = "month")
  ) |>
  filter(Inspected > 0, Defect >= 0, Defect <= Inspected)
```

Klik **Close & Apply**, lalu gunakan `CleanData` sebagai tabel laporan. Pada demo, jelaskan bahwa nama kolom dan nama output harus konsisten karena Power BI membaca hasil terakhir dari script.

## 6. R Visual dengan ggplot2

Masukkan `InspectionDate`, `Line`, `DefectRate`, dan `Inspected` ke **Values** pada R visual. Power BI membuat data frame `dataset` yang hanya berisi kolom tersebut dan menghapus duplikasi baris.

```r
library(ggplot2)
library(scales)

plot_data <- dataset |>
  transform(
    InspectionDate = as.Date(InspectionDate),
    DefectRate = as.numeric(DefectRate)
  )

ggplot(plot_data, aes(x = InspectionDate, y = DefectRate, color = Line)) +
  geom_point(aes(size = Inspected), alpha = 0.75) +
  geom_smooth(method = "loess", se = FALSE, linewidth = 0.8) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(
    title = "Pola defect rate menurut waktu",
    x = "Tanggal inspeksi", y = "Defect rate", color = "Lini", size = "Unit diperiksa"
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")
```

Catatan: agregasi untuk R visual sebaiknya dilakukan dengan sadar. Jika satu tanggal-lini memiliki beberapa baris, gunakan agregasi di Power Query atau agregasikan di R agar titik tidak menyesatkan.

## 7. Rancangan Dashboard

Susun satu halaman bernama **Quality Control Overview**:

1. Baris atas: Total inspected, Total defect, Defect rate, First pass yield.
2. Bagian tengah kiri: defect rate per lini.
3. Bagian tengah kanan: tren defect rate menggunakan R visual.
4. Bagian bawah: tabel ringkasan lini dengan conditional formatting.
5. Slicer: bulan, lini, dan jenis defect.

Gunakan judul visual berbentuk pertanyaan, misalnya **“Lini mana paling perlu investigasi?”**. Hindari menampilkan terlalu banyak chart tanpa keputusan yang dituju.

## 8. Evaluasi Pembelajaran

Peserta dinyatakan mencapai target apabila dapat:

- menghasilkan tabel `CleanData` tanpa baris tidak valid;
- menampilkan minimal empat KPI dengan nilai yang konsisten;
- membuat satu R visual yang berubah ketika slicer digunakan;
- menyampaikan satu insight, bukti pendukung, dan rekomendasi tindakan.
