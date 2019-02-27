# -*- coding: utf-8 -*-
"""
Created on Tue Jul 31 17:38:55 2018

@author: spm9r
"""

import networkx as nx
import pandas as pd

# Read in updated concept relationship data including exclusivity
dfRel = pd.read_csv("C:/Users/spm9r/eclipse-workspace-spm9r/TREC2018/data/exclusivity_graph_data.csv", names=['CUI1','CUI2','rela','exclusivity'])

dfRelSub = dfRel[0:300000]

dfRelSub2 = dfRel.query('CUI1 == "C0006826"')

#G = nx.MultiGraph()

# Create subset graph
edge_list = []
for index, row in dfRelSub2.iterrows():
    #print(row['CUI1'], row['CUI2'], row['rela'])
    #tup = (row['CUI1'], row['CUI2'], "{'rel': '%s'}" % row['rela'])
    tup = (row['CUI1'], row['CUI2'], {'rel': row['rela'], 'exclusivity': row['exclusivity']})
    #print(tup)
    edge_list.append(tup)
    #G.add_edges_from(*tup)
G.add_edges_from(edge_list)
G.number_of_nodes()
#nx.draw(G)
#G.clear()


import matplotlib.pyplot as plt

#paths = nx.single_source_shortest_path_length(G, 'C0025202', cutoff=1)
#len(paths)

# some neighbors of 'C0025202' # Melanoma
neib = [
'C0025202' # Melanoma
#,'C0037286' # Skin Neoplasms
,'C0025201' # melanocyte
,'C1332443' # BRCA2 syndrome
,'C0598034' # BRCA2 gene
,'C0699791' # stomach carcinoma
,'C1275200' # Borderline malignant melanoma
,'C1366649' #AIM1 gene
,'C1537910' #MIRLET7A1 gene
,'C0086418' # Home sapiens
,'C2825744'# MIRLET7A1 wt Allele
,'C0684249' # Carcinoma of Lung
,'C1537910' # MIRLET7A1 gene
,'C1537912' # MIRLET7A3 gene
,'C0588009' # Malignant melanoma of skin of back
,'C2826556' #DCT wt Allele
,'C1302746'#Melanocytic neoplasm
]

labs = {
'C0025202' : 'Melanoma'
,'C0025201' : 'melanocyte'
,'C1332443' : 'BRCA2 syndrome'
,'C0598034' : 'BRCA2 gene'
,'C0699791' : 'stomach carcinoma'
,'C1275200' : 'Borderline malignant melanoma'
,'C1366649' : 'AIM1 gene'
,'C1537910' : 'MIRLET7A1 gene'
,'C0086418' : 'Home sapiens'
,'C2825744': 'MIRLET7A1 wt Allele'
,'C0684249' : 'Carcinoma of Lung'
,'C1537910' : 'MIRLET7A1 gene'
,'C1537912' : 'MIRLET7A3 gene'
,'C0588009' : 'Malignant melanoma of skin of back'
,'C2826556' : 'DCT wt Allele'
,'C1302746': 'Melanocytic neoplasm'
}

H = G.subgraph(neib)

pos = nx.spring_layout(H, iterations=100)
pos = nx.circular_layout(H)
poslabel = {k: [v[0]*1.1, v[1]*1.1] for k, v in pos.items()}
edge_labs = nx.get_edge_attributes(H, 'rel')
edge_labs2 = nx.get_edge_attributes(H, 'exclusivity') # can't really use these without separating out the edges or edges between labels

#combined_dict = {(k[0], k[1], k[2]): (edge_labs[k], round(float(edge_labs2[k]), 3)) for k in edge_labs.keys()}
combined_dict = {(k[0], k[1], k[2]): "%s(%s)" % (edge_labs[k], round(float(edge_labs2[k]), 3)) for k in edge_labs.keys()}

newdict = {(k[0], k[1]): set() for k in combined_dict.keys()}
[newdict[(k[0], k[1])].add(combined_dict[k]) for k in combined_dict.keys()]
edge_attr_labels = {(k[0], k[1]): " ".join(newdict[(k[0], k[1])]) for k in newdict.keys()}


plt.clf()
plt.axis(xmin=-1.5, xmax=1.5, ymin=-1.2, ymax=1.2)
plt.setp(axes, xticks=[], yticks=[])
#axes = plt.gca()
#axes.set_xlim([-1.3,1.3])

#nx.draw(H, pos, with_labels=True)

f = plt.figure(figsize=(100,100))

p1 = f.add_subplot(111, frameon=False, xlim=[-1.3,1.3], ylim=[-1.3,1.3])

nx.draw_networkx_nodes(H, pos, node_size=800, with_labels=False, node_color="blue")

p2 = f.add_subplot(111, frameon=False, sharex=p1, sharey=p1)
nx.draw_networkx_edges(H, pos, with_labels=True, width=5, edge_color="grey")

p3 = f.add_subplot(111, frameon=False, sharex=p1, sharey=p1)
nx.draw_networkx_edge_labels(H, pos, edge_labels=edge_attr_labels, font_size=36)

p4 = f.add_subplot(111, frameon=False, sharex=p1, sharey=p1) 
nx.draw_networkx_labels(H, poslabel, labels=labs, font_size=78)


nx.draw_circular(H, with_labels=False)
nx.draw_circular(H, with_labels=False)
nx.draw_networkx_nodes(H, pos, with_labels=False)
nx.draw_networkx_edges(H, pos, with_labels=False)

