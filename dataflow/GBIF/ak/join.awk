BEGIN{
  FS = "\t"
  OFS= "|"

  while ((getline < "multimedia.txt")>0)
    if ($3 == "image/jpeg")
      img[$1] = img[$1] "," $4
}

{
  gsub(/\|/,"{PIPE}",$0)
  print $1, $64, $68, $60, $61, $69, $91, $71, $230, $189, $214, $231,
    $241, $120, $129, $138, $139, $103, gensub(/^,/,"","G",img[$1])
}

# 0   gbifID
# 63  basisOfRecord
# 67  occurrenceID
# 59  institutionCode
# 60  collectionCode
# 68  catalogNumber
# 90  otherCatalogNumbers
# 70  recordedBy
# 229 taxonKey
# 188 scientificName
# 213 taxonomicStatus
# 230 acceptedTaxonKey
# 240 acceptedScientificName
# 119 higherGeography
# 128 locality
# 137 decimalLatitude
# 138 decimalLongitude
# 102 eventDate
