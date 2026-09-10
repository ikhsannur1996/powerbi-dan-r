# Core Tidyverse

> **Tidyverse** adalah kumpulan package R yang berbagi filosofi desain yang sama: data *tidy*, sintaks konsisten, dan fungsi yang bekerja mulus satu sama lain lewat *pipe*. Cukup satu baris untuk memuat semuanya:

```r
library(tidyverse)
```

Satu perintah `library(tidyverse)` memuat **8 package core** sekaligus:

| Package | Fungsi utama | Topik di folder ini |
|---|---|---|
| `ggplot2` | Visualisasi data | [02-ggplot2.md](02-ggplot2.md) |
| `dplyr` | Manipulasi & transformasi data | [03-dplyr.md](03-dplyr.md) |
| `tidyr` | Merapikan bentuk data (pivoting, nesting) | [04-tidyr.md](04-tidyr.md) |
| `readr` | Membaca & menulis file data (CSV, TSV, dll.) | [05-readr.md](05-readr.md) |
| `purrr` | Pemrograman fungsional (iterasi, map) | [06-purrr.md](06-purrr.md) |
| `tibble` | Data frame modern dengan cetakan yang lebih baik | [07-tibble.md](07-tibble.md) |
| `stringr` | Manipulasi string / teks | [08-stringr.md](08-stringr.md) |
| `forcats` | Manipulasi faktor (data kategorikal) | [09-forcats.md](09-forcats.md) |

Selain 8 package di atas, tidyverse 2.0.0 juga otomatis memuat **lubridate** (tanggals & waktu) — dibahas di [10-lubridate.md](10-lubridate.md).

## Filosofi Bersama

1. **Tidy data** — setiap variabel satu kolom, setiap observasi satu baris, setiap nilai satu sel.
2. **Pipe `|>` / `%>%`** — alur data dari kiri ke kanan: `data |> langkah1() |> langkah2()`.
3. **Konsistensi** — argumen pertama hampir selalu data, nama fungsi jelas (`mutate`, `separate`, `map`).
4. **Error jelas** — pesan kesalahan dirancang ramah manusia, bukan mesin.
5. **Saling terhubung** — hasil satu package langsung jadi input package lain tanpa konversi.

## Isi Folder

- [01-ekosistem.md](01-ekosistem.md) — ekosistem & meta-package, yang dimuat apa saja
- [02-ggplot2.md](02-ggplot2.md) — grammar of graphics
- [03-dplyr.md](03-dplyr.md) — verbs manipulasi data
- [04-tidyr.md](04-tidyr.md) — tidy data: pivot, nest, separate
- [05-readr.md](05-readr.md) — import & ekspor data
- [06-purrr.md](06-purrr.md) — fungsional programming & map
- [07-tibble.md](07-tibble.md) — tibble, data frame modern
- [08-stringr.md](08-stringr.md) — string & regular expression
- [09-forcats.md](09-forcats.md) — factor
- [10-lubridate.md](10-lubridate.md) — tanggal & waktu

## Cara Belajar dari Folder Ini

Setiap file berisi: konsep inti → fungsi-fungsi penting dengan contoh runnable → case study mini → tips. Semua contoh memakai dataset yang sudah ada di project (`quality_inspection.csv`, `qc_*.csv`) atau data sintetis kecil, sehingga bisa langsung dijalankan di console RStudio.

```r
library(tidyverse)

inspeksi <- read_csv("quality_inspection.csv")
inspeksi |> glimpse()
```

## Referensi

- <https://www.tidyverse.org>
- <https://rstudio.github.io/cheatsheets/> — cheatsheet resmi tiap package
- *R for Data Science* (Wickham, Çetinkaya-Rundel, Grolemund) — buku induk tidyverse, gratis online: <https://r4ds.hadley.nz>
