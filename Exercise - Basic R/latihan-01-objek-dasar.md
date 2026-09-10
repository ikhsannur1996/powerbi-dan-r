# Latihan 01 — Objek Dasar & Tipe Data

> Level: ⭐ | Materi: README_Basic_R.md Bab 4.1–4.4

## Tujuan

- Membuat objek dengan `<-`.
- Memahami tipe data dasar: numeric, integer, character, logical, NA.
- Memeriksa tipe dengan `class()`.

## Persiapan

Buka script R baru, jalankan:

```r
rm(list = ls())   # bersihkan environment
```

## Soal

1. Buat objek berikut dari data inspeksi hari ini:

```r
# total unit yang diinspeksi: 5000
# total unit defect: 320
# nama produk: "Bracket"
# status lulus inspeksi: TRUE
```

Buat 4 objek dengan nama yang deskriptif (mis. `total_inspected`, `total_defect`, `product_name`, `pass_status`).

2. Hitung `defect_rate` = total defect dibagi total inspected. Simpan sebagai objek `defect_rate`.
3. Tampilkan nilai `defect_rate` dikali 100 (dalam persen).
4. Periksa `class()` dari keempat objek di soal 1.
5. Buat objek `missing_value <- NA`. Periksa `is.na(missing_value)`.
6. Buat `wrong_value <- "320"` (string, bukan angka). Coba hitung `wrong_value + 1` — baca errornya. Perbaiki dengan `as.numeric(wrong_value) + 1`.

## Cek pemahaman

- Apa bedanya `320` dan `"320"`?
- Mengapa penamaan `Total_Defect` dan `total_defect` dianggap dua objek berbeda?

## Kunci jawaban

```r
total_inspected <- 5000
total_defect    <- 320
product_name    <- "Bracket"
pass_status     <- TRUE

defect_rate <- total_defect / total_inspected
defect_rate * 100   # 6.4

class(total_inspected)  # "numeric"
class(product_name)     # "character"
class(pass_status)      # "logical"
class(missing_value)    # "logical" — NA default bertipe logical

missing_value <- NA
is.na(missing_value)    # TRUE

wrong_value <- "320"
wrong_value + 1              # Error: non-numeric argument to binary operator
as.numeric(wrong_value) + 1  # 321
```

---

[Kembali ke daftar](README.md) | [Lanjut: Latihan 02](latihan-02-vektor-indexing.md)
