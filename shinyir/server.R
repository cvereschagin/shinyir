library(shiny)
library(DT)

# Define server logic required to draw a histogram
function(input, output, session) {
  
  coupon_freq <- reactive({
    if (input$coupon_freq == "Annual") {
      m <- 1
    } else {
      m <- 2
    }
    return(m)
  })
  
  portfolio <- reactiveVal(
    data.frame(
      "Coupon Rate" = numeric(),
      "Face Value" = numeric(),
      "Maturity" = as.Date(character()),
      'Coupon Frequency' = character(),
      check.names = FALSE
    )
  )
  
  observeEvent(input$add_bond_button, {
    new_bond <- data.frame("Coupon Rate" = input$coupon_rate,
                           "Face Value" = input$face_value,
                           "Maturity" = input$maturity_date,
                           "Coupon Frequency" = input$coupon_freq,
                           check.names = FALSE)
    portfolio(rbind(portfolio(), new_bond))
  })
  
  observeEvent(input$clear_portfolio, {
    portfolio(data.frame("Coupon Rate" = numeric(),
                            "Face Value" = numeric(),
                            "Maturity" = as.Date(character()),
                            "Coupon Frequency" = character(),
                            check.names = FALSE)
    )
  })
  
  output$yield_curve_header <- renderUI({
    req(input$valuation_date)
    card_header(paste0("Yield Curves for ", input$valuation_date))
  })
  
  output$portfolio <- renderDT({
    DT::datatable(portfolio(), editable = FALSE)
  })
  
  combined_curve_plot <- reactive({
    req(input$valuation_date)
    current_curve <- interpolate_curve(input$valuation_date)
    zero_curve <- bootstrap_curve(current_curve)
    
    combined_curve <- merge(current_curve, zero_curve, by = "T2M")
    
    ggplot2::ggplot(combined_curve, aes(x = T2M)) +
      geom_line(aes(y = par_yield, color = "Par Yield")) +
      geom_line(aes(y = zero_yields, color = "Zero Yield")) +
      labs(y = "Yield (%)",
           x = "Time to Maturity (years)")
  })
  
  output$yield_plot <- renderPlot({
    combined_curve_plot()
  })
}