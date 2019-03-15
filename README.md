# BART Passenger Heatmap

Shiny app for displaying BART hourly origin-destination data.
You can find a hosted version of this on [shinyapps.io](https://jlperona.shinyapps.io/bart-passenger-heatmap/).
(If it's down, it's probably because my free tier was exhausted.)

## Background

I created this application for a class that I took while in graduate school.

### Previous Work

This application is heavily based on my previous work, [`bart-hourly-dataset-parser`](https://github.com/jlperona/bart-hourly-dataset-parser), which is licensed under the MIT License.
I used the Python script and the Pajek NET file in that repository to build the ones in this repository.
The methodology is almost identical to the one in that script, as well.

### Reasoning

I wanted to see the BART network mapped with actual GIS data, and with the passenger data that BART provides [on their website](https://www.bart.gov/about/reports/ridership).
One of the ways of doing that was by combining Shiny, which helps me create a web application, with `leaflet`, which lets me map the GIS data.
I'm sure there are other ways of visualizing this data, but just like with `bart-hourly-dataset-parser`, I made this for a class project.
I needed to use R, so this was a reasonable choice.

For true heatmapping purposes, using the actual track data isn't the best since tracks vary in size.
This is visible on the current track data.
A stylized version, like the [BART system map](https://www.bart.gov/system-map), would probably be better. 

### Methodology

There are two main pieces to this application:

* the preparser, which is in `preparser/`
* the actual Shiny code, which is in the `.R` files in the main directory

#### Preparser

See [the README for the preparser](preparser/README.md) for more information on the preparser.

#### Shiny Application

The Shiny application takes in the preparser output, as mentioned above.
It also takes in GIS data in the GeoJSON format that is provided in `geojson/`.
(For an explanation of the GIS data, see [the GeoJSON README](geojson/README.md).)
Its output is a heatmap of where the passengers traveled on the network.

The Shiny application does the following:

1. Load the preparsed data.
2. Aggregate the data for each edge.
3. Load the station and track GIS data.
4. Render the station and tracks using `leaflet`.
5. Colors the tracks based on how many passengers traveled on that edge.

In the future, I'll get the sidebar to work, which will subset the data based on the desired date-time combination.
Then, it will re-render the track colorings when the update button is pressed.
This requires using Shiny's reactives, which I admittedly don't understand fully right now.

## Resources Used

I used a variety of resources to create this application.

[This blog post on DataScience.com](https://www.datascience.com/blog/beginners-guide-to-shiny-and-leaflet-for-interactive-mapping) was amazing for getting off the ground with mapping data using `leaflet` and Shiny together.
If you're looking to get started doing something like this, I highly recommend going through that tutorial and modifying it to suit your needs.

### Package Documentation

The references for the following packages proved invaluable to getting this working:

* [`data.table`](https://github.com/Rdatatable/data.table/wiki)
* [`leaflet`](https://rstudio.github.io/leaflet/)
* [Shiny](https://shiny.rstudio.com/articles/#first-app)

### Shiny Examples

Many of the [Shiny examples](https://github.com/rstudio/shiny-examples) were helpful for demonstrating different aspects of Shiny.
In particular, I used the following:

* [028-actionbutton-demo](https://github.com/rstudio/shiny-examples/tree/master/028-actionbutton-demo) to create the update button
* [035-custominput-bindings](https://github.com/rstudio/shiny-examples/tree/master/035-custom-input-bindings) to create the update button
* [037-date-and-date-range](https://github.com/rstudio/shiny-examples/tree/master/037-date-and-date-range) to create the date range selector
* [063-superzip-example](https://github.com/rstudio/shiny-examples/tree/master/063-superzip-example) 

### Stack Overflow

Finally, I utilized a few posts on [StackOverflow](https://stackoverflow.com/) to answer some questions that I had.
These include the following:

* [Batch convert columns to numeric type](https://stackoverflow.com/questions/19146354/batch-convert-columns-to-numeric-type)
* [Change the index number of a dataframe](https://stackoverflow.com/questions/7567790/change-the-index-number-of-a-dataframe)
* [Time range input with Hour level detail in shiny](https://stackoverflow.com/questions/38849674/time-range-input-with-hour-level-detail-in-shiny)

## Lessons Learned

Two things that I became very familiar with over the course of working on this project:

* Make sure to check that your strings are imported as characters, and not factors, if that's necessary for your logic. I spent a long time debugging that issue.
* Make sure you didn't accidentally overwrite your input data. Sometimes you accidentally modify it, even when you didn't mean to.

## Future

For right now, I want to get the sidebar, subsetting, and reactivity working.
The sidebar is useless right now, so giving that a purpose is priority one.

Another idea I had was to create different types of visualizations.
Exactly what types of visualizations is a very good question.
That's a reach goal, though.
