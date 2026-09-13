## Tahap 3 — Dashboard & Insight Bisnis (15 menit)

**Tujuan:** mengubah grafik menjadi keputusan. Format insight: **Kondisi → Bukti → Tindakan**.

### 3.1 Insight utama (dari grafik yang baru dibuat)

| # | Kondisi | Bukti (angka) | Tindakan |
| --- | --- | --- | --- |
| 1 | Rencana produksi seragam sepanjang tahun | Januari hanya **0,76×** rata-rata, Desember **1,43×** (V5, V10) | pakai *Angka Bulan*: turunkan rencana Jan–Mar, naikkan Nov–Des |
| 2 | Kapasitas mesin tidak cukup | butuh **7 mesin** vs **4** terpasang; Pabrik A butuh 4 → **kurang 2** (V4) | tambah 3 mesin sebelum kuartal IV, prioritas Pabrik A lini Teh Botol |
| 3 | Pasar bergeser ke ukuran **Besar** | Kecil 24,3%→**19,0%** (Teh Botol), 30,5%→**24,3%** (Keripik); Besar **+5 poin** (V6, V7) | tambah alokasi ukuran Besar, kurangi tekanan ukuran Kecil |
| 4 | Nilai naik lebih cepat daripada unit | 2025: unit **+8,3%** vs nilai **+11,9%**; ASP naik 11.680 → **12.349** (V9) | pertahankan harga, jaga kecukupan kemasan premium |
| 5 | Packing premium makin dominan | Botol Kaca **65,2%** & Pouch **67,4%** dari nilai 2025 (V8) | kontrak volume kemasan premium lebih awal |
| 6 | Outlier promo/gangguan mengganggu rencana | **59 baris (5,1%)** outlier; selisih metode naik ±1–2 poin bila bulan ekstrem ikut dihitung | pakai **median**, dan tandai bulan promo di kalender |
| 7 | Pergeseran bauran menambah nilai | **+Rp 110 juta (+6,4%)** nilai 2025 dibanding bauran 2023 | jadikan bauran (mix) sebagai KPI komersial |

### 3.2 Rekomendasi prioritas

| Prioritas | Aksi | Ukuran keberhasilan | Tenggat |
| ---: | --- | --- | --- |
| **1** | Jadikan tabel `ramalan` **satu sumber kebenaran** rencana produksi | dipakai pada rapat bulanan | 30 hari |
| **2** | Tambah **3 mesin** (fokus Pabrik A lini Teh Botol) | nol kehabisan stok Nov–Des | sebelum Oktober |
| **3** | Sesuaikan pengadaan kemasan premium (Kaca & Pouch) | selisih pengadaan < 5% | kuartal ini |
| **4** | Kebijakan stok per ukuran: tambah Besar, kurangi Kecil | sisa stok bulan sepi −20% | 60 hari |
| **5** | Tandai bulan promo + refresh model bulanan | selisih rencana < 10% | 90 hari |

### 3.3 Kriteria lulus latihan

- [ ] Tabel **`ramalan`** terbentuk (4.032 baris) dari R di Power Query.
- [ ] Minimal **6 R visual** berhasil dijalankan dan **ikut berubah** saat slicer diubah.
- [ ] Bisa menjelaskan **mengapa median**, bukan rata-rata.
- [ ] Bisa menjelaskan **mengapa bentuk grafik V2–V7, V9, V10 tidak ada** di Power BI.
- [ ] Menuliskan **1 insight** dengan format kondisi–bukti–tindakan.

---

## Tahap 4 — Validasi & Reproduce (5 menit)

**Tujuan:** membuktikan seluruh kode bisa dijalankan **tanpa Power BI** (dan angka selalu sama).

```bash
cd "Brainstorming/selected/demand-forecasting-r-power-bi"
Rscript R/00_buat_data.R     # buat ulang data + outlier (set.seed, angka tetap)
Rscript R/03_validasi.R      # jalankan semua blok dari file R, render 10 PNG
Rscript R/04_buat_readme.R   # hanya bila kode R diubah: regenerate README.md
```

**Hasil (0 warning):**

```text
dataset Power Query : 1152 baris x 15 kolom
ramalan.csv         : 4032 baris
Rendered: V1_kpi.png ... V10_musiman_overlay.png   (10 PNG)

Outlier (|x - median SKU| > 3 x MAD) : 27 baris (2.3%)

Back-test (24 bulan, 576 baris uji):
        semua bulan : median 11,0-12,0%  vs rata-rata 11,8-14,0%
tanpa bulan ekstrem: median 10,3-10,4%  vs rata-rata 11,3-12,6%

Plan 2026 (unit)   : Normal 81.390 | Optimis 89.529 | Pesimis 73.251
Kebutuhan mesin    : 7 unit butuh, 4 terpasang -> kurang 3
```

> **Pelajaran kunci #3:** median selalu lebih baik daripada rata-rata pada data ber-outlier,
> dan `03_validasi.R` mengekstrak blok kode langsung dari file `R/` sehingga kode di README,
> Power Query, dan R visual tidak mungkin berbeda.

---

## Lampiran

### A. Struktur folder

```text
demand-forecasting-r-power-bi/
├── README.md                # tutorial ini (dihasilkan otomatis)
├── data/                    # permintaan.csv (1.152) · produk.csv (16) · lokasi.csv (2)
├── R/
│   ├── 00_buat_data.R       # generator data + outlier (set.seed 20260913)
│   ├── 01_transformasi.R    # BLOK_PQ_01  -> Tahap 1 (Power Query)
│   ├── 02_visual.R          # BLOK_RV_V1..V10 -> Tahap 2 (R visual)
│   ├── 03_validasi.R        # uji semua blok + render 10 PNG
│   └── 04_buat_readme.R     # menyusun README.md dari template/
├── template/                # sumber teks README (5 bagian berurutan)
└── output/                  # ramalan.csv + V1..V10 PNG
```

### B. Kode pendukung

| File | Isi | Kapan dijalankan |
| --- | --- | --- |
| `R/00_buat_data.R` | generator data + penyuntikan outlier | sekali sebelum pelatihan |
| `R/03_validasi.R` | mengekstrak blok dari file R, menjalankannya, mencetak semua angka | Tahap 4 |
| `R/04_buat_readme.R` | menyusun README dari `template/` + menyuntikkan blok kode asli | hanya bila kode R diubah |

> Kode generator & validator **tidak diulang** di README agar dokumen tetap ringkas —
> file-nya ada di folder yang sama dan komentarnya sudah lengkap.
> `Rscript R/04_buat_readme.R` menjamin kode di README **selalu sama** dengan kode di folder `R/`.

### C. Referensi cepat R yang dipakai

| Fungsi | Untuk apa | Muncul di |
| --- | --- | --- |
| `group_by()` + `summarise()` | agregasi per bulan/produk/pabrik | PQ, V3–V8 |
| `filter()` + `distinct()` | memilih baris & membuang duplikat 3 skenario | semua visual |
| `mutate()` | membuat kolom turunan (`Plan`, `AngkaBulan`) | PQ, visual |
| `median()` | peringkas tahan outlier | PQ, back-test |
| `left_join()` / `crossing()` | menggabungkan dimensi & membentuk skenario | PQ |
| `ggplot()` + `geom_*()` | `boxplot`, `violin`, `tile`, `segment`, `point`, `col`, `line`, `smooth` | V1–V10 |
| `scale_*_manual()` / `scale_fill_gradient()` | warna & label format | V1, V2, V5, V6, V7 |
| `facet_wrap()` | — | **tidak dipakai untuk produk** (produk = slicer) |

---

*Akhir dokumen — semua angka dapat direproduksi dari `set.seed(20260913)`.*
