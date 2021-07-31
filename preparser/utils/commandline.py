import argparse


def valid_graph_ext(input: str) -> str:
    """Verifier function used with argparse's type argument.
    Checks for certain filename extensions.
    """

    filetypes = {'net', 'gexf'}

    if input.split('.')[-1].lower() not in filetypes:
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
        metavar='input1.csv ...',
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
