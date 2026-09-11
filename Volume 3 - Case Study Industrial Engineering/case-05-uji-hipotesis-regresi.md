# Case 05 — Uji Hipotesis & Regresi: Apa yang Nyata, Apa yang Kebetulan?

> **Pertanyaan bisnis:** "Lini B tampak paling buruk — apakah perbedaan antar lini itu **nyata secara statistik**, atau sekadar kebetulan sampling? Dan apakah cycle time mendorong jumlah defect?"
>
> **Alat IE:** Uji hipotesis inferensial — uji t dua sampel, uji proporsi, ANOVA + post-hoc Tukey, dan regresi linear. Semua sudah dipelajari di Volume 1; di sini dipakai untuk menjawab pertanyaan produksi.

## 1. Deskriptif Awal

```r
library(dplyr)
library(ggplot2)
library(scales)

inspeksi <- read.csv("quality_inspection.csv")

inspeksi |>
  group_by(Line) |>
  summarise(
    Rate    = sum(Defect) / sum(Inspected),
    MeanCT  = mean(CycleTimeSec),
    N       = n(),
    .groups = "drop"
  )
```

| Line | Defect rate | Mean cycle time | n |
| --- | --- | --- | --- |
| A | 2,97% | 42,25 s | 16 |
| B | **7,32%** | **49,75 s** | 16 |
| C | 2,01% | 40,00 s | 16 |

Lini B tampak terburuk di kedua metrik — tetapi apakah selisihnya **signifikan**?

## 2. Uji t Dua Sampel: Cycle Time Lini A vs B

```r
ct_a <- inspeksi$CycleTimeSec[inspeksi$Line == "A"]
ct_b <- inspeksi$CycleTimeSec[inspeksi$Line == "B"]

t_test <- t.test(ct_a, ct_b, var.equal = TRUE)
t_test
```

**Hasil:** t = -16,43; df = 30; **p-value < 2,2e-16**; selisih mean A - B = -7,50 detik; CI 95% [-8,43; -6,57].

**Interpretasi:**
- p-value < 0,001 → tolak H₀. Selisih 7,5 detik **sangat kecil kemungkinan kebetulan**.
- CI tidak memuat nol — dengan keyakinan 95%, cycle time lini B lebih lambat **antara 6,6 dan 8,4 detik** per unit.
- Efek praktis: 7,5 detik ≈ 17% lebih lambat — signifikan **secara praktis**, bukan hanya statistik.

## 3. ANOVA + Tukey: Bandingkan Ketiga Lini Sekaligus

```r
anova_fit <- aov(CycleTimeSec ~ Line, data = inspeksi)
summary(anova_fit)
TukeyHSD(anova_fit)
```

**Hasil:** F = 323,5; p < 2,2e-16. Post-hoc Tukey HSD:

| Perbandingan | Selisih | p adj |
| --- | --- | --- |
| B − A | **+7,50 s** | < 0,001 |
| C − A | −2,25 s | < 0,001 |
| C − B | −9,75 s | < 0,001 |

- Semua pasangan berbeda signifikan. Urutan kecepatan: **C (40 s) < A (42,25 s) < B (49,75 s)**.
- Mengapa tidak langsung 3× uji t? Karena banyak uji berulang memicu *family-wise error* — ANOVA + Tukey menjaga tingkat kesalahan keseluruhan tetap 5%.

## 4. Uji Proporsi: Defect Rate Lini A vs B

```r
hasil <- read.csv("qc_hasil_produksi.csv")

agg <- hasil |>
  filter(Product != "Casing") |>          # buang produk tak dikenal master
  group_by(Lini) |>
  summarise(d = sum(UnitsDefect), n = sum(UnitsProduced), .groups = "drop")

prop.test(x = agg$d[c(1, 2)], n = agg$n[c(1, 2)])
```

**Hasil** (A vs B, n ≈ 173 ribu unit/lini): rate A 3,52% vs B 5,30%; χ² = 649,2; **p < 2,2e-16**; CI selisih [-1,92%; -1,64%].

- Dengan sampel ratusan ribu unit, perbedaan 1,78 poin persen **pasti bukan kebetulan**. Masalah lini B adalah *systemic*, bukan noise.

## 5. Regresi Linear: Apakah Cycle Time Mendorong Defect?

```r
reg <- lm(Defect ~ CycleTimeSec, data = inspeksi)
summary(reg)

ggplot(inspeksi, aes(x = CycleTimeSec, y = Defect)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm") +
  labs(title = "Cycle Time vs Jumlah Defect",
       subtitle = paste0("R² = ", round(summary(reg)$r.squared, 3)),
       x = "Cycle time (detik)", y = "Jumlah defect") +
  theme_minimal()
```

**Hasil:** Defect = −25,08 + 0,688 × CycleTimeSec; R² = 0,873; slope p < 2,2e-16.

- Setiap **+1 detik** cycle time berkaitan dengan **+0,69 unit defect** per kelompok inspeksi.
- R² 87,3% → cycle time menjelaskan hampir seluruh variasi defect pada data ini.
- **Interpretasi hati-hati (korelasi ≠ kausalitas)**: kemungkinan besar keduanya bergerak bersama karena penyebab bersama — mesin yang bermasalah (lini B) memaksa cycle time lebih lama *dan* menghasilkan lebih banyak defect. Slope bukan "membuat lebih lambat = lebih baik", melainkan sinyal: **unit-unit yang prosesnya lambat adalah unit bermasalah** — gunakan cycle time sebagai *leading indicator* di shop floor.

## 6. Rekomendasi

1. **Fokuskan kaizen di lini B** — bukti statistik dari tiga sudut (t-test, ANOVA+Tukey, uji proporsi) menunjukkan B berbeda nyata, bukan variasi normal.
2. Jadikan cycle time **trigger inspeksi**: unit dengan cycle time > 47 detik beri pengecekan khusus (slope regresi 0,69 defect/detik).
3. Lapor p-value **bersama ukuran efek** (selisih mean, CI, R²) — p-value saja tidak menyatakan besarannya.
4. Catat keterbatasan: n = 16 per lini pada data inspeksi, data observasional (bukan eksperimen terkontrol).

## 7. Latihan Mandiri

1. Uji t cycle time **shift Pagi vs Sore** di data `qc_hasil_produksi.csv` (mean per tanggal×lini agar independen). Apa kesimpulannya?
2. Regresi `UnitsDefect ~ DowntimeMin` per baris — apakah downtime memprediksi defect? Perhatikan `na.rm` dan interpretasi R²-nya.
3. Buat korelasi Pearson `cor.test(CycleTimeSec, Defect)` dan bandingkan kesimpulannya dengan regresi.

## Jawaban ringkas latihan

```r
# 1
hasil$Tanggal <- as.Date(hasil$Tanggal)

ct_shift <- hasil |>
  group_by(Lini, Tanggal, Shift) |>
  summarise(mean_prod = mean(UnitsProduced), .groups = "drop")

t.test(mean_prod ~ Shift, data = ct_shift, var.equal = TRUE)
# Ekspektasi: shift Sore sedikit lebih lambat; periksa p-value & CI sebelum
# menyimpulkan — bila p > 0,05, perbedaan belum bisa dipisah dari kebisingan.

# 2
reg2 <- lm(UnitsDefect ~ DowntimeMin, data = hasil, na.action = na.omit)
summary(reg2)   # lihat Adjusted R² — kemungkinan lemah: downtime 1 baris
                # tidak selalu menyentuh unit yang sama dengan defectnya.

# 3
cor.test(inspeksi$CycleTimeSec, inspeksi$Defect)
# r ≈ 0,93 (= akar 0,873) — konsisten: korelasi & regresi menceritakan
# hubungan yang sama; regresi tambah memberi besar efek per detik.
```

---

[← Daftar case](README.md) | 🎉 Selesai — gunakan hasil case 1–5 sebagai bahan dashboard Volume 2.
