FROM rocker/shiny-verse:4.5.2

RUN apt-get clean all && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    libquantlib0-dev && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/bchoi-qwe/IRShinyApp.git /IRShinyApp
RUN Rscript /IRShinyApp/requirements.R

EXPOSE 3838

CMD ["Rscript", "-e", "shiny::runApp('/IRShinyApp/app', host = '0.0.0.0', port = 3838)"]