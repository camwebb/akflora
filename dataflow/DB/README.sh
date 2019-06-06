source ../ENV.sh

# 1. Read in canonical names

echo "1. Loading Canonical list"

cp ../canonical/canon .
sed -i -E -e 's/\|\|/|\\N|/g' -e 's/\|\|/|\\N|/g' -e 's/^\|/\\N|/g' -e 's/\|$/|\\N/g' canon

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD < 1_load_canon.sql

rm -rf canon

# 2. ALA

cp ../ALA/ala .
sed -i -E -e 's/\|\|/|\\N|/g' -e 's/\|\|/|\\N|/g' -e 's/^\|/\\N|/g' -e 's/\|$/|\\N/g' ala

cp -f ../ALA/ala_refs .
sed -i -E -e 's/\|\|/|\\N|/g' -e 's/\|\|/|\\N|/g' -e 's/^\|/\\N|/g' -e 's/\|$/|\\N/g' -e 's/\|AK\ taxon\ list$/|\\N/g' ala_refs

echo "2. Loading ALA"

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD akflora < 2_load_ala.sql

rm -rf ala ala_refs

# 3. PAF

cp ../PAF/paf .
sed -i -E -e 's/\|\|/|\\N|/g' -e 's/\|\|/|\\N|/g' -e 's/^\|/\\N|/g' -e 's/\|$/|\\N/g' paf

cp -f ../PAF/paf_refs .
sed -i -E -e 's/\|\|/|\\N|/g' -e 's/\|\|/|\\N|/g' -e 's/^\|/\\N|/g' -e 's/\|$/|\\N/g' paf_refs

echo "3. Loading PAF"

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD akflora < 3_load_paf.sql

rm -rf paf paf_refs




