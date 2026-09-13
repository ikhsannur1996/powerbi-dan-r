# 📊 Panduan Dashboard Power BI — Volume 4

Bangun dashboard interaktif **"Optimasi Produktivitas Linimas Industri"** (±30–45 menit).
Semua angka acuan di bawah adalah **hasil aktual** dari data (bukan perkiraan).

---

## 1. Persiapan Data

1. Buka **Power BI Desktop** → **Get Data → Text/CSV** → pilih:
   `Archive/Volume 4 - Case Study End-to-End Analytics/output/fakta_powerbi.csv`
2. Pastikan tipe kolom benar:
   - `Tanggal` → **Date**; `Bulan` → teks (`2026-01` dst.); `Hari` → teks nama hari.
   - `DefectRatePct`, `PencapaianPct` → **Decimal number**.
   - Sisanya numerik → **Whole number**, kategori → **Text**.
3. (Opsional) Buat tabel kalender dengan DAX `CALENDAR()` lalu relasikan ke `Tanggal` untuk slicer bulan yang rapi.

## 2. Measure DAX (3 measure inti)

```dax
Total Produksi = SUM ( fakta_powerbi[AktualProduksi] )

Defect Rate % = DIVIDE ( SUM ( fakta_powerbi[JumlahCacat] ), SUM ( fakta_powerbi[AktualProduksi] ) ) * 100

Pencapaian % = DIVIDE ( SUM ( fakta_powerbi[AktualProduksi] ), SUM ( fakta_powerbi[TargetProduksi] ) ) * 100

Total Downtime (mnt) = SUM ( fakta_powerbi[DowntimeMenit] )
```

Format: `Defect Rate %` dan `Pencapaian %` → 2 desimal + conditional formatting
(merah jika Defect Rate % > 3, hijau jika Pencapaian % ≥ 100).

**Nilai pembanding** (untuk cek measure Anda): Total Produksi = **313.672**,
Defect Rate % = **2,56**, Pencapaian % = **96,8**, Downtime = **20.168 mnt**.

## 3. Layout 1 Halaman — 7 Visual + Slicer

```text
+---------------------------------------------------------------+
| JUDUL: Optimasi Produktivitas Linimas Industri (Jan-Jun 2026) |
| Slicer: Bulan | Line | Shift | Produk                         |
+---------------------------------------------------------------+
| [KPI: Total Produksi] [KPI: Defect Rate %] [KPI: Pencapaian %] |
| [KPI: Downtime]                                               |
+---------------------------------------------------------------+
| (1) Line chart: Produksi harian  | (2) Bar: Defect Rate %         |
|     Axis=Tanggal, Values=Produksi|     per Operator (sort desc)     |
+---------------------------------------------------------------+
| (3) Bar/Line Pareto: Cacat per   | (4) Matrix/Heatmap: Line x     |
|     Produk + % kumulatif         |     Shift (Defect Rate %)        |
+---------------------------------------------------------------+
| (5) Bar: Downtime per Mesin      | (6) Scatter: Pencapaian % (X)   |
|                                  |     vs Defect Rate % (Y),       |
|                                  |     Size=Downtime, Legend=Shift |
+---------------------------------------------------------------+
| (7) Donut: Komposisi output per Produk                          |
+---------------------------------------------------------------+
```

Pemetaan ke visual ggplot2 (referensi tampilan): V1→(1), V2→(2), V4→(3),
V6→(4), V7→(5), V3→(6), V8→(7). Tambahkan **boxplot cycle time (V5)**
sebagai visual ke-8 di halaman 2 bila ingin genap 8.

## 4. Interaksi yang Harus Dicoba (untuk demo/riset)

1. Klik **Malam** pada slicer Shift → Defect Rate naik, Pencapaian turun (efek shift malam).
2. Klik **OP06** → lihat kontribusinya pada bar operator & scatter.
3. Klik **M-02** → downtime & defect ikut tersorot (mesin prioritas maintenance).
4. Drill-down line chart dari **bulan → hari** untuk menemukan hari anomali.

## 5. Format Laporan Riset (bab hasil)

Tulis 4 bagian ini berdasarkan dashboard:

1. **Latar belakang & rumusan masalah** — "Faktor apa (operator, mesin, shift, produk)
   yang paling memengaruhi produktivitas & kualitas?"
2. **Metodologi** — dummy realistis 924 baris; dplyr untuk agregasi; ggplot2 untuk
   eksplorasi; Power BI untuk dashboard interaktif (cantumkan measure DAX).
3. **Hasil & pembahasan** — laporkan angka aktual: defect 2,56%; OP06 4,1% & OP04 3,24%;
   Malam terburuk di kedua line; M-02/M-04 downtime tertinggi; Pareto Bracket+Housing 77,9%.
4. **Kesimpulan & rekomendasi** —
   - Coaching + rotasi shift untuk OP06/OP04; audit shift Malam (kelelahan/pengawasan).
   - Preventive maintenance terjadwal untuk M-02 & M-04.
   - Fokus quality improvement pada Bracket & Housing (Pareto).
   - Kaizen/SMED pada Shaft (cycle time tertinggi).
