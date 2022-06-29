BEGIN{
  FS="|"
  PROCINFO["sorted_in"] = "@ind_str_asc"
  
  while ((getline < ("infiles/fna_names")) > 0) {
    name[$1] = clean($2 " " $3 " " $4 " " $5 " " $6 " " $7 " " $8)
    u[$1]  =   url($2, $3, $4, $5, $6,  $7)
  }
  while ((getline < ("infiles/fna_rel")) > 0) {
    if ($3 != "accepted")
      syn[$1]  = $2
    else if ($3 == "accepted")
      accepted[$1]  = 1
  }

  header()
  
  for (i in name)
    if (accepted[i])
      print ":" i "\n"                   \
        "  dc:title \"" name[i] "\" ;\n" \
        "  rdfs:seeAlso fna:" u[i] " .\n"  # was owl:sameAs but not quite right
    else
      print ":" i "\n"                                                  \
        "  dc:title \"" name[i] "\" ;\n"                                \
        "  rdfs:seeAlso fna:" u[syn[i]] " ;\n"                          \
        ((i ~ /s[0-9]+$/) ? ("  :fnasyn :" syn[i] " .\n") : (""))        \
        ((i ~ /b[0-9]+$/) ? ("  tn:basionymFor :" syn[i] " .\n") : (""))
}   


    # out = prefix(i) "\n"                                                \
    #   "  :name \"" Name[i] "\" ;"                                       \
    #   ((Canon[i]) ? "\n  :canon 1 ;" : "")                              \
    #   ((Syn[i])   ? "\n  :syn [ :accto :"                               \
    #    toupper(gensub(/-.*$/,"","G",i)) " ; :of " prefix(Syn[i]) " ] ;" : "") \
    #   ((Accepted[i]) ? "\n  :accepted [ :accto :"                       \
    #    toupper(gensub(/-.*$/,"","G",i)) " ] ;" : "")                    \
    #   ((Ortho[i]) ? "\n  :ortho " prefix(Ortho[i]) " ;" : "")          \
    #   ((Inak[i]) ? "\n  :inak [ :accto :"                               \
    #    toupper(gensub(/-.*$/,"","G",i)) " ] ;" : "")                   
    # gsub(/;$/,".\n",out)
    # print out
    # }


function clean(n) {
  gsub(/^ +/,"",n)
  gsub(/ +$/,"",n)
  gsub(/  +/," ",n)
  return n
}

function url(xg, g, xs, s, i, ie, p1, p2, p3) {
  if (xg == "×")
    p1 = "×" tolower(g)
  else
    p1 = g
  if (xs == "×")
    p2 = "×" s
  else
    p2 = s
  if (i)
    p3 = "_" i "_" ie
  
  return (p1 "_" p2 p3)
}

function header() {
  print "@prefix     : <http://w3id.org/akflora/sw/fna-names.rdf#>    .\n" \
    "@prefix   dc: <http://purl.org/dc/elements/1.1/>            .\n"   \
    "@prefix  dct: <http://purl.org/dc/terms/>                   .\n"   \
    "@prefix  rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .\n"   \
    "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>       .\n"   \
    "@prefix  owl: <http://www.w3.org/2002/07/owl#>              .\n"   \
    "@prefix  fna: <http://floranorthamerica.org/>               .\n"   \
    "@prefix   tn: <http://rs.tdwg.org/ontology/voc/TaxonName#>  .\n"   \
    "\n"                                                                \
    "<http://w3id.org/akflora/sw/fna-names.rdf>\n"                       \
    "  dc:creator \"Campbell Webb\" ;\n"                                \
    "  dc:description \"\"\"A list of FNA (see below) taxonomic names used in\n" \
    "     the Alaska Flora informatics project (w3id.org/akflora;\n"     \
    "     2008-2022), providing mappings to the current FNA website page,\n" \
    "     and information about the name's status as synonym or basionym.\n" \
    "     One new object property is introduced to simplify the modeling of\n" \
    "     synonyms (cf. the TDWG TCS taxon concept approach). FNA = Flora\n" \
    "     of North America Editorial Committee, eds. 1993+. Flora of North\n" \
    "     America North of Mexico. 19+ vols.  New York and Oxford.\"\"\" ;\n" \
    "  dc:title \"Flora of North America names\" ;\n"                   \
    "  dct:issued \"2022-06-28\" .\n"                                   \
    "  # dct:modified \"2015-07-01\" ;\n"                               \
    "\n"                                                                \
    ":fnasyn\n"                                                         \
    "  a owl:ObjectProperty ;\n"                                        \
    "  rdfs:label \"is synonym for\" ;\n"                               \
    "  rdfs:comment \"\"\"The current name is considered by the FNA treatment\n" \
    "    author to be a synonym of the target, accepted name.  The\n"   \
    "    relationship may be nomenclatural or a taxon concept relationship\n" \
    "    (see http://rs.tdwg.org/ontology/voc/TaxonConcept#IsSynonymFor).\"\"\" ;\n" \
    "  rdfs:domain tn:TaxonName ;\n"                                    \
    "  rdfs:range tn:TaxonName ;\n"                                     \
    "  rdfs:isDefinedBy <http://w3id.org/akflora/sw/fna-names.rdf> .\n"
}
