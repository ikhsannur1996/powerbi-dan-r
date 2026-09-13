# ============================================================
# Opsi 5 - Persediaan & Safety Stock
# R/00_buat_data.R  --  generator data (reproducible, set.seed)
# ============================================================
# Output:
#   data/persediaan.csv   (fakta: permintaan harian + simulasi stok)
#   data/produk.csv       (dimensi: harga, lead time, kategori, target)
# Pola sengaja ditanam:
#   - Produk Premium (P-01 & P-02)  : permintaan overdispersed + lead time
#     lengkap yang variabil, tetapi policy perusahaan hanya 5 hari cover
#     -> stockout frekuent (service level < target 98%).
#   - Produk Mass (P-05 & P-06)     : permintaan stabil + lead time kort,
#     perusahaan menyimpan 30 hari cover -> overstock, tanpa stockout.
#   - Produk Standar (P-03 & P-04)  : permintaan musiman - puncak
#     end-of-quarter (Mar/Jun/Sep/Des) -> uji musiman statistik.
# ============================================================

set.seed(20260905)

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
dir.create(file.path(base, "data"), showWarnings = FALSE)

# ------------------------------------------------------------
# 1. DIMENSI PRODUK
# ------------------------------------------------------------
produk <- data.frame(
  Produk     = c("P-01", "P-02", "P-03", "P-04", "P-05", "P-06"),
  NamaProduk = c("Bearing Assembly", "Hydraulic Valve", "Seal Kit",
                 "Filter Element", "O-Ring", "Wiper Blade"),
  Kategori   = c("Premium", "Premium", "Standar", "Standar", "Mass", "Mass"),
  HargaUnit  = c(850, 620, 180, 95, 12, 8),           # nilai per unit
  LT_Rata    = c(12, 10, 7, 6, 4, 3),                 # lead time rata (hari)
  LT_SD      = c(5, 4, 3, 2, 1, 1),                   # sd lead time (hari)
  TargetSL   = c(0.98, 0.98, 0.95, 0.95, 0.90, 0.90)  # target service level
)
write.csv(produk, file.path(base, "data", "produk.csv"), row.names = FALSE)
# ------------------------------------------------------------
# 2. PERMINTAAN HARIAN  (6 hari/semain; Minggu libur)
# ------------------------------------------------------------
tgl  <- seq(as.Date("2025-01-01"), as.Date("2026-06-30"), by = "day")
tgl  <- tgl[format(tgl, "%u") != "7"]          # libur tiap Minggu
n    <- length(tgl)
wday <- as.integer(format(tgl, "%u"))          # 1=Senin ... 6=Sabtu
bln  <- as.integer(format(tgl, "%m"))

mu_d <- c(`P-01` = 6, `P-02` = 9, `P-03` = 30, `P-04` = 40,
          `P-05` = 55, `P-06` = 65)            # rata-rata permintaan harian

# puncak end-of-quarter (Mar / Jun / Sep / Des) untuk produk Standar
seas <- ifelse(bln %in% c(3, 6, 9, 12), 1.9, 1.0)

perm <- do.call(rbind, lapply(produk$Produk, function(p) {
  mu <- mu_d[p]
  if (p %in% c("P-01", "P-02"))
    dmd <- rnbinom(n, size = 2.0, mu = mu)           # overdispersed (CV ~0,8)
  else if (p %in% c("P-03", "P-04"))
    dmd <- rpois(n, mu * seas)                        # musiman
  else
    dmd <- round(pmax(0, rnorm(n, mu, mu * 0.12)))    # stabil
  data.frame(Tanggal = tgl, Produk = p,
             Permintaan = as.integer(dmd), stringsAsFactors = FALSE)
}))
perm <- perm[order(perm$Tanggal, perm$Produk), ]
# ------------------------------------------------------------
# 3. SIMULASI STOK - POLICY PERUSAHAAN (s, Q)
#    review tiap Sabtu; bila stok <= reorder point (rop) -> order lot Q
#    rop = mu*LT + SS_company ; Q = permintaan 1 semain
#    SS_company = cover_days x permintaan rata
#    Premium=5 hari, Standar=8 hari, Mass=30 hari  <- misalokasi
# ------------------------------------------------------------
cover <- c(Premium = 5, Standar = 8, Mass = 30)

sim <- do.call(rbind, lapply(produk$Produk, function(p) {
  mu    <- mu_d[p]
  lt_r  <- produk$LT_Rata[produk$Produk == p]
  lt_s  <- produk$LT_SD[produk$Produk == p]
  SS    <- cover[produk$Kategori[produk$Produk == p]] * mu
  Q     <- ceiling(7 * mu)                  # lot order = 1 semain permintaan
  rop   <- mu * lt_r + SS                   # reorder point (policy naif)
  stock <- rop + Q                          # stok awal
  pend  <- list()                           # [[idx_tiba, qty], ...]

  dmd_p <- perm$Permintaan[perm$Produk == p]
  out <- data.frame(Tanggal = as.Date(tgl), Produk = p,
                    Permintaan = dmd_p, Aterpen = 0L,
                    StokBegint = 0L, StokEnd = 0L,
                    Stockout = 0L, Defisit = 0L, stringsAsFactors = FALSE)

  for (i in seq_len(n)) {
    ater <- 0L
    if (length(pend)) {                    # aterpen yang tiba hari ini
      due <- vapply(pend, function(x) x[1] == i, logical(1))
      if (any(due)) {
        ater  <- sum(vapply(pend[due], function(x) x[2], integer(1)))
        stock <- stock + ater
      }
      pend <- pend[!due]
    }
    begin <- stock
    miss  <- max(0L, dmd_p[i] - stock)
    stock <- max(0L, stock - dmd_p[i])

    out$Aterpen[i]    <- ater
    out$StokBegint[i] <- begin
    out$StokEnd[i]    <- stock
    out$Stockout[i]   <- as.integer(miss > 0L)
    out$Defisit[i]    <- miss

    if (wday[i] == 6L && stock <= rop) {   # review tiap Sabtu
      lt  <- max(1L, round(rlnorm(1, log(lt_r), log(1 + lt_s / lt_r))))
      arr <- as.integer(i + lt)
      if (arr <= n) pend[[length(pend) + 1L]] <- c(arr, as.integer(Q))
    }
  }
  out
}))
sim <- sim[order(sim$Tanggal, sim$Produk), ]
write.csv(sim, file.path(base, "data", "persediaan.csv"), row.names = FALSE)
# ------------------------------------------------------------
# 4. RINGKASAN GENERTA
# ------------------------------------------------------------
cat("persediaan.csv :", nrow(sim), "baris x", ncol(sim), "kolom\n")
cat("produk.csv     :", nrow(produk), "baris x", ncol(produk), "kolom\n\n")

cat("Rata-rata permintaan harian per produk:\n")
print(round(tapply(sim$Permintaan, sim$Produk, mean), 1))
cat("\nStockout days per produk (company policy saat ini):\n")
print(tapply(sim$Stockout, sim$Produk, sum))
cat("\nDefisit total per produk (unit tak terfulfil):\n")
print(tapply(sim$Defisit, sim$Produk, sum))
cat("\nStokEnd rata-rata per produk:\n")
print(round(tapply(sim$StokEnd, sim$Produk, mean), 0))
print(head(sim, 3))