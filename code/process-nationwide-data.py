import json
import csv

cutoff = 40

dates = []
filled_dates = False
def import_csv(metro_csv):
    # Parse out file name and truncate .csv extension
    dimension = metro_csv.split('/')[-1][:-4]

    with open(metro_csv, 'r') as f:
        headers, us_data = [], []
        for line in csv.reader(f):
            if line[0] == 'RegionName':
                global filled_dates
                global dates
                if not filled_dates:
                    filled_dates = True
                    dates = line[-cutoff:]
                continue
            elif line[0] == "United States":
                us_data = line
                continue
            else:
                break

    processedData = []
    if len(us_data) > cutoff:
        processedData = [value for value in us_data[-cutoff:]]
    else:
        processedData = [value for value in us_data[1:]]
    
    return dimension, processedData

def import_csvs(metro_csvs):
    data = {}
    for metro_csv in metro_csvs:
        key, value = import_csv(metro_csv)
        data[key] = value
    data["dates"] = dates
    return data

metro_csvs = [
    "../data/zillow/metro/MedianListPrice.csv",
    "../data/zillow/metro/MedianListPricePerSqft.csv",
    "../data/zillow/metro/PctOfListingsWithPriceReductions.csv",
    "../data/zillow/metro/MedianPctOfPriceReduction.csv",
    "../data/zillow/metro/ZriPerSqft.csv"
]

with open("../data/compressed-nationwide-data.json", 'wb') as f:
    json.dump(import_csvs(metro_csvs), f)
