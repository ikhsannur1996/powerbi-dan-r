# ============================================================
# BLOK VISUAL R (ggplot2)  ->  tempel di R visual Power BI
#
# Setiap blok = 1 visual. Kolom yang masuk ke Values:
#   V1: Tanggal, SKU, Produk, Rasa, Ukuran, JenisPacking, Lokasi, Jenis,
#       Permintaan, Plan, Skenario, HargaSatuan, KapasitasMesin
#   V2: Tanggal, Produk, SKU, Lokasi, Jenis, Permintaan, Plan, Skenario
#   V3: Tanggal, Produk, Ukuran, SKU, Lokasi, Jenis, Plan, Skenario
#   V4: Tanggal, Produk, SKU, Lokasi, Jenis, Plan, Skenario, KapasitasMesin
#   V5: Produk, BulanKe, AngkaBulan
#   V6: Tanggal, Produk, SKU, Ukuran, Lokasi, Jenis, Permintaan
#   V7: Tanggal, Produk, Ukuran, SKU, Lokasi, Jenis, Permintaan, Plan, Skenario
#   V8: Produk, Ukuran, JenisPacking, SKU, Lokasi, Jenis, Plan, Skenario
#   V9: Tanggal, Produk, SKU, Lokasi, Jenis, Permintaan, Plan, Skenario
#   V10: Tanggal, Produk, SKU, Lokasi, Jenis, Permintaan, Plan, Skenario
#
# BENTUK VISUAL V2-V10 sengaja memakai grafik yang TIDAK ADA di galeri visual
#   native Power BI: boxplot, lollipop, dumbbell, radial (rose), violin,
#   slope chart, tren + penghalus LOESS (pita keyakinan 95%), dan overlay
#   musiman antar tahun -> inilah alasan memakai R visual.
#
# FILTER, BUKAN ISI GRAFIK:
#   - Skenario -> slicer; kode memilih 1 skenario (Normal bila ada).
#   - Produk   -> slicer; TIDAK dipakai sebagai facet / warna / sumbu.
#     Bila beberapa produk terpilih, angkanya digabung (sum) atau dirata-ratakan.
#
# Catatan: angka numerik di Values = "Do not summarize".
#          Kolom yang dipakai slicer HARUS ada di Values juga.
# ============================================================

# >>> BLOK_RV_V1_START
# Visual 1 - KARTU KPI: 4 angka kunci dalam 1 tampilan (ikut slicer)
suppressMessages({ library(ggplot2); library(dplyr) })
D  <- dataset
sk <- intersect(c("Normal", "Pesimis", "Optimis"), unique(D$Skenario))[1]

riwayat <- D |>
  filter(Jenis == "Riwayat") |>
  distinct(Tanggal, SKU, Lokasi, Permintaan) |>
  summarise(Unit = sum(Permintaan))

rencana <- D |>
  filter(Jenis == "Plan", Skenario == sk) |>
  summarise(Unit = sum(Plan), Rp = sum(Plan * HargaSatuan))

mesin <- D |>
  filter(Jenis == "Plan", Skenario == sk) |>
  group_by(Produk, Lokasi, Tanggal, KapasitasMesin) |>
  summarise(Bulan = sum(Plan), .groups = "drop") |>
  group_by(Produk, Lokasi, KapasitasMesin) |>
  summarise(Puncak = max(Bulan), .groups = "drop") |>
  mutate(Keb = ceiling(Puncak / KapasitasMesin))

angka <- function(x) formatC(round(x), format = "d", big.mark = ".", decimal.mark = ",")
total_mesin <- sum(mesin$Keb)

kpi <- data.frame(
  Kolom  = c(1, 2, 1, 2),
  Baris  = c(2, 2, 1, 1),
  Judul  = c("Total Riwayat 3 Tahun", "Rencana 2026 (Jan-Jun)",
             "Nilai Rencana 2026", "Mesin pada Bulan Puncak"),
  Nilai  = c(angka(riwayat$Unit), angka(rencana$Unit),
             paste0("Rp ", formatC(rencana$Rp / 1e9, format = "f", digits = 2, decimal.mark = ","), " M"),
             paste0(total_mesin, " unit")),
  Ket    = c("unit, 2023-2025", sprintf("unit, skenario %s", sk),
             sprintf("skenario %s", sk), sprintf("1 mesin per lini produk, 4 terpasang")),
  Latar  = c("#EAF2FA", "#EAF2FA", "#E7F4EC", "#FDECEA"),
  Aksen  = c("#1F6FB2", "#1F6FB2", "#2E7D32", "#C62828")
)

p <- ggplot(kpi, aes(Kolom, Baris)) +
  geom_tile(aes(fill = Latar), width = 0.94, height = 0.90,
            color = "white", linewidth = 2.5) +
  geom_text(aes(y = Baris + 0.30, label = Judul),
            fontface = "bold", size = 3.7, color = "grey25") +
  geom_text(aes(y = Baris + 0.02, label = Nilai),
            fontface = "bold", size = 9, color = kpi$Aksen) +
  geom_text(aes(y = Baris - 0.28, label = Ket),
            size = 3.0, color = "grey45") +
  scale_fill_identity() +
  scale_x_continuous(limits = c(0.5, 2.5), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0.5, 2.5), expand = c(0, 0)) +
  labs(title = "Ringkasan Kinerja",
       subtitle = sprintf("Skenario aktif: %s   |   angka mengikuti slicer Produk / Ukuran / Lokasi", sk)) +
  theme_void(base_size = 12) +
  theme(plot.title    = element_text(face = "bold", size = 15, margin = margin(b = 2)),
        plot.subtitle = element_text(size = 9, color = "grey45"),
        plot.margin   = margin(8, 8, 8, 8))
p
# >>> BLOK_RV_V1_END

# >>> BLOK_RV_V2_START
# Visual 2 - BOXPLOT: sebaran permintaan bulanan per tahun + sebaran RENCANA 2026
# (boxplot tidak ada di galeri visual native Power BI)
#
# CATATAN: rencana digambar sebagai BOXPLOT dari 6 nilai bulanan (Jan-Jun 2026),
#   bukan sebagai 1 titik. Kalau dirangkum jadi satu titik, kotaknya kosong.
suppressMessages({ library(ggplot2); library(dplyr) })
D  <- dataset
sk <- intersect(c("Normal", "Pesimis", "Optimis"), unique(D$Skenario))[1]
angka <- function(x) formatC(round(x), format = "d", big.mark = ".", decimal.mark = ",")

riwayat <- D |>
  filter(Jenis == "Riwayat") |>
  distinct(Tanggal, SKU, Lokasi, Permintaan) |>
  group_by(Tanggal) |>
  summarise(Unit = sum(Permintaan), .groups = "drop") |>
  mutate(Periode = format(Tanggal, "%Y"), Grup = "Riwayat")

rencana <- D |>
  filter(Jenis == "Plan", Skenario == sk) |>
  group_by(Tanggal) |>
  summarise(Unit = sum(Plan), .groups = "drop") |>
  mutate(Periode = "Plan 2026", Grup = "Rencana")

Dd <- bind_rows(riwayat, rencana) |>
  mutate(Periode = factor(Periode, levels = c("2023", "2024", "2025", "Plan 2026")))

med <- Dd |>
  group_by(Periode, Grup) |>
  summarise(Med = median(Unit), .groups = "drop")

p <- ggplot(Dd, aes(Periode, Unit, fill = Grup)) +
  geom_boxplot(width = 0.60, color = "grey35", outlier.shape = NA, alpha = 0.95) +
  geom_point(position = position_jitter(width = 0.10, seed = 1),
             size = 1.6, color = "grey20", alpha = 0.55, show.legend = FALSE) +
  geom_text(data = med, aes(y = Med, label = angka(Med)),
            nudge_x = 0.38, hjust = 0, size = 3.0, fontface = "bold", color = "grey20") +
  scale_fill_manual(name = NULL, values = c("Riwayat" = "#9EC5E8", "Rencana" = "#1F6FB2")) +
  scale_y_continuous(labels = function(v) formatC(round(v), format = "d", big.mark = ".", decimal.mark = ",")) +
  labs(title = sprintf("Sebaran permintaan bulanan per tahun (skenario: %s)", sk),
       subtitle = "Tiap titik = total 1 bulan; kotak = 50% data tengah; angka di kanan kotak = median",
       x = NULL, y = "Unit per bulan") +
  theme_minimal(base_size = 12)
p
# >>> BLOK_RV_V2_END

# >>> BLOK_RV_V3_START
# Visual 3 - LOLLIPOP: rencana Januari 2026 per ukuran
# (lollipop / dot-and-stem tidak ada di galeri visual native Power BI)
suppressMessages({ library(ggplot2); library(dplyr) })
D   <- dataset
sk <- intersect(c("Normal", "Pesimis", "Optimis"), unique(D$Skenario))[1]

Dd <- D |>
  filter(Jenis == "Plan", Tanggal == as.Date("2026-01-01"), Skenario == sk) |>
  group_by(Ukuran) |>
  summarise(Unit = sum(Plan), .groups = "drop") |>
  mutate(Ukuran = factor(Ukuran, levels = c("Kecil", "Sedang", "Besar")),
         Label  = formatC(round(Unit), format = "d", big.mark = ".", decimal.mark = ","))

p <- ggplot(Dd, aes(Unit, Ukuran)) +
  geom_segment(aes(x = 0, xend = Unit, y = Ukuran, yend = Ukuran),
               color = "grey70", linewidth = 0.9) +
  geom_point(size = 4.2, color = "#1F6FB2") +
  geom_text(aes(label = Label), hjust = -0.30, size = 3.5, color = "grey20") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.30))) +
  scale_y_discrete(expand = expansion(add = 0.5)) +
  labs(title = sprintf("Rencana Januari 2026 per ukuran (skenario: %s)", sk),
       x = "Unit", y = NULL) +
  theme_minimal(base_size = 12)
p
# >>> BLOK_RV_V3_END

# >>> BLOK_RV_V4_START
# Visual 4 - DUMBBELL: jumlah mesin terpasang vs dibutuhkan per pabrik
# (dumbbell / gap chart tidak ada di galeri visual native Power BI)
suppressMessages({ library(ggplot2); library(dplyr) })
D   <- dataset
sk <- intersect(c("Normal", "Pesimis", "Optimis"), unique(D$Skenario))[1]

Dd <- D |>
  filter(Jenis == "Plan", Skenario == sk) |>
  group_by(Produk, Lokasi, Tanggal, KapasitasMesin) |>
  summarise(Unit = sum(Plan), .groups = "drop") |>
  group_by(Produk, Lokasi, KapasitasMesin) |>
  summarise(Puncak = max(Unit), .groups = "drop") |>
  mutate(Mesin = ceiling(Puncak / KapasitasMesin)) |>
  group_by(Lokasi) |>
  summarise(Butuh = sum(Mesin), Terpasang = n(), .groups = "drop") |>
  mutate(Kurang = Butuh - Terpasang,
         Label  = ifelse(Kurang > 0, sprintf("butuh %d  (kurang %d)", Butuh, Kurang),
                         sprintf("butuh %d", Butuh)))

p <- ggplot(Dd, aes(y = Lokasi)) +
  geom_segment(aes(x = Terpasang, xend = Butuh, y = Lokasi, yend = Lokasi),
               color = "grey65", linewidth = 1.2) +
  geom_point(aes(x = Terpasang), color = "#2E7D32", size = 3.8) +
  geom_point(aes(x = Butuh), color = "#C62828", size = 3.8) +
  geom_text(aes(x = pmax(Terpasang, Butuh), label = Label),
            hjust = -0.15, size = 3.3, color = "grey20") +
  scale_x_continuous(breaks = 0:8, limits = c(0, NA),
                     expand = expansion(mult = c(0.02, 0.45))) +
  scale_y_discrete(expand = expansion(add = 0.6)) +
  labs(title = sprintf("Kebutuhan mesin per pabrik (skenario: %s)", sk),
       subtitle = "Hijau = mesin terpasang (1 per lini produk); merah = mesin yang dibutuhkan pada bulan puncak",
       x = "Jumlah mesin", y = NULL) +
  theme_minimal(base_size = 12)
p
# >>> BLOK_RV_V4_END

# >>> BLOK_RV_V5_START
# Visual 5 - RADIAL (rose chart): ritme musiman / Angka Bulan
# (radial bar / rose chart tidak ada di galeri visual native Power BI)
suppressMessages({ library(ggplot2); library(dplyr) })
D <- dataset |>
  distinct(Produk, BulanKe, AngkaBulan) |>
  group_by(BulanKe) |>
  summarise(AngkaBulan = mean(AngkaBulan), .groups = "drop") |>
  mutate(NM     = factor(month.abb[BulanKe], levels = month.abb),
         Status = ifelse(AngkaBulan >= 1, "Di atas rata-rata", "Di bawah rata-rata"))

p <- ggplot(D, aes(NM, AngkaBulan, fill = Status)) +
  geom_col(width = 0.92) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "grey30") +
  scale_y_continuous(limits = c(0, NA)) +
  scale_fill_manual(values = c("Di atas rata-rata" = "#C62828",
                               "Di bawah rata-rata" = "#7FB3D5")) +
  coord_polar(start = -pi / 12) +
  labs(title = "Ritme musiman permintaan (radial)",
       subtitle = "Angka Bulan, 1 = rata-rata; J = Januari ... D = Desember (beberapa produk dirata-ratakan)",
       x = NULL, y = "Angka Bulan") +
  theme_minimal(base_size = 12) +
  theme(axis.text.y = element_text(size = 7))
p
# >>> BLOK_RV_V5_END

# >>> BLOK_RV_V6_START
# Visual 6 - VIOLIN: sebaran permintaan bulanan per UKURAN (2023-2025)
# (violin plot tidak ada di galeri visual native Power BI)
suppressMessages({ library(ggplot2); library(dplyr) })
D <- dataset |>
  filter(Jenis == "Riwayat") |>
  distinct(Tanggal, Produk, SKU, Ukuran, Lokasi, Permintaan) |>
  mutate(Ukuran = factor(Ukuran, levels = c("Kecil", "Sedang", "Besar")))

p <- ggplot(D, aes(Ukuran, Permintaan, fill = Ukuran)) +
  geom_violin(trim = FALSE, color = "grey35", alpha = 0.9) +
  geom_boxplot(width = 0.12, fill = "white", color = "grey30",
               outlier.color = "#C62828", outlier.size = 1.8) +
  scale_fill_manual(values = c("Kecil" = "#9EC5E8", "Sedang" = "#5B9BD5",
                               "Besar" = "#1F6FB2")) +
  scale_y_continuous(labels = function(v) formatC(round(v), format = "d", big.mark = ".", decimal.mark = ",")) +
  labs(title = "Sebaran permintaan bulanan per ukuran (2023-2025)",
       subtitle = "Bentuk violin = kepadatan data; titik merah = outlier",
       x = NULL, y = "Unit per bulan (per SKU)") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")
p
# >>> BLOK_RV_V6_END

# >>> BLOK_RV_V7_START
# Visual 7 - SLOPE CHART: pergeseran pangsa ukuran 2023 -> rencana 2026
# (slope chart tidak ada di galeri visual native Power BI)
suppressMessages({ library(ggplot2); library(dplyr); library(scales) })
D   <- dataset
sk <- intersect(c("Normal", "Pesimis", "Optimis"), unique(D$Skenario))[1]

riwayat <- D |>
  filter(Jenis == "Riwayat", format(Tanggal, "%Y") == "2023") |>
  group_by(Ukuran) |>
  summarise(Unit = sum(Permintaan), .groups = "drop") |>
  mutate(Pangsa = Unit / sum(Unit), Periode = "Riwayat 2023")

rencana <- D |>
  filter(Jenis == "Plan", Skenario == sk) |>
  group_by(Ukuran) |>
  summarise(Unit = sum(Plan), .groups = "drop") |>
  mutate(Pangsa = Unit / sum(Unit), Periode = "Plan 2026")

Dd <- bind_rows(riwayat, rencana) |>
  mutate(Periode = factor(Periode, levels = c("Riwayat 2023", "Plan 2026")),
         Ukuran  = factor(Ukuran, levels = c("Kecil", "Sedang", "Besar")))

p <- ggplot(Dd, aes(Periode, Pangsa, group = Ukuran, color = Ukuran)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 3.2) +
  geom_text(data = filter(Dd, Periode == "Riwayat 2023"),
            aes(label = percent(Pangsa, 1)), hjust = 1.35, size = 3.1, show.legend = FALSE) +
  geom_text(data = filter(Dd, Periode == "Plan 2026"),
            aes(label = percent(Pangsa, 1)), hjust = -0.35, size = 3.1, show.legend = FALSE) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_x_discrete(expand = expansion(mult = 0.35)) +
  labs(title = sprintf("Pergeseran pangsa ukuran: 2023 -> rencana 2026 (skenario: %s)", sk),
       subtitle = "Kemiringan garis = arah pergeseran bauran",
       x = NULL, y = "Pangsa unit") +
  theme_minimal(base_size = 12)
p
# >>> BLOK_RV_V7_END

# >>> BLOK_RV_V8_START
# Visual 8 - Peta Ukuran x JENIS PACKING pada plan 2026
suppressMessages({ library(ggplot2); library(dplyr); library(scales) })
D  <- dataset
sk <- intersect(c("Normal", "Pesimis", "Optimis"), unique(D$Skenario))[1]

D <- D |>
  filter(Jenis == "Plan", Skenario == sk) |>
  group_by(Ukuran, JenisPacking) |>
  summarise(Plan = sum(Plan), .groups = "drop") |>
  mutate(Ukuran = factor(Ukuran, levels = c("Kecil", "Sedang", "Besar")))

p <- ggplot(D, aes(Ukuran, JenisPacking, fill = Plan)) +
  geom_tile(color = "white") +
  geom_text(aes(label = comma(round(Plan))), size = 3.2) +
  scale_fill_gradient(low = "#DCEBF7", high = "#1F6FB2") +
  labs(title = sprintf("Peta Ukuran x Jenis Packing - Plan 2026 (skenario: %s)", sk),
       x = NULL, y = NULL) +
  theme_minimal(base_size = 12)
p
# >>> BLOK_RV_V8_END

# >>> BLOK_RV_V9_START
# Visual 9 - TREN + PENGHALUS LOESS (pita keyakinan 95%) + garis rencana
# (line chart default Power BI tidak punya penghalus statistik + pita keyakinan)
suppressMessages({ library(ggplot2); library(dplyr) })
D   <- dataset
sk <- intersect(c("Normal", "Pesimis", "Optimis"), unique(D$Skenario))[1]

aktual <- D |>
  filter(Jenis == "Riwayat") |>
  distinct(Tanggal, Produk, SKU, Lokasi, Permintaan) |>
  group_by(Tanggal) |>
  summarise(Unit = sum(Permintaan), .groups = "drop")

rencana <- D |>
  filter(Jenis == "Plan", Skenario == sk) |>
  group_by(Tanggal) |>
  summarise(Unit = sum(Plan), .groups = "drop")

batas <- max(aktual$Tanggal)

p <- ggplot() +
  geom_line(data = aktual, aes(Tanggal, Unit), color = "grey70", linewidth = 0.5) +
  geom_smooth(data = aktual, aes(Tanggal, Unit), method = "loess", formula = y ~ x,
              span = 0.7, color = "#1F6FB2", fill = "#9EC5E8", alpha = 0.35,
              linewidth = 1.1, show.legend = FALSE) +
  geom_line(data = rencana, aes(Tanggal, Unit, linetype = "Rencana"),
            color = "#C62828", linewidth = 1) +
  geom_vline(xintercept = batas, linetype = "dotted", color = "grey40") +
  scale_linetype_manual(name = NULL, values = c("Rencana" = "dashed")) +
  scale_y_continuous(labels = function(v) formatC(round(v), format = "d", big.mark = ".", decimal.mark = ",")) +
  labs(title = sprintf("Tren permintaan & rencana (skenario: %s)", sk),
       subtitle = "Abu = aktual; pita biru = tren LOESS + keyakinan 95%; merah putus-putus = rencana 2026",
       x = NULL, y = "Unit per bulan") +
  theme_minimal(base_size = 12)
p
# >>> BLOK_RV_V9_END

# >>> BLOK_RV_V10_START
# Visual 10 - OVERLAY MUSIMAN: satu garis per tahun pada bulan Jan-Des + rencana 2026
# (bentuk ini butuh ukuran DAX khusus di Power BI, bukan default line chart)
suppressMessages({ library(ggplot2); library(dplyr) })
D   <- dataset
sk <- intersect(c("Normal", "Pesimis", "Optimis"), unique(D$Skenario))[1]

riwayat <- D |>
  filter(Jenis == "Riwayat") |>
  distinct(Tanggal, Produk, SKU, Lokasi, Permintaan) |>
  mutate(Seri = format(Tanggal, "%Y"), Bulan = as.integer(format(Tanggal, "%m"))) |>
  group_by(Seri, Bulan) |>
  summarise(Unit = sum(Permintaan), .groups = "drop")

rencana <- D |>
  filter(Jenis == "Plan", Skenario == sk) |>
  mutate(Bulan = as.integer(format(Tanggal, "%m"))) |>
  group_by(Bulan) |>
  summarise(Unit = sum(Plan), .groups = "drop") |>
  mutate(Seri = "Plan 2026")

Dd <- bind_rows(riwayat, rencana) |>
  mutate(Seri = factor(Seri, levels = c("2023", "2024", "2025", "Plan 2026")))

p <- ggplot(Dd, aes(Bulan, Unit, color = Seri, linewidth = Seri, linetype = Seri)) +
  geom_line() +
  scale_linewidth_manual(values = c("2023" = 0.8, "2024" = 0.8,
                                    "2025" = 0.8, "Plan 2026" = 1.5)) +
  scale_linetype_manual(values = c("2023" = "solid", "2024" = "solid",
                                   "2025" = "solid", "Plan 2026" = "dashed")) +
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  scale_y_continuous(labels = function(v) formatC(round(v), format = "d", big.mark = ".", decimal.mark = ",")) +
  labs(title = "Pola musiman per tahun (bulan Jan-Des)",
       subtitle = sprintf("Tiap garis = total bulanan satu tahun; garis tebal putus-putus = rencana 2026 (skenario: %s)", sk),
       x = NULL, y = "Unit per bulan",
       color = "Seri", linewidth = "Seri", linetype = "Seri") +
  theme_minimal(base_size = 12)
p
# >>> BLOK_RV_V10_END
