# ============================================================
# 01_analisis_dplyr.R
# Volume 4 - Optimasi Produktivitas Linimas Industri
# Tahap 2: Transformasi & agregasi dengan dplyr
# Input : data/produksi.csv
# Output: output/*.csv (tabel siap visual / siap Power BI)
# Cara jalan (dari root repo "Power BI dan R"):
#   Rscript "Volume 4 - Case Study End-to-End Analytics/R/01_analisis_dplyr.R"
# ============================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(lubridate)
})

ROOT <- "Volume 4 - Case Study End-to-End Analytics"
df <- read.csv(file.path(ROOT, "data/produksi.csv"), stringsAsFactors = FALSE) %>%
  mutate(Tanggal = as.Date(Tanggal))

# ---- 1. KPI ringkas (kartu KPI di Power BI) ----
kpi <- df %>%
  summarise(
    TotalProduksi  = sum(AktualProduksi),
    TotalCacat     = sum(JumlahCacat),
    DefectRatePct  = round(sum(JumlahCacat) / sum(AktualProduksi) * 100, 2),
    PencapaianPct  = round(sum(AktualProduksi) / sum(TargetProduksi) * 100, 2),
    TotalDowntimeMnt = sum(DowntimeMenit),
    RataCycleTime  = round(mean(CycleTimeDetik), 1),
    HariProduksi   = n_distinct(Tanggal)
  )
print(kpi)

# ---- 2. Tren harian (line chart) ----
tren_harian <- df %>%
  mutate(Bulan = floor_date(Tanggal, "month")) %>%
  group_by(Tanggal) %>%
  summarise(
    Produksi = sum(AktualProduksi),
    Cacat    = sum(JumlahCacat),
    DefectRatePct = round(sum(JumlahCacat) / sum(AktualProduksi) * 100, 2),
    DowntimeMnt = sum(DowntimeMenit),
    .groups = "drop"
  ) %>%
  arrange(Tanggal)

# ---- 3. Performa per operator (bar chart) ----
per_operator <- df %>%
  group_by(Operator) %>%
  summarise(
    Produksi = sum(AktualProduksi),
    Cacat    = sum(JumlahCacat),
    DefectRatePct = round(sum(JumlahCacat) / sum(AktualProduksi) * 100, 2),
    ShiftTerbanyak = names(sort(table(Shift), decreasing = TRUE))[1],
    .groups = "drop"
  ) %>%
  arrange(desc(DefectRatePct))

# ---- 4. Performa per mesin & line-shift (bar + heatmap) ----
per_mesin <- df %>%
  group_by(Line, Mesin) %>%
  summarise(
    Produksi = sum(AktualProduksi),
    Cacat    = sum(JumlahCacat),
    DefectRatePct = round(sum(JumlahCacat) / sum(AktualProduksi) * 100, 2),
    DowntimeMnt = sum(DowntimeMenit),
    .groups = "drop"
  ) %>%
  arrange(desc(DefectRatePct))

matriks_line_shift <- df %>%
  group_by(Line, Shift) %>%
  summarise(
    Produksi = sum(AktualProduksi),
    Cacat    = sum(JumlahCacat),
    DefectRatePct = round(sum(JumlahCacat) / sum(AktualProduksi) * 100, 2),
    .groups = "drop"
  )

# ---- 5. Pareto cacat per produk (Pareto chart) ----
pareto_produk <- df %>%
  group_by(Produk) %>%
  summarise(Cacat = sum(JumlahCacat), .groups = "drop") %>%
  arrange(desc(Cacat)) %>%
  mutate(KumulatifPct = round(cumsum(Cacat) / sum(Cacat) * 100, 1))

# ---- 6. Downtime per mesin (untuk rekomendasi maintenance) ----
downtime_mesin <- df %>%
  group_by(Mesin) %>%
  summarise(
    TotalDowntimeMnt = sum(DowntimeMenit),
    RataPerShift = round(mean(DowntimeMenit), 1),
    Kejadian = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(TotalDowntimeMnt))

# ---- 7. Dataset bersih siap Power BI (satu tabel fakta) ----
fakta_powerbi <- df %>%
  mutate(
    DefectRatePct = round(JumlahCacat / AktualProduksi * 100, 2),
    PencapaianPct = round(AktualProduksi / TargetProduksi * 100, 1),
    Bulan = format(Tanggal, "%Y-%m"),
    Hari = weekdays(Tanggal)
  )

# ---- Simpan semua ----
dir.create(file.path(ROOT, "output"), showWarnings = FALSE)
write.csv(tren_harian,        file.path(ROOT, "output/tbl_tren_harian.csv"), row.names = FALSE)
write.csv(per_operator,       file.path(ROOT, "output/tbl_per_operator.csv"), row.names = FALSE)
write.csv(per_mesin,          file.path(ROOT, "output/tbl_per_mesin.csv"), row.names = FALSE)
write.csv(matriks_line_shift, file.path(ROOT, "output/tbl_line_shift.csv"), row.names = FALSE)
write.csv(pareto_produk,      file.path(ROOT, "output/tbl_pareto_produk.csv"), row.names = FALSE)
write.csv(downtime_mesin,     file.path(ROOT, "output/tbl_downtime_mesin.csv"), row.names = FALSE)
write.csv(fakta_powerbi,      file.path(ROOT, "output/fakta_powerbi.csv"), row.names = FALSE)

cat("OK - 7 file agregat tersimpan di", file.path(ROOT, "output"), "\n")
