source ../ENV.sh

function sqlnulls() {
    sed -i -E -e 's/\|\|/|\\N|/g' \
        -e 's/\|\|/|\\N|/g' \
        -e 's/^\|/\\N|/g' \
        -e 's/\|$/|\\N/g' $1
}

function checklines() {
    WCn=`wc -l names | gawk '{printf "%d", $1}'`
    WCo=`wc -l ortho | gawk '{printf "%d", $1}'`
    WCr=`wc -l rel | gawk '{printf "%d", $1}'`
    WCa=`wc -l ak | gawk '{printf "%d", $1}'`
    if [ $WCn -ne $WCo -o $WCn -ne $WCa -o $WCn -ne $WCr ] 
    then
        echo "  input file line numbers not same"
        exit 1
    else
        echo "Input file line numbers of names ortho ak are same "\
             "($WCn lines)"
    fi
}

# function skip() {

# 1. Read in canonical names ---------------------------------------

echo "** 1. Loading Canonical list **"

cp ../canonical/canon .
cp ../G2F/g2f .
sqlnulls canon
sqlnulls g2f

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
      < 1_load_canon.sql

rm -rf canon g2f

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

cp ../ALA/ala_ak ak
sqlnulls ak

checklines
# test input files

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @in_src='A'; source 2_load_other.sql;" akflora

rm -rf names rel ortho ak

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

# All PAF accepted names pre-filtered for AK
gawk 'BEGIN{FS=OFS="|"}{if ($1 ~ /\-s[0-9]+$/) print $1, ""; else print $1,1}' names > ak
sqlnulls ak

checklines
# test input files

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @in_src='P'; source 2_load_other.sql;" akflora

rm -rf names rel ortho ak


# 4. WCSP -------------------------------------------------------------------

if [ 0 -eq 1 ]
then


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

# no info on presence in AK (other than filtering by canon list)
gawk 'BEGIN{FS=OFS="|"}{print $1, ""}' names > ak
sqlnulls ak

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

checklines
sqlnulls names
sqlnulls rel
sqlnulls ortho

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @in_src='K'; source 2_load_other.sql;" akflora

rm -rf names rel ortho ak

fi

# 5. ACCS -------------------------------------------------------------------

echo
echo "** 5. Loading ACCS **"

gawk 'BEGIN{FS=OFS="|"}{print $1, $2, $3, $4, $5, $6, $7, $8}' \
     ../ACCS/accs > names

cp ../ACCS/accs_rel rel

gawk 'BEGIN{FS=OFS="|"}{
        if ($3 ~ /^(no_match|auto_irank|manual\?\?)$/)
          print $1, $1, "self"
        else print $1, $2, $3
      }' ../canonical/accs2canon_match > ortho
# 2020-01-17: using accs2canon_match.new after working on ACCS and not
# redoing canon match

# All ACCS accepted names are in AK (?)
gawk 'BEGIN{FS=OFS="|"}{if ($3 = "accepted") print $1, 1; else print $1,""}' rel > ak
sqlnulls ak

checklines
sqlnulls names
sqlnulls rel
sqlnulls ortho

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @in_src='C'; source 2_load_other.sql;" akflora

rm -rf names rel ortho ak

# 6. FNA ---------------------------------------------------------------

echo
echo "** 6. Loading FNA **"

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

# In Alaska?  original list is filtered for accepted names in AK, no
# info available on the synonym status (in Alaska)?. So...:
gawk 'BEGIN{FS=OFS="|"}{if ($1 ~ /\-[sb][0-9]+$/) print $1, ""; else print $1,1}' names > ak
sqlnulls ak

checklines
sqlnulls names
sqlnulls rel
sqlnulls ortho

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @in_src='N'; source 2_load_other.sql;" akflora

rm -rf names rel ortho ak

# 6. Hulten ---------------------------------------------------------------

echo
echo "** 7. Loading Hulten **"

# There are several cases of pro parte synonyms

# 2022-05-13: don't have time to work this out. This script works, but
#  then the SQL fails....
# gawk 'BEGIN{ FS=OFS="|"
#         while ((getline < "../Hulten/hulten")>0) {
#           $1 = "hulten-" $1
#           if ($9 != "accepted")
#             $9 = "hulten-" $9
#           key = $2 "|" $3 "|" $4 "|" $5 "|" $6 "|" $7 "|" $8
#           name[$1] = key
#           # pick an (arbitrary) name code for each name string
#           id[key] = $1
#           # create a rel lookup
#           if ($9 == "accepted")
#             syn[$1] = $1
#           else
#             syn[$1] = $9
#         }
#         # output names
#         for (i in id)
#           print id[i], "hulten-" i > "names"
#         # translate rel
#         for (i in syn) {
#           fromname =  id[name[i]]
#           toname   =  id[name[syn[i]]]
#           if (fromname == toname)
#             print fromname, toname , "accepted" , "Hulten"> "rel"
#           else
#             print fromname, toname , "synonym" ,"Hulten" > "rel"
#         }}'

# 2022-05-13: so just use this one, omitting all but one of the
#  proparte synonyms
gawk 'BEGIN{ FS=OFS="|" }{
        if (++i[$2 $3 $4 $5 $6 $7 $8] == 1)
          print "hulten-" $1, $2, $3, $4, $5, $6, $7, $8
      }' ../Hulten/hulten > names

gawk 'BEGIN{ FS=OFS="|" }{
        if (++i[$2 $3 $4 $5 $6 $7 $8] == 1) {
          if ($9 == "accepted")
            print "hulten-" $1, "hulten-" $1, "accepted", "Hulten"
          else
            print "hulten-" $1, "hulten-" $9, "synonym", "Hulten"
        }}' ../Hulten/hulten > rel

gawk 'BEGIN{FS=OFS="|"}{
        if ($3 ~ /^(no_match|auto_irank|manual\?\?)$/)
          print $1, $1, "self"
        else print $1, $2, $3
      }' ../canonical/hulten2canon_match > ortho

# In Alaska?

gawk 'BEGIN{
        FS=OFS="|"
        while((getline < "../Hulten/in_alaska/not_in_alaska")>0)
          notak[$1]=1
        while((getline < "names")>0) {
          if (notak[substr($1,8,5)])
            print $1, ""
          else
            print $1,1
        }}' > ak 
       
sqlnulls ak
sqlnulls names
sqlnulls rel
sqlnulls ortho
checklines

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @in_src='H'; source 2_load_other.sql;" akflora

rm -rf names rel ortho ak

# ---------------------------------------------------------------

echo
echo "** 8. Loading GBIF **"

cp ../GBIF/yt_names names

# dummy file
gawk 'BEGIN{FS=OFS="|"}{print $1 , $1, "accepted", "GBIF" }' names > rel

gawk 'BEGIN{FS=OFS="|"}{
        if ($3 ~ /^(no_match|auto_irank|manual\?\?)$/)
          print $1, $1, "self"
        else print $1, $2, $3
      }' ../canonical/yt2canon_match > ortho

gawk 'BEGIN{FS=OFS="|"}{print $1 , 1}' names > ak

sqlnulls ak
sqlnulls names
sqlnulls rel
sqlnulls ortho
checklines

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @in_src='G'; source 2_load_other.sql;" akflora

# the rel was dummy, delete
mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
      -e "DELETE FROM rel WHERE source = 'GBIF';" akflora

rm -rf names rel ortho ak

# ---------------------------------------------------------------

echo "** 9. Loading Foak **"

gawk 'BEGIN{FS=OFS="|"}{if (++u[$2 $3 $4 $5 $6 $7 $8]==1) print $1, $2, $3, $4, $5, $6, $7, $8 }' ../taxon_review/accepted_2022-05-10 > names

gawk 'BEGIN{FS=OFS="|"}{if (++u[$2 $3 $4 $5 $6 $7 $8]==1) print $1, $1, "accepted" , "FoAK"}' ../taxon_review/accepted_2022-05-10 > rel

gawk 'BEGIN{FS=OFS="|"}{
        if ($3 ~ /^(no_match|auto_irank|manual\?\?)$/)
          print $1, $1, "self"
        else print $1, $2, $3
      }' ../canonical/foak2canon_match > ortho

gawk 'BEGIN{FS=OFS="|"}{print $1 , 1}' names > ak

sqlnulls ak
sqlnulls names
sqlnulls rel
sqlnulls ortho
checklines

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "set @in_src='R'; source 2_load_other.sql;" akflora

rm -rf names rel ortho ak

# Finally

mysql -Ns --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD -e "ALTER TABLE names ADD COLUMN name VARCHAR(200); UPDATE names SET name = CONCAT_WS(' ',genhyb,genus,sphyb,species,ssptype,ssp,author);" akflora





