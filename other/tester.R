library(igraph)
library(jsonlite)
library(mapview)
library(rgdal)
library(fasttime)

# read in station data from file
# stations.json <- fromJSON(txt = "./data/stations.geojson")
# stations.spatial <- readOGR(dsn = "./data/stations.geojson")
# stations.df <- stations.json$features

# read in track data from file, create dataframe
# tracks.spatial <- readOGR(dsn = "./data/tracks.geojson")
# tracks.df <- data.frame(tracks.spatial$id, as.character(tracks.spatial$name), stringsAsFactors = FALSE)
# colnames(tracks.df) <- c("id", "stations")

# split station pairs
# stations.split <- strsplit(tracks.df$stations, "-", fixed = TRUE)
# tracks.df$station1 <- unlist(lapply(stations.split, `[[`, 1))
# tracks.df$station2 <- unlist(lapply(stations.split, `[[`, 2))

# soo <- readRDS("./data/date-hour-soo-dest-all.rds")

# map edges to mapping

# options to reduce load time
# pre-parse data, save as RDS (downside: no more hourly data, no station to station data)
# load all files into data frames (downside: slow?)
# build SQLite DB and pull as needed (downside: need to build DB)