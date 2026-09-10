# 📘 README Volume 1 — R Studio: Statistik & Visualisasi Data

> Proyek ini adalah **Volume 1** dari rangkaian pelatihan "Insight to Impact". Seluruh materi di folder ini berfokus pada analisis statistik dan visualisasi data menggunakan **R dan RStudio**, sebagai fondasi sebelum masuk ke materi **Volume 2 (Power BI)**.

---

## 1. Gambaran Umum Proyek

| Komponen | Keterangan |
| --- | --- |
| **Nama proyek** | Volume 1 — R Studio |
| **Topik materi** | Statistik dengan R Studio & Visualisasi data dengan R Studio |
| **Bahasa** | R, RStudio Desktop |
| **Package utama** | `dplyr`, `lubridate`, `ggplot2`, `scales`, `readr` |
| **Dataset** | `quality_inspection.csv` (latihan inspeksi kualitas) |
| **Luaran akhir** | Rangkaian skrip analisis statistik dan grafik `ggplot2` yang siap digunakan sebagai dasar proyek Power BI (Volume 2) |

Materi Volume 1 mencakup dua topik inti:

1. **Statistik dengan RStudio** — statistik deskriptif dan statistik inferensial (uji t, ANOVA, regresi linear), termasuk cara membaca dan menginterpretasikan **p-value** dan **R-squared**.
2. **Visualisasi data dengan RStudio** — teknik visualisasi dengan `ggplot2`, dari grafik sederhana sampai grafik multi-variabel untuk menyampaikan insight secara efektif.

### Cara Menggunakan Proyek Ini

1. Baca README ini secara berurutan dari Bab 1 sampai Bab 10.
2. Siapkan folder kerja sesuai Bab 3 (Struktur Folder Proyek).
3. Jalankan kode di RStudio baris per baris untuk memahami hasil setiap langkah.
4. Untuk setiap analisis statistik, latih menulis interpretasinya, **bukan hanya** menjalankan kode.
5. Hasil utama proyek (data bersih, ringkasan, dan grafik) akan menjadi input yang sama untuk dashboard di Volume 2.

---

## 2. Tujuan Pembelajaran

Setelah menyelesaikan Volume 1, Anda diharapkan mampu:

1. Menyiapkan lingkungan kerja R dan RStudio yang benar.
2. Membaca, memeriksa, dan membersihkan dataset.
3. Menghitung statistik deskriptif (mean, median, standar deviasi, kuartil).
4. Membuat uji inferensial yang tepat untuk pertanyaan bisnis:
   - **uji t dua sampel** untuk membandingkan 2 kelompok;
   - **ANOVA satu arah** untuk membandingkan 3 kelompok atau lebih;
   - **regresi linear sederhana** untuk hubungan antar variabel numerik.
5. Menginterpretasikan hasil statistik dengan benar (p-value, confidence interval, R-squared, koefisien).
6. Membuat berbagai jenis grafik dengan `ggplot2`: bar chart, line chart, scatter plot, dan boxplot.
7. Membuat grafik multi-variabel yang menyampaikan insight secara efektif.
8. Menyusun cerita/insight dari hasil analisis dengan bahasa bisnis yang jelas.
9. Menyimpan hasil analisis (data dan grafik) untuk dipakai di Power BI (Volume 2).

---

## 3. Prasyarat dan Instalasi

### 3.1 Instalasi R dan RStudio

| Software | URL | Keterangan |
| --- | --- | --- |
| R | <https://cran.r-project.org/> | Mesin yang menjalankan kode R |
| RStudio Desktop | <https://posit.co/download/rstudio-desktop/> | IDE/aplikasi untuk menulis kode, melihat data dan grafik, mengelola project |

### 3.2 Package R yang Digunakan

Jalankan sekali (hanya perlu sekali per instalasi):

```r
install.packages(c("dplyr", "lubridate", "ggplot2", "scales"))
```

Pada setiap sesi kerja baru, aktifkan package:

```r
library(dplyr)     # data manipulation
library(lubridate) # pengolahan tanggal
library(ggplot2)   # visualisasi
library(scales)    # format label (persentase, ribuan)
```

Baris `library(stats)` tidak perlu ditulis manual karena R sudah memuat `stats` secara default (berisi `t.test()`, `aov()`, `lm()`, `cor.test()`). Anda cukup menuliskan pustaka di atas.

### 3.3 Mengelola Folder Kerja

```r
getwd()               # melihat folder kerja saat ini
setwd("/folder/path") # mengubah folder kerja (pakai "/" atau "\\\\")
list.files()          # melihat isi folder
```

Di RStudio, cara paling disarankan: **File > New Project**, kemudian pilih folder proyek sehingga semua skrip dan data bisa diakses dengan path relatif (`"quality_inspection.csv"`).

> **Catatan Windows:** jangan gunakan `\` tunggal pada path (contoh salah: `setwd("C:\data")`). Gunakan `/` atau `\\` (contoh benar: `setwd("C:/data")`).

---

## 4. Struktur Folder Proyek

Folder `Volume 1 - R Studio` direncanakan dengan struktur berikut (Anda dapat menambahkan file sesuai kebutuhan):

```text
Volume 1 - R Studio/
├── README.md                 <- dokumen ini (materi lengkap)
├── data/
│   └── quality_inspection.csv  <- dataset latihan (copy dari folder induk)
├── scripts/
│   ├── 01_import_explore.R     <- membaca & memahami data
│   ├── 02_cleaning.R           <- pembersihan data dengan dplyr
│   ├── 03_descriptive_stats.R  <- statistik deskriptif
│   ├── 04_inferential_stats.R  <- uji t, ANOVA, regresi
│   ├── 05_visualization.R      <- semua grafik ggplot2
│   └── 06_export_results.R     <- menyimpan output analisis
├── output/
│   ├── quality_inspection_clean.csv
│   ├── quality_summary_by_line.csv
│   └── figures/                <- grafik PNG hasil ggsave()
└── reports/
    └── Catatan_Analisis.md     <- interpretasi hasil
```

**Kebiasaan yang dianjurkan** — beri nama angka pada setiap skrip (`01_`, `02_`, …) agar urutan eksekusi jelas, dan simpan semua keluaran (data bersih, ringkasan, grafik) di folder `output/` agar tidak tercampur dengan kode.

---

## 5. Dataset Proyek: `quality_inspection.csv`

Dataset ini berisi hasil inspeksi kualitas produksi pada beberapa lini. **Setiap baris mewakili satu hasil inspeksi** — kombinasi tanggal, lini, produk, dan jenis defect.

### 5.1 Struktur Kolom

| Kolom | Tipe | Keterangan |
| --- | --- | --- |
| `InspectionDate` | Date | Tanggal inspeksi |
| `Line` | Character/Factor | Lini produksi (misal A, B, C, …) |
| `Product` | Character | Nama produk yang diinspeksi |
| `DefectType` | Character | Jenis defect (isi kosong berarti tidak ada defect, akan dinormalisasi menjadi `NONE`) |
| `Inspected` | Numeric/Integer | Jumlah unit yang diperiksa |
| `Defect` | Numeric/Integer | Jumlah unit cacat |
| `CycleTimeSec` | Numeric | Waktu siklus dalam detik |

### 5.2 Membaca dan memahami dataset

```r
quality <- read.csv("quality_inspection.csv", stringsAsFactors = FALSE)

head(quality)     # 6 baris pertama
tail(quality)     # 6 baris terakhir
str(quality)      # struktur dan tipe masing-masing kolom
summary(quality)  # statistik ringkas tiap kolom
dim(quality)      # jumlah baris dan kolom
names(quality)    # nama kolom
colSums(is.na(quality))  # jumlah nilai hilang per kolom
```

Kategori unik:

```r
unique(quality$Line)
table(quality$Line)
table(quality$DefectType)
```

### 5.3 Pertanyaan yang harus dijawab saat eksplorasi data

1. Apakah jumlah baris sesuai dengan jumlah observasi yang diharapkan?
2. Apakah `InspectionDate` terbaca sebagai **Date** atau masih **character**?
3. Apakah `Inspected`, `Defect`, dan `CycleTimeSec` terbaca sebagai **numeric**?
4. Apakah ada nilai `NA` atau baris yang tidak valid (misal `Inspected <= 0`, `Defect > Inspected`)?
5. Apa saja kategori pada `Line`, `Product`, dan `DefectType`?

> **Penting:** Data yang tidak bersih akan merusak hasil statistik dan membuat grafik menyesatkan. Tahap eksplorasi di atas adalah fondasi seluruh proyek ini.

---

## 6. Modul Statistik — Konsep Dasar (Statistik Deskriptif vs Inferensial)

Sebelum memahami uji t, ANOVA, dan regresi, Anda perlu menguasai dua cabang utama statistik:

| Cabang | Pertanyaan | Contoh di dataset |
| --- | --- | --- |
| **Statistik deskriptif** | Mendeskripsikan data yang ada | Berapa rata-rata dan sebaran cycle time? |
| **Statistik inferensial** | Menyimpulkan populasi dari sampel | Apakah cycle time lini A berbeda dari lini B? |

> **Prinsip penting sepanjang materi:** statistik harus dimulai dari **pertanyaan**, bukan dari memilih uji secara acak. Pilih uji berdasarkan jenis variabel dan jumlah kelompok yang dibandingkan.

---

## 7. Modul Statistik 1 — Statistik Deskriptif

Statistik deskriptif menjawab pertanyaan "bagaimana data terlihat?" sebelum melakukan uji inferensial.

### 7.1 Statistik ringkas untuk seluruh data

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

### 7.2 Statistik per kelompok (lini)

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

### 7.3 Kuartil

```r
quantile(quality_clean$CycleTimeSec, probs = c(0.25, 0.5, 0.75))
```

### 7.4 Frekuensi dan proporsi defect

Ada tiga konsep penting yang berbeda:

- **jumlah baris** = seberapa sering kategori muncul;
- **`TotalDefect`** = jumlah unit defect;
- **`DefectRate`** = jumlah defect dibagi jumlah unit yang diperiksa.

```r
# Frekuensi kategori
defect_frequency <- quality_clean |>
  count(DefectType, name = "Rows") |>
  mutate(Proportion = Rows / sum(Rows)) |>
  arrange(desc(Rows))

# Total unit defect per jenis defect
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

> **Poin penting:** defect rate agregat dihitung sebagai **total defect dibagi total inspected**, bukan sekadar rata-rata defect rate per baris.

---

## 8. Modul Statistik 2 — Korelasi

### 8.1 Menghitung koefisien korelasi Pearson

```r
cor(
  quality_clean$CycleTimeSec,
  quality_clean$DefectRate,
  use = "complete.obs",
  method = "pearson"
)
```

### 8.2 Uji korelasi (dengan p-value)

```r
cor.test(
  quality_clean$CycleTimeSec,
  quality_clean$DefectRate,
  method = "pearson"
)
```

### 8.3 Interpretasi koefisien korelasi `r`

| Nilai `r` | Makna |
| --- | --- |
| Mendekati `+1` | Hubungan positif kuat (kedua variabel naik bersama) |
| Mendekati `-1` | Hubungan negatif kuat (satu naik, satu turun) |
| Mendekati `0` | Hubungan linear lemah atau tidak ada |

> **Catatan penting:** korelasi **bukan** bukti sebab-akibat. Cycle time tinggi dan defect rate tinggi bisa sama-sama dipengaruhi faktor lain yang belum diukur.

---

## 9. Modul Statistik 3 — Uji t Dua Sampel

### 9.1 Kapan memakai uji t?

Uji t dua sampel dipakai untuk membandingkan **rata-rata dua kelompok** yang independen.

**Pertanyaan contoh:** Apakah rata-rata cycle time lini A berbeda dari lini B?

### 9.2 Menyiapkan data dua kelompok

```r
line_ab <- quality_clean |>
  filter(Line %in% c("A", "B"))
```

### 9.3 Menjalankan uji t

```r
t_test_result <- t.test(CycleTimeSec ~ Line, data = line_ab)
t_test_result
```

### 9.4 Hipotesis

- **H0 (hipotesis nol):** rata-rata cycle time lini A dan B **sama**.
- **H1 (hipotesis alternatif):** rata-rata cycle time lini A dan B **berbeda**.

### 9.5 Cara membaca output

Output `t.test()` menampilkan beberapa bagian penting:

| Bagian | Arti |
| --- | --- |
| `t` | Statistik uji; semakin besar nilai absolutnya semakin jauh data dari H0 |
| `df` | Derajat kebebasan |
| `p-value` | Peluang memperoleh data seperti ini jika H0 benar |
| `mean of x`, `mean of y` | Rata-rata masing-masing kelompok |
| `95 percent confidence interval` | Rentang selisih rata-rata yang masuk akal; jika tidak memuat 0, selisih signifikan |

### 9.6 Interpretasi p-value (aturan umum)

- `p-value < 0.05` → **terdapat bukti statistik** untuk menolak H0 (dua kelompok berbeda).
- `p-value >= 0.05` → **belum cukup bukti** untuk menolak H0.

> **Kesalahan komunikasi yang harus dihindari:** jangan menyimpulkan "H0 terbukti benar" hanya karena p-value besar. Kesimpulan yang benar adalah: *"belum ada bukti yang cukup untuk menyatakan adanya perbedaan."*

### 9.7 Contoh interpretasi lengkap

> Rata-rata cycle time lini A adalah **X detik** dan lini B **Y detik**, dengan selisih **Z detik** (95% CI: [a, b]). Uji t menghasilkan p-value sebesar **p**, sehingga [terdapat / belum terdapat] perbedaan rata-rata cycle time yang signifikan antara kedua lini pada tingkat signifikansi 5%.

---

## 10. Modul Statistik 4 — ANOVA Satu Arah

### 10.1 Konsep ANOVA

ANOVA (Analysis of Variance) dipakai untuk membandingkan **rata-rata tiga kelompok atau lebih** sekaligus, tanpa harus melakukan banyak uji t berpasangan (yang meningkatkan risiko salah positif).

**Pertanyaan contoh:** Apakah cycle time berbeda di antara semua lini produksi?

### 10.2 Menjalankan ANOVA

```r
anova_model <- aov(CycleTimeSec ~ Line, data = quality_clean)
summary(anova_model)
```

### 10.3 Hipotesis

- **H0:** semua rata-rata cycle time **sama** antar lini.
- **H1:** **setidaknya satu** rata-rata lini berbeda dari yang lain.

### 10.4 Membaca output `summary(anova_model)`

| Bagian | Arti |
| --- | --- |
| `Df` | Derajat kebebasan untuk faktor (`Line`) dan residual |
| `Sum Sq` | Jumlah kuadrat (sum of squares) |
| `Mean Sq` | Rata-rata kuadrat = Sum Sq / Df |
| `F value` | Rasio variasi antar kelompok terhadap variasi dalam kelompok |
| `Pr(>F)` | p-value ANOVA |

Jika hasil ANOVA signifikan, kita hanya tahu "ada perbedaan". Untuk mencari **pasangan mana** yang berbeda, lakukan uji lanjutan **Tukey HSD**:

```r
TukeyHSD(anova_model)
```

### 10.5 Konfirmasi visual dengan boxplot

```r
ggplot(quality_clean, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot() +
  theme_minimal()
```

### 10.6 Asumsi penting ANOVA

1. Observasi relatif **independen** (tidak saling memengaruhi).
2. Residual mendekati **distribusi normal**.
3. Variansi antar kelompok relatif **sebanding** (homogen).

### 10.7 Pemeriksaan residual dasar

```r
par(mfrow = c(2, 2))
plot(anova_model)
par(mfrow = c(1, 1))
```

---

## 11. Modul Statistik 5 — Regresi Linear Sederhana

### 11.1 Konsep regresi linear

Regresi linear sederhana memodelkan hubungan **satu variabel prediktor (X)** terhadap **satu variabel respons (Y)**:

\[
Y = \beta_0 + \beta_1 X + \varepsilon
\]

- `β₀` = intersep (nilai Y saat X = 0);
- `β₁` = kemiringan/koefisien (perubahan rata-rata Y ketika X naik 1 satuan);
- `ε` = galat/error.

**Pertanyaan contoh:** Apakah cycle time dapat membantu menjelaskan variasi defect rate?

### 11.2 Menjalankan regresi

```r
regression_model <- lm(DefectRate ~ CycleTimeSec, data = quality_clean)
summary(regression_model)
```

### 11.3 Visualisasi garis regresi

```R
ggplot(quality_clean, aes(x = CycleTimeSec, y = DefectRate)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  theme_minimal()
```

### 11.4 Prediksi untuk nilai baru

```r
new_data <- data.frame(CycleTimeSec = c(40, 45, 50))
predict(regression_model, newdata = new_data, interval = "confidence")
```

### 11.5 Cara membaca output `summary()` — fokus pada empat bagian

| Bagian | Arti & cara membacanya |
| --- | --- |
| `Coefficients` → `Estimate` (intercept & `CycleTimeSec`) | Nilai `β₀` dan `β₁`. Koefisien `CycleTimeSec` menunjukkan berapa rata-rata defect rate berubah ketika cycle time naik 1 detik. |
| `Coefficients` → `Pr(>|t|)` | **p-value koefisien** — bukti statistik adanya hubungan linear. Jika `< 0.05`, prediktor signifikan. |
| `Multiple R-squared` | **R-squared** — proporsi variasi defect rate yang dijelaskan oleh model (antara 0 sampai 1; makin dekat ke 1 makin baik) |
| `Residual standard error` | Ukuran kesalahan rata-rata prediksi model dalam satuan Y |

### 11.6 Interpretasi p-value pada regresi

Sama seperti uji t dan ANOVA:

- `p-value` koefisien `< 0.05` → bukti statistik bahwa koefisien tidak sama dengan nol (hubungan ada);
- `p-value` koefisien `>= 0.05` → belum cukup bukti hubungan linear.

### 11.7 Interpretasi R-squared

- `R-squared = 0.85` → model menjelaskan **85% variasi** defect rate; sisanya 15% dijelaskan faktor lain/error.
- R-squared tinggi tidak otomatis berarti model benar atau kausal; periksa juga plot residual dan konteks bisnis.

### 11.8 Bahasa yang benar saat menyimpulkan

> 📢 **Catatan kritis:** regresi **tidak membuktikan sebab-akibat**. Gunakan bahasa *"berhubungan"* atau *"membantu menjelaskan"*, bukan *"menyebabkan"*, kecuali desain penelitian memang mendukung kesimpulan kausal.

**Contoh interpretasi lengkap:**

> Model regresi defect rate terhadap cycle time menghasilkan koefisien sebesar **β** (p-value = **p**), artinya setiap kenaikan cycle time 1 detik berhubungan dengan perubahan rata-rata defect rate sebesar **β**. Model menjelaskan **R-squared** proporsi variasi defect rate. Dengan p-value= **p**, hubungan ini [signifikan / belum signifikan] pada taraf 5%.

---

## 12. Memilih Uji yang Tepat (Peta Keputusan)

Gunakan tabel ini ketika menghadapi pertanyaan analisis:

| Pertanyaan | Variabel | Uji yang tepat |
| --- | --- | --- |
| Berapa rata-rata dan sebaran cycle time? | Numerik (1 grup) | Statistik deskriptif |
| Apakah cycle time berbeda antara dua lini? | Numerik × 2 kelompok | **Uji t dua sampel** |
| Apakah cycle time berbeda di tiga lini atau lebih? | Numerik × 3+ kelompok | **ANOVA satu arah** + Tukey HSD |
| Apakah cycle time berkaitan dengan defect rate? | Numerik × numerik | **Korelasi** dan **regresi linear** |
| Jenis defect apa yang paling sering muncul? | Kategorikal | Tabel frekuensi & proporsi |
| Bisakah cycle time memprediksi defect rate? | Numerik prediktor → numerik respons | **Regresi linear** |

### Ringkasan alur analisis statistik yang baik

1. **Tulis pertanyaan bisnis** dalam kalimat yang jelas.
2. **Eksplorasi data** (distribusi, missing values, outlier, kategori).
3. **Bersihkan data** sebelum membuat uji.
4. **Periksa asumsi** uji yang dipilih.
5. **Jalankan uji** dengan kode yang reproducible.
6. **Interpretasikan** angka (p-value, interval, ukuran efek) + konteks bisnis.
7. **Tuliskan keterbatasan** (ukuran sampel, desain, kausalitas).

---

# 🔆 BAGIAN VISUALISASI

## 13. Modul Visualisasi 1 — Struktur Dasar `ggplot2`

### 13.1 Konsep layer (lapisan)

`ggplot2` membangun grafik dengan **ditambahkan lapisan** menggunakan tanda `+`:

```r
ggplot(data = quality_clean, aes(x = Line, y = DefectRate)) +  # 1. data & aes (hubungan kolom)
  geom_col()                                                     # 2. bentuk grafik
```

- **`data`** → data frame yang dipakai.
- **`aes()`** (aesthetics) → menentukan hubungan kolom dengan sumbu (`x`, `y`), warna (`color`, `fill`), ukuran (`size`).
- **`geom_*()`** → bentuk visual: `geom_col()` (bar), `geom_line()` (garis), `geom_point()` (titik), `geom_boxplot()` (kotak), `geom_smooth()` (garis kecenderungan).

> **Catatan implementasi:** contoh pada modul ini memakai `geom_col()` (tersedia di ggplot2). Jika versi `ggplot2` Anda lebih lama, gunakan `geom_bar(stat = "identity")` atau lakukan agregasi sendiri sebelum plotting.

### 13.2 Bar chart (defect rate per lini)

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

ggplot(summary_by_line, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  labs(title = "Defect rate per lini", x = "Lini", y = "Defect rate")
```

Format sumbu Y sebagai persentase:

```r
ggplot(summary_by_line, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Defect rate per lini", x = "Lini", y = "Defect rate")
```

### 13.3 Line chart (tren per tanggal)

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

### 13.4 Scatter plot (hubungan dua variabel numerik)

```r
ggplot(quality_clean, aes(x = CycleTimeSec, y = DefectRate, color = Line)) +
  geom_point(size = 3, alpha = 0.7) +
  labs(
    title = "Hubungan cycle time dan defect rate",
    x = "Cycle time (detik)",
    y = "Defect rate"
  )
```

Ditambahkan garis kecenderungan:

```R
ggplot(quality_clean, aes(x = CycleTimeSec, y = DefectRate)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Kecenderungan cycle time dan defect rate")
```

### 13.5 Boxplot (sebaran per kelompok)

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

**Cara membaca boxplot:**

- garis tengah = **median**;
- kotak = **kuartil pertama sampai kuartil ketiga** (IQR);
- titik di luar whisker = kandidat **outlier**;
- kotak yang lebih tinggi = variasi lebih besar.

---

## 14. Modul Visualisasi 2 — Grafik Multi-Variabel

Grafik multi-variabel menyampaikan lebih dari dua dimensi data dalam satu gambar. `aes()` adalah kunci: setiap variabel tambahan dipetakan ke satu **estetika visual** (warna, ukuran, bentuk, grouping).

### 14.1 Warna (`color`/`fill`) = variabel kategorikal

```r
# Tren setiap lini dengan warna berbeda
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

### 14.2 Ukuran (`size`) = variabel numerik tambahan

```r
ggplot(plot_data, aes(x = InspectionDate, y = DefectRate, color = Line)) +
  geom_point(aes(size = Inspected), alpha = 0.75) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1))
```

Titik yang lebih besar menunjukkan lini dengan jumlah inspeksi lebih banyak — berguna untuk mengidentifikasi apakah defect rate tinggi "tertutupi" oleh volume inspeksi yang kecil.

### 14.3 Gabungan garis kecenderungan + titik (scatter + smooth)

```r
ggplot(plot_data, aes(x = InspectionDate, y = DefectRate, color = Line)) +
  geom_point(aes(size = Inspected), alpha = 0.75) +
  geom_smooth(method = "loess", se = FALSE, linewidth = 0.8) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(
    title = "Pola defect rate menurut waktu",
    x = "Tanggal inspeksi", y = "Defect rate",
    color = "Lini", size = "Unit diperiksa"
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")
```

**Cara baca visual ini:**

- titik menunjukkan nilai raw per inspeksi;
- garis `loess` menunjukkan kecenderungan rata-rata per lini;
- ukuran titik menunjukkan volume inspeksi;
- ambang/target dibaca bersama konteks — bila ada satu lini selalu di atas ambang, itu prioritas investigasi.

> **Catatan agregasi:** jika satu tanggal-lini memiliki beberapa baris, agregasikan data **sebelum** memasukkan ke ggplot (dengan `group_by` + `summarise`) agar titik/garis tidak menyesatkan.

### 14.4 Grafik multi-panel dengan `facet_wrap()`

Untuk kasus dengan banyak lini, gunakan satu panel per lini:

```r
ggplot(quality_clean, aes(x = InspectionDate, y = DefectRate)) +
  geom_line() +
  geom_point() +
  facet_wrap(~ Line) +
  theme_minimal()
```

Facet membagi grafik menjadi beberapa panel; setiap lini tampil di panel masing-masing sehingga tidak bergantung pada perbedaan warna.

---

## 15. Modul Visualisasi 3 — Labels, Theme, dan Menyimpan Grafik

### 15.1 Judul, label sumbu, dan legend dengan `labs()`

```r
labs(
  title = "Defect rate per lini",
  subtitle = "Data Januari-Juli 2026",
  x = "Lini",
  y = "Defect rate",
  color = "Lini",   # judul legend warna
  fill = "Lini",    # judul legend fill
  size = "Unit diperiksa"
)
```

### 15.2 Format persentase pada sumbu Y

```r
scale_y_continuous(labels = percent_format(accuracy = 0.1))
```

### 15.3 Theme

```r
theme_minimal()                # gaya minimal
theme_minimal(base_size = 11)  # dengan ukuran font dasar 11
theme(legend.position = "bottom")  # posisi legend
```

### 15.4 Menyimpan grafik dengan `ggsave()`

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

> `dpi = 300` berguna untuk laporan/kualitas print; 96–150 dipakai untuk dashboard layar.

---

## 16. Modul Visualisasi 4 — Prinsip Visualisasi yang Efektif

| Prinsip | Contoh penerapan |
| --- | --- |
| **1. Judul berbentuk pertanyaan** | "Lini mana paling perlu investigasi?" bukan "Defect rate by line" |
| **2. Sumbu penjelasan** | x = "Tanggal inspeksi", y = "Defect rate (%)" |
| **3. Mulai sumbu dari nol (bar chart)** | bar chart mulai dari nol agar proporsi tidak menyesatkan |
| **4. Gunakan warna secara bermakna** | warna hanya untuk kategori penting; jangan warna pelangi |
| **5. Batasi volume informasi** | agregasi + label, bukan 10.000 titik tanpa makna |
| **6. Ambang/target jelas** | garis dashed di defect rate 5% |
| **7. Legenda jelas** | label per lini dengan bahasa bisnis |
| **8. Grafik menjawab pertanyaan** | setiap visual harus bisa menjawab minimal satu pertanyaan bisnis |

---

## 17. Proyek Praktik Lengkap (Studi Kasus)

### 17.1 Tantangan

Bangun analisis lengkap yang menjawab:

> **"Lini dan jenis defect mana yang perlu diprioritaskan untuk perbaikan bulan berikutnya?"**

### 17.2 Alur kode lengkap (cara menulis kode reproducible)

```r
# --- 1. Membaca data ---
quality <- read.csv("quality_inspection.csv", stringsAsFactors = FALSE)

# --- 2. Cleaning dasar ---
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

# --- 3. Ringkasan per lini ---
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

# --- 4. Uji inferensial ---
line_ab <- quality_clean |> filter(Line %in% c("A", "B"))
t.test(CycleTimeSec ~ Line, data = line_ab)      # 2 lini

anova_model <- aov(CycleTimeSec ~ Line, data = quality_clean)
summary(anova_model)                              # 3+ lini
TukeyHSD(anova_model)

regression_model <- lm(DefectRate ~ CycleTimeSec, data = quality_clean)
summary(regression_model)                         # hubungan numerik

# --- 5. Visualisasi ---
summary_by_line <- line_result

ggplot(summary_by_line, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Defect rate per lini", x = "Lini", y = "Defect rate")

# --- 6. Export hasil ---
write.csv(quality_clean, "output/quality_inspection_clean.csv", row.names = FALSE)
write.csv(line_result, "output/quality_summary_by_line.csv", row.names = FALSE)
```

### 17.3 Template insight

> **Kondisi:** Lini/defect yang paling perlu perhatian adalah **….**
> **Bukti:** defect rate sebesar **…%** dengan p-value/tren **…**.
> **Tindakan:** prioritaskan investigasi **…** dengan **…**.

> ⚠️ Gunakan **hasil aktual dari R** saat menulis angka. Jangan menyalin contoh insight tanpa memeriksa output.

---

## 18. Checklist Penyelesaian Volume 1

- [ ] R dan RStudio terpasang.
- [ ] Package `dplyr`, `lubridate`, `ggplot2`, dan `scales` terpasang.
- [ ] File CSV dapat dibaca dan tipe data diperiksa (`str()`).
- [ ] Missing value dan data invalid sudah diperiksa dan difilter.
- [ ] Kolom `DefectRate` dan `FirstPassYield` sudah dibuat.
- [ ] Statistik deskriptif dihitung (mean, median, SD, kuartil).
- [ ] Frekuensi/proporsi jenis defect dihitung.
- [ ] Korelasi cycle time dan defect rate dihitung + interpretasi.
- [ ] Uji t dua sampel dijalankan + p-value diinterpretasikan.
- [ ] ANOVA dijalankan + Tukey HSD bila signifikan.
- [ ] Regresi linear dijalankan + koefisien, p-value, R-squared dibaca.
- [ ] Minimal 4 jenis grafik dibuat (bar, line, scatter, boxplot).
- [ ] Minimal 1 grafik multi-variabel dibuat (warna/ukuran/facet).
- [ ] Grafik dan data bersih diekspor ke `output/`.
- [ ] Interpretasi final menyebutkan p-value, ukuran efek, dan **keterbatasan**.

---

## 19. Kesalahan Umum dan Solusion (Troubleshooting)

| Kesalahan | Solusion |
| --- | --- |
| `could not find function` | Panggil package: `library(dplyr)`, `library(ggplot2)` |
| `object not found` | Periksa penulisan objek dan apakah sudah dibuat: `names(quality)` |
| File tidak ditemukan | `getwd()` dan `list.files()`; pastikan path dan nama file benar |
| Kolom terbaca sebagai character | Konversi tipe: `quality$Defect <- as.numeric(quality$Defect)` |
| Hasil `mean()` menjadi `NA` | Gunakan `mean(x, na.rm = TRUE)` |
| Grafik kosong/empty | Periksa `str()` dan `names()` — kolom/tipe data |
| `geom_col` tidak tersedia | Perbarui ggplot2: `install.packages("ggplot2")`, atau pakai `geom_bar(stat = "identity")` |
| RStudio masih menampilkan hasil lama | Jalankan dari atas berurutan, atau `rm(list = ls())` (hapus semua objek) |

---

## 20. Tips & Trik Volume 1

### 20.1 Statistik — pola paling sering

1. **Mulai dari pertanyaan**, bukan dari uji. Tabel Bab 12 membantu pilihan.
2. **Cek asumsi** sebelum uji: independensi observasi, distribusi residual, varianti sebanding.
3. **P-value kecil ≠ efek besar** — periksa juga ukuran selisih rata-rata dan CI.
4. **CI yang memuat 0** pada uji t → perbedaan belum signifikan.
5. Bila ANOVA signifikan, **Tukey HSD** memberi pasangan yang berbeda.
6. **Regresi**: baca koefisien, p-value, R-squared, pling residual.
7. **Prediksi**: `interval = "confidence"` untuk rata-rata, `"prediction"` untuk individuel.
8. **Korelasi =/= sebab-akibat**; gunaka bahasa "berhubungan".
9. **P-value besar ≠ H0 benar** — hanya "belum cukup bukti".
10. **Visual** (boxplot + smooth) harus gabung dengan uji — bukan sah.

### 20.2 Visualisasi — pola ggplot2 cepat

```r
# Plot + target + persentase
ggplot(summary_by_line, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = 0.05, linetype = "dashed", color = "red") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Lini mana paling perlu investigasi?", y = "Defect rate (%)") +
  theme_minimal()

# Multi-variabel: warna + ukuran + loess
ggplot(plot_data, aes(InspectionDate, DefectRate, color = Line)) +
  geom_point(aes(size = Inspected), alpha = 0.75) +
  geom_smooth(method = "loess", se = FALSE) +
  scale_y_continuous(labels = percent_format()) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")
```

### 20.3 Trik menghafal output model

| Output `summary(lm())` | Mah malum |
| --- | --- |
| `Pr(>|t|)` | p-value koefisien (uji t per prediktor) |
| `R-squared` | proporsi variansi dijelaskan |
| `Residual standard error` | kesalahan rata-rata model |
| `F-statistic` (ANOVA) | varians antar ÷ varians dalam |

---

## 21. Bank Latihan Volume 1 (Exercise Bank)

### 21.1 Statistik

1. Hitung statistik deskriptif per lini (`group_by(Line)` + `summarise`): n, mean, sd cycle time.
2. Hitung defect rate agregat per lini dan per jenis defect.
3. Uji t: apakah rata-rata cycle time lini A berbeda dari lini B? Tulis interpretasi.
4. ANOVA: apakah cycle time berbeda min um 3 lini? Periksa asumsi.
5. Regresi: cycle time membantu menjelaskan defect rate? Baca p-value & R².

### 21.2 Visualisasi

6. Bar chart defect rate per lini + garis target 5%.
7. Line chart tren defect rate per tanggal, per warna lini.
8. Scatter `CycleTimeSec` vs `DefectRate` + `geom_smooth("lm")`.
9. Boxplot cycle time per lini.
10. Facet `facet_wrap(~ Line)` line chart; simpan PNG.

### 21.3 Extra (lanjutan)

11. Prediksi defect rate untuk cycle time = c(40, 50, 60).
12. Cek residual model regresi (`plot(model)`).
13. Tulis 1 insight (kondisi-bukti-tindakan) dengan p-value dari hasil Anda.

---

## 22. Kunci Jawaban / Solusi

```r
# 1
quality_clean |>
  group_by(Line) |>
  summarise(
    n = n(),
    mean_ct = mean(CycleTimeSec, na.rm = TRUE),
    sd_ct = sd(CycleTimeSec, na.rm = TRUE),
    .groups = "drop"
  )

# 2
quality_clean |>
  group_by(Line) |>
  summarise(DefectRate = sum(Defect) / sum(Inspected), .groups = "drop") |>
  arrange(desc(DefectRate))

# 3
line_ab <- quality_clean |> filter(Line %in% c("A", "B"))
t.test(CycleTimeSec ~ Line, data = line_ab)

# 4
anova_model <- aov(CycleTimeSec ~ Line, data = quality_clean)
summary(anova_model)
TukeyHSD(anova_model)
plot(anova_model)

# 5
model <- lm(DefectRate ~ CycleTimeSec, data = quality_clean)
summary(model)

# 6
ggplot(summary_by_line, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = 0.05, linetype = "dashed", color = "red") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  theme_minimal()

# 7-10: pakai template Bab 13-15 README + `facet_wrap(~ Line)`.

# 11
new <- data.frame(CycleTimeSec = c(40, 50, 60))
predict(model, newdata = new, interval = "confidence")

# 12
par(mfrow = c(2, 2)); plot(anova_model); par(mfrow = c(1, 1))
```

---

## 23. Referensi Volume 1

| Berkas | Lokasi |
| --- | --- |
| **Cheatsheet Volume 1 (sintaks statistik + ggplot)** | `CHEATSHEET.md` (di folder ini) |
| Materi induk Basic R | `../README_Basic_R.md` |
| Volume 0 — Basic R | `../Volume 0 - Basic R/README.md` dan `CHEATSHEET.md` |
| Volume 2 — Power BI | `../Volume 2 - Power BI/README.md` dan `CHEATSHEET.md` |
| Dataset | `../quality_inspection.csv` |
| Skrip cleaning Power Query | `../quality_inspection_cleaning.R` |
| Statistik R docs | <https://stat.ethz.ch/R-manual/R-devel/library/stats/html/00_index.html> |
| ggplot2 | <https://ggplot2.tidyverse.org/> |

---

*README Volume 1 — Statistik inferensial + visualisasi untuk analisis yang reproducible dan insightful.*
