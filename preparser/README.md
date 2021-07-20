# Preparser

This Python script preparses BART hourly origin-destination data for use with the Shiny app [`bart-passenger-heatmap`](https://github.com/jlperona/bart-passenger-heatmap).
The BART data is available on [their website](https://www.bart.gov/about/reports/ridership).

## Background

I created this script to preparse data for [`bart-passenger-heatmap`](https://github.com/jlperona/bart-passenger-heatmap).
I created that Shiny application for a class that I took while in graduate school.

### Previous Work

This script is based heavily on my previous work [`bart-hourly-dataset-parser`](https://github.com/jlperona/bart-hourly-dataset-parser), which is licensed under the MIT License.
That script generates another graph file as its output.
Unlike that script, this script turns the final output back into a CSV file of the same format as the BART data.
It still requires a input graph file, though.

### Reasoning

The preparser takes in [BART hourly-origin-destination data](https://www.bart.gov/about/reports/ridership) that is provided on their website.
This data is equivalent to a fully-connected graph, where the nodes are the stations, and the edge weights are the number of passengers who traveled between each station.
Since the number of edges is on the order of `n^2`, this isn't easy to visualize using the BART network.
Instead, we need to turn these into a graph that only connects adjacent stations.
This graph has a more manageable number of edges on the order of `n`.

### Methodology

The preparser is heavily based on the Python script in [`bart-hourly-dataset-parser`](https://github.com/jlperona/bart-hourly-dataset-parser).
It does the following:

1. Parse the input graph `preparser/network/bart-abbreviations.net` to set up the network topology.
2. Read in the input data row by row.
3. Group all rows with the same date-hour combination.
	1. In each group, for every row's origin-destination pair, calculate the shortest path between the two stations. Due to the current topology of the network, there will only ever be one shortest path.
	2. Add the number of passengers to each edge on the shortest path.
	3. Write out data for each edge in the same format as the input data.

This could have been done in Shiny using `igraph`, but it took way too long to parse.
One day's worth of data took 5 minutes.
Using the preparser took about 30 minutes to run on 10 years' worth of data, but the Shiny app now loads within seconds.
The great thing about the preparser is that it's easy to re-run if BART updates their data.

## Python

### Version

This is a Python 3 script.

### Dependencies

The script uses `networkx` to parse the input graph.
It can be found on `pip`.
If you'd like to set up a virtual environment, the typical code to do so is below:

```
python3 -m venv env
source env/bin/activate
python3 -m pip install -r requirements.txt
```

The script has been tested against `flake8` and `mypy`, both of which can also be installed on `pip`.

## Usage

```
python3 bart-soo-preparser.py [-h] [--flags] input.[gexf,net] output.csv input1.csv ...
```

### Flags

The following flag is available.
For more information, use the `-h` flag when running the script.

#### Graph Directionality

`-d` and `--directed` allow you to specify that a directed graph should be output.
By default, the script defaults to an undirected graph.

### Positional Arguments

#### `input.[gexf,net]`

The representation of the BART network that serves as the basis to calculate shortest paths.
An example file has been provided at `network/bart-abbreviations.net`.
Note that this file will need to be modified to keep up with expansions in the BART network.

The following file formats are supported:

* GEXF
* Pajek NET

NetworkX supports many other graph file formats.
Adding these would be fairly simple.

#### `output.csv`

The CSV file which output is written to.
For what this file looks like, see the [data README](../data/README.md).

#### `input1.csv ...`

The CSV files provided by BART on [their website](https://www.bart.gov/about/reports/ridership).
You can provide as many as you want.

The script writes output in the same order that they're passed in.
If you want the final output to be pre-sorted, pass in the data in order.
For example, pass in the CSV file for 2011, then 2012, and so on.

## Future

I have a couple of changes in mind for the future.
These changes follow the same ones listed for [`bart-hourly-dataset-parser`](https://github.com/jlperona/bart-hourly-dataset-parser).
