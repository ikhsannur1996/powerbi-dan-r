# Materi 05 — Memilih Kolom & Menyaring Baris (dplyr)

> Pendamping Volume 0 · Waktu baca ±12 menit · Dataset `quality_inspection.csv`.
> Awali tiap sesi: `library(dplyr)` + `quality <- read.csv("quality_inspection.csv")`.

---

## 1. Materi singkat

Dua kata kerja paling sering di dplyr:

| Fungsi | Untuk apa | Analogi |
| --- | --- | --- |
| `select()` | pilih/kurangi **kolom** | pilih kolom di Excel |
| `filter()` | saring **baris** yang memenuhi syarat | AutoFilter |

Keduanya dibaca lewat pipe `|>`: `quality |> filter(...) |> select(...)` = "dari quality, saring..., lalu pilih...".
Di dalam `filter()`, koma (`,`) = DAN. `%in%` = "salah satu dari". `between(x, a, b)` = "x di antara a dan b".
Helper `select()`: `-kolom` (buang), `starts_with("...")`, `ends_with("...")`.

---

## 2. Contoh 1 — `select()`: pilih kolom

```r
library(dplyr)
quality <- read.csv("quality_inspection.csv")

quality |> select(Line, Product, DefectType, Defect) |> head(3)
quality |> select(-CycleTimeSec) |> names()          # semua KECUALI cycle time
quality |> select(starts_with("Ins")) |> names()     # awalan "Ins" -> Inspected, InspectionDate
quality |> select(ends_with("Sec")) |> names()       # akhiran "Sec" -> CycleTimeSec
```

Output:

```text
  Line Product DefectType Defect
1    A Bracket    Scratch      5
2    A Bracket  Dimension      3
3    B Bracket    Scratch      9
[1] "InspectionDate" "Line" "Product" "DefectType" "Inspected" "Defect"
[1] "InspectionDate" "Inspected"
[1] "CycleTimeSec"
```

## 3. Contoh 2 — `filter()`: saring baris

```r
quality |> filter(Line == "B") |> nrow()                        # 16 baris lini B
quality |> filter(Line == "A", Defect > 5)                      # A DAN defect > 5 -> 1 baris
quality |> filter(DefectType %in% c("Scratch", "Crack")) |> nrow()  # 20 baris
quality |> filter(between(CycleTimeSec, 42, 48)) |> nrow()      # 17 baris
```

Output:

```text
[1] 16
  InspectionDate Line Product DefectType Inspected Defect CycleTimeSec
1     2026-07-15    A Bracket    Scratch       118      6           43
[1] 20
[1] 17
```

Penjelasan: `Line == "B"` menghasilkan 16 baris (tiap lini memang 16 baris — lihat `table(quality$Line)`).
Koma di `filter(Line == "A", Defect > 5)` = DAN: hanya 1 baris lini A yang defect-nya di atas 5.

## 4. Contoh 3 — Gabungan: saring → pilih → urutkan

Pertanyaan bisnis: "Di lini A, inspeksi mana yang defect-nya ≥ 4?"

```r
quality |>
  filter(Line == "A", Defect >= 4) |>
  select(InspectionDate, DefectType, Defect) |>
  arrange(desc(Defect))
```

Output:

```text
  InspectionDate DefectType Defect
1     2026-07-15    Scratch      6
2     2026-07-01    Scratch      5
3     2026-08-01    Scratch      5
4     2026-08-15    Scratch      5
5     2026-07-08      Crack      4
6     2026-07-15  Dimension      4
7     2026-08-08      Crack      4
8     2026-08-15  Dimension      4
```

Penjelasan: `arrange(desc(Defect))` = urut menurun (lihat Materi 06 untuk `arrange()` detail).
Bacanya: "dari quality, ambil lini A yang defect ≥ 4, pilih 3 kolom, urutkan dari defect terbesar."

## 5. Contoh 4 — Tetangga `select()`: rename, relocate, distinct

```r
# rename: ganti nama kolom (nama_baru = nama_lama)
quality |> rename(Tgl = InspectionDate) |> head(2) |> select(Tgl)

# relocate: pindahkan letak kolom
quality |> relocate(Defect, .before = Line) |> head(2) |> select(Line, Defect, Inspected)

# distinct: ambil baris unik (menghilangkan duplikat)
quality |> distinct(DefectType)
quality |> distinct(Line, DefectType) |> nrow()   # 3 × 5 - kombinasi unik
```

Output:

```text
         Tgl
1 2026-07-01
2 2026-07-01

  Line Defect Inspected
1    A      5       120
2    A      3       115

    DefectType
1    Scratch
2  Dimension
3      Crack
4      Color
5       NONE

[1] 15
```

Penjelasan: `rename()` dipakai saat kolom sumber jelek namanya. `relocate()` menyusun posisi kolom biar rapi di output. `distinct(kolom)` = versi dplyr dari `unique()` — berguna untuk daftar kode (master list) dan cek duplikat (Materi 08).

---

## 6. Coba sendiri (±5 menit)

1. Pilih kolom `Line`, `Defect`, `Inspected` saja. Lalu ulangi dengan membuang `Product` (`select(-Product)`) — bandingkan `names()` keduanya.
2. Saring `Line == "C"`. Berapa baris? (Acuan contoh 2: sama seperti lini B, `16`.)
3. Saring `DefectType == "Color"`. Tebak sebelum dijalankan — petunjuk: hanya produk Panel yang punya Color.
4. Gabungan: dari lini B, ambil `InspectionDate, DefectType, Defect` untuk `Defect >= 8`, urutkan menurun. Berapa baris teratas dan defect tertingginya? (Acuan: defect tertinggi lini B = `12`.)

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 06](latihan-06-dplyr-mutate-arrange.md)

