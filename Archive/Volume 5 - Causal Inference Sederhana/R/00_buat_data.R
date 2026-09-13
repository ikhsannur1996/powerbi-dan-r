set.seed(20260601)
# Desain sengaja sederhana: 40 operator x 2 periode = 80 baris
# Cerita: 20 operator ikut PELATIHAN (treatment), 20 tidak (kontrol).
# Jebakan: yang dilatih awalnya memang lebih buruk (seleksi tidak acak),
# jadi perbandingan "sesudah saja" menipu. DiD memperbaikinya.

ops_treat <- paste0("OP-T", sprintf("%02d", 1:20))
ops_ctrl  <- paste0("OP-C", sprintf("%02d", 1:20))

buat <- function(ops, dilatih) {
  skill <- rnorm(length(ops), 0, 0.4)  # kemampuan dasar tiap operator
  base  <- ifelse(dilatih == "Ya", 4.0, 3.0)  # grup latih mulai lebih buruk
  sebelum <- round(base + skill + rnorm(length(ops), 0, 0.3), 2)
  # efek kausal SEBENARNYA dari pelatihan: -1.5 poin defect
  sesudah <- round(sebelum + rnorm(length(ops), -0.1, 0.3) +
    ifelse(dilatih == "Ya", -1.5, 0), 2)
  sesudah <- pmax(sesudah, 0.5)
  data.frame(
    Operator = rep(ops, 2),
    Dilatih = dilatih,
    Periode = rep(c("Sebelum", "Sesudah"), each = length(ops)),
    DefectRate = c(sebelum, sesudah),
    Produksi = round(rnorm(2 * length(ops), 350, 25))
  )
}

df <- rbind(buat(ops_treat, "Ya"), buat(ops_ctrl, "Tidak"))
df$Periode <- factor(df$Periode, levels = c("Sebelum", "Sesudah"))

# Path relatif terhadap root repo "Power BI dan R" agar portabel
ROOT <- "Archive/Volume 5 - Causal Inference Sederhana"
base_dir <- file.path(ROOT, "data")
if (!dir.exists(base_dir)) dir.create(base_dir, recursive = TRUE)
write.csv(df, file.path(base_dir, "causal_simple.csv"), row.names = FALSE)
cat("baris:", nrow(df), " kolom:", ncol(df), "\n")
print(aggregate(DefectRate ~ Dilatih + Periode, df, mean))

