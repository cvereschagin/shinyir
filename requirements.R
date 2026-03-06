p <- c('shiny', 'shinyjs', 'bslib', 'DT', 'arrow', 'tidyverse', 'tidyquant', 'RQuantLib')
new.packages <- p[!(p %in% installed.packages()[, "Package"])]
if (length(new.packages)) {
    install.packages(new.packages, dependencies = TRUE)
}
