## Tahap 2 — Visualisasi dengan R Visual (45 menit)

**Tujuan:** membuat **10 grafik** yang tidak tersedia di galeri native Power BI.

### 2.1 Dua aturan filter

| Kolom | Peran | Perilaku |
| --- | --- | --- |
| `Skenario` | **slicer saja** | grafik menampilkan **1 skenario**; kode memprioritaskan `Normal` |
| `Produk` | **slicer saja** | produk **tidak** dipakai sebagai facet/warna/sumbu; bila 2 produk dipilih, angkanya digabung |

> **Pelajaran kunci #2:** slicer hanya bekerja jika kolomnya ada di **Values** visual R.

### 2.2 Bentuk grafik dan padanannya di Power BI

| Visual | Bentuk | Ada di galeri native Power BI? |
| --- | --- | --- |
| V1 | Kartu KPI 2×2 | ada (Card) — ini versi 1-visual |
| V2 | **Boxplot** + titik + outlier | **tidak** |
| V3 | **Lollipop** (dot & stem) | **tidak** |
| V4 | **Dumbbell** (mesin terpasang vs butuh) | **tidak** |
| V5 | **Radial / rose chart** | **tidak** |
| V6 | **Violin + boxplot** | **tidak** |
| V7 | **Slope chart** | **tidak** |
| V8 | Heatmap ukuran × packing | ada (Matrix) |
| V9 | **Line + penghalus LOESS + pita keyakinan 95%** | **tidak** |
| V10 | **Overlay musiman** 1 garis per tahun | **tidak** |

### 2.3 Cara menempel kode

1. Klik kanvas → **Visualizations > R**.
2. Seret kolom ke **Values** sesuai daftar tiap visual; kolom angka → **Do not summarize**.
3. **Run script** → grafik muncul.
4. Ubah slicer → grafik **rendah ulang** mengikuti filter.

### V1 — Kartu KPI: 4 angka kunci

Menjawab: *berapa total 3 tahun, berapa rencana 2026, berapa nilainya, cukup berapa mesin?*

**Values:** `Tanggal, SKU, Produk, Rasa, Ukuran, JenisPacking, Lokasi, Jenis, Permintaan, Plan, Skenario, HargaSatuan, KapasitasMesin`

@@KODE_V1@@

![Visual 1 — Kartu KPI](output/V1_kpi.png)

### V2 — Boxplot: sebaran permintaan per tahun + sebaran rencana 2026

**Values:** `Tanggal, Produk, SKU, Lokasi, Jenis, Permintaan, Plan, Skenario`

@@KODE_V2@@

![Visual 2 — Boxplot tahunan](output/V2_boxplot_tahunan.png)

> **Pertanyaan yang sering muncul: “kenapa kotak Plan 2026 kosong?”**
> Karena rencana dulu **dirangkum jadi satu nilai** (median 6 bulan) sehingga tidak ada
> sebaran — yang tergambar hanya 1 titik. Perbaikannya: **biarkan 6 nilai bulanan**
> (Jan–Jun 2026) dan biarkan `geom_boxplot` yang merangkumnya. Sekarang kotaknya terisi,
> dan garis median memisahkan rencana dari riwayat.

---
