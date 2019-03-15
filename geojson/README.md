# GeoJSON files

The Shiny app expects both `stations.geojson` and `tracks.geojson` to exist in this folder.

## `stations.geojson`

This file is a GeoJSON file that contains the station locations.

### Creation

The original data was sourced from the "stations and lines" KML file provided on [BART's website](https://www.bart.gov/schedules/developers/geo).
I originally imported those files into ArcGIS and saved them into GeoJSON.
However, I've made significant edits since then to remove extraneous data provided by ArcGIS.
I also corrected the station names to match the [system map](https://www.bart.gov/system-map), and provided the abbreviations separately.

### Reproducibility

Normally, I'm a fan of reproducible analysis, and being able to reproduce this file from the original KML via a script would be nice.
However, I made significant changes to what was provided in the original KML without saving my steps.
It should be possible to write a script using `rgdal` to create the GeoJSON data in this format.
That's a potential addition for the future.

## `tracks.geojson`

This file is a GeoJSON file that contains the tracks between adjacent stations.

### Creation

The original data was sourced from the "stations and lines" KML file provided on [BART's website](https://www.bart.gov/schedules/developers/geo).
The problem with that data is that the tracks are listed via route, so there's one polyline for an entire route.
In order to color each segment separately with the number of passengers, we need separate pieces of track between stations.
I was unable to find this data anywhere else, so I made it myself.
Hence, this GeoJSON file has one polyline from station to station.

To create this file, I imported the track data from the KML file above into ArcGIS.
I then split the polylines for the routes by the stations into separate segments, using the station points themselves to split it.
Due to the way it was split, I had to merge some pieces back together, and remove some duplicates.
Finally, I exported the data to GeoJSON via ArcGIS.
I also removed some extraneous data provided by ArcGIS, and renamed track segments to be more descriptive.

### Reproducibility

Unlike with the previous file, I don't see a way to reproduce what I did in ArcGIS via a script.
There were many modifications that I had to make, and I'm not sure it's possible to script that in ArcGIS.

## Using the files

The intention is to bring these into the Shiny app and map them using `leaflet`.
However, I can imagine that this data might be useful for other projects, too.
