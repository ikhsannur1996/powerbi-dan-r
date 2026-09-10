# Exercise: 100 Kasus Penggunaan dplyr

> Kumpulan **100 soal + jawaban** berbahasa Indonesia untuk melatih transformasi data dengan `dplyr` secara end-to-end: filter, select, mutate, group & summarize, window function, join, sampai pembersihan data. Setiap jawaban bisa dijalankan langsung — cocok untuk latihan mandiri maupun materi training.

## Dataset Latihan

| File | Isi | Kolom kunci |
|---|---|---|
| `qc_hasil_produksi.csv` | Transaksi produksi harian (±450 baris): 3 lini × 2 shift, Jul–Sep 2026 | `Tanggal`, `Lini`, `Shift`, `OperatorID`, `Product` |
| `qc_operator.csv` | Master 8 operator (sengaja ada nama berantakan untuk latihan string) | `OperatorID` |
| `qc_produk.csv` | Master produk & target defect — key `Produk`, sengaja **beda nama** dari kolom `Product` transaksi, untuk latihan join | `Produk` |

Ciri data yang sengaja ditanam untuk latihan:

- Missing value pada `DowntimeMin`, `TempC`, `HumidityPct`
- `DowntimeMin` negatif (kesalahan input)
- Produk tak dikenal master: `Casing`
- Produk master yang tak pernah diproduksi: `Kabel`
- Operator yang tak pernah muncul di transaksi: `OP08`
- Baris duplikat persis

Generator: [`buat_data_latihan.R`](buat_data_latihan.R) — deterministik (`set.seed(2026)`), aman dijalankan ulang.

## Persiapan

Jalankan dari **root project** (folder `Power BI dan R`):

```r
library(dplyr)
library(lubridate)
library(stringr)
library(scales)

hasil    <- read.csv("qc_hasil_produksi.csv") |> mutate(Tanggal = as.Date(Tanggal))
operator <- read.csv("qc_operator.csv")
produk   <- read.csv("qc_produk.csv")

glimpse(hasil)
```

> Kerjakan soalnya dulu sebelum melihat jawaban. Tingkat kesulitan: ⭐ dasar · ⭐⭐ menengah · ⭐⭐⭐ lanjutan.

## A. Filter Baris

### 1. Produksi tinggi ⭐
**Soal:** Ambil semua baris dengan `UnitsProduced` di atas 1200 unit.
**Jawaban:**
```r
hasil |> filter(UnitsProduced > 1200)
```
`filter()` menyimpan baris yang kondisinya `TRUE`.

### 2. Filter kombinasi ⭐
**Soal:** Produksi Lini A pada shift Pagi.
**Jawaban:**
```r
hasil |> filter(Lini == "A", Shift == "Pagi")
```
Beberapa argumen dipisah koma berarti logika AND.

### 3. Banyak nilai sekaligus ⭐
**Soal:** Baris untuk produk Bracket atau Housing.
**Jawaban:**
```r
hasil |> filter(Product %in% c("Bracket", "Housing"))
```
`%in%` lebih ringkas daripada merangkai banyak `|`.

### 4. Rentang tanggal ⭐⭐
**Soal:** Data pada rentang 1–15 Agustus 2026.
**Jawaban:**
```r
hasil |>
  filter(between(Tanggal, as.Date("2026-08-01"), as.Date("2026-08-15")))
```
`between()` inklusif di kedua ujung. `Tanggal` sudah bertipe Date dari langkah persiapan.

### 5. Deteksi missing value ⭐
**Soal:** Baris yang suhu ruangnya tidak tercatat.
**Jawaban:**
```r
hasil |> filter(is.na(TempC))
```
`NA == apa pun` menghasilkan `NA` — deteksi NA wajib lewat `is.na()`.

### 6. Kondisi + anti-NA ⭐⭐
**Soal:** Downtime di atas 60 menit yang datanya valid.
**Jawaban:**
```r
hasil |> filter(!is.na(DowntimeMin), DowntimeMin > 60)
```
Saring NA lebih dulu agar perbandingan tidak menghasilkan `NA`.

### 7. Filter berbasis waktu ⭐
**Soal:** Seluruh transaksi bulan Agustus.
**Jawaban:**
```r
hasil |> filter(month(Tanggal) == 8)
```
`month()` dari lubridate bekerja langsung di dalam `filter()`.

### 8. Akhir pekan ⭐⭐
**Soal:** Transaksi pada hari Sabtu dan Minggu.
**Jawaban:**
```r
hasil |> filter(wday(Tanggal, week_start = 1) >= 6)
```
`week_start = 1` → Senin = 1, Sabtu = 6, Minggu = 7.

### 9. Kondisi hasil hitungan ⭐⭐
**Soal:** Baris dengan defect rate di atas 5%.
**Jawaban:**
```r
hasil |> filter(UnitsDefect / UnitsProduced > 0.05)
```
Ekspresi aritmetika boleh langsung ditulis di dalam `filter()`.

### 10. Logika OR ⭐
**Soal:** Indikasi mesin bermasalah: downtime > 90 menit ATAU defect > 60 unit.
**Jawaban:**
```r
hasil |> filter(DowntimeMin > 90 | UnitsDefect > 60)
```
Baris dengan downtime `NA` hanya lolos bila kondisi kedua bernilai `TRUE`.

## B. Slice & Mengurutkan

### 11. Urutkan downtime ⭐
**Soal:** Urutkan data dari downtime terbesar.
**Jawaban:**
```r
hasil |> arrange(desc(DowntimeMin))
```
`desc()` membalik urutan; nilai `NA` ditaruh di akhir.

### 12. Urutan multi-kunci ⭐
**Soal:** Urutkan per lini, lalu tanggal, lalu defect terbanyak.
**Jawaban:**
```r
hasil |> arrange(Lini, Tanggal, desc(UnitsDefect))
```
`arrange()` menerima banyak kunci, dievaluasi berurutan.

### 13. Head & tail ⭐
**Soal:** Tampilkan 5 baris pertama dan 5 baris terakhir.
**Jawaban:**
```r
hasil |> slice_head(n = 5)
hasil |> slice_tail(n = 5)
```

### 14. Posisi tertentu ⭐
**Soal:** Ambil baris ke-10 sampai ke-15.
**Jawaban:**
```r
hasil |> slice(10:15)
```

### 15. Top-N berdasarkan nilai ⭐⭐
**Soal:** 5 baris dengan defect rate tertinggi.
**Jawaban:**
```r
hasil |> slice_max(UnitsDefect / UnitsProduced, n = 5)
```
`slice_max()` = `arrange(desc()) + slice_head()` dalam satu langkah, dan bisa langsung menerima ekspresi.

### 16. Bottom-N tanpa NA ⭐⭐
**Soal:** 5 downtime terkecil, abaikan baris NA.
**Jawaban:**
```r
hasil |> slice_min(DowntimeMin, n = 5, na_rm = TRUE)
```
`na_rm = TRUE` membuang NA sebelum ranking.

### 17. Sampel acak ⭐
**Soal:** Ambil 5 baris secara acak.
**Jawaban:**
```r
set.seed(1)
hasil |> slice_sample(n = 5)
```
Panggil `set.seed()` agar hasil acak bisa direproduksi; `replace = TRUE` untuk bootstrapping.

### 18. Sampel proporsi ⭐⭐
**Soal:** Ambil 5% baris sebagai sampel.
**Jawaban:**
```r
hasil |> slice_sample(prop = 0.05)
```

## C. Select, Rename & Relocate

### 19. Pilih kolom ⭐
**Soal:** Ambil kolom Tanggal, Lini, Shift, UnitsDefect.
**Jawaban:**
```r
hasil |> select(Tanggal, Lini, Shift, UnitsDefect)
```

### 20. Helper select ⭐
**Soal:** Semua kolom berawalan `Unit` dan semua kolom berakhiran `Min`.
**Jawaban:**
```r
hasil |> select(starts_with("Unit"), ends_with("Min"))
```
Helper lain: `contains()`, `num_range()`, `everything()`, `last_col()`.

### 21. Helper + posisi ⭐⭐
**Soal:** Kolom yang mengandung `Temp`/`Humid` plus kolom terakhir.
**Jawaban:**
```r
hasil |> select(contains("Temp"), contains("Humid"), last_col())
```

### 22. Buang kolom ⭐
**Soal:** Hilangkan kolom suhu dan kelembaban.
**Jawaban:**
```r
hasil |> select(-c(TempC, HumidityPct))
```
Tanda `-` membuang kolom; `select(!TempC)` juga valid.

### 23. Predikat tipe ⭐⭐
**Soal:** Ambil hanya kolom numerik.
**Jawaban:**
```r
hasil |> select(where(is.numeric))
```
`where()` memilih kolom berdasarkan fungsi predikat.

### 24. Pindah posisi ⭐
**Soal:** Taruh Tanggal, Lini, Shift di posisi paling depan.
**Jawaban:**
```r
hasil |> relocate(Tanggal, Lini, Shift)
```
Default menaruh di awal; tersedia argumen `.before` / `.after`.

### 25. Rename ⭐
**Soal:** Ganti nama dua kolom ke bahasa Indonesia.
**Jawaban:**
```r
hasil |> rename(UnitJadi = UnitsProduced, UnitCacat = UnitsDefect)
```
Pola `rename(nama_baru = nama_lama)`.

### 26. Rename massal ⭐⭐
**Soal:** Jadikan semua nama kolom huruf kecil.
**Jawaban:**
```r
hasil |> rename_with(tolower)
```
`rename_with()` menerapkan fungsi ke *nama* kolom; bisa dibatasi dengan selektor.

### 27. Kolom jadi vector ⭐
**Soal:** Ekstrak `UnitsDefect` sebagai vector lalu hitung totalnya.
**Jawaban:**
```r
hasil |> pull(UnitsDefect) |> sum()
```
`pull()` adalah versi pipe-friendly dari `$`.

### 28. Dua cara reorder ⭐⭐
**Soal:** Naikkan `Product` ke kolom pertama tanpa menghilangkan kolom lain.
**Jawaban:**
```r
hasil |> relocate(Product, .before = 1)
hasil |> select(Product, everything())
```
`everything()` berarti "sisa kolom lain sesuai urutannya".

## D. Mutate — Membuat & Mengubah Kolom

### 29. Rasio kualitas ⭐
**Soal:** Buat kolom `DefectRate` dan `Yield` (first pass yield).
**Jawaban:**
```r
hasil |>
  mutate(
    DefectRate = UnitsDefect / UnitsProduced,
    Yield      = 1 - DefectRate
  )
```
`mutate()` boleh memakai kolom yang baru dibuat di langkah yang sama.

### 30. Format persen ⭐
**Soal:** Tampilkan defect rate sebagai teks persen terformat.
**Jawaban:**
```r
hasil |> mutate(DefectPct = percent(UnitsDefect / UnitsProduced, accuracy = 0.1))
```
`percent()` berasal dari package scales.

### 31. Flag dengan if_else ⭐
**Soal:** Tandai baris dengan defect rate ≤ 4% sebagai "OK".
**Jawaban:**
```r
hasil |>
  mutate(Status = if_else(UnitsDefect / UnitsProduced <= 0.04, "OK", "Review"))
```
`if_else()` lebih ketat soal tipe dibanding `ifelse()` base R.

### 32. Grade dengan case_when ⭐⭐
**Soal:** Grade kualitas: A jika rate < 3%, B jika < 5%, sisanya C.
**Jawaban:**
```r
hasil |>
  mutate(Grade = case_when(
    UnitsDefect / UnitsProduced < 0.03 ~ "A",
    UnitsDefect / UnitsProduced < 0.05 ~ "B",
    TRUE                               ~ "C"
  ))
```
`case_when()` dievaluasi berurutan; `TRUE` berperan sebagai else.

### 33. case_when multi-kondisi ⭐⭐
**Soal:** Peta risiko: Lini B shift Sore = "Tinggi"; Lini B atau shift Sore = "Sedang"; lainnya "Rendah".
**Jawaban:**
```r
hasil |>
  mutate(Risiko = case_when(
    Lini == "B" & Shift == "Sore" ~ "Tinggi",
    Lini == "B" | Shift == "Sore" ~ "Sedang",
    TRUE                          ~ "Rendah"
  ))
```
Kondisi paling spesifik ditulis lebih dulu.

### 34. Transformasi log ⭐
**Soal:** Rapatkan sebaran konsumsi energi dengan skala log10.
**Jawaban:**
```r
hasil |> mutate(EnergiLog = log10(EnergyKWh))
```

### 35. pmax/pmin ⭐⭐
**Soal:** Berapa menit downtime tiap baris melewati batas 60?
**Jawaban:**
```r
hasil |> mutate(DowntimeLebih = pmax(DowntimeMin - 60, 0))
```
`pmax()` bekerja element-wise; `max()` hanya mengembalikan satu nilai.

### 36. lag() ⭐⭐
**Soal:** Tambahkan kolom produksi hari sebelumnya (level harian).
**Jawaban:**
```r
harian <- hasil |>
  group_by(Tanggal) |>
  summarize(Produksi = sum(UnitsProduced), .groups = "drop") |>
  arrange(Tanggal)

harian |> mutate(Kemarin = lag(Produksi))
```
`lag()` butuh data yang sudah terurut.

### 37. cumsum() ⭐⭐
**Soal:** Hitung kumulatif unit cacat dari waktu ke waktu.
**Jawaban:**
```r
hasil |>
  group_by(Tanggal) |>
  summarize(Cacat = sum(UnitsDefect), .groups = "drop") |>
  arrange(Tanggal) |>
  mutate(Kumulatif = cumsum(Cacat))
```

### 38. Fitur tanggal ⭐
**Soal:** Turunkan Bulan, Kwarter, dan NamaHari dari `Tanggal`.
**Jawaban:**
```r
hasil |>
  mutate(
    Bulan    = month(Tanggal, label = TRUE),
    Kwarter  = quarter(Tanggal),
    NamaHari = wday(Tanggal, label = TRUE, week_start = 1)
  )
```

### 39. Kolom minggu ⭐⭐
**Soal:** Buat kolom `Minggu` (periode 7 hari, mulai hari Senin).
**Jawaban:**
```r
hasil |> mutate(Minggu = floor_date(Tanggal, "week", week_start = 1))
```

### 40. Regex di mutate ⭐⭐
**Soal:** Kelompokkan produk mekanik vs lainnya dari nama produk.
**Jawaban:**
```r
hasil |>
  mutate(Kelompok = if_else(str_detect(Product, "Bracket|Housing"),
                            "Mekanik", "Lainnya"))
```
`str_detect()` menerima regular expression.

### 41. across() ⭐⭐
**Soal:** Bulatkan suhu dan kelembaban ke bilangan bulat sekaligus.
**Jawaban:**
```r
hasil |> mutate(across(c(TempC, HumidityPct), \(x) round(x, 0)))
```
`across()` menerapkan fungsi ke banyak kolom; lambda `\(x)` memungkinkan argumen tambahan seperti `digits = 0`.

### 42. transmute() ⭐
**Soal:** Buat kolom baru lalu simpan HANYA kolom hasil transformasi.
**Jawaban:**
```r
hasil |> transmute(Tanggal, Lini, DefectRate = UnitsDefect / UnitsProduced)
```
`transmute()` = `mutate()` + `select()`.

## E. Group & Summarize

### 43. Total per grup ⭐
**Soal:** Total unit yang diproduksi per lini.
**Jawaban:**
```r
hasil |>
  group_by(Lini) |>
  summarize(TotalProduksi = sum(UnitsProduced), .groups = "drop")
```
`.groups = "drop"` membuat hasil kembali jadi tabel biasa tanpa pesan grup.

### 44. Rate tertimbang vs sederhana ⭐⭐⭐
**Soal:** Defect rate per lini — bandingkan cara tertimbang vs rata-rata sederhana.
**Jawaban:**
```r
hasil |>
  group_by(Lini) |>
  summarize(
    RateTertimbang = sum(UnitsDefect) / sum(UnitsProduced),
    RateSederhana  = mean(UnitsDefect / UnitsProduced),
    .groups        = "drop"
  )
```
Cara tertimbang lebih benar saat volume antar baris berbeda jauh.

### 45. Dua kunci grup ⭐
**Soal:** Ringkas produksi & cacat per kombinasi lini dan shift.
**Jawaban:**
```r
hasil |>
  group_by(Lini, Shift) |>
  summarize(
    Produksi = sum(UnitsProduced),
    Cacat    = sum(UnitsDefect),
    Rate     = Cacat / Produksi,
    .groups  = "drop"
  )
```
Kolom yang baru dibuat bisa langsung dirujuk di baris berikutnya.

### 46. Ringkasan per produk ⭐
**Soal:** Ringkas per produk: jumlah baris, total produksi, dan defect rate.
**Jawaban:**
```r
hasil |>
  group_by(Product) |>
  summarize(
    N        = n(),
    Produksi = sum(UnitsProduced),
    Rate     = sum(UnitsDefect) / Produksi,
    .groups  = "drop"
  )
```

### 47. Tren bulanan ⭐⭐
**Soal:** Hitung defect rate per bulan.
**Jawaban:**
```r
hasil |>
  mutate(Bulan = floor_date(Tanggal, "month")) |>
  group_by(Bulan) |>
  summarize(Rate = sum(UnitsDefect) / sum(UnitsProduced), .groups = "drop")
```

### 48. Tren mingguan per lini ⭐⭐
**Soal:** Defect rate mingguan untuk tiap lini.
**Jawaban:**
```r
hasil |>
  mutate(Minggu = floor_date(Tanggal, "week", week_start = 1)) |>
  group_by(Lini, Minggu) |>
  summarize(Rate = sum(UnitsDefect) / sum(UnitsProduced), .groups = "drop")
```

### 49. n_distinct ⭐
**Soal:** Berapa operator berbeda yang bekerja di tiap lini?
**Jawaban:**
```r
hasil |>
  group_by(Lini) |>
  summarize(Operator = n_distinct(OperatorID), .groups = "drop")
```

### 50. SD & CV ⭐⭐
**Soal:** Keragaman volume produksi per produk: SD dan CV.
**Jawaban:**
```r
hasil |>
  group_by(Product) |>
  summarize(
    Rata    = mean(UnitsProduced),
    SD      = sd(UnitsProduced),
    CV      = SD / Rata,
    .groups = "drop"
  )
```
CV = SD ÷ rata-rata — membandingkan keragaman antar skala yang berbeda.

### 51. Kuartil per grup ⭐⭐
**Soal:** Kuartil downtime per lini (abaikan NA).
**Jawaban:**
```r
hasil |>
  group_by(Lini) |>
  summarize(
    Q1     = quantile(DowntimeMin, 0.25, na.rm = TRUE),
    Median = quantile(DowntimeMin, 0.50, na.rm = TRUE),
    Q3     = quantile(DowntimeMin, 0.75, na.rm = TRUE),
    .groups = "drop"
  )
```

### 52. first & last ⭐⭐
**Soal:** Tanggal pertama & terakhir tiap lini mencatat produksi.
**Jawaban:**
```r
hasil |>
  arrange(Tanggal) |>
  group_by(Lini) |>
  summarize(
    Pertama  = first(Tanggal),
    Terakhir = last(Tanggal),
    .groups  = "drop"
  )
```
`first()`/`last()` mengikuti urutan baris — `arrange()` dulu.

### 53. Rentang aktif produk ⭐⭐
**Soal:** Rentang aktif tiap produk: tanggal awal, akhir, dan jumlah hari.
**Jawaban:**
```r
hasil |>
  group_by(Product) |>
  summarize(
    Awal  = min(Tanggal),
    Akhir = max(Tanggal),
    NHari = n_distinct(Tanggal),
    .groups = "drop"
  )
```

### 54. across() di summarize ⭐⭐
**Soal:** Rata-rata semua kolom numerik per shift (NA diabaikan).
**Jawaban:**
```r
hasil |>
  group_by(Shift) |>
  summarize(across(where(is.numeric), \(x) mean(x, na.rm = TRUE)),
            .groups = "drop")
```
Lambda base R `\(x)` identik dengan `function(x)`.

### 55. count() ⭐
**Soal:** Frekuensi baris per lini, urut dari terbanyak.
**Jawaban:**
```r
hasil |> count(Lini, sort = TRUE)
```
`count()` = `group_by() + tally()` versi singkat.

### 56. count() berbobot ⭐⭐
**Soal:** Total unit cacat per lini memakai count berbobot.
**Jawaban:**
```r
hasil |> count(Lini, wt = UnitsDefect, sort = TRUE)
```
Tanpa `wt`, `count()` hanya menghitung jumlah baris.

### 57. add_count() ⭐⭐
**Soal:** Temukan produk yang jarang muncul (kurang dari 10 baris).
**Jawaban:**
```r
hasil |> add_count(Product) |> filter(n < 10)
```
`add_count()` menempelkan hitungan grup sebagai kolom `n` tanpa meringkas — hasilnya baris-baris `Casing`.

### 58. tally() ⭐
**Soal:** Cara lain menghitung baris per produk.
**Jawaban:**
```r
hasil |> group_by(Product) |> tally()
```

### 59. filter setelah group_by ⭐⭐⭐
**Soal:** Pertahankan hanya lini dengan rata-rata defect rate di atas 4%.
**Jawaban:**
```r
hasil |>
  group_by(Lini) |>
  filter(mean(UnitsDefect / UnitsProduced) > 0.04) |>
  ungroup()
```
`filter()` setelah `group_by()` menyaring **grup**, bukan baris.

### 60. Grouped mutate: deviasi ⭐⭐
**Soal:** Hitung deviasi produksi tiap baris dari rata-rata lininya.
**Jawaban:**
```r
hasil |>
  group_by(Lini) |>
  mutate(Deviasi = UnitsProduced - mean(UnitsProduced)) |>
  ungroup()
```

### 61. Grouped mutate: share ⭐⭐
**Soal:** Kontribusi tiap baris terhadap total cacat lininya.
**Jawaban:**
```r
hasil |>
  group_by(Lini) |>
  mutate(Share = UnitsDefect / sum(UnitsDefect)) |>
  ungroup()
```

### 62. Pentingnya ungroup() ⭐⭐⭐
**Soal:** Mengapa `ungroup()` penting? Bandingkan hasil dengan dan tanpa ungroup.
**Jawaban:**
```r
bergrup <- hasil |> group_by(Lini)

summarize(bergrup, Rata = mean(UnitsProduced))            # per lini
summarize(ungroup(bergrup), Rata = mean(UnitsProduced))   # keseluruhan
```
Status "bergrup" menular ke semua operasi berikutnya — ungroup begitu selesai.

## F. Window Function & Ranking

### 63. Hari terburuk per lini ⭐⭐⭐
**Soal:** Satu hari terburuk (defect rate tertinggi) tiap lini.
**Jawaban:**
```r
hasil |>
  group_by(Lini, Tanggal) |>
  summarize(Rate = sum(UnitsDefect) / sum(UnitsProduced), .groups = "drop") |>
  group_by(Lini) |>
  arrange(desc(Rate), .by_group = TRUE) |>
  slice_head(n = 1) |>
  ungroup()
```
`.by_group = TRUE` membuat pengurutan terjadi di dalam grup.

### 64. Top-3 per grup ⭐⭐⭐
**Soal:** Tiga hari terburuk tiap lini.
**Jawaban:**
```r
hasil |>
  group_by(Lini, Tanggal) |>
  summarize(Rate = sum(UnitsDefect) / sum(UnitsProduced), .groups = "drop") |>
  group_by(Lini) |>
  slice_max(Rate, n = 3) |>
  ungroup()
```

### 65. Perbedaan fungsi rank ⭐⭐⭐
**Soal:** Pahami beda `min_rank`, `dense_rank`, dan `row_number` saat ada nilai kembar.
**Jawaban:**
```r
skor <- data.frame(
  Nama  = c("Andi", "Budi", "Citra", "Dedi", "Eka"),
  Nilai = c(90, 85, 85, 80, 80)
)

skor |>
  mutate(
    min_rank   = min_rank(Nilai),
    dense_rank = dense_rank(Nilai),
    row_number = row_number(Nilai)
  )
```
min_rank 1,2,2,4,4 · dense_rank 1,2,2,3,3 · row_number 1,2,3,4,5.

### 66. ntile ⭐⭐
**Soal:** Bagi downtime ke dalam 4 kuartil.
**Jawaban:**
```r
hasil |>
  filter(!is.na(DowntimeMin)) |>
  mutate(Kuartil = ntile(DowntimeMin, 4))
```

### 67. percent_rank ⭐⭐
**Soal:** Posisi relatif (0–1) tiap baris dalam lininya berdasarkan unit cacat.
**Jawaban:**
```r
hasil |>
  group_by(Lini) |>
  mutate(Persentil = percent_rank(UnitsDefect)) |>
  ungroup()
```

### 68. cume_dist ⭐⭐
**Soal:** Untuk produk Bracket, hitung proporsi baris dengan nilai ≤ baris ini.
**Jawaban:**
```r
hasil |>
  filter(Product == "Bracket") |>
  mutate(Cume = cume_dist(UnitsDefect))
```

### 69. lag() per grup ⭐⭐⭐
**Soal:** Bandingkan produksi hari ini vs kemarin per lini.
**Jawaban:**
```r
harian <- hasil |>
  group_by(Lini, Tanggal) |>
  summarize(Produksi = sum(UnitsProduced), .groups = "drop") |>
  arrange(Lini, Tanggal)

harian |>
  group_by(Lini) |>
  mutate(Kemarin = lag(Produksi), Selisih = Produksi - Kemarin) |>
  ungroup()
```

### 70. lead() ⭐⭐
**Soal:** Dan produksi hari berikutnya?
**Jawaban:**
```r
harian <- hasil |>
  group_by(Lini, Tanggal) |>
  summarize(Produksi = sum(UnitsProduced), .groups = "drop") |>
  arrange(Lini, Tanggal)

harian |>
  group_by(Lini) |>
  mutate(Besok = lead(Produksi)) |>
  ungroup()
```
`lead()` = kebalikan `lag()`.

### 71. Persen perubahan ⭐⭐⭐
**Soal:** Hitung persen perubahan produksi harian per lini (objek `harian` dari soal 69).
**Jawaban:**
```r
harian |>
  group_by(Lini) |>
  mutate(PctChange = Produksi / lag(Produksi) - 1) |>
  ungroup()
```
Baris pertama tiap lini menjadi `NA` karena tidak ada pembanding.

### 72. Kumulatif per grup ⭐⭐⭐
**Soal:** Kumulatif cacat berjalan per lini.
**Jawaban:**
```r
hasil |>
  group_by(Lini, Tanggal) |>
  summarize(Cacat = sum(UnitsDefect), .groups = "drop") |>
  arrange(Lini, Tanggal) |>
  group_by(Lini) |>
  mutate(Kumulatif = cumsum(Cacat)) |>
  ungroup()
```

### 73. Peringkat bulanan ⭐⭐⭐
**Soal:** Peringkat defect rate antar bulan di dalam tiap lini.
**Jawaban:**
```r
hasil |>
  mutate(Bulan = floor_date(Tanggal, "month")) |>
  group_by(Lini, Bulan) |>
  summarize(Rate = sum(UnitsDefect) / sum(UnitsProduced), .groups = "drop") |>
  group_by(Lini) |>
  mutate(Peringkat = min_rank(Rate)) |>
  ungroup()
```

### 74. Desil per operator ⭐⭐
**Soal:** Bagi riwayat produksi tiap operator ke 10 desil.
**Jawaban:**
```r
hasil |>
  group_by(OperatorID) |>
  mutate(Desil = ntile(UnitsProduced, 10)) |>
  ungroup()
```

## G. Join & Penggabungan Tabel

### 75. left_join dengan key beda nama ⭐⭐
**Soal:** Gabungkan master produk ke transaksi. Key-nya beda nama: `Product` vs `Produk`.
**Jawaban:**
```r
hasil |> left_join(produk, by = c("Product" = "Produk"))
```
`by = c("kolom_kiri" = "kolom_kanan")` dipakai saat nama kunci berbeda.

### 76. Join lalu hitung nilai kerugian ⭐⭐⭐
**Soal:** Hitung kerugian defect (unit × harga satuan), lalu total per kategori produk.
**Jawaban:**
```r
hasil |>
  left_join(produk, by = c("Product" = "Produk")) |>
  mutate(Kerugian = UnitsDefect * HargaSatuan) |>
  group_by(Kategori) |>
  summarize(TotalRugi = sum(Kerugian, na.rm = TRUE), .groups = "drop")
```
`na.rm = TRUE` diperlukan karena baris `Casing` tidak ketemu master (harganya NA).

### 77. left_join key sama ⭐⭐
**Soal:** Tambahkan nama operator ke data transaksi.
**Jawaban:**
```r
hasil |>
  left_join(operator |> select(OperatorID, Nama), by = "OperatorID") |>
  select(Tanggal, Lini, Shift, Nama, Product, UnitsProduced, UnitsDefect)
```
Nama kunci sama di kedua tabel → cukup `by = "OperatorID"`. Hanya kolom yang dibutuhkan yang di-join — bila `operator` di-join utuh, kolom `Lini` yang kembar otomatis berubah jadi `Lini.x`/`Lini.y`.

### 78. inner_join ⭐⭐
**Soal:** Ambil hanya transaksi yang produknya dikenal master.
**Jawaban:**
```r
hasil |> inner_join(produk, by = c("Product" = "Produk"))
```
Baris `Casing` hilang karena tidak punya pasangan.

### 79. right_join ⭐⭐
**Soal:** Pastikan semua operator muncul meski tidak pernah transaksi.
**Jawaban:**
```r
hasil |> right_join(operator, by = "OperatorID")
```
`OP08` muncul dengan kolom transaksi `NA` karena tidak pernah terekam.

### 80. full_join ⭐⭐
**Soal:** Tampilkan juga produk master yang tak pernah diproduksi.
**Jawaban:**
```r
hasil |> full_join(produk, by = c("Product" = "Produk"))
```
Sekaligus memperlihatkan `Kabel` (master tanpa transaksi) dan `Casing` (transaksi tanpa master).

### 81. semi_join ⭐⭐
**Soal:** Filter transaksi yang produknya dikenal — TANPA menambah kolom.
**Jawaban:**
```r
hasil |> semi_join(produk, by = c("Product" = "Produk"))
```
`semi_join()` hanya menyaring, tidak menggandakan baris.

### 82. anti_join (arah 1) ⭐⭐
**Soal:** Cari transaksi dengan produk tak dikenal (kandidat typo).
**Jawaban:**
```r
hasil |> anti_join(produk, by = c("Product" = "Produk"))
```
Hasilnya baris-baris `Casing`.

### 83. anti_join (arah 2) ⭐⭐
**Soal:** Kebalikannya — produk master yang tidak pernah diproduksi.
**Jawaban:**
```r
produk |> anti_join(hasil, by = c("Produk" = "Product"))
```
Arah `by` mengikuti urutan tabel: kiri = x, kanan = y.

### 84. Join multi-kolom ⭐⭐⭐
**Soal:** Bandingkan rate aktual vs target per kombinasi lini & shift.
**Jawaban:**
```r
target <- data.frame(
  Lini   = c("A", "A", "B", "B", "C", "C"),
  Shift  = c("Pagi", "Sore", "Pagi", "Sore", "Pagi", "Sore"),
  Target = c(0.030, 0.035, 0.038, 0.045, 0.028, 0.032)
)

hasil |>
  group_by(Lini, Shift) |>
  summarize(Rate = sum(UnitsDefect) / sum(UnitsProduced), .groups = "drop") |>
  left_join(target, by = c("Lini", "Shift")) |>
  mutate(Selisih = Rate - Target)
```
Bila semua nama kunci sama, `by` cukup berisi vektor nama kolom.

### 85. Kolom kembar (suffix) ⭐⭐⭐
**Soal:** Apa yang terjadi bila dua tabel yang di-join punya nama kolom sama?
**Jawaban:**
```r
target2 <- data.frame(Lini = c("A", "B", "C"),
                      TargetDefectRate = c(0.030, 0.040, 0.035))

hasil |>
  left_join(produk, by = c("Product" = "Produk")) |>
  left_join(target2, by = "Lini")
```
Kolom kembar otomatis menjadi `TargetDefectRate.x` dan `TargetDefectRate.y`. Atur sendiri dengan argumen `suffix = c("_transaksi", "_target")`.

### 86. bind_rows dengan .id ⭐⭐
**Soal:** Tumpuk data Juli & Agustus sambil menandai asalnya.
**Jawaban:**
```r
jul <- hasil |> filter(month(Tanggal) == 7) |> mutate(Periode = "Jul")
agu <- hasil |> filter(month(Tanggal) == 8) |> mutate(Periode = "Agu")

gabungan <- bind_rows(Juli = jul, Agustus = agu, .id = "Sumber")

count(gabungan, Sumber)
```
Nama argumen menjadi isi kolom `.id`.

### 87. bind_cols ⭐⭐
**Soal:** Tambahkan kolom peringkat ke tabel top-5 defect (penggabungan horizontal).
**Jawaban:**
```r
peringkat <- hasil |>
  arrange(desc(UnitsDefect)) |>
  slice_head(n = 5) |>
  select(Tanggal, Lini, Product, UnitsDefect)

bind_cols(peringkat, Peringkat = 1:5)
```
`bind_cols()` menuntut jumlah baris yang sama.

### 88. setequal ⭐⭐⭐
**Soal:** Pastikan pemecahan-penggabungan data tidak menghilangkan baris.
**Jawaban:**
```r
jul     <- hasil |> filter(month(Tanggal) == 7)
lainnya <- hasil |> filter(month(Tanggal) != 7)

setequal(bind_rows(jul, lainnya), hasil)
```
`TRUE` berarti isi baris identik (urutan boleh berbeda).

## H. Operasi Himpunan

### 89. intersect ⭐⭐
**Soal:** Tanggal yang tercatat baik di lini A maupun lini B (irisan).
**Jawaban:**
```r
tgl_a <- hasil |> filter(Lini == "A") |> distinct(Tanggal) |> pull()
tgl_b <- hasil |> filter(Lini == "B") |> distinct(Tanggal) |> pull()

intersect(tgl_a, tgl_b)
```

### 90. setdiff ⭐⭐⭐
**Soal:** Hari yang ada defect tetapi downtime-nya nol/kosong — indikasi pencatatan kurang.
**Jawaban:**
```r
tgl_defect <- hasil |>
  filter(UnitsDefect > 0) |>
  distinct(Tanggal) |> pull()

tgl_downtime <- hasil |>
  filter(!is.na(DowntimeMin), DowntimeMin > 0) |>
  distinct(Tanggal) |> pull()

setdiff(tgl_defect, tgl_downtime)
```
`setdiff(x, y)` = ada di x tetapi tidak ada di y.

## I. Pembersihan Data

### 91. str_trim ⭐
**Soal:** Bersihkan spasi berlebih di awal/akhir nama operator.
**Jawaban:**
```r
operator |> mutate(Nama = str_trim(Nama))
```
`str_squish()` lebih agresif: merapikan juga spasi ganda di tengah.

### 92. str_to_title ⭐
**Soal:** Perbaiki nama yang huruf kecil semua menjadi kapitalisasi judul.
**Jawaban:**
```r
operator |>
  mutate(Nama = str_to_title(str_trim(Nama)))
```
Fungsi stringr dipakai langsung di dalam `mutate()`.

### 93. Perbaiki nilai negatif ⭐⭐
**Soal:** Ada downtime negatif (salah input). Cek dulu, lalu perbaiki.
**Jawaban:**
```r
hasil |> filter(DowntimeMin < 0)

hasil |>
  mutate(DowntimeMin = if_else(DowntimeMin < 0,
                               abs(DowntimeMin), DowntimeMin))
```
Alternatif: jadikan NA saja agar nanti ditangani terpisah.

### 94. coalesce dengan median grup ⭐⭐⭐
**Soal:** Isi `TempC` yang kosong dengan median suhu lininya masing-masing.
**Jawaban:**
```r
hasil |>
  group_by(Lini) |>
  mutate(TempC = coalesce(TempC, median(TempC, na.rm = TRUE))) |>
  ungroup()
```
`coalesce()` mengambil nilai pertama yang bukan NA.

### 95. recode ⭐⭐
**Soal:** `Casing` tidak dikenal master — anggap salah ketik dari `Housing`.
**Jawaban:**
```r
hasil |> mutate(Product = recode(Product, Casing = "Housing"))
```
`recode()` mengganti nilai berdasarkan pemetaan nama.

### 96. if_all untuk cek NA massal ⭐⭐⭐
**Soal:** Buang baris yang salah satu kolom operasionalnya kosong.
**Jawaban:**
```r
hasil |>
  filter(if_all(c(DowntimeMin, TempC, HumidityPct), ~ !is.na(.x)))
```
`if_all()` = semua kolom dalam daftar harus lolos kondisi.

### 97. Isi NA dengan nilai default ⭐⭐
**Soal:** Downtime yang tidak dicatat dianggap nol.
**Jawaban:**
```r
hasil |> mutate(DowntimeMin = coalesce(DowntimeMin, 0))
```
Alternatif dari tidyr: `replace_na(DowntimeMin, 0)`.

### 98. distinct ⭐
**Soal:** Dataset punya baris duplikat persis — hilangkan.
**Jawaban:**
```r
hasil |> distinct()
```
Tanpa argumen, `distinct()` memakai semua kolom sebagai kriteria keunikan.

### 99. na.rm pada agregasi ⭐⭐
**Soal:** Kenapa rata-rata downtime tiba-tiba `NA`? Bandingkan dengan dan tanpa `na.rm`.
**Jawaban:**
```r
hasil |> summarize(Rata = mean(DowntimeMin))
hasil |> summarize(Rata = mean(DowntimeMin, na.rm = TRUE))
```
Satu NA saja membuat hasil agregasi menjadi NA — biasakan `na.rm = TRUE`.

### 100. Capstone: pipeline lengkap ⭐⭐⭐
**Soal:** Bersihkan data, hitung defect rate bulanan per lini, bandingkan dengan target, lalu beri status dan urutkan.
**Jawaban:**
```r
target <- data.frame(Lini = c("A", "B", "C"), Target = c(0.030, 0.040, 0.035))

hasil |>
  mutate(
    Product     = recode(Product, Casing = "Housing"),
    DowntimeMin = coalesce(DowntimeMin, 0),
    Bulan       = floor_date(Tanggal, "month")
  ) |>
  group_by(Lini, Bulan) |>
  summarize(
    Produksi = sum(UnitsProduced),
    Defect   = sum(UnitsDefect),
    Downtime = sum(DowntimeMin),
    .groups  = "drop"
  ) |>
  mutate(DefectRate = Defect / Produksi) |>
  left_join(target, by = "Lini") |>
  mutate(Status = if_else(DefectRate <= Target, "OK", "Perlu Tindakan")) |>
  arrange(Bulan, desc(DefectRate))
```
Gabungan mutate + group/summarize + join + arrange — pola pipeline yang khas di dunia kerja.

## Penutup

- Jawaban di atas adalah titik awal — coba rantai beberapa soal menjadi satu pipeline analisis utuh.
- Referensi fungsi lengkap: [`README.md`](README.md) di folder ini.
- Lanjutkan ke folder `Data Visualization - ggplot2` untuk memvisualkan hasil transformasi.
