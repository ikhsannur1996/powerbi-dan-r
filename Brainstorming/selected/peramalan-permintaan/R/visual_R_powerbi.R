# ============================================================
# VISUAL R POWER BI (ggplot2) — versi sederhana (8 blok)
# ------------------------------------------------------------
# Tempel setiap blok di satu **R visual** Power BI. Field barbut
# di "Values" (rekomen: do not summarize) dijelaskan di komentar.
#
# METODE yang digunakan (sederhana):
#   PLAN = rata-rata 3 bulan terakhir x "angka bulan"
# CekPlan = plan yang dibuat 6 bulan luar (untuk visual Cek).
#
# Kunci filter: blok hanya membaca `dataset` (baris yang sudah
# terfilter slicer) -> setiap gambar ikut slicer Produk / Skenario.
# ============================================================

# ------------------------------------------------------------
# V1 - RINGKASAN (KPI)
# Field di Values: Produk, Jenis, Tanggal, Permintaan, Plan,
#                  CekPlan, FaktorSkenario, Skenario, HargaSatuan,
#                  KapasitasMesin
# ------------------------------------------------------------
# >>> BLOK_RV_V1_START
suppressMessages({ library(ggplot2); library(dplyr); library(scales) })
Tgl <- dataset$Tanggal
Tanggal <- if (is.numeric(Tgl)) as.Date(unclass(Tgl), origin = "1970-01-01") else as.Date(as.character(Tgl))
D <- dataset |> mutate(Tanggal = Tanggal)

if (nrow(D) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data untuk filter ini", size = 7) +
    theme_void()
} else {
  # satu skenario yang ditampilkan (Pesimis -> Normal -> Optimis)
  sk <- D |> distinct(Skenario, FaktorSkenario) |> arrange(FaktorSkenario)
  sk_sel <- as.character(sk$Skenario[1]); f <- sk$FaktorSkenario[1]

  hist <- D |>
    filter(Jenis == "Riwayat") |>
    distinct(Tanggal, Produk, Permintaan) |>
    summarise(Total = sum(Permintaan, na.rm = TRUE), .groups = "drop")

  plan <- D |>
    filter(Jenis == "Plan", Skenario == sk_sel) |>
    distinct(Tanggal, Produk, HargaSatuan, Plan) |>
    mutate(Hasil = Plan * f) |>
    summarise(TotalUnit = sum(Hasil, na.rm = TRUE), .groups = "drop")

  cek <- D |>
    filter(!is.na(CekPlan)) |>
    distinct(Tanggal, Produk, Permintaan, CekPlan) |>
    summarise(k = mean(abs(Permintaan - CekPlan) / Permintaan) * 100,
              .groups = "drop")

  if (nrow(D |> filter(Jenis == "Plan")) == 0) {
    mesin <- data.frame(Keb = 0)
  } else {
    mesin <- D |>
      filter(Jenis == "Plan", Skenario == sk_sel) |>
      distinct(Tanggal, Produk, KapasitasMesin, Plan) |>
      mutate(Hasil = Plan * f) |>
      group_by(Produk, KapasitasMesin) |>
      summarise(Puncak = max(Hasil, na.rm = TRUE), .groups = "drop") |>
      mutate(Keb = ceiling(Puncak / KapasitasMesin))
  }

  fmt <- function(x) format(round(x), big.mark = ".", decimal.mark = ",")
  k_cek <- if (nrow(cek) == 0 || is.na(cek$k[1])) NA_real_ else cek$k[1]
  kpi <- data.frame(
    Label = c("Total Riwayat\n2024-2025 (unit)",
              "Plan 2026\n6 Bulan (unit)",
              "Rata-rata Selisih\nPlan vs Aktual",
              "Mesin saat Puncak\n(Plan 2026)"),
    Nilai = c(fmt(hist$Total), fmt(plan$TotalUnit),
              ifelse(is.na(k_cek), "\u2014", sprintf("%.1f%%", k_cek)),
              paste0(sum(mesin$Keb, na.rm = TRUE), " mesin")),
    stringsAsFactors = FALSE
  )
  kpi$Label <- factor(kpi$Label, levels = as.character(kpi$Label))

  p <- ggplot(kpi, aes(x = 0.5, y = 0.5, label = Nilai)) +
    geom_text(size = 7, fontface = "bold") +
    facet_wrap(~Label) +
    labs(title = "Ringkasan Peramalan (Sederhana)",
         subtitle = sprintf("Skenario: %s (x%.2f) | Metode: rata-rata 3 bulan x angka bulan",
                            sk_sel, f)) +
    theme_void(base_size = 13) +
    theme(strip.text = element_text(face = "bold", size = 9),
          plot.title = element_text(face = "bold", hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5, color = "grey40", size = 8.5))
}
p
# >>> BLOK_RV_V1_END

# ------------------------------------------------------------
# V2 - TREN: RIWAYAT vs PLAN
# Field di Values: Tanggal, Produk, Jenis, Permintaan, Plan,
#                  FaktorSkenario, Skenario
# ------------------------------------------------------------
# >>> BLOK_RV_V2_START
suppressMessages({ library(ggplot2); library(dplyr); library(scales) })
Tgl <- dataset$Tanggal
Tanggal <- if (is.numeric(Tgl)) as.Date(unclass(Tgl), origin = "1970-01-01") else as.Date(as.character(Tgl))
D <- dataset |>
  mutate(Tanggal = Tanggal,
         Nilai   = ifelse(Jenis == "Plan", Plan * FaktorSkenario, Permintaan))

if (nrow(D) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data untuk filter ini", size = 7) +
    theme_void()
} else {
  aktual <- D |> filter(Jenis == "Riwayat") |> distinct(Tanggal, Produk, Permintaan)
  plan   <- D |> filter(Jenis == "Plan") |>
    distinct(Tanggal, Produk, Skenario, Nilai) |>
    mutate(Skenario = factor(Skenario, levels = c("Pesimis", "Normal", "Optimis")))

  p <- ggplot() +
    geom_line(data = aktual, aes(Tanggal, Permintaan),
              color = "grey30", linewidth = 0.9, na.rm = TRUE) +
    geom_line(data = plan, aes(Tanggal, Nilai, color = Skenario),
              linewidth = 0.9, linetype = "dashed", na.rm = TRUE) +
    geom_vline(xintercept = as.Date("2026-01-01"),
               linetype = "dotted", color = "grey50") +
    facet_wrap(~Produk, scales = "free_y") +
    scale_y_continuous(labels = label_comma()) +
    scale_x_date(date_labels = "%b %Y", date_breaks = "3 months") +
    labs(title = "Permintaan & Plan 2026",
         subtitle = "Garis penuh = permintaan; garis putus = plan (uwekeh skenario what-if)",
         x = NULL, y = "Unit") +
    theme_minimal(base_size = 12) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8))
}
p
# >>> BLOK_RV_V2_END

# ------------------------------------------------------------
# V3 - PLAN BULAN DEPAN per Produk (Jan 2026)
# Field di Values: Jenis, Produk, Tanggal, Plan, FaktorSkenario,
#                  Skenario
# ------------------------------------------------------------
# >>> BLOK_RV_V3_START
suppressMessages({ library(ggplot2); library(dplyr); library(scales) })
Tgl <- dataset$Tanggal
Tanggal <- if (is.numeric(Tgl)) as.Date(unclass(Tgl), origin = "1970-01-01") else as.Date(as.character(Tgl))
D <- dataset |> mutate(Tanggal = Tanggal)

if (nrow(D) == 0 || nrow(D |> filter(Jenis == "Plan")) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data plan (cek filter Tahun/Bulan)", size = 6) +
    theme_void()
} else {
  bd <- D |>
    filter(Jenis == "Plan", Tanggal == as.Date("2026-01-01")) |>
    distinct(Produk, Skenario, FaktorSkenario, Plan) |>
    mutate(Hasil = Plan * FaktorSkenario,
           Skenario = factor(Skenario, levels = c("Pesimis", "Normal", "Optimis")))

  p <- ggplot(bd, aes(Produk, Hasil, fill = Skenario)) +
    geom_col(position = position_dodge2(0.7), width = 0.7) +
    geom_text(aes(label = label_comma()(round(Hasil))),
              position = position_dodge2(0.7), vjust = -0.5, size = 3) +
    scale_fill_manual(values = c(Pesimis = "#7fae8c", Normal = "steelblue",
                                 Optimis = "#C44E52"),
                      name = "Skenario") +
    scale_y_continuous(labels = label_comma()) +
    labs(title = "Plan Bulan Depan (Jan 2026) per Produk",
         subtitle = "Metode: rata-rata Okt-Des 2025 x angka bulan Januari",
         x = NULL, y = "Plan (unit)") +
    theme_minimal(base_size = 12)
}
p
# >>> BLOK_RV_V3_END

# ------------------------------------------------------------
# V4 - CEK: PLAN vs AKTUAL (Jul-Des 2025)
# Field di Values: Jenis, Tanggal, Produk, Permintaan, CekPlan
# ------------------------------------------------------------
# >>> BLOK_RV_V4_START
suppressMessages({ library(ggplot2); library(dplyr); library(tidyr) })
Tgl <- dataset$Tanggal
Tanggal <- if (is.numeric(Tgl)) as.Date(unclass(Tgl), origin = "1970-01-01") else as.Date(as.character(Tgl))
D <- dataset |> mutate(Tanggal = Tanggal)

if (nrow(D) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data untuk filter ini", size = 7) +
    theme_void()
} else {
  cek <- D |>
    filter(!is.na(CekPlan)) |>
    distinct(Tanggal, Produk, Permintaan, CekPlan) |>
    mutate(NM = factor(month.abb[as.integer(format(Tanggal, "%m"))],
                       levels = month.abb)) |>
    select(Produk, NM, Aktual = Permintaan, Plan = CekPlan) |>
    pivot_longer(c(Aktual, Plan), names_to = "Seri", values_to = "Unit")

  p <- ggplot(cek, aes(NM, Unit, fill = Seri)) +
    geom_col(position = position_dodge2(0.8), width = 0.75) +
    facet_wrap(~Produk, scales = "free_y") +
    scale_fill_manual(values = c(Aktual = "grey30", Plan = "steelblue"),
                      name = NULL) +
    scale_y_continuous(labels = label_comma()) +
    labs(title = "Cek: Plan vs Aktual (Jul-Des 2025)",
         subtitle = "Cara kita plan, seberapa hampir 6 bulan lalu? Metode sama, 6 bulan luar",
         x = NULL, y = "Unit") +
    theme_minimal(base_size = 12)
}
p
# >>> BLOK_RV_V4_END

# ------------------------------------------------------------
# V5 - ANGKA BULAN (berapa x rata-rata)
# Field di Values: Produk, BulanKe, AngkaBulan
# ------------------------------------------------------------
# >>> BLOK_RV_V5_START
suppressMessages({ library(ggplot2); library(dplyr) })
D <- dataset |> distinct(Produk, BulanKe, AngkaBulan)

if (nrow(D) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data untuk filter ini", size = 7) +
    theme_void()
} else {
  D <- D |>
    mutate(NM   = factor(month.abb[BulanKe], levels = month.abb),
           Naik = AngkaBulan > 1)
  p <- ggplot(D, aes(NM, AngkaBulan, fill = Naik)) +
    geom_col(width = 0.75) +
    geom_hline(yintercept = 1, linetype = "dashed", color = "grey40") +
    geom_text(aes(label = sprintf("%.2f", AngkaBulan)), vjust = -0.5, size = 2.6) +
    facet_wrap(~Produk) +
    scale_fill_manual(values = c(`TRUE` = "#C44E52", `FALSE` = "steelblue"),
                      guide = "none") +
    labs(title = "Angka Bulan (berapa x rata-rata produk)",
         subtitle = "Desember biasanya 1,4x rata-rata; Januari 0,7x rata-rata",
         x = NULL, y = "Angka bulan (1 = rata-rata)") +
    theme_minimal(base_size = 12) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8))
}
p
# >>> BLOK_RV_V5_END

# ------------------------------------------------------------
# V6 - HEATMAP Tahun x Bulan (permintaan riwayat)
# Field di Values: Jenis, Tanggal, Permintaan
# ------------------------------------------------------------
# >>> BLOK_RV_V6_START
suppressMessages({ library(ggplot2); library(dplyr); library(scales) })
Tgl <- dataset$Tanggal
Tanggal <- if (is.numeric(Tgl)) as.Date(unclass(Tgl), origin = "1970-01-01") else as.Date(as.character(Tgl))
D <- dataset |> mutate(Tanggal = Tanggal)

if (nrow(D) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data untuk filter ini", size = 7) +
    theme_void()
} else {
  hm <- D |>
    filter(Jenis == "Riwayat") |>
    distinct(Tanggal, Permintaan) |>
    mutate(Tahun = as.integer(format(Tanggal, "%Y")),
           BN    = as.integer(format(Tanggal, "%m")),
           NM    = factor(month.abb[BN], levels = month.abb)) |>
    group_by(Tahun, NM) |>
    summarise(Total = sum(Permintaan, na.rm = TRUE), .groups = "drop")

  p <- ggplot(hm, aes(NM, factor(Tahun), fill = Total)) +
    geom_tile(color = "white", linewidth = 0.4) +
    geom_text(aes(label = label_comma()(Total)), size = 3.4, color = "white") +
    scale_fill_gradient(low = "#dbe9f6", high = "#08306b", labels = label_comma()) +
    labs(title = "Kapan Permintaan paling tinggi? (Tahun x Bulan)",
         subtitle = "Nov-Des konsisten paling tinggi di kedua tahun",
         x = NULL, y = NULL, fill = "Unit") +
    theme_minimal(base_size = 12)
}
p
# >>> BLOK_RV_V6_END

# ------------------------------------------------------------
# V7 - KAPASITAS vs PUNCAK PLAN
# Field di Values: Jenis, Produk, Tanggal, Skenario,
#                  FaktorSkenario, Plan, KapasitasMesin
# ------------------------------------------------------------
# >>> BLOK_RV_V7_START
suppressMessages({ library(ggplot2); library(dplyr); library(scales) })
D <- dataset

if (nrow(D) == 0 || nrow(D |> filter(Jenis == "Plan")) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data plan (cek filter Tahun/Bulan)", size = 6) +
    theme_void()
} else {
  peak <- D |>
    filter(Jenis == "Plan") |>
    distinct(Tanggal, Produk, Skenario, FaktorSkenario, Plan, KapasitasMesin) |>
    mutate(Hasil = Plan * FaktorSkenario,
           Skenario = factor(Skenario, levels = c("Pesimis", "Normal", "Optimis"))) |>
    group_by(Produk, Skenario, KapasitasMesin) |>
    summarise(Puncak = max(Hasil, na.rm = TRUE), .groups = "drop")
  kap <- distinct(peak, Produk, KapasitasMesin)

  p <- ggplot(peak, aes(Skenario, Puncak, fill = Skenario)) +
    geom_col(width = 0.65) +
    geom_hline(data = kap, aes(yintercept = KapasitasMesin),
               linetype = "dashed", color = "grey40") +
    geom_text(aes(label = label_comma()(round(Puncak))), vjust = -1.1, size = 3.2) +
    facet_wrap(~Produk, scales = "free_y") +
    scale_fill_manual(values = c(Pesimis = "#7fae8c", Normal = "steelblue",
                                 Optimis = "#C44E52"), guide = "none") +
    labs(title = "Puncak Plan (Jan-Jun 2026) vs Kapasitas 1 Mesin",
         subtitle = "Garis putus = kapasitas 1 mesin. Bar > garis = butuh mesin tambahan.",
         x = "Skenario", y = "Puncak plan (unit)") +
    theme_minimal(base_size = 12)
}
p
# >>> BLOK_RV_V7_END

# ------------------------------------------------------------
# V8 - TABEL WHAT-IF (skenario)
# Field di Values: Jenis, Tanggal, Produk, Skenario,
#                  FaktorSkenario, Plan, HargaSatuan, KapasitasMesin
# ------------------------------------------------------------
# >>> BLOK_RV_V8_START
suppressMessages({ library(ggplot2); library(dplyr) })
D <- dataset |> arrange(Tanggal, Produk)

if (nrow(D) == 0 || nrow(D |> filter(Jenis == "Plan")) == 0) {
  p <- ggplot(data.frame(x = 0, y = 0), aes(x, y)) +
    geom_text(label = "Tidak ada data plan (cek filter Tahun/Bulan)", size = 6) +
    theme_void()
} else {
  ram <- D |>
    filter(Jenis == "Plan") |>
    distinct(Tanggal, Produk, Skenario, FaktorSkenario, Plan, HargaSatuan) |>
    mutate(Hasil = Plan * FaktorSkenario) |>
    group_by(Skenario) |>
    summarise(TotalUnit = sum(Hasil, na.rm = TRUE),
              TotalRp   = sum(Hasil * HargaSatuan, na.rm = TRUE),
              .groups = "drop")

  mesin <- D |>
    filter(Jenis == "Plan") |>
    distinct(Tanggal, Produk, Skenario, FaktorSkenario, Plan, KapasitasMesin) |>
    mutate(Hasil = Plan * FaktorSkenario) |>
    group_by(Skenario, Produk, KapasitasMesin) |>
    summarise(Puncak = max(Hasil, na.rm = TRUE), .groups = "drop") |>
    mutate(Keb = ceiling(Puncak / KapasitasMesin)) |>
    group_by(Skenario) |>
    summarise(Mesin = paste0(Produk, "=", Keb, collapse = ", "), .groups = "drop")

  t2 <- ram |>
    left_join(mesin, by = "Skenario") |>
    mutate(Skenario = factor(Skenario, levels = c("Pesimis", "Normal", "Optimis"))) |>
    arrange(Skenario) |>
    mutate(TotalUnit = format(round(TotalUnit), big.mark = ".", decimal.mark = ","),
           TotalRp   = paste0("Rp ",
                              format(round(TotalRp), big.mark = ".", decimal.mark = ",")))

  hdr <- c("Skenario", "Plan 2026 (unit)", "Nilai Penjualan (Rp)", "Mesin saat Puncak")
  tbl <- t2 |>
    mutate(across(everything(), as.character)) |>
    as.data.frame()
  colnames(tbl) <- hdr
  K <- ncol(tbl); R <- nrow(tbl)
  dd <- data.frame(
    x    = rep(seq_len(K), each = R + 1),
    y    = rep(seq(R + 1, 1), times = K),
    teks = as.character(t(as.matrix(rbind(hdr, tbl)))),
    stringsAsFactors = FALSE
  )
  dd$fondo <- ifelse(dd$y == R + 1, "bold", "plain")

  p <- ggplot(dd, aes(x, y, label = teks, fontface = fondo)) +
    geom_text(size = 5) +
    scale_x_continuous(limits = c(0.4, K + 0.6)) +
    scale_y_continuous(limits = c(0.4, R + 1.6)) +
    labs(title = "What-if: Skenario Plan 2026",
         subtitle = "Optimis = +10% plan; Pesimis = -10%. Slicer Produk/Bulan ikut tabel.") +
    theme_void(base_size = 13) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
          plot.subtitle = element_text(hjust = 0.5, color = "grey40", size = 9))
}
p
# >>> BLOK_RV_V8_END