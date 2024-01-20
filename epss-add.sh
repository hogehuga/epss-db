#!/bin/sh

BASEPATH=/opt/epss-db
# argument check
DATEFLAG=false
DATETARGET=""

echo "argument check..."
while getopts "d:" opt; do
  case $opt in
    d)
      DATEFLAG=true
      DATETARGET=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

if ! $DATEFLAG; then
    echo "NG: argument is not set."
    echo "  use -d YYYY-MM-DD arguments."
    echo "   ; Please specify 2022-02-04 or later."
    exit 1
fi

## date check
## if before 3rd pattern date, stoped.
DATECOMPARE="2022-02-04"
TARGETSECOUNDS=$(date -d "$DATETARGET" +%s)
COMPARESECOUNDS=$(date -d "$DATECOMPARE" +%s)

if [ $TARGETSECOUNDS -lt $COMPARESECONDS ]; then
echo "bad"
    echo "NG: Invalid date."
    echo "Please specify 2022-02-04 or later."
    return 1
fi

echo "... [ok] chk argument: $DATETARGET"

if [ ! -d 3rd ]; then
    mkdir $BASEPATH/epss-data/3rd
fi


# file check
echo "file exists check..."
GZFILE="$BASEPATH/epss-data/3rd/epss_scores-$DATETARGET.csv.gz"

if [ -e $GZFILE ]; then
        echo "NG: Target File is exists."
        echo "    Check $GZFILE and remove it."
        exit 1
else
        echo "... [ok] FILE is NOT EXISTS.($GZFILE)"
fi


# file download and argument date check.
echo "file doanload..."
cd $BASEPATH/epss-data/3rd
WGETURL="https://epss.cyentia.com/epss_scores-$DATETARGET.csv.gz"
wget -q $WGETURL
if [ $? -ne 0 ]; then
        echo "NG: Target data can not download."
        echo "    Check wget -q https://epss.cyentia.com/epss_scores-$DATETARGET.csv.gz command."
        exit 1
else
        echo "... [ok] DATA downloaded.($WGETURL)"
fi
cd ../../


# preProcessing
echo "preProcess..."
UNGZFILE="$BASEPATH/epss-data/3rd/epss_scores-$DATETARGET.csv"
OUTFILE="$BASEPATH/epss-data/epss_scores-$DATETARGET.csv"
gunzip $GZFILE
MODEL=`head -n 1 $UNGZFILE | grep "#model_version"| sed -e "s/#model_version:\(.*\),score.*/\1/g"`
grep -v "cve.epss" $UNGZFILE | grep -v "#model_version" | sed -e "s/^\(.*\),\(.*,.*\)$/\"\1\",\2,\"$MODEL\",\"$DATETARGET\"/g" > $OUTFILE
gzip $UNGZFILE
echo "... [ok] CSV file created.($OUTFILE); no checked."


# import data
echo "data import"
echo "    Please wait for data import about ..."
echo "        If the index is the default, it will be completed in about 10 minutes."
echo "OUTFILE=$OUTFILE"
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "load data infile '$OUTFILE' into table epssdb fields terminated by ',' enclosed by '\"' (cve,epss,percentile,model,date);"
rm $OUTFILE

echo "... [ok] IMPORT Database finished.; no checked."
echo "-------"
echo "FINISH ALL IMPORTS DATA."
echo "    - target date  : $DATETARGET"
echo "    - original file: $GZFILE"
echo "               url : $WGETURL"
echo "    - csv file     : $OUTFILE"
echo "FINISHED"
