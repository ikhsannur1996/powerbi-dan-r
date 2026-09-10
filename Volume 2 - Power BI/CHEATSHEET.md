# 📊 CHEATSHEET Volume 2 — Power BI + R (Insight to Impact)

> Referensi cepat untuk menghafal **alur Power BI**, **DAX**, **R di Power Query**, dan **R visual ggplot2**. Pasangkan dengan `README.md` Volume 2.

---

## 1. Alur Kerja Utama (Hafalkan)

```text
CSV / Excel
   └─> Power Query + R (Run R script)  ->  CleanData
        └─> Data model (fakta & dimensi)
             └─> Visual native (KPI, chart, slicer)
                  └─> R visual (ggplot2)
                       └─> Insight (Kondisi-Bukti-Tindakan)
```

**Aturan emas:**
1. Selalu pilih **Transform Data** saat import, bukan langsung Load.
2. Output R script di Power Query harus bernama jelas (`CleanData`).
3. Kolom yang dipakai R visual **WAJIB** dimasukkan ke **Values**.
4. R visual dirender sebagai gambar — tidak interaktif di dalamnya.

---

## 2. Import & Clean di Power Query dengan R

### Langkah
1. **Get data > Text/CSV** → pilih file → **Transform Data**.
2. Power Query Editor → **Transform > Run R script**.
3. Input tersedia sebagai data frame `dataset`.
4. Tulis R, hasil akhir disimpan di objek (misal `CleanData`).
5. Pilih `CleanData` di navigator → **Close & Apply**.

### Script pola (wajib ingat)

```r
library(dplyr)
library(lubridate)

CleanData <- dataset |>
  mutate(
    InspectionDate = as.Date(InspectionDate),
    Line = trimws(toupper(Line)),
    DefectType = trimws(DefectType),
    DefectType = if_else(DefectType == "" | is.na(DefectType), "NONE", DefectType),
    Inspected = as.integer(Inspected),
    Defect = as.integer(Defect),
    CycleTimeSec = as.numeric(CycleTimeSec)
  ) |>
  filter(Inspected > 0, Defect >= 0, Defect <= Inspected) |>
  mutate(
    DefectRate = Defect / Inspected,
    FirstPassYield = 1 - DefectRate,
    Month = floor_date(InspectionDate, "month"),
    QualityFlag = if_else(DefectRate > 0.05, "Above target", "On target")
  )
```

> Jadi di RStudio dulu sebelum masuk Power BI — lebih mudah debug.

---

## 3. DAX — KPI yang Sering Dipakai

```dax
// Measure dasar
Total Inspected   = SUM(CleanData[Inspected])
Total Defect      = SUM(CleanData[Defect])

// Pakai DIVIDE (aman untuk pembagian nol)
Defect Rate       = DIVIDE( SUM(CleanData[Defect]), SUM(CleanData[Inspected]) )
First Pass Yield  = 1 - [Defect Rate]
Average Cycle Time= AVERAGE(CleanData[CycleTimeSec])
```

**Aturan DAX cepat:**
- `DIVIDE(a, b)` lebih aman daripada `a / b`.
- Gunakan `[Measure]` di dalam measure lain (referensi).
- Nama measure ≠ nama kolom (hindari kebingungan di mana dikira R).
- Letakkan measure di tabel tersendiri / folder Display Folder.

---

## 4. Visual Native — Setup Cepat

| Visual | Field | Catatan |
| --- | --- | --- |
| **KPI card** | `Total Inspected`, `Total Defect`, `Defect Rate`, `First Pass Yield` | format %, 1 desimal |
| **Column chart** | X: `Line`; Y: `Defect Rate` | Y-axis % , judul pertanyaan |
| **Slicer** | `Month`, `Line`, `DefectType` | single/multi select |
| **Table** | `Line`, KPI measures | + conditional formatting Defect Rate |
| **Tooltip page** | `Total Inspected`, `Total Defect` | hover pada bar/point |

---

## 5. R Visual (ggplot2) dalam Power BI

1. Klik ikon **R** di panel Visualizations.
2. Masukkan kolom di **Values**: `InspectionDate`, `Line`, `DefectRate`, `Inspected`.
3. Paste kode di editor R.
4. Render sebagai gambar PNG — ukur resize.

### Script template

```r
library(ggplot2)
library(scales)

plot_data <- dataset
plot_data$InspectionDate <- as.Date(plot_data$InspectionDate)
plot_data$DefectRate <- as.numeric(plot_data$DefectRate)

ggplot(plot_data, aes(x = InspectionDate, y = DefectRate, color = Line)) +
  geom_point(aes(size = Inspected), alpha = 0.75) +
  geom_smooth(method = "loess", se = FALSE) +
  geom_hline(yintercept = 0.05, linetype = "dashed", color = "red") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Tren defect rate", x = "Tanggal", y = "Defect rate (%)") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")
```

> Semua kolom dipakai harus masuk **Values**. Filter dari slicer memengaruhi `dataset` yang dikirim ke R.

---

## 6. Insight — Template Kondisi-Bukti-Tindakan

```text
🔎 KONDISI  : Lini/defect yang paling perlu perhatian adalah ....
📊 BUKTI    : defect rate ...% (vs target 5%), tren ..., total inspected ... unit.
⚡ TINDAKAN : prioritaskan investigasi ... dengan memeriksa ....
```

**Tips:** jangan prioritaskan hanya dari total defect — bandingkan **defect rate** karena volume inspeksi beda antar lini.

---

## 7. Tips & Trik Volume 2

1. **Uji R dulu di RStudio** sebelum menaruh di Power Query — lebih cepat debug.
2. **Output bersih** bernama `CleanData` — konsisten di setiap file.
3. **Kolom R visual harus di Values** — kalau tidak, data tidak sampai ke R.
4. R visual tidak "hover"; jangan andalkan interaksi di dalam gambar.
5. **Sliceer memengaruhi R visual** selama kolom terkait dalam Values.
6. **DAX DIVIDE** > `/` untuk menghindari pembagian nol.
7. **Jangan duplikasi nama** measure & kolom R (`DefectRate`) → pakai `Overall Defect Rate`.
8. **Conditional formatting** pada tabel untuk skor lima: red>0.05, green<=0.05.
9. **Format angka**: persen 1 desimal, ribuan separator untuk count.
10. Confirm **R dijalankan dulu di RStudio** agar instalasi package pasti ada.
11. Set **R path** jika Power BI tidak menemukan R: Options > R scripting.
12. Pastikan tanggal bertipe **Date** di Power Query, bukan string.
13. Agregasi untuk R visual: lakukan di Power Query / R, jangan biarkan mentah.
14. Dashboard minimal: 4 KPI, 1 visual native, 1 R visual, slicer, insight.
15. **Judul berupa pertanyaan** seperti "Lini mana paling perlu investigasi?"
16. Tooltip tidak ada di gambar R — buat page tooltip custom jika perlu.
17. Gunakan **page report baru** untuk visual statistik Volume 1 (opsional).
18. **Uji sensitif bulan terbaru** — kesimpulan berubah? Itu penting dilaporkan.
19. Jangan lupa `library(ggplot2)` & `library(scales)` di R visual.
20. Simpan `CleanData` sebagai tabel di model (bukan query saja).

---

## 8. Checklist Cepat Sebelum Submit

- [ ] Import pakai **Transform Data** (bukan Load).
- [ ] `CleanData` terbentuk & tipe benar.
- [ ] 4 KPI konsisten.
- [ ] 1 visual native.
- [ ] 1 R visual + merespons slicer.
- [ ] Slicer Month/Line/DefectType.
- [ ] Insight: Kondisi-Bukti-Tindakan.

---

*Cheatsheet Volume 2 — ingat: CleanData → KPI DAX → visual native → R visual → insight.*