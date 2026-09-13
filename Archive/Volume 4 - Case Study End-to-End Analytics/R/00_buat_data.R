set.seed(20260401)
base <- "/Users/ikhsannur1996/Documents/Power BI dan R/Archive/Volume 4 - Case Study End-to-End Analytics/data"

tgl <- seq(as.Date("2026-01-02"), as.Date("2026-06-30"), by = "day")
tgl <- tgl[format(tgl, "%u") != "7"]  # libur tiap Minggu

shifts <- c("Pagi", "Siang", "Malam")
lini   <- c("Line-A", "Line-B")
ops    <- paste0("OP", sprintf("%02d", 1:8))
produk <- c("Bracket", "Housing", "Shaft")

ef_op <- setNames(c(0.6, 0.8, 1.0, 1.3, 0.9, 1.6, 1.1, 0.7), ops)
ef_ms <- setNames(c(1.0, 1.4, 0.8, 1.2), c("M-01", "M-02", "M-03", "M-04"))
ef_pr <- setNames(c(420, 350, 300), produk)

df <- expand.grid(Tanggal = tgl, Shift = shifts, Line = lini, stringsAsFactors = FALSE)
n <- nrow(df)
df$Operator <- sample(ops, n, replace = TRUE)
df$Mesin <- ifelse(df$Line == "Line-A",
  sample(c("M-01", "M-02"), n, TRUE), sample(c("M-03", "M-04"), n, TRUE))
df$Produk <- sample(produk, n, replace = TRUE, prob = c(0.4, 0.35, 0.25))

base_out <- as.numeric(ef_pr[df$Produk]) * ifelse(df$Shift == "Malam", 0.9, 1)
base_out <- base_out * rnorm(n, 1, 0.08)
df$TargetProduksi <- round(base_out)
df$AktualProduksi <- round(base_out * rnorm(n, 0.97, 0.06))
df$AktualProduksi <- pmax(df$AktualProduksi, 150)

rate <- 0.02 * as.numeric(ef_op[df$Operator]) * as.numeric(ef_ms[df$Mesin]) *
  ifelse(df$Shift == "Malam", 1.25, 1)
rate <- rate * rlnorm(n, 0, 0.25)
df$JumlahCacat <- rbinom(n, df$AktualProduksi, pmin(rate, 0.12))

df$DowntimeMenit <- round(rexp(n, 1 / 18) + ifelse(df$Mesin %in% c("M-02", "M-04"), 8, 0))
df$CycleTimeDetik <- round(rnorm(n, 45, 5) +
  ifelse(df$Produk == "Shaft", 8, 0) + ifelse(df$Shift == "Malam", 2, 0), 1)
df$ProductionID <- sprintf("PRD-%05d", seq_len(n))
df <- df[, c("ProductionID", "Tanggal", "Shift", "Line", "Operator", "Mesin",
  "Produk", "TargetProduksi", "AktualProduksi", "JumlahCacat",
  "DowntimeMenit", "CycleTimeDetik")]
write.csv(df, file.path(base, "produksi.csv"), row.names = FALSE)
cat("baris:", nrow(df), " kolom:", ncol(df), "\n")
print(head(df, 3))
