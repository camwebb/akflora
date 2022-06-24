# Getting species list for Ecosystems extension of Alaska into the Yukon
# 5 Blocks with low dimensional jaggedness needed for GBIF queries:
#   https://www.google.com/maps/d/viewer?mid=1JgKNK6-DVAgrsWOow2lSlFTg1U0D1Lft
# 2021-10-02 & 2022-03-16

function qgbif() {
    POLY=`gawk 'BEGIN{FS=","}{gsub(/ /,"",$0);x=x $1 "+" $2 ","} END{gsub(/,$/,"",x);print x}' poly$1`
    N=`curl -s 'https://api.gbif.org/v1/occurrence/search?taxonKey=7707728&geometry=POLYGON(('$POLY'))' | gawk '@load "json"; BEGIN {RS="\x04";OFS="|"} {json = $0} END{ json::from_json(json, data) ; print (int(data["count"]/300)+1)*300}'`
    echo '~'$N' records in block '$1 > /dev/stderr
    
    for i in `seq 0 300 $N`
    do
        echo $i
        curl -s 'https://api.gbif.org/v1/occurrence/search?limit=300&offset='$i'&taxonKey=7707728&geometry=POLYGON(('$POLY'))'\
            | gawk '
  @load "json";
  BEGIN {RS="\x04";OFS=SUBSEP}
  {json = $0}
  END{
    json::from_json(json, data)
      for (i in data["results"])
        print data["results"][i]["key"],
        data["results"][i]["basisOfRecord"],
        data["results"][i]["occurrenceID"],
        data["results"][i]["institutionCode"],
        data["results"][i]["collectionCode"],
        data["results"][i]["catalogNumber"],
        data["results"][i]["otherCatalogNumbers"],
        data["results"][i]["recordedBy"],
        data["results"][i]["taxonKey"],
        data["results"][i]["scientificName"],
        data["results"][i]["taxonomicStatus"],
        data["results"][i]["acceptedTaxonKey"],
        data["results"][i]["acceptedScientificName"],
        data["results"][i]["higherGeography"],
        data["results"][i]["locality"],
        data["results"][i]["decimalLongitude"],
        data["results"][i]["decimalLatitude"],
        gensub(/T[0-9:]+$/,"","G",data["results"][i]["eventDate"]),
        data["results"][i]["media"][1]["identifier"]}' >> block$1
    done
}

rm block*
qgbif 1 
qgbif 2
qgbif 3
qgbif 4
qgbif 5 

# Totals 2022-03-16  2022-06-24 incl HUMAN
# block1 9088        11179
# block2 1696        3038
# block3 2248        ...
# block4 5123
# block5 1639

# clean the pipe symbols
cat block* | gawk '{gsub(/\|/,"{PIPE}",$0); gsub(/\034/,"|",$0); print $0}' > yt_extension_gbif_colls
# rm block*

# gawk 'BEGIN{FS=OFS="|"}{t[$4]++}END{PROCINFO["sorted_in"]="@ind_str_asc"; for (i in t) print i,t[i]}' yt_extension_gbif_colls > yt_extension_gbif_taxa

# # just the names, with a dummy first column, and drop the families and genera
# gawk 'BEGIN{FS=OFS="|"}{t[$4]++}END{PROCINFO["sorted_in"]="@ind_str_asc"; for (i in t) print "yt-tmp-" ++n, i}' yt_extension_gbif_colls | \
#     grep -E 'yt-tmp-[0-9]+\|[^ ]+ [a-z]' > names

# # remove the dates at the end of names (parsenames does not accept)
# sed -i -E 's/, [0-9]{4}//g' names

# # parse the name parts
# parsenames names > yt_names

# # remove a few that fail
# sed -i -E '/.*\|$/d' yt_names

# rm names



