#!/usr/bin/gawk -f

@load "json" 

BEGIN {

  RS="\x04";
  OFS="|";
  system("rm -f to_check.csv");

  # ARCTOS is 170. ~Broken 2018-11
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
    for (j in data["data"][i]["results"]) {
      if ((data["data"][i]["results"][j]["data_source_id"] ~ /165|167/) && \
          (data["data"][i]["results"][j]["match_type"] ~ /[123]/)) {
        print_out(i, j)
#        found[data["data"][i]["results"][j]["match_type"],          \
#              data["data"][i]["results"][j]["data_source_id"]] = j;
      }
    }

    # process
    # ah!!! need all 3 match types, so that we can do the matching ourself! 

    # if (found[1,167]) print_out(i,found[1,167]);
    # else if (found[2,167]) print_out(i,found[2,167]);
    # else if (found[3,167]) print_out(i,found[3,167]);
    # else failIPNI = 1;

    # if (found[1,165]) print_out(i,found[1,165]);
    # else if (found[2,165]) print_out(i,found[2,165]);
    # else if (found[3,165]) print_out(i,found[3,165]);
    # else failTROP = 1;

    # # if (found[1,170]) print_out(i, found[1,170]);
    # # else if (found[2,170]) print_out(i, found[2,170]);

    # if ((failIPNI) && (failTROP)) {
    #   print data["data"][i]["supplied_id"],            \
    #     data["data"][i]["supplied_name_string"]        \
    #     >> "ala-gnr_not_found" ;
    #   close("ala-gnr_not_found");
    # }
    # delete found; failIPNI = failTROP = "";
  }
  
#  walk_array(data, "data");
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
