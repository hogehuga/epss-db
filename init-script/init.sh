#!/bin/sh
cd /opt/epss-db
mkdir epss-data
cd epss-data
BASEPATH=/opt/epss-db/epss-data

echo "[start] Get EPSS csv.gz data."
# data get

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
        echo "  wget data: $CURRENTDATE"
        wget -q https://epss.cyentia.com/epss_scores-$CURRENTDATE.csv.gz
        CURRENTDATE=$(date -I -d "$CURRENTDATE + 1 day")
done
cd ..


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
        echo "  wget data: $CURRENTDATE"
        wget -q https://epss.cyentia.com/epss_scores-$CURRENTDATE.csv.gz
        CURRENTDATE=$(date -I -d "$CURRENTDATE + 1 day")

done
cd ..


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
        echo "  wget data: $CURRENTDATE"
        wget -q https://epss.cyentia.com/epss_scores-$CURRENTDATE.csv.gz
        CURRENTDATE=$(date -I -d "$CURRENTDATE + 1 day")
done
cd $BASEPATH

echo "[end] Get EPSS csv.gz data."


# preprocess
echo "[start] PreProcessing EPSS data."

cd $BASEPATH

## 1st season
## [cve, epss]
if [ -d 1st ]; then
    cd $BASEPATH/1st

    for file in *.gz
    do
        FILEDATE=`echo $file | sed -e "s/epss_scores-\([0-9]*-[0-9]*-[0-9]*\)\.csv\.gz/\1/g"`
        OUTFILE=`echo $file|sed -e "s/\(^.*\)\.gz/\1/g"`
        echo "  processing file: $file"
        gunzip $file
        grep -v "cve.epss" $OUTFILE | sed -e "s/^\(.*\),\(.*\)$/\"\1\",\2,NULL,NULL,\"$FILEDATE\"/g" > ../$OUTFILE
        gzip $OUTFILE
    done
    cd ..
else
    echo "  ...1st directory is not exsist."
fi

## 2nd season
## [cve, epss, percentile]
if [ -d 2nd ]; then
    cd $BASEPATH/2nd
    for file in *.gz
    do
        FILEDATE=`echo $file | sed -e "s/epss_scores-\([0-9]*-[0-9]*-[0-9]*\)\.csv\.gz/\1/g"`
        OUTFILE=`echo $file|sed -e "s/\(^.*\)\.gz/\1/g"`
        echo "  processing file: $file"
        gunzip $file
        grep -v "cve.epss" $OUTFILE | sed -e "s/^\(.*\),\(.*,.*\)$/\"\1\",\2,NULL,\"$FILEDATE\"/g" > ../$OUTFILE
        gzip $OUTFILE
    done
    cd ..
else
    echo "  ...2nd directory is not exsist."
fi

# 3nd season
## [cve, epss, percentile, model_version]
if [ -d 2nd ]; then
    cd $BASEPATH/3rd
    for file in *.gz
    do
        FILEDATE=`echo $file | sed -e "s/epss_scores-\([0-9]*-[0-9]*-[0-9]*\)\.csv\.gz/\1/g"`
        OUTFILE=`echo $file|sed -e "s/\(^.*\)\.gz/\1/g"`
        gunzip $file
        MODEL=`head -n 1 $OUTFILE | grep "#model_version"| sed -e "s/#model_version:\(.*\),score.*/\1/g"`
        echo "  processing file: $file"
        grep -v "cve.epss" $OUTFILE | grep -v "#model_version" | sed -e "s/^\(.*\),\(.*,.*\)$/\"\1\",\2,\"$MODEL\",\"$FILEDATE\"/g" > ../$OUTFILE
        gzip $OUTFILE
    done
else
  echo "  ...3rd directory is not exsist."
fi

cd $BASEPATH
echo "[end] PreProcessing EPSS data."

# database init and data import
echo "[start] data import to mysql."

cd $BASEPATH

echo "  create db,table"
## table create
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root -e "create database epssdb;"
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root -e "set global local_infile = 1;"
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "create table epssdb( id int auto_increment, cve varchar(20), epss DOUBLE, percentile DOUBLE, model VARCHAR(20), date DATE, INDEX (id));"

## data import
for file in *.csv
do
        echo "  importing: $file"
        mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "load data infile '/opt/epss-db/epss-data/$file' into table epssdb fields terminated by ',' enclosed by '\"' (cve,epss,percentile,model,date);"
        rm $file
done

## suggest
echo "[end] data import to mysql."

# Create DB index
echo "[start] Create mysql index."

echo "  Create index for CVE-ID."
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "create index idx_cve on epssdb(cve);"
echo "  Create index for epss(score)."
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "create index idx_epss on epssdb(epss);"
echo "  Create index for percentile."
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "create index idx_percentile on epssdb(percentile);"
echo "  Create index for date."
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "create index idx_date on epssdb(date);"

echo "[end] Create mysql index."

echo "All initial script has completed."
echo "Have a fun!;  (^_^)/~  and ;-)"
