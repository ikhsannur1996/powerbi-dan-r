# Materi 14 — Manipulasi Teks (stringr)

> Pendamping Volume 0 · Waktu baca ±15 menit · Package: `stringr`.
> Dataset: `qc_operator.csv` (master nama operator) & `quality_inspection.csv`.

---

## 1. Materi singkat — memo fungsi teks

Semua fungsi `stringr` dimulai `str_` dan bekerja per elemen vektor. Yang paling sering:

| Fungsi | Guna | Contoh |
| --- | --- | --- |
| `str_trim()` / `str_squish()` | buang spasi ujung / rangkap | `" A  B "` → `"A B"` |
| `str_to_upper()`, `str_to_lower()`, `str_to_title()` | ubah huruf besar/kecil | `"bracket"` → `"BRACKET"` |
| `str_detect(teks, pola)` | TRUE/FALSE: mengandung pola? | `"Bracket"` → pola `"rack"` |
| `str_count(teks, pola)` | berapa kali pola muncul | `"Bracket"` hitung `"a"` → 1 |
| `str_replace_all(teks, lama, baru)` | ganti semua kemunculan | `"Line-A"` → `"Line_A"` |
| `str_c(..., sep = )` | gabung teks & angka | `str_c("Inspeksi", 1, sep = "-")` |
| `nchar()` (base) | jumlah karakter | `nchar("Bracket")` → 7 |

Pola memakai **regex** singkat: `^` = awal teks, `$` = akhir, `[...]` = pilihan karakter. Contoh: `^[a-z]` = diawali huruf kecil.

---

## 2. Contoh 1 — Pembersihan dasar (persiapan sebelum join)

```r
library(dplyr)
library(stringr)

operator <- read.csv("qc_operator.csv", stringsAsFactors = FALSE)

operator |> pull(Nama) |> head(2)      # lihat data asli ("Budi Santoso " ada spasi)
str_trim(operator$Nama[1])             # buang spasi -> "Budi Santoso"
str_to_upper(c("bracket", "PANEL"))    # "BRACKET" "PANEL"
```

Output:

```text
[1] "Budi Santoso " "Siti Rahma"
[1] "Budi Santoso"
[1] "BRACKET" "PANEL"
```

Penjelasan: nama "Budi Santoso " punya spasi di ujung — `str_trim()` membuangnya. Normalisasi teks (trim + case) adalah langkah **wajib sebelum join**: `anti_join` tidak akan mencocokkan `"A"` dengan `" A "`.

## 3. Contoh 2 — Deteksi & hitung (str_detect, str_count)

```r
quality <- read.csv("quality_inspection.csv")

# Produk mana yang mengandung "rack"? -> Bracket
unique(quality$Product)[str_detect(unique(quality$Product), "rack")]

# Seberapa sering huruf "a" muncul di nama produk
str_count(quality$Product, "a") |> head(8)

# Operator yang nama depannya huruf kecil (input tidak rapi!)
operator$Nama[str_detect(operator$Nama, "^[a-z]")]
```

Output:

```text
[1] "Bracket"
[1] 1 1 1 1 1 1 1 1
[1] "maya anggraini"
```

Penjelasan: `str_detect()` menghasilkan vektor logical — dipakai untuk filter manual (`operator$Nama[...]`). Terlihat "maya anggraini" belum kapitalisasi; `str_to_title()` bisa merapikannya.

## 4. Contoh 3 — Ganti & gabung

```r
str_replace_all(c("Line-A", "Line-B"), "-", "_")   # "Line_A" "Line_B"
str_c("Inspeksi", 1:3, sep = "-")                  # "Inspeksi-1" ...
str_to_title("maya anggraini")                     # "Maya Anggraini"
```

Output:

```text
[1] "Line_A" "Line_B"
[1] "Inspeksi-1" "Inspeksi-2" "Inspeksi-3"
[1] "Maya Anggraini"
```

Penjelasan: `str_c()` versi `stringr` dari `paste0(...)` (tanpa spasi, kecuali `sep =` ditulis). Sering dipakai membuat kolom ID sebelum `unite()` (Materi 12).

## 5. Contoh 4 — Paket lengkap dalam satu pipeline

```r
operator_bersih <- operator |>
  mutate(
    Nama = str_trim(Nama),
    Nama = str_to_title(Nama),                       # "maya anggraini" -> "Maya Anggraini"
    JumlahKata = str_count(Nama, " ") + 1            # 2 kata -> ada 1 spasi
  ) |>
  select(OperatorID, Nama, JumlahKata)

head(operator_bersih, 3)
```

Output:

```text
  OperatorID          Nama JumlahKata
1       OP01  Budi Santoso          2
2       OP02     Siti Rahma          2
3       OP03    Andi Wijaya          2
```

---

## 6. Coba sendiri (±7 menit)

1. Bersihkan `c("  Line A  ", "line b")` sehingga jadi `c("Line A", "Line B")` — pakai `str_trim()` + `str_to_title()`.
2. Buat `str_detect(c("Bracket", "Panel", "Sensor"), "[aeiou]")` — nilai apa yang keluar?
3. `str_c("Shift", c("Pagi", "Sore"), sep = "-")` hasilnya? (Acuan: `"Shift-Pagi"`, `"Shift-Sore"`.)
4. Jelaskan satu kalimat: kenapa `str_trim()` + `str_to_*()` penting sebelum `left_join()`?

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 15](latihan-15-ggplot2-lanjutan.md)