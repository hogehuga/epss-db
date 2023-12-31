#!/bin/sh
cd /opt/epss-db
mkdir epss-data
cd epss-data
BASEPATH=/opt/epss-db/epss-data


# 1st season
## 1st season: from 2021-04-14 to 2021-08-31
## It contains "cve,epss" data only.
### from: wget https://epss.cyentia.com/epss_scores-2021-04-14.csv.gz
### to:   wget https://epss.cyentia.com/epss_scores-2021-08-31.csv.gz
cd $BASEPATH
mkdir 1st
cd 1st
STARTDATE='2021-04-14'
ENDDATE='2021-09-01'
CURRENTDATE="$STARTDATE"
while [ "$CURRENTDATE" != "$ENDDATE" ];
do
        echo "Target date: $CURRENTDATE"
        wget -q https://epss.cyentia.com/epss_scores-$CURRENTDATE.csv.gz
        echo "$CURRENTDATE"
        CURRENTDATE=$(date -I -d "$CURRENTDATE + 1 day")
done
cd ..


# 2nd season
## 2nd season: from 2021-09-01 to 2022-02-03
## It contains "cve,epss,percentile" data.
### from: wget https://epss.cyentia.com/epss_scores-2021-09-01.csv.gz
### to  : wget https://epss.cyentia.com/epss_scores-2022-02-03.csv.gz
cd $BASEPATH
mkdir 2nd
cd 2nd
STARTDATE='2021-09-01'
ENDDATE='2022-02-04'
CURRENTDATE="$STARTDATE"
while [ "$CURRENTDATE" != "$ENDDATE" ];
do
        echo "Target date: $CURRENTDATE"
        wget -q https://epss.cyentia.com/epss_scores-$CURRENTDATE.csv.gz
        echo "$CURRENTDATE"
        CURRENTDATE=$(date -I -d "$CURRENTDATE + 1 day")

done
cd ..


# 3rd season
## 3rd season: from 2022-02-04
## It contains "model_version, score_date" in 1st line, and "cve,epss,percentile" data.
### from: wget https://epss.cyentia.com/epss_scores-2022-02-04.csv.gz

cd $BASEPATH
mkdir 3rd
cd 3rd
STARTDATE='2022-02-04'
ENDDATE=$(date '+%Y-%m-%d')
CURRENTDATE="$STARTDATE"
while [ "$CURRENTDATE" != "$ENDDATE" ];
do
        echo "Target date: $CURRENTDATE"
        wget -q https://epss.cyentia.com/epss_scores-$CURRENTDATE.csv.gz
        echo "$CURRENTDATE"
        CURRENTDATE=$(date -I -d "$CURRENTDATE + 1 day")
done
cd $BASEPATH
