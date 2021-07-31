import argparse
import csv
import networkx as nx  # type: ignore

from typing import Union


def generate_base_graph(args: argparse.Namespace) -> Union[nx.Graph,
                                                           nx.DiGraph]:
    """Create the base graph used for the remainder of the calculations.
    Import from inputfile, then convert to directed or undirected as desired.
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
            for source, dest in nx.edges(base_graph):
                base_graph[source][dest]['weight'] = 0

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
                                for source, dest in nx.edges(base_graph):
                                    weight = (base_graph[source]
                                              [dest]['weight']
                                              )
                                    csvwriter.writerow([previous_date,
                                                        previous_hour,
                                                        source,
                                                        dest,
                                                        weight]
                                                       )

                        # zero out edge weights for new graph
                        # do this even if we've seen the date-hour before
                        for source, dest in nx.edges(base_graph):
                            base_graph[source][dest]['weight'] = 0

                    source, dest = row[2], row[3]
                    passengers = int(row[4])

                    # for every adjacent pair of vertices in the shortest path
                    for index in range(len(shortest_paths[source][dest])
                                       - 1):
                        first = shortest_paths[source][dest][index]
                        second = shortest_paths[source][dest][index + 1]

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
                for source, dest in nx.edges(base_graph):
                    weight = base_graph[source][dest]['weight']
                    csvwriter.writerow([previous_date,
                                        previous_hour,
                                        source,
                                        dest,
                                        weight]
                                       )
