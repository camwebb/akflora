#!/usr/bin/gawk -f

@load "json" 

BEGIN {
  # 2022-03-17 switch to GNV - seems GNR is no longer actively developed

  # make JSON payload  
  load = "{\"nameStrings\": ["
  while ((getline < INFILE)>0)
    load = load "\"" $0 "\","
  gsub(/,$/,"",load)
  load = load "],\"preferredSources\":[165,167],\"withAllMatches\": true}"
  print load > (INFILE ".json" )
  close(INFILE ".json" )
  
  RS="\x04"
  cmd = "curl -H 'Content-Type: application/json; charset=UTF-8' -s -X POST " \
    "--data @" INFILE                                                   \
    ".json 'https://verifier.globalnames.org/api/v0/verifications'"
  # print cmd > "/dev/stderr"
  cmd | getline json
  close("cmd")
  # print json > "gnv.json" ; close("gnv.json")
  
  # getline json < "gnv.json"
  
  if (! json::from_json(json, data)) {
    print "JSON import failed!" > "/dev/stderr"
    exit 1
  }
  
  for (i in data["names"])
    if (isarray(data["names"][i]["results"]))
      for (j in data["names"][i]["results"])    
        if ((data["names"][i]["results"][j]["dataSourceId"] ~ /^(165|167)$/) \
            &&                                                          \
            (data["names"][i]["results"][j]["matchType"] ~ /^(Exact)$/))
          print_out(i, j)
  
  system("rm " INFILE ".json")
}

function print_out(i, j,    prefix) {

  OFS="|"
  if (data["names"][i]["results"][j]["dataSourceId"] == "165")
    prefix = "trop-"
  else if (data["names"][i]["results"][j]["dataSourceId"] == "167")
    prefix = "ipni-"
  
  print data["names"][i]["name"], \
    (prefix data["names"][i]["results"][j]["recordId"]),    \
    data["names"][i]["results"][j]["matchedName"],          \
    data["names"][i]["results"][j]["matchType"]
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
