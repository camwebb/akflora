
# for the whole of AK, the API would not work, max 100,000 records
# not used: ak/gbif_api.sh
# instead download a DWC for Alaska and Tracheophytes
# https://doi.org/10.15468/dl.866vfn
# gawk -f join.awk > gbif_ak.psv

cat ak/gbif_ak.psv yt_extension/yt_extension_gbif_colls > colls
sed -i -E '/^gbifID/d' colls

# remove duplicates ~1000
gawk 'BEGIN{FS="|"}{data[$1]=$0}END{for(i in data)print data[i]}' colls > colls.2
rm colls

# extract names, only species, remove dates 
gawk 'BEGIN{PROCINFO["sorted_in"] = "@val_str_asc"; FS=OFS="|"}{name[$9] = $10; name[$12] = $13}END{for(i in name) if (name[i] ~ /^[^ ]+ [a-z]/) print "gbif-" i, gensub(/, [0-9]{4}$/,"","G",name[i])}' colls.2 > names

parsenames names | gawk 'BEGIN{FS=OFS="|"} NF == 8 {print $0}' > names.2 # 4 fail
rm names

matchnames -a names.2 -b ../canonical/canon -o gbif2canon_match -f -q -m gbif2canon_match_manual

# rel
gawk 'BEGIN{PROCINFO["sorted_in"] = "@ind_str_asc"; FS=OFS="|"; while ((getline < "colls.2")>0) {syn["gbif-" $9] = "gbif-" $12; syn["gbif-" $12] = "gbif-" $12}} {if ($1 == syn[$1]) {print $1,  $1, "accepted" } else print $1, syn[$1], "synonym"}' names.2 > rel

# occurences, if there is a long lat and a det to sp
gawk '
  BEGIN{PROCINFO["sorted_in"] = "@ind_str_asc"
  FS=OFS="|"}
  $16 && $10 ~ /^[^ ]+ [a-z]/ {
    if ($4 == "iNaturalist") { type = "iNat" ; guid = $6 }
      else if ($4 == "UAM")    { type = "UAM" ; guid = $6 }
      else                     { type = "Other" ; guid = "" }
    print "gbo-" $1,
      type,
      guid,
      "gbif-" $9,
      (($17 ~ /^-/) ? ($17 "," $16) : ($16 "," $17))
  }' colls.2 > occ


