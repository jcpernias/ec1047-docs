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
  select(-name) |>
  mutate(ypc_2013 = ypc_2013 / (10 * ipc_2013),
         ypc_2023 = ypc_2023 / (10 * ipc_2023))

es_g <- es_db |>
  mutate(
    Gini = 100 * (Gini_2023 / Gini_2013 - 1) / 11,
    ypc = 100 * (ypc_2023 / ypc_2013 - 1) / 11,
    H = 100 * (H_2023 / H_2013 - 1) / 11,
    S80S20 = 100 * (S80S20_2023 / S80S20_2013 - 1) / 11,
  )

lines_db <- filter(es_g, ccaa == "ESP")

mk_plt <- function(x, y) {
  es_g |>
    filter(!ccaa %in% c("ESP", "CEU", "MEL")) |>
    ggplot(aes(x = {{ x }}, y = {{ y }})) +
    geom_point() +
    geom_text_repel(aes(label = ccaa)) +
    geom_vline(aes(xintercept = {{ x }}), lines_db, color = "darkblue") +
    geom_hline(aes(yintercept = {{ y }}), lines_db, color = "darkblue") +
    theme_bw()
}


ggsave("figures/ypc_H.pdf", plot = mk_plt(ypc, H),
       width = 9, family = "Times",
       encoding = "ISOLatin9.enc")

ggsave("figures/ypc_Gini.pdf", mk_plt(ypc, Gini),
       width = 9, family = "Times",
       encoding = "ISOLatin9.enc")

ggsave("figures/ypc_S80S20.pdf", mk_plt(ypc, S80S20),
       width = 9, family = "Times",
       encoding = "ISOLatin9.enc")

ggsave("figures/Gini_H.pdf", mk_plt(Gini, H),
       width = 9, family = "Times",
       encoding = "ISOLatin9.enc")

ggsave("figures/S80S20_H.pdf", mk_plt(S80S20, H),
       width = 9, family = "Times",
       encoding = "ISOLatin9.enc")


ggsave("figures/Gini.pdf", mk_plt(Gini_2013, Gini_2023),
       width = 9, family = "Times",
       encoding = "ISOLatin9.enc")

ggsave("figures/H.pdf", mk_plt(H_2013, H_2023),
       width = 9, family = "Times",
       encoding = "ISOLatin9.enc")

ggsave("figures/S80S20.pdf", mk_plt(S80S20_2013, S80S20_2023),
       width = 9, family = "Times",
       encoding = "ISOLatin9.enc")

ggsave("figures/ypc.pdf", mk_plt(ypc_2013, ypc_2023),
       width = 9, family = "Times",
       encoding = "ISOLatin9.enc")
