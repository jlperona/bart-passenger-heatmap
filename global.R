# pre-processing that only needs to be done once

library(data.table) # fast CSV import using fread()
library(fasttime)   # needed for fastPOSIXct() to convert dates quickly
library(rgdal)      # needed for readOGR() to create spatial data

# bring in station data
stations <- readOGR(dsn = "./geojson/stations.geojson")

# bring in track data and convert columns
tracks <- readOGR(dsn = "./geojson/tracks.geojson")
tracks@data[] <- lapply(tracks@data, as.character)
tracks@data$id <- as.integer(tracks@data$id)

# bring in soo data, fix column names, and convert date
soo <- fread("./data/date-hour-soo-dest-all.csv",
             header = FALSE,
             stringsAsFactors = FALSE)
colnames(soo) <- c("date", "hour", "origin", "destination", "count")
soo$date <- fastPOSIXct(soo$date, tz = "UTC")

# create station abbreviation lookup table
stationLookup <- stations@data[, which(names(stations@data) %in% c("name", "abbreviation"))]
stationLookup[] <- lapply(stationLookup, as.character)

# create character string of hour ranges in 12-hour format
twelveHour <- strftime(paste("2000-01-01 ",
                             as.character(seq(from = 0, to = 23, by = 1)),
                             ":00", sep = ""),
                       "%I:00-%I:59 %p")
