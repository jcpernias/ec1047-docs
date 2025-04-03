#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(tidyverse)
    library(readxl)
})

args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
    out_dir <- "."
} else if (length(args) == 1) {
    out_dir <- args
} else {
    stop("Too many script arguments.")
}


y  <- read_excel("./data/ineq-data.xlsx",
                 range = "Rentas!B2:B11",
                 col_names = "y",
                 col_types = "numeric") |> pull(y)

N <- length(y)
Y <- sum(y)

tbl <- tibble(i = c(0, 1:N),
              y = c(0, y),
              fy = 100 * y / Y,
              p = 100 * i / N,
              L = cumsum(fy))

ncols <- ncol(tbl)
digits <- c(0, 0, 1, 0, 1)
wdth <- 6

body <- map2(tbl, digits,
             \(x, d) formatC(x, digits = d, width = wdth, format = "f")) |>
    as_tibble() |>
    as.matrix() |>
    apply(1, \(x) paste("|", x, collapse = " ")) |>
    paste(collapse = " |\n") |>
    paste("|\n")

hyphens <- rep("-", wdth + 2) |>
    paste0(collapse = "")

hline <- paste0("|", hyphens) |>
    rep(ncols) |>
    paste0(collapse = "") |>
    paste0("|\n")

drop_cols <- -1
sums <- tbl[drop_cols] |>
    map(sum) |>
    map2(digits[drop_cols],
         \(x, d) formatC(x, digits = d, width = wdth, format = "f"))

tbl_summ <- as.character(c(N, Y)) |> c(rep("", 3))

foot <- paste("| ", tbl_summ, collapse = " ") |>
    paste("|\n")

col_hdrs <- c("i",
              "y",
              "fy",
              "p",
              "L")

hdr <- paste("|", col_hdrs, collapse = " ") |>
    paste("|\n")

attr_str <- paste0("#+NAME: tab-lorenz-data\n")

cat(attr_str, hdr, hline, body, hline, foot,
    file = file.path(out_dir, "ineq-data.org"))
write_csv(tbl, file.path(out_dir, "ineq-data.csv"))

## Local Variables:
## eval: (flyspell-mode -1)
## End:
