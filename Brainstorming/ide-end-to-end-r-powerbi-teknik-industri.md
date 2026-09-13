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

### 7.3 Rencana Dashboard (minimum **6 visual** + 4 KPI)

**Syarat minimal: 6 visual.** Desain ini menyiapkan **8 visual** (V1–V8) agar setiap pilar OEE dan setiap level R (§4) punya "panggung" sendiri — **6 di antaranya adalah R visual `ggplot2`**. Layout 2 baris × 4 kolom:

```text
┌───────────────────────────────────────────────────────────────────────────┐
│  [ KPI ] OEE 68.4% │ Availability 86.1% │ Performance 83.2% │ Quality 95.5%│  ← 4 kartu
├───────────────────────────────────────────────────────────────────────────┤
│  V1 Tren OEE harian             │  V2 Pareto downtime per mesin            │
│  (line + moving average)        │  (bar + garis kumulatif)                 │
├───────────────────────────────────────────────────────────────────────────┤
│  V3 Kartu kontrol defect rate   │  V4 Process capability cycle time        │
│  (line + UCL/LCL)               │  (histogram + LSL/USL)                   │
├───────────────────────────────────────────────────────────────────────────┤
│  V5 Heatmap Line × Shift        │  V6 Boxplot cycle time per lini          │
│  (defect rate)                  │  (sebaran + titik mean)                  │
├───────────────────────────────────────────────────────────────────────────┤
│  V7 Dekomposisi OEE (A×P×Q)     │  V8 Scatter cycle time vs defect         │
│  per lini (bar bertumpuk)       │  (titik + garis regresi)                 │
├───────────────────────────────────────────────────────────────────────────┤
│  ☑ Slicer: Tanggal │ Line │ Shift    │  💡 Insight box (kondisi→bukti→aksi) │
└───────────────────────────────────────────────────────────────────────────┘
```

### 7.4 Delapan Visual — Spesifikasi

| # | Judul | Jenis | Alat | Sumber data | Pertanyaan yang dijawab |
| --- | --- | --- | --- | --- | --- |
| **V1** | Tren OEE harian | line + moving average | native / `ggplot2` | agregat `Tanggal` | OEE membaik atau memburuk bulan ini? |
| **V2** | Pareto downtime per mesin | bar + garis kumulatif | `ggplot2` | `sum(DowntimeMin)` per `MachineID` | mesin mana penyumbang 80% downtime? |
| **V3** | Kartu kontrol defect rate | line + UCL/LCL | `ggplot2` | `X̄ ± 3σ` rolling | proses masih terkendali (in-control)? |
| **V4** | Process capability cycle time | histogram + LSL/USL | `ggplot2` | `CycleTimeSec` vs spec | proses mampu memenuhi spesifikasi (Cp/Cpk)? |
| **V5** | Heatmap Line × Shift | heatmap | `ggplot2` | defect rate matriks | kombinasi lini-shift mana paling merah? |
| **V6** | Boxplot cycle time per lini | boxplot + mean | `ggplot2` | `CycleTimeSec` per `Line` | apakah sebaran antar lini berbeda? |
| **V7** | Dekomposisi OEE (A×P×Q) | bar bertumpuk | `ggplot2` | komponen per `Line` | pilar mana yang menarik OEE turun? |
| **V8** | Scatter cycle time vs defect | titik + `geom_smooth` | `ggplot2` | 2 variabel numerik | apakah cycle time memprediksi defect? |

**Pembagian kerja yang disengaja:**

| Kelompok | Visual | Fungsi di dashboard |
| --- | --- | --- |
| **R visual** (`ggplot2`) | V2, V3, V4, V5, V7, V8 | visual yang **tidak ada** di visual native Power BI (Pareto kumulatif, kartu kontrol, capability, heatmap OEE) |
| **Native Power BI** | V1, V6 + 4 KPI + slicer | visual yang butuh **interaksi & cross-filter** cepat |

> **Aturan penting:** kolom yang dipakai R visual **harus dimasukkan ke bagian *Values*** agar R menerima data yang sudah terfilter slicer. Karena R visual non-interaktif, sediakan selalu **satu visual native pendamping** untuk kebutuhan drill-down.

### 7.5 Skrip `ggplot2` Siap Tempel (R visual)

Enam visual inti berikut **langsung bisa ditempel** ke panel R visual. Semua mengasumsikan `dataset` = data yang sudah difilter slicer.

**V2 — Pareto downtime per mesin**

```r
library(ggplot2); library(dplyr); library(scales)

pareto <- dataset |>
  group_by(MachineID) |>
  summarise(Downtime = sum(DowntimeMin), .groups = "drop") |>
  arrange(desc(Downtime)) |>
  mutate(
    Mesin    = factor(MachineID, levels = MachineID),
    Kumulatif = cumsum(Downtime) / sum(Downtime)
  )

ggplot(pareto, aes(x = Mesin)) +
  geom_col(aes(y = Downtime), fill = "steelblue") +
  geom_line(aes(y = Kumulatif * max(Downtime), group = 1),
            color = "darkred", linewidth = 1) +
  geom_point(aes(y = Kumulatif * max(Downtime)), color = "darkred") +
  scale_y_continuous(
    name = "Downtime (menit)",
    sec.axis = sec_axis(~ . / max(pareto$Downtime), labels = percent_format())
  ) +
  labs(title = "Pareto downtime per mesin", x = NULL) +
  theme_minimal(base_size = 11)
```

**V3 — Kartu kontrol defect rate (X̄ ± 3σ)**

```r
library(ggplot2); library(dplyr)

kk <- dataset |>
  group_by(Tanggal) |>
  summarise(DefectRate = sum(Defect) / sum(Output), .groups = "drop") |>
  mutate(CL  = mean(DefectRate),
         UCL = CL + 3 * sd(DefectRate),
         LCL = pmax(0, CL - 3 * sd(DefectRate)),
         Sinyal = DefectRate > UCL | DefectRate < LCL)

ggplot(kk, aes(x = Tanggal, y = DefectRate)) +
  geom_line(color = "grey30") +
  geom_point(aes(color = Sinyal), size = 2) +
  geom_hline(yintercept = kk$CL[1],  linetype = "solid",  color = "darkgreen") +
  geom_hline(yintercept = kk$UCL[1], linetype = "dashed", color = "darkred") +
  geom_hline(yintercept = kk$LCL[1], linetype = "dashed", color = "darkred") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  scale_color_manual(values = c(`FALSE` = "grey40", `TRUE` = "darkred")) +
  labs(title = "Kartu kontrol defect rate (X-bar)", x = NULL) +
  theme_minimal(base_size = 11)
```

**V4 — Process capability cycle time**

```r
library(ggplot2); library(dplyr); library(scales)

LSL <- 38; USL <- 52                      # batas spesifikasi (contoh)
ct  <- dataset$CycleTimeSec
Cp  <- (USL - LSL) / (6 * sd(ct))
Cpk <- min((USL - mean(ct)), (mean(ct) - LSL)) / (3 * sd(ct))

ggplot(dataset, aes(x = CycleTimeSec)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30,
                 fill = "steelblue", color = "white") +
  stat_function(fun = dnorm, args = list(mean = mean(ct), sd = sd(ct)),
                color = "black", linewidth = 0.8) +
  geom_vline(xintercept = c(LSL, USL), linetype = "dashed", color = "darkred") +
  annotate("text", x = USL, y = Inf, label = paste0("Cpk = ", round(Cpk, 2)),
           vjust = 2, hjust = 1.1, color = "darkred") +
  labs(title = "Process capability cycle time", x = "Cycle time (detik)", y = NULL) +
  theme_minimal(base_size = 11)
```

**V5 — Heatmap Line × Shift**

```r
library(ggplot2); library(dplyr); library(scales)

hm <- dataset |>
  group_by(Line, Shift) |>
  summarise(DefectRate = sum(Defect) / sum(Output), .groups = "drop")

ggplot(hm, aes(x = Shift, y = Line, fill = DefectRate)) +
  geom_tile(color = "white") +
  geom_text(aes(label = percent(DefectRate, accuracy = 0.1)), size = 3) +
  scale_fill_gradient(low = "#FFF5F0", high = "#C44E52") +
  labs(title = "Heatmap defect rate: Line x Shift", x = NULL, y = NULL, fill = NULL) +
  theme_minimal(base_size = 11)
```

**V6 — Boxplot cycle time per lini**

```r
library(ggplot2); library(dplyr)

ggplot(dataset, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot(alpha = 0.6, outlier.shape = NA) +
  geom_jitter(width = 0.12, alpha = 0.25, size = 1) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "white") +
  labs(title = "Sebaran cycle time per lini", x = "Lini", y = "Cycle time (detik)") +
  theme_minimal(base_size = 11)
```

**V7 — Dekomposisi OEE (A x P x Q) per lini**

```r
library(ggplot2); library(dplyr); library(tidyr); library(scales)

oee_long <- dataset |>
  group_by(Line) |>
  summarise(
    Availability = sum(RunTime) / sum(PlannedTime),
    Performance  = (sum(Output) * mean(IdealCycleSec) / 60) / sum(RunTime),
    Quality      = 1 - sum(Defect) / sum(Output),
    .groups = "drop"
  ) |>
  pivot_longer(-Line, names_to = "Pilar", values_to = "Nilai")

ggplot(oee_long, aes(x = Line, y = Nilai, fill = Pilar)) +
  geom_col(position = "dodge", width = 0.7) +
  geom_hline(yintercept = 0.85, linetype = "dashed", color = "grey40") +
  scale_y_continuous(labels = percent_format(accuracy = 1), limits = c(0, 1)) +
  labs(title = "Dekomposisi OEE per lini (target 85%)",
       x = "Lini", y = NULL, fill = "Pilar") +
  theme_minimal(base_size = 11)
```

**V8 — Scatter cycle time vs defect + regresi**

```r
library(ggplot2); library(dplyr); library(scales)

model <- lm(DefectRate ~ CycleTimeSec, data = dataset)
r2 <- summary(model)$r.squared

ggplot(dataset, aes(x = CycleTimeSec, y = DefectRate)) +
  geom_point(alpha = 0.4, color = "steelblue") +
  geom_smooth(method = "lm", formula = y ~ x, color = "darkred") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "Cycle time vs defect rate",
       subtitle = paste0("R-squared = ", round(r2, 3)),
       x = "Cycle time (detik)", y = "Defect rate") +
  theme_minimal(base_size = 11)
```

**V1 — Tren OEE harian** (native, tetapi versi `ggplot2` bila ingin R visual):

```r
library(ggplot2); library(dplyr); library(scales)

tren <- dataset |>
  group_by(Tanggal) |>
  summarise(OEE = (sum(RunTime)/sum(PlannedTime)) *
                  ((sum(Output)*mean(IdealCycleSec)/60)/sum(RunTime)) *
                  (1 - sum(Defect)/sum(Output)), .groups = "drop") |>
  mutate(MA7 = zoo::rollmean(OEE, k = 7, fill = NA, align = "right"))

ggplot(tren, aes(x = Tanggal)) +
  geom_line(aes(y = OEE), color = "grey60") +
  geom_line(aes(y = MA7), color = "steelblue", linewidth = 1.2) +
  geom_hline(yintercept = 0.85, linetype = "dashed", color = "darkred") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "Tren OEE harian + rata-rata bergulir 7 hari",
       x = NULL, y = "OEE") +
  theme_minimal(base_size = 11)
```

> **Ringkasan pemenuhan target:** **8 visual** (V1–V8) + **4 KPI card** + slicer + insight box. Enam di antaranya (V2, V3, V4, V5, V7, V8) adalah **R visual `ggplot2`**, melampaui syarat minimal 6 visual.
>
> **Catatan:** V1 memakai `zoo::rollmean`; bila paket `zoo` tidak terpasang, ganti dengan `stats::filter(OEE, rep(1/7, 7), sides = 1)` atau hitung manual dengan `dplyr` (rolling window).

---

## 8. Struktur Folder yang Diusulkan

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

