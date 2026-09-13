# ============================================================
# R/03_validasi.R  --  VALIDACIA end-to-end (lokal, tanpa Power BI)
# ------------------------------------------------------------
# Skrip ini menjalankan kode R yang SAMA PERSIS dengan blok yang
# ditempel di Power BI:
#   * BLOK_PQ_01  (Power Query -> tabel ramalan)
#   * BLOK_RV_V1..V8 (R visual -> 8 gambar ggplot2)
# Hasil: output/ramalan.csv + output/V*.png (pratinjau)
# ============================================================

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
out  <- file.path(base, "output"); dir.create(out, showWarnings = FALSE)
setwd(base)

extr <- function(path, tag) {
  txt <- readLines(path, warn = FALSE)
  a <- grep(sprintf("# >>> %s_START", tag), txt)
  b <- grep(sprintf("# >>> %s_END",   tag), txt)
  if (!length(a) || !length(b)) stop("Blok ", tag, " tidak ditempuh di ", path)
  paste(txt[(a[1] + 1):(b[1] - 1)], collapse = "\n")
}

jalan <- function(blok, env, tag) {
  tryCatch({
    res <- eval(parse(text = blok), env)
    if (is.null(res)) stop("Blok ", tag, " tidak menghasilkan objek")
    res
  }, error = function(e) {
    stop("ERROR di blok ", tag, ": ", conditionMessage(e))
  })
}

# ---------- 1. simulasii gabungan Power Query (permintaan + produk) ----------
suppressMessages({ library(dplyr); library(tidyr) })

permintaan <- read.csv(file.path(base, "data", "permintaan.csv"))
produk     <- read.csv(file.path(base, "data", "produk.csv"))

dataset <- permintaan |>
  left_join(produk, by = "Produk")

# ---------- 2. BLOK_PQ_01 -> tabel ramalan ----------
ens <- new.env()
assign("dataset", dataset, envir = ens)
ramalan <- jalan(extr("R/powerquery_01_ramalan.R", "BLOK_PQ_01"), ens, "BLOK_PQ_01")
write.csv(ramalan, file.path(out, "ramalan.csv"), row.names = FALSE)

# ---------- 3. BLOK_RV_* -> 8 gambar ggplot2 ----------
suppressMessages({ library(ggplot2); library(scales) })

dim <- list(V1 = c(9, 4.0), V2 = c(9, 4.6), V3 = c(8, 4.0),
            V4 = c(9, 4.0), V5 = c(8, 4.0), V6 = c(9, 3.2),
            V7 = c(8, 4.0), V8 = c(9, 4.0))
naam <- c(V1 = "kpi", V2 = "tren", V3 = "planbulan", V4 = "cek",
          V5 = "angkabulan", V6 = "heatmap", V7 = "kapasitas", V8 = "whatif")

for (nm in names(dim)) {
  tag  <- paste0("BLOK_RV_", nm)
  ensv <- new.env()
  assign("dataset", ramalan, envir = ensv)
  p <- jalan(extr("R/visual_R_powerbi.R", tag), ensv, tag)
  fname <- file.path(out, sprintf("V%s_%s.png", substring(nm, 2), naam[[nm]]))
  ggsave(fname, p, width = dim[[nm]][1], height = dim[[nm]][2],
         dpi = 150, bg = "white")
  cat("Dirender:", fname, "\n")
}

# ---------- 4. Ringkasan angka (untuk dokumentasi) ----------
cat("\n=== RINGKASAN VALIDACION ===\n")
cat("riwayat rows :", nrow(distinct(ramalan |> filter(Jenis == "Riwayat") |> select(Tanggal, Produk))), "\n")
cat("plan rows    :", nrow(distinct(ramalan |> filter(Jenis == "Plan") |> select(Tanggal, Produk))), "\n")
cat("total baris  :", nrow(ramalan), "(x3 skenario)\n")

hist <- ramalan |> filter(Jenis == "Riwayat") |> distinct(Tanggal, Produk, Permintaan)
pln  <- ramalan |> filter(Jenis == "Plan") |>
  distinct(Tanggal, Produk, Skenario, FaktorSkenario, Plan, HargaSatuan, KapasitasMesin) |>
  mutate(Hasil = Plan * FaktorSkenario)

cat(sprintf("Total riwayat 2024-25 : %s unit\n",
            format(sum(hist$Permintaan), big.mark = ".", decimal.mark = ",")))
cat("Plan 2026 per skenario:\n")
print(pln |> group_by(Skenario) |>
        summarise(Unit = sum(Hasil), Rp = sum(Hasil * HargaSatuan), .groups = "drop") |>
        mutate(Unit = format(round(Unit), big.mark = ".", decimal.mark = ","),
               Rp   = format(round(Rp),   big.mark = ".", decimal.mark = ",")))

cat("\nCek plan (Jul-Des 2025): rata-rata selisih per produk\n")
cek <- ramalan |> filter(!is.na(CekPlan)) |>
  distinct(Tanggal, Produk, Permintaan, CekPlan) |>
  group_by(Produk) |>
  summarise(SelisihPct = round(mean(abs(Permintaan - CekPlan) / Permintaan) * 100, 1),
            .groups = "drop")
print(cek |> as.data.frame())

cat("\nKebutuhan mesin (plan puncak Jan-Jun 2026):\n")
print(pln |> group_by(Produk, Skenario, KapasitasMesin) |>
        summarise(Puncak = round(max(Hasil)), .groups = "drop") |>
        mutate(Keb = ceiling(Puncak / KapasitasMesin)) |>
        as.data.frame())

cat("\nPlan Bulan Depan (Jan 2026) per produk:\n")
print(pln |>
        filter(as.integer(format(Tanggal, "%m")) == 1, Skenario == "Normal") |>
        transmute(Produk, Plan = round(Plan)) |>
        as.data.frame())

cat("\nValidacion selesai. File diproduksi di output/.\n")