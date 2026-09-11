# Case 03 — Process Capability (Cp/Cpk)

> **Pertanyaan bisnis:** "Proses kita stabil (Case 02) — tapi apakah ia **mampu** memenuhi target spesifikasi defect rate ≤ 5%?"
>
> **Alat IE:** Process Capability Index. Sementara control chart membandingkan proses dengan **dirinya sendiri** (batas kontrol), capability membandingkan variasi proses dengan **spesifikasi** (USL/LSL). Stabil adalah syarat, capable adalah tujuan.

## 1. Konsep

Untuk kasus satu sisi (hanya USL — defect rate tidak punya LSL):

```text
Cpu = (USL - μ) / (3σ)
```

| Cpk | Makna |
| --- | --- |
| < 1,00 | Tidak capable — lebih dari 0,27% produk di luar spesifikasi |
| 1,00–1,33 | Marginal |
| ≥ 1,33 | Capable (standar umum industri) |
| ≥ 1,67 | World class |

Rumus standar dua sisi: `Cp = (USL - LSL) / (6σ)`, `Cpk = min(Cpu, Cpl)`.

## 2. Analisis

```r
library(dplyr)
library(ggplot2)

inspeksi <- read.csv("quality_inspection.csv")

rate <- inspeksi |>
  mutate(DefectRate = Defect / Inspected)

USL <- 0.05          # spesifikasi: defect rate maksimum 5%
target <- 0.04       # target manajemen 4%

mu <- mean(rate$DefectRate)      # 0,041
s  <- sd(rate$DefectRate)        # 0,0258

cpu <- (USL - mu) / (3 * s)
cpu    # 0,116 → JAUH di bawah 1,00
```

## 3. Visualisasi: Distribusi vs Spesifikasi

```r
ggplot(rate, aes(x = DefectRate)) +
  geom_histogram(aes(y = after_stat(density)), binwidth = 0.01,
                 fill = "lightblue", color = "white") +
  geom_density(linewidth = 1, color = "steelblue") +
  geom_vline(xintercept = USL, color = "red", linetype = "dashed") +
  geom_vline(xintercept = target, color = "darkgreen", linetype = "dotted") +
  geom_vline(xintercept = mu, color = "grey30") +
  annotate("text", x = USL + 0.002, y = 8, label = "USL 5%",
           color = "red", size = 3.5) +
  annotate("text", x = target - 0.004, y = 8, label = "Target 4%",
           color = "darkgreen", size = 3.5) +
  scale_x_continuous(labels = percent) +
  labs(title = "Distribusi Defect Rate vs Spesifikasi",
       subtitle = paste0("Cpu = ", round(cpu, 3),
                         " — proses tidak capable"),
       x = "Defect rate", y = "Densitas") +
  theme_minimal()
```

## 4. Hasil & Interpretasi

| Metrik | Nilai | Artinya |
| --- | --- | --- |
| μ (rata-rata DR) | 4,10% | Di atas target 4% |
| σ (standar deviasi) | 2,58% | Variasi sangat lebar relatif ke spesifikasi |
| **Cpu** | **0,116** | Tidak capable (harusnya ≥ 1,33) |
| P(DR > USL) asumsi normal | ≈ 36,4% | ~1 dari 3 kelompok inspeksi berpotensi melanggar spesifikasi |

- Cpu hanya **0,116** — jauh dari 1,00. Proses tidak hanya bergeser ke atas (μ dekat USL), tetapi **variasinya juga terlalu besar** (σ = 2,58% vs jarak USL-μ hanya 0,9%).
- Angka ±3σ: proses membutuhkan μ turun ke ±3σ dari USL → perlu μ ≈ 5% - 3×2,58% = **-2,7%**, artinya dengan variasi sekarang, spesifikasi 5% mustahil dipenuhi walau rata-rata diturunkan. **Variasi harus dikurangi lebih dulu.**
- Perhatikan perbedaan grain of analysis: 48 baris per-inspeksi vs agregat harian (Case 02). Capability dihitung pada unit analisis yang sama dengan spesifikasi yang diterapkan.

## 5. Rekomendasi

1. **Turunkan variasi dulu, baru geser mean** — standardisasi SOP antar shift/lini, Poka-Yoke pada titik defect utama (Scratch & Dimension — Case 01).
2. Susun **roadmap**: Fase 1 target Cpk 1,00 (μ ≤ 2,6% dengan σ 0,8%), Fase 2 target 1,33.
3. Ukur capability **per lini** — lini B (Case 05: defect rate 7,3%) mendominasi kegagalan capability keseluruhan; memperbaiki B saja dapat menggeser capability global secara signifikan.
4. Jadikan Cpk sebagai KPI bulanan di dashboard (Volume 2).

## 6. Latihan Mandiri

1. Hitung Cpu **per lini** (data `qc_hasil_produksi.csv`, spesifikasi 5%). Lini mana yang paling capable?
2. Simulasi: berapa Cpk bila μ turun ke 2,5% dan σ menjadi 1%? Gunakan rumus yang sama.
3. Jelaskan dengan kalimat sendiri mengapa proses yang *in control* (Case 02) bisa *not capable* (Case 03).

## Jawaban ringkas latihan

```r
# 1 — Cpu per lini
hasil <- read.csv("qc_hasil_produksi.csv")

hasil |>
  group_by(Lini) |>
  summarise(
    mu  = sum(UnitsDefect) / sum(UnitsProduced),
    sd  = sd(UnitsDefect / UnitsProduced),
    Cpu = (0.05 - mu) / (3 * sd),
    .groups = "drop"
  )
# Lini C paling capable, lini B terburuk — konsisten dengan case 05.

# 2 — simulasi
(0.05 - 0.025) / (3 * 0.01)   # 0,833 → masih di bawah 1,33; butuh μ 2% dgn σ 0,75%
                              # agar Cpk = 1,33: (0.05-mu)/(3*sigma) = 1.33
```

3. *In control* = variasi stabil & dapat diprediksi (tidak ada special cause). *Capable* = distribusi proses berada di dalam spesifikasi. Proses bisa sangat stabil memproduksi hasil yang salah — seperti mesin yang presisi menembak di samping target.

---

[← Daftar case](README.md) | [Lanjut: Case 04 — OEE & Downtime](case-04-oee-downtime.md)
