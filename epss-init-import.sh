#!/bin/sh
BASEPATH=/opt/epss-db/epss-data
cd $BASEPATH

# table create
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root -e "create database epssdb;"
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root -e "set global local_infile = 1;"
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "create table epssdb( id int auto_increment, cve varchar(20), epss DOUBLE, percentile DOUBLE, model VARCHAR(20), date DATE, INDEX (id));"

# data import
for file in *.csv
do
        echo "importing: $file"
        mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "load data infile '/opt/epss-db/epss-data/$file' into table epssdb fields terminated by ',' enclosed by '\"' (cve,epss,percentile,model,date);"
        rm $file
done

# suggest
echo "Data import finished."
echo "We recommend creating an index like below,"
echo "  - create index idx_cve on epssdb(cve);"
echo "  - create index idx_epss on epssdb(epss);"
echo "  - create index idx_percentile on epssdb(percentile);"
echo "  - create index idx_date on epssdb(date);"
echo "or"
echo "  sh ./epss-init-index.sh"
echo "  (The above will be executed automatically, but it will take about 30 minutes.)" 
