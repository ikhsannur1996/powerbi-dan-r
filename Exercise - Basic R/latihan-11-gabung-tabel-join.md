# Materi 11 — Gabungkan Tabel (dplyr Joins)

> Pendamping Volume 0 · Waktu baca ±15 menit.
> Dataset: `quality_inspection.csv` (48 baris), `qc_produk.csv` (master produk + harga), `qc_operator.csv` (master operator), `qc_hasil_produksi.csv` (458 baris produksi harian).

---

## 1. Materi singkat — mengapa perlu join

Data di dunia nyata terpecah di beberapa tabel. Join = menyatukan dua tabel berdasarkan **kolom kunci** (key).

| Jenis | Semantik | Kapan dipakai |
| --- | --- | --- |
| `left_join(x, y)` | semua baris `x` + cocok di `y` (\<NA> jika tak ada) | default — tetap awetkan data utama |
| `inner_join(x, y)` | hanya baris yang cocok di kedua tabel | data lengkap dua-duanya |
| `right_join(x, y)` | kebalikan left (semua `y`) | jarang; ganti x↔y saja |
| `full_join(x, y)` | gabungan semua baris | rekap master vs transaksi |
| `anti_join(x, y)` | baris `x` yang **tidak** cocok | audit: data yatim/piatu |
| `semi_join(x, y)` | baris `x` yang cocok (tanpa kolom y) | filter sekaligus cek kunci |

Sintaks dasar: `left_join(x, y, by = "KunciSama")`. Kalau nama kolom beda: `by = c("Product" = "Produk")` (x punya `Product`, y punya `Produk`).

---

## 2. Contoh 1 — `left_join()`: tambah harga produk ke inspeksi

```r
library(dplyr)
quality <- read.csv("quality_inspection.csv")
produk  <- read.csv("qc_produk.csv")   # master: Produk, Kategori, HargaSatuan, TargetDefectRate

gabung <- quality |>
  left_join(produk, by = c("Product" = "Produk")) |>
  mutate(DefectRate = Defect / Inspected)

gabung |> select(Line, Product, Defect, Inspected, DefectRate, HargaSatuan, TargetDefectRate) |> head(3)

nrow(quality)   # 48 (tetap 48 — left_join tidak menambah baris)
```

Output:

```text
  Line Product Defect Inspected DefectRate HargaSatuan TargetDefectRate
1    A Bracket      5       120   0.0417       15000             0.03
2    A Bracket      3       115   0.0261       15000             0.03
3    B Bracket      9       130   0.0692       15000             0.03
[1] 48
```

Penjelasan: tiap baris inspeksi kini "menempel" `Kategori`, `HargaSatuan`, `TargetDefectRate` dari master produk. Kolom kunci `Product` (inspeksi) cocok dengan `Produk` (master) — karena namanya beda, kita tulis `by = c("Product" = "Produk")`.

## 3. Contoh 2 — Membandingkan actual vs target defect rate

```r
gabung |>
  group_by(Product) |>
  summarise(
    TotalDefect = sum(Defect),
    Harga       = first(HargaSatuan),
    Target      = first(TargetDefectRate),
    .groups     = "drop"
  )

gabung |> filter(DefectRate > TargetDefectRate) |> nrow()   # 24 baris melebihi target
gabung |> filter(DefectRate > TargetDefectRate) |> count(Product)
```

Output:

```text
# A tibble: 2 × 4
## 4. Contoh 3 — `anti_join()`: audit data yang tidak ada di master

```r
produksi <- read.csv("qc_hasil_produksi.csv")   # 458 baris transaksi harian

produksi |> anti_join(produk, by = c("Product" = "Produk")) |>
  select(Tanggal, Lini, Product, UnitsProduced) |>
  head(3)
```

Output:

```text
     Tanggal Lini Product UnitsProduced
1 2026-07-18    A  Casing           812
2 2026-08-21    A  Casing           789
3 2026-08-31    A  Casing           804
```

Penjelasan: ada produk **"Casing"** (6 baris) yang tidak ada di master `qc_produk.csv`. Ini data "yatim" (orphan). Kalau di-join tanpa diperiksa, kolom harga produk itu jadi `NA` — dan `sum()` ikut `NA`. `anti_join()` dipakai untuk **audit master** sebelum menghitung uang (contoh 4).

## 5. Contoh 4 — Join 3 tabel + peringatan NA (kasus nyata)

```r
operator <- read.csv("qc_operator.csv", stringsAsFactors = FALSE)   # master operator

produksi2 <- produksi |>
  filter(Product != "Casing") |>
  left_join(operator, by = "OperatorID", suffix = c("", "_op")) |>
  left_join(produk,   by = c("Product" = "Produk"))

produksi2 |> select(Tanggal, OperatorID, Nama, Lini, Product, HargaSatuan) |> head(2)

produksi2 |>
  group_by(Lini) |>
  summarise(
    Produksi  = sum(UnitsProduced),
    Defect    = sum(UnitsDefect),
    NilaiRugi = sum(UnitsDefect * HargaSatuan),   # dalam rupiah (defect × harga)
    .groups   = "drop"
  )
```

Output:

```text
     Tanggal OperatorID          Nama Lini Product HargaSatuan
1 2026-07-01       OP01  Budi Santoso     A Bracket       15000
2 2026-07-01       OP02     Siti Rahma     A Bracket       15000

# A tibble: 3 × 4
  Lini  Produksi Defect NilaiRugi
  <chr>    <int>  <int>     <int>
1 A       173417   6432 110430000
2 B       173115   9178 100992000
3 C       178054   5640 415365000
```

Penjelasan: (1) `suffix = c("", "_op")` mengantisipasi nama kolom ganda (`Lini` transaksi vs `Lini_op` dari master operator). (2) Setelah `Casing` dibuang, `HargaSatuan` selalu ada — hitungan `NilaiRugi` (defect × harga) valid. Urutan terburuk dari sisi **uang**: lini C (415 juta) karena memproduksi Sensor (harga 125.000) — beda konklusi dengan hanya melihat `Defect` mentah (lini B terbanyak 9.178 unit, tetapi barangnya murah).

---

## 6. Coba sendiri (±7 menit)

1. `inner_join(quality, produk, by = c("Product" = "Produk"))` — berapa baris? (Acuan: `48`; inspeksi hanya berisi Bracket & Panel yang keduanya ada di master.)
2. Hitung `NilaiRugi` per **Product** dari `produksi2` (bukan per Lini). Produk apa teratas? (Petunjuk: Sensor kategori Elektronik, harga 125.000.)
3. Pakai `full_join(quality, produk, by = c("Product" = "Produk")) |> nrow()` — kenapa `52`? (Petunjuk: 6 produk master − 2 yang cocok = 4 baris master ekstra.)
4. `semi_join(produksi, produk, by = c("Product" = "Produk"))` vs `inner_join` — apa beda jumlah kolomnya? (bisa di cek pakai `ncol()`.)
5. Jelaskan satu kalimat: kenapa audit `anti_join()` dulu sebelum `summarise()` uang?

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 12](latihan-12-tidyr-reshape.md)
  Product TotalDefect Harga Target
  <chr>         <int> <int>  <dbl>
1 Bracket         205 15000   0.03
2 Panel            45 48000   0.04
[1] 24
# A tibble: 2 × 2
  Product     n
  <chr>   <int>
1 Bracket    22
2 Panel       2
```

Penjelasan: Bracket punya defect 205 unit dengan harga 15.000; Panel 45 unit harga 48.000. 24 dari 48 inspeksi melebihi target defect rate produk — Bracket paling banyak melanggar (22 inspeksi).