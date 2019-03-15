library(leaflet) # base for shiny map display

ui <- fluidPage(
  titlePanel("BART Passenger Heatmap"),
  
  fluidRow(
    column(width = 10,
      leafletOutput("basemap",
                    height = 1000)
    ),
      
    column(width = 2,
      dateRangeInput("dateRange",
                     label = "Date Range Input: YYYY-MM-DD",
                     start = min(soo$date),
                     end = max(soo$date)
                     ),
      
      numericInput("timeRangeStart",
                   label = "Time Range Start (0 - 23)",
                   value = 0,
                   min = 0,
                   max = 23,
                   step = 1
                   ),
      
      numericInput("timeRangeEnd",
                   label = "Time Range End (0 - 23)",
                   value = 23,
                   min = 0,
                   max = 23,
                   step = 1
      ),
      
      actionButton("updateDatetime",
                   label = "Update")
    )
  )
)

# next up: add date/hour select in ui.R
# use reactives to only calculate weights as necessary
