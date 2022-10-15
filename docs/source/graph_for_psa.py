# ----------------------------------------------------------------------------
# Renee Oles      30 Aug 2022
# ----------------------------------------------------------------------------

import networkx as nx
import pandas as pd
import numpy as np
import copy
import csv

pathDict = {}
memberDict = {}
end = []


def dfsPath(
    graph,
    node,
    path,
    members,
    ):
    """
    A recursive function to find all possible paths in a graph.

    Parameters
    ----------
    graph: a graph object of networkx
        This object has the following attributes:
            graph.degree : list
                The amount of edges per node
    node: str
        str reference of the current node
    path: list
        order or nodes in current path
    members: list
        details genomeIDs currently being followed in path
    """    
    if nx.get_node_attributes(graph, 'name')[node] not in path:

        # Add the new node to the path
        path.append(nx.get_node_attributes(graph, 'name')[node])
        global pathDict
        global memberDict

        # If the path is greater than 40, then end the path here
        # Or if we've reached the end of the path, end the path here
        if path[len(path)-1] in end or graph.degree[node] == 1 or len(path) > 40:
            # If there are at least 20 isolates present in the path
            if path[len(path)-1] in end:
                name = 'path' + str(len(pathDict))
                pathDict[name] = copy.deepcopy(path)
                memberDict[name] = copy.deepcopy(members)
        
        # If not go through all neighbors of the current node 
        else:
            for neighbour in nx.all_neighbors(graph, node):
                print(path)
                # Check if the neighbour is already in the path
                if nx.get_node_attributes(graph, 'name')[neighbour] not in path:
                    # Find the members in common between old and new edge
                    newMembers = graph.get_edge_data(node,
                            neighbour)['genomeIDs'].split(';')
                    intersectionMembers = [c for c in members if c
                            in newMembers]

#                    print(path)
 #                   print(nx.get_node_attributes(graph, 'name')[neighbour])
  #                  print(len(intersectionMembers) / len(newMembers))

                    # If the neighboring edge's members do not match 
                    # 65% of the members in previous edge, do not traverse
                    if len(intersectionMembers) / len(newMembers) \
                        > 0.20 or len(intersectionMembers) \
                        / len(members) > 0.20:

                        # Recursive call to continue to the next node
                        if len(newMembers) < len(members):
                            dfsPath(graph, neighbour, path, newMembers)
                        else:
                            dfsPath(graph, neighbour, path, members)

            # If after going through all neighbors, we've finished, then we will end the path
            # If the current path fits the requirements
            if len(path) > 3 and len(members) > 5:
                if len(pathDict) > 0:
                    # make sure we don't already ahve this path
                    intersectionPath = [c for c in path if c
                            in pathDict['path' + str(len(pathDict)
                            - 1)]]
                    if len(intersectionPath) != len(path) and path[len(path)-1] in end:
                        name = 'path' + str(len(pathDict))
                        pathDict[name] = copy.deepcopy(path)
                        memberDict[name] = copy.deepcopy(members)
                elif path[len(path)-1] in end:
                    name = 'path' + str(len(pathDict))
                    pathDict[name] = copy.deepcopy(path)
                    memberDict[name] = copy.deepcopy(members)
        path.pop()
    return 0


def uploadGraph(file, root):
    """
    load graph and starting node
    """

    G = nx.read_graphml(file)

# ....G = nx.read_gml(file)

    G = G.to_undirected()


    # Find the node based off the name in string form

    source = ''.join([x for (x, y) in G.nodes(data=True) if y['name']
                     == root])

    # Conduct a BFS from the node of interest
    # To get the nodes in a breadth-first search order:

    # Remove edges that are less than a specific size

    long_edges = list(filter(lambda e: e[2] < 5, (e for e in
                      G.edges.data('size'))))
    le_ids = list(e[:2] for e in long_edges)

    # remove filtered edges from graph G

    G.remove_edges_from(le_ids)
    edges = nx.bfs_edges(G, source)
    nodes = [v for (u, v) in edges]
    names = nx.get_node_attributes(G, 'name')

    # Compare genomeIDs between edge and potential next edge

    path = []
    path = dfsPath(G, source, path, nx.get_node_attributes(G,
                   'genomeIDs')[source].split(';'))

# ....print("{" + "\n".join("{!r}: {!r},".format(k, v) for k, v in pathDict.items()) + "}")

    with open('../Operons/ps/' + root
              + 'path.csv', 'w') as f:
        for key in pathDict.keys():
            f.write('%s, %s\n' % (key, pathDict[key]))

    with open('../Operons/ps/' + root
              + 'member.csv', 'w') as f:
        for key in memberDict.keys():
            f.write('%s, %d, %s\n' % (key,len(memberDict[key]),memberDict[key]))

    return 0


    # Add attribute path as a key to each edge

if __name__ == '__main__':
    end=['tagO_2~~~wecA_1~~~tagO_3~~~tagO_1~~~wecA_2']
    uploadGraph('d2.graphml', 'rfaH_2~~~rfaH_8~~~rfaH_1')

