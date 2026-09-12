# Materi 01 — Objek, Assignment & Tipe Data

> Pendamping Volume 0 · Waktu baca ±10 menit · Dataset belum dipakai (angka contoh dari inspeksi hari ini).

---

## 1. Materi singkat

Objek adalah tempat menyimpan nilai. Operator assignment di R adalah `<-` (baca: "diisi dengan").
Setiap objek punya **tipe data**. Lima tipe yang dipakai di folder ini:

| Tipe | Contoh | Fungsi cek |
| --- | --- | --- |
| numeric (angka) | `5000`, `6.4` | `class()` |
| character (teks, selalu pakai tanda kutip) | `"Bracket"` | `class()` |
| logical (`TRUE`/`FALSE`) | `TRUE` | `class()` |
| Date (tanggal) | `as.Date("2026-07-01")` | `class()` |
| NA (data hilang — bukan nol, bukan teks kosong) | `NA` | `is.na()` |

Aturan nama objek: deskriptif, huruf kecil + underscore (`total_defect`, bukan `Total_Defect`).
R membedakan huruf besar-kecil: `total_defect` dan `Total_Defect` adalah dua objek berbeda.

---

## 2. Contoh 1 — Membuat objek dari data inspeksi hari ini

```r
total_inspected <- 5000
total_defect    <- 320
product_name    <- "Bracket"
pass_status     <- TRUE

total_inspected
product_name
```

Output:

```text
[1] 5000
[1] "Bracket"
```

Penjelasan: tiap baris menyimpan satu nilai ke satu nama. Mengetik nama objek lalu Enter menampilkan isinya.

## 3. Contoh 2 — Menghitung defect rate

```r
defect_rate <- total_defect / total_inspected
defect_rate          # proporsi: 0.064
defect_rate * 100    # persen: 6.4
```

Output:

```text
[1] 0.064
[1] 6.4
```

Penjelasan: `defect_rate` memakai dua objek yang sudah ada. Baris terakhir tidak disimpan (tanpa `<-`), hanya ditampilkan.

## 4. Contoh 3 — Memeriksa tipe data

```r
class(total_inspected)  # angka -> "numeric"
class(product_name)     # teks  -> "character"
class(pass_status)      # TRUE  -> "logical"
```

Output:

```text
[1] "numeric"
[1] "character"
[1] "logical"
```

## 5. Contoh 4 — NA dan jebakan teks-berisi-angka

```r
missing_value <- NA
is.na(missing_value)   # TRUE: memang hilang

wrong_value <- "320"      # terlihat seperti angka, TAPI teks
class(wrong_value)        # "character"
as.numeric(wrong_value) + 1   # diperbaiki dulu, baru dihitung -> 321
```

Output:

```text
[1] TRUE
[1] "character"
[1] 321
```

Penjelasan: `"320"` (pakai kutip) tidak bisa dijumlah — kalau dipaksa muncul error `non-numeric argument to binary operator` yang artinya "kamu menyuruh R menghitung teks". `as.numeric()` mengubah teks angka menjadi angka.

## 6. Contoh 5 — Struktur objek lain: list, factor, matrix

Selain vektor, tiga struktur penting:

```r
# list: kumpulan objek SEBARANG tipe/ukuran (pakai [[]] atau $)
qc_info <- list(nama = "inspeksi", n_baris = 48, lini = c("A", "B", "C"))
qc_info$lini          # "A" "B" "C"

# factor: kategori berurutan (untuk grafik & analisis grup)
line <- factor(c("A", "B", "A"), levels = c("A", "B", "C"))
class(line)           # "factor" (order level menentukan urutan tampil)

# matrix: dua dimensi, semua elemen satu tipe
m <- matrix(1:6, nrow = 2); m   # 2 baris × 3 kolom
```

Output:

```text
[1] "A" "B" "C"
[1] "factor"
     [,1] [,2] [,3]
[1,]    1    3    5
[2,]    2    4    6
```

Penjelasan: list dipakai untuk menyimpan objek campuran (mis. hasil model); factor penting saat `levels` mengontrol urutan sumbu grafik (`Line` menjadi faktor di Volume 5); matrix jarang dibanding data frame (Materi 04) — cukup tahu bentuknya.

---

## 7. Coba sendiri (±5 menit)

1. Ganti angka inspeksi menjadi `total_inspected <- 1200`, `total_defect <- 54`. Hitung ulang `defect_rate` dan versi persennya. (Acuan contoh 2: hasilnya `0.045` dan `4.5`.)
2. Buat `line_name <- "Line B"`, cek `class(line_name)`. Tebak dulu sebelum dijalankan.
3. Buat `suhu_ruang <- "28.5"`, lalu hitung `as.numeric(suhu_ruang) + 1.5`. Apa yang terjadi kalau `as.numeric()` dilewatkan?
4. Apa bedanya `320` dengan `"320"`? Tulis satu kalimat memakai kata "tipe data".

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 02](latihan-02-vektor-indexing.md)

