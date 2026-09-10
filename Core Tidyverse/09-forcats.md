# 09 — forcats: Factor (Data Kategorikal)

> Factor adalah cara R menyimpan data kategorikal: integer + kamus label (*levels*). Urutan levels menentukan urutan tampil di plot, tabel, dan model. **forcats** = *for categorical variables* (anagram "factors").

## Kenapa Factor Penting?

```r
library(tidyverse)
inspeksi <- read_csv("quality_inspection.csv")

# Tanpa factor: bar chart urut alfabet, bukan urutan nilai
ggplot(inspeksi, aes(DefectType)) + geom_bar()

# Dengan factor + fct_infreq: urut dari terbanyak
inspeksi |>
  mutate(DefectType = fct_infreq(DefectType)) |>
  ggplot(aes(DefectType)) + geom_bar()
```

Urutan level mengubah tampilan **tanpa mengubah data**.

## Membuat & Mengubah Level

```r
# Membuat factor
ukuran <- factor(c("S", "M", "L", "M", "S"),
                 levels = c("S", "M", "L"), ordered = TRUE)
ukuran

# Lihat & ubah levels
levels(ukuran)
fct_unique(ukuran)

# Renaming
fct_recode(ukuran, Kecil = "S", Sedang = "M", Besar = "L")

# Relevel / reorder berbasis nilai lain (sangat sering dipakai!)
df <- tibble(DefectType = c("Scratch", "Dimension", "Crack"),
             Total      = c(45, 32, 27))
df |> mutate(DefectType = fct_reorder(DefectType, Total))     # kecil→besar
df |> mutate(DefectType = fct_reorder(DefectType, -Total))    # besar→kecil
```

## Menggabungkan Level

```r
 jenis <- factor(c("Scratch", "Dimension", "Crack", "Color", "NONE", "Lain2"))

# fct_lump: gabungkan kategori kecil jadi "Other"
set.seed(1)
x <- sample(c(rep("Scratch", 50), rep("Dimension", 30),
              rep("Crack", 12), rep("Color", 5), rep("Lain2", 3)))
fct_count(fct_lump(x, n = 2))       # sisakan 2 terbesar, sisanya Other

# fct_collapse: gabungkan secara eksplisit
fct_collapse(jenis, Visual = c("Scratch", "Color"),
                    Struktur = c("Crack", "Dimension"))
```

## Menambah / Membuang Level

```r
# fct_expand: pastikan level ada (meski belum muncul)
fct_expand(factor(c("A", "B")), "C")

# fct_drop: buang level yang tak terpakai
fct_drop(factor(c("A", "A", "B"), levels = c("A", "B", "C")))

# fct_na_value_to_level: NA jadi level eksplisit
fct_na_value_to_level(factor(c("A", NA, "B")), level = "(kosong)")
```

## Case Study Mini: Urutkan Bar Chart & Rapikan Kategori Jarang

```r
inspeksi |>
  mutate(
    DefectType = fct_infreq(DefectType),                    # urut frekuensi
    DefectType = fct_lump_min(DefectType, min = 10,         # kecil → Lainnya
                              other_level = "Lainnya")
  ) |>
  count(DefectType) |>
  ggplot(aes(x = DefectType, y = n)) +
  geom_col() +
  labs(x = NULL, y = "Jumlah baris")
```

Pola di atas adalah resep standar membuat bar chart kategori yang rapi.

## Daftar Fungsi Penting

| Fungsi | Kegunaan |
|---|---|
| `fct_reorder(f, x)` | urutkan level berdasarkan nilai x |
| `fct_infreq(f)` | urutkan dari frekuensi terbesar |
| `fct_rev(f)` | balik urutan |
| `fct_recode(f, baru = lama)` | ganti nama level |
| `fct_lump(f, n=)` / `fct_lump_min(f, min=)` | gabung kategori kecil |
| `fct_collapse(f, baru = c(lama1, lama2))` | gabung eksplisit |
| `fct_expand` / `fct_drop` | tambah / buang level |
| `fct_count(f)` | frekuensi per level (seperti count) |
| `fct_cross(f1, f2)` | kombinasi dua faktor |

## Tips

- Kolom karakter yang akan **ditampilkan di sumbu/legend** → pertimbangkan jadi factor.
- `fct_reorder()` di dalam `aes()` langsung juga valid: `aes(x = fct_reorder(DefectType, Defect))`.
- Factor dengan `ordered = TRUE` memungkinkan perbandingan `<` `>` (mis. grade A < B < C).
- Saat join/bind dua tabel dengan factor, level bisa berbeda — pertimbangkan kembali `fct_expand`/`fct_unify`.

## Referensi

- Cheatsheet: "Factors with forcats"
- Bab *Factors* di R for Data Science: <https://r4ds.hadley.nz/factors>
- <https://forcats.tidyverse.org>
