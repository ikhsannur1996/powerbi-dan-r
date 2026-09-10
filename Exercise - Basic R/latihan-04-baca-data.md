# Latihan 04 — Membaca Data & Struktur Data Frame

> Level: ⭐⭐ | Materi: README_Basic_R.md Bab 6

## Tujuan

- Membaca CSV dengan `read.csv()`.
- Memahami struktur data frame dengan `str()`, `head()`, `names()`, `dim()`.
- Mengakses kolom dengan `$` dan bracket.

## Persiapan

Pastikan working directory mengarah ke root project:

```r
getwd()   # harus menunjuk folder "Power BI dan R"
# jika belum: Session > Set Working Directory > To Project Directory
```

## Soal

1. Baca dataset:

```r
quality <- read.csv("quality_inspection.csv")
```

2. Tampilkan 6 baris pertama dengan `head()`, lalu 3 baris terakhir dengan `tail()`.
3. Jawab dengan fungsi yang tepat:
   - Berapa jumlah **baris** dan **kolom**? (satu fungsi untuk keduanya)
   - Apa saja **nama kolom**?
   - Apa **tipe** tiap kolom?
4. Tampilkan kolom `Line` saja, lalu tampilkan kolom `CycleTimeSec` saja. Hitung rata-ratanya.
5. Ambil data baris ke-1 sampai ke-5, kolom `Line` sampai `DefectType` (pakai bracket `[baris, kolom]`).
6. Ambil semua baris dengan `Line == "A"`, hanya kolom `Defect` (dua cara: `$` dan bracket).
7. Periksa apakah ada `NA` di seluruh dataset: `sum(is.na(quality))`. Jelaskan hasilnya.
8. Konversi `InspectionDate` menjadi Date lalu periksa tipe barunya:

```r
quality$InspectionDate <- as.Date(quality$InspectionDate)
class(quality$InspectionDate)
```

## Cek pemahaman

- Apa beda `quality$Defect` dan `quality[, "Defect"]`? (Petunjuk: periksa `class()` keduanya.)
- Mengapa konversi tanggal penting sebelum dianalisis?

## Kunci jawaban

```r
quality <- read.csv("quality_inspection.csv")

head(quality)
tail(quality, 3)

dim(quality)      # 48 baris, 7 kolom
names(quality)
str(quality)

quality$Line
quality$CycleTimeSec
mean(quality$CycleTimeSec)

quality[1:5, 1:4]

quality$Defect[quality$Line == "A"]
quality[quality$Line == "A", "Defect"]

sum(is.na(quality))   # 0 — dataset bersih

quality$InspectionDate <- as.Date(quality$InspectionDate)
class(quality$InspectionDate)   # "Date"
```

---

[Kembali ke daftar](README.md) | [Lanjut: Latihan 05](latihan-05-dplyr-select-filter.md)
