# 03 — dplyr: Verbs Manipulasi Data

> Dplyr adalah kerja utama seorang data analyst. Dokumentasi mendalam sudah ada di folder `Data Transformation - dplyr` (termasuk `EXERCISE.md` berisi 100 kasus). File ini merangkum fondasi + hal-hal yang sering terlewat.

## Verbs Utama (6 Fungsi Paling Sering)

```r
library(tidyverse)
inspeksi <- read_csv("quality_inspection.csv")

inspeksi |> filter(DefectType == "Scratch")           # baris
inspeksi |> select(Line, DefectType, Defect)          # kolom
inspeksi |> mutate(Rate = Defect / Inspected)         # kolom baru
inspeksi |> arrange(desc(Defect))                     # urutkan
inspeksi |> summarize(Total = sum(Defect))            # ringkas
inspeksi |> group_by(Line)                            # kelompokkan
```

## Alur Khas: Group By → Summarize → Ungroup

```r
inspeksi |>
  group_by(Line, DefectType) |>
  summarize(
    N     = n(),
    Rate  = sum(Defect) / sum(Inspected),
    CTMed = median(CycleTimeSec),
    .groups = "drop"
  ) |>
  arrange(desc(Rate))
```

`.groups = "drop"` penting agar hasil tidak "nyangkut" status grup.

## Fungsi yang Sering Terlewat tapi Sangat Berguna

```r
# case_when — cabang banyak kondisi
inspeksi |>
  mutate(Grade = case_when(
    Defect / Inspected < 0.03 ~ "A",
    Defect / Inspected < 0.05 ~ "B",
    TRUE                      ~ "C"
  ))

# if_else — lebih ketat & cepat daripada ifelse() base
inspeksi |> mutate(Flag = if_else(CycleTimeSec > 45, "Lambat", "OK"))

# across — terapkan fungsi ke banyak kolom sekaligus
inspeksi |>
  summarize(across(c(Inspected, Defect, CycleTimeSec),
                   \(x) mean(x, na.rm = TRUE)))

# relocate, rename, distinct
inspeksi |> relocate(InspectionDate) |>
  rename(Lini = Line) |>
  distinct(Lini, DefectType)

# slice_max — top-N langsung
inspeksi |> slice_max(Defect, n = 5)

# bind_rows — tumpuk tabel
bind_rows(inspeksi, inspeksi, .id = "sumber")
```

## Join dalam Satu Pandangan

```r
target <- tibble(Line = c("A", "B", "C"), TargetDR = c(0.03, 0.04, 0.035))

# left_join: semua baris kiri, cocokan dari kanan (paling sering)
inspeksi |>
  group_by(Line) |>
  summarize(Rate = sum(Defect) / sum(Inspected), .groups = "drop") |>
  left_join(target, by = "Line") |>
  mutate(Status = if_else(Rate <= TargetDR, "OK", "Perlu Tindakan"))

# anti_join: baris kiri tanpa pasangan — sempurna untuk data quality check
inspeksi |> anti_join(target, by = "Line")
```

## Pipe: `|>` vs `%>%`

```r
# Native pipe (base R 4.1+) — recommended
inspeksi |> filter(Line == "A") |> nrow()

# Magrittr pipe — ada fitur tambahan `.` placeholder
inspeksi %>% filter(Defect > 5) %>% nrow()
```

Untuk kasus biasa pakai `|>`. Beda penting: `|>` butuh kurung `()` setelah fungsi tanpa argumen — `inspeksi |> nrow()` vs `%>%` yang bisa `inspeksi %>% nrow`.

## Debugging Pipeline

```r
# Lihat isi pipeline di tengah jalan — trik paling berguna!
inspeksi |>
  group_by(Line) |>
  summarize(Rate = mean(Defect / Inspected)) |>
  (\(df) { print(df); df })()     # print lalu lanjut

# Atau mulai dari RStudio: blok kode, Ctrl+Enter, dan inspect object
```

## Tips

- Gunakan `n_distinct(x)` di summarize — hitung nilai unik.
- `filter()` antar-`|` menganugrahkan `NA` ke hasil yang tak pasti — sadar `NA` dengan `is.na()`.
- Gabungan beberapa filter dengan koma = AND.
- `.by =` argumen modern di `mutate()`/`summarize()` — grup sementara tanpa `group_by()`:
  ```r
  inspeksi |>
    mutate(RateLine = Defect / sum(Inspected), .by = Line)
  ```
- `rowwise()` untuk operasi per-baris dengan beberapa kolom.

## Referensi

- Cheatsheet: `data-transformation.pdf`
- Folder `Data Transformation - dplyr` — materi + 100 exercise
- <https://dplyr.tidyverse.org>
