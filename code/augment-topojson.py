import json
import csv

# Data for state fips codes
FIPS = {
    2: 'AK',  
    1: 'AL',  
    5: 'AR',  
    60: 'AS',  
    4: 'AZ',  
    6: 'CA',  
    8: 'CO',  
    9: 'CT',  
    11: 'DC',  
    10: 'DE',  
    12: 'FL',  
    13: 'GA',  
    66: 'GU',  
    15: 'HI',  
    19: 'IA',  
    16: 'ID',  
    17: 'IL',  
    18: 'IN',  
    20: 'KS',  
    21: 'KY',  
    22: 'LA',  
    25: 'MA',  
    24: 'MD',  
    23: 'ME',  
    26: 'MI',  
    27: 'MN',  
    29: 'MO',  
    28: 'MS',  
    30: 'MT',  
    37: 'NC',  
    38: 'ND',  
    31: 'NE',  
    33: 'NH',  
    34: 'NJ',  
    35: 'NM',  
    32: 'NV',  
    36: 'NY',  
    39: 'OH',  
    40: 'OK',  
    41: 'OR',  
    42: 'PA',  
    72: 'PR',  
    44: 'RI',  
    45: 'SC',  
    46: 'SD',  
    47: 'TN',  
    48: 'TX',  
    49: 'UT',  
    51: 'VA',  
    78: 'VI',  
    50: 'VT',  
    53: 'WA',  
    55: 'WI',  
    54: 'WV',  
    56: 'WY'
} 

# Reads the county tsv file and returns a dictionary that maps a county id to "county, state"
def read_tsv(file):
    id_county_dict = {}
    with open(file) as tsv:
        for line in csv.reader(tsv, dialect="excel-tab"):
            if (line[0] == 'id'):
                continue
            id_string = line[0]
            id_num = int(id_string)
            if int(id_string[:-3]) in FIPS.keys():
                county = line[1] + ", " + FIPS[int(id_string[:-3])]
            else:
                continue
            id_county_dict[id_num] = county
    return id_county_dict

# Reads the Zillow csv files and returns a dictionary that maps "county, state" to arrays of data
def read_county_csv(f):
    new_dict = {}
    filename = f.split('/')[-1][:-4]
    with open(f) as csvfile:
        for line in csv.reader(csvfile):
            if line[0] == "RegionName":
                county_name = "Dates"
            else:
                county_name = line[0] + ", " + FIPS[int(line[3])]
            if len(line) > 60:
                new_dict[county_name] = line[-60:]
            else:
                new_dict[county_name] = line[5:]
    new_dict["filename"] = filename
    return new_dict

# Performs read_county_csv on multiple files and returns an array of dictionaries
def read_county_csv_multiple(files):
    all_data = []
    for f in files:
        all_data.append(read_county_csv(f))
    return all_data

# Opens the GeoJSON file and adds zillow data to the counties as properties
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

# Read in county names
county_names = "../data/us-county-names.tsv"

# Define the data files we will be using
data_files = [
    "../data/zillow/county/MedianPctOfPriceReduction.csv",
    "../data/zillow/county/MedianListPricePerSqft.csv",
    "../data/zillow/county/PctOfListingsWithPriceReductions.csv",
    "../data/zillow/county/Turnover.csv",
    "../data/zillow/county/ZriPerSqft.csv"
]

# Add data to json
augment_topojson("../data/us-states-and-counties.json", county_names, data_files,"../data/augmented-us-states-and-counties.json")
