# ============================================================
# Opsi 2 - Pengendalian Kualitas Statistik (SPC)
# R/00_buat_data.R  --  generator data (reproducible, set.seed)
# ============================================================
# Output:
#   data/qc_karakteristik.csv  (1 baris = 1 unit terukur, dengan subgroup)
#   data/spesifikasi.csv       (dimensi spesifikasi per karakteristik)
# Pola sengaja ditanam supaya SPC "menemukan" sesuatu.
# ============================================================

set.seed(20260902)

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
dir.create(file.path(base, "data"), showWarnings = FALSE)

# --- 3 karakteristik mutu yang diukur ---
karakteristik <- c("Diameter", "Berat", "Kekerasan")
target <- c(Diameter = 25.00, Berat = 120.0, Kekerasan = 60.0)
sd_proses <- c(Diameter = 0.08, Berat = 0.9, Kekerasan = 1.4)

# --- 25 subgroup x 5 sampel (n=5) per karakteristik ---
n_sub <- 25; n_sampel <- 5
sub <- rep(1:n_sub, each = n_sampel)

d <- do.call(rbind, lapply(karakteristik, function(k) {
  # Pola ditanam: subgroup 18-21 (shift malam) bergeser (out-of-control)
  geser <- ifelse(sub >= 18 & sub <= 21, c(Diameter = 0.10, Berat = 1.1, Kekerasan = 1.6)[k], 0)
  nilai <- target[k] + geser + rnorm(n_sub * n_sampel, 0, sd_proses[k])
  data.frame(
    Karakteristik = k,
    Subgroup      = sub,
    Sampel        = rep(1:n_sampel, n_sub),
    Pengukuran    = round(nilai, 3),
    Shift         = rep(rep(c("Pagi", "Sore", "Malam"), length.out = n_sub), each = n_sampel),
    Mesin         = rep(rep(c("M-01", "M-02", "M-03"), length.out = n_sub), each = n_sampel),
    stringsAsFactors = FALSE
  )
}))
write.csv(d, file.path(base, "data", "qc_karakteristik.csv"), row.names = FALSE)

# --- spesifikasi (USL / LSL) ---
spek <- data.frame(
  Karakteristik = karakteristik,
  LSL = c(24.80, 118.0, 57.0),
  Target = target,
  USL = c(25.20, 122.0, 63.0)
)
write.csv(spek, file.path(base, "data", "spesifikasi.csv"), row.names = FALSE)

# --- ringkasan ---
cat("qc_karakteristik.csv :", nrow(d), "baris x", ncol(d), "kolom\n")
cat("spesifikasi.csv      :", nrow(spek), "baris x", ncol(spek), "kolom\n\n")
cat("Rata-rata & SD per karakteristik:\n")
print(round(do.call(rbind, lapply(karakteristik, function(k) {
  x <- d$Pengukuran[d$Karakteristik == k]
  c(mean = mean(x), sd = sd(x))
})), 3))
cat("\nRentang subgroup bergeser (18-21) vs normal:\n")
print(round(tapply(d$Pengukuran[d$Karakteristik == "Diameter"],
                   ifelse(sub[d$Karakteristik == "Diameter"] %in% 18:21, "Geser", "Normal"),
                   mean), 3))
print(head(d, 3))
