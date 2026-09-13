# Case 02 — SPC: P-Chart & Xbar Chart

> **Pertanyaan bisnis:** "Apakah proses kita **stabil** secara statistik, atau ada hari-hari abnormal yang perlu diselidiki?"
>
> **Alat IE:** Statistical Process Control (SPC). P-chart memantau **proportion defect** per periode; Xbar chart memantau **rata-rata** variabel proses (di sini: cycle time). Batas kontrol ±3σ diturunkan **dari data proses sendiri** — beda dengan spesifikasi (USL/LSL) yang datang dari pelanggan.

## 1. P-Chart — Proporsi Defect per Tanggal

```r
library(dplyr)
library(ggplot2)
library(scales)

inspeksi <- read.csv("quality_inspection.csv")
inspeksi$InspectionDate <- as.Date(inspeksi$InspectionDate)

p_ctl <- inspeksi |>
  group_by(InspectionDate) |>
  summarise(n = sum(Inspected), d = sum(Defect), .groups = "drop") |>
  mutate(p = d / n)

phat <- sum(p_ctl$d) / sum(p_ctl$n)     # p-bar: proporsi keseluruhan

p_ctl <- p_ctl |>
  mutate(
    ucl = pmin(phat + 3 * sqrt(phat * (1 - phat) / n), 1),
    lcl = pmax(phat - 3 * sqrt(phat * (1 - phat) / n), 0)
  )

p_pchart <- ggplot(p_ctl, aes(x = InspectionDate, y = p)) +
  geom_line() +
  geom_point(size = 3, color = "steelblue") +
  geom_hline(yintercept = phat, color = "grey40") +
  geom_line(aes(y = ucl), color = "red", linetype = "dashed") +
  geom_line(aes(y = lcl), color = "red", linetype = "dashed") +
  annotate("text", x = min(p_ctl$InspectionDate), y = phat + 0.003,
           label = paste0("p-bar = ", percent(phat, 0.1)), hjust = 0, size = 3.2) +
  scale_y_continuous(labels = percent) +
  labs(title = "P-Chart: Proporsi Defect Harian",
       subtitle = "Batas kontrol diturunkan dari data (±3σ)",
       x = NULL, y = "Proporsi defect") +
  theme_minimal()

p_pchart
```

## 2. Xbar Chart — Rata-rata Cycle Time per Tanggal

```r
xbar <- inspeksi |>
  group_by(InspectionDate) |>
  summarise(mean_ct = mean(CycleTimeSec), n = n(), .groups = "drop")

mu <- mean(inspeksi$CycleTimeSec)   # 44 detik
s  <- sd(inspeksi$CycleTimeSec)     # 4,36 detik

xbar <- xbar |>
  mutate(
    ucl = mu + 3 * s / sqrt(n),
    lcl = mu - 3 * s / sqrt(n)
  )

ggplot(xbar, aes(x = InspectionDate, y = mean_ct)) +
  geom_line() +
  geom_point(size = 3, color = "seagreen") +
  geom_hline(yintercept = mu, color = "grey40") +
  geom_line(aes(y = ucl), color = "red", linetype = "dashed") +
  geom_line(aes(y = lcl), color = "red", linetype = "dashed") +
  labs(title = "Xbar Chart: Rata-rata Cycle Time Harian",
       x = NULL, y = "Rata-rata cycle time (detik)") +
  theme_minimal()
```

## 3. Hasil & Interpretasi

**P-chart** (p̄ = 4,05%; UCL ≈ 6,2%; LCL ≈ 1,9%):

| Tanggal | n | Defect | p | Status |
| --- | --- | --- | --- | --- |
| 01 Jul | 765 | 27 | 3,53% | ✔ |
| 08 Jul | 774 | 26 | 3,36% | ✔ |
| 15 Jul | 771 | 33 | 4,28% | ✔ |
| 22 Jul | 770 | 32 | 4,16% | ✔ |
| 01 Agu | 780 | 34 | 4,36% | ✔ |
| 08 Agu | 777 | 31 | 3,99% | ✔ |
| 15 Agu | 768 | 36 | 4,69% | ✔ |
| 22 Agu | 771 | 31 | 4,02% | ✔ |

- **0 dari 8 titik di luar batas** → proses *in statistical control*: variasi harian masih seputar variasi alamiah, tidak ada *special cause* yang mendadak.
- **Tapi hati-hati**: stabil ≠ bagus. Pusat proses (4,05%) berada **di atas target 4%** dan sangat dekat spesifikasi 5%. Proses yang stabil pada level yang salah tetap harus diperbaiki — inilah jembatan ke Case 03 (capability).
- **Xbar chart**: 0 pelanggaran, namun rata-rata cycle time **naik perlahan** dari 42,5 → 44,8 detik (drift +2,3 detik). Inilah pola *trend* yang oleh aturan Nelson (rule 3: 6 titik naik berturut) patut dicurigai sebagai *special cause* lambat: keausan tooling, pergeseran parameter, atau kenaikan suhu mesin. Rekomendasi: investigasi root cause drift, bukan menunggu titik melewati UCL.

## 4. Rekomendasi

1. Pertahankan pemantauan mingguan; buat p-chart ini sebagai rutinitas (bisa jadi visual Power BI di Volume 2).
2. Investigasi **drift cycle time** (periksa log maintenance vs tanggal).
3. Karena level p̄ terlalu tinggi, lanjut ke **Case 03** untuk menghitung capability terhadap spesifikasi.

## 5. Latihan Mandiri

1. Buat p-chart **per lini** (3 chart, atau facet) — apakah ada lini yang out of control? (Petunjuk: gunakan data `qc_hasil_produksi.csv`, group per `Lini` + `Tanggal`.)
2. Implementasikan aturan Nelson sederhana: tandai titik ke-i bila 6 titik berturut-turut naik. Ada berapa trigger di xbar chart?
3. Bandingkan hasil dengan package `qcc`: `qcc(p_ctl$d, sizes = p_ctl$n, type = "p")` — batas kontrolnya sama?

## Jawaban ringkas latihan

```r
# 1 — p-chart per lini
hasil <- read.csv("qc_hasil_produksi.csv")
hasil$Tanggal <- as.Date(hasil$Tanggal)

hasil |>
  group_by(Lini, Tanggal) |>
  summarise(n = sum(UnitsProduced), d = sum(UnitsDefect), .groups = "drop") |>
  group_by(Lini) |>
  mutate(phat = sum(d) / sum(n),
         p    = d / n,
         ucl  = phat + 3 * sqrt(phat * (1 - phat) / n),
         lcl  = pmax(phat - 3 * sqrt(phat * (1 - phat) / n), 0)) |>
  ungroup() |>
  filter(p > ucl | p < lcl) |>
  nrow()
# Lini B memiliki beberapa titik di atas UCL — wajar karena defect rate B
# memang paling tinggi dan berfluktuasi lebih besar.

# 3 — qcc (setelah install.packages("qcc"))
# library(qcc)
# qcc(p_ctl$d, sizes = p_ctl$n, type = "p")
# Batas identik: qcc memakai formula p-chart yang sama.
```

---

[← Daftar case](README.md) | [Lanjut: Case 03 — Process Capability](case-03-process-capability.md)
