#!/bin/sh
sqlite3 epss-db.sqlite3 "create table epss(cve TEXT, epss REAL, percentile REAL, model_version TEXT, score_date TEXT)"
cd epss-data

for file in *.csv
do
	echo "importing: $file"
	sqlite3 ../epss-db.sqlite3 ".mode csv" ".import $file epss"
	#rm $file
done
