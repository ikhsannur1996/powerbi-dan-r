### V3 — Lollipop: rencana Januari 2026 per ukuran

Menjawab *berapa unit untuk Kecil / Sedang / Besar bulan depan?* Pilih satu produk di
slicer → angkanya persis untuk produk itu.

**Values:** `Tanggal, Produk, Ukuran, SKU, Lokasi, Jenis, Plan, Skenario`

@@KODE_V3@@

![Visual 3 — Lollipop rencana per ukuran](output/V3_lollipop_planbulan.png)

### V4 — Dumbbell: mesin terpasang vs mesin dibutuhkan per pabrik

Menjawab *kapan mesin tidak cukup dan berapa yang perlu ditambah?* Titik hijau = terpasang,
titik merah = dibutuhkan pada bulan puncak.

**Values:** `Tanggal, Produk, SKU, Lokasi, Jenis, Plan, Skenario, KapasitasMesin`

@@KODE_V4@@

![Visual 4 — Dumbbell kebutuhan mesin](output/V4_dumbbell_kapasitas.png)

### V5 — Radial (rose): ritme musiman / Angka Bulan

Menjelaskan **mengapa rencana tidak boleh memakai rata-rata** — Januari ≈ 0,76×,
Desember ≈ 1,4×. Bar merah = bulan di atas rata-rata.

**Values:** `Produk, BulanKe, AngkaBulan`

@@KODE_V5@@

![Visual 5 — Radial Angka Bulan](output/V5_radial_angkabulan.png)

### V6 — Violin: sebaran permintaan per ukuran + outlier

Menunjukkan kepadatan data per ukuran; **titik merah = outlier** promo/gangguan,
sehingga terlihat ukuran mana yang paling terpengaruh.

**Values:** `Tanggal, Produk, SKU, Ukuran, Lokasi, Jenis, Permintaan`

@@KODE_V6@@

![Visual 6 — Violin per ukuran](output/V6_violin_ukuran.png)

---
