"""
Created on __date__

@author: vb8n
"""
import json
import requests
from elasticsearch import Elasticsearch
import csv
from argparse import ArgumentParser


parser = ArgumentParser()
parser.add_argument("-i", dest="filenum",
                    help="number for dict key for file names")

args = parser.parse_args()

runname = "NEW{0}".format(args.filenum)

# Fill template from dict
def fillTemplate(template, topicdict):
    filledquery = template
    for key in topicdict.keys():
        if (key != "id"):
            #print(key)
            #print(topicdict[key])
            filledquery = filledquery.replace(key, topicdict[key])
    return filledquery

# dict of json files containing query definition templates
# key = run name, value = filename
files = {
'NEW0': 'must_diseasegene_should_extracuis',
'NEW1': 'new_basic_noCUIs',
'NEW2': 'new_basic_exactCUIs',
'NEW3': 'new_basic_extCUIs',
'NEW4': 'new_must_exactCUIs_expCUIs_extCUIs',
'NEW5': 'new_must_exactCUIs_expCUIs_extCUIs_boost',
'NEW6': 'new_should_exactCUIs_expCUIs_extCUIs',
'NEW7': 'new_should_exactCUIs_expCUIs_extCUIs_boost',
'NEW8': 'new_noText_exactCUIs_expCUIs_extCUIs',
'NEW9': 'new_noText_noExtText_exactCUIs_expCUIs_extCUIs',
'NEW10': 'new_must_exactCUIs_expCUIs_boost'
}

queryfile = files[runname]
print("Executing run {0} using queryfile {1}".format(runname, queryfile))

# Read in json template        
with open("E:/elasticsearch/trec_query/input/{0}.json".format(queryfile)) as f:
    q = f.read()
d = json.loads(q)
#print(d)

# Read in json expanded topic file

with open("E:/elasticsearch/trec_query/input/cui-encoded-topics-expanded.json") as f:
    t = f.read()
topiclist = json.loads(t)

res = requests.get('http://localhost:9200')
# print(res.content)

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

# Create dict of queries to be run in elasticsearch
querydict = {}
for tdict in topiclist:
    querydict[int(tdict['id'])] = fillTemplate(q, tdict).replace("\t","").replace("\n", "")

reslist = []
for topic in querydict.keys():

    # run one query
    query = "{\"size\" : 1000, \"timeout\" : \"1000ms\", \"query\": %s }" % querydict[topic]
    print(query)

    results = es.search(index='trec-abstracts', body=query)
    #print(results)

    for i, result in enumerate(results['hits']['hits']):
        reslist.append((topic, 'Q0', result['_id'], i+1, result['_score'], runname))


outp = "E:/elasticsearch/trec_query/output/%s.tsv" % runname
with open(outp,'w', newline='') as out:
    csv_out=csv.writer(out, delimiter='\t')
#    csv_out.writerow(['TOPIC_NO', 'Q0', 'ID', 'RANK', 'SCORE', 'RUN_NAME'])
    for row in reslist:
        print(row)
        csv_out.writerow(row)

querylist = json.dumps([querydict[x] for x in querydict.keys()], indent=4, sort_keys=True)

with open("E:/elasticsearch/trec_query/output/%s_%s.txt" % (runname, "querylist"), "w") as text_file:
    print(querydict, file=text_file)


