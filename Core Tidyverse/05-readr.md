# 05 — readr: Import & Ekspor Data

> readr membaca file teks (CSV, TSV, delimited) menjadi tibble — lebih cepat dari `read.csv()` base, tipe kolom lebih masuk akal, dan errornya informatif.

## Fungsi Dasar

```r
library(tidyverse)

# Baca
inspeksi <- read_csv("quality_inspection.csv")   # CSV koma (paling umum)
# read_tsv()   : tab-delimited
# read_delim() : pemisah bebas, mis. ";" (Excel Eropa)
# read_csv2()  : CSV dengan ";" dan koma desimal

# Tulis
write_csv(inspeksi, "hasil_proses.csv")
# write_tsv(), write_delim(), write_excel_csv() (BOM utk Excel)
```

## Beda dengan read.csv() Base

| Aspek | `read.csv()` | `read_csv()` |
|---|---|---|
| Hasil | data.frame | **tibble** |
| String jadi | factor (R < 4.0) | **character** |
| Kecepatan | lambat | jauh lebih cepat (C++) |
| Progres | — | progress bar + spesifikasi kolom |
| Parse gagal | diam-diam jadi NA | dilaporkan (warning per kolom) |

## Kontrol Tipe Kolom

```r
# Lihat spesifikasi kolom tanpa membaca penuh
spec(inspeksi)

# Tentukan tipe secara eksplisit
read_csv("quality_inspection.csv",
         col_types = cols(
           InspectionDate = col_date(format = ""),
           Line      = col_character(),
           Product   = col_character(),
           DefectType = col_character(),
           Inspected = col_integer(),
           Defect    = col_integer(),
           CycleTimeSec = col_double()
         ))
```

Tipe parser utama: `col_double()`, `col_integer()`, `col_character()`, `col_date()`, `col_datetime()`, `col_time()`, `col_factor()`, `col_logical()`, `col_guess()`.

## Opsi yang Sering Dipakai

```r
# Semua opsi ini dipakai sesuai kebutuhan (contoh pola pemakaian):
read_csv(
  "quality_inspection.csv",
  skip    = 0,            # lewati baris header sisa ekspor Excel bila ada
  n_max   = 5,            # baca sebagian saja (untuk preview)
  na      = c("", "NA", "-"),  # nilai yang dianggap NA
  locale  = locale(decimal_mark = ","),  # angka gaya Eropa: "1,5"
  trim_ws = TRUE,
  show_col_types = FALSE
)
```

## File dari Internet & Excel

```r
# URL langsung — readr mendukung http(s)
# df <- read_csv("https://raw.githubusercontent.com/user/repo/main/data.csv")

# Excel: pakai readxl (anggota tidyverse, harus dimuat terpisah)
# install.packages("readxl")
library(readxl)
# excel_sheets("data.xlsx")            # daftar sheet
# read_excel("data.xlsx", sheet = 2)
```

## Parse Vektor — Fungsi Tunggal

Fungsi `parse_*()` bekerja pada vector — berguna untuk perbaikan kolom setelahnya:

```r
parse_number("$1,234.56")        # 1234.56 — buang non-angka
parse_number("1.234,56", locale = locale(decimal_mark = ",",
                                         grouping_mark = "."))  # 1234.56
parse_date("2026-07-01")          # Date
parse_datetime("2026-07-01 08:30")
parse_logical(c("TRUE", "FALSE", "NA"))
parse_double(c("1,5", "2,5"), locale = locale(decimal_mark = ","))

# parse_ cenderung kasih warning daripada error:
parse_double(c("1", "abc"))       # 1, NA + warning
problems(inspeksi_gagal <- read_csv("quality_inspection.csv",
                                    col_types = cols(Inspected = col_integer())))
problems(inspeksi_gagal)          # detail baris yang gagal parse
```

## Case Study Mini: CSV "Berantakan"

```r
berantakan <- tibble::tribble(
  ~v1,        ~v2,       ~v3,
  "Tanggal",  "Unit",    "Rate",     # header kedua (harus di-skip)
  "2026-07-01", "1.200", "3,5",
  "2026-07-02", "1.150", "4,0"
)

write_csv(berantakan, "berantakan.csv", na = "")

read_csv("berantakan.csv",
         skip = 1,
         col_names = c("Tanggal", "Unit", "Rate"),
         locale = locale(decimal_mark = ","),
         col_types = cols(Tanggal = col_date(), Unit = col_double(),
                          Rate = col_double()))
```

## Tips

- Selalu **cek warning** setelah `read_csv()` — kegagalan parse adalah sumber data rusak yang paling sering.
- `col_types` eksplisit untuk data produksi (Power BI) — hasil tidak berubah saat isi file berubah.
- Untuk file raksasa, pakai `vroom::vroom()` (lazy / ALTREP) — anggota ekosistem tidyverse.
- `write_csv()` tidak menyimpan tipe — bila butuh tipe tersimpan, pakai `saveRDS()`/`readRDS()` atau `arrow::write_feather()`.

## Referensi

- Cheatsheet: "Data import"
- <https://readr.tidyverse.org>
- Bab *Data import* di R for Data Science: <https://r4ds.hadley.nz/data-import>
