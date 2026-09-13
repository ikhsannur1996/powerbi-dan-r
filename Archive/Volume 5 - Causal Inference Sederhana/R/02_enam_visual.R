# ============================================================
# 02_enam_visual.R — Bagian 1: 3 visual utama (V1-V3)
# V1 tren DiD | V2 bar perubahan | V3 spaghetti per operator
# Lanjutan V4-V6 ada di 03_whatif_visual.R
# (Nama file historis "enam_visual": dulu 1 file 6 visual,
#  kini dipecah 2 file agar tiap file cepat di-run.)
# Jalan (dari root repo):
#   Rscript "Archive/Volume 5 - Causal Inference Sederhana/R/02_enam_visual.R"
# ============================================================
suppressPackageStartupMessages({ library(dplyr); library(ggplot2) })
ROOT <- "Archive/Volume 5 - Causal Inference Sederhana"
OUT  <- file.path(ROOT, "output")
if (!dir.exists(OUT)) dir.create(OUT, recursive = TRUE)

df <- read.csv(file.path(ROOT, "data/causal_simple.csv"), stringsAsFactors = FALSE) %>%
  mutate(Periode = factor(Periode, levels = c("Sebelum", "Sesudah")))

sel <- df %>% group_by(Dilatih, Periode) %>%
  summarise(Rata = mean(DefectRate), .groups = "drop")
dl  <- sel$Rata[sel$Dilatih == "Ya" & sel$Periode == "Sesudah"] -
       sel$Rata[sel$Dilatih == "Ya" & sel$Periode == "Sebelum"]
dk  <- sel$Rata[sel$Dilatih == "Tidak" & sel$Periode == "Sesudah"] -
       sel$Rata[sel$Dilatih == "Tidak" & sel$Periode == "Sebelum"]
did <- dl - dk
cat(sprintf("dl=%.3f dk=%.3f DiD=%.3f\n", dl, dk, did))
tema <- theme_minimal(base_size = 12) + theme(plot.title = element_text(face = "bold", size = 14))

# V1 = versi bernomor dari grafik utama 01_did_sederhana.R (did_tren.png).
# Isinya sama; prefix V1_ memudahkan urutan V1-V6 di output/.
# NOTE: sel diurutkan Tidak-dulu lalu Ya (lihat arrange 01), jadi vjust
# dibalik terhadap 01 (vjust>0 = label di bawah titik): atas-bawah-bawah-atas.
sel <- sel %>% arrange(Dilatih, Periode)
p1 <- ggplot(sel, aes(Periode, Rata, group = Dilatih, colour = Dilatih)) +
  geom_line(linewidth = 1.2) + geom_point(size = 4) +
  geom_text(aes(label = sprintf("%.2f", Rata)),
            vjust = c(-1.2, 1.6, 1.6, -1.2), show.legend = FALSE, size = 4.5) +
  scale_y_continuous(expand = expansion(mult = c(0.18, 0.18))) +
  labs(title = "V1 — Apakah pelatihan menurunkan defect?",
       subtitle = sprintf("DiD = %.2f - (%.2f) = %.2f poin (negatif = membaik)", dl, dk, did),
       x = NULL, y = "Rata-rata defect rate (%)", colour = "Ikut pelatihan?") + tema
ggsave(file.path(OUT, "V1_did_tren.png"), p1, width = 8, height = 5, dpi = 150)

# ---- V2: bar perubahan (rumus divisualkan) ----
dbar <- data.frame(Grup = factor(c("Dilatih (Ya)", "Kontrol (Tidak)"),
                   levels = c("Dilatih (Ya)", "Kontrol (Tidak)")), Perubahan = c(dl, dk))
p2 <- ggplot(dbar, aes(Grup, Perubahan, fill = Grup)) +
  geom_col(width = 0.55, show.legend = FALSE) +
  geom_hline(yintercept = 0, colour = "grey40") +
  geom_text(aes(label = sprintf("%+.2f", Perubahan)),
            vjust = ifelse(dbar$Perubahan > 0, -0.6, 1.4), size = 5, fontface = "bold") +
  annotate("text", x = 1.5, y = min(dbar$Perubahan) - 0.25,
           label = sprintf("Selisih (DiD) = %.2f poin", did), size = 4.5, fontface = "bold") +
  labs(title = "V2 — Bandingkan PERUBAHANNYA, bukan level akhirnya",
       subtitle = "Batang = Sesudah minus Sebelum per grup; selisih batang = efek kausal",
       x = NULL, y = "Perubahan defect rate (poin)") + tema
ggsave(file.path(OUT, "V2_bar_perubahan.png"), p2, width = 8, height = 5, dpi = 150)

# ---- V3: spaghetti per operator + rata-rata tebal ----
p3 <- ggplot(df, aes(Periode, DefectRate, group = Operator, colour = Dilatih)) +
  geom_line(alpha = 0.30, linewidth = 0.7) + geom_point(alpha = 0.30, size = 1.5) +
  geom_line(data = sel, aes(Periode, Rata, group = Dilatih, colour = Dilatih),
            inherit.aes = FALSE, linewidth = 1.6) +
  geom_point(data = sel, aes(Periode, Rata, colour = Dilatih), inherit.aes = FALSE, size = 4) +
  labs(title = "V3 — Apakah efeknya merata ke semua operator?",
       subtitle = "Garis tipis = tiap operator; garis tebal = rata-rata grup",
       x = NULL, y = "Defect rate (%)", colour = "Ikut pelatihan?") + tema
ggsave(file.path(OUT, "V3_spaghetti_operator.png"), p3, width = 8, height = 5, dpi = 150)

cat("SELESAI BAGIAN 1 (V1-V3). Lanjutan V4-V6: jalankan 03_whatif_visual.R\n")
