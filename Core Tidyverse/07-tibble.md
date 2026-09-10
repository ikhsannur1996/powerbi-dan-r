# 07 — tibble: Data Frame Modern

> tibble adalah versi modern `data.frame`: cetakan lebih informatif, aturan subset lebih aman, tidak mengubah tipe di belakang punggung.

## Membuat tibble

```r
library(tidyverse)

# tibble() — boleh rujuk kolom yang baru dibuat!
tibble(
  x = 1:5,
  y = x * 2,            # langsung pakai x
  z = y + x
)

# tribble() — transposed tibble, enak untuk data kecil manual
murid <- tribble(
  ~Nama, ~Nilai,
  "Budi",   85,
  "Siti",   92,
  "Andi",   78
)
```

`tribble()` sangat praktis untuk contoh, tabel target/lookup, atau test case.

## Beda cetakan dengan data.frame

```r
murid
# A tibble: 3 × 2
#   Nama  Nilai
#   <chr> <dbl>
# 1 Budi     85
# 2 Siti     92
# 3 Andi     78
```

- Hanya menampilkan **10 baris pertama** dan kolom yang muat layar.
- Baris pertama menunjukkan **tipe** tiap kolom (`<chr>`, `<dbl>`, `<int>`, `<date>`).
- Nama kolom tidak pernah diubah diam-diam (data.frame mengubah spasi jadi titik).

## Subset yang Lebih Aman

```r
murid$Nilai          # vector — sama seperti base
murid[["Nilai"]]     # vector
murid[1, "Nilai"]    # tetap tibble (bukan vector!)

# Partial matching TIDAK dilakukan — memancing error awal
murid$N              # NULL + warning (base R diam-diam memberi hasil)

# Untuk kolom yang belum tentu ada:
murid |> pull(Nilai)
murid |> pluck("Nilai")
```

## Opsi Tampilan

```r
print(murid, n = 10, width = Inf)  # tampil semua
glimpse(murid)                     # transposed — tiap kolom satu baris
# View(murid)                      # viewer spreadsheet — hanya di RStudio interaktif
```

## Kolom Bertipe Unik (list-column)

```r
tibble(
  grup = c("A", "B"),
  nilai = list(c(1, 2, 3), c(10, 20))   # kolom berisi vector!
)
```

List-column adalah fondasi nest()/map() — tidak bisa dilakukan data.frame biasa.

## Konversi

```r
as_tibble(mtcars)       # data.frame → tibble
as.data.frame(murid)    # tibble → data.frame (bila library lama butuh)

# rownames menjadi kolom
as_tibble(mtcars, rownames = "Mobil")
```

## Fungsi Bantu Lain

```r
# enframe: named vector → tibble dua kolom
x <- c(a = 1, b = 2, c = 3)
enframe(x)                    # kolom name, value
deframe(enframe(x))           # kembali ke named vector

# add_row & add_column
murid |> add_row(Nama = "Rina", Nilai = 88)
murid |> add_column(Lulus = TRUE)
```

## Tips

- Gunakan `tribble()` saat butuh data contoh yang dibaca manusia.
- `glimpse()` adalah cara tercepat melihat struktur + tipe + sampel isi.
- Jika fungsi package lama menolak tibble → `as.data.frame()` di titik terakhir pipe.
- tibble **tidak** mendukung rownames secara bermakna — lupakan rownames, jadikan kolom.

## Referensi

- <https://tibble.tidyverse.org>
- Bab *Tibbles* di R for Data Science: <https://r4ds.hadley.nz/tibbles>
