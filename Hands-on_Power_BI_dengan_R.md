# Hands-on Peserta
## Membangun Quality Control Overview

**Waktu praktik efektif:** sekitar 75 menit dari total sesi 120 menit  
**File:** `quality_inspection.csv` dan `quality_inspection_cleaning.R`

## A. Persiapan

Pastikan tersedia:

- Power BI Desktop dengan akses Power Query;
- R atau RStudio;
- paket R `dplyr`, `lubridate`, `ggplot2`, dan `scales`;
- file `quality_inspection.csv`.

> Power BI Desktop tidak tersedia secara native di macOS. Praktik Power BI perlu dilakukan pada Windows, mesin virtual, atau komputer laboratorium. RStudio dan skripnya dapat disiapkan di macOS.

Instal paket sekali saja di RStudio:

```r
install.packages(c("dplyr", "lubridate", "ggplot2", "scales"))
```

## B. Tantangan Utama

Bangun dashboard yang menjawab: **“Lini dan jenis defect mana yang perlu diprioritaskan untuk perbaikan bulan berikutnya?”**

Output minimum:

- tabel hasil cleaning bernama `CleanData`;
- empat KPI;
- satu visual native Power BI;
- satu visual `ggplot2` yang merespons slicer;
- satu insight tertulis dengan format kondisi, bukti, dan tindakan.

## C. Langkah Praktik Terpandu

### 1. Impor data - 5 menit

1. Buka Power BI Desktop.
2. Pilih **Get data > Text/CSV**.
3. Pilih `quality_inspection.csv`.
4. Pilih **Transform Data**, bukan langsung **Load**.
5. Periksa tipe data dan nama kolom.

### 2. Cleansing sederhana dengan `dplyr` - 15 menit

1. Di Power Query pilih **Transform > Run R script**.
2. Pastikan input Power Query tersedia sebagai data frame bernama `dataset`.
3. Tempel atau jalankan isi `quality_inspection_cleaning.R`.
4. Pilih hasil `CleanData` pada dialog navigator.
5. Pastikan `InspectionDate` bertipe Date dan metrik numerik bertipe Decimal Number.
6. Pilih **Close & Apply**.

Contoh-contoh kecil berikut dapat dicoba di RStudio menggunakan `quality_inspection.csv`:

```r
library(dplyr)

data <- read.csv("quality_inspection.csv")

# Melihat lima baris pertama
head(data)

# Memilih beberapa kolom
data |> select(InspectionDate, Line, Defect, Inspected)

# Memilih inspeksi dari lini tertentu
data |> filter(Line == "L1")

# Memilih inspeksi dengan defect lebih dari 5
data |> filter(Defect > 5)

# Membuat kolom defect rate
data |> mutate(DefectRate = Defect / Inspected)

# Mengurutkan defect rate dari yang terbesar
data |>
  mutate(DefectRate = Defect / Inspected) |>
  arrange(desc(DefectRate))

# Menghitung rata-rata defect rate per lini
data |>
  group_by(Line) |>
  summarise(AvgDefectRate = mean(Defect / Inspected, na.rm = TRUE))
```

Kode utama cleansing menggunakan `dplyr`:

```r
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

Pemeriksaan cepat:

- tidak ada `Inspected <= 0`;
- `Defect` tidak lebih besar dari `Inspected`;
- `DefectRate` berada antara 0 dan 1;
- label lini tidak memiliki spasi/variasi kapital yang tidak perlu.

### 3. Bangun KPI dan visual native - 20 menit

Buat measure berikut pada tabel `CleanData`:

```DAX
Total Inspected = SUM(CleanData[Inspected])

Total Defect = SUM(CleanData[Defect])

Defect Rate = DIVIDE([Total Defect], [Total Inspected])

First Pass Yield = 1 - [Defect Rate]
```

Tambahkan empat Card. Tambahkan juga:

- clustered column chart: `Line` dan `Defect Rate`;
- line chart: `Month` dan `Defect Rate`;
- slicer: `Month`, `Line`, `DefectType`.

Format `Defect Rate` dan `First Pass Yield` sebagai persentase dengan satu angka desimal.

### 4. Visualisasi sederhana dengan `ggplot2` - 20 menit

1. Tambahkan visual **R** dari panel Visualizations. `ggplot2` digunakan pada tahap ini untuk membuat grafik, bukan untuk cleansing data.
2. Masukkan `InspectionDate`, `Line`, `DefectRate`, dan `Inspected` ke **Values**.
3. Tempel kode berikut:

```r
library(ggplot2)
library(scales)

plot_data <- dataset
plot_data$InspectionDate <- as.Date(plot_data$InspectionDate)
plot_data$DefectRate <- as.numeric(plot_data$DefectRate)

ggplot(plot_data, aes(InspectionDate, DefectRate, color = Line)) +
  geom_point(aes(size = Inspected), alpha = 0.75) +
  geom_smooth(method = "loess", se = FALSE) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Tren defect rate", x = "Tanggal", y = "Defect rate") +
  theme_minimal() +
  theme(legend.position = "bottom")
```

4. Uji slicer `Line`. Pastikan titik dan garis berubah.
5. Beri judul visual yang menjelaskan keputusan yang didukung.

Contoh grafik sederhana untuk dicoba di RStudio:

```r
library(ggplot2)

plot_data <- data
plot_data$DefectRate <- plot_data$Defect / plot_data$Inspected

# 1. Bar chart: defect rate per lini
ggplot(plot_data, aes(x = Line, y = DefectRate)) +
  geom_col()

# 2. Bar chart berwarna berdasarkan lini
ggplot(plot_data, aes(x = Line, y = DefectRate, fill = Line)) +
  geom_col()

# 3. Line chart: defect rate dari waktu ke waktu
ggplot(plot_data, aes(x = InspectionDate, y = DefectRate, color = Line)) +
  geom_line()

# 4. Scatter plot: cycle time dan defect rate
ggplot(plot_data, aes(x = CycleTimeSec, y = DefectRate, color = Line)) +
  geom_point()

# 5. Menambahkan judul dan label sumbu
ggplot(plot_data, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  labs(
    title = "Defect rate per lini",
    x = "Lini",
    y = "Defect rate"
  )
```

Untuk R visual di Power BI, gunakan contoh nomor 3 atau gabungkan titik dan garis seperti kode utama di atas. Kolom yang dipakai dalam grafik harus dimasukkan ke **Values** agar grafik dapat mengikuti filter Power BI.

### 5. Tarik insight - 15 menit

Gunakan template berikut:

> **Kondisi:** Lini/defect yang paling perlu perhatian adalah ....  
> **Bukti:** Berdasarkan defect rate sebesar ...% dan tren ....  
> **Tindakan:** Prioritaskan investigasi .... dengan memeriksa ....

Jangan hanya menyebut lini dengan jumlah defect terbesar. Bandingkan juga defect rate karena volume inspeksi antar lini dapat berbeda.

## D. Tantangan Lanjutan Jika Selesai Lebih Cepat

1. Tambahkan garis ambang target defect rate 5% pada R visual.
2. Buat tabel top-3 kombinasi `Line` dan `DefectType` berdasarkan defect rate.
3. Tambahkan tooltip yang menampilkan total inspected.
4. Uji apakah kesimpulan berubah saat hanya memilih bulan terbaru.

Contoh garis ambang:

```r
geom_hline(yintercept = 0.05, linetype = "dashed", color = "red")
```

## E. Rubrik Penilaian Cepat

| Komponen | 0 | 1 | 2 |
| --- | --- | --- | --- |
| Cleaning | Tidak jalan | Jalan dengan koreksi | Reproducible dan tervalidasi |
| KPI | Tidak lengkap | Ada, tetapi format/rumus perlu koreksi | Lengkap dan konsisten |
| R visual | Error/tidak berubah | Tampil | Tampil dan merespons slicer |
| Insight | Deskripsi saja | Ada bukti | Ada bukti dan tindakan jelas |
