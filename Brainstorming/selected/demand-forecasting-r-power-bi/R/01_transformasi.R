# ============================================================
# BLOK R DI POWER QUERY  ->  tabel "ramalan"
# Tempel blok ini di:  Home > Transform Data
#                      > Transform > Run R script > OK
# ============================================================
# INPUT  `dataset` = hasil gabungan dari 3 CSV:
#   permintaan (kiri) + produk (kanan, by SKU) + lokasi (kanan, by Lokasi)
#   kolom: Tanggal, SKU, Lokasi, Permintaan,
#          Produk, Kategori, Rasa, Ukuran, UrutanUkuran, JenisPacking,
#          IsiKemasan, HargaSatuan, IsiPerKarton, KapasitasMesin, Faktor
#
# OUTPUT `output` = tabel "ramalan": riwayat 3 tahun + plan 2026
#   x 3 skenario (Pesimis / Normal / Optimis)
#
# METODE (3 langkah, tanpa statistika):
#   1) AngkaBulan = "berapa x rata-rata" per bulan (per produk)
#   2) Level      = nilai tengah (median) 3 bulan terakhir (per SKU + lokasi)
#   3) Plan       = Level x AngkaBulan   (6 bulan 2026)
#
# CATATAN OUTLIER: dipakai MEDIAN (bukan rata-rata) supaya lonjakan promo
#   dan penurunan ekstrem tidak menyeret angka rencana.
# ============================================================

# >>> BLOK_PQ_01_START
suppressMessages({ library(dplyr); library(tidyr) })

X <- dataset
X$Tanggal <- as.Date(X$Tanggal)
X$BulanKe <- as.integer(format(X$Tanggal, "%m"))
nama_bulan <- c("Januari", "Februari", "Maret", "April", "Mei", "Juni",
                "Juli", "Agustus", "September", "Oktober", "November", "Desember")
X$NamaBulan <- nama_bulan[X$BulanKe]

# Langkah 1: Angka Bulan (ritme per tahun), per produk
# Penyebut memakai median 12 bulan agar bulan ekstrem tidak mendominasi.
angka_bulan <- X |>
  group_by(Produk, BulanKe) |>
  summarise(Total = sum(Permintaan), .groups = "drop") |>
  group_by(Produk) |>
  mutate(AngkaBulan = Total / median(Total)) |>
  ungroup() |>
  select(Produk, BulanKe, AngkaBulan)

# Langkah 2: Level = nilai tengah (median) 3 bulan terakhir (Okt-Des 2025),
#            per SKU + lokasi
level <- X |>
  filter(Tanggal >= as.Date("2025-10-01")) |>
  group_by(SKU, Lokasi) |>
  summarise(Level = median(Permintaan), .groups = "drop")

# Langkah 3: Plan 2026 (6 bulan) = Level x AngkaBulan
plan <- merge(
  expand.grid(
    Tanggal = seq(as.Date("2026-01-01"), as.Date("2026-06-01"), by = "month"),
    Lokasi  = unique(X$Lokasi)
  ),
  distinct(select(X, SKU, Produk, Kategori, Rasa, Ukuran, UrutanUkuran,
                  JenisPacking, IsiKemasan, HargaSatuan, IsiPerKarton,
                  KapasitasMesin))
)
plan$BulanKe <- as.integer(format(plan$Tanggal, "%m"))
plan <- plan |>
  left_join(angka_bulan, by = c("Produk", "BulanKe")) |>
  left_join(level,       by = c("SKU", "Lokasi")) |>
  mutate(NamaBulan = nama_bulan[BulanKe],
         Plan = Level * AngkaBulan,
         Jenis = "Plan", Permintaan = NA_real_)

# Riwayat (3 tahun) memakai kolom yang sama
riwayat <- X |>
  left_join(angka_bulan, by = c("Produk", "BulanKe")) |>
  mutate(Jenis = "Riwayat", Plan = NA_real_)

# Skenario what-if: setiap baris 3x (Pesimis x0,90 / Normal x1,00 / Optimis x1,10)
skenario <- data.frame(
  Skenario = c("Pesimis", "Normal", "Optimis"),
  Faktor   = c(0.90, 1.00, 1.10)
)

kol <- c("Tanggal", "SKU", "Produk", "Kategori", "Rasa", "Ukuran", "UrutanUkuran",
         "JenisPacking", "IsiKemasan", "HargaSatuan", "IsiPerKarton", "KapasitasMesin",
         "Lokasi", "BulanKe", "NamaBulan", "AngkaBulan", "Jenis",
         "Permintaan", "Plan")

output <- bind_rows(riwayat |> select(all_of(kol)),
                    plan    |> select(all_of(kol))) |>
  crossing(skenario) |>
  mutate(Plan = ifelse(Jenis == "Plan", Plan * Faktor, NA_real_),
         UrutanUkuran = as.integer(UrutanUkuran)) |>
  arrange(Produk, Rasa, Ukuran, JenisPacking, Lokasi, Tanggal, Skenario)

output
# >>> BLOK_PQ_01_END
