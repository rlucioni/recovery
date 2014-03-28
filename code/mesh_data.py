import json
import csv

id_county_dict = {}
name_data_dict = {}

def read_TSV(file):
    with open(file) as tsv:
        for line in csv.reader(tsv, dialect="excel-tab"):
            if (line[0] == 'id'):
                continue

            idnum = int(line[0])
            county = line[1]
            id_county_dict[idnum] = county

def read_CSV(file):
    with open(file) as csvfile:
        for line in csv.reader(csvfile):
            name_data_dict[line[0]] = line[5:]


def mesh_data(filename,output):
    json_data = open(filename)
    data = json.load(json_data)
    counties = data['objects']['counties']['geometries']

    for county in counties:
        idnum = county["id"]
        if idnum in id_county_dict.keys():
            name = id_county_dict[idnum]
            try: 
                medianValueSqFt = name_data_dict[name]
            except KeyError:
                medianValueSqFt = []
            county["properties"] = {"name": name, "medianValueSqFt": medianValueSqFt}

        else:
            county["properties"] = {"name": "", "medianValueSqFt": []}

    with open(output,'wb') as fp:
        json.dump(data, fp)

read_TSV("../data/topojson/us-county-names.tsv")
read_CSV("../data/zillow/county/HomesSoldAsForeclosures-Ratio.csv")
mesh_data("../data/topojson/us-states-and-counties.json","../data/topojson/named-us-states-and-counties.json")

