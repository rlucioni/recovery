import json
import csv

def import_csv(metro_csv):
    # Parse out file name and truncate .csv extension
    dimension = metro_csv.split('/')[-1][:-4]

    with open(metro_csv, 'r') as f:
        headers, us_data = [], []
        for line in csv.reader(f):
            if line[0] == 'RegionName':
                headers = line
                continue
            elif line[0] == "United States":
                us_data = line
                continue
            else:
                break
    
    return dimension, [{"date": headers[i+1], "value": value} for i, value in enumerate(us_data[1:])]

def import_csvs(metro_csvs):
    data = {}
    for metro_csv in metro_csvs:
        key, value = import_csv(metro_csv)
        data[key] = value
    return data

metro_csvs = [
    "../data/zillow/metro/MedianPctOfPriceReduction.csv",
    "../data/zillow/metro/MedianListPricePerSqft.csv",
    "../data/zillow/metro/PctOfListingsWithPriceReductions.csv",
    "../data/zillow/metro/Turnover.csv",
    "../data/zillow/metro/ZriPerSqft.csv"
]

with open("../data/nationwide-data.json", 'wb') as f:
    json.dump(import_csvs(metro_csvs), f)
