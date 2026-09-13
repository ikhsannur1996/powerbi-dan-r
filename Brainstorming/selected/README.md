# ✅ Selected — Peramalan Permintaan (Super Sederhana)

> Proyek yang **dipilih** dari `Brainstorming/pilihan/` (Opsi 3 — Peramalan Permintaan) dan
> dirapakkan versi **ultra sederhana end-to-end**: **1 metoda plan saja** (rata-rata 3 bulan × angka bulan),
> semua transformasi dengan **R di Power Query**, semua visualisasi dengan **R visual** (`ggplot2`),
> semua tabel terkoneksi star-model, **8 visual**, dan **what-if** via slicer `Skenario`.

## Alur Ide → Selected → Volume Resmi

```text
Brainstorming/pilihan/03-peramalan-permintaan/   # ide lengkap (4 produk, 7 PNG)
        │  dipilih & dirapakkan sederhana
        ▼
Brainstorming/selected/peramalan-permintaan/     # proyek ini (2 produk, 8 R visual)
        │  bila sudah demo & memizi
        ▼
Volume N - ... (folder resmi)
```

## Struktur

```text
selected/
└── peramalan-permintaan/
    ├── README.md                 # ONE file end-to-end: dokumentasi + kode R inline + output visual + panduan Power BI
    ├── data/                     # permintaan.csv (48 baris) + produk.csv
    ├── R/
    │   ├── 00_buat_data.R            # generator data (reproducible)
    │   ├── powerquery_01_ramalan.R   # BLOK R -> Power Query (tabel ramalan)
    │   ├── visual_R_powerbi.R        # 8 BLOK R visual (ggplot2) -> filterable
    │   └── 03_validasi.R             # jalan semua blok lokal -> output/
    └── output/                   # ramalan.csv + V1..V8 PNG
```

## Quick Start

```bash
cd "Brainstorming/selected/peramalan-permintaan"
Rscript R/00_buat_data.R     # generate data (set.seed 20260913)
Rscript R/03_validasi.R      # validate blok R & render 8 PNG
```

Validacija lokal sudah jalan **bersih (0 warning)** + test filter 40 kombinasi semua OK.
Angka key: **total riwayat 223.514 unit** · **Plan 2026 Normal 61.176 unit (Rp 796,5 M)** ·
**selisih rata-rata plan 10,7% / 8,0%** · **Produk A 2 mesin saat puncak (semua skenario)**.

*Folder `selected` — proyek dipilih & siap demo/raffinasi.*