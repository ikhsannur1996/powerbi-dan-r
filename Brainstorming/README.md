# 🧠 Brainstorming

> Ruang bebas untuk **ide, catatan, dan eksperimen** sebelum jadi materi resmi. Bukan bagian dari alur belajar Volume 0–2 — silakan isi sesuka hati.

---

## 1. Untuk Apa Folder Ini?

| Boleh dipakai untuk | Contoh |
| --- | --- |
| Ide topik/volume baru | "Volume 6 — Time Series?" |
| Coretan kode eksperimen | Skrip coba-coba yang belum rapi |
| Catatan hasil diskusi / revisi | Usulan perbaikan materi |
| Rencana & TODO | Daftar tugas yang belum dikerjakan |
| Referensi mentah | Tautan, potongan artikel, dataset uji |

---

## 2. Konvensi Penamaan (usulan)

```text
Brainstorming/
├── README.md              # file ini
├── ide-<topik>.md         # ide/gagasan  → ide-timeseries.md
├── catatan-<topik>.md     # catatan rapat/diskusi → catatan-revisi-vol2.md
├── coba-<topik>.R         # eksperimen kode → coba-anova-2faktor.R
└── tmp/                   # scratch / hasil sementara (bebas)
```

> Tip: awali nama file dengan tanggal bila perlu, mis. `2026-09-13-ide-timeseries.md`.

---

## 3. Template Catatan Ide

Salin ini saat mulai menulis ide baru:

```markdown
# Ide: <judul>

- **Tanggal:** 2026-09-13
- **Status:** 💡 ide / 🚧 dikerjakan / ✅ selesai / ❌ ditolak
- **Terkait:** Volume 0 / 1 / 2 / Archive

## Masalah / Latar Belakang
<kenapa ide ini muncul>

## Gagasan
<penjelasan singkat>

## Langkah Berikutnya
- [ ] ...

## Catatan
<tautan referensi, dataset, dsb.>
```

---

## 4. Alur Promosi Ide → Materi Resmi

```text
Brainstorming  →  ide matang  →  buat folder "Volume N - ..."  →  commit & push
```

Kalau sebuah ide sudah matang, pindahkan ke folder volume resmi (dengan `README.md`, `R/`, `data/`, `output/`), lalu commit. Folder ini tetap boleh ditumpuki coretan baru.

---

*Folder Brainstorming — ruang eksperimen bebas. Tidak ada aturan ketat di sini.*
