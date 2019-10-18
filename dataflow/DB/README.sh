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

rm -rf ala ala_refs ala_ortho

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

exit
# 4. WCSP

# Fields: [1] ID,Major group,Family,Genus hybrid marker, Genus, [6] Species
#   hybrid marker, Species,Infraspecific rank,Infraspecific epithet,
#   [10] Authorship,Taxonomic status in TPL, Nomenclatural status from original
#   data source, Confidence level, [14] Source,Source id,IPNI
#   id,[17] Publication,Collation,Page,Date,Accepted ID


# gawk 'BEGIN{FS="|"}{g[$3]++}END{for (i in g) print i}' ../canonical/canon | sort > canon_gen

gunzip -k ../WCSP/tpl.3.gz 
mv ../WCSP/tpl.3 tpl

# add the changed genera in the syn list

# need to 1) drop the duplicate names, ii) only load genera in canon list,
#   and 3) load the gene
gawk -f tpl2wcsp.awk > wcsp

# Fixing a few extra bits:
sed -i 's/|+|/|×|/g' wcsp
sed -E -i -e 's/\|1970$/|kew-387742/g' wcsp
sed -E -i -e 's/\|1971$/|/g' wcsp
# (Missing from tpl:)
echo "tro-25560763||Bellardiochloa||violacea|var.|argaea|(Boiss. & Balansa) Chiov.|Unresolved|" >> wcsp
sqlnulls wcsp

gawk 'BEGIN{FS=OFS="|"} { if ($3 !~ /^(no_match|auto_irank|manual\?\?)$/) \
     {print $1, $2, $3} else {print $1, $1, $3}}' ../canonical/wcsp2canon_match > wcsp_ortho

sqlnulls wcsp_ortho 


mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD akflora \
      < 4_load_wcsp.sql







