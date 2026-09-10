# 08 — stringr: Manipulasi Teks & Regex

> Semua fungsi stringr diawali `str_` — mudah ditebak dengan autocomplete — dan semuanya vectorized: satu panggilan untuk seluruh kolom.

## Deteksi: str_detect & friends

```r
library(tidyverse)
teks <- c("Bracket Baut", "Housing Press", "Terminal Kuningan", "Panel Listrik")

str_detect(teks, "Bracket")        # TRUE FALSE FALSE FALSE
str_detect(teks, "^H")             # mulai dengan H → FALSE TRUE FALSE FALSE
str_which(teks, "Panel")           # posisi indeks: 4
str_count(teks, "n")               # hitung kemunculan 'n'
str_starts(teks, "B")              # alias lebih eksplisit dari ^
str_ends(teks, "k")                # akhir dengan k
```

## Subset & Ambil Isi

```r
str_sub(teks, 1, 5)                # potong posisi 1–5
str_extract(teks, "\\d+")          # angka pertama
str_extract_all("A1 B22 C333", "\\d+")   # semua angka → list
str_match(teks, "(\\w+) (\\w+)")   # hasil bergrup regex
```

## Penggantian & Pemecahan

```r
str_replace(teks, "Baut", "Baut M6")
str_replace_all("2026/07/01", "/", "-")

str_split("A-Bracket-120", "-")[[1]]    # hasil list → ambil elemen pertama
str_split_i("A-Bracket-120", "-", 2)    # langsung ambil bagian ke-2: "Bracket"

str_remove(teks, " Baut")
str_remove_all("1.234.567", "\\.")
```

## Perapian

```r
kotor <- c("  Budi  ", "Siti   Rahma", "  Andi")

str_trim(kotor)          # buang spasi ujung
str_squish(kotor)        # trim + spasi ganda di tengah jadi satu
str_to_lower(kotor); str_to_upper(kotor); str_to_title(kotor)
str_pad("42", width = 5, side = "left", pad = "0")   # "00042"
str_trunc("Teks yang sangat panjang sekali", width = 15)
```

## Penggabungan & Panjang

```r
str_c("Lini", "A", sep = "-")              # "Lini-A"
str_c(c("A", "B"), 1:2, sep = "")          # vectorized: "A1" "B2"
str_flatten(c("Budi", "Siti"), ", ")       # "Budi, Siti"
str_length(teks)                            # panjang tiap elemen
str_dup("ab", 3)                            # "ababab"
```

## Cheat Sheet Regex

| Pattern | Arti |
|---|---|
| `.` | karakter apa pun |
| `^x` / `x$` | mulai / berakhir dengan x |
| `\\d` `\\w` `\\s` | digit / huruf-angka / whitespace |
| `[abc]` | salah satu dari a, b, c |
| `[^abc]` | bukan a, b, c |
| `x?` `x+` `x*` | 0-1, ≥1, ≥0 kali |
| `x{2,4}` | 2 sampai 4 kali |
| `(abc)` | grup (bisa dirujuk `\\1`) |
| `a\\|b` | ATAU |
| `(?i)` | case-insensitive |

```r
# Contoh gabungan regex:
str_detect(teks, "(?i)panel|bracket")
str_extract("Order #2026-001 tgl 2026-07-01", "\\d{4}-\\d{3}")
```

## Case Study Mini: Bersihkan Kolom Teks

```r
laporan <- tibble(
  catatan = c("  scratch garis B   ", "DIMENTION-OUT", "crack/retak", "none")
)

laporan |>
  mutate(
    catatan_bersih = str_squish(str_to_lower(catatan)),
    jenis = case_when(
      str_detect(catatan_bersih, "scratch") ~ "Scratch",
      str_detect(catatan_bersih, "diment")  ~ "Dimension",
      str_detect(catatan_bersih, "crack")   ~ "Crack",
      TRUE                                  ~ "Lainnya"
    ),
    kata_dua = str_split_i(catatan_bersih, " ", 2)
  )
```

Pola `mutate(str_detect(...))` seperti di atas adalah cara paling umum menggolongkan teks bebas menjadi kategori bersih.

## Tips

- Semua `str_` fungsi vectorized — jangan pakai for-loop.
- `str_view(teks, "pattern")` menampilkan *highlight* hasil match di viewer — alat debug regex terbaik.
- Untuk nol-or-more tanda spasi: `"\\s*"`. Untuk angka: `"\\d+"`.
- Regex bisa diuji online di <https://regex101.com> (pilih flavor R/PCRE).
- Package `stringi` menawarkan fungsionalitas lebih luas bila perlu (unicode, translite).

## Referensi

- Cheatsheet: "stringr / Regular Expressions"
- Bab *Strings* di R for Data Science: <https://r4ds.hadley.nz/strings>
- <https://stringr.tidyverse.org>
