# base imports
import networkx as nx  # type: ignore

# relative imports
import utils.commandline
import utils.processing


def main():
    """Take in inputs, generate output file."""

    args = utils.commandline.argument_parsing()
    base_graph = utils.processing.generate_base_graph(args)
    # build lookup table of shortest paths
    shortest_paths = nx.shortest_path(base_graph)
    utils.processing.generate_output(args, base_graph, shortest_paths)


if __name__ == "__main__":
    main()
