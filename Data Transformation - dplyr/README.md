# Data Transformation dengan dplyr

> Disarikan dari cheatsheet resmi Posit: **Data transformation with dplyr** (`data-transformation.pdf`). dplyr bekerja dengan *pipe* dan mengharapkan data yang *tidy*.

## Prasyarat

```r
library(dplyr)
inspeksi <- read.csv("quality_inspection.csv")
```

Konsep *tidy data*:
- Setiap **variabel** berada dalam satu kolom.
- Setiap **observasi** berada dalam satu baris.
- dplyr bekerja dengan *pipe*: `x |> f(y)` menjadi `f(x, y)`.

## Peta Fungsi Utama

| Kategori | Fungsi | Fungsi |
|---|---|---|
| Baris | `filter()`, `filter_out()`, `distinct()`, `slice()`, `slice_sample()` | `arrange()`, `arrange(desc())` |
| Kolom | `select()`, `pull()`, `relocate()`, `mutate()`, `mutate_if()` | `rename()`, `rename_with()` |
| Ringkasan | `summarize()`, `count()`, `tally()` | `group_by()`, `ungroup()` |
| Gabung tabel | `left_join()`, `right_join()`, `inner_join()`, `full_join()` | `semi_join()`, `anti_join()` |
| Susun ulang | `bind_rows()`, `bind_cols()` | `setdiff()`, `intersect()`, `setequal()` |

## Materi

### 1. Ekstraksi kasus (baris)

```r
inspeksi |> filter(DefectType == "Scratch")           # kriteria logika
inspeksi |> filter(when_any(Defect > 5, CycleTimeSec > 45))  # kondisi gabungan
inspeksi |> distinct(Line, Product)                   # hapus duplikat
inspeksi |> slice(10:15)                              # by posisi
inspeksi |> slice_sample(n = 5)                       # acak 5 baris
```

### 2. Manipulasi variabel (kolom)

```r
inspeksi |> select(Line, DefectType, Defect)          # ambil kolom
inspeksi |> select(starts_with("Ins"), ends_with("Sec"))  # helper select
inspeksi |> pull(Defect)                              # jadikan vector
inspeksi |> relocate(InspectionDate, .before = 1)     # pindah posisi kolom
inspeksi |> rename(SiklusDetik = CycleTimeSec)
```

### 3. Membuat variabel baru (`mutate`)

```r
inspeksi |>
  mutate(
    DefectRate = Defect / Inspected,                  # vectorized function
    OverCt     = if_else(CycleTimeSec > 45, TRUE, FALSE),
    Grade      = case_when(DefectRate < 0.03 ~ "A",
                           DefectRate < 0.05 ~ "B",
                           TRUE              ~ "C")
  )
```

### 4. Merangkum kasus

```r
inspeksi |> summarize(RataDefect = mean(Defect), N = n())
inspeksi |> count(Line, sort = TRUE)                  # frekuensi per grup
inspeksi |>
  group_by(Line) |>
  summarize(
    DefectRate   = sum(Defect) / sum(Inspected),
    CycleMedian  = median(CycleTimeSec)
  )
```

Fungsi ringkasan umum: `mean()`, `median()`, `sd()`, `min()`, `max()`, `sum()`, `n()`, `n_distinct()`.

### 5. Grouped mutate

```r
# standarisasi CycleTimeSec per lini produksi
inspeksi |>
  group_by(Line) |>
  mutate(CycleZ = (CycleTimeSec - mean(CycleTimeSec)) / sd(CycleTimeSec)) |>
  ungroup()
```

### 6. Join dua tabel

```r
target <- data.frame(Line = c("A", "B"), TargetDR = c(0.03, 0.04))

inspeksi |>
  group_by(Line) |>
  summarize(DefectRate = sum(Defect) / sum(Inspected)) |>
  left_join(target, by = "Line") |>
  mutate(Status = if_else(DefectRate <= TargetDR, "OK", "Perlu Tindakan"))
```

Jenis join: `left_join()` (semua baris x), `inner_join()` (irisan), `full_join()` (gabungan), `semi_join()` (baris x yang cocok), `anti_join()` (baris x yang tidak cocok). Gunakan `by = c("A" = "B")` bila nama kolom berbeda.

### 7. Menggabungkan tabel

```r
bind_rows(tabel1, tabel2, .id = "sumber")   # tumpuk vertikal
bind_cols(tabel1, tabel2)                   # gabungkan horizontal (panjang harus sama)
setequal(tabel1, tabel2)                    # cek isi baris identik
```

## Exercise

> **Latihan 100 kasus soal + jawaban: [`EXERCISE.md`](EXERCISE.md)** — memakai dataset latihan khusus (`qc_hasil_produksi.csv`, `qc_operator.csv`, `qc_produk.csv`; generator: `buat_data_latihan.R`).

Kerjakan dengan `quality_inspection.csv`:

1. **Filter**: ambil semua baris produk `Bracket` pada lini `A` dengan `Defect` di atas 4.
2. **Mutate + case_when**: buat kolom `ShiftKategori` berdasarkan tanggal — isi bebas (misal minggu awal bulan = `Pekan 1`, dst.).
3. **Summarize**: hitung `DefectRate` total per `Line` dan per `Product` — manakah kombinasi paling bermasalah?
4. **Grouped mutate**: hitung *deviation from mean* `CycleTimeSec` tiap `Product`.
5. **Join**: buat tabel target (data.frame manual) lalu join untuk menentukan status OK / tidak OK tiap lini.
6. **Ranking**: tampilkan 5 kombinasi `Line`-`DefectType` dengan jumlah defect tertinggi (`arrange` + `desc` + `slice_head`).

## Tips & Tricks

- `filter_out()` adalah kebalikan `filter()` — baris `NA` pada kondisi *dipertahankan* secara default, jadi aman terhadap missing value.
- Gunakan `when_all()` / `when_any()` di dalam `filter()` untuk menggabungkan banyak kondisi dengan rapi.
- Helper `select()` yang sering terpakai: `starts_with()`, `ends_with()`, `contains()`, `matches()`, `num_range()`, `everything()`, `last_col()`.
- `select(-kolom)` untuk membuang kolom; `select(!gear)` juga valid.
- `across()` untuk menerapkan fungsi ke banyak kolom sekaligus: `mutate(across(where(is.numeric), round, 2))`.
- `distinct()` dengan `.keep_all = TRUE` menyimpan kolom lain dari baris pertama.
- `slice_sample(prop = 0.1)` untuk ambil 10% baris acak; `replace = TRUE` untuk *bootstrapping*.
- Ganti `NA` secara kondisional dengan `replace_values()` (mirip `coalesce()`/`replace_na()`): `mutate(DefectType = replace_values(DefectType, NA ~ "Unknown"))`.
- `pmax()`/`pmin()` untuk element-wise max/min antar kolom (bukan `max()`/`min()` antar baris).
- Gunakan `setequal()` sebelum & sesudah transformasi untuk memastikan tidak ada baris yang hilang.
- Setelah `group_by()`, jangan lupa `ungroup()` bila operasi berikutnya harus berlaku ke seluruh tabel.

## Referensi

- Cheatsheet: `data-transformation.pdf` (Posit, dplyr 1.2.1, Aug 2026)
- <https://dplyr.tidyverse.org>
