# Preparser

This Python script preparses BART hourly origin-destination data, available on [the BART website](https://www.bart.gov/about/reports/ridership).

## Prior work

This script is based heavily on my previous work [bart-hourly-dataset-parser](https://github.com/jlperona/bart-hourly-dataset-parser), which is licensed under the MIT License.
Unlike that script, this script turns the final output back into a CSV file of the same format as the BART data.
It still requires a input graph file, but doesn't write to another graph file.
