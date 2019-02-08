#!/usr/bin/gawk -f

@load "json" 

BEGIN {

  RS="\x04";
  OFS="|";
  system("rm -f to_check.csv");

  cmd = "curl -s -X POST --data-urlencode 'data_source_ids=165|167' --data-urlencode data@" INFILE " 'http://resolver.globalnames.org/name_resolvers.json'";
  
  # print cmd > "/dev/stderr"
  cmd | getline json;
  # print json >> "gnr.json";
  # close("gnr.json");

  if (! json_fromJSON(json, data)) {
    print "JSON import failed!" > "/dev/stderr"
    exit 1
  }

  for (i in data["data"]) {
    if (data["data"][i]["is_known_name"]) {
      for (j in data["data"][i]["results"]) {
        if ((data["data"][i]["results"][j]["data_source_id"] ~ /165|167/) && \
            (data["data"][i]["results"][j]["match_type"] ~ /[12345]/)) {
          print_out(i, j)
        }
      }
    }
  }
  # walk_array(data, "data");
}

function print_out(i,j,     uid) {
  
  if (data["data"][i]["results"][j]["data_source_id"] == 167)
    uid = "ipni-" data["data"][i]["results"][j]["taxon_id"];
  else if (data["data"][i]["results"][j]["data_source_id"] == 165)
    uid = "trop-" gensub(/http\:\/\/www\.tropicos\.org\/Name\//,"","G", \
                         data["data"][i]["results"][j]["url"])
  
  print data["data"][i]["supplied_id"] ,     \
    data["data"][i]["supplied_name_string"], \
    uid, 
    data["data"][i]["results"][j]["name_string"], \
    "GNR" data["data"][i]["results"][j]["match_type"],      \
    "GNR: " data["data"][i]["results"][j]["match_value"] ;
  
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
