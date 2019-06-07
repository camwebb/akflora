source ../ENV.sh

function sqlnulls() {
    sed -i -E -e 's/\|\|/|\\N|/g' \
        -e 's/\|\|/|\\N|/g' \
        -e 's/^\|/\\N|/g' \
        -e 's/\|$/|\\N/g' $1
}

# 1. Read in canonical names

echo "1. Loading Canonical list"

cp ../canonical/canon .
sqlnulls canon

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
      < 1_load_canon.sql

rm -rf canon

# 2. ALA

cp ../ALA/ala .
sqlnulls ala

cp -f ../ALA/ala_refs .
sqlnulls ala_refs
sed -i -E -e 's/\|AK\ taxon\ list$/|\\N/g' ala_refs

gawk 'BEGIN{FS=OFS="|"} { if ($3 !~ /^(no_match|auto_irank|manual\?\?)$/) {print $1, $2, $3} else {print $1, $1, $3}}' \
     ../canonical/ala2canon_match > ala_ortho
sqlnulls ala_ortho 

echo "2. Loading ALA"

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD akflora \
      < 2_load_ala.sql

rm -rf ala ala_refs


# 3. PAF

cp ../PAF/paf .
sqlnulls paf

cp -f ../PAF/paf_refs .
sqlnulls paf_refs

#gawk 'BEGIN{FS=OFS="|"} $3 !~ /^(no_match|exact|auto_irank|manual\?\?)$/ \
#      {print $1, $2, $3}' ../canonical/paf2canon_match > paf_ortho
gawk 'BEGIN{FS=OFS="|"} { if ($3 !~ /^(no_match|auto_irank|manual\?\?)$/) \
     {print $1, $2, $3} else {print $1, $1, $3}}' ../canonical/paf2canon_match > paf_ortho
sqlnulls paf_ortho 

echo "3. Loading PAF"

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD akflora \
      < 3_load_paf.sql

rm -rf paf paf_refs






