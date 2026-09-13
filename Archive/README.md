# 🗄️ README Archive — Volume 3, 4 & 5 (Arsip)

> Folder ini menyimpan **materi lama** yang sudah tidak menjadi bagian alur utama pelatihan, tetapi tetap dipertahankan sebagai referensi. Volume aktif saat ini: **Volume 0 (Basic R)**, **Volume 1 (Basic Visualization ggplot2)**, dan **Volume 2 (Statistics & Inferential Statistics)**.

---

## 1. Isi Folder

| Volume | Fokus | Format |
| --- | --- | --- |
| **Volume 3 — Case Study Industrial Engineering** | 5 case study IE: Pareto, SPC control chart, process capability, OEE & downtime, uji hipotesis + regresi | Markdown saja (5 file `case-*.md` + `README.md`) |
| **Volume 4 — Case Study End-to-End Analytics** | Studi kasus end-to-end: dplyr + ggplot2 → 8 visual + panduan dashboard Power BI | Markdown + skrip R + data + output |
| **Volume 5 — Causal Inference Sederhana** | Difference-in-Differences (DiD) & what-if visual untuk pelatihan operator | Markdown + skrip R + data + output |

---

## 2. Struktur

```text
Archive/
├── README.md                                  # file ini
├── Volume 3 - Case Study Industrial Engineering/
│   ├── README.md
│   └── case-01-pareto.md … case-05-uji-hipotesis-regresi.md
├── Volume 4 - Case Study End-to-End Analytics/
│   ├── README.md
│   ├── R/          (00_buat_data.R, 01_analisis_dplyr.R, 02_visualisasi_ggplot2.R)
│   ├── data/       (produksi.csv)
│   ├── output/     (7 tabel CSV + 8 PNG)
│   └── powerbi/    (panduan-dashboard.md)
└── Volume 5 - Causal Inference Sederhana/
    ├── README.md
    ├── R/          (00_buat_data.R, 01_did_sederhana.R, 02_enam_visual.R, 03_whatif_visual.R)
    ├── data/       (causal_simple.csv)
    └── output/     (7 PNG)
```

---

## 3. Cara Menjalankan (dari root repo "Power BI dan R")

```r
# Volume 4 — analisis end-to-end
source("Archive/Volume 4 - Case Study End-to-End Analytics/R/00_buat_data.R")
source("Archive/Volume 4 - Case Study End-to-End Analytics/R/01_analisis_dplyr.R")
source("Archive/Volume 4 - Case Study End-to-End Analytics/R/02_visualisasi_ggplot2.R")

# Volume 5 — causal inference (DiD)
source("Archive/Volume 5 - Causal Inference Sederhana/R/00_buat_data.R")
source("Archive/Volume 5 - Causal Inference Sederhana/R/01_did_sederhana.R")
source("Archive/Volume 5 - Causal Inference Sederhana/R/02_enam_visual.R")
source("Archive/Volume 5 - Causal Inference Sederhana/R/03_whatif_visual.R")
```

Atau via terminal:

```bash
Rscript "Archive/Volume 5 - Causal Inference Sederhana/R/01_did_sederhana.R"
```

---

## 4. Catatan Data

Volume 3 memakai dataset di **root repo** (`../../quality_inspection.csv`, `../../qc_hasil_produksi.csv`, `../../qc_operator.csv`, `../../qc_produk.csv`) — bukan file di dalam folder Archive. Volume 4 & 5 adalah **self-contained** (menyertakan `data/` sendiri).

---

## 5. Mengapa Diarsipkan?

Volume 3–5 adalah **studi kasus lanjutan** yang dibangun di atas dasar Volume 0–2. Materi inti kini difokuskan ke tiga volume aktif; Volume 3–5 disimpan di sini agar tautan & kode lama tetap dapat diakses tanpa mengganggu alur belajar utama.

---

*Folder Archive — arsip Volume 3, 4 & 5 dari rangkaian pelatihan "Insight to Impact".*
