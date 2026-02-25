library(shiny)
library(shinyjs)
library(bslib)


ui <- page_navbar(
  useShinyjs(),
  title = "Bond Detals",
  nav_panel(
    title = "Inputs",
    card(
      card_header("Bond Details"),
      numericInput("face_value", "Face Value", value = 100, step = 1),
      numericInput("coupon_rate", "Coupon Rate (Annual)", value = 0.05, min = 0, max = 1, step = 0.01),
      selectInput("coupon_freq", "Coupon Frequency", choices = c("Annual","Semi-Annual")),
      numericInput("maturity", "Time to Maturity (years)", value = 5, min = 0, max = 30, step = 0.1)
    )
  )
)
