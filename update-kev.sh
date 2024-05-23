#!/bin/bash
# modified from init-script/kev-init.sh

# environment
json_url="https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json"

# create kev table

mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "drop table kevcatalog;"
mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "create table kevcatalog( id int auto_increment, cveID varchar(28), vendorProject text, product text, vulnerabilityName text, dateAdded DATE, shortDescription text, requiredAction text, dueDate DATE, knownRansomwareCampaignUse text, notes text, INDEX (id));"

escapeCmd() {
  sed -e "s/'/\\\'/g" | sed -e 's/"/\\\"/g'
}

# data insert
process_json() {
  data=$(curl -s "$json_url")
  if [ -z "$data" ]; then
    echo "Error: Unable to fetch data from $json_url"
    exit 1
  fi

  while IFS= read -r line; do
    date_added=$(echo "$line"  | jq -r '.dateAdded' | escapeCmd )
    cveID=$(echo "$line"  | jq -r '.cveID' | escapeCmd )
    vendorProject=$(echo "$line"  | jq -r '.vendorProject' | escapeCmd )
    product=$(echo "$line"  | jq -r '.product' | escapeCmd )
    vulnerabilityName=$(echo "$line"  | jq -r '.vulnerabilityName' | escapeCmd )
    dateAdded=$(echo "$line"  | jq -r '.dateAdded' | escapeCmd )
    shortDescription=$(echo "$line"  | jq -r '.shortDescription' | escapeCmd )
    requiredAction=$(echo "$line"  | jq -r '.requiredAction' | escapeCmd )
    dueDate=$(echo "$line"  | jq -r '.dueDate' | escapeCmd )
    knownRansomwareCampaignUse=$(echo "$line"  | jq -r '.knownRansomwareCampaignUse' | escapeCmd )
    notes=$(echo "$line"  | jq -r '.notes' | escapeCmd )

#    echo "--------------------------"
    echo "cveID: $cveID"
#    echo "vendorProject: $vendorProject"
#    echo "product: $product"
#    echo "vulnerabilityName: $vulnerabilityName"
#    echo "dateAdded: $dateAdded"
#    echo "shortDescription: $shortDescription"
#    echo "requiredAction: $requiredAction"
#    echo "dueDate: $dueDate"
#    echo "knownRansomwareCampaignUse: $knownRansomwareCampaignUse"
#    echo "notes: $notes"

    # insert to database:epss/kevcatalog
    mysql --defaults-extra-file=/opt/epss-db/my.cnf -u root epssdb -e "insert into kevcatalog (cveID, vendorProject, product, vulnerabilityName, dateAdded, shortDescription, requiredAction, dueDate, knownRansomwareCampaignUse, notes) values('$cveID', '$vendorProject', '$product', '$vulnerabilityName', '$dateAdded', '$shortDescription', '$requiredAction', '$dueDate', '$knownRansomwareCampaignUse', '$notes')"


  done <<< "$(echo "$data" | jq -c '.vulnerabilities[]')"

}

process_json
