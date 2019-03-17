# code to create the data to be rendered

library(data.table) # fast CSV import using fread()
library(fasttime)   # needed for fastPOSIXct() to convert dates quickly
library(leaflet)    # base for shiny map display

server <- function(input, output, session)
{
  # reactive that is recalculated whenever the update button is pressed
  # it's also calculated when the app is originally opened
  passengerData <- reactive({

    # have to specify UTC here since we're using fastPOSIXct()
    startDate <- fastPOSIXct(input$dateRange[1], tz = "UTC")
    endDate <- fastPOSIXct(input$dateRange[2], tz = "UTC")

    # subset by date-time specified by user
    # data.table allows referencing column by name only
    trackCount <- soo[date >= startDate &
                      date <= endDate &
                      hour %in% as.integer(input$timeRange)]

    # aggregate subset together by edge and fix column names
    trackCount <- aggregate(trackCount$count,
                            by = list(trackCount$origin,
                                      trackCount$destination),
                            FUN = sum)
    colnames(trackCount) <- c("station1", "station2", "count")

    # paste together station names both ways
    # we need to merge this data with the track data
    # we don't necessarily know which order of names in the track data is correct
    # so we have to do both
    trackCount$name1 <- paste(trackCount$station1,
                              trackCount$station2,
                              sep = '-')
    trackCount$name2 <- paste(trackCount$station2,
                              trackCount$station1,
                              sep = '-')
    result1 <- trackCount[ , which(names(trackCount) %in% c("name1", "count"))]
    result2 <- trackCount[ , which(names(trackCount) %in% c("name2", "count"))]

    # merge on both name orders and bind results together
    result1 <- merge(x = tracks@data,
                     y = result1,
                     by.x = "name",
                     by.y = "name1")
    result2 <- merge(x = tracks@data,
                     y = result2,
                     by.x = "name",
                     by.y = "name2")
    trackCount <- rbind(result1, result2)

    # merge station data with full station names
    colnames(stationLookup) <- c("full1", "abbreviation")
    trackCount <- merge(trackCount,
                        stationLookup,
                        by.x = "station1",
                        by.y = "abbreviation")
    colnames(stationLookup) <- c("full2", "abbreviation")
    trackCount <- merge(trackCount,
                        stationLookup,
                        by.x = "station2",
                        by.y = "abbreviation")

    # order by ID
    tracks@data <- trackCount[order(trackCount$id), ]
    rownames(tracks@data) <- 1:nrow(tracks@data)

    # return final result
    tracks
  })

  # render basemap that will never change
  # only the track data changes, so we don't need to make this reactive
  output$basemap <- renderLeaflet({

    # render station icons in similar vein to actual BART map
    stationIcon <- makeIcon(
      iconUrl = "./graphics/station-icon.png",
      iconWidth = 14,
      iconHeight = 14,
      iconAnchorX = 7,
      iconAnchorY = 7
    )

    leaflet() %>%
      # render base map
      addTiles() %>%
      # render station data
      addMarkers(data = stations,
                 icon = stationIcon,
                 popup = stations$name)
  })

  # run this code when first booting the app
  # also run every time the update button is pressed
  observeEvent(input$updateDatetime,
               ignoreNULL = FALSE,
               ignoreInit = FALSE, {

    # have to specify UTC here since we're using fastPOSIXct()
    startDate <- fastPOSIXct(input$dateRange[1], tz = "UTC")
    endDate <- fastPOSIXct(input$dateRange[2], tz = "UTC")

    # check if end date is earlier than start date
    # display pop-up to warn user and don't re-render track if this is the case
    if(endDate < startDate) {
      showModal(modalDialog(
        title = "Error",
        "The end date must be the same as or after the starting date.",
        easyClose = TRUE,
        footer = NULL
      ))
    }
    # check if there are no times in time range
    # display pop-up to warn user and don't re-render track if this is the case
    else if(is.null(input$timeRange)) {
      showModal(modalDialog(
        title = "Error",
        "You must select at least one hour.",
        easyClose = TRUE,
        footer = NULL
      ))
    }
    # if user inputs are valid, re-render palette and track
    else {
      # palette color choice courtesy of the Shiny SuperZIP example
      linePalette <- colorNumeric(
        palette = "viridis",
        domain = passengerData()@data$count
      )

      # send commands to running map instance
      leafletProxy("basemap") %>%
        # clear previous rendered track data
        clearShapes() %>%
        # render popups and tracks, which are colored by input data
        addPolylines(data = passengerData(),
                     weight = 8,
                     opacity = 0.75,
                     color = ~linePalette(passengerData()@data$count),
                     popup = paste("Station 1: ", passengerData()@data$full1, "<br>",
                                   "Station 2: ", passengerData()@data$full2, "<br>",
                                   "Passengers: ", format(passengerData()@data$count,
                                                          big.mark = ',',
                                                          big.interval = 3)))
    }
  })
}
