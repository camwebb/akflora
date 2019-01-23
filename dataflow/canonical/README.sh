# Assembling a canonical names list - this now precedes ALA, PAF, etc. Don't want to do every time a new list is added.

# This list should be _wider_ than just the plants in AK, just the
# accepted, just the correct variants. I.e., make a list that should
# have all the available names in it.

# To generate: IPNI, FNA, Trop, WCSP

# 1. Take the ACCS checklist as a start of Alaskan plants. BLAST to GNA for IPNI (and Tropicos), adding _all_ fuzzy matched names.

# 2. Matchnames to FNA accept all autofuzzy

# 3. Tropicos

# 4. Matchnames to PL accept all autofuzzy.  Give canonical status as
# they are added to master list

# echo "select concat('acc-', acceptedID) as guid, concat_ws(' ', nameAccepted, authAccepted) as name, 'accepted' as status from speciesAccepted where nameAccepted REGEXP '[^\ ]+\ [^\ ]+' union select concat('non-', adjudicatedID) as guid, concat_ws(' ', nameAdjudicated, authAdjudicated) as name, concat('acc-', acceptedID) as status from speciesAdjudicated where nameAdjudicated REGEXP '[^\ ]+\ [^\ ]+';" | mysql -N -u cam -ptesttest alaskaFlora > accs

# could just use names from speciesAdjudicated
echo "select concat('accs-', adjudicatedID) as guid, concat_ws(' ', nameAdjudicated, authAdjudicated) as name from speciesAdjudicated where nameAdjudicated REGEXP '[^\ ]+\ [^\ ]+';" | mysql -N -u cam -pPASS alaskaFlora > accs

gawk 'BEGIN{FS="\t"}{gsub(/NULL/,"",$2); gsub(/×/," x ",$2); gsub(/\ ssp\.\ /," subsp. ",$2); gsub(/\ \ +/," ",$2); gsub(/^\ */,"",$2); gsub(/\ *$/,"",$2); print $1 "|" $2 > "names4gnr-"  int(++i/995)+1 }' accs
sed -i 's/ ssp. / subsp. /g' accs

# # Run through GNR
for infile in names4gnr*
do
     echo "Running GNA on " $infile
     gawk -v INFILE=$infile -f lib/gnr.awk >> gnr.out
done

rm -f names4gnr-*

# parse

grep "ipni-" gnr.out | gawk -i "taxon-tools.awk" 'BEGIN{FS=OFS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} {code[$4] = $3} END{for (i in code) {p = parse_taxon_name(i, 1); if (p) print code[i], p}}' > ipni_base

../../bin/sqlnulls ipni_base

grep "trop-" gnr.out | gawk -i "taxon-tools.awk" 'BEGIN{FS=OFS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} {code[$4] = $3} END{for (i in code) {p = parse_taxon_name(i, 1); if (p) print code[i], p}}' > trop_base

../../bin/sqlnulls trop_base


# Some errors but these are errors in GNR records
# ** Fail: 'Hordeum x caespitosum 8999+' does not match:
#          Hordeum x caespitosum 8999+  <- parsed

# ** Fail: 'Botrychium virginianum var. ? simplex A. Gray' does not match:
#          Botrychium virginianum var. ? simplex A. Gray  <- parsed

# ** Fail: 'Sphagnum riparium var. > *fallax Sanio' does not match:
#          Sphagnum riparium var. > *fallax Sanio  <- parsed

# 10,000 IPNI names!  good


# Now WCSP

gawk 'BEGIN{OFS="|";FPAT = "([^,]*)|(\"[^\"]+\")"}{for(i=1;i<=NF;i++) if(substr($i,1,1)=="\"") $i=substr($i,2,length($i)-2); print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21}' ~/public_html/MaTCH/recipes/theplantlist/data/all.csv > tpl.csv

# # fix a few - some records had """ which did not parrse
# gawk 'BEGIN{FS="|"}{x[$14]++}END{for(i in x) print i, x[i]}' tpl.csv 
# gawk 'BEGIN{FS="|"}$14 == "Unresolved" {print $0}'
# gawk 'BEGIN{FS="|"}$14 == "" {print $1}' tpl.csv
# grep Höltzer tpl.csv

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

patch tpl.csv < fixtpl.patch

gawk 'BEGIN{FS="|"} $14 ~ /WCSP/ {print $0}' tpl.csv > wcsp.csv

# check
# gawk 'BEGIN{FS="|"}{x[$8]++}END{for(i in x) print i, x[i]}' wcsp.csv
# more fixes:

sed -i 's/|var|/|var.|/g' wcsp.csv
sed -i 's/|var. schneideri|/|var.|schneideri/g' wcsp.csv

gawk -i "taxon-tools.awk" 'BEGIN{FS="\t";OFS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} {p = parse_taxon_name($2, 1); if (p) print $1, p}' accs > listA

# lots of fails in accs:
# 'Betula neoalaskana × glandulosa '
# 'Caloplaca tornoe?nsis H. Magn.'
# 'Cetraria fastigata (Del. ex Nyl. in Norrl.) Ka?rnef.'
# 'Chamaepericlymenum canadense × suecicum '
# 'Lecidea tornoe?nsis Nyl.'
# 'Coniferous Shrub (blank)'
# 'Coniferous Tree (blank)'
# 'Crustose Lichen (blank)'
# 'Betula neoalaskana × glandulosa '
# 'Calliergon subsarmentosum Kindb., sensu Ottawa Nat. 23: 137. 1909'
# 'Caloplaca tornoe?nsis H. Magn.'
# 'Cetraria fastigata (Del. ex Nyl. in Norrl.) Ka?rnef.'
# 'Chamaepericlymenum canadense × suecicum '
# 'Chamaepericlymenum canadensis × suecicum '
# 'Coniferous Shrub '
# 'Coniferous Tree '
# 'Cornus canadensis × suecica '
# 'Cornus suecica × canadensis '
# 'Crustose Lichen '
# 'Cryptobiotic Crust '
# 'Cryptobiotic Crust (blank)'
# 'Deciduous Shrub '
# 'Deciduous Shrub (blank)'
# 'Deciduous Tree '
# 'Deciduous Tree (blank)'
# 'Dwarf Shrub '
# 'Dwarf Shrub (blank)'
# 'Eriophorum russeolum x scheuchzeri '
# 'Foliose Lichen '
# 'Foliose Lichen (blank)'
# 'Fruticose Lichen '
# 'Fruticose Lichen (blank)'
# 'Lecidea tornoe?nsis Nyl.'
# 'Picea glauca x sitchensis '
# 'Salix pulchra × scouleriana na'
# 'Salix pulchra × scouleriana NULL'
# 'Subularia aquatica ssp. mexicana G.A. Mulligan & Calder, ined.?'
# 'ThelIdium methorium (Nyl.) Hellb.'
# 'Uva-Ursi uva-ursi (L.) Britton'
# 'Xanthomendoza fallax (Hepp) So?chting, Ka?rnefelt & S. Kondr.'

# gawk 'BEGIN{FS=OFS="|"}{print $1, $4, $5, $6, $7, $8, $9, $10}' wcsp.csv > listB
# Dang, duplicates

function alphaloop() {
    for i in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
    do
        echo $i
        gawk -v letter=$i 'BEGIN{FS="|"} $3 ~ letter {print $0}' listA > listA_$i
        gawk -v letter=$i 'BEGIN{FS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} $5 ~ letter {code[$4 "|" $5 "|" $6 "|" $7 "|" $8 "|" $9 "|" $10]=$1} END{for (i in code) print code[i] "|" i}' wcsp.csv > listB_$i
        matchnames -a listA_$i -b listB_$i -o accs2wcsp_match_$i -F -e 5
    done
}

export -f alphaloop
cpulimit -l 50 -i bash -c alphaloop

for i in `ls accs2wcsp_match_*`
do
    echo $i
    grep -v no_match $i >> accs2wcsp_all
done

# gawk 'BEGIN{FS="|"}{x[$3]++}END{for(i in x) print i, x[i]}' accs2wcsp_match 
# auto_fuzzy 265
# auto_basio+ 37
# auto_irank 701
# auto_basio- 21
# auto_punct 794
# auto_exin+ 30
# exact 2250
# auto_exin- 21
# auto_basexin 147

gawk 'BEGIN{FS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} {code[$11 "|" $12 "|" $13 "|" $14 "|" $15 "|" $16 "|" $17]=$2} END{for (i in code) print code[i] "|" i}' accs2wcsp_all > wcsp_base


