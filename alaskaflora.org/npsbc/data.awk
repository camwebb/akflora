BEGIN{
  FS="\t"
}

($2) {
  split($2, x, ":")
  for (i in x)
    guid[gensub(/.*\[ (H[0-9]+) \].*/,"\\1","G",x[i])] =  $1
}

END {
  PROCINFO["sorted_in"] = "@ind_str_asc"
  out = "var bc = ["
  for (i in guid)
    out = out "\"" i "\","
  gsub(/,$/,"",out)
  print out "];"

  out = "var guid = ["
  for (i in guid)
    out = out "\"" guid[i] "\","
  gsub(/,$/,"",out)
  print out "];"
}
