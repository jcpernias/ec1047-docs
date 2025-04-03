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


y  <- read_excel("./data/rentas.xlsx", col_types = "numeric") |> pull(y)

N <- length(y)
pct_pop <- 100 * (1:N) / N

pov_db <- tibble(p = c(pct_pop - 100 / N, 100),
                 y = c(y, max(y)))
write_csv(pov_db, file.path(out_dir, "pen.csv"))

y_med <- median(y)
z <- 0.6 * y_med

povline_db <- tibble(p = c(0, 100),
                     ymed = rep(y_med, 2),
                     z = 0.6 * ymed)
write_csv(povline_db, file.path(out_dir, "povline.csv"))

## Local Variables:
## eval: (flyspell-mode -1)
## End:
