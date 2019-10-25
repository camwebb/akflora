source ../ENV.sh

function sqlnulls() {
    sed -i -E -e 's/\|\|/|\\N|/g' \
        -e 's/\|\|/|\\N|/g' \
        -e 's/^\|/\\N|/g' \
        -e 's/\|$/|\\N/g' $1
}

function checklines() {
    WCn=`wc -l $1 | gawk '{printf "%d", $1}'`
    WCo=`wc -l $2 | gawk '{printf "%d", $1}'`
    WCr=`wc -l $3 | gawk '{printf "%d", $1}'`
    if [ $WCn -ne $WCo -o $WCn -ne $WCr -o $WCo -ne $WCr ]
    then
        echo "  input file line numbers not same"
        exit 1
    else
        echo "Input file line numbers of $1, $2, $3 are same ($WCn lines)"
        
    fi
}

# function skip() {

# 1. Read in canonical names ---------------------------------------

echo "** 1. Loading Canonical list **"

cp ../canonical/canon .
sqlnulls canon

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
      < 1_load_canon.sql

rm -rf canon

# 2. ALA ----------------------------------------------------------------

echo
echo "** 2. Loading ALA **"

gawk 'BEGIN{FS=OFS="|"} { print $1, $2, $3, $4, $5, $6, $7, $8 }' \
     ../ALA/ala > names
sqlnulls names

gawk 'BEGIN{FS=OFS="|"} { if ($3 !~ /^(no_match|auto_irank|manual\?\?)$/) \
     {print $1, $2, $3} else {print $1, $1, "self"}}' \
     ../canonical/ala2canon_match > ortho
sqlnulls ortho # should be redundant

cp -f ../ALA/ala_rel rel
sqlnulls rel
sed -i -E -e 's/\|AK\ taxon\ list$/|\\N/g' rel

checklines rel names ortho
# test input files

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @in_src='ALA'; source 2_load_other.sql;" akflora

rm -rf names rel ortho

# 3. PAF -------------------------------------------------------------------

echo
echo "** 3. Loading PAF **"

gawk 'BEGIN{FS=OFS="|"} { print $1, $2, $3, $4, $5, $6, $7, $8 }' \
     ../PAF/paf > names
sqlnulls names

gawk 'BEGIN{FS=OFS="|"} { if ($3 !~ /^(no_match|auto_irank|manual\?\?)$/) \
     {print $1, $2, $3} else {print $1, $1, "self"}}' \
     ../canonical/paf2canon_match > ortho
sqlnulls ortho # should be redundant

gawk 'BEGIN{FS=OFS="|"} {if ($2 == "accepted") print $1, $1, "accepted", $3; else print $1, $2, "synonym", $3;}' ../PAF/paf_refs > rel
sqlnulls rel

checklines rel names ortho
# test input files

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @in_src='PAF'; source 2_load_other.sql;" akflora

rm -rf names rel ortho


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

gawk -f tpl2wcsp.awk

# Fixing a few extra bits:
sed -i 's/|+|/|×|/g' names
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

# note, some of the names (genera) in this wcsp names list were not in
# the matched set. Need to fix that:
# gawk 'BEGIN{FS=OFS="|"; while ((getline < "ortho")>0) if (!$2) missing[$1]++; # while ((getline < "names") > 0) if (missing[$1]) print $0}' > Alist
# found that none are named. Editted tpl2wcsp.awk to reflect this.

sqlnulls ortho # should be redundant

# now, some of the names (genera) in this wcsp names list were not in
# the matched set. Need to fix that:

gawk 'BEGIN{FS=OFS="|"; while ((getline < "ortho")>0) if (!$2) missing[$1]++; while ((getline < "names") > 0) if (missing[$1]) print $0}' > Alist








