# epss-db
Download all epss data, and import database. We can explore the data by SQL querys!

**NOW: THIS IS AN EXPERIMENTAL IMPLEMENTATION.**

- Sehll script verison.
- Work on Ubuntu 24.04LTS
- But, it's a common implementation, so it should work with a little adjustment.

# Wht's This?

EPSS is Exploit Prediction Scoreing Syste from FIRST ( https://www.first.org/epss/ ).

I want to analyze EPSS, but I don't need to use SIEM, so I wanted something that could be analyzed using SQL.
We thought it was important to first implement something simple and have it widely used.

therefore...
- write in Shell script(sh/bash)
- use common commands
  - sqlite3
  - sed
  - wget
  - gzip
  - gnuzip
  - grep
    - It is sufficient if $PATH is available.

# System configuration

## REQUIRE

- commands
  - sqlite3
  - sed
  - wget
  - gzip , gunzip
  - grep
  - (git ; to clone this repo.)
- Disk space
  - 

## File and Directory

- epss-init.sh
  - Download EPSS .gz data.
- epss-preprocessing.sh
  - Format the downloaded data so that it can be entered into the database.
- epss-import.sh
  -  Import the preprocessed data into SQLite3.
- epss-data
  - The contents differ depending on when the data was provided, so we save it separately in 1st/2nd/3rd directories.
- epss-db.sqlite3
  - EPSS database. We save "epss" table.

# How to use this.

1. Clone this project. (ex. `$git clone https://github.com/hogehuga/epss-db`)
2. Run "epss-init.sh" script. (ex. `$sh epss-init.sh`)
3. Run "epss-prerocessing.sh" script. (ex. `$sh epss-preprocessing.sh`)
4. Run "epss-import.sh" script. (ex. `$sh epss-import.sh`)
5. We'll investigate EPSS! (ex. `$sqlite3 epss-db.sqlite3`)

## CAUTION

- Be careful about disk usage fees.
  - `epss-init.sh` download 714M .csv.gz data.(at 2023-12-04)
  - `epss-preprocessing.sh` extract 8.0GB data.
  - `epss-import.sh` minimizes disk growth. The imported data will be deleted.
  - Overall, we use 
- Time
-   `epss-init.sh` need about 20min(Depends on transfer speed, FIRST's response).
-   `epss-preprocessing.sh` need about 30-40min

## How it works

- epss-init.sh
  - wget .csv.gz file to ./epss-data from FIRST.
  - ./epss-data/(1st|2nd|3rd)
    - 1st data have (cve,epss(score))
    - 2nd data have (cve,epss,percentile)
    - 3rd data have (cve,pess,percentile,model_version,score_date)
- epss-preprocessing.sh
  - Unzip and standardize each data.
    - unzip
    - sed to (cve, percentile, model_version, score_date)
    - save to ./epss-data/*.cve
    - gzip ./epss-data/*/.cve to .cve.gz(like a original)
- epss-import.sh
  - Store SQLite3 to data.
    - create database, table
      - epss-data.sqlite3
      - `create table epss(cve TEXT, epss REAL, percentile REAL, model_version TEXT, score_date TEXT)`
    - import data from .csv files


# UNIMPRLEMENTED

- Get the difference .cve.gz data (GET|IMPORT).
- Commands to simplify investigations.
  - ex. Display only the percentile of a specific CVE-ID. -> now, using sql `select score_date,cve,epss,percentile from epss where cve="CVE-YYYY-NNNN";`
 
# NOTE

THIS IS EXPERIMENTAL CODE.

WE NEED +*BETTER CODE!**

I want to like this
- `$ epss-db init` -> I would like this to be an option to the command rather than a separate script.
- `$ epss-db updatedata` -> After downloading the difference between the imported data and the current time, import it into the database.
- `$ epss-db -query-cve CVE-2024-0000 -query-week` -> get 1week data where CVE-2024-0000
