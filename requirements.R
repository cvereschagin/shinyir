p <- c('shiny', 'DT', 'bs4Dash', 'fresh', 'dplyr', 'lubridate', 'tidyquant', 'RQuantLib', 'plotly')
new.packages <- p[!(p %in% installed.packages()[, "Package"])]
if (length(new.packages)) {
    install.packages(new.packages, dependencies = TRUE)
}