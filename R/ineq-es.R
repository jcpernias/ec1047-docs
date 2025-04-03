suppressPackageStartupMessages({
    library(tidyverse)
    library(readxl)
    library(ggrepel)
})

var_names <- c("S80S20", "Gini", "ypc", "H", "ipc") |>
  map(\(x) paste(x, c(2013, 2023), sep = "_")) |>
  unlist()


es_db <- read_excel("data/ineq-data.xlsx",
                    col_names = c("name", var_names),
                    sheet = "CC.AA.",
                    range = "A3:K22") |>
  left_join(read_csv("data/ccaa.csv", col_types = "cc"),
            by = c("name" = "name")) |>
  mutate(ypc_2013 = ypc_2013 / 1000,
         ypc_2023 = ypc_2023 / 1000) |>
  select(-name)

es_all <- es_db |>
  pivot_longer(cols = -ccaa,
               names_to = c("variable", "year"),
               names_sep = "_",
               names_transform = list(year = as.integer),
               values_to = "value")

mk_plot <- function(x) {
  plot_db <- es_all |>
    filter(!ccaa %in% c("CEU", "MEL")) |>
    mutate(year = paste0("y", year))


  pt_db <- plot_db |>
    filter(variable == x) |>
    select(-variable) |>
    pivot_wider(names_from = year, values_from = value)

  lines_db <- filter(pt_db, ccaa == "ESP")

  filter(pt_db, ccaa != "ESP") |>
    ggplot(aes(x = y2013, y = y2023)) +
    geom_point() +
    coord_fixed(ratio = 1, xlim = range(pt_db$y2013), ylim = range(pt_db$y2023)) +
    geom_vline(aes(xintercept = y2013), lines_db, color = "darkblue") +
    geom_hline(aes(yintercept = y2023), lines_db, color = "darkblue") +
    geom_text_repel(aes(label = ccaa)) +
    xlab("Año 2013") + ylab("Año 2023") +
    # geom_abline(intercept = 0, slope = 1) +
    theme_bw()

}

pdf("figures/Gini.pdf", width = 9, height = 6, family = "Times",
    encoding = "ISOLatin9.enc")
mk_plot("Gini")
dev.off()

pdf("figures/S80S20.pdf", width = 9, height = 6, family = "Times",
    encoding = "ISOLatin9.enc")
mk_plot("S80S20")
dev.off()

pdf("figures/H.pdf", width = 9, height = 6, family = "Times",
    encoding = "ISOLatin9.enc")
mk_plot("H")
dev.off()

pdf("figures/ypc.pdf", width = 9, height = 6, family = "Times",
    encoding = "ISOLatin9.enc")
mk_plot("ypc")
dev.off()
