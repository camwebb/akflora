source ../ENV.sh

# 1. Read in canonical names

cp ../canonical/canon .
sed -i -E -e 's/\|\|/|\\N|/g' -e 's/\|\|/|\\N|/g' -e 's/^\|/\\N|/g' -e 's/\|$/|\\N/g' canon

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD < 1_load_canon.v3.sql
