# create an RDS file out of all the soo files in "./soo"
# can easily run this to add another soo file without having to include every single new soo file that BART posts
# each soo file is ~250 MB, doing this method compressed ~2 GB down to 110 KB
# ended up with a compression of about 94%

# data.table is necessary for fread() to import all the CSVs quickly
library(data.table)
# fasttime is necessary for fastPOSIXct() to convert the date column quickly
library(fasttime)

# pull filenames from subdirectory containing soo data
filenames <- dir("./soo", full.names = TRUE)

# merge into one dataframe, rename columns, convert date to POSIXct
soo <- do.call(rbind, lapply(filenames, fread, header = FALSE))
colnames(soo) <- c("date", "hour", "src", "dest", "count")
soo$date <- fastPOSIXct(soo$date, tz = "UTC")

# save out to RDS
saveRDS(soo, file = "./data/date-hour-soo-dest-all.rds")