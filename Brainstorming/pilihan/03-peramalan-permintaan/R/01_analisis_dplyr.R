# ============================================================
# Opsi 3 - Peramalan Permintaan & Perencanaan Produksi
# R/01_analisis_dplyr.R  --  statistik & agregasi (dplyr) -> output/*.csv
# ============================================================

suppressMessages({ library(dplyr); library(tidyr); library(broom) })

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
out  <- file.path(base, "output"); dir.create(out, showWarnings = FALSE)

d <- read.csv(file.path(base, "data", "permintaan.csv")) |>
  mutate(Bulan = as.Date(Bulan),
         BulanKe = as.integer(format(Bulan, "%m")),
         Tahun   = format(Bulan, "%Y"),
         Produk  = factor(Produk))
produk <- read.csv(file.path(base, "data", "produk.csv"))

# ------------------------------------------------------------
# 1. AGREGASI DASAR
# ------------------------------------------------------------
cat("=== TOTAL PERMINTAAAN PER TAHUN ===\n")
per_tahun <- d |> group_by(Tahun) |>
  summarise(Total = sum(Permintaan), .groups = "drop") |>
  mutate(Pertumbuhan = round((Total / lag(Total) - 1) * 100, 1))
print(as.data.frame(per_tahun))
write.csv(per_tahun, file.path(out, "tbl_per_tahun.csv"), row.names = FALSE)

cat("\n=== PERMINTAAAN PER PRODUK ===\n")
per_produk <- d |> group_by(Produk) |>
  summarise(Total = sum(Permintaan), Rata = mean(Permintaan),
            Min = min(Permintaan), Max = max(Permintaan), .groups = "drop") |>
  left_join(produk, by = "Produk") |>
  mutate(PangsaPasar = Total / sum(Total))
print(as.data.frame(per_produk |> mutate(across(where(is.numeric), ~ round(.x, 3)))))
write.csv(per_produk, file.path(out, "tbl_per_produk.csv"), row.names = FALSE)

# ------------------------------------------------------------
# 2. MUSIMAN: indeks per bulan kalender
# ------------------------------------------------------------
cat("\n=== INDEKS MUSIMAN (bulan kalender) ===\n")
musiman <- d |>
  group_by(BulanKe) |>
  summarise(Rata = mean(Permintaan), .groups = "drop") |>
  mutate(Indeks = Rata / mean(Rata),
         NamaBulan = month.abb[BulanKe])
print(as.data.frame(musiman |> mutate(Rata = round(Rata), Indeks = round(Indeks, 3))))
write.csv(musiman, file.path(out, "tbl_musiman.csv"), row.names = FALSE)

# ------------------------------------------------------------
# 3. UJI STATISTIK: tren & musiman
# ------------------------------------------------------------
# Regresi tren total permintaan bulanan (agregat)
total_bulan <- d |> group_by(Bulan) |>
  summarise(Total = sum(Permintaan), .groups = "drop") |>
  mutate(t = row_number())
tren_fit <- lm(Total ~ t, data = total_bulan)
cat(sprintf("\nTren linear: slope = %.1f unit/bulan, R2 = %.3f, p = %.3g\n",
            coef(tren_fit)[2], summary(tren_fit)$r.squared,
            tidy(tren_fit)$p.value[2]))

# ANOVA: apakah permintaan berbeda antar bulan kalender? (bukti musiman)
mus_fit <- aov(Permintaan ~ factor(BulanKe), data = d)
cat(sprintf("ANOVA musiman (data mentah): F = %.2f, p = %.3g\n",
            tidy(mus_fit)$statistic[1], tidy(mus_fit)$p.value[1]))

# Uji t yang lebih sensitif: agregat bulanan, puncak (Okt-Des) vs bulan lain
total_bulan <- total_bulan |>
  mutate(BulanKe = as.integer(format(Bulan, "%m")),
         Puncak  = factor(ifelse(BulanKe %in% 10:12, "Puncak", "Biasa"),
                          levels = c("Puncak", "Biasa")))
tt <- t.test(Total ~ Puncak, data = total_bulan, var.equal = TRUE)
mean_biasa  <- mean(total_bulan$Total[total_bulan$Puncak == "Biasa"])
mean_puncak <- mean(total_bulan$Total[total_bulan$Puncak == "Puncak"])
cat(sprintf("Uji t puncak vs biasa (agregat bulanan): selisih = +%.0f unit, t = %.2f, p = %.3g\n",
            mean_puncak - mean_biasa, tt$statistic, tt$p.value))

# ------------------------------------------------------------
# 4. PERAMALAN: Moving Average & Exponential Smoothing (per produk)
# ------------------------------------------------------------
# MA(3): rata-rata 3 bulan terakhir; EWMA: pembobotan eksponensial manual.
ewma <- function(x, alpha) {
  # smoothing eksponensial sederhana (manual, tanpa package tambahan)
  # 3 nilai pertama di-NA-kan agar basis akurasi sama dengan MA(3)
  out <- rep(NA_real_, length(x))
  if (length(x) < 4) return(out)
  out[4] <- mean(x[1:3])                                   # seed ramalan t=4
  for (i in 5:length(x)) out[i] <- alpha * x[i - 1] + (1 - alpha) * out[i - 1]
  out
}

ma_ewma <- d |>
  arrange(Produk, Bulan) |>
  group_by(Produk) |>
  mutate(
    MA3    = (lag(Permintaan, 1) + lag(Permintaan, 2) + lag(Permintaan, 3)) / 3,
    EWMA03 = ewma(Permintaan, 0.3),
    EWMA06 = ewma(Permintaan, 0.6)
  ) |>
  ungroup()


# Fungsi akurasi (hanya baris yang punya nilai peramalan)
akurasi <- function(aktual, ramalan, nama) {
  ok <- !is.na(ramalan)
  a <- aktual[ok]; f <- ramalan[ok]
  data.frame(Model = nama,
             MAE  = mean(abs(a - f)),
             MAPE = mean(abs((a - f) / a)) * 100,
             RMSE = sqrt(mean((a - f)^2)))
}
cat("\n=== AKURASI PERAMALAN (semua produk) ===\n")
acc <- bind_rows(
  akurasi(ma_ewma$Permintaan, ma_ewma$MA3,    "Moving Average (3)"),
  akurasi(ma_ewma$Permintaan, ma_ewma$EWMA03, "Exp. Smoothing (a=0.3)"),
  akurasi(ma_ewma$Permintaan, ma_ewma$EWMA06, "Exp. Smoothing (a=0.6)")
)
print(as.data.frame(acc |> mutate(across(where(is.numeric), ~ round(.x, 2)))))
write.csv(acc, file.path(out, "tbl_akurasi.csv"), row.names = FALSE)
write.csv(ma_ewma, file.path(out, "tbl_peramalan.csv"), row.names = FALSE)

# ------------------------------------------------------------
# 5. KAPASITAS vs PERMINTAAN PUNCAK (per produk)
# ------------------------------------------------------------
kapasitas <- d |>
  group_by(Produk) |>
  summarise(PuncakBulanan = max(Permintaan), RataBulanan = mean(Permintaan),
            .groups = "drop") |>
  left_join(produk, by = "Produk") |>
  mutate(Utilisasi        = PuncakBulanan / KapasitasMesin,
         MesinDibutuhkan  = ceiling(Utilisasi),
         KekuranganMesin  = MesinDibutuhkan - 1)
cat("\n=== CEK KAPASITAS (bulan puncak) ===\n")
print(as.data.frame(kapasitas |> mutate(across(where(is.numeric), ~ round(.x, 3)))))
write.csv(kapasitas, file.path(out, "tbl_kapasitas.csv"), row.names = FALSE)

saveRDS(list(per_tahun = per_tahun, per_produk = per_produk, musiman = musiman,
             total_bulan = total_bulan, tren_fit = tren_fit, mus_fit = mus_fit,
             acc = acc, ma_ewma = ma_ewma, kapasitas = kapasitas),
        file.path(out, "hasil_opsi3.rds"))
cat("\nAnalisis Opsi 3 selesai. Tabel tersimpan di output/.\n")
