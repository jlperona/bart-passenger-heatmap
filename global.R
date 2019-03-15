library(data.table) # fast CSV import using fread()
library(fasttime)   # needed for fastPOSIXct()
library(rgdal)      # needed for readOGR()

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

# aggregate data together by edge
trackCount <- aggregate(soo$count, by = list(soo$origin, soo$destination), FUN = sum)
colnames(trackCount) <- c("station1", "station2", "count")

# paste together station names both ways
# we don't necessarily know which order of name in tracks@data is correct
# so we have to do both
trackCount$name1 <- paste(trackCount$station1, trackCount$station2, sep = '-')
trackCount$name2 <- paste(trackCount$station2, trackCount$station1, sep = '-')
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

# create station abbreviation lookup table
stationLookup <- stations@data[, which(names(stations@data) %in% c("name", "abbreviation"))]
stationLookup[] <- lapply(stationLookup, as.character)

# merge station data with full station names
colnames(stationLookup) <- c("full1", "abbreviation")
trackCount <- merge(trackCount, stationLookup, by.x = "station1", by.y = "abbreviation")
colnames(stationLookup) <- c("full2", "abbreviation")
trackCount <- merge(trackCount, stationLookup, by.x = "station2", by.y = "abbreviation")

# order by ID
tracks@data <- trackCount[order(trackCount$id), ]
rownames(tracks@data) <- 1:nrow(tracks@data)
