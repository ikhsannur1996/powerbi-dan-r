# ============================================================
# Volume 2 — Statistics & Inferential Statistics
# 01_statistik_inferensial.R  —  analisis lengkap → output/
# ============================================================
# Menghasilkan tabel (output/tbl_*.csv) dan galeri visual
# (output/V01_*.png … output/V18_*.png).
# Semua nombor yang tampil di README berasal dari skrip ini.
# ============================================================

suppressMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(scales)
  library(broom)
})

base <- "/Users/ikhsannur1996/Documents/Power BI dan R/Volume 2 - Statistics and Inferential Statistics"
out  <- file.path(base, "output")
dir.create(out, showWarnings = FALSE)

inspeksi <- read.csv(file.path(base, "data/statistik_sample.csv")) |>
  mutate(
    Tanggal = as.Date(Tanggal),
    Line    = factor(Line, levels = c("A", "B", "C")),
    Shift   = factor(Shift, levels = c("Pagi", "Siang", "Malam")),
    Product = factor(Product)
  )
pelatihan <- read.csv(file.path(base, "data/pelatihan_sample.csv"))

tema <- theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold"),
    plot.subtitle = element_text(color = "grey40")
  )

simpan <- function(nama, p, w = 7, h = 4.5) {
  ggsave(file.path(out, nama), p, width = w, height = h, dpi = 150, bg = "white")
}

cat("=== 1. DESKRIPTIF ===\n")
deskriptif <- inspeksi |>
  summarise(
    N       = n(),
    MeanCT  = mean(CycleTimeSec),
    MedCT   = median(CycleTimeSec),
    SDCT    = sd(CycleTimeSec),
    MinCT   = min(CycleTimeSec),
    MaxCT   = max(CycleTimeSec),
    MeanRate = mean(DefectRate)
  )
print(as.data.frame(deskriptif))
write.csv(deskriptif, file.path(out, "tbl_deskriptif.csv"), row.names = FALSE)

# --- V01: histogram + kurva normal ---
mu <- mean(inspeksi$CycleTimeSec); s <- sd(inspeksi$CycleTimeSec)
p01 <- ggplot(inspeksi, aes(x = CycleTimeSec)) +
  geom_histogram(aes(y = after_stat(density)), binwidth = 2,
                 fill = "steelblue", color = "white") +
  stat_function(fun = dnorm, args = list(mean = mu, sd = s),
                color = "darkred", linewidth = 1) +
  labs(title = sprintf("Distribusi cycle time (mean %.1f s, sd %.1f s)", mu, s),
       subtitle = "Histogram + kurva normal pembanding",
       x = "Cycle time (detik)", y = "Kepadatan") +
  tema
simpan("V01_hist_cycletime.png", p01)

# --- V02: Q-Q plot normalitas ---
p02 <- ggplot(inspeksi, aes(sample = CycleTimeSec)) +
  stat_qq(color = "steelblue", alpha = 0.7) +
  stat_qq_line(color = "darkred", linewidth = 1) +
  labs(title = "Q-Q plot cycle time", subtitle = "Titik mengikuti garis = mendekati normal",
       x = "Kuantil teoretis (normal)", y = "Kuantil sampel") +
  tema
simpan("V02_qq_cycletime.png", p02)

# ============================================================
# 2. DISTRIBUSI SAMPLING & CENTRAL LIMIT THEOREM
# ============================================================
cat("\n=== 2. DISTRIBUSI SAMPLING (CLT) ===\n")
set.seed(1)
pop <- inspeksi$CycleTimeSec
clt <- bind_rows(lapply(c(5, 30, 100), function(nn) {
  means <- replicate(1000, mean(sample(pop, nn, replace = TRUE)))
  data.frame(n = nn, mean_sampel = means)
}))
clt$n <- factor(clt$n, labels = c("n = 5", "n = 30", "n = 100"))

p03 <- ggplot(clt, aes(x = mean_sampel)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  facet_wrap(~ n, scales = "free") +
  geom_vline(xintercept = mean(pop), color = "darkred", linetype = "dashed") +
  labs(title = "Distribusi sampling rata-rata (simulasi 1000x)",
       subtitle = "Semakin besar n, sebaran makin sempit & makin normal (CLT)",
       x = "Rata-rata sampel cycle time (detik)", y = "Frekuensi") +
  tema
simpan("V03_sampling_clt.png", p03, w = 9, h = 3.6)
cat("SD populasi:", round(sd(pop), 3), "\n")
print(round(tapply(clt$mean_sampel, clt$n, sd), 3))

# --- V04: standard error vs ukuran sampel ---
se_df <- data.frame(n = 2:200)
se_df$SE <- sd(pop) / sqrt(se_df$n)
p04 <- ggplot(se_df, aes(x = n, y = SE)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_point(data = data.frame(n = c(5, 30, 100), SE = sd(pop) / sqrt(c(5, 30, 100))),
             color = "darkred", size = 2.5) +
  labs(title = "Standard error mengecil seiring bertambahnya n",
       subtitle = "SE = sd / sqrt(n)",
       x = "Ukuran sampel (n)", y = "Standard error (detik)") +
  tema
simpan("V04_se_vs_n.png", p04)

# --- V05: distribusi t vs normal + daerah kritis ---
x <- seq(-4, 4, length.out = 400)
dist_df <- bind_rows(
  data.frame(x = x, y = dnorm(x), Dist = "Normal(0,1)"),
  data.frame(x = x, y = dt(x, df = 5), Dist = "t (df = 5)")
)
krit <- qt(0.975, df = 5)
p05 <- ggplot(dist_df, aes(x = x, y = y, color = Dist)) +
  geom_line(linewidth = 1) +
  geom_area(data = subset(dist_df, Dist == "t (df = 5)" & abs(x) >= krit),
            aes(y = y), fill = "darkred", alpha = 0.3, color = NA) +
  scale_color_manual(values = c("Normal(0,1)" = "grey30", "t (df = 5)" = "steelblue")) +
  labs(title = "Distribusi t vs normal", subtitle = "Area merah = daerah penolakan (alpha 5%, dua arah)",
       x = "Nilai statistik", y = "Kepadatan", color = NULL) +
  tema
simpan("V05_t_vs_normal.png", p05)
fmtp <- function(p) if (p < 2.2e-16) "< 2.2e-16" else format.pval(p, digits = 3)

# ============================================================
# 3. ESTIMASI & INTERVAL KEPERCAYAAN
# ============================================================
cat("\n=== 3. ESTIMASI & CI ===\n")

ci_mean <- function(x, conf = 0.95) {
  n  <- length(x); m <- mean(x); se <- sd(x) / sqrt(n)
  tc <- qt(1 - (1 - conf) / 2, df = n - 1)
  c(mean = m, se = se, lwr = m - tc * se, upr = m + tc * se)
}
cat("CI 95% mean cycle time (hitung manual):\n"); print(round(ci_mean(inspeksi$CycleTimeSec), 3))
cat("CI 95% mean cycle time (t.test):\n");     print(round(t.test(inspeksi$CycleTimeSec)$conf.int, 3))

ci_per_line <- inspeksi |>
  group_by(Line) |>
  summarise(rata = mean(CycleTimeSec), s = sd(CycleTimeSec), n = n(), .groups = "drop") |>
  mutate(se = s / sqrt(n), lwr = rata - qt(0.975, n - 1) * se, upr = rata + qt(0.975, n - 1) * se)
print(ci_per_line |> mutate(across(where(is.numeric), \(x) round(x, 3))))
write.csv(ci_per_line, file.path(out, "tbl_ci_mean.csv"), row.names = FALSE)

p06 <- ggplot(ci_per_line, aes(x = Line, y = rata, color = Line)) +
  geom_hline(yintercept = mean(inspeksi$CycleTimeSec), linetype = "dashed", color = "grey40") +
  geom_point(size = 3.5) +
  geom_errorbar(aes(ymin = lwr, ymax = upr), width = 0.15, linewidth = 1) +
  scale_color_manual(values = c(A = "#4C72B0", B = "#C44E52", C = "#55A868")) +
  labs(title = "Rata-rata cycle time per lini dengan CI 95%",
       subtitle = "Garis putus-putus = rata-rata keseluruhan; CI Lini B tidak menyentuhnya",
       x = "Lini", y = "Cycle time (detik)", color = "Lini") +
  tema
simpan("V06_ci_mean.png", p06)


# ============================================================
# 4. UJI HIPOTESIS — UJI T
# ============================================================
cat("\n=== 4. UJI T ===\n")

# 4.1 One-sample: apakah rata-rata cycle time = 45 detik?
tt1 <- t.test(inspeksi$CycleTimeSec, mu = 45)
cat(sprintf("1-sampel (mu=45): t = %.2f, df = %d, p = %s, CI [%.2f; %.2f]\n",
            tt1$statistic, tt1$parameter, fmtp(tt1$p.value),
            tt1$conf.int[1], tt1$conf.int[2]))

# 4.2 Two-sample independen: Lini A vs B
ct_a <- inspeksi$CycleTimeSec[inspeksi$Line == "A"]
ct_b <- inspeksi$CycleTimeSec[inspeksi$Line == "B"]
tt2  <- t.test(ct_a, ct_b, var.equal = TRUE)
cat(sprintf("2-sampel A vs B: t = %.2f, df = %d, p = %s, selisih = %.2f, CI [%.2f; %.2f]\n",
            tt2$statistic, tt2$parameter, fmtp(tt2$p.value),
            mean(ct_b) - mean(ct_a), tt2$conf.int[1], tt2$conf.int[2]))
cat(sprintf("Uji varians (var.test): p = %s\n", fmtp(var.test(ct_a, ct_b)$p.value)))
cat(sprintf("p satu arah (B > A): p = %s\n",
            fmtp(t.test(ct_a, ct_b, var.equal = TRUE, alternative = "less")$p.value)))
sp   <- sqrt(((length(ct_a) - 1) * var(ct_a) + (length(ct_b) - 1) * var(ct_b)) /
               (length(ct_a) + length(ct_b) - 2))
d_ab <- (mean(ct_b) - mean(ct_a)) / sp
cat(sprintf("Cohen's d (B vs A): %.2f  -> efek sangat besar\n", d_ab))

sub_ab <- subset(inspeksi, Line %in% c("A", "B"))
sum_ab <- sub_ab |>
  group_by(Line) |>
  summarise(rata = mean(CycleTimeSec), s = sd(CycleTimeSec), n = n(), .groups = "drop") |>
  mutate(se = s / sqrt(n), lwr = rata - qt(0.975, n - 1) * se, upr = rata + qt(0.975, n - 1) * se)
p07 <- ggplot(sub_ab, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot(alpha = 0.55, width = 0.5, outlier.shape = NA) +
  geom_jitter(width = 0.12, alpha = 0.3, size = 1) +
  geom_pointrange(data = sum_ab, aes(y = rata, ymin = lwr, ymax = upr),
                  color = "black", size = 0.8, linewidth = 0.8) +
  scale_fill_manual(values = c(A = "#4C72B0", B = "#C44E52")) +
  labs(title = "Cycle time Lini A vs B - uji t dua sampel",
       subtitle = sprintf("t = %.2f, p %s, selisih mean %.2f detik (Cohen's d = %.2f)",
                          tt2$statistic, fmtp(tt2$p.value), mean(ct_b) - mean(ct_a), d_ab),
       x = "Lini", y = "Cycle time (detik)", fill = "Lini") +
  tema
simpan("V07_uji_t_boxplot.png", p07)

# 4.3 Paired: cycle time sebelum vs sesudah pelatihan
tt3 <- t.test(pelatihan$CycleTimeSebelum, pelatihan$CycleTimeSesudah, paired = TRUE)
cat(sprintf("Berpasangan: t = %.2f, df = %d, p = %s, selisih = %.2f, CI [%.2f; %.2f]\n",
            tt3$statistic, tt3$parameter, fmtp(tt3$p.value),
            tt3$estimate, tt3$conf.int[1], tt3$conf.int[2]))

long_pel <- pelatihan |>
  tidyr::pivot_longer(c(CycleTimeSebelum, CycleTimeSesudah),
                      names_to = "Waktu", values_to = "CT") |>
  mutate(Waktu = factor(Waktu, levels = c("CycleTimeSebelum", "CycleTimeSesudah"),
                        labels = c("Sebelum", "Sesudah")))
p08 <- ggplot(long_pel, aes(x = Waktu, y = CT, group = Operator)) +
  geom_line(alpha = 0.3, color = "steelblue") +
  geom_point(alpha = 0.45, color = "steelblue", size = 1.5) +
  stat_summary(aes(group = 1), fun = mean, geom = "line", color = "darkred", linewidth = 1.4) +
  stat_summary(aes(group = 1), fun = mean, geom = "point", color = "darkred", size = 3.5) +
  labs(title = "Cycle time sebelum vs sesudah pelatihan (berpasangan, n = 30)",
       subtitle = sprintf("Selisih mean %.2f detik; t = %.2f; p %s",
                          tt3$estimate, tt3$statistic, fmtp(tt3$p.value)),
       x = NULL, y = "Cycle time (detik)") +
  tema
simpan("V08_paired_slope.png", p08)


# ============================================================
# 5. UJI PROPORSI & CHI-SQUARE
# ============================================================
cat("\n=== 5. PROPORSI & CHI-SQUARE ===\n")

agg_line <- inspeksi |>
  group_by(Line) |>
  summarise(Defect = sum(Defect), Inspected = sum(Inspected), .groups = "drop") |>
  mutate(Rate = Defect / Inspected)
print(agg_line)

# 5.1 Uji proporsi dua lini (A vs B)
prop_ab <- prop.test(x = c(agg_line$Defect[1], agg_line$Defect[2]),
                     n = c(agg_line$Inspected[1], agg_line$Inspected[2]))
cat(sprintf("prop.test A vs B: X2 = %.2f, df = %d, p = %s, selisih rate = %.4f\n",
            prop_ab$statistic, prop_ab$parameter, fmtp(prop_ab$p.value),
            agg_line$Rate[2] - agg_line$Rate[1]))

# 5.2 Uji goodness-of-fit: apakah defect rate lini seragam (1/3 tiap lini)?
chisq_gof <- chisq.test(agg_line$Defect, p = c(1/3, 1/3, 1/3))
cat(sprintf("chisq goodness-of-fit (uniform): X2 = %.2f, df = %d, p = %s\n",
            chisq_gof$statistic, chisq_gof$parameter, fmtp(chisq_gof$p.value)))

# 5.3 Chi-square of independence: Shift x kategori defect
inspeksi2 <- inspeksi |> mutate(DefectCat = ifelse(DefectRate > 0.05, "Tinggi", "Rendah"))
tab <- table(inspeksi2$Shift, inspeksi2$DefectCat)
print(tab)
print(round(prop.table(tab, 1), 3))
chisq_ind <- chisq.test(tab)
cat(sprintf("chisq independence Shift x DefectCat: X2 = %.2f, df = %d, p = %s\n",
            chisq_ind$statistic, chisq_ind$parameter, fmtp(chisq_ind$p.value)))
cat(sprintf("Cramer's V = %.3f\n",
            sqrt(as.numeric(chisq_ind$statistic) /
                   (sum(tab) * (min(dim(tab)) - 1)))))

prop_df <- inspeksi |>
  group_by(Shift) |>
  summarise(Defect = sum(Defect), Inspected = sum(Inspected), .groups = "drop") |>
  mutate(Rate = Defect / Inspected,
         se = sqrt(Rate * (1 - Rate) / Inspected),
         lwr = Rate - 1.96 * se, upr = Rate + 1.96 * se)
print(prop_df |> mutate(across(where(is.numeric), \(x) round(x, 4))))
write.csv(prop_df, file.path(out, "tbl_proporsi_shift.csv"), row.names = FALSE)

p09 <- ggplot(prop_df, aes(x = Shift, y = Rate, fill = Shift)) +
  geom_col(alpha = 0.85, width = 0.6) +
  geom_errorbar(aes(ymin = lwr, ymax = upr), width = 0.15, linewidth = 0.9) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  scale_fill_manual(values = c(Pagi = "#55A868", Siang = "#DD8452", Malam = "#C44E52")) +
  labs(title = "Defect rate per shift dengan CI 95%",
       subtitle = sprintf("Chi-square Shift x kategori defect: p %s", fmtp(chisq_ind$p.value)),
       x = "Shift", y = "Defect rate", fill = "Shift") +
  tema
simpan("V09_proporsi_shift.png", p09)

# 5.4 Uji proporsi 1 sampel: apakah defect rate = 5%?
p1 <- prop.test(sum(inspeksi$Defect), sum(inspeksi$Inspected), p = 0.05)
cat(sprintf("prop.test 1-sampel (target 5%%): X2 = %.2f, p = %s, CI [%.4f; %.4f]\n",
            p1$statistic, fmtp(p1$p.value), p1$conf.int[1], p1$conf.int[2]))

# ============================================================
# 6. ANOVA SATU ARAH + TUKEY
# ============================================================
cat("\n=== 6. ANOVA ===\n")
anova_fit <- aov(CycleTimeSec ~ Line, data = inspeksi)
print(summary(anova_fit))
cat(sprintf("Eta squared = %.3f\n",
            summary(anova_fit)[[1]][["Sum Sq"]][1] / sum(summary(anova_fit)[[1]][["Sum Sq"]])))
tukey <- TukeyHSD(anova_fit)
print(tukey)
tukey_df <- broom::tidy(tukey)
write.csv(tukey_df, file.path(out, "tbl_tukey.csv"), row.names = FALSE)

# Cek asumsi: normalitas residual & homogenitas varians
cat(sprintf("Shapiro-Wilk residual: p = %s\n", fmtp(shapiro.test(resid(anova_fit))$p.value)))
cat(sprintf("Levene/var.test A vs C: p = %s\n",
            fmtp(var.test(inspeksi$CycleTimeSec[inspeksi$Line == "A"],
                          inspeksi$CycleTimeSec[inspeksi$Line == "C"])$p.value)))

p10 <- ggplot(inspeksi, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot(alpha = 0.6, width = 0.55, outlier.shape = NA) +
  geom_jitter(width = 0.13, alpha = 0.25, size = 1) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "white") +
  scale_fill_manual(values = c(A = "#4C72B0", B = "#C44E52", C = "#55A868")) +
  labs(title = "Cycle time per lini - ANOVA satu arah",
       subtitle = sprintf("F = %.1f; p %s; eta squared = %.2f (efek besar)",
                          summary(anova_fit)[[1]][["F value"]][1],
                          fmtp(summary(anova_fit)[[1]][["Pr(>F)"]][1]),
                          summary(anova_fit)[[1]][["Sum Sq"]][1] / sum(summary(anova_fit)[[1]][["Sum Sq"]])),
       x = "Lini", y = "Cycle time (detik)", fill = "Lini") +
  tema
simpan("V10_anova_boxplot.png", p10)

# --- V11: post-hoc Tukey ---
tukey_df$pair <- gsub("-", " vs ", tukey_df$contrast)
tukey_df$signif <- ifelse(tukey_df$adj.p.value < 0.05, "Signifikan", "Tidak signifikan")
p11 <- ggplot(tukey_df, aes(x = estimate, y = reorder(pair, estimate), color = signif)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(xmin = conf.low, xmax = conf.high), linewidth = 1, size = 0.8) +
  scale_color_manual(values = c("Signifikan" = "#C44E52", "Tidak signifikan" = "grey60")) +
  labs(title = "Post-hoc Tukey HSD - selisih cycle time antar lini",
       subtitle = "Interval yang tidak memuat nol = berbeda nyata",
       x = "Selisih rata-rata (detik)", y = NULL, color = NULL) +
  tema
simpan("V11_tukey.png", p11)

# ============================================================
# 7. KORELASI
# ============================================================
cat("\n=== 7. KORELASI ===\n")
r_pear <- cor.test(inspeksi$CycleTimeSec, inspeksi$DefectRate, method = "pearson")
r_spear <- suppressWarnings(
  cor.test(inspeksi$CycleTimeSec, inspeksi$DefectRate, method = "spearman"))
cat(sprintf("Pearson : r = %.3f, p = %s, CI [%.3f; %.3f]\n",
            r_pear$estimate, fmtp(r_pear$p.value), r_pear$conf.int[1], r_pear$conf.int[2]))
cat(sprintf("Spearman: rho = %.3f, p = %s\n", r_spear$estimate, fmtp(r_spear$p.value)))
cat(sprintf("R-squared = %.3f (cycle time menjelaskan %.1f%% variasi defect rate)\n",
            r_pear$estimate^2, 100 * r_pear$estimate^2))

p12 <- ggplot(inspeksi, aes(x = CycleTimeSec, y = DefectRate)) +
  geom_point(alpha = 0.4, color = "steelblue") +
  geom_smooth(method = "lm", formula = y ~ x, color = "darkred", se = TRUE) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "Korelasi cycle time vs defect rate",
       subtitle = sprintf("Pearson r = %.2f (p %s); R-squared = %.2f",
                          r_pear$estimate, fmtp(r_pear$p.value), r_pear$estimate^2),
       x = "Cycle time (detik)", y = "Defect rate") +
  tema
simpan("V12_korelasi.png", p12)

# --- V13: heatmap matriks korelasi antar numerik ---
num <- inspeksi |> select(Inspected, Defect, DefectRate, CycleTimeSec)
cmat <- cor(num)
cor_long <- as.data.frame(as.table(cmat))
names(cor_long) <- c("Var1", "Var2", "r")
p13 <- ggplot(cor_long, aes(x = Var1, y = Var2, fill = r)) +
  geom_tile(color = "white") +
  geom_text(aes(label = sprintf("%.2f", r)), size = 3.5, color = "black") +
  scale_fill_gradient2(low = "#4C72B0", mid = "white", high = "#C44E52",
                       midpoint = 0, limits = c(-1, 1)) +
  labs(title = "Matriks korelasi variabel numerik", x = NULL, y = NULL, fill = "r") +
  coord_fixed() + tema
simpan("V13_heatmap_korelasi.png", p13, w = 6.5, h = 5)

# ============================================================
# 8. REGRESI LINEAR SEDERHANA + DIAGNOSTIK
# ============================================================
cat("\n=== 8. REGRESI SEDERHANA ===\n")
reg1 <- lm(DefectRate ~ CycleTimeSec, data = inspeksi)
print(summary(reg1))
write.csv(broom::tidy(reg1), file.path(out, "tbl_regresi_sederhana.csv"), row.names = FALSE)
b0 <- coef(reg1)[1]; b1 <- coef(reg1)[2]
cat(sprintf("Model: DefectRate = %.4f + %.5f * CycleTimeSec\n", b0, b1))
cat(sprintf("R-squared = %.3f, p-value slope = %s\n",
            summary(reg1)$r.squared, fmtp(broom::tidy(reg1)$p.value[2])))
cat("Prediksi:\n")
pred_ct <- data.frame(CycleTimeSec = c(40, 45, 50, 55))
print(cbind(pred_ct, round(predict(reg1, pred_ct, interval = "confidence"), 4)))

p14 <- ggplot(inspeksi, aes(x = CycleTimeSec, y = DefectRate)) +
  geom_point(alpha = 0.35, color = "steelblue") +
  geom_smooth(method = "lm", formula = y ~ x, color = "darkred", fill = "darkred", alpha = 0.15) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "Regresi linear: defect rate ~ cycle time",
       subtitle = sprintf("Slope = %.5f per detik; R-squared = %.2f",
                          b1, summary(reg1)$r.squared),
       x = "Cycle time (detik)", y = "Defect rate") +
  tema
simpan("V14_regresi_sederhana.png", p14)

# --- V15: 4 plot diagnostik residual (base R) ---
png(file.path(out, "V15_diagnostik_residual.png"), width = 1200, height = 1050, res = 150)
par(mfrow = c(2, 2), mar = c(4, 4, 3, 1))
plot(reg1, which = 1:4)
par(mfrow = c(1, 1))
dev.off()

# ============================================================
# 9. REGRESI LINEAR BERGANDA
# ============================================================
cat("\n=== 9. REGRESI BERGANDA ===\n")
reg2 <- lm(DefectRate ~ CycleTimeSec + Line + Shift, data = inspeksi)
print(summary(reg2))
write.csv(broom::tidy(reg2), file.path(out, "tbl_regresi_berganda.csv"), row.names = FALSE)
cat(sprintf("R-squared berganda = %.3f, Adjusted R-squared = %.3f\n",
            summary(reg2)$r.squared, summary(reg2)$adj.r.squared))

# --- V16: koefisien regresi berganda (estimasi + CI) ---
coef_df <- broom::tidy(reg2, conf.int = TRUE) |> filter(term != "(Intercept)")
coef_df$signif <- ifelse(coef_df$p.value < 0.05, "Signifikan", "Tidak signifikan")
p16 <- ggplot(coef_df, aes(x = estimate, y = reorder(term, estimate), color = signif)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(xmin = conf.low, xmax = conf.high), linewidth = 0.9, size = 0.7) +
  scale_color_manual(values = c("Signifikan" = "#C44E52", "Tidak signifikan" = "grey60")) +
  labs(title = "Koefisien regresi berganda (dengan CI 95%)",
       subtitle = sprintf("Adjusted R-squared = %.2f", summary(reg2)$adj.r.squared),
       x = "Estimasi koefisien", y = NULL, color = NULL) +
  tema
simpan("V16_koef_regresi.png", p16, w = 7.5, h = 5)

# ============================================================
# 10. UJI NON-PARAMETRIK
# ============================================================
cat("\n=== 10. NON-PARAMETRIK ===\n")

# 10.1 Mann-Whitney U (alternatif uji t dua sampel, tanpa asumsi normal)
mw <- wilcox.test(ct_a, ct_b)
cat(sprintf("Mann-Whitney A vs B: W = %.0f, p = %s\n", mw$statistic, fmtp(mw$p.value)))

# 10.2 Kruskal-Wallis (alternatif ANOVA)
kw <- kruskal.test(CycleTimeSec ~ Line, data = inspeksi)
cat(sprintf("Kruskal-Wallis (Line): chi-sq = %.2f, df = %d, p = %s\n",
            kw$statistic, kw$parameter, fmtp(kw$p.value)))

# 10.3 Wilcoxon signed-rank (alternatif uji t berpasangan)
wx <- wilcox.test(pelatihan$CycleTimeSebelum, pelatihan$CycleTimeSesudah, paired = TRUE)
cat(sprintf("Wilcoxon berpasangan: V = %.0f, p = %s\n", wx$statistic, fmtp(wx$p.value)))

# 10.4 Uji normalitas
cat(sprintf("Shapiro-Wilk cycle time: p = %s\n",
            fmtp(shapiro.test(inspeksi$CycleTimeSec)$p.value)))
cat(sprintf("Kolmogorov-Smirnov cycle time: p = %s\n",
            fmtp(suppressWarnings(
              ks.test(inspeksi$CycleTimeSec, "pnorm",
                      mean = mean(inspeksi$CycleTimeSec),
                      sd = sd(inspeksi$CycleTimeSec)))$p.value)))

# --- V17: bandingkan parametrik vs non-parametrik ---
rank_df <- data.frame(
  Uji = c("t-test\n(2 sampel)", "Mann-Whitney", "ANOVA", "Kruskal-Wallis",
          "t-test\n(berpasangan)", "Wilcoxon"),
  Parametrik = c("Ya", "Tidak", "Ya", "Tidak", "Ya", "Tidak"),
  p = c(tt2$p.value, mw$p.value,
        summary(anova_fit)[[1]][["Pr(>F)"]][1], kw$p.value,
        tt3$p.value, wx$p.value)
)
rank_df$sig <- ifelse(rank_df$p < 0.05, "p < 0.05", "p >= 0.05")
p17 <- ggplot(rank_df, aes(x = Uji, y = -log10(p), fill = Parametrik)) +
  geom_col(width = 0.7, alpha = 0.9) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "darkred") +
  geom_text(aes(label = ifelse(p < 2.2e-16, "p<2e-16", sprintf("p=%.1e", p))),
            vjust = -0.4, size = 3) +
  annotate("text", x = 0.6, y = -log10(0.05), label = "alpha = 5%",
           color = "darkred", hjust = 0, vjust = -0.6, size = 3.2) +
  scale_fill_manual(values = c(Ya = "#4C72B0", Tidak = "#DD8452")) +
  labs(title = "Bandingkan uji parametrik vs non-parametrik",
       subtitle = "-log10(p): makin tinggi = bukti makin kuat menolak H0",
       x = NULL, y = "-log10(p-value)", fill = "Parametrik") +
  tema
simpan("V17_parametrik_vs_nonparametrik.png", p17, w = 9, h = 5)

# ============================================================
# 11. UKURAN EFEK & POWER
# ============================================================
cat("\n=== 11. UKURAN EFEK & POWER ===\n")
d_paired <- mean(pelatihan$Selisih) / sd(pelatihan$Selisih)
cat(sprintf("Cohen's d (berpasangan) = %.2f\n", d_paired))
cat(sprintf("Cohen's d (A vs B)      = %.2f\n", d_ab))
cat(sprintf("Eta squared (ANOVA)     = %.3f\n",
            summary(anova_fit)[[1]][["Sum Sq"]][1] / sum(summary(anova_fit)[[1]][["Sum Sq"]])))

pt <- power.t.test(delta = 4.5, sd = 2.0, sig.level = 0.05, power = 0.80,
                   type = "paired")
cat(sprintf("n minimal dibutuhkan (power 80%%, delta 4,5, sd 2,0): %.0f pasang\n", ceiling(pt$n)))
pwr_seq <- data.frame(n = 5:60) |>
  mutate(power = sapply(n, function(k)
    power.t.test(n = k, delta = 4.5, sd = 2.0, sig.level = 0.05, type = "paired")$power))

p18 <- ggplot(pwr_seq, aes(x = n, y = power)) +
  geom_line(color = "steelblue", linewidth = 1.2) +
  geom_hline(yintercept = 0.80, linetype = "dashed", color = "darkred") +
  geom_vline(xintercept = ceiling(pt$n), linetype = "dotted", color = "darkred") +
  annotate("text", x = ceiling(pt$n) + 1, y = 0.35,
           label = sprintf("n = %d", ceiling(pt$n)), color = "darkred", hjust = 0) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "Kurva power untuk uji t berpasangan",
       subtitle = "delta = 4,5 detik; sd = 2,0; alpha = 5% (garis putus-putus = power 80%)",
       x = "Ukuran sampel (n pasang)", y = "Power") +
  tema
simpan("V18_power_curve.png", p18)

# ============================================================
# 12. RINGKASAN UNTUK DASHBOARD
# ============================================================
cat("\n=== 12. RINGKASAN ===\n")
ci_all <- ci_mean(inspeksi$CycleTimeSec)
ringkasan <- bind_rows(
  data.frame(Uji = "Deskriptif: rata-rata cycle time", Nilai = sprintf("%.2f detik", mean(inspeksi$CycleTimeSec))),
  data.frame(Uji = "CI 95% rata-rata cycle time", Nilai = sprintf("[%.2f; %.2f]", ci_all["lwr"], ci_all["upr"])),
  data.frame(Uji = "t-test 1 sampel vs 45 detik", Nilai = sprintf("p = %s", fmtp(tt1$p.value))),
  data.frame(Uji = "t-test A vs B", Nilai = sprintf("selisih %.2f detik, p = %s", mean(ct_b) - mean(ct_a), fmtp(tt2$p.value))),
  data.frame(Uji = "t-test berpasangan (pelatihan)", Nilai = sprintf("-%.2f detik, p = %s", tt3$estimate, fmtp(tt3$p.value))),
  data.frame(Uji = "Proporsi A vs B", Nilai = sprintf("X2 = %.1f, p = %s", prop_ab$statistic, fmtp(prop_ab$p.value))),
  data.frame(Uji = "Chi-square Shift x defect", Nilai = sprintf("p = %s, V = %.2f", fmtp(chisq_ind$p.value), sqrt(as.numeric(chisq_ind$statistic) / (sum(tab) * (min(dim(tab)) - 1))))),
  data.frame(Uji = "ANOVA cycle time per lini", Nilai = sprintf("F = %.1f, p = %s", summary(anova_fit)[[1]][["F value"]][1], fmtp(summary(anova_fit)[[1]][["Pr(>F)"]][1]))),
  data.frame(Uji = "Korelasi cycle time ~ defect rate", Nilai = sprintf("r = %.2f, p = %s", r_pear$estimate, fmtp(r_pear$p.value))),
  data.frame(Uji = "Regresi sederhana", Nilai = sprintf("R2 = %.2f", summary(reg1)$r.squared)),
  data.frame(Uji = "Regresi berganda", Nilai = sprintf("Adj R2 = %.2f", summary(reg2)$adj.r.squared))
)
print(ringkasan)
write.csv(ringkasan, file.path(out, "tbl_ringkasan_uji.csv"), row.names = FALSE)

cat("\nSelesai! Semua visual tersimpan di folder output/.\n")
cat("Total file PNG :", length(list.files(out, pattern = "\\.png$")), "\n")
cat("Total file CSV :", length(list.files(out, pattern = "\\.csv$")), "\n")

