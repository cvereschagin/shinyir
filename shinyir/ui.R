library(shiny)
library(shinydashboard)
library(bs4Dash)
library(editbl)

ui <- dashboardPage(
  dashboardHeader(title = span(icon("wave-square"))),
  dashboardSidebar(
    minified = TRUE,
    expandOnHover = FALSE,
    sidebarMenu(
      id = "tabs",
      menuItem("Home", tabName = "home", icon = icon("house")),
      menuItem("Rates", tabName = "rates", icon = icon("chart-line")),
      menuItem("Risk", tabName = "risk", icon = icon("calculator")),
      menuItem("Portfolio", tabName = "portfolio", icon = icon("layer-group")),
      menuItem("PnL Attribution", tabName = "pnl", icon = icon("scale-balanced")),
      menuItem("Other", tabName = "ather", icon = icon("circle-info"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "home",
        
        bs4TabSetPanel(
          id = "home_subtabs",
          
          bs4TabPanel(
            title = "Tab 1",
            active = TRUE,
            
            fluidRow(
              box(title = "Box 1", width = 6, solidHeader = TRUE, status = "primary",
                  plotOutput("home_box1_plot", height = 250)
              ),
              box(title = "Box 2", width = 6, solidHeader = TRUE, status = "primary",
                  plotOutput("home_box2_plot", height = 250)
              )
            ),
            fluidRow(
              box(title = "Box 3", width = 6, solidHeader = TRUE, status = "primary",
                  DT::DTOutput("home_box3_tbl")
              ),
              box(title = "Box 4", width = 6, solidHeader = TRUE, status = "primary",
                  DT::DTOutput("home_box4_tbl")
              )
            )
          ),
          
          bs4TabPanel(
            title = "Tab 2",
            fluidRow(
              box(title = "Tab 2 content", width = 12, solidHeader = TRUE, status = "primary",
                  p("Placeholder")
              )
            )
          ),
          
          bs4TabPanel(
            title = "Tab 3",
            fluidRow(
              box(title = "Tab 3 content", width = 12, solidHeader = TRUE, status = "primary",
                  p("Placeholder")
              )
            )
          )
        )
      ),
      
      tabItem(
        tabName = "rates",
        
        bs4TabSetPanel(
          id = "rates_subtabs",
          
          bs4TabPanel(
            title = "Tab 1",
            active = TRUE,
            
            fluidRow(
              box(title = "Box 1", width = 6, solidHeader = TRUE, status = "primary",
                  plotOutput("rates_box1_plot", height = 250)
              ),
              box(title = "Box 2", width = 6, solidHeader = TRUE, status = "primary",
                  plotOutput("rates_box2_plot", height = 250)
              )
            ),
            fluidRow(
              box(title = "Box 3", width = 6, solidHeader = TRUE, status = "primary",
                  DT::DTOutput("rates_box3_tbl")
              ),
              box(title = "Box 4", width = 6, solidHeader = TRUE, status = "primary",
                  DT::DTOutput("rates_box4_tbl")
              )
            )
          ),
          
          bs4TabPanel(
            title = "Tab 2",
            fluidRow(
              box(title = "Tab 2 content", width = 12, solidHeader = TRUE, status = "primary",
                  p("Placeholder")
              )
            )
          ),
          
          bs4TabPanel(
            title = "Tab 3",
            fluidRow(
              box(title = "Tab 3 content", width = 12, solidHeader = TRUE, status = "primary",
                  p("Placeholder")
              )
            )
          )
        )
      ),
      
      tabItem(
        tabName = "risk",
        
        bs4TabSetPanel(
          id = "risk_subtabs",
          
          bs4TabPanel(
            title = "Tab 1",
            active = TRUE,
            
            fluidRow(
              box(title = "Box 1", width = 6, solidHeader = TRUE, status = "primary",
                  plotOutput("risk_box1_plot", height = 250)
              ),
              box(title = "Box 2", width = 6, solidHeader = TRUE, status = "primary",
                  plotOutput("risk_box2_plot", height = 250)
              )
            ),
            fluidRow(
              box(title = "Box 3", width = 6, solidHeader = TRUE, status = "primary",
                  DT::DTOutput("risk_box3_tbl")
              ),
              box(title = "Box 4", width = 6, solidHeader = TRUE, status = "primary",
                  DT::DTOutput("risk_box4_tbl")
              )
            )
          ),
          
          bs4TabPanel(
            title = "Tab 2",
            fluidRow(
              box(title = "Tab 2 content", width = 12, solidHeader = TRUE, status = "primary",
                  p("Placeholder")
              )
            )
          ),
          
          bs4TabPanel(
            title = "Tab 3",
            fluidRow(
              box(title = "Tab 3 content", width = 12, solidHeader = TRUE, status = "primary",
                  p("Placeholder")
              )
            )
          )
        )
      ),
      
      tabItem(
        tabName = "portfolio",
        
        bs4TabSetPanel(
          id = "portfolio_subtabs",
          
          bs4TabPanel(
            title = "Tab 1",
            active = TRUE,
            
            fluidRow(
              box(title = "Box 1", width = 6, solidHeader = TRUE, status = "primary",
                  plotOutput("portfolio_box1_plot", height = 250)
              ),
              box(title = "Box 2", width = 6, solidHeader = TRUE, status = "primary",
                  plotOutput("portfolio_box2_plot", height = 250)
              )
            ),
            fluidRow(
              box(title = "Box 3", width = 6, solidHeader = TRUE, status = "primary",
                  DT::DTOutput("portfolio_box3_tbl")
              ),
              box(title = "Box 4", width = 6, solidHeader = TRUE, status = "primary",
                  DT::DTOutput("portfolio_box4_tbl")
              )
            )
          ),
          
          bs4TabPanel(
            title = "Tab 2",
            fluidRow(
              box(title = "Tab 2 content", width = 12, solidHeader = TRUE, status = "primary",
                  p("Placeholder")
              )
            )
          ),
          
          bs4TabPanel(
            title = "Tab 3",
            fluidRow(
              box(title = "Tab 3 content", width = 12, solidHeader = TRUE, status = "primary",
                  p("Placeholder")
              )
            )
          )
        )
      ),
      
      tabItem(
        tabName = "pnl",
        
        bs4TabSetPanel(
          id = "pnl_subtabs",
          
          bs4TabPanel(
            title = "Tab 1",
            active = TRUE,
            
            fluidRow(
              box(title = "Box 1", width = 6, solidHeader = TRUE, status = "primary",
                  plotOutput("pnl_box1_plot", height = 250)
              ),
              box(title = "Box 2", width = 6, solidHeader = TRUE, status = "primary",
                  plotOutput("pnl_box2_plot", height = 250)
              )
            ),
            fluidRow(
              box(title = "Box 3", width = 6, solidHeader = TRUE, status = "primary",
                  DT::DTOutput("pnl_box3_tbl")
              ),
              box(title = "Box 4", width = 6, solidHeader = TRUE, status = "primary",
                  DT::DTOutput("pnl_box4_tbl")
              )
            )
          ),
          
          bs4TabPanel(
            title = "Tab 2",
            fluidRow(
              box(title = "Tab 2 content", width = 12, solidHeader = TRUE, status = "primary",
                  p("Placeholder")
              )
            )
          ),
          
          bs4TabPanel(
            title = "Tab 3",
            fluidRow(
              box(title = "Tab 3 content", width = 12, solidHeader = TRUE, status = "primary",
                  p("Placeholder")
              )
            )
          )
        )
      ),
      
      tabItem(
        tabName = "other",
        
        bs4TabSetPanel(
          id = "other_subtabs",
          
          bs4TabPanel(
            title = "Tab 1",
            active = TRUE,
            
            fluidRow(
              box(title = "Box 1", width = 6, solidHeader = TRUE, status = "primary",
                  plotOutput("other_box1_plot", height = 250)
              ),
              box(title = "Box 2", width = 6, solidHeader = TRUE, status = "primary",
                  plotOutput("other_box2_plot", height = 250)
              )
            ),
            fluidRow(
              box(title = "Box 3", width = 6, solidHeader = TRUE, status = "primary",
                  DT::DTOutput("other_box3_tbl")
              ),
              box(title = "Box 4", width = 6, solidHeader = TRUE, status = "primary",
                  DT::DTOutput("other_box4_tbl")
              )
            )
          ),
          
          bs4TabPanel(
            title = "Tab 2",
            fluidRow(
              box(title = "Tab 2 content", width = 12, solidHeader = TRUE, status = "primary",
                  p("Placeholder")
              )
            )
          ),
          
          bs4TabPanel(
            title = "Tab 3",
            fluidRow(
              box(title = "Tab 3 content", width = 12, solidHeader = TRUE, status = "primary",
                  p("Placeholder")
              )
            )
          )
        )
      )
    )
  )
)
      