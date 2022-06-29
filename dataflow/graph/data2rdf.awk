BEGIN{
  FS="|"
  PROCINFO["sorted_in"] = "@ind_str_asc"
  URI = 1

  #          what      NROA
  read_data("canon")
  read_data("paf")
  read_data("ala")
  read_data("accs")
  read_data("fna")
  read_data("hulten")
  read_data("gbif")

  # write_names()
  write_psv()
  # write_names_cypher()
  # write_occ()
  # query()
}

function read_data(what, 
                   ni, nn, name, ln, lo, n_Syn_r, n_Ortho_r) {

  printf "reading %-8s names\n", what > "/dev/stderr"
  while ((getline < ("infiles/" what "_names")) > 0) {
    ln++
    name = clean($2 " " $3 " " $4 " " $5 " " $6 " " $7 " " $8)
    # tests
    if (++ni[$1] > 1) 
      fail("id '" $1 "' in " what " names not unique")
    if (++nn[name] > 1)
      fail("name '" name "' in " what " names not unique")
    # Names[name] = 1
    Name[$1] = name
    if (what == "canon") {
      Canon[$1] = 1
      Ortho[$1] = $1
      Ortho_r[$1][++n_Ortho_r[$1]] = $1
    }
  }
  if (what == "canon")
    return
  
  delete ni ; delete nn ; lo = 0

  printf "reading %-8s rel\n", what > "/dev/stderr"
  while ((getline < ("infiles/" what "_rel")) > 0) {
    lo++
    # tests
    if (++ni[$1] > 1) 
      fail("id '" $1 "' in " what " names not unique")
    if ($3 != "accepted") {
      Syn[$1]  = $2
      Syn_r[$2][++n_Syn_r[$2]] = $1
    }
    else if ($3 == "accepted")
      Accepted[$1]  = 1
  }
  if (ln != lo)
    fail("lines (" lo ") not equal to names lines (" ln ")")

  delete ni ; lo = 0

  printf "reading %-8s ortho\n", what > "/dev/stderr"
  while ((getline < ("infiles/" what "_ortho")) > 0) {
    lo++
    # tests
    if (++ni[$1] > 1) 
      fail("id '" $1 "' in " what " ortho not unique")
    
    if ($1 == $2) {
      Canon[$1] = 1
      Ortho[$1] = $1
      Ortho_r[$1][++n_Ortho_r[$1]] = $1
    }
    else if (Name[$2]) {
      Ortho[$1] = $2
      Ortho_r[$2][++n_Ortho_r[$2]] = $1
    }
    else {
      delete Name[$2]
      fail("ortho id '" $2 "' in " what " ortho does not exist")
    }
  }
  if (ln != lo)
    fail("lines (" lo ") not equal to names lines (" ln ")")
  
  delete ni ; lo = 0

  printf "reading %-8s ak\n", what > "/dev/stderr"
  while ((getline < ("infiles/" what "_ak")) > 0) {
    lo++
    # tests
    if (++ni[$1] > 1) 
      fail("id '" $1 "' in " what " ak not unique")
      
    if ($2)
      Inak[$1] = 1
  }
  if (ln != lo)
    fail("lines (" lo ") not equal to names lines (" ln ")")

  delete ni

  if (what == "gbif") {
    printf "reading %-8s occ\n", what > "/dev/stderr"
    while ((getline < ("infiles/" what "_occ")) > 0) {
      # tests
      if (++ni[$1] > 1) 
        fail("id '" $1 "' in " what " ak not unique")
      OccType[$1] = $2
      OccGUID[$1] = $3
      OccDet[$1]  = $4
      OccCoord[$1] = $5
    }
  }

  
}

function clean(n) {
  gsub(/^ +/,"",n)
  gsub(/ +$/,"",n)
  gsub(/  +/," ",n)
  return n
}

function fail(msg) {
  print "ERORR: " msg > "/dev/stderr"
  # exit 1
}

function write_names(   i, out) {
  if (URI)
    print                                                               \
      "@prefix     : <http://alaskaflora.org/sw/tmp.rdf#> .\n"            \
      "@prefix gbif: <https://www.gbif.org/species/> .\n"                  \
      "@prefix  gbo: <https://www.gbif.org/occurrence/> .\n"                  \
      "@prefix ipni: <https://www.ipni.org/n/> .\n"                     \
      "@prefix  kew: <http://www.theplantlist.org/tpl1.1/record/kew-> .\n" \
      "@prefix trop: <http://legacy.tropicos.org/Name/> .\n"            \
      "@prefix  paf: <http://panarcticflora.org/#paf-> .\n"             \
      "@prefix  ala: <http://alaskaflora.org/sw/ala.rdf#> .\n"            \
      "@prefix accs: <https://floraofalaska.org/provisional-checklist/#> .\n" \
      "@prefix  fna: <https://beta.floranorthamerica.org/#> .\n"        \
      "@prefix hulten: <https://alaskaflora.org/hulten/hulten.xml#> .\n" 
  else
    print "@prefix : <x:> .\n"
  for (i in Name) {
    out = prefix(i) "\n"                                                \
      "  :name \"" Name[i] "\" ;"                                       \
      ((Canon[i]) ? "\n  :canon 1 ;" : "")                              \
      ((Syn[i])   ? "\n  :syn [ :accto :"                               \
       toupper(gensub(/-.*$/,"","G",i)) " ; :of " prefix(Syn[i]) " ] ;" : "") \
      ((Accepted[i]) ? "\n  :accepted [ :accto :"                       \
       toupper(gensub(/-.*$/,"","G",i)) " ] ;" : "")                    \
      ((Ortho[i]) ? "\n  :ortho " prefix(Ortho[i]) " ;" : "")          \
      ((Inak[i]) ? "\n  :inak [ :accto :"                               \
       toupper(gensub(/-.*$/,"","G",i)) " ] ;" : "")                   
    gsub(/;$/,".\n",out)
    print out
  }
}

function prefix (id) {
  if (URI) {
    return gensub(/^([^-]+)-(.+)$/,"\\1:\\2","G",id)
  }
  else
    return (":" id)
}

function write_psv(   i, out) {
  OFS="|"
  for (i in Name) {
    print i,
      toupper(gensub(/-.*$/,"","G",i)),
      Name[i],
      Canon[i],
      Ortho[i],
      Accepted[i],
      Syn[i],
      Inak[i]
  }
}

function write_names_cypher(   i, out, lab, src, node, syn, ortho) {
  out = "CREATE\n"
  for (i in Name) {
    lab = gensub(/-/,"","G",i)
    src = toupper(gensub(/-.*$/,"","G",i))
    node[i] = "(" lab ":Name "                                         \
      "{name: '" gensub(/'/,"","G",Name[i]) "', "                       \
      "label: '" i "' "                                                 \
      ((Canon[i]) ? ", canon: 'yes'" : "")                              \
      ((Accepted[i]) ?                                                  \
       ", acceptedby: ['" src "']" : "")                                \
      ((Inak[i]) ?                                                      \
       ", inakby: ['" src "']" : "")                                    \
      "})"
    if (Syn[i])
      syn[i] =                                                          \
        "((" lab ") -[:SYN {accordingto: ['" src "']}]-> "              \
        "(" gensub(/-/,"","G",Syn[i]) "))"
    if (Ortho[i])                                                       \
      ortho[i] = "((" lab ") -[:ORTHO {accordingto: ['" src "']}]-> "   \
        "(" gensub(/-/,"","G", Ortho[i]) "))"
  }
  for (i in node)
    out = out node[i] ",\n"
  for (i in syn)
    out = out syn[i] ",\n"
  for (i in ortho)
    out = out ortho[i] ",\n"
  gsub(/,\n$/,";\n",out)
  print out
}

function write_occ(   i, out) {
  for (i in OccType) {
    out = prefix(i) "\n"                                                \
      "  :occtype \"" OccType[i] "\" ;"                                 \
      "\n  :det " prefix(OccDet[i]) " ;"                                \
      "\n  :coord \"" OccCoord[i] "\" ;"                                \
      ((OccGUID[i]) ? "\n  :guid \"" OccGUID[i] "\" ;" : "")
    gsub(/;$/,".\n",out)
    print out
  }
}


  # print "reading paf & paf syns" > "/dev/stderr"
  # while ((getline < "../PAF/paf")>0)
  #   print ":" $1 "\n"\
  #     "  :name \"" clean($2 " " $3 " " $4 " " $5 " " $6 " " $7 " " $8)"\" ;\n"\
  #     "\" ;\n  :syn :"  $9 " .\n"
  
  # print "reading paf ortho" > "/dev/stderr"
  # while ((getline < "../canonical/paf2canon_match")>0)
  #   if ($2)
  #     print ":" $1 " :ortho :" $2 " .\n"
  
  # print "cleaning names" > "/dev/stderr"
  # for (i in name) {
  #   gsub(/^ +/,"",name[i])
  #   gsub(/ +$/,"",name[i])
  #   gsub(/  +/," ",name[i])
  # }

function query(  i, j) {
  OFS="|"

  print "query" > "/dev/stderr"
  # Example: find cases of inferred canon to canon
  # <set> IDs
  for (i in Name)
    # <filter> canon names
    if (Canon[i])
      # <subset> to those ortho-to names
      if (isarray(Ortho_r[i]))
        for (j in Ortho_r[i]) 
          # <subset> to those which have synonyms, and ortho to IDs
          # <filter> which are Canon
          if (Canon[Ortho[Syn[Ortho_r[i][j]]]])
            # <ouput>
            print i, j,
              Ortho_r[i][j],
              Syn[Ortho_r[i][j]],
              toupper(gensub(/-.*$/,"","G",Ortho_r[i][j])),
              Ortho[Syn[Ortho_r[i][j]]]
  
}
  
