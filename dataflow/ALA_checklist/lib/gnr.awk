#!/usr/bin/gawk -f

@load "json" 

BEGIN {

  RS="\x04";
  OFS="|";
  system("rm -f to_check.csv");

  cmd = "curl -s -X POST --data-urlencode 'data_source_ids=165|167|170' --data-urlencode data@" INFILE " 'http://resolver.globalnames.org/name_resolvers.json'";

  # print cmd > "/dev/stderr"
  cmd | getline json;
  # print json >> "gnr.json";
  # close("gnr.json");

  if (! json_fromJSON(json, data)) {
    print "JSON import failed!" > "/dev/stderr"
    exit 1
  }

  for (i in data["data"]) {
    for (j in data["data"][i]["results"]) {
      if (data["data"][i]["results"][j]["data_source_id"] ~ /165|167|170/) {
        found[data["data"][i]["results"][j]["match_type"],          \
              data["data"][i]["results"][j]["data_source_id"]] = j;
      }
    }

    # process
    if (found[1,167]) print_out(i,found[1,167]);
    else if (found[2,167]) print_out(i,found[2,167]);
    else if (found[3,167]) print_out(i,found[3,167]);
    else failIPNI = 1;

    if (found[1,165]) print_out(i,found[1,165]);
    else if (found[2,165]) print_out(i,found[2,165]);
    else if (found[3,165]) print_out(i,found[3,165]);
    else failTROP = 1;

    if (found[1,170]) print_out(i, found[1,170]);
    else if (found[2,170]) print_out(i, found[2,170]);

    if ((failIPNI) && (failTROP)) {
      print data["data"][i]["supplied_id"],            \
        data["data"][i]["supplied_name_string"]        \
        >> "ala-gnr_not_found" ;
      close("ala-gnr_not_found");
    }
    delete found; failIPNI = failTROP = "";
  }
  
#  walk_array(data, "data");
}

function print_out(i,j,     prefix) {
#  print "in: " i ": " data["data"][i]["supplied_id"];
#  print "in: " i ": " data["data"][i]["supplied_name_string"];
#  print "in: " i ": " data["data"][i]["results"][j]["taxon_id"];
#  print "in: " i ": " data["data"][i]["results"][j]["match_value"];
#  print "in: " i ": " data["data"][i]["results"][j]["data_source_title"];
#  print "in: " i ": " data["data"][i]["results"][j]["name_string"] "\n";
  if (data["data"][i]["results"][j]["data_source_id"] == 167) prefix = "ipni";
  else if (data["data"][i]["results"][j]["data_source_id"] == 165) prefix = "trop";
  else if (data["data"][i]["results"][j]["data_source_id"] == 170) prefix = "arct";
  
  print data["data"][i]["supplied_id"] , \
    data["data"][i]["supplied_name_string"], \
    prefix "-" data["data"][i]["results"][j]["taxon_id"], \
    data["data"][i]["results"][j]["name_string"], \
    "GNR" data["data"][i]["results"][j]["match_type"],      \
    "GNR: " data["data"][i]["results"][j]["match_value"] ;

  if (data["data"][i]["results"][j]["match_type"] == 2) {
    if (collapse(data["data"][i]["supplied_name_string"]) ==    \
        collapse(data["data"][i]["results"][j]["name_string"])) {   \
      print data["data"][i]["supplied_id"] ,                        \
        data["data"][i]["supplied_name_string"],                    \
        prefix "-" data["data"][i]["results"][j]["taxon_id"],       \
        data["data"][i]["results"][j]["name_string"],               \
        "COLLEQ", "Collapsed equality" ;
    }
    else {
      # Better to do this from the DB, with rules for author strings
      
      # print data["data"][i]["supplied_id"] ,                \
      #  data["data"][i]["supplied_name_string"],            \
      #  data["data"][i]["results"][j]["name_string"],          \
      #  prefix "-" data["data"][i]["results"][j]["taxon_id"], ""    \
      #  >> "to_check.csv" ;
      # close("to_check.csv") ;
    }
  }
}


function collapse(x) {
  gsub (/\ and\ /," \\& ", x);
  # See here for data: 
  # https://code.activestate.com/recipes/251871-latin1-to-ascii-the-
  #   unicode-hammer/
  # https://stackoverflow.com/questions/1382998/latin-1-to-ascii#1383721
  gsub(/[ùúûü]/,"u", x);
  gsub(/[Ñ]/,"N", x);
  gsub(/[ÀÁÂÃÄÅ]/,"A", x);
  gsub(/[ìíîï]/,"i", x);
  gsub(/[ÒÓÔÕÖØ]/,"O", x);
  gsub(/[Ç]/,"C", x);
  gsub(/[æ]/,"ae", x);
  gsub(/[Ð]/,"D", x);
  gsub(/[ýÿ]/,"y", x);
  gsub(/[ÈÉÊË]/,"E", x);
  gsub(/[ñ]/,"n", x);
  gsub(/[àáâãäå]/,"a", x);
  gsub(/[òóôõöø]/,"o", x);
  gsub(/[ß]/,"b", x);
  gsub(/[ÙÚÛÜ]/,"U", x);
  gsub(/[Þþ]/,"p", x);
  gsub(/[ç]/,"c", x);
  gsub(/[ÌÍÎÏ]/,"I", x);
  gsub(/[ð]/,"d", x);
  gsub(/[èéêë]/,"e", x);
  gsub(/[Æ]/,"Ae", x);
  gsub(/[Ý]/,"Y", x);
  # delete spaces and periods:
  gsub(/[ .]/,"", x)

  # check for missing "×"
  gsub(/×/,"", x)
  return tolower(x);
}


function walk_array(arr, name,      i)
{
  for (i in arr) {
    if (isarray(arr[i]))
      walk_array(arr[i], (name "[" i "]"))
    else
      printf("%s[%s] = %s\n", name, i, arr[i])
  }
}
