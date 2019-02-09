
@include "taxon-tools.awk"

BEGIN{
  FS=OFS="|"
  PROCINFO["sorted_in"] = "@ind_str_asc"
}
{
  # test:
  c2[$2]++
  if (c2[$2] > 1) print $2 " (adj) is a dup" c2[$2] > "/dev/stderr"
  
  s[$2]=$1
  t[$2]=$3
  l[$2]=$5

  # test:
  if ($3 == 1)
    if ($2 != $5)
      print "acc: " $5 " is not same as " $2 > "/dev/stderr"
  
  # test:
  if (a[$5])
    if (a[$5] != $4)
      print $5 " (acc) is not consistent with IDs " a[$5] " vs. " $4 > "/dev/stderr"
  a[$5]=$4
}

END{
  
  for (i in s) {
    pn = parse_taxon_name(i, 1)
    if (pn)
      if (t[i] == 1)
        print "accs-" s[i], pn , "accepted"
      else
        print "accs-" s[i], pn , "accs-" s[l[i]]
  }
}


# # Some errors in the ACCS DB:
#
# acc: Misopates orontium (L.) Raf. is not same as Antirrhinum orontium L.
# acc: Bryoria trichodes (Michx.) Brodo & D. Hawksw. is not same as Bryoria trichodes ssp. trichodes (Michx.) Brodo & D. Hawksw.
# acc: Cladonia cervicornis (Ach.) Flotow is not same as Cladonia cervicornis ssp. cervicornis (Ach.) Flotow
# acc: Corallorhiza mertensiana Bong., orth. var. is not same as Corallorrhiza mertensiana Bong., orth. var.
# acc: Corallorhiza trifida Chatelain, orth. var. is not same as Corallorrhiza trifida Chatelain, orth. var.
# acc: Elymus violaceus (Hornem.) Feilberg is not same as Elymus violaceus (Hornem.) Böcher ex J. Feilberg
# acc: Coniferous Shrub (blank) is not same as Coniferous Shrub 
# acc: Coniferous Tree (blank) is not same as Coniferous Tree 
# acc: Crustose Lichen (blank) is not same as Crustose Lichen 
# acc: Cryptobiotic Crust (blank) is not same as Cryptobiotic Crust 
# acc: Deciduous Shrub (blank) is not same as Deciduous Shrub 
# acc: Deciduous Tree (blank) is not same as Deciduous Tree 
# acc: Dwarf Shrub (blank) is not same as Dwarf Shrub 
# acc: Eriophorum vaginatum ssp. vaginatum L. is not same as Eriophorum vaginatum var. vaginatum L.
# acc: Papaver croceum Rändel ex D.F. Murray is not same as Papaver nudicaule ssp. nudicaule L.
# acc: Foliose Lichen (blank) is not same as Foliose Lichen 
# acc: Fruticose Lichen (blank) is not same as Fruticose Lichen 
# acc: Protopannaria pezizoides (Weber) P.M. Joerg. & S. Ekman is not same as Protopannaria pezizoides (Weber) P.M. Jørg. & S. Ekman
# acc: Salix pulchra × scouleriana na is not same as Salix pulchra × scouleriana NULL

# These do not parse:
# *  Fail: 'Cornus suecica × canadensis ' does not match:
#          Cornus suecica × canadensis   <- parsed
# *  Fail: 'Fruticose Lichen ' does not match:
#          |Fruticose|||||Lichen   <- parsed
# *  Fail: 'Dwarf Shrub ' does not match:
#          |Dwarf|||||Shrub   <- parsed
# *  Fail: 'Xanthomendoza fallax (Hepp) So?chting, Ka?rnefelt & S. Kondr.' does not match:
#          Xanthomendoza fallax (Hepp) So?chting, Ka?rnefelt & S. Kondr.  <- parsed
# *  Fail: 'Chamaepericlymenum canadense × suecicum ' does not match:
#          Chamaepericlymenum canadense × suecicum   <- parsed
# *  Fail: 'Crustose Lichen ' does not match:
#          |Crustose|||||Lichen   <- parsed
# *  Fail: 'Cornus canadensis × suecica ' does not match:
#          Cornus canadensis × suecica   <- parsed
# *  Fail: 'Cryptobiotic Crust ' does not match:
#          |Cryptobiotic|||||Crust   <- parsed
# *  Fail: 'Betula neoalaskana × glandulosa ' does not match:
#          Betula neoalaskana × glandulosa   <- parsed
# *  Fail: 'Salix pulchra × scouleriana NULL' does not match:
#          Salix pulchra × scouleriana NULL  <- parsed
# *  Fail: 'Chamaepericlymenum canadensis × suecicum ' does not match:
#          Chamaepericlymenum canadensis × suecicum   <- parsed
# *  Fail: 'Coniferous Shrub ' does not match:
#          |Coniferous|||||Shrub   <- parsed
# *  Fail: 'Foliose Lichen ' does not match:
#          |Foliose|||||Lichen   <- parsed
# *  Fail: 'Uva-Ursi uva-ursi (L.) Britton' does not match:
#          |Uva-|||||Ursi uva-ursi (L.) Britton  <- parsed
# *  Fail: 'Eriophorum russeolum x scheuchzeri ' does not match:
#          |Eriophorum||russeolum||×|scheuchzeri   <- parsed
# *  Fail: 'Deciduous Shrub ' does not match:
#          |Deciduous|||||Shrub   <- parsed
# *  Fail: 'Calliergon subsarmentosum Kindb., sensu Ottawa Nat. 23: 137. 1909' does not match:
#          Calliergon subsarmentosum Kindb., sensu Ottawa Nat. 23: 137. 1909  <- parsed
# *  Fail: 'Caloplaca tornoe?nsis H. Magn.' does not match:
#          Caloplaca tornoe?nsis H. Magn.  <- parsed
# *  Fail: 'Deciduous Tree ' does not match:
#          |Deciduous|||||Tree   <- parsed
# *  Fail: 'Coniferous Tree ' does not match:
#          |Coniferous|||||Tree   <- parsed
# *  Fail: 'Subularia aquatica ssp. mexicana G.A. Mulligan & Calder, ined.?' does not match:
#          Subularia aquatica ssp. mexicana G.A. Mulligan & Calder, ined.?  <- parsed
# *  Fail: 'Cetraria fastigata (Del. ex Nyl. in Norrl.) Ka?rnef.' does not match:
#          Cetraria fastigata (Del. ex Nyl. in Norrl.) Ka?rnef.  <- parsed
# *  Fail: 'ThelIdium methorium (Nyl.) Hellb.' does not match:
#          |Thel|||||Idium methorium (Nyl.) Hellb.  <- parsed
# *  Fail: 'Lecidea tornoe?nsis Nyl.' does not match:
#          Lecidea tornoe?nsis Nyl.  <- parsed
# *  Fail: 'Picea glauca x sitchensis ' does not match:
#          |Picea||glauca||×|sitchensis   <- parsed
