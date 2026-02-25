library(tidyverse)
library(tidyquant)

fred_codes <- c("DGS1MO","DGS3MO", "DGS6MO", "DGS1", "DGS2","DGS3", "DGS5","DGS7","DGS10","DGS20","DGS30")

rate_data <- tidyquant::tq_get(fred_codes, 
                               get = "economic.data",
                               from = "1992-01-01") %>% 
  dplyr::mutate(
    T2M = dplyr::case_when(
      grepl("MO", symbol) ~ as.numeric(str_extract(symbol, "\\d+"))/12,
      .default = as.numeric(str_extract(symbol, "\\d+"))),
    yield = price / 100) %>% 
  dplyr:: select(-price) %>% 
  tidyr::drop_na()

fun <- splinefun(x = rate_data$T2M, y = rate_data$yield, method = "natural")

interpolated <- data.frame(
  x = seq(0.83, 30, by = 0.01),
  y = fun(seq(0.83,30, by = 0.01))
)

plot <- ggplot2::ggplot(rate_data,
                        aes(x = date, y = yield, color = symbol)) +
  geom_line()

plot


plot <- ggplot2::ggplot(interpolated,
                        aes(x = date, y = yield, color = symbol)) +
  geom_line()

plot


