# Materi 12 — Merubah Bentuk Data (tidyr: pivot & split)

> Pendamping Volume 0 · Waktu baca ±15 menit · Package: `tidyr`.
> Dataset: `qc_hasil_produksi.csv` (458 baris transaksi harian).

---

## 1. Materi singkat — data yang rapi (tidy data)

Aturan tidy data: **setiap baris = satu observasi, setiap kolom = satu variabel**. Di lapangan data sering "lebar" (wide) atau "pecah" (split) dan perlu dibentuk ulang:

| Fungsi | Arah | Guna |
| --- | --- | --- |
| `pivot_longer()` | lebar → panjang | kolom nilai gabung jadi 2 kolom `key` + `value` (untuk ggplot `facet`) |
| `pivot_wider()` | panjang → lebar | jadikan tabel matriks (layout Excel / Power BI matrix) |
| `separate()` | 1 kolom → 2 | pecah `"Line-A"` jadi `"Line"` dan `"A"` |
| `unite()` | 2 kolom → 1 | gabung kolom jadi satu ID |

`pivot_wider` butuh  argumen `names_from` (kolom yang nama-namanya jadi kolom baru) dan `values_from` (kolom angkanya). Tambahkan `values_fill = 0` untuk mengisi sel kosong.

---

## 2. Contoh 1 — `pivot_longer()`: kumpulan kolom pengukur → format ggplot

```r
library(dplyr)
library(tidyr)

produksi <- read.csv("qc_hasil_produksi.csv", stringsAsFactors = FALSE)

produksi |>
  slice(1:2) |>
  select(Tanggal, TempC, HumidityPct, EnergyKWh) |>
  pivot_longer(-Tanggal, names_to = "Variabel", values_to = "Nilai")
```

Output:

```text
  Tanggal    Variabel    Nilai
1 2026-07-01 TempC        26.4
2 2026-07-01 HumidityPct  70
3 2026-07-01 EnergyKWh    23.0
4 2026-07-01 TempC        26.0
5 2026-07-01 HumidityPct  73
6 2026-07-01 EnergyKWh    38.2
```

Penjelasan: 3 kolom pengukur (TempC, HumidityPct, EnergyKWh) "dipanjangkan" menjadi 2 kolom: `Variabel` (nama) dan `Nilai` (angka). Sekarang mudah di-`group_by(Variabel)` atau di-`facet_wrap(~ Variabel)` di ggplot2. Ini pola persis yang dipakai sebelum visualisasi multi-variabel (lihat Materi 15).

## 3. Contoh 2 — Persiapkan data ringkasan bulanan

```r
library(lubridate)

bulanan <- produksi |>
  mutate(Bulan = floor_date(as.Date(Tanggal), "month")) |>
  group_by(Lini, Bulan) |>
  summarise(Defect = sum(UnitsDefect), .groups = "drop")

bulanan
```

Output:

```text
# A tibble: 9 × 3
  Lini  Bulan      Defect
  <chr> <date>      <int>
1 A     2026-07-01   2268
2 A     2026-08-01   2239
3 A     2026-09-01   2003
4 B     2026-07-01   3305
5 B     2026-08-01   2945
6 B     2026-09-01   2928
7 C     2026-07-01   1888
8 C     2026-08-01   1986
9 C     2026-09-01   1766
```

## 4. Contoh 3 — `pivot_wider()`: jadikan matriks baris = lini, kolom = bulan

```r
bulanan |>
  pivot_wider(names_from = Bulan, values_from = Defect, values_fill = 0)
```

Output:

```text
# A tibble: 3 × 4
  Lini  `2026-07-01` `2026-08-01` `2026-09-01`
  <chr>        <int>        <int>        <int>
1 A              2268         2239         2003
2 B              3305         2945         2928
3 C              1888         1986         1766
```

Penjelasan: bentuk ini cocok untuk *matrix visual* Power BI / tabel laporan. Baca baris B: 3305 → 2945 → 2928 (turun). `values_fill = 0` mengganti bulan yang tidak ada data menjadi 0 (daripada `NA`).

## 5. Contoh 4 — `separate()` & `unite()`: pecah/gabung kolom teks

```r
# separate: "Line-A" -> "Line" dan "A"
separate(data.frame(x = c("Line-A", "Line-B")), x,
         into = c("Kata", "Suffix"), sep = "-")

# unite: gabungkan dua kolom menjadi satu ID
unite(data.frame(Line = c("A", "B"), Nomor = c(1, 2)),
      ID, Line, Nomor, sep = "-")
```

Output:

```text
  Kata Suffix
1 Line      A
2 Line      B
  ID
1 A-1
2 B-2
```

Penjelasan: `separate()` berguna saat satu kolom membawa dua informasi (mis. `"Lini-Shift"`). `unite()` kebalikannya — membuat kolom ID gabungan sebelum join antar tabel.

---

## 6. Coba sendiri (±7 menit)

1. Panjangkan kolom `UnitsProduced`, `UnitsDefect`, `DowntimeMin` dari 2 baris pertama `produksi` (sama seperti contoh 1). Berapa baris hasilnya? (Acuan: 2 baris × 3 kolom = `6`.)
2. Dari `bulanan`, buat versi lebar pakai `pivot_wider(names_from = Lini, values_from = Defect)`. Kolom apa yang jadi nama kolom baru?
3. Buat `deret <- data.frame(ShiftMesin = c("Pagi-M01", "Sore-M02"))`. Pakai `separate(..., sep = "-", into = c("Shift", "Mesin"))`. Tampilkan hasilnya.
4. Jelaskan satu kalimat: kapan `pivot_longer()` lebih bermanfaat daripada `pivot_wider()`? (Petunjuk: arah untuk ggplot `facet`.)

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 13](latihan-13-tanggal-lubridate.md)