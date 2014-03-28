import json
import csv

data_dicts = []

def read_TSV(file):
    id_county_dict = {}
    with open(file) as tsv:
        for line in csv.reader(tsv, dialect="excel-tab"):
            if (line[0] == 'id'):
                continue

            idnum = int(line[0])
            county = line[1]
            id_county_dict[idnum] = county
    return id_county_dict

def read_county_CSV(f):
    # for file in files:
    new_dict = {}
    filename = f.split('/')[-1][:-4]
    with open(f) as csvfile:
        for line in csv.reader(csvfile):
            new_dict[line[0]] = line[5:]
    # data_dicts.append(new_dict)
    new_dict["filename"] = filename
    return new_dict

def read_county_CSV_multiple(files):
    all_data = []
    for f in files:
        all_data.append(read_county_CSV(f))
    return all_data



def mesh_data(filename,countynames,countyfiles,output):
    id_county_dict = read_TSV(countynames)

    json_data = open(filename)
    data = json.load(json_data)
    counties = data['objects']['counties']['geometries']

    county_data = read_county_CSV_multiple(countyfiles)

    for county in counties:
        idnum = county["id"]
        name = ""
        if idnum in id_county_dict.keys():
            name = id_county_dict[idnum]
            county["properties"] = {"name": name}
        else:
            county["properties"] = {"name": ""}

        for dataset in county_data:
            try: 
                value = dataset[name]
            except KeyError:
                value = []
            county["properties"][dataset["filename"]] = value

    with open(output,'wb') as fp:
        json.dump(data, fp)

countynames = "../data/topojson/us-county-names.tsv"

datafiles = ["../data/zillow/county/MedianValuePerSqft.csv",
            "../data/zillow/county/MedianListPricePerSqft.csv",
            "../data/zillow/county/MedianSoldPricePerSqft.csv",
            "../data/zillow/county/PctOfHomesSellingForLoss.csv",
            "../data/zillow/county/HomesSoldAsForeclosures-Ratio.csv"]

mesh_data("../data/topojson/us-states-and-counties.json",countynames, datafiles,"../data/topojson/named-us-states-and-counties.json")

