# Preparser

This Python script preparses BART hourly origin-destination data.
This data is available on the [BART website](https://www.bart.gov/about/reports/ridership).

## Prior work

This script is based heavily on my previous work [`bart-hourly-dataset-parser`](https://github.com/jlperona/bart-hourly-dataset-parser), which is licensed under the MIT License.
That script generates another graph file as its output.
Unlike that script, this script turns the final output back into a CSV file of the same format as the BART data.
It still requires a input graph file.

## Usage

```
python bart-soo-preparser.py input.[gexf,net] output.csv soo1.csv soo2.csv ...
```

## Network

The network file `bart-abbreviations.net` is based off of [the network file in `bart-hourly-dataset-parser`](https://github.com/jlperona/bart-hourly-dataset-parser/blob/master/network/bart.net).
I modified it to use the 4-letter station abbreviations to make it easier to index in R.

<> (TODO: update this file further)
