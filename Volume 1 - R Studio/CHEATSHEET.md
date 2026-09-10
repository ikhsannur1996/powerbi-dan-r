# 📘 CHEATSHEET Volume 1 — Statistik & Visualisasi dengan R Studio

> Referensi cepat untuk menghafal **uji statistik**, **cara membaca output**, serta **ggplot2 lanjutan**. Semua contoh memakai `quality_inspection.csv` yang sudah dibersihkan. Pasangkan dengan `README.md`.

---

## 1. Statistik Deskriptif — kode singkat

```r
library(dplyr)

# Ringkasan cepat seluruh kolom numerik
summary(quality_clean)

# Statistik pilihan per kolom
quality_clean |>
  summarise(
    n = n(),
    mean_ct  = mean(CycleTimeSec, na.rm = TRUE),
    median_ct = median(CycleTimeSec, na.rm = TRUE),
    sd_ct     = sd(CycleTimeSec, na.rm = TRUE),
    q25 = quantile(CycleTimeSec, 0.25, na.rm = TRUE),
    q75 = quantile(CycleTimeSec, 0.75, na.rm = TRUE)
  )

# Per kelompok (lini)
quality_clean |>
  group_by(Line) |>
  summarise(n = n(), avg = mean(CycleTimeSec), .groups = "drop")
```

## 2. Korelasi

```r
cor(x, y, use = "complete.obs", method = "pearson")
cor.test(x, y, method = "pearson")   # berikut p-value & CI

# Matriks korelasi banyak kolom
cor(select(quality_clean, where(is.numeric)), use = "complete.obs")
```

Interpretasi cepat `r`:

| `r` | Makna |
| --- | --- |
| ≈ `+1` | positif kuat |
| ≈ `-1` | negatif kuat |
| ≈ `0` | linear lemah / tidak ada |

> ⚠️ Korelasi ≠ sebab-akibat.

---

## 3. Uji t Dua Sampel

```r
# Data dua lini
line_ab <- quality_clean |> filter(Line %in% c("A", "B"))

# Formula style (variabel ~ grup)
t.test(CycleTimeSec ~ Line, data = line_ab)

# Vector style
t.test(x = line_a$CycleTimeSec, y = line_b$CycleTimeSec)
```

Yang dibaca dari output: `t`, `df`, `p-value`, `mean of x/y`, `95% CI` (bila CI tidak memuat 0 → signifikan).

```r
# Uji satu sisi (jika hipotesis directional)
t.test(..., alternative = "less")    # atau "greater"

# Mematikan asumsi varians sama (default Welch sudah aman)
t.test(..., var.equal = TRUE)        # t standar (student)
```

## 4. ANOVA Satu Arah

```r
anova_model <- aov(CycleTimeSec ~ Line, data = quality_clean)
summary(anova_model)              # F value & Pr(>F)

# Post-hoc bila signifikan
TukeyHSD(anova_model)

# Cek asumsi
plot(anova_model)                 # residual plots (4-in-1)
```

Baca `summary()`: `F value` besar dan `Pr(>F)` `< 0.05` → ada perbedaan antar kelompok.

> 🔁 Analogi ANOVA: membandingkan **varians antar kelompok** terhadap **varians dalam kelompok**. Nama uji karena memakai varians, bukan membandingkan varians.

---

## 5. Regresi Linear Sederhana

```r
model <- lm(DefectRate ~ CycleTimeSec, data = quality_clean)
summary(model)        # koefisien, p-value, R-squared
coef(model)           # hanya koefisien (intercept & slope)
confint(model)        # interval keyakinan koefisien
fitted(model)         # nilai prediksi
resid(model)          # sisa/residual
```

Yang penting dibaca `summary()`:

| Bagian | Maksud |
| --- | --- |
| `Estimate` | intercept (β₀) & slope (β₁) |
| `Pr(>|t|)` koefisien | p-value per prediktor |
| `Multiple R-squared` | proporsi variansi yang dijelaskan model |
| `Residual standard error` | ukuran kesalahan prediksi |

Prediksi:

```r
new <- data.frame(CycleTimeSec = c(40, 45, 50))
predict(model, newdata = new, interval = "confidence")  # rata-rata Y
predict(model, newdata = new, interval = "prediction")  # Y individual
```

> ### Bahasa kesimpulan
> - Signifikan → *"Cycle time **berhubungan dengan** defect rate"*.
> - Jangan ucapkan "menyebabkan" tanpa desain kausal.
> - P-value besar bukan "H0 benar", melainkan "belum cukup bukti".

---

## 6. Memilih Uji (yang penting hafal)

| Pertanyaan | Jumlah grup | Uji |
| --- | --- | --- |
| Banding 2 kelompok | 2 | `t.test()` |
| Banding ≥ 3 kelompok | ≥ 3 | `aov()` + `TukeyHSD()` |
| Hubungan numerik×numerik | — | `cor.test()`, `lm()` |
| Frekuensi kategori | — | `table()`, `prop.table()`, `chisq.test()` |

---

## 7. ggplot2 — Template yang Sering Dipakai

```r
# 1) Bar chart dengan persen
ggplot(summary_by_line, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Defect rate per lini", y = "Defect rate (%)") +
  theme_minimal()

# 2) Tren per kelompok (multi-line)
ggplot(trend, aes(x = InspectionDate, y = DefectRate, color = Line)) +
  geom_line(linewidth = 1) + geom_point() +
  scale_y_continuous(labels = percent_format())

# 3) Multi-variabel: warna + ukuran + loess
ggplot(data, aes(InspectionDate, DefectRate, color = Line)) +
  geom_point(aes(size = Inspected), alpha = 0.7) +
  geom_smooth(method = "loess", se = FALSE) +
  facet_wrap(~ Line)

# 4) Garis target
ggplot(...) + geom_hline(yintercept = 0.05, linetype = "dashed", color = "red")
```

### Pilihan tema & warna

```r
theme_minimal(); theme_bw(); theme_classic(); theme_light()
scale_color_brewer(palette = "Set2")
scale_fill_viridis_d()
```

---

## 8. Ekstraksi & Ekspor Hasil Statistik

```r
# Ambil p-value dari uji t
t_result <- t.test(CycleTimeSec ~ Line, data = line_ab)
t_result$p.value
t_result$estimate         # rata-rata kelompok

# Dari anova
sm_anova <- summary(anova_model)

# Dari lm
sm <- summary(model)
sm$coefficients           # tabela koefisien
sm$r.squared              # R²

# Simpan hasil ke CSV
write.csv(as.data.frame(sm$coefficients), "coef.csv")
```

---

## 9. Tips & Trik Statistik + Visualisasi

1. **Cek data dulu**: distribusi dan outlier (`summary()`, boxplot) sebelum uji.
2. **Uji sesuai pertanyaan**, bukan sebaliknya — tentukan dulu apa yang ingin dibandingan.
3. **Uji satu sisi** hanya jika hipotesis memang searah (p-value dua sisi menjadi dua kali lebih besar).
4. **P-value kecil bukan berarti efek besar** — perhatikan beda rata-rata (`estimate`).
5. **CI memuat 0** = tidak signifikan; cepat pelaporan dengan interval.
6. **ANOVA signifikan** → selalu cek `TukeyHSD()` untuk mengetahui mana yang beda.
7. **Regresi**: periksa `R²` DAN p-value koefisien, serta plot residual dasar.
8. **R² tinggi ≠ model benar** — bisa overfit / omitted variable.
9. Pakai `geom_smooth(method = "lm")` = visualisasi yang sejalan dengan `lm()`.
10. **Boxplot bersama ANOVA** — visual kuartil memberi konteks beda nyata.
11. Pada data terbatas, beda signifikan bisa "tidak praktikal" — gabung dengan business judgement.
12. Formula vs vector `t.test`: pakai formula bila data dalam satu frame.
13. Jika `NA` di uji: bersihkan data dulu (`drop_na`/`filter`), bukan bergantung `na.rm` di fungsi.
14. Untuk laporan: tulis "p = 0,032; 95% CI [0,04; 0,80]" — tidak hanya p-value.
15. Interpretasi lengkap = **konteks + angka + batasan**.
16. P-value di regresi = uji t pada koefisien slope; interpretasi bergantung variabel.
17. `predict()` confidence vs prediction: CI = rata-rata Y, PI = nilai individual.
18. Simpan model `lm()` dalam objek — jangan hanya `summary()` sekali jalan.
19. Untuk sampling/replika: `set.seed(123)` agar hasil bisa diulang.
20. Jangan meng-copy insight contoh tanpa mengganti angka dari output Anda.

---

## 10. "Kalimat Sopan" untuk Menulis Insight (Template)

```text
1. Deskripsi:  "Rata-rata cycle time lini A adalah X detik, sementara lini B adalah Y detik."
2. Uji:       "Uji t menunjukkan beda yang [signifikan/tidak] signifikan (p = ..; 95% CI [.., ..])."
3. Efek:      "Selisih antarlini berjumlah Z detik, yang secara praktis [berarti/tidak berarti]."
4. Batasan:   "Hasil ini berbasis latihan dataset terbatas dan belum mengoreksi faktor proses lain."
```

---

*Cheatsheet Volume 1 — ingat cepat: t-test → ANOVA → regresi, interpretu p, R², selalu gabung ± grafik.*