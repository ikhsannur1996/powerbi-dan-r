# Materi 06 — Kolom Baru & Pengurutan (dplyr)

> Pendamping Volume 0 · Waktu baca ±12 menit · Dataset `quality_inspection.csv`.
> Awali: `library(dplyr); library(lubridate)` + baca CSV (lihat contoh 1).
> `case_when()` sudah dikenalkan di Materi 03; di sini dipakai di dalam `mutate()`.

---

## 1. Materi singkat

| Fungsi | Untuk apa | Contoh |
| --- | --- | --- |
| `mutate()` | buat/ubah **kolom** | `mutate(DefectRate = Defect / Inspected)` |
| `ifelse()` / `case_when()` | kolom label berdasar syarat | 2 kategori → `ifelse()`; 3+ → `case_when()` |
| `arrange()` | urutkan **baris** | `arrange(desc(DefectRate))` = terbesar dulu |
| `floor_date(tgl, "month")` | tanggal → awal bulan | `2026-07-15` → `2026-07-01` (lubridate) |

`mutate()` bisa memakai kolom yang baru dibuat di baris yang sama (dihitung berurutan dari atas).
`arrange()` tidak mengubah data asli kecuali disimpan (`<-`).

---

## 2. Contoh 1 — Persiapan + kolom defect rate

```r
library(dplyr)
library(lubridate)
quality <- read.csv("quality_inspection.csv") |>
  mutate(InspectionDate = as.Date(InspectionDate))

quality <- quality |>
  mutate(
    DefectRate     = round(Defect / Inspected, 4),
    FirstPassYield = 1 - DefectRate
  )

quality |> select(Line, Defect, Inspected, DefectRate, FirstPassYield) |> head(3)
```

Output:

```text
  Line Defect Inspected DefectRate FirstPassYield
1    A      5       120     0.0417         0.9583
2    A      3       115     0.0261         0.9739
3    B      9       130     0.0692         0.9308
```

Penjelasan: `DefectRate` = defect dibagi inspected (4 desimal). `FirstPassYield` = 1 − defect rate (lolos inspeksi pertama). Baris 1: 5/120 = 0.0417 → yield 0.9583.

## 3. Contoh 2 — Kolom label: `ifelse()` dan `case_when()`

```r
quality <- quality |>
  mutate(
    QualityFlag = ifelse(DefectRate > 0.05, "Above", "On target"),
    Severity = case_when(
      Defect >= 8 ~ "Tinggi",
      Defect >= 4 ~ "Sedang",
      TRUE        ~ "Rendah"
    ),
    EfisiensiCT = ifelse(CycleTimeSec > 45, "Lambat", "Normal")
  )

table(quality$QualityFlag)
table(quality$Severity)
table(quality$EfisiensiCT)
```

Output:

```text

     Above On target
        16        32

 Rendah Sedang Tinggi
     21     13     14

Lambat Normal
    16     32
```

Penjelasan: ambang 5% → 16 baris "Above". `case_when()` dibaca dari atas: defect 12 → Tinggi; 5 → Sedang; 2 → Rendah. `TRUE ~` = "sisanya". Cycle time > 45 detik → 16 baris "Lambat" (semuanya lini B — cek sendiri dengan `table(quality$Line[quality$EfisiensiCT == "Lambat"])`).

## 4. Contoh 3 — Kolom bulan + pengurutan

```r
quality <- quality |>
  mutate(Bulan = floor_date(InspectionDate, "month"))
table(quality$Bulan)   # Juli vs Agustus seimbang

quality |>
  arrange(desc(DefectRate)) |>
  select(Line, Product, DefectType, Inspected, Defect, DefectRate) |>
  head(5)
```

Output:

```text
2026-07-01 2026-08-01
        24         24

  Line Product DefectType Inspected Defect DefectRate
1    B Bracket      Crack       126     12     0.0952
2    B Bracket      Crack       123     11     0.0894
3    B Bracket    Scratch       128     11     0.0859
4    B Bracket    Scratch       129     11     0.0853
5    B Bracket      Crack       121     10     0.0826
```

Penjelasan: 24 baris Juli + 24 Agustus. Lima defect rate tertinggi semuanya lini B (0.0826–0.0952) — sinyal awal lini B bermasalah, didalami di Materi 07.

## 5. Contoh 4 — Satu pipeline utuh (select → mutate → arrange)

```r
ranking <- quality |>
  select(Line, Defect, Inspected) |>
  mutate(DefectRate = Defect / Inspected) |>
  arrange(desc(DefectRate))

head(ranking, 3)
```

Output:

```text
  Line Defect Inspected DefectRate
1    B     12       126 0.09523810
2    B     11       123 0.08943089
3    B     11       128 0.08593750
```

---

## 6. Contoh 5 — `across()`: terapkan fungsi ke banyak kolom

```r
# Ubah beberapa kolom sekaligus jadi proporsi dari inspected
quality |>
  mutate(across(c(Defect, Inspected), ~ .x / 100)) |>   # skala 0-100 ke 0-1
  select(Defect, Inspected) |> head(2)

# Kolom label: klasifikasi semua kolom numerik yang > 5
quality |>
  summarise(across(where(is.numeric), ~ sum(.x > 5)))
```

Output:

```text
  Defect Inspected
1   0.05      1.2
2   0.03      1.15

  Inspected Defect CycleTimeSec
1        48     16           48
```

Penjelasan: `across(kolom, fungsi)` = ulangi fungsi ke tiap kolom terpilih. `~ .x` = formula singkat fungsi (`.x` = nilai kolom). `where(is.numeric)` memilih semua kolom angka. Baca hasil: semua 48 baris `Inspected` dan `CycleTimeSec` > 5; hanya 16 baris `Defect` > 5. Pola ini diperluas di Materi 16 contoh 6 untuk ringkasan statistik multi-kolom.

---

## 7. Coba sendiri (±5 menit)

1. Buat `QualityFlag2` berambang 3% (`DefectRate > 0.03`). Berapa baris "Above"? (Acuan: pasti > 16 — petunjuk: `table()`.)
2. Buat `Severity2`: "Tinggi" jika `Defect >= 10`, "Sedang" jika `>= 5`, sisanya "Rendah". Bandingkan `table()`-nya dengan contoh 2.
3. Urutkan `quality` dari cycle time terbesar (`arrange(desc(CycleTimeSec))`), tampilkan 3 teratas. Lini apa semuanya?
4. Rangkai: `filter(Line == "B")` → `select(DefectType, Defect, Inspected)` → `mutate(DefectRate = ...)` → `arrange(desc(DefectRate))`. Apa baris teratasnya?
5. Gunakan `across(c(Inspected, Defect), ~round(.x / 10, 1))` pada `quality` — kolom apa yang berubah dan berapa desimalnya?

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 07](latihan-07-dplyr-group-summarise.md)

