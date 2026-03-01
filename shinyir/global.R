library(tidyverse)
library(tidyquant)
library(RQuantLib)

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

current_curve <- rate_data %>% 
  dplyr::filter(date == max(date)) %>% 
  dplyr::select(T2M, yield)

max_date <- max(rate_data$date)


# should bootstrap fred curve to zero curve before interpolation
#bootstrap <- function()

# zero_curve <- RQuantLib::DiscountCurve(
#   params = list(interpWhat = "discount",
#                 interpHow = "loglinear"),
#   tsQuotes = current_curve$yield,
#   times = current_curve$T2M
# )
# 
# test <- current_curve$yield

fun <- splinefun(x = current_curve$T2M, y = current_curve$yield, method = "natural")

T2M_interpolated <- seq(min(current_curve$T2M), max(current_curve$T2M), by = 0.001)

y_vals <- fun(T2M_interpolated)

interpolated_curve <- data.frame(T2M = T2M_interpolated,
                                 yield = y_vals,
                                 type = "par_rates")

# interpolated_curve_plot <- ggplot2::ggplot(interpolated_curve,
#                         aes(x = T2M_interpolated, y = y_vals)) +
#   geom_line()
# 
# interpolated_curve_plot

tsQuotes <- list(
  d1m  = current_curve$yield[1],
  d3m  = current_curve$yield[2],
  d6m  = current_curve$yield[3],
  d1y  = current_curve$yield[4],
  s2y  = current_curve$yield[5],
  s3y  = current_curve$yield[6],
  s5y  = current_curve$yield[7],
  s7y  = current_curve$yield[8],
  s10y = current_curve$yield[9],
  s20y = current_curve$yield[10],
  s30y = current_curve$yield[11]
)

params = list(tradeDate = max_date,
              settleDate = max_date,
              dt = 0.5,
              interpWhat = "zero",
              interpHow  = "spline"
)

times = seq(min(current_curve$T2M), max(current_curve$T2M), by = 0.001)

curve <- RQuantLib::DiscountCurve(
  params,
  tsQuotes,
  times
)

zero_curve <- data.frame(T2M = curve$times, 
                         yield = curve$zerorates,
                         type = "zero_rate")


combined_curve <- rbind(interpolated_curve, zero_curve)

combined_curve_plot <- ggplot2::ggplot(combined_curve,
                        aes(x = T2M, y = yield, color = type)) +
  geom_line()

combined_curve_plot # This doesn't seem correct as zero rates should not be lower then par rates



price_bond <- function(coupon_rate, face_value, expiry_date, valuation_date, m=2, zero_curve){

  T2M <- interval(valuation_date,expiry_date) %>% 
    time_length("years") %>% 
    round(3)
  
  cfs <- c()
  discount_factors <- c()
  pvs <- c()
  times <- c()
  
  if (T2M > 1/m) { # If maturity is further than the first coupon payment
    
    schedule <- round(rev(seq(from = T2M, to = 0, by = -1/m)),3)
    
    # if (T2M %% 1/m != 0) { # Add the final principle payment at maturity
    #   schedule <- append(schedule, T2M)
    #}
  } else { # If maturity is before the hypothetical first coupon payment
    schedule <- T2M
  }
  
  for (i in 1:length(schedule)) {
    
    if (i > 1) {
      prev_time <- schedule[i-1]
    } else {
      prev_time <- 0
    }
    
    time <- schedule[i]
    
    zero_rate <- zero_curve %>%
      dplyr::filter(round(zero_curve$T2M,3) == schedule[i]) %>%
      dplyr::pull(yield)
    
    period_length <- time - prev_time
    cf <- coupon_rate * period_length * face_value
    
    if (i == length(schedule)) {
      cf <- cf + face_value
    }
    
    discount_factor <- 1/((1 + zero_rate/m)^(time*m))
    pv <- cf * discount_factor
    
    times <- append(times, time)
    cfs <- append(cfs, cf)
    discount_factors <- append(discount_factors, discount_factor)
    pvs <- append(pvs, pv)
    
  }

  table <- data.frame(times, cfs, discount_factors, pvs)
  
  price <- sum(table$pvs)
  
  return(price)
}

test <- price_bond(0.0357,100,"2027-06-18",max_date,2,zero_curve)


price_portfolio <- function(portfolio_df, valuation_date, zero_curve) {
  portfolio_df %>%
    rowwise() %>%
    mutate(
      price = price_bond(coupon_rate, face_value, expiry_date, valuation_date, m, zero_curve))
}


# shift_curve <- function(zero_curve, bump_bp = 1) {
#   zero_curve %>%
#     mutate(yield = yield + bump_bp/10000)
# }





# bootstrap <- function(fred_curve) {
#   
#   data <- data.frame()
#   discount_factor_list <- c()
#   
#   for(i in 1:nrow(fred_curve)) {
#     
#     T2M <- fred_curve$T2M[i]
#     yield <- fred_curve$yield[i]
#     
#     face_value <- 100
#     payment_freq <- 2 # semi-annual payments
#     
#     if(T2M <= 1) { # maturities one year or less don't pay coupons, so the fred rate = zero rate.
#       
#       periods <- 0
#       zero_rate <- yield
#       discount_factor <- 1 / (1 + zero_rate/1)^T2M  # annual compounding for short-term
#       discount_factor_list <- c(discount_factor_list, discount_factor)
#       
#     } else {
#       
#       periods <- T2M * payment_freq
#       coupon <- face_value * yield / payment_freq
#       
#       # sum of known discounted coupons (from previously bootstrapped DFs)
#       # Only include as many DFs as there are coupon payments before maturity
#       n_prev <- length(discount_factor_list)
#       n_coupons <- periods - 1
#       if(n_coupons > n_prev) n_coupons <- n_prev  # cannot use more than known DFs
#       
#       sum_known <- sum(coupon * discount_factor_list[1:n_coupons])
#       
#       # calculate discount factor for final period
#       discount_factor <- (face_value + coupon - sum_known) / (face_value + coupon)
#       
#       # calculate zero rate from discount factor
#       zero_rate <- 2 * (discount_factor^(-1/periods) - 1)
#       
#       # append DF to list
#       discount_factor_list <- c(discount_factor_list, discount_factor)
#       
#     }
#     
#     new_row <- data.frame(T2M, periods, yield, zero_rate)
#     
#     data <- rbind(data, new_row)
#     
#   }
#   return(data)
# }
# 
# zero_curve <- bootstrap(current_curve)










# #helper function to get the actual values from the ticker names since "DiscountCurve" only reads the numbers
# q <- function(df_day, sym){
#   df_day %>%
#     filter(symbol == sym) %>%
#     pull(rate) %>%
#     first()
# }
# 
# # The building process of the zero rate curve requires a function called "DiscountCurve" and it requires some things I create here such as "params" and "tsQuotes"
# build_curve_tbl <- function(df_day, eval_date, grid_times = seq(0.25, 30, by = 0.25), m = 2) {
#   
#   # Quotes for DiscountCurve
#   tsQuotes <- list(
#     d1m = q(df_day, "DGS1MO"),
#     d3m = q(df_day, "DGS3MO"),
#     d6m = q(df_day, "DGS6MO"),
#     d1y = q(df_day, "DGS1"),
#     s2y = q(df_day, "DGS2"),
#     s5y = q(df_day, "DGS5"),
#     s10y = q(df_day, "DGS10"),
#     s20y = q(df_day, "DGS20"),
#     s30y = q(df_day, "DGS30")
#   )
#   
#   params <- list(
#     tradeDate = eval_date,
#     settleDate = eval_date,
#     dt = 1/365,
#     interpWhat = "discount",
#     interpHow = "loglinear"
#   )
#   
#   # VERY Cool function to get the zero rates
#   curve <- RQuantLib::DiscountCurve(params, tsQuotes, grid_times)
#   
#   # Creating a table to show the maturities, DFs and Zero Rates
#   tibble(
#     maturity = grid_times,
#     discount_factor = as.numeric(curve$discounts),
#     zero_rate = as.numeric(curve$zerorates)
#   )
#   
# }












