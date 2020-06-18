BEGIN{
  FS=OFS="|"
}

# DEC_LAT|DEC_LONG|FORMATTED_SCIENTIFIC_NAME|GUID|IDENTIFICATION_ID|OTHERCATALOGNUMBERS|PARTDETAIL

{
  if (match($6, /ALAAC/))
    $6 = gensub(/^.*ALAAC= *([Vv]?[0-9]+).*$/,"\\1","G",$6)
  else
    $6 = ""

  if (match($7, /BC:H[0-9]+/))
    $7 = gensub(/^.*BC:(H[0-9]+).*$/,"\\1","G",$7)
  else
    $7 = ""
  if (($7) && (x[$7]++ < 1))
    print $7, $6, $4, $3, $2, $1
}
