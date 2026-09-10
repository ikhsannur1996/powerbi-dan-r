# Basic R: Dari Sintaks Dasar sampai Statistical Analysis

## 1. Gambaran Umum

Dokumen ini adalah modul belajar R untuk pemula. Materi dibuat dengan contoh sederhana dan dataset latihan `quality_inspection.csv`.

Alur belajar:

```text
R dasar -> membaca data -> memahami data -> data manipulation -> visualisasi -> statistik deskriptif -> statistical analysis
```

Kasus yang digunakan adalah inspeksi kualitas produksi. Setiap baris data mewakili satu hasil inspeksi berdasarkan tanggal, lini, produk, dan jenis defect.

## 2. Tujuan Pembelajaran

Setelah menyelesaikan modul ini, peserta dapat:

1. Menjalankan R dan RStudio.
2. Membuat objek, vector, dan data frame.
3. Menggunakan operator dan fungsi dasar R.
4. Membaca, memeriksa, dan menyimpan data CSV.
5. Membersihkan data dengan `dplyr`.
6. Membuat kolom baru, melakukan filter, sorting, grouping, dan summarising.
7. Membuat grafik dasar dengan `ggplot2`.
8. Menghitung statistik deskriptif.
9. Melakukan korelasi, uji t, ANOVA, dan regresi linear sederhana.
10. Menulis interpretasi analisis dengan bahasa bisnis yang jelas.

## 3. Persiapan R dan RStudio

### 3.1 Instalasi

Install R dari CRAN:

<https://cran.r-project.org/>

Install RStudio Desktop dari Posit:

<https://posit.co/download/rstudio-desktop/>

R adalah mesin untuk menjalankan kode. RStudio adalah aplikasi yang membantu menulis kode, melihat data, membaca grafik, dan mengelola project.

### 3.2 Package yang digunakan

Jalankan satu kali saja untuk instalasi:

```r
install.packages(c("dplyr", "lubridate", "ggplot2", "scales"))
```

Panggil package setiap kali memulai sesi analisis:

```r
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)
```

### 3.3 Working directory

Lihat folder kerja saat ini:

```r
getwd()
```

Mengatur folder kerja secara manual:

```r
setwd("/folder/tempat/file/berada")
```

Cara yang lebih aman di RStudio adalah membuka project pada folder yang berisi file latihan. Hindari menulis path dengan backslash tunggal di Windows. Gunakan `/` atau `\\`.

Mengecek isi folder:

```r
list.files()
```

## 4. Dasar-Dasar R

### 4.1 Komentar

Komentar dimulai dengan tanda `#` dan tidak dijalankan oleh R.

```r
# Ini komentar
2 + 3  # R menghitung angka di sebelah kiri
```

### 4.2 Operasi aritmetika

```r
2 + 3       # penjumlahan: 5
10 - 4      # pengurangan: 6
6 * 7       # perkalian: 42
20 / 5      # pembagian: 4
2^3         # pangkat: 8
17 %% 5     # sisa bagi: 2
17 %/% 5    # pembagian bulat: 3
```

Contoh menghitung defect rate:

```r
defect <- 5
inspected <- 120

defect_rate <- defect / inspected
 defect_rate
```

Hapus spasi sebelum `defect_rate` jika menyalin kode di atas. Bentuk yang benar adalah:

```r
defect_rate
```

### 4.3 Assignment dan nama objek

Gunakan `<-` untuk menyimpan nilai ke objek:

```r
inspected <- 120
defect <- 5
product_name <- "Bracket"
```

Nama objek harus jelas. Contoh yang disarankan:

```r
total_inspected <- 1000
average_cycle_time <- 43.5
```

R membedakan huruf besar dan kecil:

```r
value <- 10
Value <- 20
value  # 10
Value  # 20
```

### 4.4 Tipe data dasar

```r
number_value <- 12.5       # numeric
integer_value <- 12L       # integer
text_value <- "Bracket"    # character
logical_value <- TRUE       # logical
missing_value <- NA         # missing value
```

Memeriksa tipe data:

```r
class(number_value)
typeof(number_value)
is.numeric(number_value)
is.character(text_value)
is.logical(logical_value)
```

### 4.5 Vector

Vector berisi beberapa nilai dengan tipe yang sama.

```r
inspected_values <- c(120, 115, 130, 125)
line_values <- c("A", "A", "B", "B")
pass_values <- c(TRUE, TRUE, FALSE, TRUE)
```

Fungsi dasar vector:

```r
length(inspected_values)
sum(inspected_values)
mean(inspected_values)
min(inspected_values)
max(inspected_values)
sort(inspected_values)
```

Membuat urutan angka:

```r
1:5
seq(from = 0, to = 10, by = 2)
rep("A", times = 3)
```

### 4.6 Indexing

Index R dimulai dari 1, bukan 0.

```r
inspected_values[1]
inspected_values[2:3]
inspected_values[c(1, 4)]
inspected_values[-1]
```

Indexing berdasarkan kondisi:

```r
inspected_values[inspected_values > 120]
line_values[line_values == "A"]
```

### 4.7 Missing value

`NA` berarti nilai hilang. Jangan membandingkan `NA` dengan `==` untuk mengecek nilai hilang.

```r
values <- c(10, 20, NA, 40)
is.na(values)
mean(values, na.rm = TRUE)
```

Contoh yang salah:

```r
values == NA
```

Contoh yang benar:

```r
is.na(values)
```

### 4.8 Factor dan tanggal

Kategori dapat disimpan sebagai factor:

```r
line <- factor(c("A", "B", "A", "C"))
levels(line)
```

Tanggal sebaiknya dikonversi menjadi tipe Date:

```r
inspection_date <- as.Date("2026-07-01")
format(inspection_date, "%d-%m-%Y")
```

Dengan `lubridate`:

```r
ymd("2026-07-01")
year(inspection_date)
month(inspection_date)
week(inspection_date)
```

## 5. Fungsi dan Logika Dasar

### 5.1 Fungsi umum

```r
round(4.567, 2)
abs(-10)
sqrt(16)

text <- "quality inspection"
nchar(text)
toupper(text)
tolower(text)
trimws("  Line A  ")
```

### 5.2 Operator perbandingan dan logika

```r
5 > 3
5 == 5
5 != 3
5 >= 5
5 <= 10
```

Operator logika:

```r
# AND: kedua kondisi harus benar
5 > 3 & 5 < 10

# OR: salah satu kondisi benar
5 < 3 | 5 < 10

# NOT: membalik kondisi
!(5 > 3)
```

### 5.3 `if` dan `ifelse`

```r
defect_rate <- 0.06

if (defect_rate > 0.05) {
  print("Above target")
} else {
  print("On target")
}
```

Untuk banyak nilai, gunakan `ifelse()`:

```r
rates <- c(0.02, 0.06, 0.04)
ifelse(rates > 0.05, "Above target", "On target")
```

### 5.4 Membuat fungsi sendiri

```r
calculate_defect_rate <- function(defect, inspected) {
  defect / inspected
}

calculate_defect_rate(5, 120)
```

Fungsi dengan pemeriksaan sederhana:

```r
calculate_defect_rate_safe <- function(defect, inspected) {
  if (inspected <= 0) {
    return(NA_real_)
  }
  defect / inspected
}

calculate_defect_rate_safe(5, 120)
calculate_defect_rate_safe(5, 0)
```

## 6. Membaca dan Memahami Dataset

### 6.1 Membaca CSV

Pastikan file `quality_inspection.csv` berada di working directory.

```r
quality <- read.csv("quality_inspection.csv", stringsAsFactors = FALSE)
```

Di R versi terbaru, alternatifnya:

```r
quality <- read.csv("quality_inspection.csv", stringsAsFactors = FALSE)
```

### 6.2 Melihat struktur dan isi data

```r
head(quality)
tail(quality)
str(quality)
summary(quality)
nrow(quality)
ncol(quality)
names(quality)
dim(quality)
```

Pemeriksaan yang perlu dijawab:

- Apakah jumlah baris sesuai dengan jumlah observasi?
- Apakah tanggal terbaca sebagai tanggal atau masih character?
- Apakah `Inspected`, `Defect`, dan `CycleTimeSec` terbaca sebagai numeric?
- Apakah ada nilai `NA`?
- Apa saja kategori pada `Line`, `Product`, dan `DefectType`?

Contoh pemeriksaan kategori:

```r
unique(quality$Line)
table(quality$Line)
table(quality$DefectType)
```

Contoh pemeriksaan missing value per kolom:

```r
colSums(is.na(quality))
```

### 6.3 Konversi tipe data

```r
quality$InspectionDate <- as.Date(quality$InspectionDate)
quality$Inspected <- as.numeric(quality$Inspected)
quality$Defect <- as.numeric(quality$Defect)
quality$CycleTimeSec <- as.numeric(quality$CycleTimeSec)
```

Periksa kembali:

```r
str(quality)
```

## 7. Data Manipulation dengan `dplyr`

`dplyr` menyediakan kata kerja yang mudah dibaca untuk mengolah data:

| Fungsi | Kegunaan |
| --- | --- |
| `select()` | memilih kolom |
| `filter()` | memilih baris berdasarkan kondisi |
| `mutate()` | membuat atau mengubah kolom |
| `arrange()` | mengurutkan baris |
| `distinct()` | mengambil nilai unik |
| `rename()` | mengganti nama kolom |
| `summarise()` | membuat ringkasan |
| `group_by()` | mengelompokkan data sebelum diringkas |
| `count()` | menghitung jumlah baris per kategori |
| `left_join()` | menggabungkan data berdasarkan kunci |

Mulai dengan:

```r
library(dplyr)
```

### 7.1 `select()`: memilih kolom

```r
quality |> select(InspectionDate, Line, Defect, Inspected)
```

Memilih semua kolom kecuali satu kolom:

```r
quality |> select(-Product)
```

Memilih kolom berdasarkan pola nama:

```r
quality |> select(contains("Defect"))
quality |> select(starts_with("Cycle"))
```

### 7.2 `filter()`: memilih baris

```r
quality |> filter(Line == "A")
quality |> filter(Defect > 5)
quality |> filter(Inspected >= 120)
```

Beberapa kondisi sekaligus:

```r
quality |> filter(Line == "A", Defect > 3)
quality |> filter(Line %in% c("A", "B"))
quality |> filter(DefectType != "NONE")
```

Mencari data tanggal tertentu:

```r
quality |> filter(InspectionDate >= as.Date("2026-07-15"))
```

### 7.3 `mutate()`: membuat kolom baru

```r
quality_clean <- quality |>
  mutate(
    DefectRate = Defect / Inspected,
    FirstPassYield = 1 - DefectRate
  )
```

Membuat label kualitas:

```r
quality_clean <- quality_clean |>
  mutate(
    QualityFlag = if_else(DefectRate > 0.05, "Above target", "On target")
  )
```

Membuat kolom bulan:

```r
quality_clean <- quality_clean |>
  mutate(
    Month = floor_date(InspectionDate, unit = "month")
  )
```

### 7.4 `arrange()`: mengurutkan data

```r
quality_clean |> arrange(DefectRate)
quality_clean |> arrange(desc(DefectRate))
quality_clean |> arrange(Line, desc(DefectRate))
```

### 7.5 `distinct()`: nilai unik

```r
quality |> distinct(Line)
quality |> distinct(Line, Product)
```

### 7.6 `rename()`: mengganti nama kolom

```r
quality_clean |>
  rename(
    Date = InspectionDate,
    LineName = Line
  )
```

### 7.7 `count()`: menghitung kategori

```r
quality |> count(Line)
quality |> count(DefectType, sort = TRUE)
quality |> count(Line, DefectType, sort = TRUE)
```

### 7.8 `summarise()`: statistik ringkas

```r
quality_clean |>
  summarise(
    TotalInspected = sum(Inspected),
    TotalDefect = sum(Defect),
    OverallDefectRate = TotalDefect / TotalInspected,
    AverageCycleTime = mean(CycleTimeSec)
  )
```

Gunakan `na.rm = TRUE` jika data dapat berisi nilai hilang:

```r
quality_clean |>
  summarise(
    AverageCycleTime = mean(CycleTimeSec, na.rm = TRUE),
    MaximumCycleTime = max(CycleTimeSec, na.rm = TRUE)
  )
```

### 7.9 `group_by()`: ringkasan per kelompok

Defect rate yang benar untuk agregasi adalah total defect dibagi total inspected, bukan sekadar rata-rata defect rate per baris.

```r
summary_by_line <- quality_clean |>
  group_by(Line) |>
  summarise(
    TotalInspected = sum(Inspected),
    TotalDefect = sum(Defect),
    DefectRate = TotalDefect / TotalInspected,
    AverageCycleTime = mean(CycleTimeSec, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(desc(DefectRate))

summary_by_line
```

Ringkasan per jenis defect:

```r
summary_by_defect <- quality_clean |>
  group_by(DefectType) |>
  summarise(
    TotalDefect = sum(Defect),
    TotalInspected = sum(Inspected),
    DefectRate = TotalDefect / TotalInspected,
    .groups = "drop"
  ) |>
  arrange(desc(DefectRate))
```

Ringkasan per lini dan jenis defect:

```r
quality_clean |>
  group_by(Line, DefectType) |>
  summarise(
    TotalDefect = sum(Defect),
    TotalInspected = sum(Inspected),
    DefectRate = TotalDefect / TotalInspected,
    .groups = "drop"
  ) |>
  arrange(desc(DefectRate))
```

### 7.10 Pipeline dengan pipe `|>`

Pipe meneruskan hasil dari kiri ke fungsi di kanan.

```r
quality |>
  filter(Line == "A") |>
  mutate(DefectRate = Defect / Inspected) |>
  select(InspectionDate, Line, DefectRate) |>
  arrange(desc(DefectRate))
```

Cara membaca kode tersebut:

1. ambil `quality`;
2. pilih lini A;
3. buat `DefectRate`;
4. pilih tiga kolom;
5. urutkan dari rate terbesar.

### 7.11 Cleaning lengkap

```r
quality_clean <- quality |>
  mutate(
    InspectionDate = as.Date(InspectionDate),
    Line = trimws(toupper(Line)),
    Product = trimws(Product),
    DefectType = trimws(DefectType),
    DefectType = if_else(
      is.na(DefectType) | DefectType == "",
      "NONE",
      DefectType
    ),
    Inspected = as.numeric(Inspected),
    Defect = as.numeric(Defect),
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

Validasi hasil cleaning:

```r
nrow(quality_clean)
summary(quality_clean$DefectRate)
any(quality_clean$Inspected <= 0)
any(quality_clean$Defect > quality_clean$Inspected)
any(quality_clean$DefectRate < 0 | quality_clean$DefectRate > 1)
```

Semua pemeriksaan `any()` di atas seharusnya menghasilkan `FALSE`.

## 8. Visualisasi dengan `ggplot2`

### 8.1 Struktur dasar

```r
library(ggplot2)

ggplot(data = quality_clean, aes(x = Line, y = DefectRate)) +
  geom_col()
```

- `data` adalah data yang digunakan.
- `aes()` menentukan hubungan kolom dengan sumbu atau warna.
- `geom_col()` menentukan bentuk grafik.

### 8.2 Bar chart

```r
ggplot(summary_by_line, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  labs(
    title = "Defect rate per lini",
    x = "Lini",
    y = "Defect rate"
  )
```

Format sebagai persentase:

```r
ggplot(summary_by_line, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Defect rate per lini")
```

### 8.3 Line chart

```r
trend_by_date <- quality_clean |>
  group_by(InspectionDate) |>
  summarise(
    TotalDefect = sum(Defect),
    TotalInspected = sum(Inspected),
    DefectRate = TotalDefect / TotalInspected,
    .groups = "drop"
  )

ggplot(trend_by_date, aes(x = InspectionDate, y = DefectRate)) +
  geom_line(color = "firebrick", linewidth = 1) +
  geom_point(color = "firebrick") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Tren defect rate", x = "Tanggal", y = "Defect rate")
```

Line chart per lini:

```r
trend_by_line <- quality_clean |>
  group_by(InspectionDate, Line) |>
  summarise(
    TotalDefect = sum(Defect),
    TotalInspected = sum(Inspected),
    DefectRate = TotalDefect / TotalInspected,
    .groups = "drop"
  )

ggplot(trend_by_line, aes(InspectionDate, DefectRate, color = Line)) +
  geom_line() +
  geom_point() +
  scale_y_continuous(labels = percent_format(accuracy = 0.1))
```

### 8.4 Scatter plot

```r
ggplot(quality_clean, aes(x = CycleTimeSec, y = DefectRate, color = Line)) +
  geom_point(size = 3, alpha = 0.7) +
  labs(
    title = "Hubungan cycle time dan defect rate",
    x = "Cycle time (detik)",
    y = "Defect rate"
  )
```

Tambahkan garis kecenderungan:

```r
ggplot(quality_clean, aes(x = CycleTimeSec, y = DefectRate)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Kecenderungan cycle time dan defect rate")
```

### 8.5 Boxplot

Boxplot membantu membandingkan sebaran cycle time antar lini.

```r
ggplot(quality_clean, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot() +
  labs(
    title = "Sebaran cycle time per lini",
    x = "Lini",
    y = "Cycle time (detik)"
  ) +
  theme_minimal()
```

Cara membaca boxplot:

- garis tengah adalah median;
- kotak menunjukkan kuartil pertama sampai kuartil ketiga;
- titik di luar whisker dapat menjadi kandidat outlier;
- kotak yang lebih tinggi menunjukkan variasi yang lebih besar.

## 9. Statistical Analysis

Statistik harus dimulai dari pertanyaan, bukan dari memilih uji secara acak.

| Pertanyaan | Analisis yang sesuai |
| --- | --- |
| Berapa rata-rata dan sebaran cycle time? | Statistik deskriptif |
| Apakah cycle time berbeda antara dua lini? | Uji t dua sampel |
| Apakah cycle time berbeda di tiga lini atau lebih? | ANOVA satu arah |
| Apakah cycle time berkaitan dengan defect rate? | Korelasi dan regresi |
| Jenis defect apa yang paling sering muncul? | Tabel frekuensi dan proporsi |

### 9.1 Statistik deskriptif

```r
quality_clean |>
  summarise(
    N = n(),
    MeanDefectRate = mean(DefectRate),
    MedianDefectRate = median(DefectRate),
    SDDefectRate = sd(DefectRate),
    MinDefectRate = min(DefectRate),
    MaxDefectRate = max(DefectRate)
  )
```

Statistik per lini:

```r
quality_clean |>
  group_by(Line) |>
  summarise(
    N = n(),
    MeanCycleTime = mean(CycleTimeSec),
    MedianCycleTime = median(CycleTimeSec),
    SDCycleTime = sd(CycleTimeSec),
    MeanDefectRate = mean(DefectRate),
    .groups = "drop"
  )
```

Kuartil:

```r
quantile(quality_clean$CycleTimeSec, probs = c(0.25, 0.5, 0.75))
```

### 9.2 Frekuensi dan proporsi defect

```r
defect_frequency <- quality_clean |>
  count(DefectType, name = "Rows") |>
  mutate(Proportion = Rows / sum(Rows)) |>
  arrange(desc(Rows))

defect_frequency
```

Untuk total unit defect per jenis defect:

```r
defect_summary <- quality_clean |>
  group_by(DefectType) |>
  summarise(
    TotalDefect = sum(Defect),
    TotalInspected = sum(Inspected),
    DefectRate = TotalDefect / TotalInspected,
    .groups = "drop"
  ) |>
  arrange(desc(TotalDefect))
```

Perhatikan perbedaan:

- jumlah baris menunjukkan seberapa sering kategori muncul;
- `TotalDefect` menunjukkan jumlah unit defect;
- `DefectRate` memperhitungkan jumlah unit yang diperiksa.

### 9.3 Korelasi

Korelasi Pearson mengukur hubungan linear antara dua variabel numerik.

```r
cor(
  quality_clean$CycleTimeSec,
  quality_clean$DefectRate,
  use = "complete.obs",
  method = "pearson"
)
```

Uji korelasi:

```r
cor.test(
  quality_clean$CycleTimeSec,
  quality_clean$DefectRate,
  method = "pearson"
)
```

Interpretasi koefisien korelasi `r` secara umum:

- mendekati `1`: hubungan positif kuat;
- mendekati `-1`: hubungan negatif kuat;
- mendekati `0`: hubungan linear lemah atau tidak ada.

Korelasi bukan bukti sebab-akibat. Cycle time yang tinggi dan defect rate yang tinggi dapat memiliki faktor penyebab lain yang belum diukur.

### 9.4 Uji t dua sampel

Pertanyaan contoh:

> Apakah rata-rata cycle time lini A berbeda dari lini B?

```r
line_ab <- quality_clean |>
  filter(Line %in% c("A", "B"))

t_test_result <- t.test(CycleTimeSec ~ Line, data = line_ab)
t_test_result
```

Hipotesis:

- H0: rata-rata cycle time lini A dan B sama.
- H1: rata-rata cycle time lini A dan B berbeda.

Interpretasi p-value:

- jika `p-value < 0.05`, terdapat bukti statistik untuk menolak H0;
- jika `p-value >= 0.05`, belum cukup bukti untuk menolak H0.

Jangan menyimpulkan “H0 terbukti benar” hanya karena p-value besar. Kesimpulan yang lebih tepat adalah “belum ada bukti yang cukup untuk menyatakan adanya perbedaan.”

### 9.5 ANOVA satu arah

Jika membandingkan tiga lini atau lebih, gunakan ANOVA.

```r
anova_model <- aov(CycleTimeSec ~ Line, data = quality_clean)
summary(anova_model)
```

Hipotesis:

- H0: semua rata-rata cycle time sama.
- H1: setidaknya ada satu rata-rata yang berbeda.

Jika hasil ANOVA signifikan, cari pasangan yang berbeda:

```r
TukeyHSD(anova_model)
```

Pemeriksaan visual:

```r
ggplot(quality_clean, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot() +
  theme_minimal()
```

Asumsi penting ANOVA:

- observasi relatif independen;
- residual mendekati normal;
- variasi antar kelompok relatif sebanding.

Pemeriksaan residual dasar:

```r
par(mfrow = c(2, 2))
plot(anova_model)
par(mfrow = c(1, 1))
```

### 9.6 Regresi linear sederhana

Pertanyaan contoh:

> Apakah cycle time dapat membantu menjelaskan variasi defect rate?

```r
regression_model <- lm(DefectRate ~ CycleTimeSec, data = quality_clean)
summary(regression_model)
```

Visualisasi garis regresi:

```r
ggplot(quality_clean, aes(x = CycleTimeSec, y = DefectRate)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  theme_minimal()
```

Prediksi untuk cycle time tertentu:

```r
new_data <- data.frame(CycleTimeSec = c(40, 45, 50))
predict(regression_model, newdata = new_data, interval = "confidence")
```

Hal yang perlu dibaca dari `summary()`:

- koefisien `CycleTimeSec`: perubahan rata-rata defect rate ketika cycle time naik satu detik;
- p-value koefisien: bukti statistik hubungan linear;
- `R-squared`: proporsi variasi defect rate yang dijelaskan model;
- residual standard error: ukuran kesalahan model.

Regresi tidak otomatis membuktikan bahwa cycle time menyebabkan defect. Gunakan bahasa “berhubungan” atau “membantu menjelaskan”, kecuali desain penelitian memang mendukung kesimpulan kausal.

## 10. Contoh Analisis Lengkap

Kode berikut menjalankan alur dari membaca data sampai menghasilkan kesimpulan ringkas.

```r
library(dplyr)
library(lubridate)

quality <- read.csv("quality_inspection.csv", stringsAsFactors = FALSE)

quality_clean <- quality |>
  mutate(
    InspectionDate = as.Date(InspectionDate),
    Line = trimws(toupper(Line)),
    DefectType = trimws(DefectType),
    DefectType = if_else(is.na(DefectType) | DefectType == "", "NONE", DefectType),
    Inspected = as.numeric(Inspected),
    Defect = as.numeric(Defect),
    CycleTimeSec = as.numeric(CycleTimeSec)
  ) |>
  filter(
    !is.na(InspectionDate),
    Inspected > 0,
    Defect >= 0,
    Defect <= Inspected
  ) |>
  mutate(
    DefectRate = Defect / Inspected,
    FirstPassYield = 1 - DefectRate,
    Month = floor_date(InspectionDate, "month")
  )

line_result <- quality_clean |>
  group_by(Line) |>
  summarise(
    TotalInspected = sum(Inspected),
    TotalDefect = sum(Defect),
    DefectRate = TotalDefect / TotalInspected,
    AverageCycleTime = mean(CycleTimeSec),
    .groups = "drop"
  ) |>
  arrange(desc(DefectRate))

line_result

best_priority <- line_result |>
  slice_max(DefectRate, n = 1)

best_priority
```

Contoh format insight:

> Lini yang perlu diprioritaskan adalah lini pada baris pertama `line_result` karena memiliki defect rate tertinggi. Validasi tambahan perlu dilakukan dengan melihat jenis defect dominan, tren bulanan, dan cycle time sebelum tindakan perbaikan ditetapkan.

Gunakan hasil aktual dari R saat menulis angka. Jangan menyalin contoh insight tanpa memeriksa output.

## 11. Export Hasil Analisis

Menyimpan data yang sudah dibersihkan:

```r
write.csv(quality_clean, "quality_inspection_clean.csv", row.names = FALSE)
```

Menyimpan ringkasan lini:

```r
write.csv(line_result, "quality_summary_by_line.csv", row.names = FALSE)
```

Menyimpan grafik:

```r
quality_plot <- ggplot(summary_by_line, aes(Line, DefectRate)) +
  geom_col()

ggsave(
  filename = "defect_rate_by_line.png",
  plot = quality_plot,
  width = 8,
  height = 5,
  dpi = 300
)
```

## 12. Kesalahan Umum dan Solusinya

### File tidak ditemukan

```r
getwd()
list.files()
```

Pastikan nama file dan folder benar.

### Kolom terbaca sebagai character

```r
str(quality)
quality$Defect <- as.numeric(quality$Defect)
```

Periksa apakah ada simbol atau teks yang mengganggu konversi.

### `object not found`

Pastikan objek sudah dibuat dan penulisannya sama persis:

```r
names(quality)
```

### `could not find function`

Panggil package:

```r
library(dplyr)
library(ggplot2)
```

### Hasil `mean()` menjadi `NA`

Gunakan:

```r
mean(quality$CycleTimeSec, na.rm = TRUE)
```

### Grafik kosong atau error

Periksa tipe data dan nama kolom:

```r
str(quality_clean)
names(quality_clean)
```

### RStudio terasa menyimpan hasil lama

Jalankan ulang dari atas secara berurutan. Untuk memulai sesi bersih:

```r
rm(list = ls())
```

Gunakan perintah tersebut dengan hati-hati karena menghapus semua objek di Environment.

## 13. Latihan Mandiri

### Level 1: Dasar

1. Hitung total `Inspected` seluruh data.
2. Hitung total `Defect` seluruh data.
3. Tampilkan hanya kolom `Line`, `Product`, dan `DefectType`.
4. Tampilkan data dengan `CycleTimeSec` lebih besar dari 45.
5. Tampilkan daftar lini yang unik.

### Level 2: Data manipulation

1. Buat kolom `DefectRate`.
2. Buat kolom `QualityFlag` dengan ambang 5%.
3. Hitung total inspected dan total defect per lini.
4. Urutkan lini dari defect rate terbesar.
5. Hitung jumlah data per jenis defect.
6. Buat ringkasan per `Line` dan `Product`.

### Level 3: Visualisasi

1. Buat bar chart defect rate per lini.
2. Buat line chart defect rate per tanggal.
3. Buat boxplot cycle time per lini.
4. Buat scatter plot cycle time dan defect rate.
5. Tambahkan judul, label sumbu, dan format persentase.

### Level 4: Statistical analysis

1. Bandingkan rata-rata cycle time lini A dan B dengan uji t.
2. Gunakan ANOVA untuk membandingkan cycle time semua lini.
3. Hitung korelasi cycle time dan defect rate.
4. Buat model regresi linear.
5. Tulis kesimpulan dengan menyebutkan ukuran efek, p-value, dan keterbatasan.

## 14. Checklist Penyelesaian

- [ ] R dan RStudio sudah terpasang.
- [ ] Package `dplyr`, `lubridate`, `ggplot2`, dan `scales` sudah terpasang.
- [ ] File CSV dapat dibaca.
- [ ] Tipe data sudah diperiksa.
- [ ] Missing value sudah diperiksa.
- [ ] Data invalid sudah difilter.
- [ ] Kolom `DefectRate` sudah dibuat.
- [ ] Ringkasan per lini sudah dibuat.
- [ ] Minimal tiga jenis grafik sudah dicoba.
- [ ] Statistik deskriptif sudah dihitung.
- [ ] Minimal satu analisis inferensial sudah dijalankan.
- [ ] Interpretasi tidak hanya menyebut p-value.
- [ ] Kesimpulan menyebutkan keterbatasan analisis.

## 15. Catatan Interpretasi

Dataset ini adalah dataset latihan dengan jumlah observasi terbatas. Hasil uji statistik digunakan untuk belajar alur analisis, bukan sebagai keputusan produksi final. Dalam kondisi nyata, pertimbangkan periode data yang lebih panjang, desain sampling, independensi observasi, ukuran sampel, faktor proses lain, dan validasi bersama ahli domain.
