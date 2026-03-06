library(shiny)
library(shinyjs)
library(bslib)
library(DT)

page_navbar(
  useShinyjs(),
  title = "Shiny IR",
  id = "navbar",
  theme = bs_theme(bootswatch = "flatly"),
  selected = "Portfolio Builder",
  sidebar = sidebar(
    dateInput("valuation_date", "Select Valuation Date", min = min(rate_data$date), max = max(rate_data$date)),
    numericInput("coupon_rate", "Coupon Rate (%)", value = 5, step = 0.01),
    numericInput("face_value", "Face Value", value = 1000, step = 100),
    dateInput("maturity_date", "Maturity Date"),
    selectInput("coupon_freq", "Coupon Frequency", choices = c("Annual", "SemiAnnual")),
    actionButton("add_bond_button", "Add To Portfolio"),
    actionButton("clear_portfolio", "Clear Entire Portfolio")
  ),
  
    # First Page = Portfolio Builder
  nav_panel(
    title = "Portfolio Builder",
    card(
      card_header("Current Portfolio"),
      DTOutput("portfolio")
    ),
    card(
      uiOutput("yield_curve_header"),
      plotOutput("yield_plot")
    )
)
)
    
#     # Second Page - Analysis
#   nav_panel(
#     title = "Analysis",
#     card(
#       card_header("Bond Portfolio"),
#       tableOutput("bond_table")
#     ),
#     card(
#       uiOutput("back_button"),
#       uiOutput("calendar_button")
#     ),
#     row_heights = c(4,1)
#   ),
#     
#     # Third Page - Scenarios
#   nav_panel(
#     title = "Scenario",
#     card(
#       card_header("Add Bond")
#     ),
#     card(
#       numeric_input("coupon_rate", "Coupon Rate", step = 0.01,
#     ),
#     row_heights = c(4,1)
#   )
# )
# )
