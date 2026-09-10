# Latihan 03 — Fungsi, Operator & Logika

> Level: ⭐ | Materi: README_Basic_R.md Bab 5

## Tujuan

- Memakai fungsi bawaan: `round()`, `abs()`, `sqrt()`, `toupper()`, dll.
- Menggunakan operator perbandingan dan logika (`&`, `|`, `!`).
- Menulis percabangan `if` dan `ifelse()`.

## Soal

1. Terapkan fungsi berikut pada angka `-16.783`: `abs()`, lalu `sqrt()` dari hasil `abs()`, lalu `round(..., 2)`. Tulis dalam satu baris (nested) dan simpan sebagai `hasil`.
2. Bersihkan teks berikut:

```r
nama_produk <- "  bracket UPPER  "
```

- buang spasi ujung dengan `trimws()`,
- ubah ke huruf kecil semua dengan `tolower()`,
- hitung jumlah karakter dengan `nchar()`.

3. Evaluasi dan pahami hasil tiap baris:

```r
defect_rate <- 0.06
defect_rate > 0.05
defect_rate == 0.05
defect_rate != 0.05
defect_rate > 0.05 & defect_rate < 0.10
defect_rate < 0.05 | defect_rate > 0.20
!(defect_rate > 0.05)
```

4. Dengan `if ... else`, tulis: jika `defect_rate > 0.05` cetak `"Above target"`, jika tidak cetak `"On target"`. Jalankan dengan `defect_rate <- 0.03`, lalu ganti jadi `0.06` dan jalankan ulang.
5. Buat vektor `defect_rates <- c(0.02, 0.06, 0.04, 0.08)`. Gunakan `ifelse()` untuk menghasilkan vektor label `"Above"` / `"On target"`.
6. (Bonus) Defect rate dikatakan **kritis** bila di atas 0.07. Dengan `ifelse()` bertingkat (nested), buat label: `"Kritis"` jika > 0.07, `"Above"` jika > 0.05, selain itu `"On target"`.

## Cek pemahaman

- Apa beda `&` dengan `&&`? (Petunjuk: coba `c(TRUE, FALSE) & c(TRUE, TRUE)` vs versi `&&`.)
- Kenapa `ifelse()` cocok untuk vektor, sedangkan `if` tidak?

## Kunci jawaban

```r
hasil <- round(sqrt(abs(-16.783)), 2)   # 4.1

nama_produk <- "  bracket UPPER  "
trimws(nama_produk)      # "bracket UPPER"
tolower(trimws(nama_produk))   # "bracket upper"
nchar(trimws(nama_produk))     # 13

# Soal 3: TRUE, FALSE, TRUE, TRUE, TRUE, FALSE

defect_rate <- 0.03
if (defect_rate > 0.05) {
  print("Above target")
} else {
  print("On target")
}

defect_rates <- c(0.02, 0.06, 0.04, 0.08)
ifelse(defect_rates > 0.05, "Above", "On target")

ifelse(defect_rates > 0.07, "Kritis",
       ifelse(defect_rates > 0.05, "Above", "On target"))
```

---

[Kembali ke daftar](README.md) | [Lanjut: Latihan 04](latihan-04-baca-data.md)
