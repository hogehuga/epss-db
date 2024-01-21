# epss-db
Download all epss data, and import database. We can explore the data by SQL querys!

**NOW: THIS IS AN EXPERIMENTAL IMPLEMENTATION.**

- Sehll script verison.
- Work on mysql docker image.

README.md was created using Google Translate.

# What's NEW!

- 2024-01-21 JST
  - epss-graph.sh is comming! Plot EPSS/Percentile graph by CVE-ID.
- 2024-01-20 JST
  - It has been redesigned to be simpler!
    - remove sqlite3 version, because toooooo slow(access single 40GB file)
    - I decided to use a Docker image
- 2023-12-10 JST
  - Added epss-add.sh to add data.
- 2023-12-04 JST
  - First release.

# Wht's This?

EPSS is Exploit Prediction Scoreing Syste from FIRST ( https://www.first.org/epss/ ).

I want to analyze EPSS, but I don't need to use SIEM, so I wanted something that could be analyzed using SQL.
We thought it was important to first implement something simple and have it widely used.

An environment where Docker can be executed is required.

# System configuration

## REQUIRE

- docker
- HOST disc space
  - EPSS .csv.gz file  : 1[GB]
  - EPSS mysql database: 40[GB]
- Ability to write SQL statements ...

## File and Directory

- docker/
  - epss-db Dockerfile
- init-script/
  - Script to run for the first time.
- epss-data/
  - The contents differ depending on when the data was provided, so we save it separately in 1st/2nd/3rd directories.
  - Download EPSS .gz data.
- skel/
  - skelton(template) file directory.
- epss-add.sh
  - This is a script that downloads data for a specific day and registers it in the database.
- epss-autoAdd.sh
  - This is a script that registers all data up to the previous day. I created this because it is a pain to run epss-add.sh for multiple days.
  - Normally, use this.
- epss-graph.sh
  - Once you pass your CVE-ID, a graph will show you your EPSS and percentile changes over the past 180 days.
- epssquery.sh
  - This is a script to easily open the mysql console.
- my.cnf
  - Settings for accessing the mysql console.

# How to use this.

## setup

Get Dockaer image

```
$ docker pull hogehuga/epss-db
```

Create docker volume
- mysql database data: `epssDB` volme
- epss .csv.gz file: `epssFile` volume

```
$ docker volume create epssDB
$ docker volume create epssFile
```

Run container
- If you want to share the "share" directory for sharing analysis results, please add `-v <yourShredDirctory>:/opt/epss-db/share`.
  - eg. container:/opt/epss-db/share , host sahred:/home/hogehuga/share. -> `-v /home/hogehuga/share:/opt/epss-db/share`
```
$ docker container run --name epssdb -v epssDB:/var/lib/mysql -v epssFile:/opt/epss-db/epss-data -e MYSQL_ROOT_PASSWORD=mysql -d hogehuga/epss-db
```

Prepare the data
```
$ docker exec -it epssdb /bin/bash
(work inside a container)
# cd /opt/epss-db/init-script
# ./init.sh
```

Once your data is ready, all you need to do is use it!

## Data analysis

Enter the container and use SQL commands to perform analysis.

```
$ docker exec -it epssdb /bin/bash
(work inside a container)
# cd /opt/epss-db
# ./epssquery.sh
mysql> select * from epssdb limit 1;
+----+---------------+---------+------------+-------+------------+
| id | cve           | epss    | percentile | model | date       |
+----+---------------+---------+------------+-------+------------+
|  1 | CVE-2020-5902 | 0.65117 |       NULL | NULL  | 2021-04-14 |
+----+---------------+---------+------------+-------+------------+
1 row in set (0.00 sec)

mysql>
```

## epss-graph.sh

Create EPSS and percentile charts and CSV data for the past 180 days.
- Using the `-a` option will create the graph using all the data present in the database.
- Data will be created under ./shera directory
  - <CVE-ID>.csv: CSV data
  - EPSS-<CVE-ID>.png: Graph
  - skel-<CVE-ID>.plt: gnuplot script. Template is `./skel/plot.plt`

If you want to change gnuplot options, edit the skel-<CVE-ID>.plt file.
- edit skel-<CVE-ID>.plt file
  - tile, tics, label, etc...
- Pass skel to gnuplot and draw the graph.
  - `# LANG=C.utf8 gnuplot skel-<CVE-ID>.plt`

```
# ./epss-graph.sh -cve "CVE-2022-27016"
; -> ./share/CVE-2022-27016.csv (from:180 days ago)
; -> ./share/EPSS-CVE-2022-27016.png

# ./epss-graph.sh -cve "CVE-2022-27016" -a
; -> Similar to above, but creates images for all registered periods

```
![period option true](./Documents/epss-graph.png)
![period option false](./Documents/epss-graph_-a.png)


## Update EPSS data

Automatically registers data from the last registered data to the latest data in the database.

```
# ./epss-autoAdd.sh
```

## Update epss-db

`git pull origin` or rebuild container.

```
# cd /opt/epss-db
# git pull origin
```

```
on HOST

$ docker stop epssdb
$ docker pull hogehuga/epss-db
$ docker container run --name epssdbNEWNAME -v epssDB:/var/lib/mysql -v epssFile:/opt/epss-db/epss-data -e MYSQL_ROOT_PASSWORD=mysql -d hogehuga/epss-db
  ; Please specify the same value as last time

NOTE:
- Databases(/var/lib/mysql as "epssDB" docker volume) and files(/opt/epss-db/epss-data as "epssFile" docker volume) will be inherited.
```
