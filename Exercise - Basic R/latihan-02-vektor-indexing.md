# Materi 02 — Vektor, Urutan & Indexing

> Pendamping Volume 0 · Waktu baca ±10 menit · Contoh memakai cycle time 5 inspeksi: 38, 42, 45, 41, 39 detik.

---

## 1. Materi singkat

Vektor = kumpulan nilai sejenis dalam satu objek. Cara membuat:

| Cara | Fungsi | Contoh hasil |
| --- | --- | --- |
| Manual | `c(...)` | `c(38, 42, 45)` |
| Urutan 1 per 1 | `:` | `1:5` → 1 2 3 4 5 |
| Urutan lompat | `seq(from, to, by)` | `seq(0, 100, by = 10)` |
| Ulangi nilai | `rep(x, times)` | `rep("Line A", 3)` |

Index di R mulai dari **1** (bukan 0). `x[1]` = elemen pertama, `x[-1]` = semua kecuali pertama, `x[x > 40]` = elemen yang memenuhi kondisi.
`NA` menular: `mean(c(5, 3, NA))` = `NA`, kecuali `mean(..., na.rm = TRUE)`.

---

## 2. Contoh 1 — Membuat vektor cycle time

```r
cycle_time <- c(38, 42, 45, 41, 39)
cycle_time

length(cycle_time)  # berapa data?
sum(cycle_time)     # total
mean(cycle_time)    # rata-rata
min(cycle_time); max(cycle_time)
```

Output:

```text
[1] 38 42 45 41 39
[1] 5
[1] 205
[1] 41
[1] 38
[1] 45
```

Penjelasan: `length()` = jumlah elemen. `mean()` = 205 / 5 = 41 detik.

## 3. Contoh 2 — Urutan dan pengulangan

```r
1:10
seq(from = 0, to = 100, by = 10)
rep("Line A", 3)
```

Output:

```text
 [1]  1  2  3  4  5  6  7  8  9 10
 [1]   0  10  20  30  40  50  60  70  80  90 100
[1] "Line A" "Line A" "Line A"
```

Penjelasan: `:` untuk urutan rapat, `seq()` untuk lompatan, `rep()` untuk mengulang label (mis. nama lini).

## 4. Contoh 3 — Indexing (mengambil elemen)

```r
cycle_time[1]       # elemen pertama -> 38
cycle_time[2:4]     # elemen ke-2 s.d. ke-4 -> 42 45 41
cycle_time[-1]      # semua KECUALI pertama -> 42 45 41 39
cycle_time[c(1, 5)] # elemen ke-1 DAN ke-5 -> 38 39
cycle_time[cycle_time > 40]  # hanya yang di atas 40 -> 42 45 41
```

Output:

```text
[1] 38
[1] 42 45 41
[1] 42 45 41 39
[1] 38 39
[1] 42 45 41
```

Penjelasan: index negatif = "buang". Index kondisi (`cycle_time > 40`) menghasilkan `TRUE/FALSE` lalu dipakai menyaring — pola yang sama dipakai `filter()` di dplyr nanti.

## 5. Contoh 4 — NA di dalam vektor

```r
defect_count <- c(5, 3, NA, 8, 2)
mean(defect_count)                # NA — ada 1 hilang, rata-rata ikut hilang
mean(defect_count, na.rm = TRUE)  # 4.5 — hitung tanpa NA
is.na(defect_count)               # posisi mana yang NA?
```

Output:

```text
[1] NA
[1] 4.5
[1] FALSE FALSE  TRUE FALSE FALSE
```

Penjelasan: `na.rm = TRUE` = "remove NA dulu". `is.na()` mengembalikan vektor logical — elemen ke-3 `TRUE`.

## 6. Contoh 5 — Vektor karakter (nama lini)

```r
line <- c("A", "A", "B", "C", "B")
line[line == "B"]   # hanya yang B
```

Output:

```text
[1] "B" "B"
```

---

## 7. Coba sendiri (±5 menit)

1. Dari `cycle_time`, ambil elemen ke-3 sampai ke-5. (Acuan contoh 3: hasilnya `45 41 39`.)
2. Tampilkan `cycle_time` yang `>= 42`. Tebak jumlahnya sebelum dijalankan (jawab: 3 nilai: 42, 45).
3. Buat `seq(from = 5, to = 50, by = 5)`. Berapa `length()`-nya? (Jawab: 10.)
4. Buat `defect_count <- c(4, NA, 6)`. Hitung `sum()` tanpa dan dengan `na.rm = TRUE`. Jelaskan bedanya satu kalimat.

---

[Kembali ke daftar](README.md) | [Lanjut: Materi 03](latihan-03-fungsi-logika.md)

