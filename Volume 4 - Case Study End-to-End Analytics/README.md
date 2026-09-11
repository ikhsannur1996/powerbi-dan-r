# 🏭 Volume 4 — Optimasi Produktivitas Linimas Industri: Analisis Data Terintegrasi dengan R, dplyr & Power BI

> Studi kasus **end-to-end seperti riset/penelitian**: dari rumusan masalah → data → analisis R (dplyr + ggplot2) → dashboard Power BI → kesimpulan & rekomendasi.

---

## 1. Ringkasan Eksekutif

| Komponen | Keterangan |
|---|---|
| **Judul** | Optimasi Produktivitas Linimas Industri: Analisis Data Terintegrasi dengan R, dplyr & Power BI |
| **Periode data** | 2 Jan – 30 Jun 2026 (154 hari produksi, libur tiap Minggu) |
| **Dataset** | `data/produksi.csv` — **924 baris × 12 kolom** (1 baris = 1 shift × 1 line) |
| **Temuan kunci** | Defect rate keseluruhan **2,56%**; operator **OP06 (4,1%)** & **OP04 (3,24%)** tertinggi; shift **Malam** paling merah di kedua line; mesin **M-02 & M-04** penyumbang downtime terbesar |
| **Luaran** | 7 tabel agregat + 8 visual ggplot2 + panduan dashboard Power BI (6–8 visual) |

## 2. Struktur Folder

```text
Volume 4 - Case Study End-to-End Analytics/
├── README.md                      # file ini
├── data/
│   └── produksi.csv               # data dummy realistis (924 × 12)
├── R/
│   ├── 00_buat_data.R             # generator data (set.seed(20260401), bisa di-run ulang)
│   ├── 01_analisis_dplyr.R        # transformasi & agregasi → output/*.csv
│   └── 02_visualisasi_ggplot2.R   # 8 visual eksplorasi → output/V*.png
├── output/
│   ├── fakta_powerbi.csv          # tabel fakta bersih siap import Power BI
│   ├── tbl_*.csv                  # 6 tabel agregat siap pakai
│   └── V1_*.png … V8_*.png        # 8 visual ggplot2
└── powerbi/
    └── panduan-dashboard.md       # langkah membangun dashboard Power BI
```

## 3. Dataset — Kamus Data

| Kolom | Tipe | Keterangan |
|---|---|---|
| `ProductionID` | teks | ID unik `PRD-00001` … `PRD-00924` |
| `Tanggal` | tanggal | 2026-01-02 s.d. 2026-06-30 (tanpa Minggu) |
| `Shift` | kategori | Pagi / Siang / Malam |
| `Line` | kategori | Line-A / Line-B |
| `Operator` | kategori | OP01 … OP08 |
| `Mesin` | kategori | M-01, M-02 (Line-A); M-03, M-04 (Line-B) |
| `Produk` | kategori | Bracket / Housing / Shaft |
| `TargetProduksi` | numerik | target unit per shift |
| `AktualProduksi` | numerik | realisasi unit |
| `JumlahCacat` | numerik | unit cacat |
| `DowntimeMenit` | numerik | menit berhenti per shift |
| `CycleTimeDetik` | numerik | rata-rata detik per unit |

**Pola yang sengaja ditanam** (agar analisis menemukan sesuatu, seperti di lapangan):
- OP06 & OP04 punya risiko cacat lebih tinggi (butuh coaching/rotasi).
- M-02 & M-04 lebih sering downtime (prioritas preventive maintenance).
- Shift Malam: output −10%, risiko cacat ×1,25 (faktor kelelahan).
- Shaft: cycle time +8 detik (proses lebih kompleks).

## 4. Cara Menjalankan (dari root repo "Power BI dan R")

```r
# 1. (Opsional) buat ulang data
source("Volume 4 - Case Study End-to-End Analytics/R/00_buat_data.R")

# 2. Analisis dplyr → 7 file agregat di output/
source("Volume 4 - Case Study End-to-End Analytics/R/01_analisis_dplyr.R")

# 3. Visual ggplot2 → 8 file PNG di output/
source("Volume 4 - Case Study End-to-End Analytics/R/02_visualisasi_ggplot2.R")
```

Atau via terminal:

```bash
Rscript "Volume 4 - Case Study End-to-End Analytics/R/01_analisis_dplyr.R"
Rscript "Volume 4 - Case Study End-to-End Analytics/R/02_visualisasi_ggplot2.R"
```

## 5. KPI (hasil aktual dari data)

| KPI | Nilai |
|---|---|
| Total produksi | **313.672 unit** |
| Total cacat | **8.042 unit** |
| Defect rate | **2,56%** |
| Pencapaian vs target | **96,8%** |
| Total downtime | **20.168 menit (~336 jam)** |
| Rata-rata cycle time | **47,6 detik** |

## 6. Delapan Visual (cermin dashboard Power BI)

| # | File | Jenis | Insight |
|---|---|---|---|
| V1 | `V1_tren_harian.png` | Line + smooth | tren produksi stabil, fluktuasi wajar |
| V2 | `V2_defect_operator.png` | Bar terurut | OP06 & OP04 di atas rata-rata |
| V3 | `V3_scatter_pencapaian_defect.png` | Bubble (size = downtime) | titik kanan-atas = bahaya |
| V4 | `V4_pareto_produk.png` | Pareto | Bracket 42,9% + Housing → 77,9% kumulatif |
| V5 | `V5_boxplot_cycletime.png` | Boxplot | Shaft paling lambat |
| V6 | `V6_heatmap_line_shift.png` | Heatmap | Malam merah di kedua line |
| V7 | `V7_downtime_mesin.png` | Bar | M-02 (6.238 mnt) & M-04 (5.838 mnt) |
| V8 | `V8_donut_produk.png` | Donut | komposisi output per produk |

## 7. Lanjut ke Power BI

Buka [`powerbi/panduan-dashboard.md`](powerbi/panduan-dashboard.md) — import `output/fakta_powerbi.csv`, buat 3 measure DAX, susun 7 visual + slicer, lalu tulis kesimpulan. Format riset (latar belakang → metodologi → hasil → rekomendasi) ada di panduan tersebut.
