# 📊 README Volume 2 — Power BI: Insight to Impact

> Proyek ini adalah **Volume 2** dari rangkaian pelatihan *"Insight to Impact: Elevating Power BI with R"*. Materi di folder ini berfokus pada pembangunan dashboard **Power BI** yang menggabungkan visual native, R visual (`ggplot2`), KPI, dan insight yang ditindaklanjuti.

---

## 1. Gambaran Umum Proyek

| Komponen | Keterangan |
| --- | --- |
| **Nama proyek** | Volume 2 — Power BI |
| **Topik materi** | Power BI (dashboard) + integrasi R |
| **Durasi sesi** | 120 menit (10.00-12.00 WIB) |
| **Tanggal pelatihan** | 20 September 2026 |
| **Format** | Hybrid (offline + online) |
| **Peserta** | Asisten Laboratorium ADRK dan peserta Teknik Industri |
| **Level** | Power BI dasar-menengah, statistik dasar-menengah, pengantar R |
| **Target akhir** | Dashboard Power BI profesional yang menggabungkan visual native dan visual R |

### Tema dan Pokus

> **Insight to Impact: Elevating Power BI with R**

Fokus pelatihan adalah menggabungkan Power BI dan R untuk analisis yang lebih reproducible, terutama:

1. **Data preparation & data cleaning** menggunakan R di Power Query;
2. **Analisis statistik** dan pembuatan metrik turunan;
3. **Visualisasi `ggplot2`** di dalam Power BI;
4. **Penyusunan dashboard** yang menghasilkan insight dan rekomendasi tindakan.

### Gambaran Materi Volume 1 vs Volume 2

| | Volume 1 (R Studio) | Volume 2 (Power BI) |
| --- | --- | --- |
| Focus | Analisis statistik + visualisasi dalam RStudio | Dashboard Power BI yang menyampaikan insight |
| Luaran | Skrip R, grafik ggplot2 | File `.pbix` (dashboard interaktif) |
| Koneksi | Fondasi analitik | Aplikasi bisnis dari hasil Volume 1 |

---

## 2. Tujuan Pembelajaran

Pada akhir sesi Volume 2, peserta diharapkan mampu:

1. Menjelaskan **posisi R dan Power BI** dalam alur kerja analitik end-to-end.
2. **Membersihkan dan membentuk data** menggunakan R skript di Power Query.
3. Membuat visualisasi `ggplot2` yang **merespons filter Power BI**.
4. Menggabungkan **KPI, visual native, dan visual R** dalam satu dashboard.
5. Menyampaikan **insight berbasis data** beserta tindakan yang disarankan.

---

## 3. Prasyarat Teknis

### 3.1 Software yang Dibutuhkan

| Software | Keterangan |
| --- | --- |
| **Power BI Desktop** | Dengan akses Power Query dan R visual. Download: <https://powerbi.microsoft.com/desktop/> |
| **R / RStudio** | Instalasi R <https://cran.r-project.org/> dan RStudio <https://posit.co/download/rstudio-desktop/> |
| **Dataset** | `quality_inspection.csv` (baca dari direktori induk `../quality_inspection.csv`) |
| **Skrip R** | `quality_inspection_cleaning.R` |

### 3.2 Package R yang Wajib

Jalankan **sekali saja** di RStudio:

```r
install.packages(c("dplyr", "lubridate", "ggplot2", "scales"))
```

### 3.3 Catatan macOS

> Power BI Desktop **tidak tersedia secara native di macOS**. Peserta macOS perlu memakai komputer **Windows**, mesin virtual Windows, atau lingkungan laboratorium untuk bagian Power BI. RStudio dan skrip R tetap dapat disiapkan di macOS.

### 3.4 Power BI Mendeteksi Instalasi R

Power BI Desktop harus dapat menemukan instalasi R (Settings > Options > R Script). Periksa:

- path instalasi R (R.exe / Rscript.exe);
- paket `dplyr`, `lubridate`, `ggplot2`, `scales` tersedia untuk instalasi R itu.

---

## 4. Struktur Folder Proyek

```text
Volume 2 - Power BI/
├── README.md                 <- dokumen ini (materi lengkap)
├── data/
│   └── quality_inspection.csv  <- dataset (copy dari folder induk)
├── scripts/
│   └── quality_inspection_cleaning.R  <- R skrip untuk Power Query
├── dashboard/
│   └── Quality_Control_Overview.pbix  <- file laporan Power BI
└── reports/
    └── Catatan_Insight.md     <- insight dan rekomendasi tindakan
```

> Skrip `quality_inspection_cleaning.R` dan dataset sudah tersedia di folder induk. Anda dapat menyalin ke folder `data/` dan `scripts/` agar proyek Volume 2 menjadi **self-contained**.

---

## 5. Dataset Proyek

### 5.1 Struktur `quality_inspection.csv`

| Kolom | Tipe | Keterangan |
| --- | --- | --- |
| `InspectionDate` | Date | Tanggal inspeksi |
| `Line` | Text | Lini produksi |
| `Product` | Text | Nama produk |
| `DefectType` | Text | Jenis defect (kosong = tidak ada defect) |
| `Inspected` | Number | Jumlah unit yang diperiksa |
| `Defect` | Number | Jumlah unit cacat |
| `CycleTimeSec` | Number | Waktu siklus (detik) |

### 5.2 Skenario Bisnis

Peserta berperan sebagai **analis kualitas** laboratorium yang memantau inspeksi beberapa lini produksi. Pertanyaan utama latihan:

> 💬 **Lini dan jenis defect mana yang perlu diprioritaskan untuk perbaikan bulan berikutnya?**

### 5.3 Pertanyaan Bisnis Eksplisit

1. Lini mana yang memiliki defect rate paling tinggi?
2. Apakah variasi proses meningkat pada lini tertentu?
3. Bagaimana pola defect berubah menurut bulan dan jenis defect?
4. Tindakan perbaikan mana yang perlu diprioritaskan?

---

## 6. Alur Kerja Power BI dan R

```text
CSV / Excel -> Power Query + R (cleaning/features) -> Data model ->
Visual native Power BI + R visual (ggplot2) -> Insight dan keputusan
```

### 6.1 Kapan memakai Power Query + R?

Gunakan R di Power Query untuk transformasi yang lebih nyaman ditulis sebagai kode:

- standardisasi nama (trim, uppercase, normalisasi teks);
- pembuatan kolom turunan (`DefectRate`, `FirstPassYield`, `Month`, `QualityFlag`);
- pengelompokan dan diringkasan;
- deteksi nilai ekstrem/hapus baris tidak valid;
- transformasi berulang yang tetap reproducible.

### 6.2 Kapan memakai R visual?

Gunakan R visual ketika:

- visual yang dibutuhkan tidak tersedia secara native di Power BI;
- `ggplot2` memberi kontrol statistik dan estetika yang lebih baik;
- ingin menyampaikan tren/pola dengan garis `loess`, ukuran titik per volume, dan lain-lain.

### 6.3 Batasan Penting (catatan sebelum mulai)

1. R visual dirender sebagai **gambar**; interaktivitas hanya mengikuti **filter Power BI** (slicer, cross-filter), bukan interaksi di dalam gambar.
2. **Kolom yang dipakai R visual harus dimasukkan ke bagian Values** pada visual tersebut; jika tidak, R tidak menerima data.
3. Power BI harus menemukan instalasi R dan paket yang digunakan.
4. Jangan gunakan nama kolom yang duplikat; Power BI menghapus duplikasi baris saat mengirim data ke R.
5. Untuk distribusi laporan, uji ulang dependensi R pada lingkungan publikasi/gateway organisasi.

---

## 7. Modul 1 — Data Preparation & Cleaning Menggunakan R di Power Query

### 7.1 Langkah 1: Impor Data (5 menit)

1. Buka **Power BI Desktop**.
2. Klik **Get data > Text/CSV**.
3. Pilih `quality_inspection.csv` dari folder proyek.
4. Klik **Transform Data** (JANGAN langsung Load — data harus dibersihkan dulu).
5. Periksa tipe data dan nama kolom di Power Query Editor.

### 7.2 Langkah 2: Running R Script (15 menit)

1. Di Power Query, pilih **Transform > Run R script**.
2. Power Query menyediakan tabel input kepada R sebagai data frame bernama **`dataset`**.
3. Tempel atau jalankan isi `quality_inspection_cleaning.R`.
4. Pada dialog navigator, pilih hasil output bernama **`CleanData`**.
5. Pastikan tipe hasil: `InspectionDate` = Date, metrik numerik = Decimal Number.
6. Klik **Close & Apply** untuk menerapkan transformasi di model.

### 7.3 Kode Cleaning Lengkap

```r
# Script ini dipakai di Power Query > Transform > Run R script.
# Power Query menyediakan tabel input dengan nama dataset.

library(dplyr)
library(lubridate)

CleanData <- dataset |>
  mutate(
    InspectionDate = as.Date(InspectionDate),
    Line = trimws(toupper(Line)),
    Product = trimws(Product),
    DefectType = trimws(DefectType),
    DefectType = if_else(is.na(DefectType) | DefectType == "", "NONE", DefectType),
    Inspected = as.integer(Inspected),
    Defect = as.integer(Defect),
    CycleTimeSec = as.numeric(CycleTimeSec)
  ) |>
  filter(
    !is.na(InspectionDate),
    !is.na(Inspected),
    Inspected > 0,
    !is.na(Defect),
    Defect >= 0,
    Defect <= Inspected
  ) |>
  mutate(
    DefectRate = Defect / Inspected,
    FirstPassYield = 1 - DefectRate,
    Month = floor_date(InspectionDate, unit = "month"),
    QualityFlag = if_else(DefectRate > 0.05, "Above target", "On target")
  )
```

### 7.4 Tahapan Cleaning yang Diexplisit

| # | Tahapan | Kode penting |
| --- | --- | --- |
| 1 | Mengubah tanggal dan kolom numerik ke tipe yang sesuai | `as.Date()`, `as.integer()`, `as.numeric()` |
| 2 | Menyamakan format `Line` dan `Product` (hapus spasi, uppercase) | `trimws()`, `toupper()` |
| 3 | Mengganti `DefectType` kosong menjadi `NONE` | `if_else(is.na() \| == "", "NONE", ...)` |
| 4 | Hapus inspeksi tidak valid | `filter(Inspected > 0, Defect <= Inspected)` |
| 5 | Metrik turunan | `DefectRate`, `FirstPassYield`, `Month`, `QualityFlag` |

### 7.5 Validasi Hasil Cleaning

Pastikan jumlah baris `CleanData` logis dan tanpa baris tidak valid:

```r
summary(CleanData$DefectRate)
any(CleanData$Inspected <= 0)                # FALSE
any(CleanData$Defect > CleanData$Inspected)  # FALSE
```

> Jangan lupa: nama kolom dan nama output **harus konsisten**, karena Power BI membaca hasil akhir dari skrip dengan nama `CleanData`.

### 7.6 Prinsip Reproducibility

Transformasi harus dapat **diulang** dan **ditelusuri**. Hindari cleaning manual di spreadsheet untuk langkah yang akan dilakukan berkali-kali (misal ketika data perbarui setiap bulan). Kode skript menyimpan logika cleaning in-satu-tempat.

---

## 8. Modul 2 — Desain Data Model Sederhana

Untuk latihan ini kita gunakan **satu tabel fakta inspeksi** bernama `CleanData`.

### 8.1 Grain yang Jelas

- **Setiap baris mewakili satu kombinasi** inspeksi harian, lini, dan jenis defect.
- Tidak ada baris duplikat setelah tahap cleaning.

### 8.2 Fakta vs Dimensi (untuk proyek lanjutan)

```text
Dimensi (tabel kecil)             Fakta (tabel besar)
┌───────────────┐           ┌──────────────────────────┐
│ Dim_Date      │ 1──N      │ CleanData                │
│ Dim_Line      │ 1──N      │ InspectionDate           │
│ Dim_Product   │ 1──N      │ Line | Product | Defect  │
│ Dim_DefectType│ 1──N      │ Inspected | CycleTimeSec │
└───────────────┘           └──────────────────────────┘
```

- **Fakta**: jumlah unit, defect, cycle time — agregat per dimensi.
- **Dimensi**: kalender tanggal (bulan/tahun), daftar lini, produk, jenis defect.

### 8.3 Praktik untuk Sesi Ini

Untuk latihan, gunakan satu tabel `CleanData` dan agregasikan langsung di visual (bulan dari `InspectionDate`). Data model dinyatakan tetap sederhana agar peserta focus pada integrasi R.

---

## 9. Modul 3 — KPI dan Metrik Turunan

### 9.1 Definisi KPI

| KPI | Definisi | Rumus |
| --- | --- | --- |
| **Total inspected** | Jumlah unit yang diperiksa | `SUM(Inspected)` |
| **Total defect** | Jumlah unit cacat | `SUM(Defect)` |
| **Defect rate** | Proporsi defect | `Total defect / Total inspected` |
| **First pass yield** | Proporsi unit tanpa defect | `(Inspected - Defect) / Inspected` |
| **Average cycle time** | Rata-rata waktu siklus (detik) | `AVERAGE(CycleTimeSec)` |

Metrik `DefectRate`, `FirstPassYield`, `Month`, dan `QualityFlag` sudah dibuat **di R** (kolom turunan pada `CleanData`) — ini menjaga satu sumber truth antara Volume 1 dan Volume 2.

### 9.2 Format Visual KPI

- `Defect Rate` dan `First Pass Yield` → format **persentase** dengan satu angka desimal.
- `Total inspected` dan `Total defect` → format **Number/thousand separator**.

---

## 10. Modul 4 — Visual Native Power BI

### 10.1 Rancangan minimal dashboard (Quality Control Overview)

1. **Baris atas**: 4 KPI card (Total inspected, Total defect, Defect rate, First pass yield).
2. **Tengah kiri**: column chart **defect rate per lini**.
3. **Tengah kanan**: **R visual** tren defect rate (ggplot2) — merespons slicer.
4. **Bagian bawah**: tabel ringkasan lini dengan conditional formatting.
5. **Slicer**: `Month`, `Line`, `DefectType`.

### 10.2 Column Chart — Defect Rate per Lini

1. Tambah visual **Column chart**.
2. **X-axis** → `Line`.
3. **Y-axis** → `DefectRate` (set aggregated by `Average` atau yang sesuai skenario; lebih tepat: gunakan measure `DefectRate = DIVIDE(SUM(Defect), SUM(Inspected))`).
4. Format Y-axis sebagai **persentase** dengan satu desimal.
5. Judul visual berbentuk pertanyaan: *"Lini mana paling perlu investigasi?"*

### 10.3 Contoh Measure DAX (Rekomendasi)

```dax
Defect Rate = DIVIDE(SUM(CleanData[Defect]), SUM(CleanData[Inspected]))

First Pass Yield = 1 - [Defect Rate]

Total Inspected = SUM(CleanData[Inspected])

Total Defect = SUM(CleanData[Defect])

Average Cycle Time = AVERAGE(CleanData[CycleTimeSec])
```

> Measure dengan `DIVIDE` lebih aman daripada `/` (divides by zero handling). Nama measure jangan duplikat dengan nama kolom R (`DefectRate`) agar tidak tercampur; beri nama kolom R `DefectRate` dan measure `Overall Defect Rate` untuk menjaga kejelasan.

### 10.4 Slicer

Slicer untuk `Month`, `Line`, `DefectType` memberi peserta kontrol:

- Slicer **Visualizations > Slicer**;
- Tambahkan kolom dari `CleanData`;
- Format sebagai daftar (list) dengan single select (atau multi).

### 10.5 Tabel Ringkasan dengan Conditional Formatting

1. Tambah **Table visual**.
2. Dimensi: `Line`.
3. Kolom: `Total Inspected`, `Total Defect`, `Defect Rate`, `Average Cycle Time`.
4. Conditional formatting pada `Defect Rate`:
   - **Color scale** (green-yellow-red) atau **Rules**: `> 0.05` red, else green.

### 10.6 Tooltip (lanjutan)

Tambah tooltip page yang menampilkan `Total Inspected` dan `Total Defect` ketika user hover pada lini/kolom.

---

## 11. Modul 5 — R Visual dengan ggplot2 di Power BI

### 11.1 Langkah Menambahkan R Visual

1. Di panel **Visualizations**, klik ikon **R** (R visual).
2. Masukkan kolom yang dibutuhkan ke bagian **Values**:
   - `InspectionDate`, `Line`, `DefectRate`, `Inspected`.
3. Power BI menjalankan R dan membuat data frame **`dataset`** yang hanya berisi kolom tersebut (duplikasi baris dihapus secara otomatis).
4. Tempel kode R di editor visual.

### 11.2 Kode R Visual Utama (tren defect rate)

```r
library(ggplot2)
library(scales)

plot_data <- dataset
plot_data$InspectionDate <- as.Date(plot_data$InspectionDate)
plot_data$DefectRate <- as.numeric(plot_data$DefectRate)

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

### 11.3 Cara Baca Visual Ini

- **Titik**: nilai raw per inspeksi; ukuran titik = volume unit.
- **Garis loess**: kecenderungan rata-rata defect rate per lini.
- **Legend**: warna per lini, posisi bottom.

### 11.4 Tantangan Lanjutan: Ambang Target

Ditambahkan garis dashed di target 5%:

```r
geom_hline(yintercept = 0.05, linetype = "dashed", color = "red")
```

### 11.5 Uji Interaktif

1. Klik slicer `Line` dan pastikan titik/garis **berubah**.
2. Klik visual native (cross-filter) dan pastikan R visual berubah.
3. Periksa apakah judul visual masih menjelaskan keputusan yang didukung.

### 11.6 Catatan Penting R Visual

- R visual dirender sebagai **gambar**; elemen di dalamnya **tidak interaktif** (no hover/tooltip dalam gambar).
- Semua kolom yang dipakai **harus dimasukkan ke Values**.
- Agregasi untuk R visual sebaiknya dilakukan dengan **sadar**; jika satu tanggal-lini berisi beberapa baris, agregasikan di Power Query atau di R agar titik tidak menyesatkan.

---

## 12. Modul 6 — Penyusunan Dashboard & Insight

### 12.1 Rancangan Visual Halaman (Layout)

```
┌──────────────────────────────────────────────────────┐
│  Quality Control Overview            [Slicer Baris]  │
├──────────┬──────────┬──────────┬─────────────────────┤
│ Total    │ Total    │ Defect   │ First Pass          │
│ Inspected│ Defect   │ Rate     │ Yield               │
├──────────┴──────────┴──────────┴─────────────────────┤
│  Column Chart:         │  R Visual (ggplot2):       │
│  Defect rate per lini  │  Pola defect rate (tren)   │
├────────────────────────┴────────────────────────────┤
│  Table: Line | Total Inspected | Total Defect |     │
│         Defect Rate | Avg Cycle Time                │
│  [conditional formatting]                            │
├──────────────────────────────────────────────────────┤
│  Insight box: Kondisi > Bukti > Tindakan             │
└──────────────────────────────────────────────────────┘
```

### 12.2 Prinsip Desain Dashboard

1. Judul visual berbentuk **pertanyaan**, bukan deskripsi.
2. **KPI in baris atas** jawab "kondisi terkini" cepat.
3. Column chart jawab "perbandingan antar lini".
4. Line/R visual jawab "tren dari waktu ke waktu".
5. Tabel dan slicer memberi **detail dan kontrol**.
6. Hindari banyak chart tanpa keputusan — setiap visual menjawab minimal satu pertanyaan.

### 12.3 Template Insight (Kondisi-Bukti-Tindakan)

> 🔎 **Kondisi:** Lini/defect yang paling perlu perhatian adalah **….**
>
> 📊 **Bukti:** defect rate sebesar **…%** (vs target 5%), tren «…», dengan total inspected **… unit**.
>
> ⚡ **Tindakan:** prioritaskan investigasi **…** dengan memeriksa **…** (misal root cause, calibration, re-training operator).

**Poin analitik penting:** jangan prioritaskan hanya berdasarkan total defect — membandingkan **defect rate** karena volume inspeksi antar lini dapat berbeda.

### 12.4 Contoh Insight Lengkap

> **Kondisi:** Lini B dan defect type "Misalignment" perlu diprioritaskan. **Bukti:** defect rate lini B sebesar 8,4% — di atas ambang 5%, dan tren menunjukkan peningkatan dari bulan Juni ke Juli, dengan 6.200 unit diperiksa. **Tindakan:** investigasi proses alignment di lini B (kalibrasi mesin dan review fixture) secepatnya untuk menurunkan defect sebelum produksi bulan berikutnya.

---

## 13. Tantangan Lanjutan (Jika Selesai Lebih Cepat)

1. **Garis ambang target 5%** pada R visual (`geom_hline`).
2. **Top-3 kombinasi `Line` + `DefectType`** berdasarkan defect rate.
3. **Tooltip** yang menampilkan `Total Inspected`.
4. **Uji sensitivitas**: apakah kesimpulan berubah saat hanya pilih bulan terbaru?
5. Tambahkan **page report** dengan grafik statistik Volume 1 (uji t/ANOVA/regresi) sebagai suplemen analisis.

---

## 14. Rubrik Penilaian Cepat

| Komponen | 0 | 1 | 2 |
| --- | --- | --- | --- |
| **Cleaning** | Tidak jalan | Jalan dengan koreksi | Reproducible dan tervalidasi |
| **KPI** | Tidak lengkap | Ada tetapi format/rumus perlu koreksi | Lengkap dan konsisten |
| **R visual** | Error/tidak berubah | Tampil | Tampil **dan** merespons slicer |
| **Insight** | Deskripsi saja | Ada bukti | Ada bukti **dan** tindakan jelas |

---

## 15. Agenda 120 Menit

| Waktu | Kegiatan | Hasil |
| --- | --- | --- |
| 10 menit | Pembukaan dan konteks bisnis | Peserta memahami tujuan integrasi Power BI + R |
| 15 menit | Konsep alur kerja Power BI + R | Peserta memahami posisi Power Query, R visual, data model |
| 15 menit | Demo import dan cleaning | Tabel `CleanData` terbentuk |
| 15 menit | Demo KPI dan visual native | KPI dan visual perbandingan lini tersedia |
| 30 menit | Hands-on terpandu | Peserta membangun bagian utama dashboard |
| 20 menit | R visual dengan `ggplot2` | Visual tren/pola defect merespons filter |
| 10 menit | Penyusunan insight | Peserta menulis bukti dan rekomendasi |
| 5 menit | Review dan penutup | Hasil latihan diperiksa |

---

## 16. Checklist Penyelesaian Volume 2

- [ ] Dataset `quality_inspection.csv` impor ke Power BI (Transform Data).
- [ ] R script dijalankan di Power Query; output `CleanData` dipilih.
- [ ] `InspectionDate` = Date, metrik = Decimal Number.
- [ ] 4 KPI card dibuat dengan nilai konsisten.
- [ ] 1 visual native (column chart defect rate per lini) dibuat.
- [ ] Slicer `Month`, `Line`, `DefectType` dibuat dan jalan.
- [ ] 1 R visual ggplot2 dibuat dan **berubah** saat slicer digunakan.
- [ ] Tabel ringkasan dengan conditional formatting dibuat.
- [ ] Insight tertulis dengan format Kondisi-Bukti-Tindakan.

---

## 17. Kesalahan Umum dan Solusion

| Kesalahan | Solusion |
| --- | --- |
| R script error di Power Query | Periksa instalasi R/package; pastikan input bernama `dataset`; jalan skrip dulu di RStudio |
| Output `CleanData` tidak muncul di navigator | Pastikan nama objek output `CleanData` dan tidak ada error sebelum baris akhir |
| R visual tidak berubah saat slicer | Pastikan kolom yang dipakai dimasukkan ke **Values**; slicer terhubung ke tabel yang sama |
| R visual kosong/blank | Periksa `dir()`/error message di visual; pastikan data tidak kosong setelah filter |
| `geom_col` / `geom_smooth` not found | Install ggplot2 versi terbaru: `install.packages("ggplot2")` |
| Power BI tidak menemukan R.exe | Set path R Script di Options > Options > R Script |
| Duplikasi baris di R visual | Power BI menghapus duplikasi; jika perlu, agregasikan sebelum R visual |
| KPI display `#` overflow | Lebarkan kolom atau ubah format number |

---

## 18. Tips & Trik Volume 2

### 18.1 R di Power Query

1. Uji R dulu di RStudio sebelum menaruh di Power Query.
2. Nama output bersih konsisten: `CleanData`.
3. Power Query input selalu bernama `dataset` — tidak mengubah itu.
4. Jika R error di Power Query, jalan skrip dulu di RScript/console.
5. Pastikan instalasi R dipakai Power BI sama dengan yang di RStudio.

### 18.2 R Visual

6. Kolom yang dipakai R visual **harus masuk Values**.
7. R visual dirender sebagai gambar — tidak "hover" di dalam.
8. Semua filter/slicer yang memengaruhi data akan ri-render R visual.
9. Gunakan `library(ggplot2)` dan `library(scales)` di kode visual.
10. Agregasi lakukan di Power Query atau R sebelum plot — bukan biarkan mentah.

### 18.3 DAX & Format

11. `DIVIDE()` lebih aman daripada `/`.
12. Nama measure ≠ nama kolom (`DefectRate` vs `Overall Defect Rate`).
13. Format persen 1 desimal; ribuan separator untuk count/unit.
14. Conditional formatting tabel untuk ambang 5%.
15. Bereken measure dalam satu tempat (Display Folder) agar konsisten.

### 18.4 Desain & Insight

16. Dashboard minimal: 4 KPI + 1 native + 1 R visual + slicer + insight.
17. Judul berupa pertanyaan, bukan label.
18. Prioritasi berdasarkan defect rate, bukan hanya total defect.
19. Uji sensitiviti: jika hanya bulan terbaru, kesimpulan berubah?
20. Simpan `.pbix` di folder `dashboard/` setelah jadi.

---

## 19. Bank Latihan Volume 2 (Exercise Bank)

### 19.1 Cleaning & Model

1. Import `quality_inspection.csv` melalui **Get Data > Text/CSV** + **Transform Data**.
2. Jalankan R script di Power Query; verifikasi output `CleanData` muncul di navigator.
3. Pastikan kolom `InspectionDate` bertipe Date; DefectRate bertipe Decimal.
4. Buat tabel measure (DAX) untuk 4 KPI.

### 19.2 Visual Native

5. Buat 4 KPI card dari measure.
6. Buat column chart defect rate per lini + format persen + judul pertanyaan.
7. Buat slicer untuk `Month`, `Line`, `DefectType`.
8. Buat tabel ringkasan lini + conditional formatting defect rate.

### 19.3 R Visual

9. Tambah R visual, masukan kolom `InspectionDate`, `Line`, `DefectRate`, `Inspected` di Values.
10. Paste kode template (Bab 11 README); verifikasi tren render.
11. Uji slicer Line — titik/garis harus berubah.
12. Tambah garis target 5% (`geom_hline`).

### 19.4 Insight & Final

13. Tulis insight Kondisi-Bukti-Tindakan berdasarkan hasil Anda.
14. Uji sensitiviti bulan terbaru (filter Month = terbaru) dan catat perubahan insight.
15. Simpan laporan sebagai `.pbix` di folder proyek.

---

## 20. Kata Kunci Jawaban (Hint Singkat)

- KPI: `SUM(CleanData[Inspected])`, `SUM(CleanData[Defect])`, `DIVIDE(...)`, `1 - [Defect Rate]`.
- R Power Query: output `CleanData` + tipe Date/numeric.
- R Visual Values: 4 kolom wajib.
- Judul pertanyaan: "Lini mana paling perlu investigasi?"
- Conditional: `> 0.05` red, `<= 0.05` green.
- Insight template: kondisi → bukti → tindakan.

---

## 21. Referensi Volume 2

| Berkas | Lokasi |
| --- | --- |
| **Cheatsheet Volume 2 (sintaks Power BI + R)** | `CHEATSHEET.md` (di folder ini) |
| Materi lengkap Volume 2 (untuk pengajar) | `../Materi_Training_Power_BI_dengan_R.md` |
| Hands-on peserta Volume 2 | `../Hands-on_Power_BI_dengan_R.md` |
| README induk | `../README.md` |
| Volume 0 & 1 (fondasi R) | `../Volume 0 - Basic R/README.md`, `../Volume 1 - R Studio/README.md` |
| Dataset | `../quality_inspection.csv` |
| Skrip R Power Query | `../quality_inspection_cleaning.R` |
| TOR sumber | `../Term of Reference (TOR) Training Hardskill Vol. 2 (Pak Ikhsan).docx.pdf` |

---

*README Volume 2 — alur end-to-end: data → model → visual → insight dengan integrasi R.*