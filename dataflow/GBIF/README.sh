# Getting species list for Ecosystems extension of Alaska into the Yukon
# 5 Blocks with low dimensional jaggedness needed for GBIF queries:
#   https://www.google.com/maps/d/viewer?mid=1JgKNK6-DVAgrsWOow2lSlFTg1U0D1Lft
# 2021-10-02 & 2022-03-16

function qgbif() {
    POLY=`gawk 'BEGIN{FS=","}{gsub(/ /,"",$0);x=x $1 "+" $2 ","} END{gsub(/,$/,"",x);print x}' poly$1`
    N=`curl -s 'https://api.gbif.org/v1/occurrence/search?taxonKey=7707728&basisOfRecord=PRESERVED_SPECIMEN&geometry=POLYGON(('$POLY'))' | gawk '@load "json"; BEGIN {RS="\x04";OFS="|"} {json = $0} END{ json::from_json(json, data) ; print (int(data["count"]/300)+1)*300}'`
    echo '~'$N' records in block '$1 > /dev/stderr
    
    for i in `seq 0 300 $N`
    do
        echo $i
        curl -s 'https://api.gbif.org/v1/occurrence/search?limit=300&offset='$i'&taxonKey=7707728&basisOfRecord=PRESERVED_SPECIMEN&geometry=POLYGON(('$POLY'))' | gawk '@load "json"; BEGIN {RS="\x04";OFS="|"} {json = $0} END{ json::from_json(json, data) ; for (i in data["results"]) print data["results"][i]["key"], data["results"][i]["institutionCode"], data["results"][i]["catalogNumber"], data["results"][i]["acceptedScientificName"], data["results"][i]["decimalLongitude"],data["results"][i]["decimalLatitude"]}' >> block$1
    done
}

rm block*
qgbif 1 
qgbif 2
qgbif 3
qgbif 4
qgbif 5 

# Totals (2022-03-16)
# block1 9088
# block2 1696
# block3 2248
# block4 5123
# block5 1639

cat block* > yt_extension_gbif_colls
rm block*

gawk 'BEGIN{FS=OFS="|"}{t[$4]++}END{PROCINFO["sorted_in"]="@ind_str_asc"; for (i in t) print i,t[i]}' yt_extension_gbif_colls > yt_extension_gbif_taxa

# just the names, with a dummy first column, and drop the families and genera
gawk 'BEGIN{FS=OFS="|"}{t[$4]++}END{PROCINFO["sorted_in"]="@ind_str_asc"; for (i in t) print "yt-tmp-" ++n, i}' yt_extension_gbif_colls | \
    grep -E 'yt-tmp-[0-9]+\|[^ ]+ [a-z]' > names

# remove the dates at the end of names (parsenames does not accept)
sed -i -E 's/, [0-9]{4}//g' names

# parse the name parts
parsenames names > yt_names
rm names



