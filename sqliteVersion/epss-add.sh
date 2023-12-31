#!/bin/sh

# argument check
DATEFLAG=false
DATETARGET=""

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
    exit 1
fi

echo "... [ok] chk argument: $DATETARGET"

# database check
echo "database record exists check..."
CHKDB=`sqlite3 epss-db.sqlite3 "select count(*) from epss where score_date=\"$DATETARGET\";"`
if [ $CHKDB -ne 0 ]; then
	echo "NG: Data EXISTS. DATA APPEND ABOTED. $CHKDB records exsist."
	echo "    Check -d Date argument or database;"
	echo '        argument is "$DATETARGET",'
	echo '        SQL like : select * from epss where score_date="$DATETARGET";'
	exit 1
else
	echo "... [ok] DB has $CHKDB recoeds."

fi

# file check
echo "file exists check..."
FILE="./epss-data/3rd/epss_scores-$DATETARGET.csv.gz"

if [ -e $FILE ]; then
	echo "NG: Target File is exists."
	echo "    Check $FILE and remove it."
	exit 1
else
	echo "... [ok] FILE is NOT EXISTS.($FILE)"
fi

# file download and argument date check.
echo "file doanload..."
cd epss-data/3rd
WGETFILE="https://epss.cyentia.com/epss_scores-$DATETARGET.csv.gz"
#wget -q https://epss.cyentia.com/epss_scores-$DATETARGET.csv.gz
wget -q $WGETFILE
if [ $? -ne 0 ]; then
       	echo "NG: Target data can not download."
	echo "    Check wget -q https://epss.cyentia.com/epss_scores-$DATETARGET.csv.gz command."
	exit 1
else
	echo "... [ok] DATA downloaded.($WGETFILE)"

fi
cd ../../

# preProcessing
echo "preProcess..."
CSVFILE="./epss-data/3rd/epss_scores-$DATETARGET.csv"
OUTFILE="./epss-data/epss_scores-$DATETARGET.csv"
gunzip $FILE
MODEL=`head -n 1 $CSVFILE | grep "#model_version"| sed -e "s/#model_version:\(.*\),score.*/\1/g"`
grep -v "cve.epss" $CSVFILE | grep -v "#model_version"| sed -e "s/^\(.*\)$/\1,$MODEL,$DATETARGET/g" > $OUTFILE
gzip $CSVFILE

echo "... [ok] CSV file created.($OUTFILE); no checked."

# import data
echo "data import"
echo "    Please wait for data import about ..."
echo "        If sqlite3 has many indexes, neeed to FEW HOURS."
echo "        Has no indexes, need to LESS THAN 30MINUTES"
sqlite3 ./epss-db.sqlite3 ".mode csv" ".import $OUTFILE epss"
echo "... [ok] IMPORT Database finished.; no checked."
echo "-------"
echo "FINISH ALL IMPORTS DATA."
echo "    - target date  : $DATETARGET"
echo "    - original file: $FILE"
echo "               url : $WGETFILE"
echo "    - csv file     : $OUTFILE"
echo "CHECK DATABASE as "
echo "    $ sqlite3 epss-database.sqlite3"
echo "    > select count(*) from epss where score_date=\"$DATETARGET\";"
