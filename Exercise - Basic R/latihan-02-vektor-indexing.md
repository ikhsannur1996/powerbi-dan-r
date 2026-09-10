# Latihan 02 — Vektor & Indexing

> Level: ⭐ | Materi: README_Basic_R.md Bab 4.5–4.7

## Tujuan

- Membuat vektor dengan `c()`, `:`, `seq()`, `rep()`.
- Mengakses elemen dengan index positif, negatif, dan kondisi.
- Menangani `NA` di dalam vektor.

## Soal

1. Buat vektor `cycle_time` berisi cycle time 5 inspeksi: 38, 42, 45, 41, 39.
2. Hitung `length()`, `sum()`, `mean()`, `min()`, `max()` dari `cycle_time` dalam satu blok.
3. Buat urutan `1:10`, lalu `seq(from = 0, to = 100, by = 10)`, lalu `rep("Line A", 3)`. Perhatikan bentuk hasilnya.
4. Dari `cycle_time`, tampilkan:
   - elemen pertama,
   - elemen ke-2 sampai ke-4,
   - semua elemen kecuali yang pertama (pakai index negatif),
   - elemen ke-1 dan ke-5 sekaligus.
5. Tampilkan semua nilai `cycle_time` yang lebih besar dari 40 (indexing dengan kondisi).
6. Buat vektor `defect_count <- c(5, 3, NA, 8, 2)`.
   - Hitung `mean(defect_count)` — perhatikan hasilnya.
   - Hitung ulang dengan `na.rm = TRUE`.
   - Tampilkan posisi mana saja yang `NA` dengan `is.na()`.
7. Buat vektor karakter `line <- c("A", "A", "B", "C", "B")`. Tampilkan hanya elemen yang bernilai `"B"`.

## Cek pemahaman

- Kenapa index R dimulai dari 1 (bukan 0 seperti Python)?
- Apa yang terjadi jika menghitung `mean()` pada vektor yang mengandung `NA` tanpa `na.rm = TRUE`?

## Kunci jawaban

```r
cycle_time <- c(38, 42, 45, 41, 39)

length(cycle_time)  # 5
sum(cycle_time)     # 205
mean(cycle_time)    # 41
min(cycle_time)     # 38
max(cycle_time)     # 45

1:10
seq(from = 0, to = 100, by = 10)
rep("Line A", 3)

cycle_time[1]
cycle_time[2:4]
cycle_time[-1]
cycle_time[c(1, 5)]

cycle_time[cycle_time > 40]

defect_count <- c(5, 3, NA, 8, 2)
mean(defect_count)                # NA
mean(defect_count, na.rm = TRUE)  # 4.5
is.na(defect_count)               # FALSE FALSE TRUE FALSE FALSE

line <- c("A", "A", "B", "C", "B")
line[line == "B"]
```

---

[Kembali ke daftar](README.md) | [Lanjut: Latihan 03](latihan-03-fungsi-logika.md)
