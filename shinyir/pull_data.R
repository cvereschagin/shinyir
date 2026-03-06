library(arrow)

fred_codes <- c("DGS1MO","DGS3MO", "DGS6MO", "DGS1", "DGS2","DGS3", "DGS5","DGS7","DGS10","DGS20","DGS30")

rate_data <- tidyquant::tq_get(fred_codes, 
                               get = "economic.data",
                               from = "1992-01-01") %>% 
  dplyr::mutate(
    T2M = dplyr::case_when(
      grepl("MO", symbol) ~ as.numeric(str_extract(symbol, "\\d+"))/12,
      .default = as.numeric(str_extract(symbol, "\\d+"))),
    par_yield = price / 100) %>% 
  dplyr:: select(-price) %>% 
  tidyr::drop_na()

write_feather(
  rate_data,
  "fred_data.feather"
)