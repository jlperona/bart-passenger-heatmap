server <- function(input, output, session)
{
  output$basemap <- renderLeaflet({
    stationIcon <- makeIcon(
      iconUrl = "./graphics/station-icon.png",
      iconWidth = 16,
      iconHeight = 16,
      iconAnchorX = 8,
      iconAnchorY = 8
    )

    # https://rstudio.github.io/leaflet/colors.html
    linePalette <- colorNumeric(
      palette = "Blues",
      domain = tracks@data$weight
    )

    leaflet() %>%
      addTiles() %>%
      addMarkers(data = stations,
                 icon = stationIcon,
                 popup = stations$name) %>%
      addPolylines(data = tracks,
                   opacity = 0.8,
                   color = ~linePalette(tracks@data$weight),
                   popup = paste(tracks@data$weight, "passengers"))
  })
}

# next up: add date/hour select in ui.R
# use reactives to only calculate weights as necessary

# build pre-parser to have every edge weight calculated per hour
# then can just subset through this using a reactive as necessary
