# ============================================================
# Opsi 5 - Persediaan & Safety Stock
# R/01_analisis_dplyr.R  --  statistik & agregasi (dplyr) -> output/*.csv
# ============================================================
# Ringkasan:
#   - EOQ      = sqrt(2*PermintaanAnual*TarifOrder / (Hold*HargaUnit))
#   - SigmaDLT = sqrt(LT_Rata*SD_demanda^2 + Mean^2*LT_SD^2)
#   - ROP      = Mean*LT_Rata + Safety Stock (z*SigmaDLT)
#   - SS_company = cover_days x permintaan rata  (policy naif saat ini)
# ============================================================

suppressMessages({ library(dplyr); library(tidyr); library(broom) })

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
out  <- file.path(base, "output"); dir.create(out, showWarnings = FALSE)

d <- read.csv(file.path(base, "data", "persediaan.csv")) |>
  mutate(Tanggal  = as.Date(Tanggal),
         Produk   = factor(Produk),
         Bulan    = format(Tanggal, "%Y-%m"))
prod <- read.csv(file.path(base, "data", "produk.csv"))

# ------------------------------------------------------------
# 1. STATISTIK PERMINTAAN PER PRODUK
# ------------------------------------------------------------
cat("=== 1. PERMINTAAN PER PRODUK ===\n")
dem <- d |> group_by(Produk) |>
  summarise(N_Hari  = n(),
            Sum     = sum(Permintaan),
            Mean    = mean(Permintaan),
            SD      = sd(Permintaan),
            Min     = min(Permintaan),
            Max     = max(Permintaan), .groups = "drop") |>
  mutate(CV = SD / Mean) |>
  left_join(prod |> select(Produk, NamaProduk, Kategori, HargaUnit), by = "Produk")
print(as.data.frame(dem |> mutate(across(where(is.numeric), ~ round(.x, 2)))))
write.csv(dem, file.path(out, "tbl_demanda.csv"), row.names = FALSE)

# ------------------------------------------------------------
# 2. POLICY: EOQ, ROP, SAFETY STOCK  (level produk)
# ------------------------------------------------------------
cat("\n=== 2. POLICY INVENTAIRI (EOQ / ROP / SS) ===\n")
K_order <- 150000        # tarif per order (currency)
h_rate  <- 0.30          # holding cost 30%/jaar
cover   <- c(Premium = 5, Standar = 8, Mass = 30)    # cover_days company

policy <- dem |>
  left_join(prod |> select(Produk, LT_Rata, LT_SD, TargetSL), by = "Produk") |>
  mutate(Annual      = Mean * 313,                       # 6 hari/semain
         SigmaDLT    = sqrt(LT_Rata * SD^2 + Mean^2 * LT_SD^2),
         SS_company  = as.numeric(cover[as.character(Kategori)]) * Mean,
         SS_rec      = qnorm(TargetSL) * SigmaDLT,
         ROP_rec     = Mean * LT_Rata + SS_rec,
         EOQ         = sqrt(2 * Annual * K_order / (h_rate * HargaUnit))) |>
  select(Produk, NamaProduk, Kategori, HargaUnit, LT_Rata, Mean, SD, CV,
         Annual, SigmaDLT, SS_company, SS_rec, ROP_rec, EOQ)
print(as.data.frame(policy |> mutate(across(where(is.numeric), ~ round(.x, 1)))))
write.csv(policy, file.path(out, "tbl_policy.csv"), row.names = FALSE)

# ------------------------------------------------------------
# 3. ABC CLASSIFICATION (berdasarkan nilai pemakaian tahunan)
# ------------------------------------------------------------
# 4. PERFORMANS SAAT INI (dari simulasi stok)
# ------------------------------------------------------------
cat("\n=== 4. PERFORMANS POLICY PERUSAHAAN ===\n")
perf <- d |> group_by(Produk) |>
  summarise(StockoutDays    = sum(Stockout),
            DefisitUnit     = sum(Defisit),
            PermintaanTotal = sum(Permintaan),
            AvgStok         = mean(StokEnd), .groups = "drop") |>
  left_join(dem |> select(Produk, N_Hari), by = "Produk") |>
  mutate(ServiceLevel = 1 - StockoutDays / N_Hari,
         FillRate     = 1 - DefisitUnit / PermintaanTotal) |>
  left_join(prod |> select(Produk, HargaUnit), by = "Produk") |>
  mutate(AvgStokValue = AvgStok * HargaUnit)
print(as.data.frame(perf |> mutate(across(where(is.numeric), ~ round(.x, 4)))))
write.csv(perf, file.path(out, "tbl_perf.csv"), row.names = FALSE)

# ------------------------------------------------------------
# 5. UJI STATISTIK
# ------------------------------------------------------------
cat("\n=== 5. UJI STATISTIK ===\n")
# 5a. Uji t musiman: P-03 bulan end-of-quarter vs bulan biasa
p03 <- d |> filter(Produk == "P-03") |>
  mutate(Puncak = as.integer(format(Tanggal, "%m")) %in% c(3, 6, 9, 12))
tt_m <- t.test(Permintaan ~ Puncak, data = p03, var.equal = FALSE)
cat(sprintf("Uji t musiman P-03: puncak Eoq %.1f unit lebih tinggi dari bulan biasa, |t| = %.2f, p = %.3g\n",
            diff(tt_m$estimate), abs(tt_m$statistic), tt_m$p.value))

# 5b. ANOVA permintaan antar produk
aov_d <- aov(Permintaan ~ Produk, data = d)
aov_tab <- tidy(aov_d)
cat(sprintf("ANOVA permintaan antar produk: F = %.1f, p = %.3g\n",
            aov_tab$statistic[1], aov_tab$p.value[1]))

# 5c. Variasi bulanan (menangkap musiman) per produk
cv_bulan <- d |>
  group_by(Produk, Bulan) |>
  summarise(M = sum(Permintaan), .groups = "drop") |>
  group_by(Produk) |>
  summarise(CVBulan = sd(M) / mean(M), .groups = "drop")

# 5d. Regresi + korelasi: laju stockout ~ CV bulanan (level produk)
lvl <- perf |>
  left_join(cv_bulan, by = "Produk") |>
  mutate(Laju = StockoutDays / N_Hari)
reg_cv <- lm(Laju ~ CVBulan, data = lvl)
cat(sprintf("Regresi laju stockout ~ CV bulanan: slope = %.3f, R2 = %.3f, p = %.3g\n",
            coef(reg_cv)[2], summary(reg_cv)$r.squared, tidy(reg_cv)$p.value[2]))
ct <- cor.test(lvl$CVBulan, lvl$Laju)
cat(sprintf("Korelasi CV bulanan vs laju stockout: r = %.3f, p = %.3g\n", ct$estimate, ct$p.value))
# ------------------------------------------------------------
cat("\n=== 3. ABC KUMULATIF ===\n")
abc <- policy |> arrange(desc(Annual * HargaUnit)) |>
  mutate(UsageValue = Annual * HargaUnit,
         Share      = UsageValue / sum(UsageValue),
         Kum        = cumsum(Share),
         ABC        = case_when(Kum <= 0.75 ~ "A", Kum <= 0.975 ~ "B", TRUE ~ "C"))
print(as.data.frame(abc |>
  select(Produk, Kategori, Annual, UsageValue, Share, Kum, ABC) |>
  mutate(across(where(is.numeric), ~ round(.x, 3)))))
# ------------------------------------------------------------
# 6. TREN BULANAN  (per produk)
# ------------------------------------------------------------
tren <- d |> group_by(Bulan, Produk) |>
  summarise(Permintaan = sum(Permintaan),
            Stockout   = sum(Stockout), .groups = "drop") |>
  mutate(Bulan = as.Date(paste0(Bulan, "-01")))
write.csv(tren, file.path(out, "tbl_tren_bulanan.csv"), row.names = FALSE)

# ------------------------------------------------------------
# 7. SKENARIO WHAT-IF: SERVICE LEVEL -> SAFETY STOCK
# ------------------------------------------------------------
cat("\n=== 7. WHAT-IF: SAFETY STOCK PER SERVICE LEVEL ===\n")
SL_grid <- c(0.90, 0.95, 0.98, 0.99)
skenario <- do.call(rbind, lapply(SL_grid, function(sl) {
  policy |>
    mutate(SL       = sl,
           z        = qnorm(sl),
           SS_rec   = z * SigmaDLT,
           ROP      = Mean * LT_Rata + SS_rec,
           Invest   = SS_rec * HargaUnit,
           Delta    = (SS_rec - SS_company) * HargaUnit) |>
    select(Produk, Kategori, SL, SS_rec, ROP, Invest, Delta)
}))
print(as.data.frame(skenario |> mutate(across(where(is.numeric), ~ round(.x, 2)))))
write.csv(skenario, file.path(out, "tbl_skenario.csv"), row.names = FALSE)

saveRDS(list(dem = dem, policy = policy, abc = abc, perf = perf,
             tren = tren, skenario = skenario, lvl = lvl,
             tt_m = tt_m, aov_tab = aov_tab, reg_cv = reg_cv),
        file.path(out, "hasil_opsi5.rds"))
cat("\nAnalisis Opsi 5 selesai. Tabel tersimpan di output/.\n")
write.csv(abc, file.path(out, "tbl_abc.csv"), row.names = FALSE)