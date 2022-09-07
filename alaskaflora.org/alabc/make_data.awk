BEGIN{
  FS=","
}
NR > 1 {
  i++
  if ($1 ~ /UAMb/)
    coll[i] = "c"
  else
    coll[i] = "v"
  gsub(/[^0-9]/,"",$1)
  guid[i] = $1
  bc[i] = $2
  if ($3)
    img[i] = "1"
  else
    img[i] ="0"
  if ($4 ~ /^[VLB]?[0-9]+$/)
    alaac[i] = $4
  else
    alaac[i] = "N/A"
}
END{
  printf "var bc = ["
  for (j = 1; j < i; j++)
    printf "\"" bc[j] "\","
  printf "\"" bc[i] "\"];\n"

  printf "var coll = ["
  for (j = 1; j < i; j++)
    printf "\"" coll[j] "\","
  printf "\"" coll[i] "\"];\n"

  printf "var guid = ["
  for (j = 1; j < i; j++)
    printf guid[j] ","
  printf guid[i] "];\n"

  printf "var img = ["
  for (j = 1; j < i; j++)
    printf  img[j] ","
  printf img[i] "];\n"

  printf "var alaac = ["
  for (j = 1; j < i; j++)
    printf "\"" alaac[j] "\","
  printf "\"" alaac[i] "\"];\n"
}
