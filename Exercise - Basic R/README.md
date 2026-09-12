# 📘 Exercise — Basic R: Materi + Contoh + Latihan

> Pendamping **Volume 0** (Basic R, Data Manipulation & Data Visualization).
> Cara baca tiap file: **Materi singkat → Contoh kode + output → Coba sendiri**
> (modifikasi kecil dari contoh, bukan soal ujian).
>
> Dataset: `quality_inspection.csv` (48 baris inspeksi kualitas) — plus `qc_hasil_produksi.csv` (458 baris produksi harian), `qc_produk.csv` (master produk + harga) & `qc_operator.csv` (master operator) untuk materi join/teks/deskriptif.
> Prasyarat: R + RStudio, package `dplyr`, `tidyr`, `lubridate`, `stringr`, `ggplot2`, `scales`.

---

## Cara memakai folder ini

1. Buka RStudio di folder project ini (`Power BI dan R`).
2. Buka file materi berurutan (01 → 10). Tiap file bisa dibaca 10–15 menit.
3. Ketik ulang **Contoh** di Console / R Script, jalankan baris per baris, perhatikan **Output**.
4. Kerjakan **Coba sendiri** — variasinya kecil (ganti angka, kolom, atau ambang). Tidak ada kunci jawaban terpisah: jawabannya adalah contoh yang sedikit diubah.
5. Kalau error, baca pesannya: biasanya salah nama kolom (`names(quality)`), lupa `library()`, atau salah working directory (`getwd()`, `list.files()`).

## Aturan kode di folder ini

- Dataset selalu dibaca dari root project: `read.csv("quality_inspection.csv")`.
- Pipe modern: `|>` (bukan `%>%`).
- Weighted defect rate selalu `sum(Defect) / sum(Inspected)` — bukan rata-rata dari rata-rata.
- Semua contoh dijalankan dan output-nya dicantumkan apa adanya (R 4.x).

## Daftar materi

| No | File | Isi |
| --- | --- | --- |
| 1 | `latihan-01-objek-dasar.md` | Objek, `<-`, tipe data, `class()`, konversi tipe |
| 2 | `latihan-02-vektor-indexing.md` | Vektor `c()`, `seq()`, `rep()`, indexing, `NA` |
| 3 | `latihan-03-fungsi-logika.md` | Fungsi, logical function, operator, `if`/`ifelse()`/`if_else()`, `case_when()`, `coalesce()`, buat fungsi & lambda |
| 4 | `latihan-04-baca-data.md` | Membaca CSV, `str()`, `head()`, `dim()`, akses kolom |
| 5 | `latihan-05-dplyr-select-filter.md` | `select()`, helper kolom, `filter()`, pipe `|>` |
| 6 | `latihan-06-dplyr-mutate-arrange.md` | `mutate()`, `case_when()`, tanggal `lubridate`, `arrange()` |
| 7 | `latihan-07-dplyr-group-summarise.md` | `group_by()`, `summarise()`, `count()`, weighted rate |
| 8 | `latihan-08-cleaning-pipeline.md` | Diagnosa data kotor → pipeline cleaning → validasi → simpan |
| 9 | `latihan-09-ggplot2-dasar.md` | Template ggplot2: bar, column, line, scatter, boxplot, `ggsave()` |
| 10 | `latihan-10-mini-project.md` | Studi kasus end-to-end: import → cleaning → ringkasan → 2 grafik → ekspor |
| 11 | `latihan-11-gabung-tabel-join.md` | Join antar tabel: `left/inner/full/anti/semi`, `by`, `suffix`, audit master |
| 12 | `latihan-12-tidyr-reshape.md` | Ubah bentuk data: `pivot_longer/wider`, `separate`, `unite` |
| 13 | `latihan-13-tanggal-lubridate.md` | Tanggal & waktu: `as.Date`, `wday/month/quarter`, `floor_date`, `difftime` |
| 14 | `latihan-14-stringr-teks.md` | Manipulasi teks: `str_trim`, `str_detect`, `str_count`, `str_replace_all`, `str_c` |
| 15 | `latihan-15-ggplot2-lanjutan.md` | Visualisasi lanjut: `facet`, `scale`, warna `viridis/brewer`, `theme`, `ggsave` |
| 16 | `latihan-16-statistik-deskriptif.md` | Ringkasan angka: `summary/quantile/sd`, per grup, `prop.table`, `cor`, `across` → jembatan Volume 1 |

## Peta konsep (16 file dalam 1 gambar kata)

```text
01 objek & tipe data (+ list/factor/matrix)
  -> 02 vektor & indexing
    -> 03 fungsi & logika (if/ifelse/case_when, buat fungsi, lambda)
      -> 04 baca & simpan CSV, struktur data
        -> 05 pilih kolom (select/rename/distinct) & saring baris (filter)
          -> 06 kolom baru (mutate/across) & urutkan (arrange)
            -> 07 ringkas per grup (group_by/summarise/count)
              -> 08 cleaning pipeline + validasi (incl. data produksi kotor)
                -> 09 visualisasi dasar (ggplot2)
                  -> 10 mini project (semua digabung)
                -> 11 gabung tabel (join)        [lanjut alur data]
                -> 12 reshape (tidyr pivot)      [lanjut alur data]
                -> 13 tanggal & waktu (lubridate)[lanjut alur data]
                -> 14 teks (stringr)             [lanjut alur data]
                -> 15 visualisasi lanjutan (facet/theme)
                -> 16 statistik deskriptif       [jembatan Volume 1]
```

Alur lanjutan (11–16) dipakai penuh di studi kasus Volume 3 (SPC, OEE, uji hipotesis) dan Volume 4–5:

---

*Exercise Basic R — pendamping Volume 0 rangkaian pelatihan "Insight to Impact".*

