BEGIN{
  FS="|"

  while ((getline < "../canonical/canon") > 0) 
    name[gensub(/^trop/,"tro","G",$1)] = $2 $3 $4 $5 $6 $7

  while ((getline < "wcsp") > 0) {
    if (name[$1] && (name[$1] != $2 $3 $4 $5 $6 $7))
      print $1, name$1, $2 $3 $4 $5 $6 $7
    # else print $1
  }
}

  
