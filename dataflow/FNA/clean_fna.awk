BEGIN{
  FS = OFS = "|"
}

# for Alaskan plants only
$9 ~ /Alaska/ && ($3) {
# ($3) {
  sst = ssp = auth = status = genhyb = sphyb = ""
  gsub(/\.xml/,"",$1)
  gsub(/^V/,"",$1)
  gsub(/_/,"-",$1)
  
  # hybrid signs
  if ($2 ~ /×/) genhyb = "×"
  gsub(/[× ]/,"",$2)
  if ($3 ~ /×/) sphyb = "×"
  gsub(/[× ]/,"",$3)
    
  if ($10 == "ACCEPTED") {
    id = "fna-" $1
    status = "accepted"
    gen[$1] = toupper(substr($2,1,1)) tolower(substr($2,2))
  }
  else if ($10 == "SYNONYM") {
    id = "fna-" $1 "-s" (++syn[$1])
    status = "fna-" $1
    if ($2 ~ /\./) $2 = gen[$1] 
  }
  if ($10 == "BASIONYM") {
    id = "fna-" $1 "-b" (++bas[$1])
    status = "fna-" $1
  }
  
  if ($5) {
    sst = "subsp."
    ssp = $5
    auth = $6
  }
  else if ($7) {
    sst = "var."
    ssp = $7
    auth = $8
  }
  else auth = $4
  
  print id, genhyb, toupper(substr($2,1,1)) tolower(substr($2,2)), sphyb, $3, \
    sst, ssp, gensub(/unknown/,"","G",auth), status
}
