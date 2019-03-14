# https://www.datascience.com/blog/beginners-guide-to-shiny-and-leaflet-for-interactive-mapping
ui <- fluidPage(
  titlePanel("BART Passenger Heatmap"),
  leafletOutput("basemap",
                height = 600)
)
