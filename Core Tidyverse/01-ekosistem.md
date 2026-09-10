# 01 — Ekosistem Tidyverse & Meta-Package

## Apa yang Sebenarnya Dimuat `library(tidyverse)`?

`tidyverse` adalah **meta-package**: package yang isinya terutama adalah *dependency* ke package lain. Saat dimuat, ia:

1. **Attach** 8 package core + lubridate — fungsi-fungsinya langsung bisa dipakai.
2. **Memuat konflik handler** — bila ada fungsi bernama sama dari base R atau package lain, tidyverse menampilkan pesan yang menjelaskan aturan prioritas:

```
── Attaching core tidyverse packages ───────────────────────
✔ dplyr     1.2.1     ✔ readr     2.2.0
✔ forcats   1.0.1     ✔ stringr   1.6.0
✔ ggplot2   4.0.3     ✔ tibble    3.3.1
✔ lubridate 1.9.5     ✔ tidyr     1.3.2
✔ purrr     1.2.2
── Conflicts ───────────────────────────────────────────────
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
```

Aturannya: **package yang dimuat paling akhir menang**. Itulah sebabnya `filter()` dan `lag()` milik dplyr menutupi versi `stats` — biasanya inilah yang diinginkan.

## Cara Menyiasati Konflik

```r
library(tidyverse)

# Pakai versi eksplisit bila perlu versi base / package lain:
stats::filter   # fungsi filter bawaan stats
dplyr::filter   # fungsi filter data manipulation

# Cara elegan: namespace-specific selection
conflicted::conflict_prefer("filter", "dplyr")
```

## Fungsi Bantu Meta-Package

```r
tidyverse_packages()    # daftar package yang di-attach
tidyverse_conflicts()   # daftar konflik aktif
tidyverse_logo()        # logo ASCII ;)
# tidyverse_update()    # cek versi baru (butuh koneksi & mirror CRAN)
```

## Keluarga Tidyverse yang Tidak Otomatis Dimuat

Tidyverse lebih besar dari 8 core-nya. Beberapa package "anggota" sering dibutuhkan tapi harus di-*load* sendiri:

| Package | Fungsi | Instal |
|---|---|---|
| `scales` | format axis & label (percent, comma) | bagian dari instalasi tidyverse |
| `haven` | baca SPSS/Stata/SAS | `install.packages("haven")` |
| `jsonlite` | JSON | `install.packages("jsonlite")` |
| `rvest` | web scraping | `install.packages("rvest")` |
| `httr2` | akses API | `install.packages("httr2")` |
| `xml2` | XML | `install.packages("xml2")` |
| `curl` | koneksi internet | `install.packages("curl")` |
| `dbplyr` | dplyr ke database SQL | `install.packages("dbplyr")` |
| `feather` | baca tulis cepat | `install.packages("arrow")` |

```r
# Contoh: scales sering dipakai bersama ggplot2/dplyr
library(scales)
percent(0.0425, accuracy = 0.1)   # "4.3%"
comma(1234567)                    # "1,234,567"
```

## Alt: Instal Parsial

Tidak wajib instal seluruh meta-package — bisa per package:

```r
install.packages("dplyr")     # hanya dplyr
library(dplyr)
```

Tapi untuk pemula, `install.packages("tidyverse")` + `library(tidyverse)` paling praktis.

## Alternatif Berbasis tidyverse

- **tidymodels** — machine learning (parsnip, recipes, rsample, workflows)
- **rmarkdown / quarto** — laporan reproducible
- **shiny** — web app interaktif
- **data.table** — bukan tidyverse, tapi alternatif performa tinggi

## Cek Versi Sesi

```r
sessionInfo()          # ringkasan versi R + semua package sesi ini
packageVersion("ggplot2")
```
