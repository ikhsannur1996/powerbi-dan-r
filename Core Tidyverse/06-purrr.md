# 06 — purrr: Pemrograman Fungsional

> purrr menggantikan `for` loop dengan keluarga fungsi `map()`: terapkan satu fungsi ke setiap elemen list/vector/kolom, dan dapatkan hasil berbentuk rapi.

## Keluarga map() — Pilih Berdasarkan Tipe Output

```r
library(tidyverse)

angka <- list(1, 4, 9, 16)

map_dbl(angka, sqrt)      # numeric : 1 2 3 4
map_int(angka, \(x) length(1:x))   # integer
map_chr(angka, \(x) paste("v =", x)) # character
map_lgl(angka, \(x) x > 5)         # logical
map(angka, \(x) x * 10)            # list (bentuk bebas)
```

Pola nama: `map_<tipe output>`. Bila hasil tiap elemen panjangnya sama & ingin data frame: gunakan `map_dfr()` (row-bind) atau `map()` lalu `list_rbind()`.

## map() di Kolom data frame

```r
df <- tibble(grup = c("A", "B"),
             angka = list(c(1, 2, 3), c(10, 20)))

df |> mutate(mean = map_dbl(angka, mean))
# A tibble: 2 × 2
#   grup  angka     mean
#   <chr> <list>   <dbl>
# 1 A     <dbl[3]>    2
# 2 B     <dbl[2]>   15
```

## Formula Shorthand `~`

```r
# '~ .x' = function(.x) — singkat, untuk lambda sederhana
map_int(1:5, ~ .x * 2)
map_chr(c("budi", "siti"), ~ str_to_title(.x))
```

`.x` = elemen saat ini; `.y` = elemen kedua list (di `map2()`).

## map2 & pmap — Banyak Input

```r
# map2: dua list diproses paralel
biaya  <- c(100, 200)
margin <- c(0.1, 0.2)
map2_dbl(biaya, margin, ~ .x * (1 + .y))

# pmap: n input — parameter berupa list
params <- tibble(biaya = c(100, 200), margin = c(0.1, 0.2))
params |> pmap_dbl(\(biaya, margin) biaya * (1 + margin))
```

Nama argumen `pmap` harus cocok dengan nama kolom — sangat rapi untuk simulasi berparameter.

## keep / discard / reduce

```r
bil <- list(2, 5, 8, 11, 14)

keep(bil, \(x) x > 8)         # ambil yang lolos kondisi
purrr::discard(bil, \(x) x > 8)   # buang yang lolos (prefiks aman dari konflik)
reduce(bil, \(a, b) a + b)    # kumulatif jadi satu nilai — 40
accumulate(bil, \(a, b) a + b) # seperti reduce tapi riwayatnya disimpan
```

## Iterasi ke List-Column: nest + map (Pola Terbaik)

```r
inspeksi <- read_csv("quality_inspection.csv")

# Model per lini, hasilnya tibble rapi
inspeksi |>
  nest(.by = Line) |>
  mutate(
    model = map(data, ~ lm(Defect ~ Inspected, data = .x)),
    slope = map_dbl(model, ~ coef(.x)[["Inspected"]]),
    r_sq  = map_dbl(model, ~ summary(.x)$r.squared)
  ) |>
  select(-data, -model)
```

Satu pipeline: split → model → extract. Tanpa for-loop, tanpa state global.

## safely / possibly — Error-Handling dalam map

```r
daftar <- list("5", "abc", "12")

# safely: hasil + error disimpan dua-duanya (tidak berhenti)
hasil <- map(daftar, safely(as.numeric))
hasil

# possibly: beri nilai default bila error
map_dbl(daftar, possibly(as.numeric, otherwise = NA))
```

Tanpa purrr, satu elemen error bisa menghentikan seluruh loop. Dengan `safely`, error jadi data.

## walk — map untuk Side-Effect

```r
# walk() mengembalikan input — dipakai untuk print/save, bukan hasil
files <- c("a.csv", "b.csv")
# walk(files, ~ message("Memproses ", .x))

# Contoh nyata: save tiap grafik grup
plot_list <- list(p1 = ggplot() + theme_void(), p2 = ggplot() + theme_void())
# iwalk(plot_list, ~ ggsave(paste0(.y, ".png"), .x))
```

## imap — Iterasi dengan Nama/Indeks

```r
nilai <- c(a = 10, b = 20, c = 30)
imap_chr(nilai, ~ paste0(.y, " = ", .x))
```

## Tips

- Gunakan `map()` saat output list; `map_dbl/chr/int/lgl` saat output atomik.
- `list_rbind()` / `list_cbind()` adalah penerus `map_dfr/map_cbind` (purrr 1.0+).
- Untuk kondisi bertingkat, gabungkan dengan dplyr: `mutate(result = map_dbl(...))`.
- Saat kode `for` loop makin rumit & banyak variabel sementara → saat itu purrr menguntungkan.
- Gunakan `\(x)` (base R) daripada `~ .x` bila butuh lebih dari satu argumen.

## Referensi

- Cheatsheet: "purrr"
- Bab *Iteration* di R for Data Science: <https://r4ds.hadley.nz/iteration>
- <https://purrr.tidyverse.org>
