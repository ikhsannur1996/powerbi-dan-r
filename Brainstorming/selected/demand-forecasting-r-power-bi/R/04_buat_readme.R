# ============================================================
# R/04_buat_readme.R  —  menyusun README.md dari template/
#
# Blok kode di README disalin APA ADANYA dari file R, yaitu bagian
# di antara penanda "# >>> ..._START" dan "# >>> ..._END".
# Dengan begitu README dan kode Power Query / R visual tidak mungkin berbeda.
#
# Jalankan:  Rscript R/04_buat_readme.R
# ============================================================
args <- commandArgs(trailingOnly = FALSE)
sp   <- sub("^--file=", "", args[grep("^--file=", args)])
base <- if (length(sp)) dirname(dirname(normalizePath(sp))) else getwd()
setwd(base)

extr <- function(path, tag) {
  txt <- readLines(path, warn = FALSE)
  a <- grep(sprintf("# >>> %s_START", tag), txt)
  b <- grep(sprintf("# >>> %s_END", tag), txt)
  if (!length(a) || !length(b)) stop("Blok ", tag, " tidak ditemukan di ", path)
  paste(txt[(a[1] + 1):(b[1] - 1)], collapse = "\n")
}

blok <- function(tag) paste0("```r\n", extr("R/02_visual.R", tag), "\n```")
pq   <- paste0("```r\n", extr("R/01_transformasi.R", "BLOK_PQ_01"), "\n```")

# --- contoh isi tabel ramalan untuk README ---
ram <- read.csv("output/ramalan.csv")
ram$Tanggal <- as.Date(ram$Tanggal)
sel <- ram[ram$Produk == "Teh Botol" & ram$Rasa == "Jasmin" & ram$Ukuran == "Sedang" &
             ram$JenisPacking == "Botol PET" & ram$Lokasi == "Pabrik A" &
             ram$Tanggal %in% as.Date(c("2025-12-01", "2026-01-01")), ]
sel <- sel[order(sel$Tanggal, sel$Skenario), ]

fnum <- function(x) ifelse(is.na(x), "-",
                           formatC(x, format = "d", big.mark = ".", decimal.mark = ","))
contoh <- data.frame(
  Tanggal     = format(sel$Tanggal, "%Y-%m"),
  SKU         = sel$SKU,
  Pabrik      = sel$Lokasi,
  Jenis       = sel$Jenis,
  Skenario    = sel$Skenario,
  AngkaBulan  = formatC(sel$AngkaBulan, format = "f", digits = 2, decimal.mark = ","),
  Permintaan  = fnum(sel$Permintaan),
  Plan        = fnum(sel$Plan),
  check.names = FALSE, stringsAsFactors = FALSE
)

md_tbl <- function(d) {
  hdr  <- paste0("| ", paste(names(d), collapse = " | "), " |")
  sep  <- paste0("| ", paste(rep("---", ncol(d)), collapse = " | "), " |")
  rows <- apply(d, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |"))
  paste(c(hdr, sep, rows), collapse = "\n")
}

gsub_lit <- function(s, key, val) {
  val <- gsub("\\", "\\\\", val, fixed = TRUE)   # amankan backslash utk replacement
  gsub(key, val, s, fixed = TRUE)
}

files <- sort(list.files("template", pattern = "[.]md$", full.names = TRUE))
if (length(files) != 5) stop("template/ harus berisi 5 bagian, ditemukan: ", length(files))

txt <- paste(vapply(files, function(f)
  paste(readLines(f, warn = FALSE), collapse = "\n"), character(1)), collapse = "\n\n")

txt <- gsub_lit(txt, "@@KODE_PQ@@", pq)
for (i in 1:10) txt <- gsub_lit(txt, sprintf("@@KODE_V%d@@", i), blok(sprintf("BLOK_RV_V%d", i)))
txt <- gsub_lit(txt, "@@TABEL_RAMALAN@@", md_tbl(contoh))

sisa <- gregexpr("@@[A-Z_0-9]+@@", txt)
if (sisa[[1]][1] > 0) warning("Placeholder belum terisi: ",
                              paste(regmatches(txt, sisa)[[1]], collapse = ", "))

writeLines(txt, "README.md")
cat("README.md ditulis:", length(strsplit(txt, "\n", fixed = TRUE)[[1]]), "baris\n")
