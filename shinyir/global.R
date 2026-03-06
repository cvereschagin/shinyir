library(tidyverse)
library(tidyquant)
library(plotly)

# fred_codes <- c("DGS1MO","DGS3MO", "DGS6MO", "DGS1", "DGS2","DGS3", "DGS5","DGS7","DGS10","DGS20","DGS30")
# 
# rate_data <- tidyquant::tq_get(fred_codes, 
#                                get = "economic.data",
#                                from = "1992-01-01") %>% 
#   dplyr::mutate(
#     T2M = dplyr::case_when(
#       grepl("MO", symbol) ~ as.numeric(str_extract(symbol, "\\d+"))/12,
#       .default = as.numeric(str_extract(symbol, "\\d+"))),
#     par_yield = price / 100) %>% 
#   dplyr:: select(-price) %>% 
#   tidyr::drop_na()

# Converted data to a feather file that will run daily with github actions

rate_data <- arrow::read_feather("fred_data.feather")

interpolate_curve <- function(valuation_date) {
  current_curve <- rate_data %>% 
    dplyr::filter(date == valuation_date) %>% 
    dplyr::select(T2M, par_yield)
  
  T2M_interpolated <- seq(0.5, max(current_curve$T2M), by = 0.5)
  
  fun <- splinefun(x = current_curve$T2M, y = current_curve$par_yield, method = "natural")
  
  y_vals <- fun(T2M_interpolated)
  
  interpolated_curve <- data.frame(T2M = T2M_interpolated,
                                   par_yield = y_vals)
  
  return(interpolated_curve)
  
}

#current_curve <- interpolate_curve("2026-02-06")


bootstrap_curve <- function(fred_curve) {
  
  T2M <- c()
  zero_yields <- c()
  
  fred_yields <- c()
  face_value <- 100
  
  m <- 2 # Fred par yield curve assumes semi annual payments
  
  for(i in 1:nrow(fred_curve)) {
    
    t2m <- fred_curve$T2M[i]
    yield <- fred_curve$par_yield[i]
    coupon <- yield * face_value / m
    periods <- t2m * m
    
    if (t2m < 1) { # No coupon payments if matruity less then 1 year.
      
      zero_yield <- yield
      zero_yields <- append(zero_yields,zero_yield)
      T2M <- append(T2M, t2m)
      
    } else {
      
      # calculating the present value of the coupon payments with their respective zero yield.
      
      coupon_cumsum <- 0
      
      for (j in 1:(periods - 1)) {
        
        coupon_zero_yield <- zero_yields[j]
        coupon_cumsum <- coupon_cumsum + (coupon/(1+coupon_zero_yield/m)^j)
        
      }
      
      # solving for the zero rate in the final repayment that keeps the price at par
      
      zero_yield <- m * (((coupon + face_value)/(face_value - coupon_cumsum))^(1/periods)-1)
      
      zero_yields <- append(zero_yields, zero_yield)
      T2M <- append(T2M, t2m)
      
    }
    
    zero_curve <- data.frame(T2M, zero_yields)
    
    
  }
  return(zero_curve)
}

#zero_curve <- bootstrap_curve(current_curve)


#combined_curve <- merge(current_curve, zero_curve, by = "T2M")


# combined_curve_plot <- ggplot2::ggplot(combined_curve,
#                         aes(x = T2M)) +
#   geom_line(aes(y = par_yield)) +
#   geom_line(aes(y = zero_yields))
# 
# combined_curve_plot # This doesn't seem correct as zero rates should not be lower then par rates


price_bond <- function(coupon_rate, face_value, expiry_date, valuation_date, m=2, zero_curve, step_size = 0){
  
  T2M <- interval(valuation_date,expiry_date) %>% 
    time_length("years") %>% 
    round(4)
  step_size <- step_size * 0.0001
  cfs <- c()
  discount_factors <- c()
  pvs <- c()
  times <- c()
  
  if (T2M > 1/m) { # If maturity is further than the first coupon payment
    
    schedule <- round(rev(seq(from = T2M, to = 0, by = -1/m)),4)
    
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
    
    zero_rate <- zero_curve %>% arrange(abs(T2M-schedule[i])) %>% 
      slice(1) %>%
      dplyr::pull(zero_yields)
    
    
    zero_rate <- zero_rate + step_size
    
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
#valuation_date <- max_date
#expiry_date <- "2035-06-18"
#coupon_rate <- 0.0357
#face_value <- 100
#i <- 2
#m = 2
#step_size <- 0.0001
#test <- price_bond(0.0357,100,"2035-06-18",max_date,2,zero_curve)

#price_up - price_dwn
#p_up_table <- table
#p_down_table <- table

#diff <- sum(p_up_table$pvs)-sum(p_down_table$pvs)
#diff / (2*0.0001) * 0.0001

calc_delta <- function(coupon_rate, face_value, expiry_date, valuation_date, m, zero_curve, step_size) {
  
  price_up <- price_bond(coupon_rate, face_value, expiry_date, valuation_date, m, zero_curve, step_size = step_size)
  price_dwn <- price_bond(coupon_rate, face_value, expiry_date, valuation_date, m, zero_curve, step_size =  step_size*-1)
  
  delta <- (price_up - price_dwn)/(2*step_size)
  
  return(delta)
}
#max_date <- Sys.Date()
#delta_test <- calc_delta(0.0357,100,"2035-06-18", "2026-02-06",2,zero_curve, 1)

calc_gamma <- function(coupon_rate, face_value, expiry_date, valuation_date, m, zero_curve, step_size) {
  
  price <- price_bond(coupon_rate, face_value, expiry_date, valuation_date, m, zero_curve, step_size = 0)
  price_up <- price_bond(coupon_rate, face_value, expiry_date, valuation_date, m, zero_curve, step_size = step_size)
  price_dwn <- price_bond(coupon_rate, face_value, expiry_date, valuation_date, m, zero_curve, step_size =  step_size*-1)
  
  gamma <- (price_up - 2*price + price_dwn)/(step_size^2)
  
  return(gamma)
}

#gamma_test <- calc_gamma(0.0357,100,"2035-06-18",max_date,2,zero_curve, 1)


#test_df2 <- data.frame(coupon_rate = 0.0357, face_value = 100, expiry = "2035-06-18", step_size = 0.0001, price = test, delta = delta_test, gamma = gamma_test)


price_portfolio <- function(portfolio_df, valuation_date, zero_curve, step_size) {
  portfolio_df %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      price = price_bond(coupon_rate, face_value, expiry_date, valuation_date, m, zero_curve, step_size = 0),
      delta = calc_delta(coupon_rate, face_value, expiry_date, valuation_date, m, zero_curve, step_size),
      gamma = calc_gamma(coupon_rate, face_value, expiry_date, valuation_date, m, zero_curve, step_size))
}


shift_entire_curve <- function(zero_curve, bp_shift = 1) {
  zero_curve %>%
    dplyr::mutate(zero_yields = zero_yields + bp_shift/10000)
}

#graph the Zero Rate over time for the specified time to maturity
graph_zero_curve <- function(rate_data = rate_data, code, dateRange){
  zero_graph <- rate_data %>% 
    filter(symbol == code, date >= dateRange[1], date <= dateRange[2]) %>% 
    bootstrap_curve() %>% 
    plot_ly() %>% 
    add_trace(x = ~date, y = ~zero_yields, type = "scatter", mode = "lines") %>% 
    layout(title = paste0("Zero Curve of ", code, " Treasury Bills"), xaxis = list(title = "Annualized Yield of a Zero Coupon Bond"), yaxis = list(title = "Date"))
  return(zero_graph)
}

get_master_df <- function(coupon, face, expiry, valuation_date, m, basis_step){
  zero_curve <- interpolate_curve(valuation_date = valuation_date) %>% bootstrap_curve()
  Price <- c()
  Delta <- c()
  Gamma <- c()
    
    if (m  == "Annual"){
      m <-  1
    }
    else{
      m <-  2
    }
    
    price <- price_bond(coupon, face, expiry, valuation_date, m, zero_curve, 0)
    Price <- append(Price,price)
    
    delta <- calc_delta(coupon, face, expiry, valuation_date, m, zero_curve, basis_step)
    Delta <- append(Delta, delta)
    
    gamma <- calc_gamma(coupon, face, expiry, valuation_date, m, zero_curve, basis_step)
    Gamma <- append(Gamma, gamma)
  
  master_df <- data.frame(Price, Delta, Gamma)
  return(master_df)
}

load_delta_heatmap <- function(greek_df, coupon_rate, face_value){
  greek_df %>% plot_ly() %>% 
    add_trace(x = ~prices, y = ~T2M, z = ~Delta, type = "heatmap") %>% 
    layout(title = list(text = paste0("Bond Delta, Price, and Time to Maturity", "<br>",paste0("Coupon Rate = ",coupon_rate *100, "% | Face Value = $",face_value)), size = 15), xaxis = list(title = "Price"), legend = list(title = "Delta"))
}