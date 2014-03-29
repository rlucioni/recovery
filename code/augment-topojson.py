import json
import csv

# Map FIPS codes to states
FIPS = {
    2 : 'AK',  
    1 : 'AL',  
    5 : 'AR',  
    60: 'AS',  
    4 : 'AZ',  
    6 : 'CA',  
    8 : 'CO',  
    9 : 'CT',  
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

# Read county FIPS TSV file and return dictionary mapping FIPS codes to county names formatted as "County, State"
def read_tsv(county_fips):
    fips_to_county_name = {}
    with open(county_fips) as f:
        for line in csv.reader(f, dialect='excel-tab'):
            id_string = line[0]

            # Ignore header row
            if (id_string == 'id'):
                continue

            # Truncate last three digits to yield state FIPS code
            state_fips = int(id_string[:-3])

            if state_fips in FIPS.keys():
                county_name = "{}, {}".format(line[1], FIPS[state_fips])
            else:
                continue

            fips_to_county_name[int(id_string)] = county_name

    return fips_to_county_name

cutoff = 60

# Read Zillow CSV file and return dictionary mapping "County, State" to date-keyed data
def read_county_csv(county_csv):
    data = {}
    # Parse out file name and truncate .csv extension
    dimension = county_csv.split('/')[-1][:-4]
    data['dimension'] = dimension

    with open(county_csv, 'r') as f:
        headers = []
        for line in csv.reader(f):
            if line[0] == 'RegionName':
                headers = line
                # Possible compression option: store dates once in separate array for each dimension
                # if len(line) > cutoff:
                #     # Only select elements after cutoff index
                #     data['dates'] = line[-cutoff:]
                # else:
                #     # Ignore non-date headers
                #     data['dates'] = line[5:]
            else:
                # county_name = "{}, {}".format(line[0], FIPS[int(line[3])])
                county_name = "{}, {}".format(line[0], line[1])
                # Only consider elements after cutoff index
                if len(line) > cutoff:
                    data[county_name] = [{'date': headers[-cutoff:][i], 'value': value} for i, value in enumerate(line[-cutoff:])]
                else:
                    data[county_name] = [{'date': headers[5:][i], 'value': value} for i, value in enumerate(line[5:])]
    
    return data

# Perform read_county_csv on multiple files and return array of dictionaries
def read_county_csvs(county_csvs):
    all_data = []
    for county_csv in county_csvs:
        all_data.append(read_county_csv(county_csv))
    return all_data

# Open JSON file and add Zillow data to county properties
def augment_topojson(original_json, county_fips, county_csvs, augmented_json):
    # All counties, keyed by FIPS code
    fips_to_county_name = read_tsv(county_fips)

    data = json.load(open(original_json))
    counties = data['objects']['counties']['geometries']

    data_objects = read_county_csvs(county_csvs)

    for county in counties:
        fips = county["id"]
        county_name = ""
        if fips in fips_to_county_name.keys():
            county_name = fips_to_county_name[fips]
        
        county["properties"] = {"name": county_name}

        for data_object in data_objects:
            try: 
                county_data = data_object[county_name]
            # Assign counties missing from Zillow data an empty data array
            except KeyError:
                county_data = []

            county["properties"][data_object['dimension']] = county_data

    with open(augmented_json, 'wb') as f:
        json.dump(data, f)

county_fips = "../data/us-county-fips.tsv"

county_csvs = [
    "../data/zillow/county/MedianPctOfPriceReduction.csv",
    "../data/zillow/county/MedianListPricePerSqft.csv",
    "../data/zillow/county/PctOfListingsWithPriceReductions.csv",
    "../data/zillow/county/Turnover.csv",
    "../data/zillow/county/ZriPerSqft.csv"
]

augment_topojson("../data/us-states-and-counties.json", county_fips, county_csvs,"../data/augmented-us-states-and-counties.json")
