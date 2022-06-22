BEGIN{
  FS="|"
  PROCINFO["sorted_in"] = "@ind_str_asc"

  #          what      NROA
  read_data("canon",  "1000")
  read_data("paf",    "1111")
  read_data("ala",    "1111")
  read_data("accs",   "1111")
  read_data("fna",    "1111")
  read_data("hulten", "1111")

  write_names()
  # query()
}

function read_data(what, switches,
                   ni, nn, name, ln, lo, n_Syn_r, n_Ortho_r) {
  if (substr(switches,1,1) == "1") {
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
  }

  delete ni ; delete nn ; lo = 0

  if (substr(switches,2,1) == "1") {
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
  }

  delete ni ; lo = 0

  if (substr(switches,3,1) == "1") {
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
  }

  delete ni ; lo = 0

  if (substr(switches,4,1) == "1") {
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
  print "@prefix : <x:> .\n"
  for (i in Name) {
    out = ":" i "\n"                                             \
      "  :name \"" Name[i] "\" ;"                                       \
      ((Canon[i]) ? "\n  :canon 1 ;" : "")                              \
      ((Syn[i])   ? "\n  :syn [ :accto :"                               \
       toupper(gensub(/-.*$/,"","G",i)) " ; :of :" Syn[i] " ] ;" : "")  \
      ((Accepted[i]) ? "\n  :accepted [ :accto :"                       \
       toupper(gensub(/-.*$/,"","G",i)) " ] ;" : "")                    \
      ((Ortho[i]) ? "\n  :ortho :" Ortho[i] " ;" : "")                  \
      ((Inak[i]) ? "\n  :inak [ :accto :"                               \
       toupper(gensub(/-.*$/,"","G",i)) " ] ;" : "")                   
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
        for (j in Ortho_r[i]) {
          # <subset> to those which have synonyms, and ortho to IDs
          # <filter> which are Canon
          if (Canon[Ortho[Syn[Ortho_r[i][j]]]])
            # <ouput>
            print i, j,
              Ortho_r[i][j],
              Syn[Ortho_r[i][j]],
              Ortho[Syn[Ortho_r[i][j]]]
  
}

