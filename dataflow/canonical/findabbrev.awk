@load "aregex"

BEGIN{
  FS=OFS="|"

  while ((getline < "../FNA/fna") > 0) {
    $8 = gensub(/[^A-ZÁÉŠ]([A-ZÁÉŠ])\. +/,"\\1.","G",$8)
    gsub(/[)(&,\]\[]/," ",$8)
    split($8,a," +")
    for (i in a)
      if (a[i] !~ /\.$/)
        if (length(a[i]) > 4) 
          long[a[i]]++
  }

  while ((getline < "canon") > 0) {
    $8 = gensub(/[^A-ZÁÉŠ]([A-ZÁÉŠ])\. +/,"\\1.","G",$8)
    gsub(/[)(&,\]\[]/," ",$8)
    split($8,a," +")
    for (i in a)
      if (a[i] ~ /\.$/)
        if (length(a[i]) > 2) 
          abbrev[a[i]]++
  }


  for (i in abbrev) 
    for (j in long) 
      # if (amatch(j, gensub(/\./,"\\.", "G", substr(i,1,length(i)-1)), 1))
      if(j ~ gensub(/\./,"\\.", "G", substr(i,1,length(i)-1)))
        print gensub(/\./,"\\\\. ?","G",j), i
  
  
  # for (i in long) print i
  # for (i in l) print i, l[i]
  #n = asort(l)
  #for (i = 1; i <= n; i++) print l[i]
}
