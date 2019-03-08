# TREC_2018_UVA
UVA approach to TREC 2018 Precision Medicine Task


# Prerequisites

UMLS - local installation in SQL database - for relatedness calculations.

Apache cTAKES - for CUI-encoding the text.

Elasticsearch 6.x - for indexing and querying the text.


# Introduction

To use this setup we used a local installation of Apache cTAKES for natural language processing. This allows a user to parse and annotate the document abstract text with Concept Unique Identifiers that serve as an ontology-based embedding of the medical text. We used a standard installation of cTAKES with a local installation of UMLS in a SQL Server database. The YTEX extension was used to allow cTAKES to write CUIs to the database. The specific configuration files used to configure cTAKES as well as a powershell script used to configure and run the annotation pipeline are included in this repository. cTAKES and UMLS can be found at the links below and are not distributed in this repository.

Elasticsearch is necessary to index and query the data. The raw text and the encoded CUIs form the corpus for the Elasticsearch index.

The relatedness graph is created by using a SQL query to preprocess the data and then processed by a Python script using the NetworkX package as a graph. A separate Python script is used to send the queries to the Elasticsearch engine and write results to tsv format.

