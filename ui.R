# code to create the rendering

library(leaflet) # base for shiny map display

ui <- fluidPage(
  
  # add the title to the top of the page
  titlePanel("BART Passenger Heatmap"),
  
  # the main portion of the app
  fluidRow(
    
    # the rendered map
    column(width = 10,
      leafletOutput("basemap",
                    height = 1000)
    ),
      
    # the buttons, all together in one centered column
    column(width = 2,
           align = "center",
           
      # selector for the desired date range
      # minimums and maximums are determined from the input data
      dateRangeInput("dateRange",
                     label = "Date Range: YYYY-MM-DD",
                     start = min(soo$date),
                     end = max(soo$date),
                     min = min(soo$date),
                     max = max(soo$date)),
      
      # checkboxes for the desired times
      # we use checkboxes so users can pick non-contiguous ranges
      checkboxGroupInput("timeRange",
                         label = "Hours",
                         choiceNames = twelveHour,
                         choiceValues = seq(from = 0, to = 23, by = 1),
                         selected = seq(from = 0, to = 23, by = 1)),
      
      # update button
      # updates the map when pressed
      actionButton("updateDatetime",
                   label = "Update")
    )
  )
)
