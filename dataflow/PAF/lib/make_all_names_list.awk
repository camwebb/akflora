BEGIN{
  OFS = "|"

  FS="\t"
  while ((getline < "paf.1") > 0) {
    if ($8)  {auth = "(" $8 ") " $7}
    if (!$8) {auth = $7}

    # If an aggregate, fix name
    if ($3 ~ /\ aggregate/) {$3 = $4}

    # Sort out the var vs subsp vs sp
    subt = ""
    if (($2 == "subspecies") && $5) {subt = "subsp." $5}
    if (($2 == "subspecies") && $6) {gsub(/(_|\])/,"",$6); subt = "var." $6}
    if ($2 == "species")          {subt = ""}
    
    acc["paf-" $1] = "paf-" $1 
    name = $3 " " subt " " auth
    gsub(/\ \ */, " ", name)
    gsub(/(^\ |\ $)/, "", name)
    code[name] = "paf-" $1
  }
  
  FS="|"
  while (( getline < "paf.3") > 0) {
    gsub(/^\ */,"",$0)
    gsub(/\ *\|\ */,"|",$0)
    gsub(/\ *$/,"",$0)
    ++c[$1]
    n[$2][c[$1]] = $1
  }
  for (i in n) {
    if (!code[i]) {
      for (j in n[i]) {
        # should only be one value of j
        # if there is already a code for this, it is both a syn and an accepted
        code[i] = "paf-" n[i][j] "-s" j
        # make the lookup
        acc[code[i]] = "paf-" n[i][j]
      }
    }
    else print "Warning: " code[i] ", " i " is both acc and syn" > "/dev/stderr"
  }
  
  for (i in code) print code[i], acc[code[i]], i
  # split into paf-names, paf-rel

  # note warnings
}
