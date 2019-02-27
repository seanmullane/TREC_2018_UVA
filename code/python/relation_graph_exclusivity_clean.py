# -*- coding: utf-8 -*-
"""
Created on Tue Jul 31 17:38:55 2018

@author: Sean Mullane/spm9r
"""

import networkx as nx
import pandas as pd

# Read in updated concept relationship data including exclusivity
dfRel = pd.read_csv("C:/Users/spm9r/eclipse-workspace-spm9r/TREC2018/data/exclusivity_graph_data.csv", names=['CUI1','CUI2','rela','exclusivity'])

# Create subset graph
edge_list = []
for index, row in dfRelSub2.iterrows():
    tup = (row['CUI1'], row['CUI2'], {'rel': row['rela'], 'exclusivity': row['exclusivity']})
    edge_list.append(tup)
G.add_edges_from(edge_list)
G.number_of_nodes()


###FIX this may have a subtle bug where paths is returned empty sometimes, maybe when there is only a small nummber of connections?
### test case for bug: CUI C2317560
# I think maybe it doesn't return anything if there is a cycle? Expected behavior: In this case it should still return a partial path up to the point where there would be a cycle.
def findPathsWithRel(G, selfnode, u, uRelType, uExcl, n):
    '''
    This enumerates all non-cyclic paths in graph G from CUI node u up to 
    length n. This has a bug that includes an extra element at the end of each 
    path tuple that is removed in the wrapper method as a workaround.
    '''    
    if uRelType is None:
        uRelType = 'root'
    if uExcl is None:
        uExcl = 0
    if n==0:
        return [[(selfnode, uRelType, u, uExcl)]]
    paths = []
    for edge in G.edges(u, data = True): # edge is a tuple of (node u, node <other>, dict{'rel': '<reltype>'})
        neighbor = edge[1]
        relType = edge[2]['rel']
        exclusivity = edge[2]['exclusivity']
        for path in findPathsWithRel(G, u, neighbor, relType, exclusivity, n-1):
            if (((u) not in [x[2] for x in path]) and (neighbor != u)): # prevent cycles
                paths.append([(u, relType, neighbor, exclusivity)]+path)
            else:
                # need to return something to start climbing back up the recursion tree
                return [[(selfnode, uRelType, u, uExcl)]] 
    return paths

###FIX add code to calculate weight of each path from exclusivity
def findPathsWithRel_wrapper(G, u, n):
    '''
    This wrapper is a workaround to handle a bug in the included method. Better
    than reasoning about recursion, amirite?
    '''
    paths = findPathsWithRel(G, u, u, None, None, n)
    paths = [x[:-1] for x in paths]
    return paths

	
###FIX need to create an algorithm to loop through the list of path tuples
# and for each distinct node in the paths, return a list of reduced-length paths
# directly between the original node and the new node.


def getDistinctCUIs(L):
    '''
    L is a list of tuples of CUIs & relationships
    '''
    cuis = set()
    for path in L:
        for tup in path:
            cuis.add(tup[2]) # should be 2nd CUI in tuple
    return (cuis)


def getPathsAB(L, A, B):
    '''
    returns subset of L that are all paths directly from CUI A to CUI B in pathlist L
    '''
    paths = set()
    for path in L: # path is a tuple of tuples(paths)
        newpath = []
        start = False
        end = False
        for leg in path: # leg is a tuple of relations
            if (leg[0] == A): # leg[0] should be first CUI in tuple
                start = True
            if (leg[2] == B): # leg[2] should be first CUI in tuple
                # last leg of the path subset we want, so set end flag
                end = True
            if (start):
                newpath.append(leg)
            if (end):
                newpath = tuple(newpath)
                paths.add(newpath)
                break
    return paths


'''
Given two CUIs, A and B, this function calculates the relatedness value
between A and B.
'''
def calculateRelatednessAB(L, A, B, alpha = 0.5):
    # create list of all paths from A to B, which is a subset of L
    paths = getPathsAB(L, A, B)
    len_list = []
    weight_list = []

    # iterate through paths and calculate weights and decay factor of each path
    for path in paths:
        wInv = 0
        for leg in path:
            e = leg[3] # leg[3] should be exclusivity value of relation
            wInv += 1/float(e)
        w = 1/wInv # this is weight of path
        len_list.append(len(path))
        weight_list.append(w)

    # calculate relatedness measure
    return sum([(alpha ** length) * weight for length,weight in zip(len_list, weight_list)])


def calculateRelatednessFromA(G, A, n, alpha = 0.5):
    '''
    This enumerates all non-cyclic paths in graph G from CUI A up to length n, 
    then for each other distinct CUI cui in the paths it finds all distinct 
    direct paths from A to cui. Then it calculates the weight of each direct 
    path using exclusivity values and path lengths. Finally it calculates the 
    exclusivity-based relatedness of A with each relevant CUI cui and returns 
    them as a list of tuples.
    '''
    # Get all non-cyclic paths from A to any other CUI up to length n
    allpaths = findPathsWithRel_wrapper(G, A, n)
    
    CUIset = getDistinctCUIs(allpaths)
    
    relList = []
    for cui in CUIset:
        relList.append((cui, calculateRelatednessAB(allpaths, A, cui, alpha)))
    return relList

def getTopRelatedCuis(G, A, n, nCUI, alpha = 0.5):
    '''
    This returns a list of the top nCUI CUIs, ordered by relatedness to A.
    '''
    CUIlist = calculateRelatednessFromA(G, A, n, alpha)

    CUIlist.sort(key = lambda tup: tup[1]) # sort in order of relatedness
    
    return CUIlist[::-1][0:nCUI] # descending order
    


'''
Read in patient topics and do topic expansions
'''    
import xml.etree.ElementTree as ET
    
tree = ET.parse("C:/Users/spm9r/eclipse-workspace-spm9r/TREC2018/data/topics2018.xml")
root = tree.getroot()
print(root[0][0].text)

# Print bare-ish text for run through cTAKES
for elem in root:
    print(" ")
    print(elem.attrib['number'])
    print(" ")
    for subelem in elem:
        print(subelem.text)

# Read in the cTAKES/manually annotated topics

with open("C:/Users/spm9r/eclipse-workspace-spm9r/TREC2018/data/cui-encoded-topics.txt") as f:
    topicdoc = f.readlines()


# Parse text file into json file ###FIX still need to handle negations
    
import re

topiclist = []
for line in topicdoc:
    if (re.match('TOPICID \d+', line)):
        tdict = {}
        gCUI = ""
        tdict['id'] = re.match('TOPICID (\d+)', line).group(1)
        wherewe = 'diagnosis'
    elif (re.match('SENTENCE:\s+(.+)? [-]{6} (C\d+)', line)):
        tdict['diagnosis_TEXT'] = re.match('SENTENCE:\s+(.+)? [-]{6} (C\d+)', line).group(1).strip()
        tdict['diagnosis_CUI_EXACT'] = re.match('SENTENCE:\s+(.+)? [-]{6} (C\d+)', line).group(2).strip()
        wherewe = 'gene'
    elif (wherewe == 'gene'):
        tdict['gene_TEXT'] = re.match('SENTENCE:\s+(.+)', line).group(1).strip()
        wherewe = 'geneCUI'
    elif (wherewe == 'geneCUI'):
        if (re.match('\s+(C\d{7})', line)):
            gCUI = gCUI + re.match('\s+(C\d{7})', line).group(1) + " "
        if (re.match('SENTENCE:', line)):
            tdict['gene_CUI_EXACT'] = gCUI.strip()
            tdict['demographics_TEXT'] = re.match('SENTENCE:\s+?(.+)', line).group(1).strip()
            wherewe = 'demoCUI'
            #print(wherewe)
    elif (wherewe == 'demoCUI'):
        if(re.match('\s+(C\d{7})', line)):
            #print(wherewe)
            tdict['demo_CUI_EXACT'] = re.match('\s+(C\d{7})', line).group(1).strip()
            topiclist.append(tdict)

# Run query expansions on CUI fields using relatedness measure to find most-related concepts
            
for tdict in topiclist:
    print(tdict['id'])
    tdict['diagnosis_CUI_EXP'] = " ".join([tup[0] for tup in getTopRelatedCuis(G, tdict['diagnosis_CUI_EXACT'], 3, 10, alpha = 0.5) if tup[1] >= 0.1])
    #print(tdict['diagnosisCUIexp'])
    geneCUIlist = []
    for cui in tdict['gene_CUI_EXACT'].strip().split(" "):
        geneCUIlist.append(" ".join([tup[0] for tup in getTopRelatedCuis(G, cui, 3, 10, alpha = 0.5) if tup[1] >= 0.1]))
    tdict['gene_CUI_EXP'] = " ".join(geneCUIlist)
    #print(tdict['gene_CUI_EXP'])

# Write to file in json format

import json
jsob_exp = json.dumps(topiclist, indent=4, sort_keys=True)

with open("C:/Users/spm9r/eclipse-workspace-spm9r/TREC2018/data/cui-encoded-topics-expanded.json", "w") as text_file:
    print(jsob_exp, file=text_file)





