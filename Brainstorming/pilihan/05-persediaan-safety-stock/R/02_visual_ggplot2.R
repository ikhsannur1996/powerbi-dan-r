# ============================================================
# Opsi 5 - Persediaan & Safety Stock
# R/02_visual_ggplot2.R  --  visual eksplorasi (ggplot2) -> output/*.png
# ============================================================

suppressMessages({ library(dplyr); library(tidyr); library(ggplot2); library(scales) })

args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
out  <- file.path(base, "output"); dir.create(out, showWarnings = FALSE)

d <- read.csv(file.path(base, "data", "persediaan.csv")) |>
  mutate(Tanggal = as.Date(Tanggal),
         Produk  = factor(Produk),
         Bulan   = format(Tanggal, "%Y-%m"))
prod <- read.csv(file.path(base, "data", "produk.csv"))
d <- d |> left_join(prod |> select(Produk, NamaProduk, Kategori, TargetSL), by = "Produk")

tema <- theme_minimal(base_size = 12) +
  theme(plot.title    = element_text(face = "bold"),
        plot.subtitle = element_text(color = "grey40"),
        legend.position = "top")

simpan <- function(nm, p, w = 8, h = 4.6)
  ggsave(file.path(out, nm), p, width = w, height = h, dpi = 150, bg = "white")

# --- V1: Tren permintaan harian + rata-rata 7 hari (per produk) ---
d1 <- d |> group_by(Produk) |> arrange(Tanggal) |>
  mutate(MA7 = as.numeric(stats::filter(Permintaan, rep(1 / 7, 7), sides = 1))) |>
  ungroup()

p1 <- ggplot(d1, aes(x = Tanggal)) +
  geom_line(aes(y = Permintaan), color = "grey70", linewidth = 0.4) +
  geom_line(aes(y = MA7), color = "steelblue", linewidth = 1) +
  facet_wrap(~Produk, scales = "free_y", ncol = 3) +
  labs(title = "Tren permintaan harian per produk",
       subtitle = "garis biru = rata-rata bergerak 7 hari; P-03/P-04 berpuncak end-of-quarter",
       x = NULL, y = "Permintaan (unit)") +
  tema
simpan("V1_tren_permintaan.png", p1, w = 10, h = 6)

# --- V2: Sebaran permintaan harian (boxplot per produk) ---
p2 <- ggplot(d, aes(x = Produk, y = Permintaan, fill = Kategori)) +
  geom_boxplot(alpha = 0.65, outlier.shape = NA) +
  geom_jitter(width = 0.14, alpha = 0.15, size = 0.7) +
  scale_fill_manual(values = c(Premium = "#C44E52", Standar = "#DD8452", Mass = "#55A868")) +
  labs(title = "Sebaran permintaan harian per produk",
       subtitle = "CV ~0,8 produk Premium vs ~0,12 produk Mass - determinan kebutuhan stok pengaman",
       x = NULL, y = "Permintaan (unit)", fill = "Kategori") +
  tema
simpan("V2_boxplot_permintaan.png", p2, w = 8, h = 4.6)

# --- V3: ABC Pareto (share nilai + kumulatif) ---
abc <- read.csv(file.path(base, "output", "tbl_abc.csv")) |>
  mutate(Produk = factor(Produk, levels = Produk))

p3 <- ggplot(abc, aes(x = Produk)) +
  geom_col(aes(y = Share), fill = "steelblue", width = 0.65) +
  geom_text(aes(y = Share, label = scales::percent(Share, accuracy = 0.1)),
            vjust = -0.4, size = 3) +
  geom_line(aes(y = Kum, group = 1), color = "darkred", linewidth = 1) +
  geom_point(aes(y = Kum), color = "darkred", size = 2.5) +
  geom_hline(yintercept = 0.75, linetype = "dashed", color = "grey40") +
  geom_hline(yintercept = 0.975, linetype = "dashed", color = "grey60") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "Pareto ABC - share nilai pemakaian tahunan",
       subtitle = "3 produk A = 74,2% nilai; P-04 kandidat B; O-Ring & Wiper = C ~5%",
       x = NULL, y = "Share nilai tahunan") +
  tema + theme(axis.text.x = element_text(angle = 20, hjust = 1))
simpan("V3_pareto_abc.png", p3)
# --- V4: EOQ - kurva total cost vs lot order (3 produk representatif) ---
K_order <- 150000; h_rate <- 0.30
dem2 <- read.csv(file.path(base, "output", "tbl_policy.csv")) |>
  select(Produk, NamaProduk, Annual, EOQ, HargaUnit)

eoq_d <- do.call(rbind, lapply(c("P-01", "P-03", "P-06"), function(p) {
  r <- dem2 |> filter(Produk == p)
  qs <- seq(50, max(r$Annual * 1.5, 500), length.out = 60)
  data.frame(Produk = p, NamaProduk = r$NamaProduk, Q = qs,
             Cost = (r$Annual / qs) * K_order + (qs / 2) * h_rate * r$HargaUnit,
             EOQ = r$EOQ)
}))

p4 <- ggplot(eoq_d, aes(x = Q, y = Cost)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_vline(aes(xintercept = EOQ), linetype = "dashed", color = "darkred") +
  facet_wrap(~Produk, scales = "free", ncol = 3) +
  scale_y_continuous(labels = comma_format()) +
  labs(title = "EOQ: trade-off tarif order vs cost holding",
       subtitle = "garis putus-putus = EOQ; produk Premium order sedikit, produk Mass order bulk",
       x = "Lot order (Q, unit)", y = "Total annual cost (order + holding)") +
  tema
simpan("V4_eoq_cost.png", p4, w = 10, h = 4.6)

# --- V5: Stockout days per produk + service level ---
perf <- read.csv(file.path(base, "output", "tbl_perf.csv")) |>
  left_join(prod |> select(Produk, NamaProduk, Kategori, TargetSL), by = "Produk") |>
  mutate(Produk = reorder(Produk, StockoutDays))

p5 <- ggplot(perf, aes(x = reorder(Produk, StockoutDays), y = StockoutDays, fill = Kategori)) +
  geom_col(width = 0.65) +
  geom_text(aes(label = sprintf("%d hari (SL %s)", StockoutDays,
                                scales::percent(1 - StockoutDays / 468, accuracy = 0.1))),
            hjust = -0.05, size = 3) +
  coord_flip() +
  scale_fill_manual(values = c(Premium = "#C44E52", Standar = "#DD8452", Mass = "#55A868")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.18))) +
  labs(title = "Stockout days per produk (18 bulan)",
       subtitle = "P-03/P-04 stockout saat puncak Eoq; P-05/P-06 overstock - nol stockout",
       x = NULL, y = "Hari stockout (dari 468)", fill = "Kategori") +
  tema + theme(legend.position = "none")
simpan("V5_stockout_bar.png", p5)
# --- V6: What-if - safety stock dibutuhkan untuk setiap service level ---
sken <- read.csv(file.path(base, "output", "tbl_skenario.csv")) |>
  left_join(dem2 |> select(Produk, NamaProduk), by = "Produk") |>
  mutate(Produk = factor(Produk, levels = c("P-01", "P-02", "P-03", "P-04", "P-05", "P-06")))

p6 <- ggplot(sken, aes(x = SL, y = SS_rec, color = Produk)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  facet_wrap(~Produk, ncol = 3, scales = "free_y") +
  scale_x_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "Safety stock dibutuhkan per service level",
       subtitle = "P-01/P-02 butuh SS >> policy saat ini; P-05/P-06 policy saat ini 30x over",
       x = "Service level target", y = "Safety stock (unit)", color = NULL) +
  tema + theme(legend.position = "none")
simpan("V6_whatif_safety.png", p6, w = 10, h = 5.5)

# --- V7: Timeline stok P-01 vs reorder point (spotlight stockout) ---
policy01 <- read.csv(file.path(base, "output", "tbl_policy.csv")) |>
  filter(Produk == "P-01")
p01 <- d |> filter(Produk == "P-01")

p7 <- ggplot(p01, aes(x = Tanggal, y = StokEnd)) +
  geom_line(color = "steelblue", linewidth = 0.7) +
  geom_point(data = p01 |> filter(Stockout == 1),
             aes(x = Tanggal, y = 0), color = "#C44E52", size = 1.6) +
  geom_hline(yintercept = policy01$ROP_rec, linetype = "dashed",
             color = "darkred", linewidth = 0.9) +
  labs(title = "P-01 Bearing Assembly - stok vs reorder point",
       subtitle = sprintf("ROP rekomendasi = %.0f unit; titik merah = hari stockout (22 hari)",
                          policy01$ROP_rec),
       x = NULL, y = "StokEnd (unit)") +
  tema
simpan("V7_stok_timeline_p01.png", p7, w = 10, h = 4.6)

# --- V8: CV bulanan vs laju stockout (regresi) ---
cv_bulan <- d |> group_by(Produk, Bulan) |>
  summarise(M = sum(Permintaan), .groups = "drop") |>
  group_by(Produk) |> summarise(CVBulan = sd(M) / mean(M), .groups = "drop")

lvl <- perf |>
  mutate(ProdukC = as.character(Produk),
         Laju = StockoutDays / 468) |>
  left_join(cv_bulan, by = c("ProdukC" = "Produk"))
reg <- lm(Laju ~ CVBulan, data = lvl)

p8 <- ggplot(lvl, aes(x = CVBulan, y = Laju)) +
  geom_smooth(method = "lm", formula = y ~ x, color = "darkred", fill = "grey85", se = TRUE) +
  geom_point(aes(color = Kategori), size = 4) +
  geom_text(aes(label = ProdukC), vjust = -1.2, size = 3.2) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "Laju stockout vs variasi bulanan permintaan",
       subtitle = sprintf("R2 = %.2f; p = %.3g - variasi bulanan (musiman) mendikte kebutuhan SS",
                          summary(reg)$r.squared, tidy2 <- summary(reg)$coefficients[2, 4]),
       x = "CV permintaan bulanan", y = "Laju stockout (% hari)", color = "Kategori") +
  tema
simpan("V8_cvb_vs_stockout.png", p8)

cat("\nVisual Opsi 5 selesai. 8 file PNG di output/.\n")