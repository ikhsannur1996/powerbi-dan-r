# 04 — tidyr: Merapikan Bentuk Data

> tidyr menjawab satu pertanyaan: **apakah data saya sudah tidy?** Tidy = tiap variabel satu kolom, tiap observasi satu baris, tiap nilai satu sel.

## Kenapa Perlu Dirapikan?

```r
# Lebar (wide) — enak dibaca manusia, sulit untuk dplyr/ggplot
penjualan_wide <- tibble(
  Bulan  = c("Jan", "Feb"),
  `Lini A` = c(120, 135),
  `Lini B` = c(110, 128)
)

# Panjang (long) — format tidy, siap dianalisis
penjualan_long <- tibble(
  Bulan  = rep(c("Jan", "Feb"), 2),
  Lini   = rep(c("A", "B"), each = 2),
  Unit   = c(120, 135, 110, 128)
)
```

ggplot2 & dplyr bekerja optimal pada format panjang. tidyr adalah jembatan antar keduanya.

## pivot_longer / pivot_wider

```r
library(tidyverse)

# WIDE → LONG
penjualan_wide |>
  pivot_longer(cols = c(`Lini A`, `Lini B`),
               names_to = "Lini", values_to = "Unit")

# LONG → WIDE
penjualan_long |>
  pivot_wider(names_from = Lini, values_from = Unit)
```

Kasus nyata — data lebar bulanan dari Excel:

```r
penjualan_wide2 <- tibble(
  Produk  = c("Bracket", "Housing"),
  Jan     = c(120, 110),
  Feb     = c(135, 128),
  Mar     = c(140, 133)
)

penjualan_wide2 |>
  pivot_longer(cols = Jan:Mar,
               names_to  = "Bulan",
               values_to = "Unit") |>
  mutate(Bulan = factor(Bulan, levels = c("Jan", "Feb", "Mar")))
```

## separate / unite

```r
dta <- tibble(kolom = c("A-Bracket-120", "B-Terminal-85"))

# Satu kolom → banyak
dta |> separate(kolom, into = c("Lini", "Produk", "Unit"), sep = "-")

# Banyak kolom → satu
dta |>
  separate(kolom, into = c("Lini", "Produk", "Unit"), sep = "-") |>
  unite("KodeProduk", Lini, Produk, sep = "")
```

`separate_wider_regex()` / `separate_wider_delim()` adalah versi baru yang lebih ketat (dplyr/tidyr 1.3+).

## complete / fill / replace_na

```r
tidak_lengkap <- tibble(
  Bulan = c("Jan", "Feb", "Jan", "Feb"),
  Lini  = c("A", "A", "B", "B"),
  Unit  = c(120, 135, 110, NA)
)

# complete — isi kombinasi yang hilang
tidak_lengkap |> complete(Bulan, Lini)

# fill — isi ke bawah nilai terakhir (umum di data laporan Excel)
tibble(Bulan = c("Jan", NA, NA), Lini = c("A", "B", "C")) |>
  fill(Bulan)

# replace_na — ganti NA dengan nilai tertentu
tidak_lengkap |> replace_na(list(Unit = 0))
```

## drop_na

```r
# Buang baris dengan NA di kolom tertentu (atau semua kolom)
tidak_lengkap |> drop_na(Unit)
tidak_lengkap |> drop_na()
```

## nest / unnest — List-Column

```r
library(tidyverse)
inspeksi <- read_csv("quality_inspection.csv")

# Satu baris per lini, datanya jadi list-column
per_line <- inspeksi |> nest(.by = Line)
per_line
per_line$data[[1]]      # data frame lengkap lini A di satu sel

# Unnest untuk kembali
per_line |> unnest(data)
```

Nest adalah fondasi pola "split-apply-combine" yang elegan dengan purrr:

```r
# Fit model linear per lini sekaligus
inspeksi |>
  nest(.by = Line) |>
  mutate(model = map(data, ~ lm(Defect ~ Inspected, data = .x)),
         r_sq  = map_dbl(model, ~ summary(.x)$r.squared))
```

## Case Study Mini: Data Excel "Laporan Mingguan" → Tidy

```r
mentah <- tibble(
  Minggu          = c("W1", "W2"),
  `Defect_A`      = c(5, 7),
  `Defect_B`      = c(9, 10),
  `CycleTime_A`   = c(42, 43),
  `CycleTime_B`   = c(48, 49)
)

mentah |>
  pivot_longer(-Minggu, names_to = c("Metric", "Lini"),
               names_sep = "_", values_to = "Nilai") |>
  pivot_wider(names_from = Metric, values_from = Nilai)
```

Hasil: kolom `Minggu, Lini, Defect, CycleTime` — siap dianalisis.

## Tips

- `pivot_longer(cols = everything())` untuk melipat semua kolom.
- `names_prefix =` berguna bila nama kolom punya awalan seragam (mis. `Unit_`).
- `values_drop_na = TRUE` di `pivot_longer()` membuang kombinasi kosong.
- Setelah pivot, **periksa tipe** — string angka sering perlu `as.numeric()`.
- Urutan umum: `read → pivot_longer → separate → mutate → analyze`.

## Referensi

- Cheatsheet: "Data tidying with tidyr"
- <https://tidyr.tidyverse.org>
- Bab *Tidy data* di R for Data Science: <https://r4ds.hadley.nz/data-tidy>
