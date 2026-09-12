# ============================================================
# 03_whatif_visual.R — V4 distribusi + V5/V6 what-if
# Jalan (dari root repo):
#   Rscript "Volume 5 - Causal Inference Sederhana/R/03_whatif_visual.R"
# ============================================================
suppressPackageStartupMessages({ library(dplyr); library(ggplot2); library(tidyr) })
ROOT <- "Volume 5 - Causal Inference Sederhana"
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

# V4 distribusi perubahan per operator
delta <- df %>%
  pivot_wider(id_cols = c(Operator, Dilatih), names_from = Periode, values_from = DefectRate) %>%
  mutate(Delta = Sesudah - Sebelum)
mg <- delta %>% group_by(Dilatih) %>% summarise(M = mean(Delta), .groups = "drop")
p4 <- ggplot(delta, aes(Delta, fill = Dilatih)) +
  geom_histogram(alpha = 0.65, bins = 10, position = "identity", colour = "white") +
  geom_vline(data = mg, aes(xintercept = M, colour = Dilatih),
             linetype = "dashed", linewidth = 1.1, show.legend = FALSE) +
  labs(title = "V4 - Distribusi perubahan tiap operator",
       subtitle = "Garis putus-putus = rata-rata perubahan tiap grup",
       x = "Perubahan defect (Sesudah - Sebelum)", y = "Jumlah operator",
       fill = "Ikut pelatihan?") + tema
ggsave(file.path(OUT, "V4_distribusi_delta.png"), p4, width = 8, height = 5, dpi = 150)
cat("V4 OK\n")

# V5 (WHAT-IF 1): rollout pelatihan ke semua operator
sesudah <- df %>% filter(Periode == "Sesudah")
cacat_aktual <- sum(sesudah$DefectRate / 100 * sesudah$Produksi)
prod_ctrl <- sum(sesudah$Produksi[sesudah$Dilatih == "Tidak"])
hemat <- prod_ctrl * (-did) / 100
dwhat <- data.frame(
  Skenario = factor(c("Aktual", "What-if (latih semua)"),
                    levels = c("Aktual", "What-if (latih semua)")),
  UnitCacat = c(cacat_aktual, cacat_aktual - hemat))
p5 <- ggplot(dwhat, aes(Skenario, UnitCacat, fill = Skenario)) +
  geom_col(width = 0.55, show.legend = FALSE) +
  geom_text(aes(label = sprintf("%.0f unit", UnitCacat)),
            vjust = -0.5, size = 5, fontface = "bold") +
  annotate("text", x = 1.5, y = max(dwhat$UnitCacat) * 0.55,
           label = sprintf("Dicegah = %.0f unit cacat\n(dari %.0f unit produksi kontrol)",
                           hemat, prod_ctrl), size = 4.5, fontface = "bold") +
  labs(title = "V5 (What-if) - Kalau pelatihan diperluas ke semua operator?",
       subtitle = sprintf("Asumsi efek sama (%.2f poin) untuk grup kontrol", did),
       x = NULL, y = "Total unit cacat periode Sesudah") + tema
ggsave(file.path(OUT, "V5_whatif_rollout.png"), p5, width = 8, height = 5, dpi = 150)
cat(sprintf("V5 OK: aktual=%.0f dicegah=%.0f kontrol=%.0f\n", cacat_aktual, hemat, prod_ctrl))

# V6 (WHAT-IF 2): sensitivitas asumsi tren paralel
sken <- data.frame(AsumsiKontrol = seq(-0.5, 0.5, by = 0.25))
sken$DiD <- dl - sken$AsumsiKontrol
p6 <- ggplot(sken, aes(AsumsiKontrol, DiD)) +
  geom_line(linewidth = 1.1, colour = "steelblue") +
  geom_point(size = 3.5, colour = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dotted", colour = "grey40") +
  geom_vline(xintercept = dk, linetype = "dashed", colour = "firebrick") +
  geom_text(aes(label = sprintf("%.2f", DiD)), vjust = -1, size = 4) +
  annotate("text", x = dk, y = min(sken$DiD) - 0.08,
           label = sprintf("Aktual kontrol\n%+.2f", dk),
           colour = "firebrick", size = 4, fontface = "bold") +
  labs(title = "V6 (What-if) - Bagaimana jika asumsi tren paralel salah?",
       subtitle = "Sumbu-x = seandainya perubahan kontrol; sumbu-y = DiD. Selama garis < 0, aman.",
       x = "Asumsi perubahan grup kontrol (poin)", y = "Efek kausal DiD (poin)") + tema
ggsave(file.path(OUT, "V6_whatif_sensitivitas.png"), p6, width = 8, height = 5, dpi = 150)
cat("V6 OK\n")
cat("SELESAI - file di output/:\n")
print(list.files(OUT, pattern = "^V[1-6]_.*\\.png$"))
