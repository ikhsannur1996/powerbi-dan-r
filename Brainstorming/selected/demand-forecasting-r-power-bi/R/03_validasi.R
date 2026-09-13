# ============================================================
# R/03_validasi.R  —  VALIDASI end-to-end (lokal, tanpa Power BI)
#
# Skrip ini membaca CSV, meniru penggabungan Power Query,
# menjalankan blok BLOK_PQ_01 (transformasi) dan BLOK_RV_V1..V8 (visual),
# lalu mencetak semua angka kunci untuk README.
#
# Jalankan:  Rscript R/03_validasi.R
# ============================================================

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
out  <- file.path(base, "output")
dir.create(out, showWarnings = FALSE)
setwd(base)

# --- ambil blok kode dari file lalu jalankan ---
extr <- function(path, tag) {
  txt <- readLines(path, warn = FALSE)
  a <- grep(sprintf("# >>> %s_START", tag), txt)
  b <- grep(sprintf("# >>> %s_END",   tag), txt)
  if (!length(a) || !length(b)) stop("Blok ", tag, " tidak ditemukan di ", path)
  paste(txt[(a[1] + 1):(b[1] - 1)], collapse = "\n")
}

jalan <- function(blok, env, tag) {
  tryCatch({
    res <- eval(parse(text = blok), env)
    if (is.null(res)) stop("Blok ", tag, " tidak menghasilkan apa pun")
    res
  }, error = function(e) stop("ERROR di blok ", tag, ": ", conditionMessage(e)))
}

suppressMessages({ library(dplyr); library(tidyr) })

# --- 1. tiru penggabungan Power Query (Merge Queries) ---
permintaan <- read.csv(file.path("data", "permintaan.csv"))
produk     <- read.csv(file.path("data", "produk.csv"))
lokasi     <- read.csv(file.path("data", "lokasi.csv"))

dataset <- permintaan |>
  left_join(produk, by = "SKU") |>
  left_join(lokasi, by = "Lokasi")

cat("dataset Power Query :", nrow(dataset), "baris x", ncol(dataset), "kolom\n")

# --- 2. BLOK_PQ_01 -> tabel ramalan ---
ens <- new.env()
assign("dataset", dataset, envir = ens)
ramalan <- jalan(extr("R/01_transformasi.R", "BLOK_PQ_01"), ens, "BLOK_PQ_01")
write.csv(ramalan, file.path(out, "ramalan.csv"), row.names = FALSE)
cat("ramalan.csv         :", nrow(ramalan), "baris\n\n")

# --- 3. BLOK_RV_V1..V8 -> 8 PNG ---
suppressMessages({ library(ggplot2); library(scales) })
dim  <- list(V1 = c(9.0, 4.8), V2 = c(9.0, 4.6), V3 = c(9.0, 3.4), V4 = c(9.0, 3.6),
             V5 = c(8.6, 4.6), V6 = c(9.0, 4.4), V7 = c(9.0, 4.4), V8 = c(9.0, 4.2),
             V9 = c(9.0, 4.4), V10 = c(9.0, 4.4))
naam <- c(V1 = "kpi", V2 = "boxplot_tahunan", V3 = "lollipop_planbulan",
          V4 = "dumbbell_kapasitas", V5 = "radial_angkabulan", V6 = "violin_ukuran",
          V7 = "slope_pangsa_ukuran", V8 = "peta_ukuran_packing",
          V9 = "tren_loess", V10 = "musiman_overlay")

for (nm in names(dim)) {
  tag  <- paste0("BLOK_RV_", nm)
  ensv <- new.env()
  assign("dataset", ramalan, envir = ensv)
  p <- jalan(extr("R/02_visual.R", tag), ensv, tag)
  fname <- file.path(out, sprintf("V%s_%s.png", substring(nm, 2), naam[[nm]]))
  ggsave(fname, p, width = dim[[nm]][1], height = dim[[nm]][2],
         dpi = 150, bg = "white")
  cat("Rendered:", basename(fname), "\n")
}

# --- 4. angka kunci untuk README & business case ------------------------
frmt <- function(x) format(round(x), big.mark = ".", decimal.mark = ",")
miliar <- function(x) paste0("Rp ", formatC(round(x / 1e9, 2), format = "f",
                                            digits = 2, decimal.mark = ","), " miliar")

hist <- ramalan |>
  filter(Jenis == "Riwayat", Skenario == "Normal") |>
  mutate(Tahun = as.integer(format(Tanggal, "%Y")),
         BulanKe = as.integer(format(Tanggal, "%m")))

plan_all <- ramalan |>
  filter(Jenis == "Plan")

cat("\n=== A. UKURAN DATA ===\n")
cat("Riwayat   :", nrow(hist), "baris = 36 bulan x 2 pabrik x 16 SKU\n")
cat("Plan      :", nrow(plan_all |> distinct(Tanggal, SKU, Lokasi)), "baris",
    "= 6 bulan x 2 pabrik x 16 SKU\n")
cat("Total baris tabel ramalan :", nrow(ramalan), "\n")

cat("\n=== A2. OUTLIER DI DATA MENTAH (data/permintaan.csv) ===\n")
perm <- read.csv(file.path("data", "permintaan.csv"))
outl <- perm |>
  group_by(SKU) |>
  mutate(Tengah = median(Permintaan), Simpangan = mad(Permintaan)) |>
  filter(Simpangan > 0, abs(Permintaan - Tengah) > 3 * Simpangan) |>
  ungroup()
cat("Rentang unit per baris :", min(perm$Permintaan), "s/d", max(perm$Permintaan), "unit\n")
cat("Outlier (|x - median SKU| > 3 x MAD) :", nrow(outl),
    sprintf("baris (%.1f%%)\n", nrow(outl) / nrow(perm) * 100))
cat("Contoh 3 outlier terbesar:\n")
print(outl |>
        arrange(desc(abs(Permintaan - Tengah))) |>
        head(3) |>
        select(Tanggal, SKU, Lokasi, Permintaan, Tengah) |>
        as.data.frame())
cat("Catatan: karena ada outlier, metode memakai MEDIAN (bukan rata-rata)\n")

cat("\n=== B. PENJUALAN PER PRODUK PER TAHUN ===\n")
print(hist |>
        group_by(Produk, Tahun) |>
        summarise(Unit = frmt(sum(Permintaan)),
                   Rp = miliar(sum(Permintaan * HargaSatuan)),
                  .groups = "drop") |>
        as.data.frame())

cat("\nPertumbuhan YoY per produk (%):\n")
print(hist |>
        group_by(Produk, Tahun) |>
        summarise(Unit = sum(Permintaan), .groups = "drop") |>
        group_by(Produk) |>
        summarise(`2024 vs 2023` = round((Unit[Tahun == 2024] / Unit[Tahun == 2023] - 1) * 100, 1),
                  `2025 vs 2024` = round((Unit[Tahun == 2025] / Unit[Tahun == 2024] - 1) * 100, 1),
                  .groups = "drop") |>
        as.data.frame())

cat("\nTotal riwayat 3 tahun :", frmt(sum(hist$Permintaan)), "unit\n")
cat("Total nilai 3 tahun   : Rp", format(round(sum(hist$Permintaan * hist$HargaSatuan) / 1e9, 2),
                                         decimal.mark = ","), "miliar\n")

cat("\n=== C. MIX UKURAN (Besar / Sedang / Kecil) ===\n")
cat("Total unit per ukuran:\n")
print(hist |>
        group_by(Produk, Ukuran, UrutanUkuran) |>
        summarise(Unit = sum(Permintaan), .groups = "drop") |>
        arrange(Produk, UrutanUkuran) |>
        mutate(Unit = frmt(Unit)) |>
        as.data.frame())

cat("\nPangsa ukuran per tahun (%):\n")
print(hist |>
        group_by(Produk, Tahun, Ukuran, UrutanUkuran) |>
        summarise(Unit = sum(Permintaan), .groups = "drop") |>
        group_by(Produk, Tahun) |>
        mutate(Pangsa = round(Unit / sum(Unit) * 100, 1)) |>
        ungroup() |>
        select(Produk, Ukuran, UrutanUkuran, Tahun, Pangsa) |>
        tidyr::pivot_wider(names_from = Tahun, values_from = Pangsa,
                           names_prefix = "Th") |>
        arrange(Produk, UrutanUkuran) |>
        as.data.frame())

cat("\n=== D. MIX JENIS PACKING ===\n")
print(hist |>
        group_by(Produk, JenisPacking, Tahun) |>
        summarise(Unit = sum(Permintaan), .groups = "drop") |>
        group_by(Produk, Tahun) |>
        mutate(Pangsa = round(Unit / sum(Unit) * 100, 1)) |>
        ungroup() |>
        select(Produk, JenisPacking, Tahun, Pangsa) |>
        tidyr::pivot_wider(names_from = Tahun, values_from = Pangsa,
                           names_prefix = "Th") |>
        as.data.frame())

cat("\n=== E. TOTAL PER LOKASI (3 tahun) ===\n")
print(hist |>
        group_by(Lokasi) |>
        summarise(Unit = frmt(sum(Permintaan)), .groups = "drop") |>
        as.data.frame())

cat("\n=== F. PLAN 2026 PER SKENARIO ===\n")
print(ramalan |>
        filter(Jenis == "Plan") |>
        group_by(Skenario) |>
        summarise(Unit = frmt(sum(Plan)), .groups = "drop") |>
        as.data.frame())

cat("\n=== G. KEBUTUHAN MESIN (puncak per bulan) ===\n")
print(ramalan |>
        filter(Jenis == "Plan") |>
        group_by(Skenario, Produk, Lokasi, KapasitasMesin, Tanggal) |>
        summarise(Bulan = sum(Plan), .groups = "drop") |>
        group_by(Skenario, Produk, Lokasi, KapasitasMesin) |>
        summarise(Puncak = round(max(Bulan)), .groups = "drop") |>
        mutate(Mesin = ceiling(Puncak / KapasitasMesin)) |>
        arrange(Skenario, Produk, Lokasi) |>
        as.data.frame())

cat("\n=== H. PLAN JANUARI 2026 (semua skenario) ===\n")
cat("Per ukuran:\n")
print(ramalan |>
        filter(Jenis == "Plan", Tanggal == as.Date("2026-01-01")) |>
        group_by(Produk, Ukuran, UrutanUkuran, Skenario) |>
        summarise(Unit = round(sum(Plan)), .groups = "drop") |>
        arrange(Produk, UrutanUkuran) |>
        tidyr::pivot_wider(names_from = Skenario, values_from = Unit) |>
        as.data.frame())

cat("\nPer jenis packing:\n")
print(ramalan |>
        filter(Jenis == "Plan", Tanggal == as.Date("2026-01-01")) |>
        group_by(Produk, JenisPacking, Skenario) |>
        summarise(Unit = round(sum(Plan)), .groups = "drop") |>
        tidyr::pivot_wider(names_from = Skenario, values_from = Unit) |>
        as.data.frame())

cat("\n=== I. UJI KEPERCAYAAN METODE (back-test) ===\n")
bt <- hist |>
  arrange(SKU, Lokasi, Tanggal) |>
  group_by(SKU, Lokasi) |>
  mutate(Tengah   = median(Permintaan),
         Simpangan = mad(Permintaan),
         Ekstrem  = Simpangan > 0 & abs(Permintaan - Tengah) > 3 * Simpangan,
         Media3   = (lag(Permintaan, 1) + lag(Permintaan, 2) + lag(Permintaan, 3)) / 3,
         Tengah3  = apply(cbind(lag(Permintaan, 1), lag(Permintaan, 2),
                                lag(Permintaan, 3)), 1, median, na.rm = TRUE)) |>
  ungroup() |>
  filter(BulanKe >= 7) |>
  mutate(CekMedian = Tengah3 * AngkaBulan,
         CekMean   = Media3  * AngkaBulan) |>
  filter(!is.na(CekMedian), !is.na(CekMean))

ringkas_bt <- function(z, label) {
  z |>
    group_by(Produk) |>
    summarise(`Median (%)`    = round(mean(abs(Permintaan - CekMedian) / Permintaan) * 100, 1),
              `Rata-rata (%)` = round(mean(abs(Permintaan - CekMean)   / Permintaan) * 100, 1),
              .groups = "drop") |>
    mutate(Cakupan = label, .before = 1)
}
print(bind_rows(ringkas_bt(bt, "semua bulan"),
                ringkas_bt(filter(bt, !Ekstrem), "tanpa bulan ekstrem")) |>
        as.data.frame())
cat("Bulan ekstrem   :", sum(bt$Ekstrem), "dari", nrow(bt), "baris uji\n")
cat("Catatan: median lebih tahan terhadap outlier daripada rata-rata.\n")

cat("\n=== J. ANGKA BULAN (Jan & Des) ===\n")
print(ramalan |>
        filter(BulanKe %in% c(1, 12)) |>
        distinct(Produk, BulanKe, AngkaBulan) |>
        arrange(Produk, BulanKe) |>
        mutate(AngkaBulan = round(AngkaBulan, 2)) |>
        as.data.frame())

cat("\n=== K. TOP 5 SKU PADA PLAN 2026 (Normal) ===\n")
print(ramalan |>
        filter(Jenis == "Plan", Skenario == "Normal") |>
        group_by(SKU, Rasa, Ukuran, JenisPacking) |>
        summarise(Unit = round(sum(Plan)), .groups = "drop") |>
        arrange(desc(Unit)) |>
        head(5) |>
        as.data.frame())

cat("\n=== L. DAMPAK FINANSIAL (sudut pandang Business Analyst) ===\n")
cat("L.1 Pertumbuhan unit vs nilai (Rp):\n")
print(hist |>
        group_by(Tahun) |>
        summarise(Unit = frmt(sum(Permintaan)),
                  Rp   = miliar(sum(Permintaan * HargaSatuan)),
                  ASP  = frmt(sum(Permintaan * HargaSatuan) / sum(Permintaan)),
                  .groups = "drop") |>
        as.data.frame())

cat("\nL.2 Laju pertumbuhan (%):\n")
print(hist |>
        group_by(Tahun) |>
        summarise(Unit = sum(Permintaan), Rp = sum(Permintaan * HargaSatuan), .groups = "drop") |>
        mutate(`Unit tumbuh` = round((Unit / lag(Unit) - 1) * 100, 1),
               `Rp tumbuh`   = round((Rp / lag(Rp) - 1) * 100, 1)) |>
        filter(Tahun >= 2024) |>
        select(Tahun, `Unit tumbuh`, `Rp tumbuh`) |>
        as.data.frame())

cat("\nL.3 Pangsa NILAI (Rp) per ukuran pada 2025 (%):\n")
print(hist |>
        filter(Tahun == 2025) |>
        group_by(Produk, Ukuran, UrutanUkuran) |>
        summarise(Rp = sum(Permintaan * HargaSatuan), .groups = "drop") |>
        group_by(Produk) |>
        mutate(`Pangsa nilai` = round(Rp / sum(Rp) * 100, 1)) |>
        ungroup() |>
        arrange(Produk, UrutanUkuran) |>
        select(Produk, Ukuran, `Pangsa nilai`) |>
        as.data.frame())

cat("\nL.4 Pangsa NILAI (Rp) per jenis packing pada 2025 (%):\n")
print(hist |>
        filter(Tahun == 2025) |>
        group_by(Produk, JenisPacking) |>
        summarise(Rp = sum(Permintaan * HargaSatuan), .groups = "drop") |>
        group_by(Produk) |>
        mutate(`Pangsa nilai` = round(Rp / sum(Rp) * 100, 1)) |>
        ungroup() |>
        select(Produk, JenisPacking, `Pangsa nilai`) |>
        as.data.frame())

cat("\nL.5 Dampak pergeseran mix ukuran & packing pada nilai 2025:\n")
cat("(simulasi: bila pangsa tiap SKU pada 2025 masih sama seperti 2023)\n")
mix <- hist |>
  filter(Tahun %in% c(2023, 2025)) |>
  group_by(Tahun, Produk, SKU, HargaSatuan) |>
  summarise(Unit = sum(Permintaan), .groups = "drop")
tot25 <- mix |> filter(Tahun == 2025) |>
  group_by(Produk) |> summarise(Total = sum(Unit), .groups = "drop")
sim <- mix |> filter(Tahun == 2023) |>
  group_by(Produk, SKU, HargaSatuan) |>
  summarise(Unit = sum(Unit), .groups = "drop") |>
  group_by(Produk) |> mutate(Share23 = Unit / sum(Unit)) |> ungroup() |>
  left_join(tot25, by = "Produk") |>
  mutate(RpSim = Total * Share23 * HargaSatuan) |>
  group_by(Produk) |>
  summarise(RpSimulasi = sum(RpSim), .groups = "drop")
print(mix |> filter(Tahun == 2025) |>
        mutate(RpNyata = Unit * HargaSatuan) |>
        group_by(Produk) |>
        summarise(`Nilai nyata 2025` = round(sum(RpNyata) / 1e6),
                  `Nilai bila mix 2023` = round(sim$RpSimulasi[match(
                    first(Produk), sim$Produk)] / 1e6),
                  .groups = "drop") |>
        mutate(`Dampak mix (Rp juta)` = `Nilai nyata 2025` - `Nilai bila mix 2023`,
               `Dampak (%)` = round((`Nilai nyata 2025` / `Nilai bila mix 2023` - 1) * 100, 1)) |>
        as.data.frame())

cat("\nL.6 Nilai plan 2026 per skenario (Rp miliar):\n")
print(ramalan |>
        filter(Jenis == "Plan") |>
        group_by(Skenario) |>
        summarise(`Rp miliar` = round(sum(Plan * HargaSatuan) / 1e9, 2)) |>
        as.data.frame())

cat("\nL.7 Kebutuhan mesin vs asumsi terpasang (1 mesin per produk per pabrik = 4):\n")
keb <- ramalan |>
  filter(Jenis == "Plan", Skenario == "Normal") |>
  group_by(Produk, Lokasi, KapasitasMesin, Tanggal) |>
  summarise(Bulan = sum(Plan), .groups = "drop") |>
  group_by(Produk, Lokasi, KapasitasMesin) |>
  summarise(Puncak = round(max(Bulan)), .groups = "drop") |>
  mutate(Mesin = ceiling(Puncak / KapasitasMesin))
print(keb |> as.data.frame())
cat("Total kebutuhan mesin (Normal) :", sum(keb$Mesin), "unit\n")
cat("Asumsi terpasang saat ini       : 4 unit (1 per produk per pabrik)\n")
cat("Kekurangan                      :", sum(keb$Mesin) - 4, "unit\n")

cat("\nValidasi selesai. Semua hasil ada di folder output/.\n")
