BEGIN{
  PROCINFO["sorted_in"] =  "@ind_str_asc"
  use = 26
  a="abcdefghijklmnopqrstuvwxyz"
  # this will find diacritics too, under the base letter, e.g.,
  # Adenoïdes is found by: Adenoi*
  
  for (i = 1; i <= use; i++)
    for (j = 1; j <= use; j++)
      st[2][substr(a,i,1) substr(a,j,1)]++

  # 2 chars = 676 calls
  for (i in st[2])
    callING(i)
  
  # redo for 300+ in 2chars
  if (length(st[3]))
    for (i in st[3])
      for (j = 1; j <= use; j++)
        callING(i substr(a,j,1))

  # redo for 300+ in 3chars - just in case
  if (length(st[4]))
    for (i in st[4])
      for (j = 1; j <= use; j++)
        callING(i substr(a,j,1))
  
  for (i in g) print i > "ING_list"
  
}
    
function testFile(file ,    test, cmd) {
  RS="\n"    
  cmd = "ls " file " 2> /dev/null"
  cmd | getline test
  close(cmd)
  if (test == file) return 1
  else return 0
}
    
function callING(x     , i, cmd, out, n, tmp, j) {
  # public -> g[], st[][]

  cmd = "curl -s --data-urlencode 'searcher=' --data-urlencode \
         'SearchWord=" x "*' --data-urlencode 'mychoice=genus'          \
         https://naturalhistory2.si.edu/botany/ing/INGsearch.cfm        \
        | grep '<B>' | sed -E -e 's|^.*<B>([^<]+)</B>.*$|\\1|g'"
  RS="\x04"
  cmd | getline out
  if(close(cmd) == -1) print "not closed" > "/dev/stderr"
  # monitor with "lspf | grep curl" 
  n = split(out,tmp,"\n")
  if (!n) n = 1
  if (n > 1)
    print x " " n-1 > "/dev/stderr"
  for (j = 1; j < n; j++) {
    g[tmp[j]]++
  }
  delete tmp

  if (n >= 300) {
    st[length(x)+1][x]++
    if (length(x) == 3) {
      print "  Warning, " x " has >= 300 lines. Will add another char." \
        > "/dev/stderr"
    }
  }
}
