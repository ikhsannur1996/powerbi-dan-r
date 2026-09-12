# Materi 08 — Cleaning Data & Pipeline Lengkap

> Pendamping Volume 0 · Waktu baca ±12 menit · Dataset `quality_inspection.csv`.
> Prinsip: **diagnosa dulu → perbaiki → validasi**. Jangan langsung visualisasi dari data mentah.

---

## 1. Materi singkat

Data lapangan selalu kotor. Tiga jenis kotoran + obatnya:

| Jenis | Contoh | Obat |
| --- | --- | --- |
| Missing (`NA`) | `CycleTimeSec` kosong | `filter(!is.na(...))` (buang) atau `mutate()` isi nilai |
| Invalid (tidak masuk akal) | `Defect = -1`, `Defect > Inspected` | ubah ke `NA` dulu (`ifelse()`), lalu saring |
| Format berantakan | `" b "` (spasi + huruf kecil) | `trimws(toupper(...))` di `mutate()` |

Alur baku (sesuai `quality_inspection_cleaning.R` di root project):

```text
baca -> rapikan teks & tipe -> tandai invalid jadi NA -> saring baris valid
     -> tambah kolom turunan (DefectRate, QualityFlag) -> validasi -> simpan CSV
```

Kenapa invalid dijadikan `NA` dulu, bukan langsung dibuang? Supaya jejaknya jelas di kode (audit trail): baris mana yang salah input tetap terlihat sebagai NA sebelum disaring.

---

## 2. Contoh 1 — Buat data kotor + diagnosa

Untuk belajar, kita rusakkan salinan data secara terkontrol (`set.seed(123)` agar hasilnya sama setiap run):

```r
library(dplyr)
quality <- read.csv("quality_inspection.csv")

set.seed(123)
quality_dirty <- quality
quality_dirty$CycleTimeSec[sample(1:nrow(quality), 3)] <- NA   # 3 NA
quality_dirty$Defect[sample(1:nrow(quality), 2)] <- -1         # defect negatif (salah input)
quality_dirty$Line[sample(1:nrow(quality), 2)] <- " b "        # spasi + huruf kecil

sum(is.na(quality_dirty$CycleTimeSec))   # 3
quality_dirty |> filter(Defect < 0 | Defect > Inspected) |> select(Line, Inspected, Defect, CycleTimeSec)
```

Output:

```text
[1] 3
  Line Inspected Defect CycleTimeSec
1    B       130     -1           46
2    C       138     -1           41
```

## 3. Contoh 2 — Pipeline cleaning lengkap (satu pipe)

```r
quality_clean <- quality_dirty |>
  mutate(
    Line   = trimws(toupper(Line)),          # " b " -> "B"
    Defect = ifelse(Defect < 0, NA, Defect)  # negatif -> NA (jejak!)
  ) |>
  filter(
    !is.na(CycleTimeSec),   # buang 3 baris NA
    Inspected > 0,
    Defect <= Inspected     # NA ikut gugur di sini (NA <= x = NA = tidak lolos filter)
  ) |>
  mutate(
    DefectRate  = round(Defect / Inspected, 4),
    QualityFlag = ifelse(DefectRate > 0.05, "Above", "On target")
  )
```

Penjelasan per langkah: (1) teks dirapikan — `" b "` jadi `"B"`; (2) defect −1 jadi NA; (3) tiga saringan — baris NA cycle time gugur, baris defect-NA gugur karena `NA <= Inspected` = NA; (4) kolom turunan seperti Materi 06.

## 4. Contoh 3 — Validasi (wajib, jangan dilewatkan)

```r
nrow(quality_dirty)                    # 48 (sebelum)
nrow(quality_clean)                    # 43 (sesudah: 3 NA + 2 invalid gugur)
sum(is.na(quality_clean$CycleTimeSec)) # 0
table(quality_clean$Line)              # hanya A, B, C yang rapi
```

Output:

```text
[1] 48
[1] 43

 A  B  C
12 16 15
[1] 0
```

Rumus validasi: baris menyusut 48 → 43 (5 gugur). Tidak ada NA cycle time tersisa. Kolom Line hanya A/B/C. Kalau salah satu gagal, pipeline-nya yang salah — bukan datanya.

## 5. Contoh 4 — Simpan hasil bersih

```r
write.csv(quality_clean, "quality_clean.csv", row.names = FALSE)
```

Risiko tanpa validasi: grafik dan ringkasan di materi berikutnya diam-diam memakai 5 baris sampah — defect rate dan ranking lini ikut salah tanpa pesan error apa pun.

## 6. Contoh 5 — Lapangan: data `qc_hasil_produksi.csv` (458 baris, punya NA & negatif)

Data produksi harian menyimpan kesalahan nyata:

```r
produksi <- read.csv("qc_hasil_produksi.csv", stringsAsFactors = FALSE)

sapply(produksi, function(z) sum(is.na(z)))   # TempC 20, HumidityPct 20, DowntimeMin 12

produksi |>
  filter(DowntimeMin < 0 | is.na(DowntimeMin)) |>
  select(Tanggal, Lini, Shift, DowntimeMin) |>
  head(4)
```

Output:

```text
     Tanggal  Lini  Shift  DowntimeMin
1 2026-07-11     A   Pagi           -12
2 2026-07-20     C   Pagi            -8
3 2026-07-21     A   Pagi            NA
4 2026-07-25     C   Sore            -5
```

Penjelasan: `DowntimeMin` ada yang **negatif** (-12, -8, -5) = mustahil secara fisik, dan ada `NA`. Pipeline bersih yang benar:

```r
produksi_clean <- produksi |>
  filter(!is.na(TempC), !is.na(HumidityPct), !is.na(DowntimeMin)) |>
  filter(DowntimeMin >= 0) |>        # buang negatif
  mutate(DefectRate = UnitsDefect / UnitsProduced)

nrow(produksi)                    # 458
nrow(produksi_clean)              # 405 (53 baris gugur karena NA/negatif)
```

Catatan: 20 baris `TempC` NA dan 20 baris `HumidityPct` NA ternyata **pada baris yang sama** (tumpang-tindih), ditambah 12 NA `DowntimeMin` dan 3 negatif → total kombinasi unik 53 baris gugur (458 − 405). Cek: `sum(is.na(produksi_clean$TempC))` = 0, `min(produksi_clean$DowntimeMin)` = 0. Kalau tidak dibersihkan, `mean(produksi$DowntimeMin)` ikut `NA` dan rata-rata jadi meleset.

---

## 7. Coba sendiri (±7 menit)

1. Ulangi contoh 1–3 dengan `set.seed(456)`. Berapa `nrow(quality_clean)` sekarang? (Acuan: belum tentu 43 — posisi rusak acak, tapi rumusnya sama.)
2. Tambahkan saringan `CycleTimeSec > 0` ke contoh 2. Berapa baris gugur tambahan? (Acuan: `0` — dataset ini tidak punya cycle time negatif/nol.)
3. Ganti ambang `QualityFlag` contoh 2 menjadi 3%. Bandingkan `table()`-nya.
4. Dari `produksi`, hitung `mean(DowntimeMin)` tanpa dan dengan `na.rm = TRUE` — jelaskan bedanya.
5. Amati `produksi_clean`: berapa `max(DowntimeMin)` yang tersisa? (Acuan: `234` — ditahan, bukan dibuang: nilai besar bisa jadi insiden nyata. Keputusan membuang vs menahan = judgment + domain.)

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 09](latihan-09-ggplot2-dasar.md)

