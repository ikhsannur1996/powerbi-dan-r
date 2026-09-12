# 📐 CHEATSHEET Volume 2 — Statistics & Inferential Statistics

> Satu halaman referensi cepat untuk **memilih dan menjalankan uji statistik** di R. Pasangkan dengan `README.md`. Salin-tempel contoh ini langsung di RStudio dan gantikan nama kolom/data.

---

## 1. Setup & Data

```r
library(dplyr); library(tidyr); library(ggplot2)
library(scales); library(broom)

# Data utama: 360 baris inspeksi (Tanggal, Shift, Line, Operator, Product,
#              Inspected, Defect, DefectRate, CycleTimeSec)
inspeksi  <- read.csv("data/statistik_sample.csv") |>
  mutate(Line  = factor(Line, levels = c("A", "B", "C")),
         Shift = factor(Shift, levels = c("Pagi", "Siang", "Malam")))

# Data berpasangan: 30 operator, sebelum vs sesudah pelatihan
pelatihan <- read.csv("data/pelatihan_sample.csv")
```

## 2. Kerangka 5 Langkah (selalu urut ini)

```text
1. Rumuskan pertanyaan bisnis + H0/H1
2. Pilih uji          (lihat pohon keputusan §14)
3. Cek asumsi         (normalitas, varians, independensi)
4. Jalankan uji       (statistik, p-value, CI)
5. Simpulkan + ukuran efek + kaitkan ke keputusan
```

## 3. Statistik Deskriptif

```r
inspeksi |> summarise(N = n(),
                      mean = mean(CycleTimeSec), median = median(CycleTimeSec),
                      sd = sd(CycleTimeSec), min = min(CycleTimeSec), max = max(CycleTimeSec))

quantile(inspeksi$CycleTimeSec, probs = c(.25, .50, .75))   # kuartil
tapply(inspeksi$CycleTimeSec, inspeksi$Line, mean)          # per kelompok (base)
inspeksi |> group_by(Line) |>                               # per kelompok (dplyr)
  summarise(n = n(), mean = mean(CycleTimeSec), sd = sd(CycleTimeSec), .groups = "drop")
```

## 4. Distribusi & Probabilitas

```r
dnorm(x, mean, sd)      # kepadatan
pnorm(x, mean, sd)      # peluang kumulatif (P(X <= x))
qnorm(p, mean, sd)      # kuantil (invers)
rnorm(n, mean, sd)      # bangkitkan acak

dt(x, df)   pt(q, df)   qt(p, df)   rt(n, df)      # distribusi t
qnorm(.975)                  # 1,96 -> nilai kritis CI 95%
qt(.975, df = 29)            # 2,045 -> t kritis df = 29
```

## 5. Estimasi & Interval Kepercayaan

```r
# CI mean manual: xbar +/- t(kritis, df) * SE
n <- nrow(inspeksi); m <- mean(inspeksi$CycleTimeSec); se <- sd(inspeksi$CycleTimeSec)/sqrt(n)
m + c(-1, 1) * qt(.975, df = n - 1) * se       # CI 95%

t.test(inspeksi$CycleTimeSec)$conf.int          # cara instan

# CI proporsi (Wald): p +/- 1.96 * sqrt(p(1-p)/n)
# CI per kelompok:
inspeksi |> group_by(Line) |>
  summarise(rata = mean(CycleTimeSec), s = sd(CycleTimeSec), n = n(), .groups = "drop") |>
  mutate(se = s/sqrt(n), lwr = rata - qt(.975, n-1)*se, upr = rata + qt(.975, n-1)*se)
```
## 6. Uji t — Tiga Jenis

```r
# 6a. Satu sampel: apakah mean = nilai tertentu?
t.test(inspeksi$CycleTimeSec, mu = 45)

# 6b. Dua sampel independen (cek varians dulu)
ct_a <- inspeksi$CycleTimeSec[inspeksi$Line == "A"]
ct_b <- inspeksi$CycleTimeSec[inspeksi$Line == "B"]
var.test(ct_a, ct_b)                             # p>0,05 -> varians sebanding
t.test(ct_a, ct_b, var.equal = TRUE)             # atau var.equal = FALSE (Welch)
t.test(CycleTimeSec ~ Line, data = subset(inspeksi, Line %in% c("A","B")))  # formula

# 6c. Berpasangan (sebelum-sesudah) — WAJIB pakai paired
t.test(pelatihan$CycleTimeSebelum, pelatihan$CycleTimeSesudah, paired = TRUE)

# Arah uji: alternative = "two.sided" (default) / "less" / "greater"
```

## 7. Proporsi & Chi-Square

```r
# 7a. Dua proporsi
prop.test(x = c(524, 1541), n = c(15478, 15561))

# 7b. Satu proporsi vs target
prop.test(sum(inspeksi$Defect), sum(inspeksi$Inspected), p = 0.05)

# 7c. Chi-square independensi (2 kategori)
tab <- table(inspeksi$Shift, ifelse(inspeksi$DefectRate > 0.05, "Tinggi", "Rendah"))
prop.table(tab, 1)                # proporsi per baris
chisq.test(tab)
sqrt(as.numeric(chisq.test(tab)$statistic) / (sum(tab) * (min(dim(tab)) - 1)))  # Cramer's V

# 7d. Goodness-of-fit (apakah proporsi seragam?)
chisq.test(c(524, 1541, 645), p = c(1/3, 1/3, 1/3))

# Aturan: sel expected < 5 -> pakai fisher.test()
```

## 8. ANOVA Satu Arah + Post-hoc Tukey

```r
anova_fit <- aov(CycleTimeSec ~ Line, data = inspeksi)
summary(anova_fit)                                 # apakah minimal satu berbeda?
TukeyHSD(anova_fit)                                # pasangan mana yang berbeda?
tidy(TukeyHSD(anova_fit))                          # versi tibble (broom)

# Ukuran efek: eta squared
summary(anova_fit)[[1]][["Sum Sq"]][1] / sum(summary(anova_fit)[[1]][["Sum Sq"]])

# ANOVA dua arah (dengan interaksi)
summary(aov(CycleTimeSec ~ Line * Shift, data = inspeksi))

# Cek asumsi
shapiro.test(resid(anova_fit))                     # normalitas residual
plot(anova_fit)                                    # 4 plot diagnostik
```

## 9. Korelasi

```r
cor.test(x, y, method = "pearson")                 # linear
cor.test(x, y, method = "spearman")                # monotonik (peringkat)
cor.test(x, y, method = "kendall")                 # ukuran sampel kecil

cor(inspeksi[, c("Inspected","Defect","DefectRate","CycleTimeSec")])  # matriks

# r = 0 tak berarti tak ada hubungan — hanya tak ada hubungan LINEAR.
# Korelasi != kausalitas.
# Warning "cannot compute exact p-value with ties" = wajar bila banyak nilai
# sama (mis. defect bulat); p-value tetap dipakai (aproksimasi), tidak error.
```

## 10. Regresi Linear

```r
reg1 <- lm(DefectRate ~ CycleTimeSec, data = inspeksi)          # sederhana
summary(reg1)
tidy(reg1, conf.int = TRUE)                                     # koefisien + CI
glance(reg1)                                                    # R2, AIC, p, dll
predict(reg1, newdata = data.frame(CycleTimeSec = c(40, 45, 50)),
        interval = "confidence")                                # prediksi + CI

reg2 <- lm(DefectRate ~ CycleTimeSec + Line + Shift, data = inspeksi)  # berganda
summary(reg2)

# Diagnostik
par(mfrow = c(2, 2)); plot(reg1); par(mfrow = c(1, 1))
# Normalitas residual, homoskedastisitas, linearitas, outlier berpengaruh
```

## 11. Non-Parametrik (bila normalitas gagal)

```r
shapiro.test(x)                                            # H0: data normal
ks.test(x, "pnorm", mean(x), sd(x))                        # alternatif

wilcox.test(ct_a, ct_b)                                    # Mann-Whitney (2 sampel)
kruskal.test(CycleTimeSec ~ Line, data = inspeksi)         # Kruskal-Wallis (3+)
wilcox.test(sebelum, sesudah, paired = TRUE)               # Wilcoxon berpasangan
cor.test(x, y, method = "spearman")                        # Spearman
```

## 12. Ukuran Efek & Power

```r
# Cohen's d (2 sampel, pooled SD)
sp <- sqrt(((n1-1)*var(x) + (n2-1)*var(y)) / (n1+n2-2))
d  <- (mean(y) - mean(x)) / sp
# 0,2 kecil | 0,5 sedang | 0,8 besar

# Eta squared (ANOVA): lihat §8.   Cramer's V (chi-square): lihat §7.

# Power & ukuran sampel
power.t.test(delta = 4.5, sd = 2.0, sig.level = 0.05, power = 0.80)   # berapa n?
power.t.test(n = 30, delta = 4.5, sd = 2.0, sig.level = 0.05)          # power?
# Catatan: power.t.test() memakai delta (selisih absolut) + sd, cukup untuk
# kasus 2 sampel & berpasangan. TIDAK perlu package tambahan.
```

Aturan praktis: **power ≥ 0,80**. Sampel kecil → hanya bisa mendeteksi efek besar; jangan simpulkan "tak ada efek" dari studi yang *underpowered*.

## 13. Tabel Hasil Volume 2 (angka nyata dari data)

| Uji | Statistik | p-value | Keputusan |
| --- | --- | --- | --- |
| CI 95% mean cycle time | 46,98 detik | [46,44; 47,52] | — |
| t 1-sampel (μ = 45) | t = 7,17 | 4,41e-12 | beda dari 45 s |
| t 2-sampel A vs B | t = −14,02 | < 2,2e-16 | B lebih lambat 6,69 s |
| t berpasangan (pelatihan) | t = 13,56 | 4,43e-14 | turun 4,70 s |
| Proporsi A vs B | χ² = 529,7 | < 2,2e-16 | rate B jauh lebih tinggi |
| Chi-square Shift × defect | χ² = 26,93 | 1,42e-06 | tidak independen (V = 0,27) |
| ANOVA per lini | F = 181,3 | < 2,2e-16 | minimal satu beda (η² = 0,50) |
| Korelasi cycle time~defect | r = 0,57 | < 2,2e-16 | positif sedang |
| Regresi sederhana | R² = 0,33 | < 2,2e-16 | slop +0,0049 |
| Regresi berganda | Adj R² = 0,52 | — | Line & Shift nyata |

## 14. Pohon Keputusan — Pilih Uji yang Tepat

```text
Pertanyaan tentang RATA-RATA (variabel numerik)?
  ├─ 1 kelompok vs target      -> t 1-sampel
  ├─ 2 kelompok independen     -> t 2-sampel (var.test dulu)
  └─ 3+ kelompok               -> ANOVA + Tukey
       (normalitas gagal?)     -> Kruskal-Wallis + Dunn

Pertanyaan tentang PROPORSI (defect, ya/tidak)?
  ├─ 1 proporsi vs target      -> prop.test(..., p = ...)
  ├─ 2 proporsi                -> prop.test(x =, n =)
  └─ hubungan 2 kategori       -> chisq.test + Cramer's V

Pertanyaan SEBELUM vs SESUDAH (objek sama)?
  -> t berpasangan  (alternatif: Wilcoxon signed-rank)

Pertanyaan HUBUNGAN dua variabel numerik?
  ├─ asosiasi saja             -> cor.test (Pearson/Spearman)
  └─ prediksi + besar efek     -> lm() + diagnostik → R2, koefisien

Ukuran SAMPEL / power
  -> power.t.test(...)
```

## 15. Anatomi Hasil Uji — Apa yang Dibaca

```text
t.test / prop.test  -> statistic, parameter(df), p.value, conf.int, estimate
chisq.test          -> statistic(X2), parameter(df), p.value, expected
aov + TukeyHSD      -> F value, Pr(>F), diff/CI/p adj per pasangan
cor.test            -> estimate(r), p.value, conf.int
lm + summary        -> Estimate, Std.Error, t, Pr(>|t|), R2, Adj R2
```

Selalu laporkan **tiga hal**: (1) statistik & p-value, (2) **ukuran efek**, (3) **interval kepercayaan**. p-value saja tidak menyatakan besaran.

## 16. Problem → Fix Cepat

| Problem | Fix |
| --- | --- |
| `object not found` | cek `str(df)` / ejaan kolom (R case-sensitive) |
| Hasil `NA` | `na.rm = TRUE` atau `na.omit()` |
| Data terbaca character | `as.numeric()` / `as.Date()` dulu |
| p-value mengejutkan (n besar) | laporkan juga **ukuran efek** — signifikan ≠ penting |
| Hasil "tak signifikan" | cek **power**; mungkin sampel terlalu kecil |
| `chisq.test` warning "expected < 5" | pakai `fisher.test()` |
| Uji t salah untuk data berpasangan | wajib `paired = TRUE` |
| Banyak uji t berpasangan | ganti **ANOVA + Tukey** (hindari family-wise error) |
| Korelasi tinggi → klaim sebab-akibat | salah; korelasi ≠ kausalitas |

---

*CHEATSHEET Volume 2 — alur ingat: **pertanyaan → jenis data → uji → asumsi → p + efek + CI**. Dari deskriptif, distribusi sampling, uji hipotesis, ANOVA, korelasi–regresi, hingga ukuran efek & power.*

