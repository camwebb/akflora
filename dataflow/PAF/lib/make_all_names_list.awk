BEGIN{
  OFS = "|"

  FS="\t"
  while ((getline < "paf.1") > 0) {
    if ($8)  {auth = "(" $8 ") " $7}
    if (!$8) {auth = $7}

    # If an aggregate, fix name
    if ($3 ~ /\ aggregate/) {$3 = $4}

    # Sort out the var vs subsp vs sp vs taxon
    subt = ""
    if (($2 == "subspecies") && $5) {subt = "subsp. " $5}
    else if (($2 == "subspecies") && $6) {gsub(/(_|\])/,"",$6);
      subt = "var. " $6}
    else if (($2 == "subspecies") && $10) {
      gsub(/[`_)(]/,"",$10)
      gsub(/\ \ */,"_",$10)
      gsub(/taxon_/,"",$10)
      subt = "taxon " $10
    }
    else if ($2 == "species")          {subt = ""}
    else print "Warning: " $1 " name not made" > "/dev/stderr"
    
    acc["paf-" $1] = "paf-" $1 
    name = $3 " " subt " " auth
    gsub(/\ \ */, " ", name)
    gsub(/(^\ |\ $)/, "", name)
    code[name] = "paf-" $1
  }
  
  FS="|"
  while (( getline < "paf.4") > 0) {
    gsub(/^\ */,"",$0)
    gsub(/\ *\|\ */,"|",$0)
    gsub(/\ *$/,"",$0)
    ++c[$1]
    n[$2][c[$1]] = $1
  }
  for (i in n) {
    warn = ""
    if (!code[i]) {
      for (j in n[i]) {
        # should only be one value of j
        # if there is already a code for this, it is both a syn and an accepted
        code[i] = "paf-" n[i][j] "-s" j
        # make the lookup
        acc[code[i]] = "paf-" n[i][j]
      }
    }
    else {
      for (j in n[i]) {
        warn = warn "paf-" n[i][j] "-s" j
      }
      print "Warning: " code[i] ", " i " is both acc and syn (" warn ")" \
        > "/dev/stderr"
    }
  }
  # simple:
  #  for (i in code) print code[i], acc[code[i]], i
  # split into paf-names, paf-rel

  for (i in code) print code[i], parse_taxon_name(i, 1) > "paf-names"
  close("paf-names")

  for (i in code) print code[i], i > "listA"
  close("listA")

  for (i in code) {
    if (code[i] == acc[code[i]]) s = "accepted"
    else s = "synonym"
    print code[i], s, "PAF 2018", acc[code[i]] > "paf-rel"
  }
  close("paf-rel")
}
