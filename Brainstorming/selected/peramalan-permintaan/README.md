# 📊 Peramalan Permintaan — Proyek End-to-End (Power BI + R)

> **Satu README lengkap** untuk proyek *Peramalan Permintaan — Versi Super Sederhana*:
> dokumentasi, **semua kode R** (inline), **semua output visual** (tentanam), dan **panduan
> dashboard Power BI** langkah-demi-langkah.
>
> Bahasa sehari-hari — **tidak perlu tau statistika** — hanya aritmetika dasar:
> *rata-rata, kali, dan membagi*.
>
> **Pertanyaan inti:** *Berapa permintaan bulan depan? Bilang kapan mesin tidak cukup?*

---

## 1. Gambaran Umum

| Komponen | Keterangan |
| --- | --- |
| **Nama proyek** | Peramalan Permintaan — Versi Super Sederhana (sumber: `Brainstorming/pilihan/03-peramalan-permintaan`) |
| **Metoda plan** | `rata-rata 3 bulan terakhir × angka bulan` — 1 metoda, tanpa istilah statistika |
| **Transformasi** | 100% R di **Power Query** (`dplyr`/`tidyr`) → tabel `ramalan` (+ cross join skenario what-if) |
| **Visualisasi** | 8 **R visual** `ggplot2` yang merespons slicer (star model terkoneksi) |
| **Model data** | fakt `ramalan` (180 baris) + dimensi `produk` (2) + `skenario` (3) — **semua terkoneksi** |
| **Dataset** | 2 produk × 24 bulan (2024–2025) → plan 6 bulan (2026 Jan–Jun) |
| **Bahasa dokumentasi** | Indonesia (bahasa sehari-hari) |

**Semua angka di file ini = hasil aktual dari `output/` (bukan perkiraan).**

### Prasyarat (R)

```r
install.packages(c("dplyr", "tidyr", "ggplot2", "scales"))
```

Power BI Desktop: **File > Options > Global > R scripting** → check instalasi R
(labeled: "Detected R home directories"). Semua sumber data → **Privacy = Public**.

> Power BI tidak meng-`library()` otomatis → setiap blok R di bawah ber `library()` sendiri.

---

## 2. Struktur Folder

```text
Brainstorming/selected/peramalan-permintaan/
├── README.md                     # file ini (dokumentasi + kode + gambar + panduan)
├── data/
│   ├── permintaan.csv            # fakta: 48 baris (2 produk x 24 bulan)
│   └── produk.csv                # dimensi produk (nama, harga, kapasitas)
├── R/
│   ├── 00_buat_data.R            # generator data (set.seed 20260913)
│   ├── powerquery_01_ramalan.R   # BLOK R -> Power Query -> tabel "ramalan"
│   ├── visual_R_powerbi.R        # 8 BLOK R visual (ggplot2)
│   └── 03_validasi.R             # jalan semua blok lokal -> output/
└── output/                       # ramalan.csv + V1..V8 PNG (pratinjau)
```

> **Single source of truth:** kode yang ditempel di Power BI **persis sama** dengan file `R/*`.
> `R/03_validasi.R` diekstrak kode itu dari marka `# >>> BLOK_*_START/END` lalu dijalan —
> jadi bila jalan di mac = jalan di Power BI. Kode dalam README file ini = **salinan persis file tersebut**.

---

## 3. Cara Menjalankan (validacja lokal, tanpa Power BI)

```bash
cd "Brainstorming/selected/peramalan-permintaan"
Rscript R/00_buat_data.R     # 1x: generate data (set.seed)
Rscript R/03_validasi.R      # jalan blok Power Query + 8 R visual -> output/
```

Luaran:

| File | Keterangan |
| --- | --- |
| `output/ramalan.csv` | 180 baris = (48 riwayat + 12 plan) × 3 skenario |
| `output/V1_kpi.png` … `V8_whatif.png` | pratinjau 8 R visual (lihat bab 10) |

Validacja aktual: **exit 0, 0 warning**, test filter 40 kombinasi → **ALL OK**.



---

## 4. Data: 2 Produk, 24 Bulan

| Produk | Kategori | HargaSatuan | Kapasitas 1 mesin (unit/bulan) | Tren (ditanam) |
| --- | --- | ---: | ---: | --- |
| **Produk A** | Minuman | Rp 12.000 | 7.000 | +1,0%/bulan (tumbuh) |
| **Produk B** | Makanan | Rp 15.000 | 3.800 | +0,4%/bulan (quasi stabil) |

Angka aktual:

| Metrik | Produk A | Produk B |
| --- | ---: | ---: |
| Total 2024 | 67.540 | 39.883 |
| Total 2025 | 76.290 (**+13,0%**) | 39.801 (**±0**) |
| Total riwayat 2024–25 | **223.514 unit** | — |

**Angka Bulan** (berapa × rata-rata produk): Desember contoh **1,4×** rata-rata;
Januari **0,7×** rata-rata (visual V5 & heatmap V6 mengecek pattern ini).

---

## 5. Metoda Plan — Sederhana (1 cara saja)

```text
PLAN bulan ke depan  =  rata-rata 3 bulan terakhir  ×  angka bulan
```

| Langkah | Perjelasan | Angka contoh (Produk A) |
| --- | --- | --- |
| 1. **Rata-rata 3 bulan terakhir** | rata-rata permintaan Okt–Des 2025 | ≈ 7.024 (level) |
| 2. **Angka bulan** | bulan Januari biasanya 0,7× rata-rata | 0,67 |
| 3. **PLAN Jan 2026** | `7.024 × 0,67` | **≈ 5.231 unit** |

### Cek metode ini (`CekPlan`)

Cara yang sama, tetapi 6 bulan lalu — kita cek *seberapa hampir plan vs aktual* di Jul–Des 2025:

| Produk | Rata-rata selisih (plan vs aktual) |
| --- | ---: |
| Produk A | **10,7%** |
| Produk B | **8,0%** |

Cara baca: "bila plan cara ini 6 bulan lalu, rata-rata selisih 8–11% — cukup baik untuk plan produksi."

---

## 6. Hasil & What-if (Skenario)

Slicer `Skenario` mengubah **faktor plan** (×0,90 / ×1,00 / ×1,10):

| Skenario | Faktor | Plan 2026 (unit) | Penjualan 2026 (Rp) | Mesin puncak A | Mesin puncak B |
| --- | ---: | ---: | ---: | ---: | ---: |
| **Pesimis** | ×0,90 | 55.058 | Rp 716,9 M | 2 | **1** |
| **Normal** | ×1,00 | 61.176 | Rp 796,5 M | **2** | **2** |
| **Optimis** | ×1,10 | 67.293 | Rp 876,2 M | **2** | **2** |

Cek cepat:

- Plan puncak **Produk A** (Normal) = **7.924** > kapasitas 7.000 → **butuh 2 mesin** (di semua skenario).
- Plan puncak **Produk B** (Normal) = **4.016** > 3.800 → **2 mesin**; di Pesimis 3.615 < 3.800 → **cukup 1**.
- **Plan bulan depan** Jan 2026 (Normal): Produk A **5.231** · Produk B **2.856**.


---

## 7. Kode: Generator Data (`R/00_buat_data.R`)

Jalan 1x: `Rscript R/00_buat_data.R` → `data/permintaan.csv` + `data/produk.csv` (reproducible, set.seed).

```r
# ============================================================
# Peramalan Permintaan - Versi Compact (proyek "selected")
# R/00_buat_data.R  --  generator data ringkas
#
# Case sederhana: 2 produk x 24 bulan (2024-2025) = 48 baris.
# Pola yang ditanam (set.seed):
#   * TREN naik per produk (Produk A +1,0%/bulan; Produk B +0,4%/bulan)
#   * MUSIMAN puncak Nov-Des (indeks 1,28 & 1,38) vs dasar Jan-Feb (0,82)
#   * noise normal ~ 7%
#
# Output: data/permintaan.csv  (fakta: Tanggal, Produk, Permintaan)
#         data/produk.csv      (dimensi: Kategori, Harga, Kapasitas, LeadTime)
# ============================================================

set.seed(20260913)

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
dir.create(file.path(base, "data"), showWarnings = FALSE)

bulan   <- seq(as.Date("2024-01-01"), as.Date("2025-12-01"), by = "month")
produk  <- c("Produk A", "Produk B")

# --- parameter dasar ---
base_qty <- c("Produk A" = 5000, "Produk B" = 3000)      # unit/bulan dasar
tren_p   <- c("Produk A" = 0.010, "Produk B" = 0.004)    # tren % per bulan
# indeks musiman per bulan kalender (1 = rata-rata; puncak Nov & Des)
musim <- c(0.82, 0.85, 0.93, 1.00, 1.08, 1.15, 1.10, 1.02, 1.04, 1.12, 1.28, 1.38)

df <- expand.grid(Tanggal = bulan, Produk = produk, stringsAsFactors = FALSE)
df <- df[order(df$Tanggal, df$Produk), ]

n        <- nrow(df)
bulan_ke <- as.integer(format(df$Tanggal, "%m"))
idx      <- (as.integer(format(df$Tanggal, "%Y")) - 2024) * 12 + bulan_ke

df$Permintaan <- round(
  base_qty[df$Produk] * (1 + tren_p[df$Produk]) ^ idx * musim[bulan_ke] * rnorm(n, 1, 0.07)
)
df$Permintaan <- pmax(df$Permintaan, 200)

# --- dimensi produk ---
produk_dim <- data.frame(
  Produk         = produk,
  Kategori       = c("Minuman", "Makanan"),
  HargaSatuan    = c(12000, 15000),      # Rp/unit
  KapasitasMesin = c(7000, 3800),        # unit/bulan per mesin
  LeadTimeHari   = c(7, 14),
  stringsAsFactors = FALSE
)

write.csv(df, file.path(base, "data", "permintaan.csv"), row.names = FALSE)
write.csv(produk_dim, file.path(base, "data", "produk.csv"), row.names = FALSE)

cat("permintaan.csv :", nrow(df), "baris x", ncol(df), "kolom\n")
cat("produk.csv     :", nrow(produk_dim), "baris x", ncol(produk_dim), "kolom\n\n")
cat("Total permintaan per tahun:\n")
print(tapply(df$Permintaan, format(df$Tanggal, "%Y"), sum))
cat("\nRata-rata per produk:\n")
print(round(tapply(df$Permintaan, df$Produk, mean)))
cat("\nPuncak musiman (indeks per bulan kalender):\n")
print(round(tapply(df$Permintaan, bulan_ke, mean) / mean(df$Permintaan), 2))
print(head(df, 4))
```

---

## 8. Kode: Transformasi di Power BI (R di Power Query)

Tempel kode ini di Power Query: **Home > Transform Data > (query `ramalan_sumber`) > Transform > Run R script**.

- **Input** `dataset` = gabungan `permintaan` + `produk` (Merge Queries by `Produk`).
- **Output** `output` = tabel **`ramalan`** (180 baris: riwayat + plan 2026 × 3 skenario).

Metoda dalam kode (komentar menjel di bahasa sehari-hari):

| Langkah R | Keterangan |
| --- | --- |
| `Rata3` | rata-rata 3 bulan terakhir per produk |
| `AngkaBulan` | "bulan ini biasanya …× rata-rata" (untuk PLAN 2026) |
| `CekPlan` | plan yang dibuat 6 bulan lalu (untuk visual **Cek**) — versi AngkaBulan 2024 |
| `Level` | rata-rata Okt–Des 2025 (level terbaru) |
| `Plan` | `Level × AngkaBulan` untuk 2026 Jan–Jun |
| cross join `Skenario` | Pesimis 0,90 / Normal 1,00 / Optimis 1,10 (what-if) |

### Blok R (`R/powerquery_01_ramalan.R`)

```r
# ============================================================
# BLOK R DI POWER QUERY #1  ->  tabel "ramalan"  (versi sederhana)
# ------------------------------------------------------------
# TEMPEL kode ini pada:  Home > Transform Data (Power Query) >
# sono "ramalan_sumber" > Transform > Run R script > OK
#
# INPUT  (variabel `dataset`, dibuat otomatis Power BI) =
#   hasil gabungan "permintaan" (kiri) + "produk" (kanan) by Produk
#   kolom: Tanggal, Produk, Permintaan, Kategori, HargaSatuan,
#          KapasitasMesin, LeadTimeHari
#
# OUTPUT (variabel `output`, nama WAHIB per Power BI) =
#   tabel "ramalan": riwayat (2024-2025) + PLAN 2026 (Jan-Jun)
#   x 3 skenario what-if (Pesimis / Normal / Optimis)
#
# METODE PLAN (sederhana, tanpa statistika):
#   1) AngkaBulan : bulan Desember biasanya 1,4x rata-rata produk;
#                   bulan Januari biasanya 0,7x rata-rata.
#                   (rata-rata bulan kalender : rata-rata produk)
#   2) Level      : rata-rata 3 bulan TERAKHIR (Okt-Des 2025)
#   3) PLAN bulan = Level x AngkaBulan
#   4) CekPlan    : PLAN yang dibuat 6 bulan lalu (Jul-Des 2025)
#                   memakai level 3 bulan sebelum x AngkaBulan(2024)
#                   -> untuk visual "Cek: Plan vs Aktual"
# ============================================================

# >>> BLOK_PQ_01_START
suppressMessages({
  library(dplyr)
  library(tidyr)
})

# ---------- 1. normalisasi & kolom dasar ----------
X <- dataset
X$Tanggal    <- as.Date(trimws(as.character(X$Tanggal)))
X$Produk     <- as.character(X$Produk)
X$Permintaan <- as.numeric(X$Permintaan)
X <- X[order(X$Produk, X$Tanggal), ]

X <- X |>
  mutate(
    Tahun      = as.integer(format(Tanggal, "%Y")),
    BulanKe    = as.integer(format(Tanggal, "%m")),
    NamaBulan  = month.abb[BulanKe],
    Jenis      = "Riwayat"          # vs "Plan" (bulan maju)
  )

# ---------- 2. rata-rata 3 bulan terakhir (Level per bulan) ----------
X <- X |>
  group_by(Produk) |>
  arrange(Tanggal) |>
  mutate(Rata3 = (lag(Permintaan, 1) + lag(Permintaan, 2) +
                    lag(Permintaan, 3)) / 3) |>
  ungroup()

# ---------- 3. Angka Bulan (indeks musiman), 2 versi ----------
# versi lengkap (2024+2025) -> untuk PLAN 2026
angka_full <- X |>
  group_by(Produk, BulanKe) |>
  summarise(rb = mean(Permintaan), .groups = "drop") |>
  group_by(Produk) |>
  mutate(AngkaBulan = rb / mean(rb)) |>
  ungroup() |>
  select(Produk, BulanKe, AngkaBulan)

# versi 2024 saja -> untuk CEK PLAN (bonkest 2025) tanpa "monyeji"
angka_2024 <- X |>
  filter(Tahun == 2024) |>
  group_by(Produk, BulanKe) |>
  summarise(rb = mean(Permintaan), .groups = "drop") |>
  group_by(Produk) |>
  mutate(Angka = rb / mean(rb)) |>
  ungroup() |>
  select(Produk, BulanKe, Angka)

# AngkaBulan untuk SEMUA baris (riwayat + plan)
X <- X |>
  left_join(angka_full, by = c("Produk", "BulanKe"))

# ---------- 4. CekPlan: plan yang dibuat 6 bulan luar -------------
X <- X |>
  left_join(angka_2024, by = c("Produk", "BulanKe")) |>
  mutate(CekPlan = ifelse(Tahun == 2025 & BulanKe >= 7,
                          Rata3 * Angka, NA_real_)) |>
  select(-Angka)

# ---------- 5. Level terbaru (rata-rata Okt-Des 2025) ----------
level_akhir <- X |>
  filter(Tahun == 2025, BulanKe >= 10) |>
  group_by(Produk) |>
  summarise(Level = mean(Permintaan), .groups = "drop")

# ---------- 6. PLAN maju: 2026 Jan-Jun per produk ----------
plan_grid <- expand.grid(
  Tanggal = seq(as.Date("2026-01-01"), as.Date("2026-06-01"), by = "month"),
  Produk  = c("Produk A", "Produk B"),
  stringsAsFactors = FALSE
) |>
  mutate(
    Tahun     = 2026L,
    BulanKe   = as.integer(format(Tanggal, "%m")),
    NamaBulan = month.abb[as.integer(format(Tanggal, "%m"))],
    Jenis     = "Plan"
  ) |>
  left_join(angka_full, by = c("Produk", "BulanKe")) |>
  left_join(level_akhir, by = "Produk") |>
  mutate(Plan = Level * AngkaBulan) |>
  select(-Level)

# dimensi produk (dari input original)
dims <- X |>
  select(Produk, Kategori, HargaSatuan, KapasitasMesin) |>
  distinct()

plan_grid <- plan_grid |>
  left_join(dims, by = "Produk") |>
  mutate(Permintaan = NA_real_, Rata3 = NA_real_, CekPlan = NA_real_)

# ---------- 7. gabung riwayat + plan, lalu skenario what-if ----------
kols <- c("Tanggal", "Tahun", "BulanKe", "NamaBulan", "Produk", "Kategori",
          "HargaSatuan", "KapasitasMesin", "Jenis", "Permintaan",
          "CekPlan", "Plan", "AngkaBulan")

tbl <- bind_rows(
  X          |> select(any_of(kols)),
  plan_grid  |> select(any_of(kols))
)

skenario <- data.frame(
  Skenario      = c("Pesimis", "Normal", "Optimis"),
  FaktorSkenario = c(0.90, 1.00, 1.10),
  stringsAsFactors = FALSE
)

output <- tbl |>
  crossing(skenario) |>
  arrange(Produk, Tanggal, Skenario) |>
  select(all_of(c(kols, "Skenario", "FaktorSkenario")))
# >>> BLOK_PQ_01_END
```

> Set **Privacy = Public** pada step skrip; Power BI mengenali variabel luaran `output` → query
> `ramalan`. Kolom `Tanggal` = **Date**; `Perintaan`/`Plan`/`CekPlan`/`AngkaBulan`/`FaktorSkenario` = **Decimal**.

---

## 9. Kode: 8 R Visual (ggplot2)

Tempel setiap blok di satu **R visual**: klik ikon **R** (Visualization pane) → **Enable script visuals** →
tarik field ke **Values** (numerik = **Do not summarize**) → tempel blok → **Run script**.

| # | R visual | Field di Values | BLOK | Keterangan |
| --- | --- | --- | --- | --- |
| V1 | Ringkasan (KPI) | `Produk, Jenis, Tanggal, Permintaan, Plan, CekPlan, FaktorSkenario, Skenario, HargaSatuan, KapasitasMesin` | `BLOK_RV_V1` | 4 angka: total riwayat · plan 2026 · selisih rata-rata · mesin |
| V2 | Tren riwayat & plan | `Tanggal, Produk, Jenis, Permintaan, Plan, FaktorSkenario, Skenario` | `BLOK_RV_V2` | garis penuh = real; garis putus = plan per skenario |
| V3 | Plan bulan depan | `Jenis, Produk, Tanggal, Plan, FaktorSkenario, Skenario` | `BLOK_RV_V3` | 1 angka: plan Jan 2026 per produk |
| V4 | Cek: plan vs aktual | `Jenis, Tanggal, Produk, Permintaan, CekPlan` | `BLOK_RV_V4` | plan 6 bulan lalu vs aktual (Jul–Des 2025) |
| V5 | Angka bulan | `Produk, BulanKe, AngkaBulan` | `BLOK_RV_V5` | "Desember biasanya 1,4× rata-rata" |
| V6 | Heatmap tahun×bulan | `Jenis, Tanggal, Permintaan` | `BLOK_RV_V6` | kapan permintaan paling tinggi |
| V7 | Kapasitas vs puncak | `Jenis, Produk, Tanggal, Skenario, FaktorSkenario, Plan, KapasitasMesin` | `BLOK_RV_V7` | bar > garis kapasitas = butuh mesin tambahan |
| V8 | Tabel what-if | `Jenis, Tanggal, Produk, Skenario, FaktorSkenario, Plan, HargaSatuan, KapasitasMesin` | `BLOK_RV_V8` | skenario row: plan unit · Rp · mesin |

### File blok (`R/visual_R_powerbi.R`) — 8 blok dalam 1 file

```r
# ============================================================
# VISUAL R POWER BI (ggplot2) — versi sederhana (8 blok)
# ------------------------------------------------------------
# Tempel setiap blok di satu **R visual** Power BI. Field barbut
# di "Values" (rekomen: do not summarize) dijelaskan di komentar.
#
# METODE yang digunakan (sederhana):
#   PLAN = rata-rata 3 bulan terakhir x "angka bulan"
# CekPlan = plan yang dibuat 6 bulan luar (untuk visual Cek).
#
# Kunci filter: blok hanya membaca `dataset` (baris yang sudah
# terfilter slicer) -> setiap gambar ikut slicer Produk / Skenario.
# ============================================================

# ------------------------------------------------------------
# V1 - RINGKASAN (KPI)
# Field di Values: Produk, Jenis, Tanggal, Permintaan, Plan,
#                  CekPlan, FaktorSkenario, Skenario, HargaSatuan,
#                  KapasitasMesin
# ------------------------------------------------------------
# >>> BLOK_RV_V1_START
suppressMessages({ library(ggplot2); library(dplyr); library(scales) })
Tgl <- dataset$Tanggal
Tanggal <- if (is.numeric(Tgl)) as.Date(unclass(Tgl), origin = "1970-01-01") else as.Date(as.character(Tgl))
D <- dataset |> mutate(Tanggal = Tanggal)

if (nrow(D) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data untuk filter ini", size = 7) +
    theme_void()
} else {
  # satu skenario yang ditampilkan (Pesimis -> Normal -> Optimis)
  sk <- D |> distinct(Skenario, FaktorSkenario) |> arrange(FaktorSkenario)
  sk_sel <- as.character(sk$Skenario[1]); f <- sk$FaktorSkenario[1]

  hist <- D |>
    filter(Jenis == "Riwayat") |>
    distinct(Tanggal, Produk, Permintaan) |>
    summarise(Total = sum(Permintaan, na.rm = TRUE), .groups = "drop")

  plan <- D |>
    filter(Jenis == "Plan", Skenario == sk_sel) |>
    distinct(Tanggal, Produk, HargaSatuan, Plan) |>
    mutate(Hasil = Plan * f) |>
    summarise(TotalUnit = sum(Hasil, na.rm = TRUE), .groups = "drop")

  cek <- D |>
    filter(!is.na(CekPlan)) |>
    distinct(Tanggal, Produk, Permintaan, CekPlan) |>
    summarise(k = mean(abs(Permintaan - CekPlan) / Permintaan) * 100,
              .groups = "drop")

  if (nrow(D |> filter(Jenis == "Plan")) == 0) {
    mesin <- data.frame(Keb = 0)
  } else {
    mesin <- D |>
      filter(Jenis == "Plan", Skenario == sk_sel) |>
      distinct(Tanggal, Produk, KapasitasMesin, Plan) |>
      mutate(Hasil = Plan * f) |>
      group_by(Produk, KapasitasMesin) |>
      summarise(Puncak = max(Hasil, na.rm = TRUE), .groups = "drop") |>
      mutate(Keb = ceiling(Puncak / KapasitasMesin))
  }

  fmt <- function(x) format(round(x), big.mark = ".", decimal.mark = ",")
  k_cek <- if (nrow(cek) == 0 || is.na(cek$k[1])) NA_real_ else cek$k[1]
  kpi <- data.frame(
    Label = c("Total Riwayat\n2024-2025 (unit)",
              "Plan 2026\n6 Bulan (unit)",
              "Rata-rata Selisih\nPlan vs Aktual",
              "Mesin saat Puncak\n(Plan 2026)"),
    Nilai = c(fmt(hist$Total), fmt(plan$TotalUnit),
              ifelse(is.na(k_cek), "\u2014", sprintf("%.1f%%", k_cek)),
              paste0(sum(mesin$Keb, na.rm = TRUE), " mesin")),
    stringsAsFactors = FALSE
  )
  kpi$Label <- factor(kpi$Label, levels = as.character(kpi$Label))

  p <- ggplot(kpi, aes(x = 0.5, y = 0.5, label = Nilai)) +
    geom_text(size = 7, fontface = "bold") +
    facet_wrap(~Label) +
    labs(title = "Ringkasan Peramalan (Sederhana)",
         subtitle = sprintf("Skenario: %s (x%.2f) | Metode: rata-rata 3 bulan x angka bulan",
                            sk_sel, f)) +
    theme_void(base_size = 13) +
    theme(strip.text = element_text(face = "bold", size = 9),
          plot.title = element_text(face = "bold", hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5, color = "grey40", size = 8.5))
}
p
# >>> BLOK_RV_V1_END

# ------------------------------------------------------------
# V2 - TREN: RIWAYAT vs PLAN
# Field di Values: Tanggal, Produk, Jenis, Permintaan, Plan,
#                  FaktorSkenario, Skenario
# ------------------------------------------------------------
# >>> BLOK_RV_V2_START
suppressMessages({ library(ggplot2); library(dplyr); library(scales) })
Tgl <- dataset$Tanggal
Tanggal <- if (is.numeric(Tgl)) as.Date(unclass(Tgl), origin = "1970-01-01") else as.Date(as.character(Tgl))
D <- dataset |>
  mutate(Tanggal = Tanggal,
         Nilai   = ifelse(Jenis == "Plan", Plan * FaktorSkenario, Permintaan))

if (nrow(D) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data untuk filter ini", size = 7) +
    theme_void()
} else {
  aktual <- D |> filter(Jenis == "Riwayat") |> distinct(Tanggal, Produk, Permintaan)
  plan   <- D |> filter(Jenis == "Plan") |>
    distinct(Tanggal, Produk, Skenario, Nilai) |>
    mutate(Skenario = factor(Skenario, levels = c("Pesimis", "Normal", "Optimis")))

  p <- ggplot() +
    geom_line(data = aktual, aes(Tanggal, Permintaan),
              color = "grey30", linewidth = 0.9, na.rm = TRUE) +
    geom_line(data = plan, aes(Tanggal, Nilai, color = Skenario),
              linewidth = 0.9, linetype = "dashed", na.rm = TRUE) +
    geom_vline(xintercept = as.Date("2026-01-01"),
               linetype = "dotted", color = "grey50") +
    facet_wrap(~Produk, scales = "free_y") +
    scale_y_continuous(labels = label_comma()) +
    scale_x_date(date_labels = "%b %Y", date_breaks = "3 months") +
    labs(title = "Permintaan & Plan 2026",
         subtitle = "Garis penuh = permintaan; garis putus = plan (uwekeh skenario what-if)",
         x = NULL, y = "Unit") +
    theme_minimal(base_size = 12) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8))
}
p
# >>> BLOK_RV_V2_END

# ------------------------------------------------------------
# V3 - PLAN BULAN DEPAN per Produk (Jan 2026)
# Field di Values: Jenis, Produk, Tanggal, Plan, FaktorSkenario,
#                  Skenario
# ------------------------------------------------------------
# >>> BLOK_RV_V3_START
suppressMessages({ library(ggplot2); library(dplyr); library(scales) })
Tgl <- dataset$Tanggal
Tanggal <- if (is.numeric(Tgl)) as.Date(unclass(Tgl), origin = "1970-01-01") else as.Date(as.character(Tgl))
D <- dataset |> mutate(Tanggal = Tanggal)

if (nrow(D) == 0 || nrow(D |> filter(Jenis == "Plan")) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data plan (cek filter Tahun/Bulan)", size = 6) +
    theme_void()
} else {
  bd <- D |>
    filter(Jenis == "Plan", Tanggal == as.Date("2026-01-01")) |>
    distinct(Produk, Skenario, FaktorSkenario, Plan) |>
    mutate(Hasil = Plan * FaktorSkenario,
           Skenario = factor(Skenario, levels = c("Pesimis", "Normal", "Optimis")))

  p <- ggplot(bd, aes(Produk, Hasil, fill = Skenario)) +
    geom_col(position = position_dodge2(0.7), width = 0.7) +
    geom_text(aes(label = label_comma()(round(Hasil))),
              position = position_dodge2(0.7), vjust = -0.5, size = 3) +
    scale_fill_manual(values = c(Pesimis = "#7fae8c", Normal = "steelblue",
                                 Optimis = "#C44E52"),
                      name = "Skenario") +
    scale_y_continuous(labels = label_comma()) +
    labs(title = "Plan Bulan Depan (Jan 2026) per Produk",
         subtitle = "Metode: rata-rata Okt-Des 2025 x angka bulan Januari",
         x = NULL, y = "Plan (unit)") +
    theme_minimal(base_size = 12)
}
p
# >>> BLOK_RV_V3_END

# ------------------------------------------------------------
# V4 - CEK: PLAN vs AKTUAL (Jul-Des 2025)
# Field di Values: Jenis, Tanggal, Produk, Permintaan, CekPlan
# ------------------------------------------------------------
# >>> BLOK_RV_V4_START
suppressMessages({ library(ggplot2); library(dplyr); library(tidyr) })
Tgl <- dataset$Tanggal
Tanggal <- if (is.numeric(Tgl)) as.Date(unclass(Tgl), origin = "1970-01-01") else as.Date(as.character(Tgl))
D <- dataset |> mutate(Tanggal = Tanggal)

if (nrow(D) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data untuk filter ini", size = 7) +
    theme_void()
} else {
  cek <- D |>
    filter(!is.na(CekPlan)) |>
    distinct(Tanggal, Produk, Permintaan, CekPlan) |>
    mutate(NM = factor(month.abb[as.integer(format(Tanggal, "%m"))],
                       levels = month.abb)) |>
    select(Produk, NM, Aktual = Permintaan, Plan = CekPlan) |>
    pivot_longer(c(Aktual, Plan), names_to = "Seri", values_to = "Unit")

  p <- ggplot(cek, aes(NM, Unit, fill = Seri)) +
    geom_col(position = position_dodge2(0.8), width = 0.75) +
    facet_wrap(~Produk, scales = "free_y") +
    scale_fill_manual(values = c(Aktual = "grey30", Plan = "steelblue"),
                      name = NULL) +
    scale_y_continuous(labels = label_comma()) +
    labs(title = "Cek: Plan vs Aktual (Jul-Des 2025)",
         subtitle = "Cara kita plan, seberapa hampir 6 bulan lalu? Metode sama, 6 bulan luar",
         x = NULL, y = "Unit") +
    theme_minimal(base_size = 12)
}
p
# >>> BLOK_RV_V4_END

# ------------------------------------------------------------
# V5 - ANGKA BULAN (berapa x rata-rata)
# Field di Values: Produk, BulanKe, AngkaBulan
# ------------------------------------------------------------
# >>> BLOK_RV_V5_START
suppressMessages({ library(ggplot2); library(dplyr) })
D <- dataset |> distinct(Produk, BulanKe, AngkaBulan)

if (nrow(D) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data untuk filter ini", size = 7) +
    theme_void()
} else {
  D <- D |>
    mutate(NM   = factor(month.abb[BulanKe], levels = month.abb),
           Naik = AngkaBulan > 1)
  p <- ggplot(D, aes(NM, AngkaBulan, fill = Naik)) +
    geom_col(width = 0.75) +
    geom_hline(yintercept = 1, linetype = "dashed", color = "grey40") +
    geom_text(aes(label = sprintf("%.2f", AngkaBulan)), vjust = -0.5, size = 2.6) +
    facet_wrap(~Produk) +
    scale_fill_manual(values = c(`TRUE` = "#C44E52", `FALSE` = "steelblue"),
                      guide = "none") +
    labs(title = "Angka Bulan (berapa x rata-rata produk)",
         subtitle = "Desember biasanya 1,4x rata-rata; Januari 0,7x rata-rata",
         x = NULL, y = "Angka bulan (1 = rata-rata)") +
    theme_minimal(base_size = 12) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8))
}
p
# >>> BLOK_RV_V5_END

# ------------------------------------------------------------
# V6 - HEATMAP Tahun x Bulan (permintaan riwayat)
# Field di Values: Jenis, Tanggal, Permintaan
# ------------------------------------------------------------
# >>> BLOK_RV_V6_START
suppressMessages({ library(ggplot2); library(dplyr); library(scales) })
Tgl <- dataset$Tanggal
Tanggal <- if (is.numeric(Tgl)) as.Date(unclass(Tgl), origin = "1970-01-01") else as.Date(as.character(Tgl))
D <- dataset |> mutate(Tanggal = Tanggal)

if (nrow(D) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data untuk filter ini", size = 7) +
    theme_void()
} else {
  hm <- D |>
    filter(Jenis == "Riwayat") |>
    distinct(Tanggal, Permintaan) |>
    mutate(Tahun = as.integer(format(Tanggal, "%Y")),
           BN    = as.integer(format(Tanggal, "%m")),
           NM    = factor(month.abb[BN], levels = month.abb)) |>
    group_by(Tahun, NM) |>
    summarise(Total = sum(Permintaan, na.rm = TRUE), .groups = "drop")

  p <- ggplot(hm, aes(NM, factor(Tahun), fill = Total)) +
    geom_tile(color = "white", linewidth = 0.4) +
    geom_text(aes(label = label_comma()(Total)), size = 3.4, color = "white") +
    scale_fill_gradient(low = "#dbe9f6", high = "#08306b", labels = label_comma()) +
    labs(title = "Kapan Permintaan paling tinggi? (Tahun x Bulan)",
         subtitle = "Nov-Des konsisten paling tinggi di kedua tahun",
         x = NULL, y = NULL, fill = "Unit") +
    theme_minimal(base_size = 12)
}
p
# >>> BLOK_RV_V6_END

# ------------------------------------------------------------
# V7 - KAPASITAS vs PUNCAK PLAN
# Field di Values: Jenis, Produk, Tanggal, Skenario,
#                  FaktorSkenario, Plan, KapasitasMesin
# ------------------------------------------------------------
# >>> BLOK_RV_V7_START
suppressMessages({ library(ggplot2); library(dplyr); library(scales) })
D <- dataset

if (nrow(D) == 0 || nrow(D |> filter(Jenis == "Plan")) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data plan (cek filter Tahun/Bulan)", size = 6) +
    theme_void()
} else {
  peak <- D |>
    filter(Jenis == "Plan") |>
    distinct(Tanggal, Produk, Skenario, FaktorSkenario, Plan, KapasitasMesin) |>
    mutate(Hasil = Plan * FaktorSkenario,
           Skenario = factor(Skenario, levels = c("Pesimis", "Normal", "Optimis"))) |>
    group_by(Produk, Skenario, KapasitasMesin) |>
    summarise(Puncak = max(Hasil, na.rm = TRUE), .groups = "drop")
  kap <- distinct(peak, Produk, KapasitasMesin)

  p <- ggplot(peak, aes(Skenario, Puncak, fill = Skenario)) +
    geom_col(width = 0.65) +
    geom_hline(data = kap, aes(yintercept = KapasitasMesin),
               linetype = "dashed", color = "grey40") +
    geom_text(aes(label = label_comma()(round(Puncak))), vjust = -1.1, size = 3.2) +
    facet_wrap(~Produk, scales = "free_y") +
    scale_fill_manual(values = c(Pesimis = "#7fae8c", Normal = "steelblue",
                                 Optimis = "#C44E52"), guide = "none") +
    labs(title = "Puncak Plan (Jan-Jun 2026) vs Kapasitas 1 Mesin",
         subtitle = "Garis putus = kapasitas 1 mesin. Bar > garis = butuh mesin tambahan.",
         x = "Skenario", y = "Puncak plan (unit)") +
    theme_minimal(base_size = 12)
}
p
# >>> BLOK_RV_V7_END

# ------------------------------------------------------------
# V8 - TABEL WHAT-IF (skenario)
# Field di Values: Jenis, Tanggal, Produk, Skenario,
#                  FaktorSkenario, Plan, HargaSatuan, KapasitasMesin
# ------------------------------------------------------------
# >>> BLOK_RV_V8_START
suppressMessages({ library(ggplot2); library(dplyr) })
D <- dataset |> arrange(Tanggal, Produk)

if (nrow(D) == 0 || nrow(D |> filter(Jenis == "Plan")) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data plan (cek filter Tahun/Bulan)", size = 6) +
    theme_void()
} else {
  ram <- D |>
    filter(Jenis == "Plan") |>
    distinct(Tanggal, Produk, Skenario, FaktorSkenario, Plan, HargaSatuan) |>
    mutate(Hasil = Plan * FaktorSkenario) |>
    group_by(Skenario) |>
    summarise(TotalUnit = sum(Hasil, na.rm = TRUE),
              TotalRp   = sum(Hasil * HargaSatuan, na.rm = TRUE),
              .groups = "drop")

  mesin <- D |>
    filter(Jenis == "Plan") |>
    distinct(Tanggal, Produk, Skenario, FaktorSkenario, Plan, KapasitasMesin) |>
    mutate(Hasil = Plan * FaktorSkenario) |>
    group_by(Skenario, Produk, KapasitasMesin) |>
    summarise(Puncak = max(Hasil, na.rm = TRUE), .groups = "drop") |>
    mutate(Keb = ceiling(Puncak / KapasitasMesin)) |>
    group_by(Skenario) |>
    summarise(Mesin = paste0(Produk, "=", Keb, collapse = ", "), .groups = "drop")

  t2 <- ram |>
    left_join(mesin, by = "Skenario") |>
    mutate(Skenario = factor(Skenario, levels = c("Pesimis", "Normal", "Optimis"))) |>
    arrange(Skenario) |>
    mutate(TotalUnit = format(round(TotalUnit), big.mark = ".", decimal.mark = ","),
           TotalRp   = paste0("Rp ",
                              format(round(TotalRp), big.mark = ".", decimal.mark = ",")))

  hdr <- c("Skenario", "Plan 2026 (unit)", "Nilai Penjualan (Rp)", "Mesin saat Puncak")
  tbl <- t2 |>
    mutate(across(everything(), as.character)) |>
    as.data.frame()
  colnames(tbl) <- hdr
  K <- ncol(tbl); R <- nrow(tbl)
  dd <- data.frame(
    x    = rep(seq_len(K), each = R + 1),
    y    = rep(seq(R + 1, 1), times = K),
    teks = as.character(t(as.matrix(rbind(hdr, tbl)))),
    stringsAsFactors = FALSE
  )
  dd$fondo <- ifelse(dd$y == R + 1, "bold", "plain")

  p <- ggplot(dd, aes(x, y, label = teks, fontface = fondo)) +
    geom_text(size = 5) +
    scale_x_continuous(limits = c(0.4, K + 0.6)) +
    scale_y_continuous(limits = c(0.4, R + 1.6)) +
    labs(title = "What-if: Skenario Plan 2026",
         subtitle = "Optimis = +10% plan; Pesimis = -10%. Slicer Produk/Bulan ikut tabel.") +
    theme_void(base_size = 13) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
          plot.subtitle = element_text(hjust = 0.5, color = "grey40", size = 9))
}
p
# >>> BLOK_RV_V8_END
```

> Kunci filter: blok membaca `dataset` (baris yang sudah terfilter slicer) → pakai `distinct()`/
> `group_by()` sebelum summing (kerena baris skenario berulang) → gambar merespons slicer.
> Guard `if (nrow(dataset) == 0)` → tidak error saat filter kosong.


---

## 10. Output Visual (Pratinjau)

Gambar di bawah = hasil dirender pi `R/03_validasi.R` (kode **persis** yang ditempel di R visual).
In Power BI setiap gambar akan merespons slicer Produk / Skenario / Tahun / NamaBulan.

### V1 — Ringkasan (KPI)

![V1 — Ringkasan (KPI)](output/V1_kpi.png)

### V2 — Tren riwayat & plan 2026

![V2 — Tren riwayat & plan](output/V2_tren.png)

### V3 — Plan bulan depan (Jan 2026) per produk

![V3 — Plan bulan depan](output/V3_planbulan.png)

### V4 — Cek: plan vs aktual (Jul–Des 2025)

![V4 — Cek plan vs aktual](output/V4_cek.png)

### V5 — Angka bulan (berapa × rata-rata)

![V5 — Angka bulan](output/V5_angkabulan.png)

### V6 — Heatmap tahun × bulan

![V6 — Heatmap](output/V6_heatmap.png)

### V7 — Kapasitas vs puncak plan

![V7 — Kapasitas vs puncak](output/V7_kapasitas.png)

### V8 — Tabel what-if (skenario)

![V8 — Tabel what-if](output/V8_whatif.png)


---

## 11. Kode: Validacja Lokal (`R/03_validasi.R`)

Jalan dari root proyek: `Rscript R/03_validasi.R`

- Simulasii gabungan Power Query (`permintaan` + `produk` → `dataset`),
- dijalan **BLOK_PQ_01** (transformasi → `ramalan`),
- dijalan **BLOK_RV_V1…V8** (8 gambar → `output/V*.png`),
- stdout ringkasan angka key (plan per skenario, selisih, mesin).

```r
# ============================================================
# R/03_validasi.R  --  VALIDACIA end-to-end (lokal, tanpa Power BI)
# ------------------------------------------------------------
# Skrip ini menjalankan kode R yang SAMA PERSIS dengan blok yang
# ditempel di Power BI:
#   * BLOK_PQ_01  (Power Query -> tabel ramalan)
#   * BLOK_RV_V1..V8 (R visual -> 8 gambar ggplot2)
# Hasil: output/ramalan.csv + output/V*.png (pratinjau)
# ============================================================

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
out  <- file.path(base, "output"); dir.create(out, showWarnings = FALSE)
setwd(base)

extr <- function(path, tag) {
  txt <- readLines(path, warn = FALSE)
  a <- grep(sprintf("# >>> %s_START", tag), txt)
  b <- grep(sprintf("# >>> %s_END",   tag), txt)
  if (!length(a) || !length(b)) stop("Blok ", tag, " tidak ditempuh di ", path)
  paste(txt[(a[1] + 1):(b[1] - 1)], collapse = "\n")
}

jalan <- function(blok, env, tag) {
  tryCatch({
    res <- eval(parse(text = blok), env)
    if (is.null(res)) stop("Blok ", tag, " tidak menghasilkan objek")
    res
  }, error = function(e) {
    stop("ERROR di blok ", tag, ": ", conditionMessage(e))
  })
}

# ---------- 1. simulasii gabungan Power Query (permintaan + produk) ----------
suppressMessages({ library(dplyr); library(tidyr) })

permintaan <- read.csv(file.path(base, "data", "permintaan.csv"))
produk     <- read.csv(file.path(base, "data", "produk.csv"))

dataset <- permintaan |>
  left_join(produk, by = "Produk")

# ---------- 2. BLOK_PQ_01 -> tabel ramalan ----------
ens <- new.env()
assign("dataset", dataset, envir = ens)
ramalan <- jalan(extr("R/powerquery_01_ramalan.R", "BLOK_PQ_01"), ens, "BLOK_PQ_01")
write.csv(ramalan, file.path(out, "ramalan.csv"), row.names = FALSE)

# ---------- 3. BLOK_RV_* -> 8 gambar ggplot2 ----------
suppressMessages({ library(ggplot2); library(scales) })

dim <- list(V1 = c(9, 4.0), V2 = c(9, 4.6), V3 = c(8, 4.0),
            V4 = c(9, 4.0), V5 = c(8, 4.0), V6 = c(9, 3.2),
            V7 = c(8, 4.0), V8 = c(9, 4.0))
naam <- c(V1 = "kpi", V2 = "tren", V3 = "planbulan", V4 = "cek",
          V5 = "angkabulan", V6 = "heatmap", V7 = "kapasitas", V8 = "whatif")

for (nm in names(dim)) {
  tag  <- paste0("BLOK_RV_", nm)
  ensv <- new.env()
  assign("dataset", ramalan, envir = ensv)
  p <- jalan(extr("R/visual_R_powerbi.R", tag), ensv, tag)
  fname <- file.path(out, sprintf("V%s_%s.png", substring(nm, 2), naam[[nm]]))
  ggsave(fname, p, width = dim[[nm]][1], height = dim[[nm]][2],
         dpi = 150, bg = "white")
  cat("Dirender:", fname, "\n")
}

# ---------- 4. Ringkasan angka (untuk dokumentasi) ----------
cat("\n=== RINGKASAN VALIDACION ===\n")
cat("riwayat rows :", nrow(distinct(ramalan |> filter(Jenis == "Riwayat") |> select(Tanggal, Produk))), "\n")
cat("plan rows    :", nrow(distinct(ramalan |> filter(Jenis == "Plan") |> select(Tanggal, Produk))), "\n")
cat("total baris  :", nrow(ramalan), "(x3 skenario)\n")

hist <- ramalan |> filter(Jenis == "Riwayat") |> distinct(Tanggal, Produk, Permintaan)
pln  <- ramalan |> filter(Jenis == "Plan") |>
  distinct(Tanggal, Produk, Skenario, FaktorSkenario, Plan, HargaSatuan, KapasitasMesin) |>
  mutate(Hasil = Plan * FaktorSkenario)

cat(sprintf("Total riwayat 2024-25 : %s unit\n",
            format(sum(hist$Permintaan), big.mark = ".", decimal.mark = ",")))
cat("Plan 2026 per skenario:\n")
print(pln |> group_by(Skenario) |>
        summarise(Unit = sum(Hasil), Rp = sum(Hasil * HargaSatuan), .groups = "drop") |>
        mutate(Unit = format(round(Unit), big.mark = ".", decimal.mark = ","),
               Rp   = format(round(Rp),   big.mark = ".", decimal.mark = ",")))

cat("\nCek plan (Jul-Des 2025): rata-rata selisih per produk\n")
cek <- ramalan |> filter(!is.na(CekPlan)) |>
  distinct(Tanggal, Produk, Permintaan, CekPlan) |>
  group_by(Produk) |>
  summarise(SelisihPct = round(mean(abs(Permintaan - CekPlan) / Permintaan) * 100, 1),
            .groups = "drop")
print(cek |> as.data.frame())

cat("\nKebutuhan mesin (plan puncak Jan-Jun 2026):\n")
print(pln |> group_by(Produk, Skenario, KapasitasMesin) |>
        summarise(Puncak = round(max(Hasil)), .groups = "drop") |>
        mutate(Keb = ceiling(Puncak / KapasitasMesin)) |>
        as.data.frame())

cat("\nPlan Bulan Depan (Jan 2026) per produk:\n")
print(pln |>
        filter(as.integer(format(Tanggal, "%m")) == 1, Skenario == "Normal") |>
        transmute(Produk, Plan = round(Plan)) |>
        as.data.frame())

cat("\nValidacion selesai. File diproduksi di output/.\n")
```


---

## 12. Panduan Dashboard Power BI (±30–45 menit)

### 12.1 Load Data & Gabung Query

1. **Get Data → Text/CSV** → `data/permintaan.csv` → query **`permintaan`**.
2. **Get Data → Text/CSV** → `data/produk.csv` → query **`produk`**.
3. **Transform Data** → dalam query `permintaan`: **Home → Merge Queries**
   (`permintaan` kiri, `produk` kanan, join by `Produk`, **Left Outer**).
4. Expand kolom `produk` → pilih: `Kategori`, `HargaSatuan`, `KapasitasMesin`, `LeadTimeHari`.
5. Rinomina query: **`ramalan_sumber`**.

### 12.2 Trasformasi dengan R

Pada query `ramalan_sumber`: **Transform → Run R script** → tempel
**blok bab 8** (`R/powerquery_01_ramalan.R`) → variabel luaran `output` → **OK** → **Privacy = Public**.

Cek tipe kolom di Data view:

| Kolom | Tipe |
| --- | --- |
| `Tanggal` | **Date** |
| `Tahun`, `BulanKe` | **Whole number** |
| `Permintaan`, `Plan`, `CekPlan`, `AngkaBulan`, `FaktorSkenario` | **Decimal** |
| `HargaSatuan`, `KapasitasMesin` | **Whole number** |
| `NamaBulan`, `Produk`, `Kategori`, `Jenis`, `Skenario` | **Text** |

### 12.3 ⭐ Model Data & Konexion Tabel (semua terkoneksi)

Star model sederhana con 3 tabel:

```text
                 ┌──────────────┐
   produk ──────>│    ramalan   │<────── skenario
 (dimensi 2)     │   (fakt 180) │     (dimensi 3)
                 └──────────────┘
```

**Buat dimensi `skenario` (3 baris, dari fakt):**

1. Power Query: **klik kanan query `ramalan` → Reference** → rinomina **`skenario`**.
2. **Transform → Remove Other Columns** → pilih `Skenario` dan `FaktorSkenario`.
3. **Home → Remove Rows → Remove Duplicates** → 3 baris (Pesimis/Normal/Optimis).

**Pokvari data sumber mentah (optional):** klik kanan tabel `permintaan` di Fields pane →
uncheck **"Include in report"** (agar model lebih bersih; `produk`, `ramalan`, `skenario` tetap dimuat).

**Buat hubungan (Model view):**

| Dalle | Verso | Kardinalitas | Cross filter |
| --- | --- | --- | --- |
| `produk[Produk]` | → `ramalan[Produk]` | 1 : many | one-side → many |
| `skenario[Skenario]` | → `ramalan[Skenario]` | 1 : many | one-side → many |

(Drag kolom di tab Model: `produk[Produk]` → `ramalan[Produk]`, dsb.)

**Kenapa ini garanti "slicer terkoneksi semua":** slicer `Produk` memakai dimensione `produk` →
hubungan filter `ramalan` → **R visual menerima solo baris terfilter** → gambar ikut.
Slicer `Skenario` (dim `skenario`), `Tahun`/`NamaBulan` (kolom fakt) — juga filter untuk semua visual.

> Konsep: **tidak ada tabel patah** — dimensi dan fakt terkoneksi, jadi filter dari slicer
> berbari sampai ke baris fakt yang diterima R visual (`dataset`).

### 12.4 Slicer

| Slicer | Field (tabel) | Modus |
| --- | --- | --- |
| Produk | `produk[Produk]` | Dropdown |
| Skenario | `skenario[Skenario]` | **Dropdown, single select** (what-if) |
| Tahun | `ramalan[Tahun]` | Dropdown multi |
| NamaBulan | `ramalan[NamaBulan]` | Dropdown multi |

### 12.5 Bangun 8 R Visual

Per visual: klik ikon **R visual** → Enable → tarik field ke **Values** (bab 9 tabel) →
tempel blok dari bab 9 → **Run script**. Field numerik = **Do not summarize**.

| # | R visual | BLOK (bab 9) |
| --- | --- | --- |
| V1 | Ringkasan (KPI) | `BLOK_RV_V1` |
| V2 | Tren riwayat & plan | `BLOK_RV_V2` |
| V3 | Plan bulan depan | `BLOK_RV_V3` |
| V4 | Cek plan vs aktual | `BLOK_RV_V4` |
| V5 | Angka bulan | `BLOK_RV_V5` |
| V6 | Heatmap tahun×bulan | `BLOK_RV_V6` |
| V7 | Kapasitas vs puncak | `BLOK_RV_V7` |
| V8 | Tabel what-if | `BLOK_RV_V8` |

Layout contoh: 4 slicer di atas; V1+V8 di bar pertama; V2 di kiri (besar); V3+V5 di kanan;
V4+V7 di bar bawah; V6 di kanan kecil.

### 12.6 Demo What-if (slicer Skenario)

1. Slicer `Skenario` = **Normal**: V1 "Plan 2026 = 61.176 unit" & "Mesin = 4";
   V7 Produk A puncak 7.924 > 7.000 (2 mesin), Produk B 4.016 > 3.800 (2 mesin); V8 row Normal.
2. Slicer = **Optimis**: V1 plan = 67.293; V7 puncak Produk B 4.418 → bar di atas garis.
3. Slicer = **Pesimis**: V1 plan = 55.058; V7 Produk B 3.615 < 3.800 → 1 mesin.

### 12.7 Troubleshooting

| Simptom | Causa | Fix |
| --- | --- | --- |
| R visual tidak mengubah ke slicer | **Hubungan belum buat** / kolom slicer tidak di Values | Buat hubungan (bab 12.3); sertakan kolom slicer di Values |
| Slicer mengubah 1 visual saja | Interaksi visual = None | Format > **Edit interactions** → semua = Filter |
| Angka KPI dua kali | baris skenario berulang | blok harus `distinct()` sebelum summing (kode fresh dari file R) |
| R visual error saat filter 0 baris | tidak ada data untuk filter | blok ber guard `nrow(dataset) == 0` → dirender pesan |
| R script tidak jalan | Privacy ≠ Public / path R salah | semua sumber Public; cek Options > R scripting |
| `Tanggal` jadi teks di R | tipe kolom bukan Date | set `Tanggal` = Date di tabel `ramalan` |
| Refresh gagal di Service | R tidak paket di cloud | demo/refresh di **Desktop** |

### 12.8 Checklist

- [ ] Model: `produk` + `skenario` terkoneksi ke `ramalan` (bab 12.3)
- [ ] `permintaan` dihide (Include in report off) — optional
- [ ] 8 R visual dirender tanpa error
- [ ] Slicer Produk / Skenario / Tahun / NamaBulan mengubah **semua** 8
- [ ] What-if demo sesuai angka bab 6


---

## 13. Kenapa Filter Berjalan di Semua Visual

1. **Slicer filter baris fakt.** Slicer `Produk` (dimensi `produk`) & `Skenario` (dimensi `skenario`)
   terkoneksi ke `ramalan` dengan hubungan 1-many (bab 12.3). Slicer menyaring baris `ramalan`.
2. **R visual hanya menerima baris terfilter.** Skrip ggplot2 membaca `dataset` (baris yang
   pasas filter) → gambar ikut berubah. Skrip juga membangun `distinct()`/`group_by()` sendiri.
3. **Tidak ada tabel patah** → tidak ada gambar yang "tidak ikut slicer".
4. R visual juga *cross-filter* visual lain (behavias native Power BI).

> Penting: R visual = gambar statis (PNG). Yang interaktif adalah **slicer**, bukan elemen dalam
> gambar. Sertakan semua kolom yang dibutuhan di **Values** (bab 9).

---

## 14. Kesimpulan & Rekomendasi

| # | Temuan (bahasa sehari-hari) | Bukti | Rekomendasi |
| --- | --- | --- | --- |
| 1 | Produk A tumbuh +13% dengan puncak Desember | total 76.290 (2025) · angka bulan Des 1,4 | siapkan kapasitas Produk A sebelum Q4 |
| 2 | Metode plan sederhana cukup rapih | selisih rata-rata 10,7% / 8,0% (Cek 2025) | update plan setiap bulan (rata 3 terakhir × angka bulan) |
| 3 | Puncak plan pasar kapasitas 1 mesin | Produk A 7.924 > 7.000 (Normal) | tambah/tutaf mesin Produk A **atau** perataan puncak |
| 4 | What-if teruji pilihan secara ulsuk | Optimis: Produk B 4.418 > 3.800 (2 mesin) | bila imbas promosi, tardi silakan mesin Produk B |
| 5 | Skenario penjualan jelas di Rp | Normal Rp 796,5 M vs Optimis Rp 876,2 M | diskusi pihak bisnis pakai slicer Skenario |

**Format insight (kondisi → bukti → tindakan):**

> **Kondisi:** permintaan tumbuh dengan puncak Desember sehingga 1 mesin Produk A tidak cukup
> di setiap skenario (puncak plan ≥ 7.132).
> **Bukti:** plan puncak Produk A = 7.924 (Normal); kapasitas 1 mesin = 7.000; selisih rata-rata plan 10,7%.
> **Tindakan:** update plan bulanan dengan *rata 3 bulan terakhir × angka bulan*, tambah
> 1 mesin Produk A, dan pakai slicer Skenario untuk simulasi promosi/Pesimis.

---

## 15. Catatan & Limitasi

| Item | Catatan |
| --- | --- |
| **R visual = statis** | Gambar R tidak interaktif (tooltip/klik); yang interaktif = slicer & filter |
| **1 blok R di Power Query = 1 tabel** | Transformasi utama menghasilkan tabel `ramalan`; dimensione `skenario` = query reference (distinct) |
| **Lookahead CekPlan** | `CekPlan` 2025 memakai `AngkaBulan` dari data 2024 saja, jadi tanpa "monyeji" (no futuro) |
| **Plan 2026** | Memakai level rata-rata Okt–Des 2025 × `AngkaBulan` (2024+2025) — update bulanan yang menghadapi level yang diubah |
| **Power BI Service** | R tidak paket di cloud → demo/refresh yang bisa diandai di **Desktop** |
| **Sumber ide** | `Brainstorming/pilihan/03-peramalan-permintaan` (versi lengkap con MA/EWMA/MAPE) — proyek ini dirapakkan sederhana |

---

*README lengkap — Peramalan Permintaan (End-to-End, Power BI + R). Bagian dari `Brainstorming/selected/`.*
