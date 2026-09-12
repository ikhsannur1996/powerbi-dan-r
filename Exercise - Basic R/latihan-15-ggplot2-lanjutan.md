# Materi 15 — Visualisasi Lanjutan: Facet, Skala, Tema & Warna

> Pendamping Volume 0 · Waktu baca ±15 menit · Package: `ggplot2`, `scales`.
> Data: `qc_hasil_produksi.csv` (458 baris). Prasyarat: Materi 09 & 12.

---

## 1. Materi singkat — lapisan "pelengkap" ggplot

Grafik = data + `ggplot()` + `geom_*()` + lapisan penyempurna:

| Lapisan | Fungsi | Info kunci |
| --- | --- | --- |
| `facet_wrap(~ var)` / `facet_grid(a ~ b)` | membagi 1 grafik jadi banyak | `scales = "free_y"` per-plot |
| `scale_y_continuous(labels = ...)` | format sumbu | `percent`, `comma`, `breaks=`, `limits=` |
| `scale_colour_viridis_c()` | warna kontinu (ramah buta warna) | untuk variabel numerik |
| `scale_fill_brewer()` | palet kategori | `"Set2"`, `"Dark2"` |
| `theme_minimal()` + `theme()` | tampilan akhir | `legend.position`, `axis.text.x`, `panel.grid` |
| `position = "fill"` | proporsi 100% tiap kolom | membandingkan komposisi |
| `ggsave(file, width, height, dpi)` | simpan PNG/PDF | dpi 150–300 utk presentasi |

Kombinasi `geom_col(position = "fill")` di Materi 09 berubah jadi "bandingkan komposisi antar grup".

---

## 2. Contoh 1 — Agregasi dulu, lalu facet

```r
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)

produksi <- read.csv("qc_hasil_produksi.csv", stringsAsFactors = FALSE)

bulanan <- produksi |>
  mutate(Bulan = floor_date(as.Date(Tanggal), "month")) |>
  group_by(Lini, Bulan) |>
  summarise(Defect = sum(UnitsDefect), .groups = "drop")

ggplot(bulanan, aes(Bulan, Defect, fill = Lini)) +
  geom_col() +
  facet_wrap(~ Lini, scales = "free_y") +
  scale_y_continuous(labels = comma) +
  labs(title = "Defect per bulan, dipecah per lini", x = NULL, y = "Defect") +
  theme_minimal()
```

Selesai render (9 batang: 3 lini × 3 bulan). Penjelasan: `facet_wrap(~ Lini)` membuat 3 panel, satu per lini; `scales = "free_y"` memberi skala sumbu-y berbeda sehingga pola per lini terlihat jelas (B paling tinggi 3300-an).

## 3. Contoh 2 — Warna kontinu: downtime sebagai warna

```r
ggplot(produksi |> drop_na(), aes(UnitsProduced, UnitsDefect, colour = DowntimeMin)) +
  geom_point(alpha = 0.6) +
  scale_colour_viridis_c() +
  labs(title = "Produksi vs defect, warna = downtime",
       x = "Unit diproduksi", y = "Unit defect") +
  theme_minimal()
```

Penjelasan: `scale_colour_viridis_c()` memetakan angka (DowntimeMin) ke gradasi warna yang ramah bagi buta warna. Judul contoh plot: tren positif — makin banyak produksi, makin banyak defect (lihat Materi 16 untuk ukurannya).

## 4. Contoh 3 — Proporsi 100% & label persen

```r
produksi |>
  group_by(Lini, Shift) |>
  summarise(Defect = sum(UnitsDefect), .groups = "drop") |>
  ggplot(aes(Lini, Defect, fill = Shift)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = percent) +
  labs(title = "Komposisi defect per lini", y = "Proporsi", fill = "Shift") +
  theme_minimal()
```

Penjelasan: `position = "fill"` selalu setinggi 1 (100%) tiap lini — membandingkan **komposisi** Shift, bukan total. `labels = percent` (dari `scales`) menampilkan 0,50 → "50%".

## 5. Contoh 4 — Distribusi: histogram + warna kategori

```r
ggplot(produksi, aes(UnitsProduced, fill = Lini)) +
  geom_histogram(bins = 12, alpha = 0.7, position = "identity") +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Distribusi produksi per lini", x = "Unit", y = "Jumlah hari") +
  theme_minimal()

ggplot(produksi, aes(UnitsProduced)) +
  geom_density(fill = "steelblue", alpha = 0.4) +
  labs(title = "Kepadatan distribusi produksi", x = "Unit") +
  theme_minimal()
```

Penjelasan: `geom_histogram` = distribusi; `position = "identity"` + `alpha` = biarkan 3 lini saling timpa (transparan). `geom_density` = versi halus. Palet `Set2` memilih warna dulu lalu di-`fill`.

## 6. Contoh 5 — Simpan dengan ggsave (PNG & PDF)

```r
g <- ggplot(bulanan, aes(Bulan, Defect, colour = Lini)) +
  geom_line(linewidth = 1.1) + geom_point(size = 3) +
  scale_y_continuous(labels = comma) +
  theme_minimal()

ggsave("trend_defect_bulanan.png", g, width = 8, height = 5, dpi = 150)
ggsave("trend_defect_bulanan.pdf", g, width = 8, height = 5)   # PDF vektor utk laporan
```

Cek file: `list.files(pattern = "trend_defect")`. `dpi = 300` untuk slide Power BI agar tajam saat diperbesar.

---

## 7. Coba sendiri (±7 menit)

1. Tambahkan `ncol = 3` di `facet_wrap(~ Lini)` contoh 1 — apa perubahannya?
2. Ganti `scale_fill_brewer(palette = "Set2")` jadi `"Dark2"` — apa perbedaannya?
3. Dari Materi 09 contoh, ganti grafik defect rate per lini jadi `scale_y_continuous(labels = percent, limits = c(0, 0.10))`. Skala jadi apa?
4. Buat scatter `UnitsProduced` vs `DowntimeMin` dengan warna = `Shift` (`scale_colour_brewer(palette = "Dark2")`). Simpan PNG dpi 200.

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 16](latihan-16-statistik-deskriptif.md)