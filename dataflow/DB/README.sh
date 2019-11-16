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

# 4. WCSP -------------------------------------------------------------------

echo
echo "** 4. Loading WCSP **"

# need to 1) drop the duplicate names,
#         2) only load genera in canon list
#         3) load the additional genera where a synonym points outside
#            the canon list of genera
# previously used: gawk -f tpl2wcsp.awk
# Now done in WCSP/ and canon

gawk 'BEGIN{FS=OFS="|"}{print $1, $2, $3, $4, $5, $6, $7, $8}' \
     ../WCSP/wcsp_ak > names

# Check the uids in wcsp
gawk 'BEGIN{
        FS="|"
        while ((getline < "../canonical/canon") > 0) 
          name[gensub(/^trop/,"tro","G",$1)] = $2 $3 $4 $5 $6 $7
        while ((getline < "names") > 0) {
          if (name[$1] && (name[$1] != $2 $3 $4 $5 $6 $7))
            print $1, name$1, $2 $3 $4 $5 $6 $7
        }
      }'

# rel:

gawk 'BEGIN{FS=OFS="|"}{
        if ($9 == "Synonym")
          print $1, $10, "synonym", "WCSP"
        else
          print $1, $1, "accepted", "WCSP"
      }' ../WCSP/wcsp_ak > rel

gawk 'BEGIN{FS=OFS="|"}{
        if ($3 ~ /^(no_match|auto_irank|manual\?\?)$/)
          print $1, $1, "self"
        else print $1, $2, $3
      }' ../canonical/wcsp2canon_match > ortho

checklines rel names ortho
sqlnulls names
sqlnulls rel
sqlnulls ortho

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @in_src='WCSP'; source 2_load_other.sql;" akflora

rm -rf names rel ortho

# 5. ACCS -------------------------------------------------------------------

echo
echo "** 4. Loading ACCS **"

gawk 'BEGIN{FS=OFS="|"}{print $1, $2, $3, $4, $5, $6, $7, $8}' \
     ../ACCS/accs > names

cp ../ACCS/accs_rel rel

gawk 'BEGIN{FS=OFS="|"}{
        if ($3 ~ /^(no_match|auto_irank|manual\?\?)$/)
          print $1, $1, "self"
        else print $1, $2, $3
      }' ../canonical/accs2canon_match > ortho

checklines rel names ortho
sqlnulls names
sqlnulls rel
sqlnulls ortho

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @in_src='ACCS'; source 2_load_other.sql;" akflora

rm -rf names rel ortho

# 6. FNA ---------------------------------------------------------------

echo
echo "** 4. Loading FNA **"

gawk 'BEGIN{FS=OFS="|"}{print $1, $2, $3, $4, $5, $6, $7, $8}' \
     ../FNA/fna > names

gawk 'BEGIN{FS=OFS="|"}{
        if ($9 == "accepted")
          print $1, $1, "accepted", "FNA"
        else
          print $1, $9, "synonym", "FNA"
      }' ../FNA/fna > rel

gawk 'BEGIN{FS=OFS="|"}{
        if ($3 ~ /^(no_match|auto_irank|manual\?\?)$/)
          print $1, $1, "self"
        else print $1, $2, $3
      }' ../canonical/fna2canon_match > ortho

checklines rel names ortho
sqlnulls names
sqlnulls rel
sqlnulls ortho

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @in_src='FNA'; source 2_load_other.sql;" akflora

rm -rf names rel ortho






