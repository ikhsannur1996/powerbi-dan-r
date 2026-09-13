# 📊 Panduan Dashboard Power BI — Peramalan Permintaan (Super Sederhana)

> Bangun dashboard **"Peramalan Permintaan & What-if"** (±30–45 menit), tanpa statistika.
> Semua trasformasi: **R di Power Query**. Semua visualisasi: **R visual** (`ggplot2`).
> Semua tabel terkoneksi → **slicer menyaring semua gambar**.
> Angka yang ditulis = hasil aktual dari `output/`.

---

## 1. Prasyarat

| # | Langkah |
| --- | --- |
| 1 | Install R (<https://cran.r-project.org/>) |
| 2 | `install.packages(c("dplyr", "tidyr", "ggplot2", "scales"))` di R |
| 3 | **File > Options > Global > R scripting** → check R home directory |
| 4 | Semua sumber data → **Privacy = Public** (icone kilitan) |

> Power BI tidak di-`library()` otomatis → setiap blok R ber `library()` sendiri.

---

## 2. Load Data & Gabung Query

1. **Get Data → Text/CSV** → `data/permintaan.csv` → query **`permintaan`**.
2. **Get Data → Text/CSV** → `data/produk.csv` → query **`produk`**.
3. **Transform Data** → dalam query `permintaan`: **Home → Merge Queries**
   (`permintaan` kiri, `produk` kanan, join by `Produk`, **Left Outer**).
4. Expand kolom `produk` → pilih `Kategori, HargaSatuan, KapasitasMesin, LeadTimeHari`.
5. Rinomina query: **`ramalan_sumber`**.

---

## 3. Trasformasi dengan R (BLOK #1 → tabel `ramalan`)

Pada query `ramalan_sumber`:

1. **Transform → Run R script** → tempel kode dari **`R/powerquery_01_ramalan.R`**
   (blok `BLOK_PQ_01_START/END`). Variabel luaran = **`output`** → Power BI kenali it `ramalan`.
2. Set **Privacy = Public**, klik OK.
3. Cek tipe kolom di Data view:
   - `Tanggal` = **Date**; `Tahun`, `BulanKe` = **Whole number**;
   - `Permintaan`, `Plan`, `CekPlan`, `AngkaBulan`, `FaktorSkenario` = **Decimal**;
   - lain numerik = **Whole**; kategorik = **Text**.

> BLOK #2 (tabel akurasi) **tidak ada lagi** — proyek sederhana ini tidak butuh model comparison.

---

## 4. ⭐ Model Data & Konexion Tabel (semua terkoneksi)

Dotovati star model sederhana **con 3 tabel** yang terkoneksi:

```text
                 ┌──────────────┐
   produk ──────>│    ramalan   │<────── skenario
 (dimensi 2)     │   (fakt 180) │     (dimensi 3)
                 └──────────────┘
```

### 4.1 Buat dimensi `skenario` (3 baris, dari R)

1. Power Query: **klik kanan query `ramalan` → Reference** → rinomina **`skenario`**.
2. **Transform → Remove Other Columns** → pilih `Skenario` dan `FaktorSkenario`.
3. **Home → Remove Rows → Remove Duplicates** → terbent 3 baris (Pesimis/Normal/Optimis).

### 4.2 Menyelin tabel sumber mentah

- Dalam Fields pane (Data view): klik kanan tabel **`permintaan`** →
  uncheck **"Include in report"** (optional, agar model lebih bersih).
  Tabel `produk` dan `ramalan` dan `skenario` tetap dimuat.

### 4.3 Buat hubungan (Model view)

| Dalle | Verso | Kardinalitas | Cross filter |
| --- | --- | --- | --- |
| `produk[Produk]` | → `ramalan[Produk]` | 1 : many | one-side → many |
| `skenario[Skenario]` | → `ramalan[Skenario]` | 1 : many | one-side → many |

(Versione vector: dalam tab Model, drag kolom `produk[Produk]` ke `ramalan[Produk]`, dsb.)

### 4.4 Kenapa ini garanti "slicer terkoneksi semua"

- Slicer `Produk` memakai kolom dimensi `produk` → hubungan filtr `ramalan` →
  **R visual menerima solo baris terfilter** → gambar ikut.
- Slicer `Skenario` memakai dim `skenario` → hubungan filtr `ramalan`.
- Slicer `Tahun` / `NamaBulan` memakai kolom fakt `ramalan` sendiri → juga filter untuk semua visual.

> Konsep: **tidak ada tabel patah** — dimensi dan fakt terkoneksi, jadi filter dari slicer
> berbari sampai ke baris fakt yang diterima R visual.

---

## 5. Slicer (dashboard)

| Slicer | Field (tabel) | Modus |
| --- | --- | --- |
| Produk | `produk[Produk]` | Dropdown |
| Skenario | `skenario[Skenario]` | **Dropdown, single select** (what-if) |
| Tahun | `ramalan[Tahun]` | Dropdown multi |
| NamaBulan | `ramalan[NamaBulan]` | Dropdown multi |

---

## 6. Bangun 8 R Visual

Per visual: klik ikon **R visual** → Enable → tarik field ke **Values** →
tempel blok dari **`R/visual_R_powerbi.R`** → Run script.
Field numerik = **Do not summarize** (skrip yang aggregasi).

| # | R visual | Field di Values | BLOK in `visual_R_powerbi.R` |
| --- | --- | --- | --- |
| V1 | Ringkasan (KPI) | `Produk, Jenis, Tanggal, Permintaan, Plan, CekPlan, FaktorSkenario, Skenario, HargaSatuan, KapasitasMesin` | `BLOK_RV_V1` |
| V2 | Tren riwayat & plan | `Tanggal, Produk, Jenis, Permintaan, Plan, FaktorSkenario, Skenario` | `BLOK_RV_V2` |
| V3 | Plan bulan depan | `Jenis, Produk, Tanggal, Plan, FaktorSkenario, Skenario` | `BLOK_RV_V3` |
| V4 | Cek plan vs aktual | `Jenis, Tanggal, Produk, Permintaan, CekPlan` | `BLOK_RV_V4` |
| V5 | Angka bulan | `Produk, BulanKe, AngkaBulan` | `BLOK_RV_V5` |
| V6 | Heatmap tahun×bulan | `Jenis, Tanggal, Permintaan` | `BLOK_RV_V6` |
| V7 | Kapasitas vs puncak | `Jenis, Produk, Tanggal, Skenario, FaktorSkenario, Plan, KapasitasMesin` | `BLOK_RV_V7` |
| V8 | Tabel what-if | `Jenis, Tanggal, Produk, Skenario, FaktorSkenario, Plan, HargaSatuan, KapasitasMesin` | `BLOK_RV_V8` |

Pratinjau (hasil lokal): `output/V1_kpi.png` … `V8_whatif.png`.

Layout contoh: 4 slicer di atas; V1+V8 di bar pertama; V2 di kiri (besar); V3+V5 di kanan; V4+V7 di bar bawah; V6 di kanan kecil.

---

## 7. Demo What-if (slicer Skenario)

1. Slicer `Skenario` = **Normal**: V1 "Plan 2026 = 61.176 unit" & "Mesin = 4";
   V7 Produk A puncak 7.924 > 7.000 (2 mesin), Produk B 4.016 > 3.800 (2 mesin); V8 row Normal.
2. Slicer = **Optimis**: V1 plan = 67.293; V7 puncak Produk B 4.418 → bar tinggi di atas garis.
3. Slicer = **Pesimis**: V1 plan = 55.058; V7 Produk B 3.615 < 3.800 → 1 mesin.

### Angka pembanding

| Metrik | Nilai |
| --- | --- |
| Total riwayat 2024–2025 | 223.514 unit |
| Plan 2026 Pesimis / Normal / Optimis | 55.058 / 61.176 / 67.293 unit |
| Penjualan 2026 (Rp) | 716,9 M / 796,5 M / 876,2 M |
| Selisih rata-rata plan (Cek 2025) | Produk A 10,7% · Produk B 8,0% |
| Mesin saat puncak (Normal) | Produk A 2 · Produk B 2 |
| Plan bulan depan Jan 2026 (Normal) | Produk A 5.231 · Produk B 2.856 |

---

## 8. Troubleshooting

| Simptom | Causa | Fix |
| --- | --- | --- |
| R visual tidak mengubah ke slicer | **Hubungan belum buat** / kolom slicer tidak di Values | Buat hubungan (bab 4.3); sertakan kolom slicer di Values |
| Slicer mengubah 1 visual saja | Interaksi visual = None | Format > **Edit interactions** → semua = Filter |
| Angka KPI dua kali | baris skenario berulang | blok harus `distinct()` sebelum summing (kode fresh dari file) |
| R visual error saat filter 0 baris | tidak ada data untuk filter | blok ber guard `nrow(dataset)==0` → dirender pesan |
| R script tidak jalan | Privacy != Public / path R salah | semua sumber Public; cek Options > R scripting |
| `Tanggal` jadi teks di R | tipe kolom bukan Date | set `Tanggal` = Date di tabel `ramalan` |
| Refresh gagal di Service | R tidak paket di cloud | demo/refresh di **Desktop** |

---

## 9. Checklist

- [ ] Model: `produk` + `skenario` terkoneksi ke `ramalan` (bab 4.3)
- [ ] `permintaan` dihide (Include in report off) — optional
- [ ] 8 R visual dirender tanpa error
- [ ] Slicer Produk / Skenario / Tahun / NamaBulan mengubah **semua** 8
- [ ] What-if demo sesuai tabel di bab 7
- [ ] Angka pratinjau (V1, V8) sesuai tabel di bab 7

---

*Panduan Dashboard — Peramalan Permintaan (Super Sederhana). Blok R in `R/`.*