# Materi 13 — Tanggal & Waktu (lubridate)

> Pendamping Volume 0 · Waktu baca ±15 menit · Package: `lubridate`.
> Dataset: `qc_hasil_produksi.csv` (periode 2026-07-01 s.d. 2026-09-26).

---

## 1. Materi singkat — tanggal itu bukan teks

Tanggal mentah dari CSV berupa `character` (`"2026-07-01"`). Di-`as.Date()` jadi kelas `Date` agar bisa diurutkan, dikurangi, dan diambil bagiannya (tahun, bulan, hari).

| Fungsi | Hasil | Contoh input → output |
| --- | --- | --- |
| `as.Date(tgl)` | `Date` dari `"YYYY-MM-DD"` | `"2026-07-15"` → `2026-07-15` |
| `lubridate::ymd/dmy` | parses berbagai format | `"15/07/2026"` → `dmy()` |
| `year()`, `month()`, `day()` | ambil bagian tanggal | `month(t)` → 7 |
| `month(t, label = TRUE)` | nama bulan | → `July` |
| `wday(t, label = TRUE)` | nama hari | → `Wednesday` |
| `quarter()` | kuartal | `2026-07-15` → `2026.3` |
| `floor_date(t, "month")` | potong ke awal bulan | `2026-07-15` → `2026-07-01` |
| `difftime(a, b)` | selisih waktu | 38 hari, dst. |

`floor_date()` adalah kunci untuk **agregasi**: ganti tingkat ketelitian tanggal (`"month"`, `"week"`, `"day"`).

---

## 2. Contoh 1 — Parsing & ekstraksi

```r
library(dplyr)
library(lubridate)

t <- as.Date(c("2026-07-15", "2026-08-22"))
t                                  # Date
wday(t, label = TRUE, abbr = FALSE)
month(t, label = TRUE, abbr = FALSE)
quarter(t, with_year = TRUE)
format(t, "%d %b %Y")              # output teks untuk judul grafik
difftime(t[2], t[1], units = "days")
```

Output:

```text
[1] "2026-07-15" "2026-08-22"
[1] Wednesday Saturday
[1] July   August
[1] 2026.3 2026.3
[1] "15 Jul 2026" "22 Aug 2026"
Time difference of 38 days
```

Penjelasan: `wday(..., label = TRUE)` mengembalikan **factor** terurut (Sunday…Saturday) — berguna untuk mengurutkan grafik oleh hari. `format()` mengubah Date jadi teks hanya untuk tampilan.

Trik parsing format lain:

```r
ymd("2026-07-15")
dmy("15/07/2026")
```

Output:

```text
[1] "2026-07-15"
[1] "2026-07-15"
```

## 3. Contoh 2 — Tanggal di dalam pipeline (kolom baru)

```r
produksi <- read.csv("qc_hasil_produksi.csv", stringsAsFactors = FALSE)

produksi |>
  mutate(T = as.Date(Tanggal),
         Hari   = wday(T, label = TRUE, abbr = FALSE),
         Bulan  = month(T, label = TRUE, abbr = FALSE)) |>
  select(T, Hari, Bulan) |>
  head(4)
```

Output:

```text
          T    Hari Bulan
1 2026-07-01 Wednesday  July
2 2026-07-01 Wednesday  July
3 2026-07-01 Wednesday  July
4 2026-07-01 Wednesday  July
```

## 4. Contoh 3 — Agregasi per bulan & per hari kerja

```r
produksi |>
  mutate(Bulan = floor_date(as.Date(Tanggal), "month")) |>
  count(Bulan)

produksi |>
  mutate(Hari = wday(as.Date(Tanggal), label = TRUE, abbr = FALSE)) |>
  count(Hari) |>
  arrange(desc(n))
```

Output:

```text
# A tibble: 3 × 2
  Bulan          n
  <date>     <int>
1 2026-07-01   162
2 2026-08-01   158
3 2026-09-01   138

# A tibble: 6 × 2
  Hari          n
  <chr>     <int>
1 Wednesday    78
2 Thursday     78
3 Friday       78
4 Saturday     78
5 Monday       74
6 Tuesday      72
```

Penjelasan: `count(Bulan)` = aplikasi `group_by + summarise(n = n())` setelah `floor_date`. Minggu tidak produksi (46–48 baris/hari, 6 hari kerja). Tren "berapa transaksi per bulan" menurun (162 → 158 → 138) karena id-nya mengikuti kalender.

## 5. Contoh 4 — Rentang data & agregasi mingguan

```r
produksi |>
  mutate(T = as.Date(Tanggal)) |>
  summarise(Mulai = min(T), Selesai = max(T),
            RentangHari = as.numeric(max(T) - min(T), units = "days"))

produksi |>
  mutate(Minggu = floor_date(as.Date(Tanggal), "week")) |>
  count(Minggu) |>
  slice_head(n = 3)
```

Output:

```text
      Mulai    Selesai RentangHari
1 2026-07-01 2026-09-26          87
# A tibble: 3 × 2
  Minggu         n
  <date>     <int>
1 2026-06-28    24
2 2026-07-05    36
3 2026-07-12    36
```

Penjelasan: data mencakup 87 hari kalender (1 Juli – 26 September 2026). Minggu pertama hanya 24 baris (mulai Selasa), sisanya 36 baris/minggu (6 hari × 6 slot lini × shift).

---

## 6. Coba sendiri (±7 menit)

1. `wday(as.Date("2026-09-26"), label = TRUE, abbr = FALSE)` — hari apa? (Acuan: `Saturday`.)
2. Dari `produksi`, tambahkan kolom `Kuartal = quarter(as.Date(Tanggal), with_year = TRUE)` lalu `count(Kuartal)`. Berapa kuartal? (Acuan: `2026.3` satu nilai.)
3. `as.numeric(difftime(as.Date("2026-09-26"), as.Date("2026-07-01"), units = "weeks"))` — berapa minggu? (Acuan: `12.43`.)
4. Jelaskan satu kalimat: beda `floor_date(t, "month")` vs `month(t)` (petunjuk: hasilnya kelas Date vs angka/bulan).

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 14](latihan-14-stringr-teks.md)