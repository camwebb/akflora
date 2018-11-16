
function depunct(x) {
  # See here for data: 
  # https://code.activestate.com/recipes/251871-latin1-to-ascii-the-
  #   unicode-hammer/
  # https://stackoverflow.com/questions/1382998/latin-1-to-ascii#1383721
  gsub(/[ùúûü]/,"u", x);
  gsub(/[Ñ]/,"N", x);
  gsub(/[ÀÁÂÃÄÅ]/,"A", x);
  gsub(/[ìíîï]/,"i", x);
  gsub(/[ÒÓÔÕÖØ]/,"O", x);
  gsub(/[Ç]/,"C", x);
  gsub(/[æ]/,"ae", x);
  gsub(/[Ð]/,"D", x);
  gsub(/[ýÿ]/,"y", x);
  gsub(/[ÈÉÊË]/,"E", x);
  gsub(/[ñ]/,"n", x);
  gsub(/[àáâãäå]/,"a", x);
  gsub(/[òóôõöø]/,"o", x);
  gsub(/[ß]/,"b", x);
  gsub(/[ÙÚÛÜ]/,"U", x);
  gsub(/[Þþ]/,"p", x);
  gsub(/[ç]/,"c", x);
  gsub(/[ÌÍÎÏ]/,"I", x);
  gsub(/[ð]/,"d", x);
  gsub(/[èéêë]/,"e", x);
  gsub(/[Æ]/,"Ae", x);
  gsub(/[Ý]/,"Y", x);

  # for using "agrep -w" there can only be alphanumerics and underscore
  # the only key non-punct characters to maintain are "()"
  gsub (/[()]/,"_",x)
  # and "&"
  # [ was: gsub (/\ and\ /," \\& ", x); ]
  gsub (/(\ and\ |&)/,"_",x)
  # Now delete spaces and periods, and all other punctuation:
  gsub(/[^A-Za-z0-9_]/,"", x)
  # [ was gsub(/[ .]/,"", x) ; gsub(/"/,"", x) ]

  # test
  if (x ~ /[^A-Za-z0-9_]/) print "Warning: non al-num in x: " x
  
  return tolower(x);
}

