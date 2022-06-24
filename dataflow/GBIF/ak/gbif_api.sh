# get iNat too (not just basisOfRecord=PRESERVED_SPECIMEN)

# Explore with
# curl -s 'https://api.gbif.org/v1/occurrence/search?institutionCode=UAM&collectionCode=Herb&stateProvince=Alaska' | json_walk_array | less

N=`curl -s 'https://api.gbif.org/v1/occurrence/search?taxonKey=7707728&stateProvince=Alaska' | gawk '@load "json"; BEGIN {RS="\x04";OFS="|"} {json = $0} END{ json::from_json(json, data) ; print (int(data["count"]/300)+1)*300}'`
echo '~'$N' records'  > /dev/stderr
    
for i in `seq 0 300 $N`
do
    echo $i
    curl -s 'https://api.gbif.org/v1/occurrence/search?limit=300&offset='$i'&taxonKey=7707728&stateProvince=Alaska' | \
      gawk -v sp=$1 '@load "json"
  BEGIN {RS="\x04";OFS="|"}
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
        data["results"][i]["media"][1]["identifier"]
  }' >> gbif
done


