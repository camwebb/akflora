BEGIN{
  FS="|";
  OFS="|";
  PROCINFO["sorted_in"] = "@ind_str_asc";
}
{
  key =  $1 $2 $3  $4  $5  $6  $7 ;
  key2 = $8 $9 $10 $11 $12 $13 $14 ;
  namelist[key]++;

  # checks
  if ((key != key2) && ($16 == "accepted")) print "fail: " key " != " key2 " but " $16;
  if ((key == key2) && ($16 == "synonym")) print "fail: " key " == " key2 " but " $16;
  
  if ($15 == "accepted") {
    acctest[key]++;
    acc[key]=1;
  }

  # add n:
  n[key] = ++i;

  # lookup
  s2a[key] = key2;

  # data
  # previously set to "\\N"
  xgen[key]   = ($1) ? $1 : "" ;
  gen[key]    = ($2) ? $2 : "" ;
  xsp[key]    = ($3) ? $3 : "" ;
  sp[key]     = ($4) ? $4 : "" ;
  typ[key]    = ($5) ? $5 : "" ;
  ssp[key]    = ($6) ? $6 : "" ;
  auth[key]   = ($7) ? $7 : "" ;

  status[key] = ($15) ? $15 : "" ;
  inak[key]   = ($16) ? $16 : "" ;
  comm[key]   = ($17) ? $17 : "" ;
  ref[key]    = ($18) ? $18 : "" ;

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
    if (!acc[i]) {
      ns2a[i] = "ala-" n[s2a[i]]
    }
    else {
      ns2a[i] = "accepted"
    }

  # output names:

  # for (i in namelist) print "ala-" n[i],  xgen[i], gen[i], xsp[i], sp[i], typ[i], ssp[i], auth[i], inak[i] >> "ala-names" ;

  for (i in namelist)
    print "ala-" n[i], xgen[i], gen[i], xsp[i], sp[i], typ[i],  \
      ssp[i], auth[i], ns2a[i]
}

