# 📊 Peramalan Permintaan — Versi Super Sederhana (Power BI + R)

> **Proyek end-to-end** yang dipilih dari `Brainstorming/pilihan/03-peramalan-permintaan`,
> dirapakkan **lebih sederhana lagi**: bahasa sehari-hari, **1 metoda plan saja**
> (*rata-rata 3 bulan terakhir × angka bulan*), **semua trasformasi di Power Query dengan R**,
> **semua visualisasi dengan R visual** (`ggplot2`), dan **semua tabel terkoneksi** sehingga
> slicer menyaring setiap gambar.
>
> **Pertanyaan inti:** *Berapa plan bulan depan? Bilang kapan mesin tidak cukup?*

> Tidak perlu tau statistika untuk memakai proyek ini. Semua yang dibutuhkan hanya
> **aritmetika dasar**: rata-rata, kali, dan membagi.

---

## 1. Gambaran Umum

| Komponen | Keterangan |
| --- | --- |
| **Nama proyek** | Peramalan Permintaan — Versi Super Sederhana |
| **Metoda plan** | `rata-rata 3 bulan terakhir × angka bulan` (1 metoda, tanpa istilah statistika) |
| **Bahasa** | R (`dplyr`/`tidyr` di Power Query; `ggplot2`/`scales` di R visual) |
| **Dataset** | 2 produk × 24 bulan (2024–2025) → plan 6 bulan (2026 Jan–Jun) |
| **Model data** | tabel fakt `ramalan` + dimensi `produk` & `skenario` — **semua terkoneksi** |
| **Luaran** | 1 tabel transformata (R) · 8 R visual · panduan Power BI · angka verifikasi |

**Semua angka di file ini = hasil aktual dari `output/` (bukan perkiraan).**

---

## 2. Struktur Folder

```text
Brainstorming/selected/peramalan-permintaan/
├── README.md                     # file ini (end-to-end, bahasa sederhana)
├── data/
│   ├── permintaan.csv            # fakta: 48 baris (2 produk x 24 bulan)
│   └── produk.csv                # dimensi produk (nama, harga, kapasitas)
├── R/
│   ├── 00_buat_data.R            # generator data (set.seed(20260913))
│   ├── powerquery_01_ramalan.R   # BLOK R -> Power Query -> tabel "ramalan"
│   ├── visual_R_powerbi.R        # 8 BLOK R -> R visual Power BI
│   └── 03_validasi.R             # jalan semua blok lokal -> output/
├── output/                       # ramalan.csv + V1..V8 PNG (pratinjau)
└── powerbi/
    └── panduan-dashboard.md      # langkah-demi-langkah bangun dashboard
```

> Kode R yang ditempel di Power BI **persis sama** dengan yang dijalaman `03_validasi.R`
> (diekstrak dari marker `# >>> BLOK_*_START/END`) — jadi bila jalan di mac = jalan di Power BI.

---

## 3. Cara Menjalankan (validacja lokal, tanpa Power BI)

```bash
cd "Brainstorming/selected/peramalan-permintaan"
Rscript R/00_buat_data.R     # 1x: generate data (set.seed)
Rscript R/03_validasi.R      # jalan blok Power Query + 8 R visual -> output/
```

Luaran: `output/ramalan.csv` (180 baris = riwayat+plan × 3 skenario) + `output/V1…V8.png`.

---

## 4. Data: 2 Produk, 24 Bulan

| Produk | Kategori | HargaSatuan | Kapasitas 1 mesin (unit/bulan) | Tren (ditanam) |
| --- | --- | ---: | ---: | --- |
| **Produk A** | Minuman | Rp 12.000 | 7.000 | +1,0%/bulan (tumbuh) |
| **Produk B** | Makanan | Rp 15.000 | 3.800 | +0,4%/bulan (quasi stabil) |

Data aktual:

| Metrik | Produk A | Produk B |
| --- | ---: | ---: |
| Total 2024 | 67.540 | 39.883 |
| Total 2025 | 76.290 (+13,0%) | 39.801 (±0) |
| Total riwayat 2024–25 | **223.514 unit** | |

**Angka Bulan** (berapa × rata-rata): Desember contoh 1,4× rata-rata; Januari 0,7× rata-rata.

---

## 5. Metoda Plan — Sederhana (1 cara saja)

```text
PLAN bulan ke depan  =  rata-rata 3 bulan terakhir  ×  angka bulan
```

Di kdek negeri:

| Langkah | Perjelasan | Angka contoh (Produk A) |
| --- | --- | --- |
| 1. **Rata-rata 3 bulan terakhir** | rata-rata permintaan Okt–Des 2025 | ≈ 7.024 (level) |
| 2. **Angka bulan** | bulan Januari biasanya 0,7× rata-rata | 0,67 |
| 3. **PLAN Jan 2026** | `7.024 × 0,67` | **≈ 5.231 unit** |

**Cek metode ini** (`CekPlan`): cara yang sama, tetapi 6 bulan lalu — kita cek
*seberapa hampir plan vs aktual* di Jul–Des 2025:

| Produk | Rata-rata selisih (plan vs aktual) |
| --- | ---: |
| Produk A | **10,7%** |
| Produk B | **8,0%** |

Cara baca: "bila plan cara ini 6 bulan lalu, rata-rata selisih 8–11% — cukup baik untuk plan produksi."

Cara baca: "bila plan cara ini 6 bulan lalu, rata-rata di sisi ancak 8–11% kalo" —
---

## 6. Transformasi di Power BI (R di Power Query)

Tempel `R/powerquery_01_ramalan.R` di salah langkah Power Query (**Run R script**).
Input `dataset` = gabung `permintaan` + `produk`; output = variabel `output` = tabel **`ramalan`**.

| Kolom luaran | Keterangan (bahasa sehari-hari) |
| --- | --- |
| `Tanggal, Tahun, BulanKe, NamaBulan` | data bulanan |
| `Produk, Kategori, HargaSatuan, KapasitasMesin` | dimensi produk |
| `Jenis` | `Riwayat` (data real) / `Plan` (bulan maju) |
| `Permintaan` | jumlah unit yang **real** di bulan itu |
| `Plan` | **plan** kita (level × angka bulan), hanya untuk 2026 |
| `CekPlan` | plan yang dibuat 6 bulan lalu (untuk visual **Cek**) |
| `AngkaBulan` | "bulan ini biasanya ...× rata-rata" |
| `Skenario, FaktorSkenario` | what-if: Pesimis 0,90 / Normal 1,00 / Optimis 1,10 |

> Blok ini mengerjakan **semua trasformasi dalam R**: rata3, angka bulan,
> plan, cekPlan, dan cross join skenario. Tidak ada kolom "statistik" ortolan suidak.

---

## 7. Tabel & Konexion (semua tabel terkoneksi via slicer)

Model data di Power BI adalah **star model sederhana**:

```text
produk (1)  ──Produk──<  ramalan (many)   >──Skenario──  (1) skenario
```

* **`ramalan`** = tabel fakt — baris = 1 bulan × 1 produk × 1 skenario.
* **`produk`** = dimensi (2 baris) — slicer **Produk** filter fakt.
* **`skenario`** = dimensi (3 baris, dari query reference `distinct(Skenario, FaktorSkenario)`).

Kenapa penting:

1. **Tidak ada tabel "patah"** (disconnected) → **satu slicer mengubah semua visual**,
   gambar R juga, karena Power BI menyaring baris fakt yang kemudian dimasukan ke R.
2. Slicer `Produk` dan `Skenario` mengubah semua 8 visual (KPI, tren, tabel, dsb.).
3. Slicer `Tahun`/`NamaBulan` (kolom fakt) juga mengubah semua visual yang ber piening
   bulan itu (riwayat vs plan sesuai yang dibutuhkan).

---

## 8. What-if (Skenario)

Slicer `Skenario` mengubah **Fastumbuhan** plan (×0,90 / ×1,00 / ×1,10):

| Skenario | Plan 2026 (unit) | Penjualan 2026 (Rp) | Mesin saat puncak A | Mesin saat puncak B |
| --- | ---: | ---: | ---: | ---: |
| **Pesimis** | 55.058 | Rp 716,9 M | 2 | **1** |
| **Normal** | 61.176 | Rp 796,5 M | 2 | **2** |
| **Optimis** | 67.293 | Rp 876,2 M | 2 | **2** |

**Cek cepat:** plan puncak Produk A (Normal) = **7.924** > kapasitas 7.000 → **butuh 2 mesin**.
Produk B normal = **4.016** > 3.800 → **2 mesin**; pesimis 3.615 < 3.800 → cukup 1.

---

## 9. 8 Visual R (ggplot2) — semuanya filterable

| # | Visual | Field di Values (R visual) | Keterangan |
| --- | --- | --- | --- |
| V1 | **Ringkasan (KPI)** | Produk, Jenis, Tanggal, Permintaan, Plan, CekPlan, FaktorSkenario, Skenario, HargaSatuan, KapasitasMesin | 4 angka: total riwayat · plan 2026 · selisih rata-rata · mesin |
| V2 | **Tren riwayat & plan** | Tanggal, Produk, Jenis, Permintaan, Plan, FaktorSkenario, Skenario | garis penuh = real; garis putus = plan per skenario |
| V3 | **Plan bulan depan** | Jenis, Produk, Tanggal, Plan, FaktorSkenario, Skenario | 1 angka: plan Jan 2026 per produk |
| V4 | **Cek: plan vs aktual** | Jenis, Tanggal, Produk, Permintaan, CekPlan | plan 6 bulan lalu vs aktual (Jul–Des 2025) |
| V5 | **Angka bulan** | Produk, BulanKe, AngkaBulan | "Desember biasanya 1,4× rata-rata" |
| V6 | **Heatmap tahun×bulan** | Jenis, Tanggal, Permintaan | kapan permintaan paling tinggi |
| V7 | **Kapasitas vs puncak** | Jenis, Produk, Tanggal, Skenario, FaktorSkenario, Plan, KapasitasMesin | bar > garis kapasitas = butuh mesin tambahan |
| V8 | **Tabel what-if** | Jenis, Tanggal, Produk, Skenario, FaktorSkenario, Plan, HargaSatuan, KapasitasMesin | skenario row: plan unit · Rp · mesin |

> Pratinjau: `output/V1_kpi.png` … `V8_whatif.png`.

---

## 10. Kenapa Filter Berjalan di Semua Visual

1. **Slicer filter baris fakt.** Slicer `Produk` (dimensi `produk`) & `Skenario` (dimensi `skenario`)
   terkoneksi ke `ramalan` dengan hubungan 1-many. Slicer menyaring baris `ramalan`.
2. **R visual hanya menerima baris terfilter.** Skrip ggplot2 membaca `dataset` (baris yang
   pasas filter) → gambar ikut berubah. Blue membangun `distinct()`/`group_by()` sendiri.
3. **Tidak ada tabel patah** → tidak ada gambar yang "tidak ikut slicer".
4. R visual juga *cross-filter* visual lain (Power BI native behavias).

> Penting: R visual = gambar statis (PNG). Yang interaktif adalah **slicer**,
> bukan elemen dalam gambar. Sertakan semua kolom yang dibutuhan di **Values**.

---

## 11. Panduan Dashboard

Buka **`powerbi/panduan-dashboard.md`** — langkah-demi-langkah (±30–45 menit):
load CSV → gabung query → blok R → **buat konexion tabel (star model)** → 8 R visual → slicer → demo.

---

## 12. Kesimpulan & Rekomendasi

| # | Temuan (bahasa sehari-hari) | Bukti | Rekomendasi |
| --- | --- | --- | --- |
| 1 | Produk A tumbuh +13% dengan puncak Desember | total 76.290 (2025) · angka bulan Des 1,4 | siapkan kapasitas Produk A sebelum Q4 |
| 2 | Metode plan sederhana cukup rapih | selisih rata-rata 10,7% / 8,0% | update plan setiap bulan (rata 3 terakhir) |
| 3 | Puncak plan pasar kapasitas 1 mesin | Produk A 7.924 > 7.000 (normal) | tambah/tutaf mesin Produk A atau perataan puncak |
| 4 | What-if jangka optione secara ulsuk | Optimis: Produk B 4.418 > 3.800 (2 mesin) | bila imbas promosi, tardi plan C mesin B |
| 5 | Skenario penjualan jelas di Rp | Normal Rp 796,5 M vs Optimis Rp 876,2 M | diskusi pihak bisnis pakai slice Skenario |

**Format insight (kondisi → bukti → tindakan):**

> **Kondisi:** permintaan tumbuh dengan puncak Desember sehingga 1 mesin Produk A tidak cukup
> di setiap skenario (puncak plan ≥ 7.132).
> **Bukti:** plan puncak Produk A = 7.924 (normal); kapasitas 1 mesin = 7.000; selisih rata-rata plan 10,7%.
> **Tindakan:** update plan bulanan dengan *rata 3 bulan terakhir × angka bulan*,
> tambah 1 mesin Produk A, dan pakai slicer Skenario untuk simulasi promosi/Pesimis.

---

*README — Peramalan Permintaan (Versi Super Sederhana, Power BI + R). Bagian dari `Brainstorming/selected/`.*
