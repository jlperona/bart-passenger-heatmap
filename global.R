library(data.table) # fast CSV import using fread()
library(fasttime)   # needed for fastPOSIXct()
library(igraph)     # needed to convert soo data to edge weights
library(leaflet)    # base for shiny map display
library(rgdal)      # needed for readOGR()
library(shiny)      # base for shiny application

# bring in station data
stations <- readOGR(dsn = "./data/stations.geojson")

# bring in track data and convert columns
tracks <- readOGR(dsn = "./data/tracks.geojson")
tracks@data[] <- lapply(tracks@data, as.character)
tracks@data$id <- as.integer(tracks@data$id)

# bring in soo data, fix column names, and convert date
data.20181231 <- fread("./data/2018-12-31.csv",
                       header = FALSE,
                       stringsAsFactors = FALSE)
colnames(data.20181231) <- c("date", "hour", "origin", "destination", "count")
data.20181231$date <- fastPOSIXct(data.20181231$date, tz = "UTC")

# import graph, remove extra edges, and set weights to 0
weightedGraph <- read_graph("./data/bart-abbreviations.net",
                            format = "pajek") %>%
  simplify() %>%
  set_edge_attr(name = "weight", value = 0)

# loop over all rows in the soo data
# attempted to use apply() to vectorize this and it didn't work
for(row in 1:nrow(data.20181231))
{
  # find shortest path from origin to destination
  shortestPath <- shortest_paths(weightedGraph,
                                 from = as.character(data.20181231[row, "origin"]),
                                 to = as.character(data.20181231[row, "destination"]),
                                 weights = NA,
                                 output = "epath")$epath[[1]]

  # add the count to the value that's currently there
  edge_attr(weightedGraph, "weight", shortestPath) <-
    edge_attr(weightedGraph, "weight", shortestPath) +
    as.numeric(data.20181231[row, "count"])
} # for all rows in the soo data

# merge the weights with the track geometry
# attempted to vectorize this and it didn't work
for(row in 1:nrow(tracks@data))
{
  # look up edge ID in graph using vertex names
  edgeID <- get.edge.ids(weightedGraph, c(tracks@data[row, "station1"], tracks@data[row, "station2"]))
  # add this to the tracks data so it's accessible by leaflet
  tracks@data[row, "weight"] <- E(weightedGraph)[edgeID]$weight
}
