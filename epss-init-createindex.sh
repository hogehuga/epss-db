#!/bin/sh
BASEPATH=/opt/epss-db/epss-data
cd $BASEPATH

# index create
echo "Create index for CVE-ID."
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "create index idx_cve on epssdb(cve);"
echo "...Done"
echo "Create index for epss(score)."
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "create index idx_epss on epssdb(epss);"
echo "...Done"
echo "Create index for percentile."
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "create index idx_percentile on epssdb(percentile);"
echo "...Done"
echo "Create index for date."
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "create index idx_date on epssdb(date);"
echo "...Done"

echo "Index created."
