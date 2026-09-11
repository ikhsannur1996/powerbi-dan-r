# ============================================================
# 01_did_sederhana.R — Difference-in-Differences (DiD) paling simpel
# IDE: Korelasi != Kausal. Bandingkan PERUBAHAN, bukan level akhir.
# Cara jalan (dari root repo):
#   Rscript "Volume 5 - Causal Inference Sederhana/R/01_did_sederhana.R"
# ============================================================
suppressPackageStartupMessages({ library(dplyr); library(ggplot2) })
ROOT <- "Volume 5 - Causal Inference Sederhana"

df <- read.csv(file.path(ROOT, "data/causal_simple.csv"), stringsAsFactors = FALSE) %>%
  mutate(Periode = factor(Periode, levels = c("Sebelum", "Sesudah")))

# ---- 1. Rata-rata 4 sel (cara manual, tanpa regresi) ----
sel <- df %>%
  group_by(Dilatih, Periode) %>%
  summarise(Rata = round(mean(DefectRate), 3), .groups = "drop")
print(sel)

# ---- 2. Estimasi DiD manual ----
perubahan_latih  <- sel$Rata[sel$Dilatih == "Ya" & sel$Periode == "Sesudah"] -
                    sel$Rata[sel$Dilatih == "Ya" & sel$Periode == "Sebelum"]
perubahan_kontrol <- sel$Rata[sel$Dilatih == "Tidak" & sel$Periode == "Sesudah"] -
                    sel$Rata[sel$Dilatih == "Tidak" & sel$Periode == "Sebelum"]
did <- round(perubahan_latih - perubahan_kontrol, 3)
cat(sprintf("Perubahan grup latih   : %.3f\n", perubahan_latih))
cat(sprintf("Perubahan grup kontrol : %.3f\n", perubahan_kontrol))
cat(sprintf("Efek kausal (DiD)      : %.3f poin defect\n", did))

# ---- 3. Cara regresi (hasil HARUS sama dengan manual) ----
df$Sesudah <- ifelse(df$Periode == "Sesudah", 1, 0)
df$Treat   <- ifelse(df$Dilatih == "Ya", 1, 0)
m <- lm(DefectRate ~ Treat + Sesudah + Treat:Sesudah, data = df)
cat("--- ringkasan regresi ---\n"); print(summary(m))

# ---- 4. Satu grafik: garis tren dua grup ----
rata <- df %>% group_by(Dilatih, Periode) %>% summarise(Rata = mean(DefectRate), .groups = "drop") %>%
  arrange(Dilatih, Periode) %>%
  mutate(Lab = sprintf("%.2f", Rata),
         Nudge = c(-0.13, 0.13, 0.13, -0.13))
p <- ggplot(rata, aes(Periode, Rata, group = Dilatih, colour = Dilatih)) +
  geom_line(linewidth = 1.2) + geom_point(size = 4) +
  geom_text(aes(y = Rata + Nudge, label = Lab), show.legend = FALSE, size = 4.5) +
  scale_y_continuous(expand = expansion(mult = c(0.18, 0.18))) +
  labs(title = "Apakah pelatihan menurunkan defect?",
       subtitle = sprintf("DiD = %.2f - (%.2f) = %.2f poin  (negatif = membaik)",
                          perubahan_latih, perubahan_kontrol, did),
       x = NULL, y = "Rata-rata defect rate (%)", colour = "Ikut pelatihan?") +
  theme_minimal(base_size = 13) + theme(plot.title = element_text(face = "bold"))
ggsave(file.path(ROOT, "output/did_tren.png"), p, width = 8, height = 5, dpi = 150)
cat("tersimpan: output/did_tren.png\n")
