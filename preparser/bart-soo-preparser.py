import argparse
import csv
import networkx as nx

def valid_graph_ext(input):
    filetypes = {'net', 'gexf'}

    if input.split('.')[input.count('.')].lower() not in filetypes:
        msg = 'Unrecognized file format: \'{0}\'.'.format(input)
        raise argparse.ArgumentTypeError(msg)

    return input

parser = argparse.ArgumentParser(
    description = 'Take in BART origin-destination data and a source graph. Output a CSV file that gives passengers between adjacent stations.')

# mandatory/positional arguments
parser.add_argument('inputfile', type = valid_graph_ext, metavar = 'input.[gexf,net]',
    help = 'Graph to use as the basis. Supports GEXF and Pajek NET. Format will be guessed from the file extension.')
parser.add_argument('outputfile', metavar = 'output.csv',
    help = 'CSV file to write the final results to.')
parser.add_argument('csvfile', nargs = argparse.REMAINDER, metavar = '...',
    help = 'BART origin-destination data files to read from. Accepts multiple files, parses and writes in order.')

# optional arguments
parser.add_argument('-d', '--directed', action = 'store_true',
    help = 'Create a directed graph instead of an undirected one.')

args = parser.parse_args()

# truncate output file
open(args.outputfile, 'w').close()

inputtype = args.inputfile.split('.')[args.inputfile.count('.')].lower()

# import graph representation using NetworkX
if inputtype == 'net':
    base_multigraph = nx.read_pajek(args.inputfile)
elif inputtype == 'gexf':
    base_multigraph = nx.read_gexf(args.inputfile)

# convert to undirected or directed depending on arguments
if args.directed is True:
    base_graph = nx.DiGraph(base_multigraph)
else:
    base_graph = nx.Graph(base_multigraph)

# build lookup table of shortest paths
shortest_paths = nx.shortest_path(base_graph)

# iterate over all CSV files
for current_file in args.csvfile:
    # import current CSV file and start reading in rows
    with open(current_file) as csvfile:
        csvreader = csv.reader(csvfile)

        # starting with a new file, no previous date-hour
        previous_date = -1
        previous_hour = -1

        # zero out all weights on the graph
        for source, destination in nx.edges(base_graph):
            base_graph[source][destination]['weight'] = 0

        # parse out relevant information in row
        for row in csvreader:
            linenumber = csvreader.line_num

            try:
                # get current date-hour
                current_date = row[0]
                current_hour = int(row[1])

                # first line of file, update previous date-hour
                if previous_date == -1 and previous_hour == -1:
                    previous_date = current_date
                    previous_hour = current_hour

                if current_date != previous_date or current_hour != previous_hour:
                    with open(args.outputfile, 'a') as outputfile:
                        csvwriter = csv.writer(outputfile)

                        # write edge weights of previous graph to file
                        for source, destination in nx.edges(base_graph):
                            weight = base_graph[source][destination]['weight']
                            csvwriter.writerow([previous_date, previous_hour, source, destination, weight])

                    # zero out edge weights for new graph
                    for source, destination in nx.edges(base_graph):
                        base_graph[source][destination]['weight'] = 0

                source = row[2]
                destination = row[3]
                passengers = int(row[4])

                # for every adjacent pair of vertices in the shortest path
                for index in range(0, len(shortest_paths[source][destination]) - 1):
                    first = shortest_paths[source][destination][index]
                    second = shortest_paths[source][destination][index + 1]

                    # add the number of passengers to the edge weight
                    base_graph[first][second]['weight'] += passengers

                previous_date = current_date
                previous_hour = current_hour

            except:
                print('Exception occurred at line number', linenumber, 'in', args.csvfile)
                raise

    # print out very last hour in data
    with open(args.outputfile, 'a') as outputfile:
        csvwriter = csv.writer(outputfile)

        # write edge weights of previous graph to file
        for source, destination in nx.edges(base_graph):
            weight = base_graph[source][destination]['weight']
            csvwriter.writerow([previous_date, previous_hour, source, destination, weight])
