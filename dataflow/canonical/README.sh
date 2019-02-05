# Assembling a canonical names list for Alaska

# This list should be _wider_ than just the plants in AK, just the
# accepted, just the correct variants. I.e., make a list that should
# have all the available names in it, or as many as can be picked up
# in canonical form. Sources IPNI > Trop > WCSP (FNA does not have
# GUIDs yet, plus the author citations are not abbreviated, so harder
# to reconcile).


#    GNA for IPNI and Tropicos, adding _all_ fuzzy matched names.
# 4. Matchnames to PL accept all autofuzzy.  Give canonical status as
# they are added to master list

# 1. Assemble rough lists: ACCS + ALA + PAF + FNA (should add Hulten at some point)

# 1a. ACCS
echo "select concat('accs-', adjudicatedID) as guid, \
  concat_ws(' ', nameAdjudicated, authAdjudicated) as name \
  from speciesAdjudicated where nameAdjudicated REGEXP '[^\ ]+\ [^\ ]+';" \
    | mysql -N -u cam -pPASSWORD alaskaFlora | tr "\t" "|" > accs
# peel off the attached hybrid marks  
sed -i -E 's/×([A-Za-z])/x \1/g' accs
# tidy up (GNR chokes on ×)
sed -i -e 's/ ssp. / subsp. /g' -e 's/| */|/g' -e 's/ *$//g' \
    -e 's/  */ /g' -e 's/×/x/g' accs

# 1b. ALA
gawk 'BEGIN{FS="|"}{print $1 "|" $2, $3, $4, $5, $6, $7, $8}' \
     ../ALA_checklist/ala-names > ala
sed -i -e 's/\\N//g' -e 's/| */|/g' -e 's/ *$//g' -e 's/  */ /g' \
    -e 's/×/x/g' ala

# 1c. PAF
gawk 'BEGIN{FS="|"}{print $1 "|" $2, $3, $4, $5, $6, $7, $8}' \
     ../PAF/paf-names > paf
sed -i -e 's/\\N//g' -e 's/| */|/g' -e 's/ *$//g' -e 's/  */ /g' \
    -e 's/×/x/g' paf

# 1d. FNA
gawk 'BEGIN{FS="|"}{print $1 "|" $2, $3, $4, $5, $6, $7, $8}' \
     ../FNA/fna_alaska > fna
sed -i -e 's/\\N//g' -e 's/| */|/g' -e 's/ *$//g' -e 's/  */ /g' \
    -e 's/×/x/g' fna

# remove duplicates
cat accs ala paf fna | gawk 'BEGIN{FS="|"; PROCINFO["sorted_in"] \
   = "@ind_str_asc"}{n[$2]=$1}END{for (i in n) print n[i] "|" i}' > all_rough

# split into batches of 1,000 for GNR
gawk 'BEGIN{FS="|"}{print $1 "|" $2 > "names4gnr-"  int(++i/995)+1 }' all_rough

# 2. Run through GNR
rm -f gnr.out
for infile in names4gnr*
do
     echo "Running GNA on " $infile
     gawk -v INFILE=$infile -f lib/gnr.awk >> gnr.out
done

rm -f names4gnr-*

# parse

grep "ipni-" gnr.out | gawk -i "taxon-tools.awk" 'BEGIN{FS=OFS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} {code[$4] = $3} END{for (i in code) {p = parse_taxon_name(i, 1); if (p) print code[i], p}}' > ipni_base

# ../../bin/sqlnulls ipni_base

grep "trop-" gnr.out | gawk -i "taxon-tools.awk" 'BEGIN{FS=OFS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} {code[$4] = $3} END{for (i in code) {p = parse_taxon_name(i, 1); if (p) print code[i], p}}' > trop_base

# ../../bin/sqlnulls trop_base

# Some errors but these are errors in GNR records
# ** Fail: 'Hordeum x caespitosum 8999+' does not match:
#          Hordeum x caespitosum 8999+  <- parsed
# ** Fail: 'Botrychium virginianum var. ? simplex A. Gray' does not match:
#          Botrychium virginianum var. ? simplex A. Gray  <- parsed
# ** Fail: 'Sphagnum riparium var. > *fallax Sanio' does not match:
#          Sphagnum riparium var. > *fallax Sanio  <- parsed

exit

# 3. WCSP from the Plant List

gawk 'BEGIN{OFS="|";FPAT = "([^,]*)|(\"[^\"]+\")"}{for(i=1;i<=NF;i++) if(substr($i,1,1)=="\"") $i=substr($i,2,length($i)-2); print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21}' ~/public_html/MaTCH/recipes/theplantlist/data/all.csv > tpl.csv

# # fix a few - some records had """ which did not parse, found via:
# gawk 'BEGIN{FS="|"}{x[$14]++}END{for(i in x) print i, x[i]}' tpl.csv 
# gawk 'BEGIN{FS="|"}$14 == "Unresolved" {print $0}'
# gawk 'BEGIN{FS="|"}$14 == "" {print $1}' tpl.csv
# grep Höltzer tpl.csv
# # manually:
# sed -i '/gcc-17049|/ d' tpl.csv 
# sed -i '/gcc-22474|/ d' tpl.csv
# sed -i '/gcc-18503|/ d' tpl.csv
# sed -i '/ild-47379|/ d' tpl.csv
# sed -i '/ild-47380|/ d' tpl.csv
# sed -i '/gcc-34703|/ d' tpl.csv
# sed -i '/gcc-108480|/ d' tpl.csv
# sed -i '/gcc-17799|/ d' tpl.csv
# sed -i '/gcc-7104|/ d' tpl.csv
# sed -i '/gcc-9594|/ d' tpl.csv
# sed -i '/gcc-144759|/ d' tpl.csv
# sed -i '/gcc-135361|/ d' tpl.csv
# sed -i '/gcc-89224|/ d' tpl.csv
# sed -i '/ild-52413|/ d' tpl.csv
# sed -i '/ild-52414|/ d' tpl.csv
# sed -i '/gcc-88328|/ d' tpl.csv
# sed -i '/gcc-6229|/ d' tpl.csv
# sed -i '/ild-52641|/ d' tpl.csv
# sed -i '/ild-29900|/ d' tpl.csv
# sed -i '/ild-52648|/ d' tpl.csv
# sed -i '/ild-51842|/ d' tpl.csv
# sed -i '/gcc-155879|/ d' tpl.csv
# sed -i '/gcc-28873|/ d' tpl.csv
# sed -i '/gcc-156518|/ d' tpl.csv
# sed -i '/gcc-147121|/ d' tpl.csv
# sed -i '/gcc-148273|/ d' tpl.csv
# sed -i '/gcc-151659|/ d' tpl.csv
# sed -i '/gcc-155168|/ d' tpl.csv
# sed -i '/gcc-150007|/ d' tpl.csv
# # Made a patch

patch tpl.csv < fixtpl.patch

gawk 'BEGIN{FS="|"} $14 ~ /WCSP/ {print $0}' tpl.csv > wcsp.csv
rm -f tpl.csv

# check via
# gawk 'BEGIN{FS="|"}{x[$8]++}END{for(i in x) print i, x[i]}' wcsp.csv
# a few more fixes:

sed -i 's/|var|/|var.|/g' wcsp.csv
sed -i 's/|var. schneideri|/|var.|schneideri/g' wcsp.csv

# Convert all_rough into a delimited list
# a few fixes
sed -i -E -e 's/Uva\-Ursi/Uva-ursi/g' -e 's/\?//g' -e 's/,\ sensu.*$//g' \
    all_rough
gawk -i "taxon-tools.awk" 'BEGIN{FS=OFS="|"; PROCINFO["sorted_in"] = \
  "@ind_str_asc"} {p = parse_taxon_name($2, 1); if (p) print $1, p}' \
     all_rough > all_rough.listA

# lots of fails in accs:
# 'Betula neoalaskana × glandulosa '
# 'Caloplaca tornoe?nsis H. Magn.'
# 'Cetraria fastigata (Del. ex Nyl. in Norrl.) Ka?rnef.'
# 'Chamaepericlymenum canadense × suecicum '
# 'Coniferous Shrub (blank)'
# 'ThelIdium methorium (Nyl.) Hellb.'
# etc.

function alphaloop() {
    for i in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
    do
        echo $i
        gawk -v letter=$i 'BEGIN{FS="|"} $3 ~ letter {print $0}' \
             all_rough.listA > listA_$i
        gawk -v letter=$i 'BEGIN{FS="|"; PROCINFO["sorted_in"] = \
           "@ind_str_asc"} $5 ~ letter {code[$4 "|" $5 "|" $6 "|" $7 \
           "|" $8 "|" $9 "|" $10]=$1} END{for (i in code) \
           print code[i] "|" i}' wcsp.csv > listB_$i
        matchnames -a listA_$i -b listB_$i -o all2wcsp_match_$i -F -e 5 -q
    done
}

export -f alphaloop
# gets hot! use cpulimit if you have it
cpulimit -l 50 -i bash -c alphaloop

# gather the parts
for i in `ls all2wcsp_match_*`
do
    echo $i
    grep -v no_match $i >> all2wcsp_all
done

rm -f listA_* listB_* all2wcsp_match_*

# summarize_field 3 all2wcsp_all 
# auto_basexin                   :    240
# auto_basio+                    :     50
# auto_basio-                    :     30
# auto_exin+                     :     38
# auto_exin-                     :     61
# auto_fuzzy                     :    344
# auto_in+                       :     36
# auto_irank                     :   1095
# auto_punct                     :    950
# exact                          :   3042

gawk 'BEGIN{FS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} {code[$11 "|" $12 "|" $13 "|" $14 "|" $15 "|" $16 "|" $17]=$2} END{for (i in code) print code[i] "|" i}' all2wcsp_all > wcsp_base



# *** Ah... need to reconcile trop to ipni, to remove the variants!

cp trop_base trop_listA
cp ipni_base ipni_listB

matchnames -a trop_listA -b ipni_listB -o trop2ipni_match -f -q
grep -c "|manual" trop2ipni_match 
# 41

sed -E '/(\|manual|\|auto_punct|\|exact|\|auto_in)/ d' trop2ipni_match | gawk 'BEGIN{FS=OFS="|"}{print $1, $4, $5, $6, $7, $8, $9, $10}' > trop_base.2

cat ipni_base trop_base.2 > ipni+trop_base
summarize_field 1 ipni+trop_base | grep " 2"
# all uniq

cp wcsp_base wcsp_listA
cp ipni+trop_base ipni+trop_listB

matchnames -a wcsp_listA -b ipni+trop_listB -o wcsp2i+t_match -f -q
sed -E '/(\|manual|\|auto_punct|\|exact|\|auto_in)/ d' wcsp2i+t_match | gawk 'BEGIN{FS=OFS="|"}{print $1, $4, $5, $6, $7, $8, $9, $10}' > wcsp_base.2

cat ipni_base trop_base.2 wcsp_base.2 | sort > i+t+w_base
../../bin/sqlnulls i+t+w_base

mysql --show-warnings -u cam -ptesttest < load_canon.sql


#  move ot other README

echo "select concat_ws('-', names.id, uids.authority), genhyb, genus, sphyb, species, ssptype, ssp, author from names , uids where names.id = uids.nameID and uids.canon = 1 order by genus, species, ssp;" | mysql -N -u cam -ptesttest akflora | tr "\t" "|" > canon_listB

gawk 'BEGIN{FS=OFS="|"}{print $1, $2, $3, $4, $5, $6, $7, $8}' ../ALA_checklist/ala-names > ala_listA


# ------------------------------------------------------- ala-1687  --( 762/3740)
#     Schoenoplectus acutis (Muhl. ex Bigelow) A.Love & D.Love
#  1: Schoenoplectus acutus (Muhl. ex Bigelow) A. Love & D. Love
#  2: Schoenoplectus acutus (Muhl. ex Bigelow) Á.Löve & D.Löve
#  3: Schoenoplectus acutus (Muhl. ex J.M.Bigelow) Á.Löve & D.Löve
#   > c
#                 ala-1687 vs. 16414-TROP          
#                          vs. 19328-WCSP          
#                          vs. 8984-IPNI           
#   > 3

cp ../PAF/paf-names paf.listA
sed -i -e 's/\\N//g' paf.listA

matchnames -a paf.listA -b canon_listB -o paf2canon_match -f -q

