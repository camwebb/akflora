BEGIN{
  FS=OFS="|"
}

{
  if (match($4, /ALAAC/))
    $4 = gensub(/^.*ALAAC= *([Vv]?[0-9]+).*$/,"\\1","G",$4)
  else
    $4 = ""

  if (match($5, /BC:H[0-9]+/))
    $5 = gensub(/^.*BC:(H[0-9]+).*$/,"\\1","G",$5)
  else
    $5 = ""
  if (($5) && (x[$5]++ < 1))
    print $5, $4, $2, $1
}
