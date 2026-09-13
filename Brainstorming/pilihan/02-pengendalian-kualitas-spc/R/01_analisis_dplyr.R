# ============================================================
# Opsi 2 - Pengendalian Kualitas Statistik (SPC)
# R/01_analisis_dplyr.R  --  statistik & agregasi (dplyr) -> output/*.csv
# ============================================================

suppressMessages({ library(dplyr); library(tidyr); library(broom) })

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
out  <- file.path(base, "output"); dir.create(out, showWarnings = FALSE)

d <- read.csv(file.path(base, "data", "qc_karakteristik.csv")) |>
  mutate(Karakteristik = factor(Karakteristik),
         Shift = factor(Shift, levels = c("Pagi", "Sore", "Malam")),
         Mesin = factor(Mesin))
spek <- read.csv(file.path(base, "data", "spesifikasi.csv"))

# --- konstanta peta kendali X-bar & R untuk n = 5 ---
A2 <- 0.577; D3 <- 0; D4 <- 2.114; d2 <- 2.326

# --- peta kendali per karakteristik ---
peta <- d |>
  group_by(Karakteristik, Subgroup) |>
  summarise(Xbar = mean(Pengukuran), R = max(Pengukuran) - min(Pengukuran),
            .groups = "drop") |>
  group_by(Karakteristik) |>
  mutate(Xbarbar = mean(Xbar), Rbar = mean(R),
         UCL_x = Xbarbar + A2 * Rbar, LCL_x = Xbarbar - A2 * Rbar,
         UCL_r = D4 * Rbar, LCL_r = D3 * Rbar,
         OutOfControl = (Xbar > UCL_x | Xbar < LCL_x | R > UCL_r)) |>
  ungroup()

cat("=== PETA KENDALI X-BAR (batas per karakteristik) ===\n")
print(as.data.frame(peta |> group_by(Karakteristik) |>
  summarise(Xbarbar = first(Xbarbar), Rbar = first(Rbar),
            UCL = first(UCL_x), LCL = first(LCL_x),
            OOC = sum(OutOfControl), .groups = "drop") |>
  mutate(across(where(is.numeric), \(x) round(x, 3)))))
write.csv(peta, file.path(out, "tbl_peta_kendali.csv"), row.names = FALSE)

# --- Cp / Cpk per karakteristik ---
capability <- d |>
  group_by(Karakteristik) |>
  summarise(mean = mean(Pengukuran), sd = sd(Pengukuran), .groups = "drop") |>
  left_join(spek, by = "Karakteristik") |>
  mutate(Cp  = (USL - LSL) / (6 * sd),
         Cpk = pmin((USL - mean) / (3 * sd), (mean - LSL) / (3 * sd)))
cat("\n=== PROCESS CAPABILITY (Cp & Cpk) ===\n")
print(as.data.frame(capability |> mutate(across(where(is.numeric), \(x) round(x, 3)))))
write.csv(capability, file.path(out, "tbl_capability.csv"), row.names = FALSE)

# --- uji normalitas pengukuran Diameter ---
diam <- d$Pengukuran[d$Karakteristik == "Diameter"]
sw <- shapiro.test(diam)
cat(sprintf("\nShapiro-Wilk (Diameter): W = %.4f, p = %.4f\n", sw$statistic, sw$p.value))

# --- uji t: subgroup bergeser (18-21) vs normal ---
diam_peta <- peta |> filter(Karakteristik == "Diameter") |>
  mutate(Periode = ifelse(Subgroup %in% 18:21, "Bergeser", "Normal"))
tt <- t.test(Xbar ~ Periode, data = diam_peta, var.equal = TRUE)
cat(sprintf("Uji t subgroup bergeser vs normal: t = %.2f, p = %.3g, selisih = %.3f\n",
            tt$statistic, tt$p.value, diff(rev(tt$estimate))))
write.csv(diam_peta, file.path(out, "tbl_uji_geser.csv"), row.names = FALSE)

# --- uji varians: apakah proses stabil antar shift? ---
cat("\n=== Rata-rata pengukuran per shift (Diameter) ===\n")
print(as.data.frame(d |> filter(Karakteristik == "Diameter") |> group_by(Shift) |>
  summarise(mean = round(mean(Pengukuran), 3), sd = round(sd(Pengukuran), 4),
            n = n(), .groups = "drop")))
print(broom::tidy(aov(Pengukuran ~ Shift, data = filter(d, Karakteristik == "Diameter"))))

# --- ringkasan judgment ---
cat("\n=== RINGKASAN ===\n")
cat(sprintf("Cpk terendah : %.2f (%s)\n",
            min(capability$Cpk), capability$Karakteristik[which.min(capability$Cpk)]))
cat(sprintf("Titik out-of-control : %d dari %d subgroup\n",
            sum(peta$OutOfControl), nrow(peta)))
cat("Karakteristik dengan Cp<1.33:", paste(capability$Karakteristik[capability$Cp < 1.33], collapse = ", "), "\n")
saveRDS(list(peta = peta, capability = capability, spek = spek, sw = sw, tt = tt),
        file.path(out, "hasil_opsi2.rds"))
