import json
import csv

id_county_dict = {}

def read_TSV(file):
    with open(file) as tsv:
        for line in csv.reader(tsv, dialect="excel-tab"):
            if (line[0] == 'id'):
                continue

            idnum = int(line[0])
            county = line[1]
            id_county_dict[idnum] = county

def mesh_data(filename,output):
    json_data = open(filename)
    data = json.load(json_data)
    counties = data['objects']['counties']['geometries']

    for county in counties:
        idnum = county["id"]
        if idnum in id_county_dict.keys():
            county["properties"] = {"name": id_county_dict[idnum]}
        else:
            county["properties"] = {"name": "NONE"}

    with open(output,'wb') as fp:
        json.dump(data, fp)

read_TSV("../data/topojson/us-county-names.tsv")
mesh_data("../data/topojson/us-states-and-counties.json","../data/topojson/named-us-states-and-counties.json")
