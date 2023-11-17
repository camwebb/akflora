BEGIN{
  FS=","
}
NR > 1 {
  i++
  if ($1 ~ /Alg/)
    coll[i] = "a"
  else if ($1 ~ /UAMb/)
    coll[i] = "c"
  else
    coll[i] = "v"
  gsub(/[^0-9]/,"",$1)
  guid[i]       = $1
  bc[i]         = $2
  alaac[i]      = $3
  collinfo[i]   = ($4) ? $4 : 0
  locninfo[i]   = ($5) ? $5 : 0
  georefinfo[i] = ($6) ? $6 : 0
  njpg[i]       = ($7) ? $7 : 0
  ndng[i]       = ($8) ? $8 : 0
}
END{

  printf "var coll = ["
  for (j = 1; j < i; j++)
    printf "\"" coll[j] "\","
  printf "\"" coll[i] "\"];\n"

  printf "var guid = ["
  for (j = 1; j < i; j++)
    printf guid[j] ","
  printf guid[i] "];\n"

  printf "var bc = ["
  for (j = 1; j < i; j++)
    printf "\"" bc[j] "\","
  printf "\"" bc[i] "\"];\n"

  printf "var alaac = ["
  for (j = 1; j < i; j++)
    printf "\"" alaac[j] "\","
  printf "\"" alaac[i] "\"];\n"

  printf "var collinfo = ["
  for (j = 1; j < i; j++)
    printf  collinfo[j] ","
  printf collinfo[i] "];\n"

  printf "var locninfo = ["
  for (j = 1; j < i; j++)
    printf  locninfo[j] ","
  printf locninfo[i] "];\n"

  printf "var georefinfo = ["
  for (j = 1; j < i; j++)
    printf  georefinfo[j] ","
  printf georefinfo[i] "];\n"

  printf "var njpg = ["
  for (j = 1; j < i; j++)
    printf  njpg[j] ","
  printf njpg[i] "];\n"

  printf "var ndng = ["
  for (j = 1; j < i; j++)
    printf  ndng[j] ","
  printf ndng[i] "];\n"

}
