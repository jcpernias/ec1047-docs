suppressPackageStartupMessages({
    library(tidyverse)
    library(readxl)
    library(ggrepel)
})


var_names <- c("S80S20", "Gini", "ypc", "H") |>
  map(\(x) paste(x, c(2013, 2023), sep = "_")) |>
  unlist()


es_db <- read_excel("data/pov-ineq.xlsx",
                    col_names = c("name", var_names),
                    sheet = "CC.AA.",
                    range = "A3:I20") |>
  left_join(read_csv("data/ccaa.csv", col_types = "cc"),
            by = c("name" = "name")) |>
  select(-name)

es_g <- es_db |>
  mutate(
    Gini = 100 * (Gini_2023 / Gini_2013 - 1) / 11,
    ypc = 100 * (ypc_2023 / ypc_2013 - 1) / 11,
    H = 100 * (H_2023 / H_2013 - 1) / 11,
    S80S20 = 100 * (S80S20_2023 / S80S20_2013 - 1) / 11,
  )

lines_db <- filter(es_g, ccaa == "ESP")

mk_plt <- function(x, y, xlab, ylab) {
  es_g |>
    filter_out(ccaa == "ESP") |>
    ggplot(aes(x = {{ x }}, y = {{ y }})) +
    geom_vline(aes(xintercept = {{ x }}), lines_db, color = "snow4") +
    geom_hline(aes(yintercept = {{ y }}), lines_db, color = "snow4") +
    geom_point(size = 1) +
    geom_label_repel(aes(label = ccaa), size = 4.5, box.padding = 0.2) +
    theme_bw(base_size = 24) +
    labs(x = xlab, y = ylab)
}


save_pdf <- function(path, plot) {
  ggsave(path, plot = plot,
    width = 9, family = "Times",
    encoding = "ISOLatin9.enc")
}

save_pdf("figures/ypc_H.pdf", mk_plt(ypc, H, "Crec. Renta", "Crec. Pobreza"))
save_pdf("figures/ypc_Gini.pdf", mk_plt(ypc, Gini, "Crec. Renta", "Crec. Gini" ))
save_pdf("figures/ypc_S80S20.pdf", mk_plt(ypc, S80S20, "Crec. Renta", "Crec. S80S20"))
save_pdf("figures/Gini_H.pdf", mk_plt(Gini, H, "Crec. Gini", "Crec. Pobreza"))
save_pdf("figures/S80S20_H.pdf", mk_plt(S80S20, H, "Crec. S80S20", "Crec. Pobreza"))
save_pdf("figures/Gini.pdf", mk_plt(Gini_2013, Gini_2023, "Gini 2013", "Gini 2023"))
save_pdf("figures/H.pdf", mk_plt(H_2013, H_2023, "Pobreza 2013", "Pobreza 2023"))
save_pdf("figures/S80S20.pdf", mk_plt(S80S20_2013, S80S20_2023,
  "S80S20 2013", "S80S20 2023"))
save_pdf("figures/ypc.pdf", mk_plt(ypc_2013, ypc_2023, "Renta 2013", "Renta 2023"))
