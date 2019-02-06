BEGIN{
  FS="|";
  OFS="|";
}
{
  # print "  -> "$0;
  syn = "accepted";
  if ($2 != $1) syn = "synonym";
  ++i;
  print "",  parsename($1) , "", parsename($2) , syn , $3 , $4, $5 ;
  
}

function parsename(instring,          words, word, gen, sphyb, sp, subtype, subtaxon, auth, i ) {
  
  words = split(instring,word,/\ \ */);
  gen = sphyb = sp = subtype = subtaxon = auth = "";
  i = 0;
  gen = word[++i];
  if (tolower(word[i+1]) == "x") {
    # a hybrid
    sphyb = "×";
    i++;
  }
  sp = word[++i];
  
  # is is a ssp etc?
  # if (match(instring,/(subsp\.|var\.)/)) {
  if (match(instring,/\ subsp\.\ /)) subtype = "subsp.";
  if (match(instring,/\ var\.\ /)) subtype = "var.";
  if (subtype) {
    # print "   " subtype;
    while (word[++i] != subtype) {}
    subtaxon = word[++i];
  }
  while (i < words-1) {
    # print "   " i " -> " word[i+1]; 
    auth = auth word[++i] " ";
  }
  auth = auth word[++i];
  return gen "|"  sphyb "|"  sp "|"  subtype "|"  subtaxon "|"  auth ; # "|" tolower(gensub(/[ .]/,"","G",auth));

}
