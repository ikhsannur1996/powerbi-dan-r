# Materi 03 — Fungsi, Logical Function & Logika

> Pendamping Volume 0 · Waktu baca ±20 menit · Contoh memakai ambang defect rate 5% (0.05).
> Bagian: (1) fungsi, (2) operator & logical, (3) `if`/`ifelse()`, (4) dplyr `case_when()` & teman, (5) buat fungsi sendiri, (6) fungsi anonim.

---

## 1. Materi singkat — dua dunia fungsi di R

R memakai dua gaya fungsi yang tampilannya mirip tapi perilakunya berbeda:

| Gaya | Berasal dari | Perlakuan `NA` | Butuh `library()` |
| --- | --- | --- | --- |
| Base R (`ifelse`, `&`, `is.na`) | bawaan R | **menular** (NA dipertahankan) | tidak |
| Tidyverse (`if_else`, `case_when`, `coalesce`) | package `dplyr` | **eksplisit** (argumen `missing =`) | `library(dplyr)` |

Panduan memilih:

| Situasi | Fungsi |
| --- | --- |
| Periksa/tandai per elemen (vektor umum) | `ifelse()` (base) |
| Kolom di data frame, tipe harus konsisten, NA perlu ditangani | `if_else()` |
| 2+ kondisi berjenjang (paling disarankan) | `case_when()` |
| Isi nilai kosong/`NA` dengan cadangan | `coalesce()` |
| Ubah nilai tertentu menjadi `NA` | `na_if()` |

Fungsi = perintah siap pakai `nama_fungsi(input)` dan bisa bersarang: `round(sqrt(abs(-16.783)), 2)` → `4.1`.

---

## 2. Contoh 1 — Logical function bawaan (predikat)

Fungsi yang menjawab `TRUE`/`FALSE` per elemen disebut *logical function* (predikat):

```r
x <- c(1.5, 3.2, NA, 4.4)

is.numeric(x)        # seluruh objek: angka?  -> TRUE
is.na(x)             # per elemen: hilang?  -> FALSE FALSE TRUE FALSE
is.finite(x)         # terhingga (bukan NA/Inf)? -> FALSE FALSE FALSE TRUE

c(TRUE, FALSE) & c(TRUE, TRUE)   # FALSE (per elemen vektor)
TRUE && TRUE                     # TRUE  (skalar, dipakai di if)
any(c(TRUE, FALSE, TRUE))        # TRUE  — "ada yang TRUE?"
all(c(TRUE, TRUE, TRUE))         # TRUE  — "semua TRUE?"
xor(c(TRUE, TRUE, FALSE), c(TRUE, FALSE, FALSE))  # FALSE TRUE FALSE
```

Output:

```text
[1] TRUE
[1] FALSE FALSE  TRUE FALSE
[1] FALSE FALSE FALSE  TRUE
[1] FALSE
[1] TRUE
[1] TRUE
[1] TRUE
[1] FALSE  TRUE FALSE
```

Penjelasan: `&`/`|` bekerja per elemen (vectorized); `&&`/`||` hanya cek elemen pertama dan dipakai di `if`. `is.na(x)` adalah jantung semua pengecekan missing data di folder ini.

---

## 3. Contoh 2 — Operator perbandingan & logika

```r
defect_rate <- 0.06
defect_rate > 0.05                        # TRUE: di atas ambang
defect_rate == 0.05                       # FALSE (perbandingan pakai ==, bukan =)
defect_rate != 0.05                       # TRUE
defect_rate > 0.05 & defect_rate < 0.10   # TRUE & TRUE -> TRUE
defect_rate < 0.05 | defect_rate > 0.20   # FALSE | FALSE -> FALSE
!(defect_rate > 0.05)                     # NOT TRUE -> FALSE
```

Output:

```text
[1] TRUE
[1] FALSE
[1] TRUE
[1] TRUE
[1] FALSE
[1] FALSE
```

Jebakan `==` dengan `NA` (NA = "belum tahu", jadi `NA == "B"` = `NA`), bandingkan dengan `%in%`:

```r
c("A", NA, "B") == "B"    # FALSE NA TRUE   (NA menular)
c("A", NA, "B") %in% "B"  # FALSE FALSE TRUE (NA TIDAK menular)
```

Output:

```text
[1] FALSE    NA  TRUE
[1] FALSE FALSE  TRUE
```

Praktik di `filter()` (Materi 05): `filter(Line == "B")` ikut memakai baris NA, `%in%` lebih aman.

---

## 4. Contoh 3 — `if ... else` (satu nilai / skalar)

```r
defect_rate <- 0.06
if (defect_rate > 0.05) {
  print("Above target")
} else {
  print("On target")
}
```

Output:

```text
[1] "Above target"
```

Penjelasan: ganti `defect_rate <- 0.03` lalu jalankan ulang → `"On target"`. `if` hanya untuk satu nilai; untuk vektor pakai `ifelse()`, `case_when()`, atau `if_else()` di contoh berikut.

## 5. Contoh 4 — `ifelse()` dan `if_else()` (per elemen)

```r
defect_rates <- c(0.02, 0.06, 0.04, 0.08)

# base R: semua label character -> aman
ifelse(defect_rates > 0.05, "Above", "On target")

# Bertingkat: kritis > 0.07, di atas ambang > 0.05, sisanya on target
ifelse(defect_rates > 0.07, "Kritis",
       ifelse(defect_rates > 0.05, "Above", "On target"))

# dplyr::if_else: tipe ketat + argumen missing untuk NA
library(dplyr)
if_else(c(TRUE, FALSE, NA), "Ya", "Tidak", missing = "Belum tahu")
# [1] "Ya"       "Tidak"    "Belum tahu"
```

Catatan: `ifelse()` base R **tidak** punya argumen `missing` — NA dipertahankan. Contoh:

```r
ifelse(c(TRUE, NA, FALSE), 1L, 0L)
# [1]  1 NA  0
```

Sebaliknya, `if_else()` dari dplyr punya `missing=` untuk NA. Pilih `ifelse()` untuk skrip biasa; pilih `if_else()` untuk `mutate()` jika ingin NA ditangani eksplisit.

Penjelasan: keduanya vectorized (setiap elemen). `ifelse()` mengembalikan type yang disesuaikan; `if_else()` lebih ketat (bertipe sama) tapi butuh `library(dplyr)`.
```

Output:

```text
[1] "On target" "Above"     "On target" "Above"
[1] "On target" "Above"     "On target" "Kritis"
[1] "Ya"         "Tidak"      "Belum tahu"
```

Perbedaan: `if_else()` mewajibkan `yes`/`no` bertipe sama (error kalau beda) dan punya `missing =` untuk mengisi `NA`. `case_when()` (contoh 5) = versi berjenjang yang lebih mudah dibaca.

---

## 6. Contoh 5 — `case_when()` (2+ kondisi, paling disarankan)

```r
defect_rates <- c(0.02, 0.06, 0.04, 0.08)

case_when(
  defect_rates > 0.07 ~ "Kritis",
  defect_rates > 0.05 ~ "Above",
  TRUE                ~ "On target"
)
```

Output:

```text
[1] "On target" "Above"     "On target" "Kritis"
```

Penjelasan: tiap baris `kondisi ~ hasil`, dievaluasi **dari atas**; yang benar pertama menang; `TRUE ~` = "sisanya"; hasil otomatis bertipe sama. Ini versi "if-else berjenjang yang mudah dibaca" — dipakai lagi di Materi 06 untuk kolom `Severity`.

Fungsi pendamping `coalesce()` & `na_if()`:

```r
coalesce(c(NA, 2, NA), c(10, 20, 30))   # ambil nilai pertama yang bukan NA -> 10 2 30
na_if(c("A", "", "B"), "")              # ubah "" menjadi NA -> "A" NA "B"
```

Output:

```text
[1] 10  2 30
[1] "A" NA  "B"
```

---

## 7. Contoh 6 — Membuat fungsi sendiri

Fungsi menangkap pola yang dipakai berulang. Bentuk dasar:

```r
nama_fungsi <- function(argumen) {
  # tubuh fungsi
  hasil_akhir   # baris terakhir = nilai yang dikembalikan
}
```

Contoh 1 variabel:

```r
defect_rate <- function(defect, inspected) {
  defect / inspected
}
defect_rate(5, 120)   # 0.04166667 — bisa dipanggil kapan saja
```

Contoh dengan nilai default (`ambang = 0.05`) + satu argumen:

```r
flag_defect <- function(rate, ambang = 0.05) {
  ifelse(rate > ambang, "Above", "On target")
}
flag_defect(c(0.02, 0.09))                 # pakai ambang default
flag_defect(c(0.02, 0.09), ambang = 0.10)  # pakai ambang sendiri
```

Output:

```text
[1] 0.04166667
[1] "On target" "Above"
[1] "On target" "On target"
```

Penjelasan: fungsi dibuat sekali, dipakai berkali-kali dengan argumen berbeda; nilai default membuat panggilan aman tanpa semua argumen. Fungsi bernama ini nanti bisa dipanggil langsung di dalam `mutate()` bila logika dipakai berulang. Biasakan 1 fungsi = 1 pekerjaan.

---

## 8. Contoh 7 — Fungsi anonim / lambda

Fungsi tanpa nama, dipakai langsung di dalam fungsi lain (family `apply` / `purrr`). Dua gaya: `function(x)` (lama) dan `\(x)` (singkat, R 4.1+).

```r
# Gaya klasik
sapply(list(1:3, 4:6), function(x) mean(x))   # 2 5

# Gaya lambda \(x) — hasil sama
sapply(list(1:3, 4:6), \(x) mean(x))          # 2 5

# Lambda + ifelse: klasifikasi cepat tiap elemen
sapply(c(0.02, 0.06), \(r) ifelse(r > 0.05, "Above", "On target"))
```

Output:

```text
[1] 2 5
[1] 2 5
[1] "On target" "Above"
```

Penjelasan: lambda cocok untuk logika sekali-pakai di dalam `sapply()`/`lapply()` atau `across()` dplyr. Kalau tubuhnya panjang, simpan jadi fungsi bernama (contoh 6) agar kode terbaca.

## 9. Coba sendiri (±7 menit)

1. Predikat: buat `x <- c(2, NA, 9)`, lalu `is.na(x)`, `any(is.na(x))`, `all(x > 1)`. Jelaskan hasil terakhir (petunjuk: NA menular).
2. `case_when()` dengan 4 level: `< 0.03` → `"Bagus"`, `< 0.05` → `"Aman"`, `< 0.07` → `"Waspada"`, sisanya `"Kritis"` untuk `c(0.02, 0.04, 0.06, 0.09)`. Tulis hasilnya sebelum dijalankan. (Acuan: Bagus, Aman, Waspada, Kritis.)
3. Buat fungsi `hitung_fpy <- function(rate) 1 - rate`. Panggil dengan `0.0417` → `0.9583`; lalu dengan vektor `c(0.02, 0.07)`.
4. Lambda: `sapply(c(10, 25, 40), \(jam) ifelse(jam >= 36, "Lembur", "Normal"))`. (Acuan: Normal, Normal, Lembur.)
5. `if_else(..., missing = ...)`: `if_else(c(TRUE, NA, FALSE), 1L, 0L, missing = -1L)`. Nilai untuk NA? (Acuan: `-1`.)

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 04](latihan-04-baca-data.md)

