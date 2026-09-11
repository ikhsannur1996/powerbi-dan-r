# 🎯 Volume 5 — Causal Inference Sederhana (Studi Kasus Pelatihan Operator)

> Versi **paling simpel**: 1 pertanyaan, 1 metode (Difference-in-Differences), 1 grafik.
> Prasyarat: bisa `filter/summarise` (Volume 0) dan baca scatter/line chart.

---

## 1. Cerita (1 paragraf)

Manajer melatih 20 operator yang defect-nya tinggi. Sesudah pelatihan, defect mereka
turun. **Apakah pelatihan yang menyebabkan penurunan itu?** Tidak bisa langsung
disimpulkan — mungkin defect turun sendiri (musim, mesin baru, dll). Kita butuh
**grup pembanding** (20 operator tak dilatih) dan bandingkan **perubahannya**.

## 2. Data — `data/causal_simple.csv` (80 baris × 5 kolom)

| Kolom | Isi |
|---|---|
| `Operator` | OP-T01…T20 (dilatih), OP-C01…C20 (kontrol) |
| `Dilatih` | Ya / Tidak |
| `Periode` | Sebelum / Sesudah |
| `DefectRate` | defect rate (%) tiap operator tiap periode |
| `Produksi` | unit (kontrol tambahan, tidak dipakai di versi simpel) |

Jebakan yang sengaja ditanam: grup latih **memang mulai lebih buruk** (rata-rata
3,99% vs 3,12%). Jadi perbandingan "sesudah saja" (2,32 vs 3,17) **melebih-lebihkan**
efek pelatihan. Inilah *selection bias* — alasan kita butuh DiD.

Buat ulang data kapan saja: `Rscript "Volume 5 - Causal Inference Sederhana/R/00_buat_data.R"`

## 3. Metode — Difference-in-Differences (1 rumus)

```text
Efek kausal = (Latih_sesudah − Latih_sebelum) − (Kontrol_sesudah − Kontrol_sebelum)
            =        PERUBAHAN grup latih    −      PERUBAHAN grup kontrol
```

Logika: perubahan grup kontrol = "yang akan terjadi tanpa pelatihan".
Mengurangkannya membuang tren umum, menyisakan efek murni pelatihan.
Asumsi satu-satunya: **tren paralel** — tanpa pelatihan, kedua grup akan bergerak
sejajar (masuk akal di sini karena periode pendek & pabrik yang sama).

## 4. Hasil (angka aktual dari data)

| Grup | Sebelum | Sesudah | Perubahan |
|---|---|---|---|
| Dilatih | 4,00% | 2,32% | **−1,67** |
| Kontrol | 3,12% | 3,17% | **+0,05** |

**Efek kausal = −1,67 − (+0,05) = −1,73 poin defect** (p < 0,001, signifikan).
Cara regresi `lm(DefectRate ~ Treat + Sesudah + Treat:Sesudah)` memberi angka
**persis sama** (−1,726) — koefisien interaksi `Treat:Sesudah` itulah efek kausal.

![Grafik DiD](output/did_tren.png)

## 5. Kesimpulan Manajer (1 kalimat)

> Pelatihan menurunkan defect sekitar **1,7 poin** — operator yang tadinya terburuk
> (4%) kini jadi terbaik (2,3%), jadi **lanjutkan & luaskan pelatihan ke semua shift**.

## 6. Cara Menjalankan

```bash
Rscript "Volume 5 - Causal Inference Sederhana/R/00_buat_data.R"  # opsional
Rscript "Volume 5 - Causal Inference Sederhana/R/01_did_sederhana.R"
```

## 7. Latihan (3 soal cepat)

1. Hitung manual di kertas: (2,32 − 4,00) − (3,17 − 3,12) = …? (jawaban: −1,73)
2. Mengapa "bandingkan sesudah saja" (2,32 vs 3,17 = selisih −0,85) salah? (petunjuk: level awal beda)
3. Kapan asumsi tren paralel rusak? (contoh: mesin grup latih diganti berbarengan dengan pelatihan)
