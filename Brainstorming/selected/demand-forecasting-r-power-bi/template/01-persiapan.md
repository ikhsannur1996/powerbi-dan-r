# 🧪 Training R di Power BI — 90 Menit
## Use Case: Peramalan Permintaan CV Segar Jaya

> **Tujuan sesi:** peserta mampu (1) **mentransformasi data dengan R di Power Query**,
> (2) membuat **R visual (`ggplot2`)** berbentuk grafik yang **tidak ada** di Power BI,
> dan (3) membaca **insight bisnis** dari hasilnya.
>
> **Konteks bisnis (1 paragraf):** CV Segar Jaya menjual 16 SKU (Teh Botol & Keripik
> Kentang; ukuran Kecil/Sedang/Besar) ke 2 pabrik. Rencana produksi masih memakai
> rata-rata, sehingga stok menumpuk di bulan sepi (Januari) dan mesin penuh di bulan
> puncak (November–Desember). Kita membangun **satu tabel rencana** yang menjawab:
> *produksi bulan depan berapa, mesin cukup tidak, dan packing mana yang diprioritaskan?*

| Info | Nilai |
| --- | --- |
| **Durasi** | **90 menit** (agenda di bawah) |
| **Level** | R dasar; Power BI dasar–menengah |
| **Dataset** | `data/permintaan.csv` (1.152 baris) + `produk.csv` (16) + `lokasi.csv` (2) |
| **Metode** | `Plan = median 3 bulan × angka bulan` — **tanpa statistika** |
| **Prasyarat R** | `install.packages(c("dplyr", "tidyr", "ggplot2", "scales"))` |
| **Hasil akhir** | tabel `ramalan` **4.032 baris** + **10 R visual** + 1 halaman dashboard |

> **Cara membaca:** setiap tahap berisi **Tujuan → Kode R → Hasil**. Kode boleh langsung
> disalin ke Power BI. Semua blok diuji otomatis oleh `R/03_validasi.R` (0 warning).

## Agenda

| Menit | Tahap | Hasil yang dilihat peserta |
| ---: | --- | --- |
| 0–5 | **0. Persiapan** | paham data, dimensi, dan outlier |
| 5–25 | **1. Transformasi di Power Query** | tabel `ramalan` (4.032 baris) |
| 25–70 | **2. Sepuluh R visual** | 10 grafik yang ikut slicer |
| 70–85 | **3. Dashboard & insight** | layout + insight kondisi–bukti–tindakan |
| 85–90 | **4. Validasi & penutup** | peserta bisa reproduce sendiri |

---

## Tahap 0 — Persiapan (5 menit)

**Tujuan:** tahu isi data, dan tahu mengapa R dipakai.

### 0.1 Data (star model mini)

```text
  produk (16 SKU) ──┐
                    ├──►  permintaan  (fakta 1.152 baris)  ◄── lokasi (2)
  skenario (3) ─────┘
```

- `permintaan.csv`: `Tanggal, SKU, Lokasi, Permintaan` → 1 baris = 1 bulan × 1 SKU × 1 pabrik.
- `produk.csv`: `SKU, Produk, Kategori, Rasa, Ukuran, UrutanUkuran, JenisPacking, IsiKemasan, HargaSatuan, IsiPerKarton, KapasitasMesin`.
- `lokasi.csv`: `Lokasi, Faktor` → Pabrik A 0,60 dan Pabrik B 0,40.

### 0.2 Dimensi produk (16 SKU)

| Produk | Ukuran (isi) | Packing | Harga | Isi/karton | Kapasitas mesin/bln |
| --- | --- | --- | ---: | ---: | ---: |
| Teh Botol | Kecil (250 ml) | Botol PET | Rp 6.000 | 24 | 4.000 |
| Teh Botol | Sedang (450 ml) | Botol PET / Botol Kaca | Rp 9.000 / 12.000 | 12 | 4.000 |
| Teh Botol | Besar (1.000 ml) | Botol Kaca | Rp 18.000 | 6 | 4.000 |
| Keripik Kentang | Kecil (60 g) | Sachet | Rp 6.500 | 40 | 2.200 |
| Keripik Kentang | Sedang (120 g) | Sachet / Pouch | Rp 11.000 / 15.000 | 24 | 2.200 |
| Keripik Kentang | Besar (250 g) | Pouch | Rp 22.000 | 12 | 2.200 |

### 0.3 Kondisi data: ada outlier

| Kejadian | Faktor | Kapan | Baris |
| --- | --- | --- | ---: |
| Promo | ×1,30 – ×1,85 | lebih sering Mar–Apr & Nov–Des | 34 |
| Gangguan pasokan / mesin | ×0,35 – ×0,65 | acak | 20 |
| Ekstrem (langka) | ×2,20 – ×2,80 | acak | 5 |
| Normal | ×1,00 | — | 1.093 |

Rentang data: **57 – 1.578 unit per baris**; total **59 baris (5,1%)** adalah outlier.

> **Pelajaran kunci #1:** karena ada outlier, sesi ini **tidak memakai rata-rata**, tetapi
> **median**. Rata-rata terseret lonjakan promo; median tidak.

---

## Tahap 1 — Transformasi Data dengan R di Power Query (20 menit)

**Tujuan:** membentuk tabel **`ramalan`** = riwayat 36 bulan **+** rencana 6 bulan × 3 skenario.

### 1.1 Langkah di Power BI Desktop

1. **Get Data > Text/CSV** → impor 3 file CSV.
2. **Transform Data** → klik query `permintaan` → **Merge Queries** dengan `produk`
   (kolom kunci `SKU`) → expand semua kolom produk.
3. Merge lagi dengan `lokasi` (kunci `Lokasi`) → expand `Faktor`
   → rename query menjadi **`ramalan_sumber`** (1.152 baris × 15 kolom).
4. **Transform > Run R script** → tempel kode pada §1.2 → **OK**.
5. Power BI mengenali objek **`output`** → rename query hasilnya menjadi **`ramalan`**.
6. **File > Options and settings > Options > Privacy** → pilih
   *Always ignore privacy levels* → **OK** (agar skrip R tidak diblokir).
7. **Close & Apply**.

### 1.2 Kode R (salin-tempel)

@@KODE_PQ@@

### 1.3 Apa yang dilakukan kode itu

| Langkah | Arti sederhana |
| --- | --- |
| `AngkaBulan` | “bulan ini biasanya berapa kali rata-rata?” (per produk; penyebut = **median 12 bulan**) |
| `Level` | **median** Okt–Des 2025 per SKU per pabrik → tahan terhadap outlier |
| `Plan` | `Level × AngkaBulan` untuk Jan–Jun 2026 |
| `Skenario` | setiap baris dikali 3: Pesimis ×0,90 · Normal ×1,00 · Optimis ×1,10 |

### 1.4 Hasil

```text
dataset (hasil merge) : 1152 baris x 15 kolom
ramalan (output)      : 4032 baris  = (1152 riwayat + 192 rencana) x 3 skenario
```

Contoh isi tabel `ramalan` (satu SKU, satu pabrik):

@@TABEL_RAMALAN@@

> `Permintaan` hanya terisi saat `Jenis = "Riwayat"`; `Plan` hanya saat `Jenis = "Plan"`.
> Nama bulan & `AngkaBulan` ikut terbawa agar bisa dipakai visual.

---
