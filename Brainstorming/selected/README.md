# ✅ Selected — Peramalan Permintaan (Use Case Training R di Power BI)

> Proyek **use case training 90 menit**: transformasi data dengan **R di Power Query** dan
> **10 R visual (`ggplot2`)** berbentuk grafik yang **tidak tersedia** di Power BI,
> dibungkus satu **README tutorial** yang memuat kode dan hasilnya.
> **`Produk` dan `Skenario` dipakai sebagai FILTER (slicer), bukan isi grafik.**

## Alur Ide → Selected → Volume Resmi

```text
Brainstorming/pilihan/03-peramalan-permintaan/        # ide lengkap (4 produk, 7 PNG)
        │  dipilih & dirapikan jadi use case training
        ▼
Brainstorming/selected/demand-forecasting-r-power-bi/ # proyek ini (2 produk, 10 R visual)
        │  bila sudah demo & memadai
        ▼
Volume N - ... (folder resmi)
```

## Struktur

```text
selected/
└── demand-forecasting-r-power-bi/
    ├── README.md                 # TUTORIAL 90 menit: kode R + hasil + insight
    ├── data/                     # permintaan.csv (1.152 baris) + produk.csv (16) + lokasi.csv (2)
    ├── R/
    │   ├── 00_buat_data.R        # generator data + outlier (set.seed 20260913)
    │   ├── 01_transformasi.R     # BLOK_PQ_01 -> Power Query (tabel ramalan)
    │   ├── 02_visual.R           # BLOK_RV_V1..V10 -> R visual (ggplot2)
    │   ├── 03_validasi.R         # uji semua blok lokal -> output/ (10 PNG, 0 warning)
    │   └── 04_buat_readme.R      # susun ulang README.md dari template/
    ├── template/                 # 5 bagian sumber teks README
    └── output/                   # ramalan.csv + V1..V10 PNG
```

## Agenda 90 Menit

| Menit | Tahap | Hasil |
| ---: | --- | --- |
| 0–5 | Persiapan | paham data & outlier |
| 5–25 | Transformasi (R di Power Query) | tabel `ramalan` 4.032 baris |
| 25–70 | 10 R visual | 10 grafik non-native, ikut slicer |
| 70–85 | Dashboard & insight | 7 insight + 5 rekomendasi |
| 85–90 | Validasi & penutup | bisa reproduce sendiri |

## Quick Start

```bash
cd "Brainstorming/selected/demand-forecasting-r-power-bi"
Rscript R/00_buat_data.R     # generate data + outlier (angka selalu sama)
Rscript R/03_validasi.R      # validasi blok R & render 10 PNG
```

**Pelajaran kunci:** (1) pakai **median**, bukan rata-rata, karena ada outlier; (2) slicer
hanya bekerja bila kolomnya ada di **Values** R visual; (3) **bentuk grafik V2–V7, V9, V10
tidak ada** di Power BI — itulah alasan memakai R visual.

**Angka kunci:** riwayat **409.700 unit** · rencana 2026 Normal **81.390 unit (Rp 1,02 M)** ·
back-test median **10,3–12,0%** vs rata-rata **11,3–14,0%** · mesin **7 butuh vs 4 terpasang**.

*Folder `selected` — proyek dipilih & siap dijadikan materi training.*
