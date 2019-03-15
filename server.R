library(leaflet) # base for shiny map display

server <- function(input, output, session)
{
  output$basemap <- renderLeaflet({
    stationIcon <- makeIcon(
      iconUrl = "./graphics/station-icon.png",
      iconWidth = 14,
      iconHeight = 14,
      iconAnchorX = 7,
      iconAnchorY = 7
    )

    linePalette <- colorNumeric(
      palette = "viridis",
      domain = tracks@data$count
    )

    leaflet() %>%
      addTiles() %>%
      addMarkers(data = stations,
                 icon = stationIcon,
                 popup = stations$name) %>%
      addPolylines(data = tracks,
                   weight = 7,
                   opacity = 0.75,
                   color = ~linePalette(tracks@data$count),
                   popup = paste("Station 1: ", tracks@data$full1, "<br>",
                                 "Station 2: ", tracks@data$full2, "<br>",
                                 "Passengers: ", format(tracks@data$count,
                                                        big.mark = ",",
                                                        big.interval = 3)))
  })
}
