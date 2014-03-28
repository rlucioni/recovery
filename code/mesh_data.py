import json
import csv

id_county_dict = {}
# county_id_dict = {}

def read_TSV(file):
	with open(file) as tsv:
		for line in csv.reader(tsv, dialect="excel-tab"):
			if (line[0] == 'id'):
				continue
			idnum = int(line[0])
			county = line[1]
			id_county_dict[idnum] = county
			# county_id_dict[county] = idnum

def mesh_data(filename,output):
	json_data = open(filename)
	data = json.load(json_data)
	keys = data.keys()
	objects = data['objects']
	# states = objects['states']
	counties = objects['counties']['geometries']
	for county in counties:
		idnum = county["id"]
		if idnum in id_county_dict.keys():
			county["name"] = id_county_dict[idnum]
		else:
			county["name"] = "NONE"
		# print id_county_dict[county["id"]]

	with open(output,'wb') as fp:
		json.dump(data,fp)

read_TSV("../data/topojson/us-county-names.tsv")
mesh_data("../data/topojson/us-states-and-counties.json","../data/topojson/us-states-and-counties-data.json")
