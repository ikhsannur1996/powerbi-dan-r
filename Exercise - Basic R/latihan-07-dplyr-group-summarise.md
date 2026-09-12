# Materi 07 — Ringkasan per Grup (dplyr)

> Pendamping Volume 0 · Waktu baca ±12 menit · Dataset `quality_inspection.csv`.
> Awali: `library(dplyr)` + baca CSV (lihat Materi 05 contoh 1).

---

## 1. Materi singkat

`group_by()` + `summarise()` = "bagi data per kelompok, lalu hitung satu angka per kelompok".
Rumus baca: `quality |> group_by(Line) |> summarise(...)` = "dari quality, kelompokkan per lini, lalu ringkas...".

| Fungsi agregasi | Artinya |
| --- | --- |
| `n()` | jumlah baris grup |
| `sum()`, `mean()`, `median()`, `min()`, `max()` | total / rata-rata / tengah / min / maks |
| `n_distinct()` | jumlah nilai unik |
| `count(kolom)` | jalan pintas `group_by() + summarise(n = n())` |

Aturan defect rate: selalu **weighted** — `sum(Defect) / sum(Inspected)`.
Jangan `mean(DefectRate)`: baris kecil (inspected 100) dan baris besar (inspected 1000) diperlakukan sama — tidak adil.
Selalu tutup dengan `.groups = "drop"` agar hasil tidak "terkunci grup".

---

## 2. Contoh 1 — Hitung baris per lini (dua cara)

```r
quality |> group_by(Line) |> summarise(N = n(), .groups = "drop")
quality |> count(Line)
```

Output (keduanya sama):

```text
# A tibble: 3 × 2
  Line      N
  <chr> <int>
1 A        16
2 B        16
3 C        16
```

## 3. Contoh 2 — Defect rate per lini (weighted) + urutan

```r
ringkasan_line <- quality |>
  group_by(Line) |>
  summarise(
    TotalInspected = sum(Inspected),
    TotalDefect    = sum(Defect),
    DefectRate     = sum(Defect) / sum(Inspected),
    .groups        = "drop"
  )

ringkasan_line |> arrange(desc(DefectRate))
```

Output:

```text
# A tibble: 3 × 4
  Line  TotalInspected TotalDefect DefectRate
  <chr>          <int>       <int>      <dbl>
1 B               2021         148     0.0732
2 A               1920          57     0.0297
3 C               2235          45     0.0201
```

Penjelasan: lini B 7.32% — lebih dari 2× lini A dan 3× lini C. Jawaban bisnis: **lini B terburuk**.
Cek jebakan rata-rata-dari-rata-rata: `mean()` per baris memberi angka berbeda — itulah kenapa `sum/sum` wajib.

## 4. Contoh 3 — Ringkas dua level + saring hasil ringkasan

```r
quality |>
  group_by(Line, DefectType) |>
  summarise(TotalDefect = sum(Defect), .groups = "drop") |>
  filter(TotalDefect > 8) |>
  arrange(desc(TotalDefect))
```

Output:

```text
# A tibble: 7 × 3
  Line  DefectType TotalDefect
  <chr> <chr>            <int>
1 B     Scratch             76
2 B     Crack               56
3 A     Scratch             21
4 A     Dimension           20
5 C     Color               18
6 B     Dimension           16
7 C     Dimension           16
```

Penjelasan: `filter()` **setelah** `summarise()` menyaring hasil ringkasan (bukan baris mentah).
Dua kombinasi teratas (B-Scratch 76, B-Crack 56) = 132 dari 250 total defect (52.8%) — fokus perbaikan di sana.

## 5. Contoh 4 — Statistik cycle time & produk

```r
quality |>
  group_by(Line) |>
  summarise(
    MeanCT   = round(mean(CycleTimeSec), 1),
    MedianCT = median(CycleTimeSec),
    MinCT    = min(CycleTimeSec),
    MaxCT    = max(CycleTimeSec),
    .groups  = "drop"
  )

quality |>
  group_by(Product) |>
  summarise(
    NLini       = n_distinct(Line),
    Inspected   = sum(Inspected),
    JenisDefect = n_distinct(DefectType),
    .groups     = "drop"
  )
```

Output:

```text
# A tibble: 3 × 5
  Line   MeanCT MedianCT MinCT MaxCT
  <chr>   <dbl>    <dbl> <int> <int>
1 A        42.2       42    41    43
2 B        49.8       50    46    52
3 C        40         40    39    41

# A tibble: 2 × 4
  Product NLini Inspected JenisDefect
  <chr>   <int>     <int>       <int>
1 Bracket     2      3941           4
2 Panel       1      2235           3
```

Penjelasan: lini B tidak hanya defect tertinggi tapi juga paling lambat (rata-rata 49.8 vs 40–42 detik).
Bracket diproduksi 2 lini dengan 4 jenis defect; Panel 1 lini (C) dengan 3 jenis. Selalu pakai `na.rm = TRUE` di `mean()`/`median()` bila data bisa mengandung NA (dataset ini bersih, tapi kebiasaan aman).

## 6. Contoh 5 — `count(wt = )`, `slice_max()` & bukti weighted vs rata-rata

```r
# count(wt = Defect): total defect per jenis (bukan jumlah baris)
quality |> count(DefectType, wt = Defect, sort = TRUE)

# slice_max: baris 2 teratas berdasar defect rate
quality |>
  mutate(Rate = Defect / Inspected) |>
  slice_max(Rate, n = 2) |>
  select(Line, Product, Defect, Inspected)

# Bukti konsep: weighted vs mean(DefectRate)
quality |>
  mutate(DR = Defect / Inspected) |>
  group_by(Line) |>
  summarise(
    Weighted   = round(sum(Defect) / sum(Inspected), 4),
    Unweighted = round(mean(DR), 4),
    .groups    = "drop"
  )
```

Output:

```text
# A tibble: 5 × 2
  DefectType     n
  <chr>      <int>
1 Scratch       97
2 Crack         64
3 Dimension     52
4 NONE          19
5 Color         18

# A tibble: 2 × 4
  Line Product Defect Inspected
1    B Bracket     12       126
2    B Bracket     11       123

# A tibble: 3 × 3
  Line  Weighted Unweighted
  <chr>    <dbl>      <dbl>
1 A       0.0297     0.0297
2 B       0.0732     0.0732
3 C       0.0201     0.0202
```

Penjelasan: `count(wt = Defect)` menjumlahkan nilai bukan jumlah baris — urutan sebenarnya berdasarkan **unit** (Scratch 97, Crack 64). `slice_max()` mengambil baris-baris teratas tanpa `arrange()`. Kolom `Weighted` vs `Unweighted` nyaris sama di dataset ini (varian inspected kecil), TAPI konsepnya tetap wajib: kalau satu baris inspected = 100 dan lainnya = 1.000, `mean(DefectRate)` akan timpang. Gunakan `sum/sum`.

---

## 7. Coba sendiri (±5 menit)

1. Ringkas per `DefectType`: total defect + jumlah baris, urutkan menurun. Jenis apa teratas? (Acuan: `Scratch` 108, `Crack` 64 — cek dengan `count(DefectType, sort = TRUE)`.)
2. Ringkas per `Line`: rata-rata `Inspected` per baris. Lini apa terbesar? (Petunjuk: total ÷ 16.)
3. Dari contoh 3, naikkan ambang ke `TotalDefect > 20`. Kombinasi apa yang tersisa? (Jawab: 3 — B-Scratch, B-Crack, A-Scratch.)
4. Jelaskan satu kalimat: kenapa `sum(Defect)/sum(Inspected)` lebih adil daripada `mean(DefectRate)`? (Petunjuk: bobot inspected.)

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 08](latihan-08-cleaning-pipeline.md)

