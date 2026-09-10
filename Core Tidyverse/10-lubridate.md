# 10 — lubridate: Tanggal & Waktu

> Sejak tidyverse 2.0, lubridate ikut dimuat oleh `library(tidyverse)`. Tanggal & waktu itu rumit (zona waktu, bulan beda panjang, DST) — lubridate menyederhanakannya.

## Tiga Tipe Inti

```r
library(tidyverse)

d <- as_date("2026-07-01")         # Date — tanpa jam (calendar day)
t <- as_datetime("2026-07-01 08:30:00")  # POSIXct — dengan jam (timeline)
p <- ymd_hms("2026-07-01 08:30:00", tz = "Asia/Jakarta")  # dengan zona

class(d); class(t); class(p)
```

Aturan: **Date** untuk tanggal saja (laporan harian), **POSIXct** untuk momen waktu (sensor, log).

## Parser "ydm_hms" Fleksibel

Fungsi parser dinamai sesuai urutan komponen: `y` = year, `m` = month, `d` = day, `h/m/s` = jam/menit/detik.

```r
ymd("2026-07-01")
dmy("01-07-2026")            # format Indonesia/Eropa
mdy("July 1, 2026")
ymd_hm("2026-07-01 08:30")
dmy_hms("01/07/2026 08:30:15")
parse_date_time("01 Jul 2026", orders = "dby")  # fleksibel penuh
```

Nama fungsi = urutan input, bukan urutan output. `as_date()` tetap berguna untuk standar ISO `YYYY-MM-DD`.

## Ekstraksi Komponen

```r
tgl <- ymd("2026-08-15")
day(tgl); month(tgl); year(tgl)
wday(tgl, label = TRUE, week_start = 1)   # "Sabtu"
qday(tgl); quarter(tgl); semester(tgl)

jam <- ymd_hms("2026-08-15 14:35:22")
hour(jam); minute(jam); second(jam)
```

## Membuat & Membulatkan

```r
make_date(2026, 7, 1)
make_datetime(2026, 7, 1, 8, 30)

floor_date(tgl,  "month")     # 2026-07-01
floor_date(tgl,  "week", week_start = 1)   # Senin minggu itu
ceiling_date(tgl, "month")    # 2026-08-01
round_date(ymd("2026-07-20"), "month")
```

`floor_date(..., "month")` adalah cara standar membuat kolom "periode bulan" untuk agregasi.

## Aritmetika Waktu

```r
# Duration — panjang waktu eksak dalam detik
dweeks(1); ddays(3); dhours(2); dminutes(30)
tgl + ddays(30)

# Period — sesuai kalender manusia
tgl + months(1)          # tanggal yang sama bulan depan
tgl + years(1)
tgl %m+% months(1)       # aman bila hasil melewati akhir bulan

# Interval — selisih dua momen
mulai <- ymd("2026-07-01"); selesai <- ymd("2026-09-30")
interval(mulai, selesai) / ddays(1)      # 91 hari
as.period(interval(mulai, selesai))      # "2m 29d 0H 0M 0S"
```

Duration (detik presisi) vs Period (kalender) — beda penting saat DST/leap year. Untuk bisnis umumnya pakai period.

## Selisih Waktu (time difference)

```r
sekarang <- now()
selisih <- ymd_hms("2026-07-01 08:00:00") %--% sekarang
as.duration(selisih)
time_length(selisih, "days")     # paksa satuan
```

## Zona Waktu

```r
waktu_utc <- ymd_hms("2026-07-01 08:00:00", tz = "UTC")
with_tz(waktu_utc, "Asia/Jakarta")     # konversi tampilan (+7)
force_tz(waktu_utc, "Asia/Jakarta")    # GANTI label tanpa ubah momen

tz(waktu_utc)
Sys.timezone()
```

Simpan data di UTC, konversi ke lokal hanya saat ditampilkan — best practice universal.

## Case Study Mini: Analisis Waktu Produksi

```r
hasil <- read_csv("qc_hasil_produksi.csv", col_types = cols(Tanggal = col_date()))

hasil |>
  mutate(
    Bulan    = floor_date(Tanggal, "month"),
    HariKerja = wday(Tanggal, label = TRUE, week_start = 1),
    Kwarter  = quarter(Tanggal, with_year = TRUE)
  ) |>
  group_by(Bulan) |>
  summarize(
    Rate = sum(UnitsDefect) / sum(UnitsProduced),
    NHariKerja = n_distinct(Tanggal),
    .groups = "drop"
  )
```

## Tips

- Selalu **parse dulu** ke Date/POSIXct sebelum dianalisis — string tanggal itu umpan error.
- `week_start = 1` (Senin) untuk konteks Indonesia/Eropa.
- Untuk agregasi periodik, `floor_date()` + `group_by()` adalah pola standar.
- `Sys.Date()` / `now()` untuk "sekarang"; `today()` alias `Sys.Date()`.
- Kolom Date/POSIXct bisa langsung dipakai di `ggplot2` dengan `scale_x_date()`/`scale_x_datetime()`.

## Referensi

- Cheatsheet: "lubridate"
- Bab *Dates and times* di R for Data Science: <https://r4ds.hadley.nz/dates-and-times>
- <https://lubridate.tidyverse.org>
