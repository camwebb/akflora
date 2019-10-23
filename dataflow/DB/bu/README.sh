source ../ENV.sh

function sqlnulls() {
    sed -i -E -e 's/\|\|/|\\N|/g' \
        -e 's/\|\|/|\\N|/g' \
        -e 's/^\|/\\N|/g' \
        -e 's/\|$/|\\N/g' $1
}

# function skip() {

# 1. Read in canonical names ---------------------------------------

echo "** 1. Loading Canonical list **"

cp ../canonical/canon .
sqlnulls canon

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
      < 1_load_canon.sql

# rm -rf canon


# 2. ALA ----------------------------------------------------------------

echo "** 2. Loading ALA **"

cp ../ALA/ala .
sqlnulls ala

cp -f ../ALA/ala_refs .
sqlnulls ala_refs
sed -i -E -e 's/\|AK\ taxon\ list$/|\\N/g' ala_refs

gawk 'BEGIN{FS=OFS="|"} { if ($3 !~ /^(no_match|auto_irank|manual\?\?)$/) \
     {print $1, $2, $3} else {print $1, $1, $3}}' \
     ../canonical/ala2canon_match > ala_ortho
sqlnulls ala_ortho 

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD akflora \
      < 2_load_ala.sql

# rm -rf ala ala_refs ala_ortho

# 3. PAF -------------------------------------------------------------------

echo "3. Loading PAF"

cp ../PAF/paf .
sqlnulls paf

cp -f ../PAF/paf_refs .
sqlnulls paf_refs

gawk 'BEGIN{FS=OFS="|"} { if ($3 !~ /^(no_match|auto_irank|manual\?\?)$/) \
     {print $1, $2, $3} else {print $1, $1, $3}}' \
     ../canonical/paf2canon_match > paf_ortho
sqlnulls paf_ortho 

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD akflora \
      < 3_load_paf.sql

# rm -rf paf paf_refs

# } # skip()

exit

# 4. WCSP

gawk 'BEGIN{FS="|"}{g[$3]++}END{for (i in g) print i}' ../canonical/canon | \
    sort > canon_gen

gunzip -k ../WCSP/tpl.3.gz 
mv ../WCSP/tpl.3 tpl

# need to 1) drop the duplicate names,
#         2) only load genera in canon list
#         3) load the additional genera where a synonym points outside
#            the canon list of genera

gawk -f tpl2wcsp.awk > wcsp

# Fixing a few extra bits:
sed -i 's/|+|/|×|/g' wcsp
sed -E -i -e 's/\|1970$/|kew-387742/g' wcsp
sed -E -i -e 's/\|1971$/|/g' wcsp
# (Missing from tpl:)
echo "tro-25560763||Bellardiochloa||violacea|var.|argaea|\
(Boiss. & Balansa) Chiov.|Unresolved|" >> wcsp

# Check the uids in wcsp

if [ `gawk -f compare_wcsp_uids.awk | wc -c` -ne 0 ]
then
    echo "UIDS in canon not same as in wcsp"
    exit 1
fi

sqlnulls wcsp

gawk 'BEGIN{FS=OFS="|"} { if ($3 !~ /^(no_match|auto_irank|manual\?\?)$/) \
     {print $1, $2, $3} else {print $1, $1, $3}}' \
     ../canonical/wcsp2canon_match > wcsp_ortho

sqlnulls wcsp_ortho 

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD akflora \
      < 4_load_wcsp.sql







