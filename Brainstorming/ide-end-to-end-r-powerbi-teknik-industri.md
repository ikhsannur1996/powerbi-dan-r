# Ide: Project End-to-End "R di Power BI" — Case Study Teknik Industri

- **Tanggal:** 2026-09-13
- **Status:** 💡 ide (menunggu keputusan)
- **Terkait:** Volume 0 (Basic R), Volume 1 (ggplot2), Volume 2 (Statistik Inferensial), R-Power BI, Archive (Volume 3–5)
- **Fokus:** R **Basic → Medium → Advanced** + implementasi **statistik** memakai `dplyr` & `ggplot2` saja

---

## 1. Masalah / Latar Belakang

Materi yang sudah ada bagus secara **terpisah-pisah**:

- Volume 0 mengajarkan sintaks dasar R.
- Volume 1 mengajarkan galeri `ggplot2`.
- Volume 2 mengajarkan statistik inferensial.
- R-Power BI mengajarkan *cara* memakai R di Power BI (konfigurasi, R di Power Query, R visual).

Yang **belum ada**: satu **project end-to-end** yang menyatukan semuanya dalam **satu studi kasus Teknik Industri** — dari data mentah → cleaning `dplyr` → analisis statistik → visual `ggplot2` → dashboard Power BI → rekomendasi manajerial.

Kebutuhan peserta (asisten lab ADRK / Teknik Industri) adalah **bukti bahwa R di Power BI benar-benar menyelesaikan masalah pabrik**, bukan sekadar demo sintaks.

---

## 2. Rekomendasi Case Study

### 2.1 Pilihan utama (rekomendasi): **"OEE & Mutu Lini Produksi"**

> **Pertanyaan bisnis:** *Lini/mesin/shift mana yang menurunkan OEE bulan ini, dan tindakan perbaikan apa yang paling berdampak?*

OEE (Overall Equipment Effectiveness) adalah metrik **paling khas Teknik Industri** dan secara alami memaksa tiga jenis analisis sekaligus:

| Pilar OEE | Data | Analisis | R yang dipakai |
| --- | --- | --- | --- |
| **Availability** | downtime, uptime | distribusi & tren | `dplyr` + `ggplot2` |
| **Performance** | cycle time, target output | capability, uji t/ANOVA | statistik inferensial |
| **Quality** | defect, inspected | SPC, uji proporsi | statistik + `ggplot2` |
| **OEE = A × P × Q** | gabungan | dekomposisi & Pareto | `dplyr` lanjutan |

**Mengapa ini yang terbaik:**
- Menyatukan **SPC** (kartu kontrol), **process capability** (Cp/Cpk), **uji hipotesis**, **regresi**, dan **visualisasi** — semua topik Volume 0–2.
- Angka OEE **dikenal manajemen** → rekomendasi mudah diterjemahkan ke aksi.
- Natural untuk dashboard Power BI (KPI + filter).

### 2.2 Alternatif (bila ingin lebih fokus)

| Opsi | Judul | Kekuatan | Kapan dipakai |
| --- | --- | --- | --- |
| B | **Pengendalian Kualitas & Process Capability** | SPC sangat dalam | bila audiens QC-heavy |
| C | **Peramalan Permintaan & Perencanaan Produksi** | time series | bila audiens PPIC |
| D | **Analisis Downtime & Preventive Maintenance** | MTBF/MTTR, Pareto | bila audiens maintenance |

> **Rekomendasi:** pakai **2.1** sebagai *project utama*, lalu sediakan **2.2-C** sebagai *mini-project* latihan mandiri (memakai mesin statistik yang sama).

---

## 3. Arsitektur End-to-End (alur project)

```text
[1] Data mentah (CSV)
      │
      ▼
[2] ETL / Cleaning  ──►  Power Query → Run R script (dplyr)
      │                  output = tabel bersih (CleanData)
      ▼
[3] Analisis statistik (RStudio, dplyr + base R)
      │   • deskriptif   • SPC        • capability
      │   • uji t        • ANOVA      • proporsi   • regresi
      ▼
[4] Visualisasi (ggplot2, dua tempat):
      │   (a) RStudio  → PNG untuk laporan
      │   (b) R visual → di kanvas Power BI (merespons filter)
      ▼
[5] Dashboard Power BI (KPI + native visual + R visual + slicer)
      │
      ▼
[6] Insight & Rekomendasi (kondisi → bukti → tindakan)
```

Inilah "end-to-end" yang dimaksud: **satu dataset → enam tahap → satu keputusan**.

---
## 4. Rekomendasi Level R: Basic → Medium → Advanced

Setiap level memakai **case study yang sama** tetapi menaikkan derajat kesulitan. Ini membuat peserta merasa "satu cerita, makin dalam" — bukan lompat topik.

### 4.1 Ringkasan tiga level

| Level | Fokus | Alat `dplyr` | Alat `ggplot2` | Kenapa ini IE |
| --- | --- | --- | --- | --- |
| 🟢 **Basic** | baca & ringkas data | `select`, `filter`, `mutate`, `arrange`, `count` | bar, line, scatter, boxplot | laporan harian produksi |
| 🟡 **Medium** | kelompok, gabung, pivot | `group_by`, `summarise`, `left_join`, `pivot_longer`, `case_when` | facet, `fct_reorder`, errorbar, heatmap | perbandingan lini/shift/mesin |
| 🔴 **Advanced** | model & kontrol proses | fungsi sendiri, `purrr::map`, `across`, jendela bergulir | `stat_function`, kartu kontrol, `patchwork` manual | SPC, capability, regresi, OEE |

### 4.2 🟢 BASIC — "Membaca & Merangkum Pabrik"

**Tujuan:** peserta bisa memuat data dan menjawab pertanyaan sederhana.

```r
library(dplyr)
library(ggplot2)

# 1. baca data hasil cleaning
data <- read.csv("data/produksi.csv")

# 2. ringkasan cepat
data |> select(Tanggal, Line, Output, Defect) |> head(10)
data |> filter(Line == "Line-A", Defect > 5)
data |> mutate(DefectRate = Defect / Output) |> arrange(desc(DefectRate))

# 3. visual dasar
ggplot(data, aes(x = Line, y = Output)) + geom_col()
ggplot(data, aes(x = Tanggal, y = Output)) + geom_line()
ggplot(data, aes(x = CycleTime, y = DefectRate)) + geom_point()
```

**Luaran Basic:** 4 visual sederhana + tabel ringkas. **Statistik:** mean, median, sd, min, max.

### 4.3 🟡 MEDIUM — "Membandingkan & Menggabungkan"

**Tujuan:** peserta bisa menjawab "apakah lini/shift ini memang berbeda?" dengan benar.

```r
# ringkasan per kelompok
per_line <- data |>
  group_by(Line, Shift) |>
  summarise(
    Output      = sum(Output),
    Defect      = sum(Defect),
    DefectRate  = Defect / Output,
    MeanCycle   = mean(CycleTime),
    .groups = "drop"
  )

# gabung dengan master mesin
data <- data |> left_join(master_mesin, by = "MachineID")

# pivot untuk visual
panjang <- data |> pivot_longer(c(Output, Defect), names_to = "Metrik", values_to = "Nilai")

# uji statistik
t.test(CycleTime ~ Shift, data = filter(data, Shift %in% c("Pagi","Sore")))
anova_fit <- aov(CycleTime ~ Line, data = data); summary(anova_fit); TukeyHSD(anova_fit)
cor.test(data$CycleTime, data$DefectRate)

# visual
ggplot(per_line, aes(x = fct_reorder(Line, DefectRate), y = DefectRate)) +
  geom_col(fill = "steelblue") + coord_flip()

ggplot(data, aes(x = Line, y = CycleTime, fill = Line)) +
  geom_boxplot() + facet_wrap(~ Shift)
```

**Luaran Medium:** tabel agregat + visual pembanding + **p-value & CI** yang diinterpretasikan.

### 4.4 🔴 ADVANCED — "Model, SPC & OEE"

**Tujuan:** peserta bisa membangun **kartu kontrol**, **capability**, **regresi**, dan **dekomposisi OEE**.

```r
# (a) Process capability manual (tanpa package qcc)
x <- data$CycleTime
cp  <- (60 - 35) / (6 * sd(x))                     # USL=60, LSL=35
cpk <- min((60 - mean(x)), (mean(x) - 35)) / (3 * sd(x))

# (b) Kartu kontrol X-bar (batas dihitung sendiri dengan dplyr)
spc <- data |>
  group_by(Tanggal) |>
  summarise(xbar = mean(CycleTime), s = sd(CycleTime), .groups = "drop") |>
  mutate(
    xbb = mean(xbar),
    UCL = xbb + 3 * mean(s) / sqrt(n()),
    LCL = xbb - 3 * mean(s) / sqrt(n()),
    OutOfControl = xbar > UCL | xbar < LCL
  )

# (c) Regresi berganda
model <- lm(DefectRate ~ CycleTime + DowntimeMin + Shift, data = data)
summary(model); broom::tidy(model); broom::glance(model)

# (d) Fungsi sendiri + purrr (analisis per mesin sekaligus)
hitung_oee <- function(df) {
  A <- sum(df$RunTime) / sum(df$PlannedTime)
  P <- (sum(df$Output) * df$IdealCycle[1]) / sum(df$RunTime)
  Q <- 1 - sum(df$Defect) / sum(df$Output)
  A * P * Q
}
oee <- data |> group_by(MachineID) |> nest() |>
  mutate(OEE = map_dbl(data, hitung_oee)) |> select(-data)

# (e) Visual lanjutan: kartu kontrol + dekomposisi
ggplot(spc, aes(x = Tanggal, y = xbar)) +
  geom_line() + geom_point(aes(color = OutOfControl), size = 2) +
  geom_hline(yintercept = spc$xbb) +
  geom_hline(yintercept = c(spc$UCL[1], spc$LCL[1]), linetype = "dashed", color = "red")
```

**Luaran Advanced:** nilai Cp/Cpk, kartu kontrol dengan titik out-of-control, koefisien regresi, dan **OEE per mesin**.

---

## 5. Implementasi Statistik: Peta `dplyr` ↔ `ggplot2`

Setiap topik statistik dipasangkan: **hitung dengan `dplyr`** → **gambarkan dengan `ggplot2`**. Kolom "Verifikasi" = cara memastikan angka benar.

| # | Topik statistik | Hitung (`dplyr`/base) | Gambar (`ggplot2`) | Verifikasi | Level |
| --- | --- | --- | --- | --- | --- |
| 1 | Deskriptif | `summarise(mean, sd, median, IQR)` | histogram, boxplot | bandingkan dgn RStudio | 🟢 |
| 2 | Distribusi | `quantile()`, `table()` | `geom_histogram`, `geom_density` | skewness kasar | 🟢 |
| 3 | Proporsi defect | `sum(Defect)/sum(Output)` | `geom_col` + `percent_format` | uji `prop.test` | 🟡 |
| 4 | Perbandingan 2 grup | `group_by` + `t.test` | boxplot + errorbar CI | cek `var.test` | 🟡 |
| 5 | Perbandingan ≥3 grup | `aov()` + `TukeyHSD` | boxplot + `facet_wrap` | eta² / Tukey plot | 🟡 |
| 6 | Hubungan antar variabel | `cor()`, `cor.test()` | scatter + `geom_smooth` | bandingkan Pearson vs Spearman | 🟡 |
| 7 | Regresi | `lm()`, `broom::tidy` | scatter + garis + `annotate(R²)` | cek `plot(model)` diagnostik | 🔴 |
| 8 | SPC (kartu kontrol) | rolling mean/SD dgn `mutate` | line + `geom_hline` UCL/LCL | aturan Nelson/Western Electric | 🔴 |
| 9 | Process capability | Cp/Cpk formula manual | histogram + garis LSL/USL | bandingkan dgn tabel Z | 🔴 |
| 10 | OEE | dekomposisi A×P×Q | bar bertumpuk / gauge tiruan | cek komponen ≤ 1 | 🔴 |

> **Prinsip pengajaran:** **jangan** langsung pakai package jadi (mis. `qcc`, `forecast`). Hitung manual dulu dengan `dplyr` supaya peserta **paham rumusnya**, baru tawarkan package sebagai "jalan pintas" (opsional).

---

## 6. Desain Dataset (rekomendasi)

Usulan **1 tabel fakta + 2 tabel dimensi**, ± 900–1.500 baris (cukup untuk demo, ringan untuk Power BI).

### 6.1 Tabel fakta — `data/produksi.csv`

| Kolom | Tipe | Keterangan |
| --- | --- | --- |
| `ProductionID` | teks | `PRD-00001` … |
| `Tanggal` | tanggal | 3–6 bulan, tanpa hari libur |
| `Shift` | kategori | Pagi / Sore / Malam |
| `Line` | kategori | Line-A / Line-B / Line-C |
| `MachineID` | kategori | M-01 … M-06 (join ke dimensi mesin) |
| `OperatorID` | kategori | OP01 … OP10 (join ke dimensi operator) |
| `Product` | kategori | Bracket / Housing / Shaft |
| `PlannedTime` | numerik | menit tersedia per shift |
| `RunTime` | numerik | menit mesin benar-benar jalan |
| `DowntimeMin` | numerik | PlannedTime − RunTime |
| `Output` | numerik | unit diproduksi |
| `Defect` | numerik | unit cacat |
| `IdealCycleSec` | numerik | cycle time ideal (untuk Performance) |
| `CycleTimeSec` | numerik | cycle time aktual |

### 6.2 Tabel dimensi

- `data/mesin.csv` → `MachineID`, `JenisMesin`, `TahunInstalasi`, `LineDefault`
- `data/operator.csv` → `OperatorID`, `NamaSamaran`, `LevelSkill`, `TanggalMasuk`

### 6.3 Pola yang sengaja ditanam (agar analisis menemukan sesuatu)

| Pola | Dampak | Terdeteksi oleh |
| --- | --- | --- |
| Satu mesin sering downtime | Availability turun | Pareto downtime, ANOVA |
| Shift Malam defect ↑ 1,5× | Quality turun | `prop.test`, chi-square |
| Satu operator skill rendah | Performance turun | perbandingan grup |
| Cycle time ↑ saat mesin panas | korelasi | `cor.test`, regresi |
| Tren perbaikan setelah tanggal X | improvement | kartu kontrol, tren |

> Ini mengikuti prinsip yang sudah dipakai di Archive Volume 4 (`set.seed`, pola ditanam) — jadi hasil `Rscript` **reproducible** dan selalu "menemukan" sesuatu untuk dibahas.

---

## 7. Integrasi Power BI (dua titik pemakaian R)

Mengacu ke modul **R-Power BI**, R dipakai di **dua tempat** — dan di project ini keduanya dipakai:

| | **R di Power Query** (`dplyr`) | **R visual** (`ggplot2`) |
| --- | --- | --- |
| Tujuan | cleaning + metrik turunan (persisten) | gambar yang merespons filter (tampilan) |
| Input | `dataset` | `dataset` (field di *Values*) |
| Output | `output` (tabel bersih) | gambar di kanvas |
| Isi project | hitung `DefectRate`, `OEE`, `Flag`, join dimensi | kartu kontrol, Pareto, boxplot, heatmap |
| Ini yang dijaga | reproducibility & konsistensi angka | visual yang tak ada di visual native |

### 7.1 Rencana `dplyr` di Power Query

```r
library(dplyr)

output <- dataset |>
  mutate(
    Tanggal   = as.Date(Tanggal),
    Line      = trimws(toupper(Line)),
    DowntimeMin = pmax(0, PlannedTime - RunTime),
    Availability = RunTime / PlannedTime,
    Performance  = (Output * IdealCycleSec / 60) / RunTime,
    Quality      = 1 - Defect / Output,
    DefectRate   = Defect / Output
  ) |>
  mutate(OEE = Availability * Performance * Quality,
         Flag = if_else(DefectRate > 0.05, "Above target", "On target")) |>
  filter(PlannedTime > 0, RunTime > 0, RunTime <= PlannedTime, Defect <= Output)

output   # WAJIB bernama 'output'
```

### 7.2 Rencana R visual `ggplot2`

```r
library(ggplot2); library(dplyr)

ringkas <- dataset |>
  group_by(Line) |>
  summarise(DefectRate = sum(Defect) / sum(Output), .groups = "drop")

ggplot(ringkas, aes(x = reorder(Line, DefectRate), y = DefectRate, fill = Line)) +
  geom_col() + coord_flip() +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(title = "Defect rate per lini", x = NULL) + theme_minimal()
```

### 7.3 Rencana Dashboard (minimal)

| Zona | Isi | Sumber |
| --- | --- | --- |
| KPI card | OEE, Availability, Performance, Quality | hitung `dplyr` di Power Query |
| Native visual | tren OEE harian, Pareto downtime | visual native |
| R visual | kartu kontrol, boxplot cycle time per lini | `ggplot2` |
| Slicer | Tanggal, Line, Shift | merespons semua visual |
| Insight box | kondisi → bukti → tindakan | ditulis peserta |

---

## 8. Struktur Folder Usulan (bila dipromosikan jadi Volume resmi)

```text
Volume 6 - R End-to-End Teknik Industri/     # nama usulan
├── README.md                     # format Volume 0 (tanpa cheatsheet)
├── R/
│   ├── 00_buat_data.R            # generator dataset (set.seed, pola ditanam)
│   ├── 01_basic_dplyr.R          # 🟢 level Basic
│   ├── 02_medium_statistik.R     # 🟡 level Medium (uji t, ANOVA, korelasi)
│   ├── 03_advanced_spc_oee.R     # 🔴 level Advanced (SPC, Cp/Cpk, regresi, OEE)
│   └── 04_visual_ggplot2.R       # galeri visual → output/*.png
├── data/
│   ├── produksi.csv              # tabel fakta
│   ├── mesin.csv                 # dimensi
│   └── operator.csv              # dimensi
├── output/
│   ├── V01_*.png … V20_*.png     # visual (muncul inline di README)
│   └── tbl_*.csv                 # tabel agregat
└── powerbi/
    └── panduan-dashboard.md      # langkah + skrip dplyr/ggplot2 siap tempel
```

> Struktur ini konsisten dengan Volume 1, 2, 4, dan R-Power BI — jadi pembaca tidak perlu belajar tata letak baru.

---

## 9. Roadmap Pengerjaan (usulan milestone)

| # | Milestone | Luaran | Estimasi |
| --- | --- | --- | --- |
| 1 | Kunci case study & dataset | `00_buat_data.R` jalan, 3 CSV | 0,5 hari |
| 2 | Skrip Basic | `01_basic_dplyr.R` + 4–5 visual | 0,5 hari |
| 3 | Skrip Medium + statistik | uji t, ANOVA, korelasi, agregat | 1 hari |
| 4 | Skrip Advanced | SPC, Cp/Cpk, regresi, OEE | 1,5 hari |
| 5 | Galeri `ggplot2` | 15–20 PNG konsisten | 1 hari |
| 6 | README (format Volume 0) | bab lengkap + gambar inline | 1,5 hari |
| 7 | Panduan Power BI | `powerbi/panduan-dashboard.md` | 0,5 hari |
| 8 | Validasi & commit | `Rscript` bersih tanpa warning | 0,5 hari |

Total ± **7 hari kerja** (fokus, tidak penuh).

---

## 10. Risiko & Catatan Teknis

| Risiko | Dampak | Mitigasi |
| --- | --- | --- |
| Package `qcc`/`forecast`/`car` **tidak terpasang** | skrip gagal di mesin ini | hitung SPC/capability manual dengan `dplyr` + base R |
| R tidak tersedia di Power BI Service (versi 4.3.3) | refresh gagal | samakan versi R; uji dulu di Desktop |
| R visual non-interaktif | cross-filter terbatas | agregasi di `dplyr`, sediakan visual native untuk interaksi |
| Data terlalu besar | timeout 5 menit / 150k baris | agregasi lebih awal (`summarise`) |
| Power BI Desktop tidak ada di macOS | tidak bisa demo penuh | demo pakai Windows/VM; RStudio tetap jalan di macOS |

---

## 11. Langkah Berikutnya (checklist)

- [ ] Setujui case study utama (§2.1) atau pilih alternatif (§2.2)
- [ ] Konfirmasi 3 level R (§4) sudah sesuai audiens
- [ ] Konfirmasi dataset (§6) & pola yang ditanam
- [ ] Tentukan nama volume resmi (`Volume 6 - ...`) bila naik dari Brainstorming
- [ ] Mulai milestone 1: tulis `00_buat_data.R`
- [ ] (Opsional) buat `.pbix` contoh + screenshot untuk README
- [ ] Validasi akhir: `Rscript` dari root tanpa warning → commit & push

---

## 12. Catatan / Referensi

- Modul internal: `R-Power BI/README.md`, `Volume 0 - Basic R`, `Volume 1 - Basic Visualization ggplot`, `Volume 2 - Statistics and Inferential Statistics`
- Pola generator data: `Archive/Volume 4 - Case Study End-to-End Analytics/R/00_buat_data.R`
- Microsoft Learn: [R in Power Query Editor](https://learn.microsoft.com/en-us/power-bi/connect-data/desktop-r-in-query-editor), [R visuals](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-r-visuals)
- Konsep OEE: Availability × Performance × Quality (Nakajima / TPM)

---

*Catatan ide — belum jadi materi resmi. Ubah sesuka hati sebelum dipromosikan ke folder Volume.*

