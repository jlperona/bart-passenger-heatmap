# GeoJSON files

The Shiny app expects both `stations.geojson` and `tracks.geojson` to exist in this folder.

## `stations.geojson`

This file is a GeoJSON file that contains the station locations.

### Creation

The original data was sourced from the "stations and lines" KML file provided on [BART's website](https://www.bart.gov/schedules/developers/geo).
Below is the methodology with QGIS:

1. Import the KML file into QGIS and export the station layer into GeoJSON. It's easier to edit GeoJSON in QGIS.
2. Re-import the GeoJSON.
3. Remove a couple of features:
    * a transfer station for Oakland International Airport
    * a transfer station for eBART at Pittsburg/Bay Point
4. Remove extra columns, and add a column for station abbreviations.
5. Export the final GeoJSON.

### Reproducibility

It is possible to write a script either using `rgdal` for R or Python extensions for QGIS to clean the KML files and export to GeoJSON.
That's a potential addition for the future.

## `tracks.geojson`

This file is a GeoJSON file that contains the tracks between adjacent stations.

### Creation

The original data was sourced from the "stations and lines" KML file provided on [BART's website](https://www.bart.gov/schedules/developers/geo).
The problem with that data is that the tracks are listed via route, so there's one polyline for an entire route.
In order to color each segment separately with the number of passengers, we need separate pieces of track between stations.
I was unable to find this data anywhere else, so I made it myself.
Hence, this GeoJSON file has one polyline per station.

Below is the methodology with QGIS:

1. Import the KML file into QGIS and export the track layer into GeoJSON. It's easier to edit GeoJSON in QGIS.
2. Re-import the GeoJSON.
3. Using QGIS's Split Features tool, cut off the extra pieces of track past the end of some lines.
4. Painstakingly split the polylines manually at stations with the Split Feature tool.
    * The majority of these are easy, as the polylines in the original layer are pretty long.
    * For places where there are multiple connecting stations: duplicate, split, and merge as necessary to get a single polyline to each of the other stations.
4. Remove all other columns in the feature table.
5. Add columns and data for `station1`, `station2`, and rename each feature appropriately.
6. Export the final GeoJSON.

Using *Split Lines at Points* tools makes the splitting process faster at the cost of accuracy and more re-merging features.
There's no automated way to handle the multiple connecting stations problem; that has to be done manually.
Adding data needs to be done manually as well.

### Reproducibility

Unlike with the previous file, I don't see a way to reproduce what I did via a script.
There were many modifications that I had to make, and it would be difficult to script that in GIS software.

## Using the files

The intention is to bring these into the Shiny app and map them using `leaflet`.
However, I can imagine that this data might be useful for other projects, too.
