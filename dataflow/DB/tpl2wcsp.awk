BEGIN{
  FS=OFS="|"
  while ((getline < "../canonical/canon") > 0) g[$3]++

  # there are a few duplicate names
  while ((getline < "tpl") > 0) {
    if (g[$5] && ($14 == "WCSP") && (++uniq[$4 $5 $6 $7 $8 $9 $10]==1)) {
      xg[$1] = $4
      g[$1] = $5
      xs[$1] = $6
      s[$1] = $7
      st[$1] = $8
      ss[$1] = $9
      a[$1] = $10
      stat[$1] = $11
      acc[$1] = $21
      refd[$21]++
    }
  }

  close("tpl")
      
  #  Get (add) the lines in genera that are synonyms, but only if uniq
  while ((getline < "tpl") > 0) {
    if (refd[$1] && (++uniq[$4 $5 $6 $7 $8 $9 $10]==1)) {
      xg[$1] = $4
      g[$1] = $5
      xs[$1] = $6
      s[$1] = $7
      st[$1] = $8
      ss[$1] = $9
      a[$1] = $10
      stat[$1] = $11
      acc[$1] = $21
    }
  }

  for (i in xg) {
    print i, xg[i], g[i], xs[i], s[i], st[i], ss[i], a[i], stat[i], acc[i]
  }
    
  # for (i in gen) {
#     if (acc[i]) {
#       g2g[gen[acc[i]]][gen[i]]++
#       print i, gen[i], acc[i], gen[acc[i]] "\n"
#     }
#   }
#   exit
#   for (i in g2g) {
#     print i " <- "    # $5 " <- " gs[$1] # , $1 # g[$5]++
#     for (j in g2g[i]) print j ", "   
#     print "\n"
#   }
#   # for (i in g) print i
#
}
