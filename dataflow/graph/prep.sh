# script to massage all input sources into the correct format
# 2022-06-22

rm -rf infiles
mkdir infiles

# canonical names ---------------------------------------

echo "** 1. Loading Canonical list **"

cp ../canonical/canon infiles/canon_names
# cp ../G2F/g2f .

# fix!
sed -i 's/tro-50108303/trop-50108303/g' infiles/canon_names

# 2. ALA ----------------------------------------------------------------

echo "** 2. Loading ALA **"

gawk 'BEGIN{FS=OFS="|"} { print $1, $2, $3, $4, $5, $6, $7, $8 }' \
     ../ALA/ala > infiles/ala_names

gawk 'BEGIN{FS=OFS="|"} { if ($3 !~ /^(no_match|auto_irank|manual\?\?)$/) \
     {print $1, $2, $3} else {print $1, $1, "self"}}' \
     ../canonical/ala2canon_match > infiles/ala_ortho

cp -f ../ALA/ala_rel infiles/ala_rel
sed -i -E -e 's/\|AK\ taxon\ list$/|/g' infiles/ala_rel

cp ../ALA/ala_ak infiles/ala_ak

# 3. PAF -------------------------------------------------------------------

echo "** 3. Loading PAF **"

gawk 'BEGIN{FS=OFS="|"} { print $1, $2, $3, $4, $5, $6, $7, $8 }' \
     ../PAF/paf > infiles/paf_names

gawk 'BEGIN{FS=OFS="|"} { if ($3 !~ /^(no_match|auto_irank|manual\?\?)$/) \
     {print $1, $2, $3} else {print $1, $1, "self"}}' \
     ../canonical/paf2canon_match > infiles/paf_ortho

gawk 'BEGIN{FS=OFS="|"} {if ($2 == "accepted") print $1, $1, "accepted", $3; else print $1, $2, "synonym", $3;}' ../PAF/paf_refs > infiles/paf_rel

# All PAF accepted names pre-filtered for AK
gawk 'BEGIN{FS=OFS="|"}{if ($1 ~ /\-s[0-9]+$/) print $1, ""; else print $1,1}' \
     infiles/paf_names > infiles/paf_ak

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

fi

# 5. ACCS -------------------------------------------------------------------

echo "** 5. Loading ACCS **"

gawk 'BEGIN{FS=OFS="|"}{print "accs-" gensub(/×/,"x","G",$1), $2, $3, $4, $5, $6, $7, $8}' \
     ../ACCS/accs > infiles/accs_names

gawk 'BEGIN{FS=OFS="|"}{print "accs-" gensub(/×/,"x","G",$1), "accs-" gensub(/×/,"x","G",$2), $3, $4, $5, $6, $7, $8}' \
     ../ACCS/accs_rel > infiles/accs_rel

gawk 'BEGIN{FS=OFS="|"}{
        if ($3 ~ /^(no_match|auto_irank|manual\?\?)$/)
          print "accs-" gensub(/×/,"x","G",$1), "accs-" gensub(/×/,"x","G",$1), "self"
        else print "accs-" gensub(/×/,"x","G",$1), $2, $3
      }' ../canonical/accs2canon_match > infiles/accs_ortho

# All ACCS accepted names are in AK (?)
gawk 'BEGIN{FS=OFS="|"}{if ($3 == "accepted") print $1, 1; else print $1,""}' infiles/accs_rel > infiles/accs_ak

# 6. FNA ---------------------------------------------------------------

echo "** 6. Loading FNA **"

gawk 'BEGIN{FS=OFS="|"}{print $1, $2, $3, $4, $5, $6, $7, $8}' \
     ../FNA/fna > infiles/fna_names
# little fix needed Hordeum... "
sed -i 's/"//g' infiles/fna_names

gawk 'BEGIN{FS=OFS="|"}{
        if ($9 == "accepted")
          print $1, $1, "accepted", "FNA"
        else
          print $1, $9, "synonym", "FNA"
      }' ../FNA/fna > infiles/fna_rel

gawk 'BEGIN{FS=OFS="|"}{
        if ($3 ~ /^(no_match|auto_irank|manual\?\?)$/)
          print $1, $1, "self"
        else print $1, $2, $3
      }' ../canonical/fna2canon_match > infiles/fna_ortho

# In Alaska?  original list is filtered for accepted names in AK, no
# info available on the synonym status (in Alaska)?. So...:
gawk 'BEGIN{FS=OFS="|"}{if ($1 ~ /\-[sb][0-9]+$/) print $1, ""; else print $1,1}' infiles/fna_names > infiles/fna_ak

# 6. Hulten ---------------------------------------------------------------

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
      }' ../Hulten/hulten > infiles/hulten_names

gawk 'BEGIN{ FS=OFS="|" }{
        if (++i[$2 $3 $4 $5 $6 $7 $8] == 1) {
          if ($9 == "accepted")
            print "hulten-" $1, "hulten-" $1, "accepted", "Hulten"
          else
            print "hulten-" $1, "hulten-" $9, "synonym", "Hulten"
        }}' ../Hulten/hulten > infiles/hulten_rel

gawk 'BEGIN{FS=OFS="|"}{
        if ($3 ~ /^(no_match|auto_irank|manual\?\?)$/)
          print $1, $1, "self"
        else print $1, $2, $3
      }' ../canonical/hulten2canon_match > infiles/hulten_ortho

# In Alaska?

gawk 'BEGIN{
        FS=OFS="|"
        while((getline < "../Hulten/in_alaska/not_in_alaska")>0)
          notak[$1]=1
        while((getline < "infiles/hulten_names")>0) {
          if (notak[substr($1,8,5)])
            print $1, ""
          else
            print $1,1
        }}' > infiles/hulten_ak 
       
# ---------------------------------------------------------------

echo "** 8. Loading GBIF **"

cp ../GBIF/names.2 infiles/gbif_names
cp ../GBIF/rel infiles/gbif_rel
gawk 'BEGIN{FS=OFS="|"} { if ($3 !~ /^(no_match|auto_irank|manual\?\?)$/) \
     {print $1, $2, $3} else {print $1, $1, "self"}}' \
     ../GBIF/gbif2canon_match > infiles/gbif_ortho
gawk 'BEGIN{FS=OFS="|"}{print $1, ""}' ../GBIF/names.2 > infiles/gbif_ak
cp ../GBIF/occ infiles/gbif_occ

# ---------------------------------------------------------------

echo "** 8. Loading TCM **"

gawk 'BEGIN{FS=OFS="|"} NR > 1 {gsub(/NULL/,"",$0); print "tcm-n" $1, "", $4, "", $5, gensub(/ssp/,"subsp","G",$13), $7, $8}' \
     ../tcm/name > infiles/tcm_names

gawk 'BEGIN{FS=OFS="|"} NR > 1 { if ($3 !~ /^(no_match|auto_irank|manual\?\?)$/)      {print $1, $2, $3} else {print $1, $1, "self"}}' \
     ../tcm/tcm2canon_match | sed 's/tcm-/tcm-n/g' > infiles/tcm_ortho

gawk 'BEGIN{FS=OFS="|"} NR > 1 {
  gsub(/NULL/,"",$0)
  print "tcm-p" $1, $4 " (" $5 ") " $6 ". " (($7) ? ($7 ".") : "") (($8) ? (" Vol. " $8 ".") : "") (($9) ? (" Pp. " $9 ".") : "") (($10) ? (" Pub. " $10 ".") : "") (($12) ? (" DOI:" $12 ".") : "") (($13) ? (" URL: " $13 ".") : "")}' \
   ../tcm/pub > infiles/tcm_pub

gawk 'BEGIN{FS=OFS="|"} NR > 1 {gsub(/NULL/,"",$0); print "tcm-tc" $1, "tcm-n" $3, "tcm-p" $4}' \
     ../tcm/tc > infiles/tcm_tc

gawk 'BEGIN{FS=OFS="|"} NR > 1 {gsub(/NULL/,"",$0); print "tcm-tcm" $1, "tcm-tc" $2, $12, "tcm-tc" $6, "tcm-p" $7, $9}' \
     ../tcm/tcm > infiles/tcm_tcm


exit

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





