library(leaflet) # base for shiny map display

ui <- fluidPage(
  titlePanel("BART Passenger Heatmap"),
  leafletOutput("basemap",
                height = 600)
)

# next up: add date/hour select in ui.R
# use reactives to only calculate weights as necessary
