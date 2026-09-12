# Materi 16 — Statistik Deskriptif (Ringkasan Angka)

> Pendamping Volume 0 · Waktu baca ±15 menit · Dataset: `quality_inspection.csv` & `qc_hasil_produksi.csv`.
> Jembatan menuju Volume 1 (uji t, ANOVA, regresi).

---

## 1. Materi singkat — ukuran ringkasan

| Ukuran | Fungsi | Makna |
| --- | --- | --- |
| Rata-rata (mean) | `mean(x)` | "pusat" data — sensitif ke pencilan |
| Median | `median(x)` | "tengah" — tahan terhadap pencilan |
| Kuartil | `quantile(x, c(.25,.5,.75))` | 25% / 50% / 75% data |
| Sebaran | `sd(x)`, `var(x)`, `IQR(x)`, `min/max` | seberapa melebar |
| Frekuensi | `table(x)`, `prop.table(x)` | hitung & proporsi kategori |
| Korelasi | `cor(x, y)` | arah & kekuatan hubungan linear (−1…+1) |

Naikkan kebiasaan `na.rm = TRUE` di setiap `mean()/sd()/sum()` — dataset sering punya `NA`.

---

## 2. Contoh 1 — Ringkasan cepat base R

```r
quality <- read.csv("quality_inspection.csv")

summary(quality$CycleTimeSec)                                  # min, q1, median, mean, q3, max
quantile(quality$CycleTimeSec, c(.25, .5, .75))
sd(quality$CycleTimeSec)                                       # 4.5
```

Output:

```text
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
  39.00   40.75   42.00   44.00   49.00   52.00
 25%   50%   75%
40.75 42.00 49.00
[1] 4.5
```

Penjelasan: cycle time 39–52 detik, median 42. Ada dua "kelompok" (A & C ~40, B ~50) — `summary` tak bisa menunjukkan itu; grafik (Materi 09) dan tabel grup (contoh 2) yang bisa.

## 3. Contoh 2 — Ringkasan per grup (mean, sd, median, IQR)

```r
library(dplyr)

quality |>
  group_by(Line) |>
  summarise(
    Mean = mean(CycleTimeSec),
    SD   = sd(CycleTimeSec),
    Med  = median(CycleTimeSec),
    IQ   = IQR(CycleTimeSec),
    .groups = "drop"
  )
```

Output:

```text
# A tibble: 3 × 5
  Line   Mean    SD   Med    IQ
  <chr> <dbl> <dbl> <dbl> <dbl>
1 A      42.2 0.683    42   1
2 B      49.8 1.69     50   2
3 C      40   0.730    40   0.5
```

Penjelasan: lini B paling lama RATA-RATA (49,8) dan paling bervariasi (SD 1,69) — sedangkan lini C konsisten (SD 0,73). Ini melengkapi temuan "B terburuk" dari Materi 07.

## 4. Contoh 3 — Frekuensi & proporsi kategori

```r
table(quality$DefectType)                       # jumlah per jenis
round(prop.table(table(quality$DefectType)) * 100, 1)   # dalam persen
```

Output:

```text
    Color     Crack Dimension      NONE   Scratch
        6         8        13         9        12
  Color Crack Dimension   NONE Scratch
   12.5   16.7      27.1   18.8    25.0
```

Penjelasan: `table()` = hitung; `prop.table(table(...))` = proporsi (jumlahnya 1, tinggal ×100). Dimension 27,1% = jenis defect paling sering diinspeksi.

## 5. Contoh 4 — Korelasi & matriks korelasi

```r
cor(quality$CycleTimeSec, quality$Defect)                  # 0.935 (kuat)
cor(quality$CycleTimeSec, quality$Defect)^2                # 0.873 (r^2)

produksi <- read.csv("qc_hasil_produksi.csv")

produksi |>
  drop_na() |>
  select(UnitsProduced, UnitsDefect, EnergyKWh, TempC) |>
  cor() |>
  round(2)
```

Output:

```text
[1] 0.935
[1] 0.873
      UnitsProduced UnitsDefect EnergyKWh TempC
UnitsProduced         1.00        0.40     -0.07  0.03
UnitsDefect           0.40        1.00      0.31 -0.02
EnergyKWh            -0.07        0.31      1.00 -0.05
TempC                 0.03       -0.02     -0.05  1.00
```

Penjelasan: cycle time–defect di inspeksi berkorelasi r = 0,935 (sangat kuat), r² = 0,873 → 87% variasi defect "dijelaskan" data cycle time (di garis lm). Di produksi harian, korelasi terkuat `UnitsProduced`–`UnitsDefect` (0,40) dan `UnitsDefect`–`EnergyKWh` (0,31). Korelasi ≠ sebab-akibat — itu dibahas Volume 5 (causal inference).

## 6. Contoh 5 — Ringkas banyak kolom sekaligus (across)

```r
produksi |>
  summarise(
    across(c(UnitsProduced, UnitsDefect, DowntimeMin),
           list(mean = ~ mean(.x, na.rm = TRUE), sd = ~ sd(.x, na.rm = TRUE)))
  )
```

Output:

```text
  UnitsProduced_mean UnitsProduced_sd UnitsDefect_mean UnitsDefect_sd
1            1160.43         264.1318         46.56769        19.7635
  DowntimeMin_mean DowntimeMin_sd
1         34.70179       36.69416
```

Penjelasan: `across(...)` + `list(mean = ~ ..., sd = ~ ...)` menghitung mean & sd untuk tiga kolom sekaligus. Kolom nama dihasilkan `Kolom_fungsi`. Catal: `~` = formula singkat untuk fungsi; gunakan `na.rm = TRUE` di dalamnya.

---

## 7. Coba sendiri (±7 menit)

1. `quantile(produksi$EnergyKWh, c(.25, .5, .75))` — cek apakah sesuai `summary()`: 22.8 / 28.4 / 35.4.
2. Hitung mean & median `DowntimeMin` per Lini (pakai `na.rm = TRUE`). Lini mana paling besar median-nya? (Acuan: C ≈ 24.)
3. `cor(produksi$EnergyKWh, produksi$UnitsDefect, use = "complete.obs")` — nilainya? (Acuan ≈ 0.31; `use = "complete.obs"` dipakai saat ada NA.)
4. Jelaskan satu kalimat: kenapa `median` lebih cocok daripada `mean` untuk `DowntimeMin`? (Petunjuk: ada nilai negatif & 234 menit.)

---

[Kembali ke daftar](README.md) | 🎉 Selesai — lanjut ke Volume 1 (statistik) atau folder `Data Transformation - dplyr`.