# GeoJSON files

The Shiny app expects both `stations.geojson` and `tracks.geojson` to exist in this folder.

## Caveat

**Note:** there are some missing tracks.
The passenger data is current up to June 2021, and all the stations up to June 2021 display.
However, the GeoJSON for the tracks needs to be updated for the Berryessa extension.
The data is calculated for them, but they won't display until polylines are added.

When I've fixed the GeoJSON, I'll remove this message.

## `stations.geojson`

This file is a GeoJSON file that contains the station locations.

### Creation

The original data was sourced from the "stations and lines" KML file provided on [BART's website](https://www.bart.gov/schedules/developers/geo).
I originally imported those files into GIS software and saved them into GeoJSON.
However, I've made edits since then to remove extraneous data and add the station abbreviations.

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
Hence, this GeoJSON file has one polyline from station to station.

To create this file, I imported the track data from the KML file above into GIS software (ArcGIS, QGIS).
I then split the polylines for the routes by the stations into separate segments, using the station points themselves to split it.
Due to the way it was split, I had to merge some pieces back together, and remove some duplicates.
Finally, I exported the data to GeoJSON.
I also removed some extraneous data, and renamed track segments to be more descriptive.

### Reproducibility

Unlike with the previous file, I don't see a way to reproduce what I did via a script.
There were many modifications that I had to make, and it would be difficult to script that in GIS software.

## Using the files

The intention is to bring these into the Shiny app and map them using `leaflet`.
However, I can imagine that this data might be useful for other projects, too.
