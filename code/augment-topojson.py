import json
import csv

def read_tsv(file):
    id_county_dict = {}
    with open(file) as tsv:
        for line in csv.reader(tsv, dialect="excel-tab"):
            if (line[0] == 'id'):
                continue
            id_string = line[0]
            id_num = int(id_string)
            if len(id_string) < 5:
                county = line[1] + "0" + line[0][:-3]
            else:
                county = line[1] + line[0][:-3]
            id_county_dict[id_num] = county
    return id_county_dict

def read_county_csv(f):
    new_dict = {}
    filename = f.split('/')[-1][:-4]
    with open(f) as csvfile:
        for line in csv.reader(csvfile):
            county_name = line[0] + line[3]
            if len(line) > 60:
                new_dict[county_name] = line[-60:]
            else:
                new_dict[county_name] = line[5:]
    new_dict["filename"] = filename
    return new_dict

def read_county_csv_multiple(files):
    all_data = []
    for f in files:
        all_data.append(read_county_csv(f))
    return all_data

def augment_topojson(filename, county_names, county_files, output):
    id_county_dict = read_tsv(county_names)

    json_data = open(filename)
    data = json.load(json_data)
    counties = data['objects']['counties']['geometries']

    county_data = read_county_csv_multiple(county_files)

    for county in counties:
        id_num = county["id"]
        name = ""
        if id_num in id_county_dict.keys():
            name = id_county_dict[id_num]
        
        county["properties"] = {"name": name}

        for dataset in county_data:
            try: 
                value = dataset[name]
            except KeyError:
                value = []

            county["properties"][dataset["filename"]] = value

    with open(output, 'wb') as fp:
        json.dump(data, fp)

county_names = "../data/us-county-names.tsv"

data_files = [
    "../data/zillow/county/MedianPctOfPriceReduction.csv",
    "../data/zillow/county/MedianListPricePerSqft.csv",
    "../data/zillow/county/PctOfListingsWithPriceReductions.csv",
    "../data/zillow/county/Turnover.csv",
    "../data/zillow/county/ZriPerSqft.csv"
]

augment_topojson("../data/us-states-and-counties.json", county_names, data_files,"../data/augmented-us-states-and-counties.json")
