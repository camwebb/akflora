BEGIN{
  FS="|";
  OFS="|";
  PROCINFO["sorted_in"] = "@ind_str_asc";
}
{
  key =  $2 $3  $4  $5  $6  $7  $8 ;
  key2 = $9 $10 $11 $12 $13 $14 $15 ;
  namelist[key]++;

  # checks
  if ((key != key2) && ($16 == "accepted")) print "fail: " key " != " key2 " but " $16;
  if ((key == key2) && ($16 == "synonym")) print "fail: " key " == " key2 " but " $16;
  
  if ($16 == "accepted") {
    acctest[key]++;
    acc[key]=1;
  }

  # add n:
  n[key] = ++i;

  # lookup
  s2a[key] = key2;

  # data
  xgen[key] = $2;
  gen[key] = $3;
  xsp[key] = $4;
  sp[key] = $5;
  typ[key] = $6;
  ssp[key] = $7;
  auth[key] = $8;

  status[key] = $16;
  inak[key] = $17;
  comm[key] = $18;
  ref[key] = $19;

}

END{
  # test for uniq first name
  for (i in namelist)
    if (namelist[i]>1)
      print "fail: " i , namelist[i]

  # test for single accepted
  for (i in acctest)
    if (acctest[i]>1)
      print "fail: " i , acctest[i]

  # make lookup table
  for (i in namelist) 
    if (!acc[i])
      ns2a[i] = n[s2a[i]];

  # output names:
  for (i in namelist) print "ala-" n[i],  xgen[i], gen[i], xsp[i], sp[i], typ[i], ssp[i], auth[i] >> "ala-names-tmp.csv" ;

  for (i in namelist) {
    if (acc[i]) print "ala-" n[i], status[i], inak[i], comm[i], ref[i], "" >> "ala-rel-tmp.csv" ;
    else print "ala-" n[i], status[i], inak[i], comm[i], ref[i], "ala-" ns2a[i] >> "ala-rel-tmp.csv" ;
  }
}
  
