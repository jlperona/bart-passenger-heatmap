import argparse
import csv
import networkx as nx

from typing import Union


def valid_graph_ext(input: str) -> str:
    """Verifier function used with argparse's type argument.
    Checks for certain filename extensions.
    """

    filetypes = {'net', 'gexf'}

    if input.split('.')[input.count('.')].lower() not in filetypes:
        msg = 'Unrecognized file format: \'{0}\'.'.format(input)
        raise argparse.ArgumentTypeError(msg)

    return input


def argument_parsing() -> argparse.Namespace:
    """Parse input arguments with argparse."""

    parser = argparse.ArgumentParser(
        description='Take in BART origin-destination data and a source graph. '
                    'Output a CSV file that gives passengers between adjacent '
                    'stations. A passenger who travels between two stations '
                    'adds one to the count of all stations along the '
                    'shortest path between those two stations.'
    )

    # mandatory/positional arguments
    parser.add_argument(
        'inputfile',
        type=valid_graph_ext,
        metavar='input.[gexf,net]',
        help='Graph to use as the basis. '
             'Supports GEXF and Pajek NET. '
             'Format will be guessed from the file extension.'
    )

    parser.add_argument(
        'outputfile',
        metavar='output.csv',
        help='CSV file to write the final results to.'
    )

    parser.add_argument(
        'csvfile',
        nargs=argparse.REMAINDER,
        metavar='...',
        help='BART origin-destination data files to read from. '
             'Accepts multiple files, parses and writes in order given.'
    )

    # optional arguments
    parser.add_argument(
        '-d',
        '--directed',
        action='store_true',
        help='Create a directed graph instead of an undirected one.'
    )

    return parser.parse_args()


def generate_base_graph(args: argparse.Namespace) -> Union[nx.Graph,
                                                           nx.DiGraph]:
    """Create a dictionary of shortest paths.
    The dictionary is in the format [source][dest][nodes in path].
    The shortest paths are cached to
    """
    inputtype = args.inputfile.split('.')[args.inputfile.count('.')].lower()

    # import graph representation using NetworkX
    if inputtype == 'net':
        base_multigraph = nx.read_pajek(args.inputfile)
    elif inputtype == 'gexf':
        base_multigraph = nx.read_gexf(args.inputfile)

    # convert to undirected or directed depending on arguments
    if args.directed:
        return nx.DiGraph(base_multigraph)
    else:
        return nx.Graph(base_multigraph)


def generate_output(args: argparse.Namespace,
                    base_graph: Union[nx.Graph, nx.DiGraph],
                    shortest_paths: dict) -> None:
    """Take in the base graph and dictionary of shortest paths.
    Write edge weights to the singular output file defined by args.
    The edges are the station links defined in base_graph.
    The weights are the number of passengers that traveled along that edge.

    If a passenger travels between two stations, they add 1 weight to every
    edge in the shortest path between those two stations.
    """
    # truncate output file
    open(args.outputfile, 'w').close()

    seen_date_hours = set()

    # iterate over all CSV files
    for current_file in args.csvfile:
        # import current CSV file and start reading in rows
        with open(current_file) as csvfile:
            csvreader = csv.reader(csvfile)

            # starting with a new file, no previous date-hour
            previous_date, previous_hour = '', ''

            # zero out all weights on the graph
            for source, destination in nx.edges(base_graph):
                base_graph[source][destination]['weight'] = 0

            # parse out relevant information in row
            for row in csvreader:
                try:
                    # get current date-hour
                    current_date, current_hour = row[0], row[1]

                    # first line of file, update previous date-hour
                    if previous_date == '' and previous_hour == '':
                        previous_date = current_date
                        previous_hour = current_hour
                    # changing hour or day, write current day-hour to file
                    elif (current_date != previous_date or
                            current_hour != previous_hour):

                        date_hour = previous_date + ' ' + previous_hour

                        # BART has a bad habit of duplicating hours of data
                        # so if we've seen this date-hour before don't write it
                        if date_hour not in seen_date_hours:
                            seen_date_hours.add(date_hour)

                            with open(args.outputfile, 'a') as outputfile:
                                csvwriter = csv.writer(outputfile)

                                # write edge weights of previous graph to file
                                for source, destination in nx.edges(base_graph):
                                    weight = (base_graph[source]
                                              [destination]['weight']
                                              )
                                    csvwriter.writerow([previous_date,
                                                        previous_hour,
                                                        source,
                                                        destination,
                                                        weight]
                                                       )

                        # zero out edge weights for new graph
                        # do this even if we've seen the date-hour before
                        for source, destination in nx.edges(base_graph):
                            base_graph[source][destination]['weight'] = 0

                    source, destination = row[2], row[3]
                    passengers = int(row[4])

                    # for every adjacent pair of vertices in the shortest path
                    for index in range(len(shortest_paths[source][destination])
                                       - 1):
                        first = shortest_paths[source][destination][index]
                        second = shortest_paths[source][destination][index + 1]

                        # add the number of passengers to the edge weight
                        base_graph[first][second]['weight'] += passengers

                    previous_date, previous_hour = current_date, current_hour

                except Exception:
                    print('Exception occurred at line number ',
                          csvreader.line_num, ' in ', str(current_file), '.',
                          sep='')
                    raise

        # print out very last hour in data
        with open(args.outputfile, 'a') as outputfile:
            csvwriter = csv.writer(outputfile)

            date_hour = previous_date + ' ' + previous_hour

            # BART has a bad habit of duplicating hours of data
            # so if we've seen this date-hour before don't write it
            if date_hour not in seen_date_hours:
                seen_date_hours.add(date_hour)

                # write edge weights of previous graph to file
                for source, destination in nx.edges(base_graph):
                    weight = base_graph[source][destination]['weight']
                    csvwriter.writerow([previous_date,
                                        previous_hour,
                                        source,
                                        destination,
                                        weight]
                                       )


def main():
    """Take in inputs, generate output file."""
    args = argument_parsing()
    base_graph = generate_base_graph(args)
    # build lookup table of shortest paths
    shortest_paths = nx.shortest_path(base_graph)
    generate_output(args, base_graph, shortest_paths)


if __name__ == "__main__":
    main()
