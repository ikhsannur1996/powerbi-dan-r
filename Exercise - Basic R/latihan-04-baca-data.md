# Materi 04 — Membaca CSV & Memahami Struktur Data

> Pendamping Volume 0 · Waktu baca ±10 menit · Dataset: `quality_inspection.csv` (48 baris × 7 kolom).
> Jalankan dari root project (`getwd()` harus berakhiran `Power BI dan R`).

---

## 1. Materi singkat

`read.csv()` membaca file CSV menjadi **data frame** (tabel R: baris = observasi, kolom = variabel).
Begitu data masuk, tiga hal wajib dicek: **ukuran**, **nama kolom**, **tipe kolom**.

| Fungsi | Untuk apa | Contoh output di dataset ini |
| --- | --- | --- |
| `dim()` | jumlah baris & kolom | 48 baris, 7 kolom |
| `names()` | nama kolom | InspectionDate, Line, Product, DefectType, Inspected, Defect, CycleTimeSec |
| `str()` | tipe tiap kolom + contoh isi | chr, int — lihat contoh 2 |
| `head()` / `tail()` | intip awal / akhir | 6 baris pertama / 3 terakhir |
| `$` dan `[baris, kolom]` | ambil kolom / sel | `quality$Line`, `quality[1:5, 1:4]` |

---

## 2. Contoh 1 — Baca data & cek working directory

```r
getwd()   # pastikan menunjuk folder "Power BI dan R"
# Jika belum: Session > Set Working Directory > To Project Directory

quality <- read.csv("quality_inspection.csv")
```

Penjelasan: tidak ada output — objek `quality` kini ada di Environment. Kalau muncul `cannot open file`, artinya working directory salah: cek `list.files()` — `quality_inspection.csv` harus terlihat.

## 3. Contoh 2 — Intip struktur (ini dilakukan setiap kali terima data baru)

```r
dim(quality)    # ukuran
names(quality)  # nama kolom
str(quality)    # tipe kolom
```

Output:

```text
[1] 48  7
[1] "InspectionDate" "Line" "Product" "DefectType" "Inspected" "Defect" "CycleTimeSec"
'data.frame':	48 obs. of  7 variables:
 $ InspectionDate: chr  "2026-07-01" "2026-07-01" "2026-07-01" ...
 $ Line          : chr  "A" "A" "B" "B" ...
 $ Product       : chr  "Bracket" "Bracket" "Bracket" ...
 $ DefectType    : chr  "Scratch" "Dimension" "Scratch" ...
 $ Inspected     : int  120 115 130 125 140 135 ...
 $ Defect        : int  5 3 9 4 4 2 ...
 $ CycleTimeSec  : int  42 41 46 47 39 40 ...
```

Penjelasan: `chr` = teks, `int` = bilangan bulat. `InspectionDate` masih `chr` (teks) — diubah ke Date di contoh 5.

## 4. Contoh 3 — Intip isi awal & akhir

```r
head(quality)          # 6 baris pertama
tail(quality, 3)       # 3 baris terakhir
```

Output:

```text
  InspectionDate Line Product DefectType Inspected Defect CycleTimeSec
1     2026-07-01    A Bracket    Scratch       120      5           42
2     2026-07-01    A Bracket  Dimension       115      3           41
3     2026-07-01    B Bracket    Scratch       130      9           46
4     2026-07-01    B Bracket      Crack       125      4           47
5     2026-07-01    C   Panel  Dimension       140      4           39
6     2026-07-01    C   Panel      Color       135      2           40
...
   InspectionDate Line Product DefectType Inspected Defect CycleTimeSec
46     2026-08-22    B Bracket      Crack       121     10           52
47     2026-08-22    C   Panel  Dimension       143      3           40
48     2026-08-22    C   Panel       NONE       139      2           39
```

## 5. Contoh 4 — Ambil kolom & sel

```r
quality$Line              # kolom Line saja (vektor)
mean(quality$CycleTimeSec)  # rata-rata cycle time -> 44

quality[1:5, 1:4]         # baris 1-5, kolom 1-4 (Line s.d. DefectType)
quality$Defect[quality$Line == "A"]      # defect lini A (cara 1: $)
quality[quality$Line == "A", "Defect"]   # defect lini A (cara 2: bracket)
```

Output:

```text
 [1] "A" "A" "B" "B" "C" "C" "A" "A" "B" "B" "C" "C" ... (total 16 A, 16 B, 16 C)
[1] 44
  InspectionDate Line Product DefectType
1     2026-07-01    A Bracket    Scratch
2     2026-07-01    A Bracket  Dimension
3     2026-07-01    B Bracket    Scratch
4     2026-07-01    B Bracket      Crack
5     2026-07-01    C   Panel  Dimension
 [1] 5 3 4 2 4 6 2 3 5 3 4 2 4 5 2 3
```

Penjelasan: `quality$Defect` dan `quality[, "Defect"]` isinya sama (vektor angka); bedanya hanya cara tulis. Pola `kolom[kondisi]` adalah versi base-R dari `filter()`.

## 6. Contoh 5 — Cek NA & konversi tanggal

```r
sum(is.na(quality))   # 0 -> dataset bersih, tidak ada NA

quality$InspectionDate <- as.Date(quality$InspectionDate)
class(quality$InspectionDate)   # "Date"
```

Output:

```text
[1] 0
[1] "Date"
```

Penjelasan: konversi tanggal penting sebelum analisis waktu (tren harian, grup bulan) — tanggal teks tidak bisa diurutkan/di-floor dengan benar.

## 7. Contoh 6 — Simpan data & kelola file

```r
# Simpan data frame ke CSV (tanpa nomor baris!)
write.csv(quality, "quality_salinan.csv", row.names = FALSE)

list.files(pattern = "quality")   # cek file ada
file.remove("quality_salinan.csv")  # hapus file (jangan berantakan)
```

Output:

```text
[1] "qc_hasil_produksi.csv" "qc_operator.csv" "qc_produk.csv"
[4] "quality_inspection.csv" "quality_inspection_cleaning.R" "quality_salinan.csv"
```

Penjelasan: `write.csv(..., row.names = FALSE)` — tanpa itu muncul kolom `X` berisi nomor baris yang mencemari data. `list.files(pattern)` menyaring nama file; `file.remove()` membersihkan hasil percobaan. Pola ini dipakai di Materi 08 (simpan hasil cleaning) dan Materi 10 (ekspor ringkasan).

> Tips `tibble`: `read.csv()` menghasilkan data.frame klasik. Di ekosistem tidyverse, `readr::read_csv()` menghasilkan tibble — tampilan print lebih ringkas (10 baris) dan string otomatis jadi karakter (bukan faktor). Sintaks dasar sama: `readr::read_csv("quality_inspection.csv")`.

---

## 8. Coba sendiri (±5 menit)

1. Tampilkan `head(quality, 10)` — kolom apa yang paling cepat kamu pahami? Kenapa?
2. Hitung `mean(quality$Defect)` dan `max(quality$Inspected)`. (Acuan: rata-rata defect ≈ `5.21`, maks inspected `144`.)
3. Ambil baris dengan `Line == "C"`, kolom `DefectType` saja, dua cara (`$` dan bracket). Hasilnya sama?
4. Jelaskan satu kalimat: kenapa `str()` selalu dijalankan sebelum analisis?

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 05](latihan-05-dplyr-select-filter.md)

