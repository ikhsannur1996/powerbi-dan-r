# Training Power BI dengan R

## Ringkasan Undangan

Paket ini disusun berdasarkan undangan/Term of Reference (TOR) **Training Hardskill Vol. 2** dengan tema:

> **Insight to Impact: Elevating Power BI with R**

Fokus pelatihan adalah menggabungkan Power BI dan R untuk menghasilkan analisis yang lebih reproducible, terutama pada:

- data preparation dan data cleaning menggunakan R di Power Query;
- analisis statistik dan pembuatan metrik turunan;
- visualisasi `ggplot2` di dalam Power BI;
- penyusunan dashboard yang menghasilkan insight dan rekomendasi tindakan.

### Sasaran peserta

- Asisten Laboratorium ADRK dan peserta Teknik Industri.
- Peserta dengan kemampuan dasar hingga menengah dalam Power BI dan statistik.
- Peserta yang masih memiliki sedikit pengalaman dalam mengintegrasikan R dengan Power BI.

### Waktu dan format

- **Durasi:** 2 jam, pukul 10.00-12.00 WIB.
- **Tanggal pada undangan:** 20 September 2026.
- **Format:** hybrid.
- **Target akhir:** dashboard Power BI profesional yang menggabungkan visual native Power BI dan visual R.

## Tujuan Pembelajaran

Pada akhir sesi, peserta diharapkan mampu:

1. Menjelaskan peran R dan Power BI dalam alur kerja analitik.
2. Membersihkan dan membentuk data menggunakan R di Power Query.
3. Membuat visualisasi `ggplot2` yang merespons filter Power BI.
4. Menggabungkan KPI, visual native, dan R visual dalam satu dashboard.
5. Menyampaikan insight berbasis data beserta tindakan yang disarankan.

## Skenario Hands-on

Peserta berperan sebagai analis kualitas yang membantu laboratorium memantau inspeksi beberapa lini produksi.

Pertanyaan utama latihan:

> **Lini dan jenis defect mana yang perlu diprioritaskan untuk perbaikan bulan berikutnya?**

Dashboard minimal harus memuat:

- tabel hasil cleaning bernama `CleanData`;
- KPI total inspected, total defect, defect rate, dan first pass yield;
- satu visual native Power BI;
- satu visual `ggplot2` yang berubah ketika slicer digunakan;
- satu insight dengan format kondisi, bukti, dan tindakan.

## Agenda 120 Menit

| Waktu | Kegiatan | Hasil |
| --- | --- | --- |
| 10 menit | Pembukaan dan konteks bisnis | Peserta memahami tujuan integrasi Power BI dan R |
| 15 menit | Konsep alur kerja Power BI + R | Peserta memahami posisi Power Query, R visual, dan data model |
| 15 menit | Demo import dan cleaning | Tabel `CleanData` terbentuk |
| 15 menit | Demo KPI dan visual native | KPI dan visual perbandingan lini tersedia |
| 30 menit | Hands-on terpandu | Peserta membangun bagian utama dashboard |
| 20 menit | R visual dengan `ggplot2` | Visual tren/pola defect merespons filter |
| 10 menit | Penyusunan insight | Peserta menulis bukti dan rekomendasi |
| 5 menit | Review dan penutup | Hasil latihan diperiksa |

## Isi Paket

| Berkas | Kegunaan |
| --- | --- |
| `Materi_Training_Power_BI_dengan_R.md` | Panduan pengajar, konsep, contoh kode, rancangan dashboard, dan evaluasi |
| `Hands-on_Power_BI_dengan_R.md` | Lembar kerja peserta dengan langkah praktik terpandu |
| `README_Basic_R.md` | Modul lengkap Basic R, data manipulation, visualisasi, dan statistical analysis |
| `quality_inspection.csv` | Dataset inspeksi kualitas untuk latihan |
| `quality_inspection_cleaning.R` | Skrip cleaning dan pembentukan metrik di Power Query |
| `README.md` | Ringkasan undangan dan petunjuk penggunaan paket |
| `Term of Reference (TOR) Training Hardskill Vol. 2 (Pak Ikhsan).docx.pdf` | Dokumen undangan/TOR sumber |

## Prasyarat Teknis

- Power BI Desktop dengan akses Power Query dan R visual.
- R atau RStudio.
- Paket R: `dplyr`, `lubridate`, `ggplot2`, dan `scales`.
- Dataset `quality_inspection.csv`.

Instal paket R sebelum pelatihan:

```r
install.packages(c("dplyr", "lubridate", "ggplot2", "scales"))
```

Power BI Desktop tidak tersedia secara native di macOS. Peserta macOS perlu memakai komputer Windows, Windows virtual machine, atau lingkungan laboratorium untuk menjalankan bagian Power BI. RStudio dan skrip R tetap dapat disiapkan di macOS.

## Cleansing dengan `dplyr`

Cleansing dilakukan di Power Query melalui **Transform > Run R script**. Power BI menyediakan tabel input dengan nama `dataset`. Dengan `dplyr`, proses cleaning dapat ditulis secara reproducible dan dijalankan kembali ketika data diperbarui.

Contoh tahapan cleansing:

1. Mengubah tanggal dan kolom numerik ke tipe data yang sesuai.
2. Menyamakan format `Line` dan `Product` dengan menghapus spasi serta menormalkan teks.
3. Mengganti `DefectType` yang kosong menjadi `NONE`.
4. Menghapus inspeksi yang tidak valid, misalnya `Inspected <= 0` atau jumlah defect melebihi jumlah inspeksi.
5. Membuat `DefectRate`, `FirstPassYield`, `Month`, dan `QualityFlag`.

```r
library(dplyr)
library(lubridate)

CleanData <- dataset |>
	mutate(
		InspectionDate = as.Date(InspectionDate),
		Line = trimws(toupper(Line)),
		Product = trimws(Product),
		DefectType = trimws(DefectType),
		DefectType = if_else(is.na(DefectType) | DefectType == "", "NONE", DefectType),
		Inspected = as.integer(Inspected),
		Defect = as.integer(Defect),
		CycleTimeSec = as.numeric(CycleTimeSec)
	) |>
	filter(
		!is.na(InspectionDate),
		!is.na(Inspected),
		Inspected > 0,
		!is.na(Defect),
		Defect >= 0,
		Defect <= Inspected
	) |>
	mutate(
		DefectRate = Defect / Inspected,
		FirstPassYield = 1 - DefectRate,
		Month = floor_date(InspectionDate, unit = "month"),
		QualityFlag = if_else(DefectRate > 0.05, "Above target", "On target")
	)
```

Setelah skrip dijalankan, pilih output `CleanData` pada Navigator Power Query lalu gunakan **Close & Apply**. Detail langkah praktik tersedia di `Hands-on_Power_BI_dengan_R.md`, sedangkan skrip lengkap tersedia di `quality_inspection_cleaning.R`.

## Urutan Pelaksanaan

1. Baca `Materi_Training_Power_BI_dengan_R.md` sebagai panduan pengajar.
2. Siapkan Power BI Desktop, R/RStudio, paket R, dan dataset.
3. Gunakan `Hands-on_Power_BI_dengan_R.md` sebagai lembar kerja peserta.
4. Impor CSV ke Power BI melalui **Get data > Text/CSV**.
5. Jalankan `quality_inspection_cleaning.R` melalui **Transform > Run R script**.
6. Gunakan output `CleanData` untuk membuat KPI, visual native, slicer, dan R visual.
7. Tutup sesi dengan insight dan rekomendasi perbaikan yang didukung data.

## Kriteria Keberhasilan

Peserta mencapai target apabila dapat:

- menghasilkan `CleanData` tanpa baris inspeksi yang tidak valid;
- menampilkan empat KPI dengan nilai yang konsisten;
- membuat minimal satu visual native dan satu R visual;
- menunjukkan bahwa visual R berubah saat slicer digunakan;
- menjelaskan minimal satu insight, bukti pendukung, dan tindakan lanjutan.

## Catatan Penggunaan R Visual

R visual dirender sebagai gambar. Filter dan cross-filter dari Power BI tetap dapat memengaruhi data yang dikirim ke R, tetapi elemen di dalam gambar tidak memiliki interaksi seperti visual native. Kolom yang diperlukan harus dimasukkan ke bagian **Values** pada R visual.
