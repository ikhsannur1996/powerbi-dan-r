### V7 — Slope chart: pergeseran pangsa ukuran 2023 → rencana 2026

Menjawab *bauran bergeser ke mana?* Kemiringan garis = arah pergeseran. Garis **Besar**
naik, **Kecil** turun, **Sedang** relatif stabil.

**Values:** `Tanggal, Produk, Ukuran, SKU, Lokasi, Jenis, Permintaan, Plan, Skenario`

@@KODE_V7@@

![Visual 7 — Slope pangsa ukuran](output/V7_slope_pangsa_ukuran.png)

### V8 — Heatmap: ukuran × jenis packing

Menjawab *packing mana yang volumenya besar?* Sel gelap = volume besar. Sel kosong berarti
kombinasi ukuran–packing itu memang tidak ada.

**Values:** `Produk, Ukuran, JenisPacking, SKU, Lokasi, Jenis, Plan, Skenario`

@@KODE_V8@@

![Visual 8 — Peta ukuran dan packing](output/V8_peta_ukuran_packing.png)

### V9 — Line + penghalus LOESS + pita keyakinan 95%

Tiga lapis: garis abu = aktual bulanan, garis biru + pita = **tren halus beserta rentang
keyakinan**, garis merah putus-putus = rencana 2026. Inilah yang tidak bisa dilakukan
line chart default Power BI.

**Values:** `Tanggal, Produk, SKU, Lokasi, Jenis, Permintaan, Plan, Skenario`

@@KODE_V9@@

![Visual 9 — Tren LOESS](output/V9_tren_loess.png)

### V10 — Overlay musiman: satu garis per tahun (Jan–Des)

Sumbu X bukan tanggal, melainkan **bulan 1–12**, sehingga pola musiman semua tahun
langsung **sebanding**. Garis tebal putus-putus = rencana 2026.

**Values:** `Tanggal, Produk, SKU, Lokasi, Jenis, Permintaan, Plan, Skenario`

@@KODE_V10@@

![Visual 10 — Overlay musiman](output/V10_musiman_overlay.png)

### 2.4 Rancangan halaman dashboard

| Zona | Isi |
| --- | --- |
| **Atas** | V1 Kartu KPI |
| **Baris 1** | V9 Tren LOESS · V10 Overlay musiman |
| **Baris 2** | V3 Lollipop (rencana per ukuran) · V4 Dumbbell (mesin) |
| **Baris 3** | V2 Boxplot tahunan · V6 Violin ukuran |
| **Baris 4** | V7 Slope pangsa · V8 Heatmap packing |
| **Sisi kanan** | V5 Radial angka bulan |
| **Slicer (kiri atas, tinggi)** | `Produk`, `Skenario`, `Ukuran`, `JenisPacking`, `Lokasi`, `Tanggal` |

---
