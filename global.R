# pre-processing that only needs to be done once

library(data.table) # fast CSV import using fread()
library(fasttime)   # needed for fastPOSIXct() to convert dates quickly
library(rgdal)      # needed for readOGR() to import spatial data

# bring in station data
stations <- readOGR(dsn = "./geojson/stations.geojson")

# bring in track data and convert columns
tracks <- readOGR(dsn = "./geojson/tracks.geojson")
tracks@data[] <- lapply(tracks@data, as.character)
tracks@data$id <- 1:nrow(tracks@data)

# bring in soo data by year in order
soo <- data.frame(matrix(ncol = 5, nrow = 0), stringsAsFactors = FALSE)
for (filename in sort(dir("./data", "*.csv", full.names = TRUE))) {
  soo <- rbind(soo, fread(filename, header = FALSE, stringsAsFactors = FALSE))
}

# fix column names
colnames(soo) <- c("date", "hour", "origin", "destination", "count")

# convert date using fastPOSIXct()
# we use this function because using as.POSIXct() is *extremely* slow
# this creates an oddity of needing all the times to be in UTC, though
soo$date <- fastPOSIXct(soo$date, tz = "UTC")

# save first and last dates in soo data
minDate <- min(soo$date)
maxDate <- max(soo$date)

# create station abbreviation lookup table
stationLookup <- stations@data[, which(names(stations@data) %in% c("name", "abbreviation"))]
stationLookup[] <- lapply(stationLookup, as.character)

# create character string of hour ranges in 12-hour format
# we need to put a date in there even though we're going to throw it away anyway
twelveHour <- strftime(paste("2000-01-01 ",
                             as.character(seq(from = 0, to = 23, by = 1)),
                             ":00", sep = ""),
                       "%I:00-%I:59 %p")
