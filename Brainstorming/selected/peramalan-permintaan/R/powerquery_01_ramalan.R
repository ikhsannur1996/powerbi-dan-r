# ============================================================
# BLOK R DI POWER QUERY #1  ->  tabel "ramalan"  (versi sederhana)
# ------------------------------------------------------------
# TEMPEL kode ini pada:  Home > Transform Data (Power Query) >
# sono "ramalan_sumber" > Transform > Run R script > OK
#
# INPUT  (variabel `dataset`, dibuat otomatis Power BI) =
#   hasil gabungan "permintaan" (kiri) + "produk" (kanan) by Produk
#   kolom: Tanggal, Produk, Permintaan, Kategori, HargaSatuan,
#          KapasitasMesin, LeadTimeHari
#
# OUTPUT (variabel `output`, nama WAHIB per Power BI) =
#   tabel "ramalan": riwayat (2024-2025) + PLAN 2026 (Jan-Jun)
#   x 3 skenario what-if (Pesimis / Normal / Optimis)
#
# METODE PLAN (sederhana, tanpa statistika):
#   1) AngkaBulan : bulan Desember biasanya 1,4x rata-rata produk;
#                   bulan Januari biasanya 0,7x rata-rata.
#                   (rata-rata bulan kalender : rata-rata produk)
#   2) Level      : rata-rata 3 bulan TERAKHIR (Okt-Des 2025)
#   3) PLAN bulan = Level x AngkaBulan
#   4) CekPlan    : PLAN yang dibuat 6 bulan lalu (Jul-Des 2025)
#                   memakai level 3 bulan sebelum x AngkaBulan(2024)
#                   -> untuk visual "Cek: Plan vs Aktual"
# ============================================================

# >>> BLOK_PQ_01_START
suppressMessages({
  library(dplyr)
  library(tidyr)
})

# ---------- 1. normalisasi & kolom dasar ----------
X <- dataset
X$Tanggal    <- as.Date(trimws(as.character(X$Tanggal)))
X$Produk     <- as.character(X$Produk)
X$Permintaan <- as.numeric(X$Permintaan)
X <- X[order(X$Produk, X$Tanggal), ]

X <- X |>
  mutate(
    Tahun      = as.integer(format(Tanggal, "%Y")),
    BulanKe    = as.integer(format(Tanggal, "%m")),
    NamaBulan  = month.abb[BulanKe],
    Jenis      = "Riwayat"          # vs "Plan" (bulan maju)
  )

# ---------- 2. rata-rata 3 bulan terakhir (Level per bulan) ----------
X <- X |>
  group_by(Produk) |>
  arrange(Tanggal) |>
  mutate(Rata3 = (lag(Permintaan, 1) + lag(Permintaan, 2) +
                    lag(Permintaan, 3)) / 3) |>
  ungroup()

# ---------- 3. Angka Bulan (indeks musiman), 2 versi ----------
# versi lengkap (2024+2025) -> untuk PLAN 2026
angka_full <- X |>
  group_by(Produk, BulanKe) |>
  summarise(rb = mean(Permintaan), .groups = "drop") |>
  group_by(Produk) |>
  mutate(AngkaBulan = rb / mean(rb)) |>
  ungroup() |>
  select(Produk, BulanKe, AngkaBulan)

# versi 2024 saja -> untuk CEK PLAN (bonkest 2025) tanpa "monyeji"
angka_2024 <- X |>
  filter(Tahun == 2024) |>
  group_by(Produk, BulanKe) |>
  summarise(rb = mean(Permintaan), .groups = "drop") |>
  group_by(Produk) |>
  mutate(Angka = rb / mean(rb)) |>
  ungroup() |>
  select(Produk, BulanKe, Angka)

# AngkaBulan untuk SEMUA baris (riwayat + plan)
X <- X |>
  left_join(angka_full, by = c("Produk", "BulanKe"))

# ---------- 4. CekPlan: plan yang dibuat 6 bulan luar -------------
X <- X |>
  left_join(angka_2024, by = c("Produk", "BulanKe")) |>
  mutate(CekPlan = ifelse(Tahun == 2025 & BulanKe >= 7,
                          Rata3 * Angka, NA_real_)) |>
  select(-Angka)

# ---------- 5. Level terbaru (rata-rata Okt-Des 2025) ----------
level_akhir <- X |>
  filter(Tahun == 2025, BulanKe >= 10) |>
  group_by(Produk) |>
  summarise(Level = mean(Permintaan), .groups = "drop")

# ---------- 6. PLAN maju: 2026 Jan-Jun per produk ----------
plan_grid <- expand.grid(
  Tanggal = seq(as.Date("2026-01-01"), as.Date("2026-06-01"), by = "month"),
  Produk  = c("Produk A", "Produk B"),
  stringsAsFactors = FALSE
) |>
  mutate(
    Tahun     = 2026L,
    BulanKe   = as.integer(format(Tanggal, "%m")),
    NamaBulan = month.abb[as.integer(format(Tanggal, "%m"))],
    Jenis     = "Plan"
  ) |>
  left_join(angka_full, by = c("Produk", "BulanKe")) |>
  left_join(level_akhir, by = "Produk") |>
  mutate(Plan = Level * AngkaBulan) |>
  select(-Level)

# dimensi produk (dari input original)
dims <- X |>
  select(Produk, Kategori, HargaSatuan, KapasitasMesin) |>
  distinct()

plan_grid <- plan_grid |>
  left_join(dims, by = "Produk") |>
  mutate(Permintaan = NA_real_, Rata3 = NA_real_, CekPlan = NA_real_)

# ---------- 7. gabung riwayat + plan, lalu skenario what-if ----------
kols <- c("Tanggal", "Tahun", "BulanKe", "NamaBulan", "Produk", "Kategori",
          "HargaSatuan", "KapasitasMesin", "Jenis", "Permintaan",
          "CekPlan", "Plan", "AngkaBulan")

tbl <- bind_rows(
  X          |> select(any_of(kols)),
  plan_grid  |> select(any_of(kols))
)

skenario <- data.frame(
  Skenario      = c("Pesimis", "Normal", "Optimis"),
  FaktorSkenario = c(0.90, 1.00, 1.10),
  stringsAsFactors = FALSE
)

output <- tbl |>
  crossing(skenario) |>
  arrange(Produk, Tanggal, Skenario) |>
  select(all_of(c(kols, "Skenario", "FaktorSkenario")))
# >>> BLOK_PQ_01_END