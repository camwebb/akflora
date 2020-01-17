
@include "taxon-tools.awk"

BEGIN{
  FS=OFS="|"
  PROCINFO["sorted_in"] = "@ind_str_asc"
  fix5A = "854|2123|3486|5009|8130"
  split(fix5A,fix5B,"|"); for (i in fix5B) fix5[fix5B[i]]=1;
  fix1A = "5451"
  split(fix1A,fix1B,"|"); for (i in fix1B) fix1[fix1B[i]]=1;
  killA = "4987|4988|4989|4990|4992|4993|4998|9935|9937|1709|3282|3283|3784|3804|13066|1699|1701|1709|1712|1715|1722|3774|13066|3786|3789|4951|8593|12673|1711"
  split(killA,killB,"|"); for (i in killB) kill[killB[i]]=1;
}

(!kill[$1]) {
  # Clean names
  gsub(/ +$/,"",$2)
  gsub(/ +$/,"",$5)

  # fix errors: incorrect accepted, e.g.
  # 2123|Bryoria trichodes subsp. trichodes (Michx.) Brodo & D. Hawksw.|1|695|\
  #   Bryoria trichodes (Michx.) Brodo & D. Hawksw.|CNALH
  # 854|Antirrhinum orontium L.|1|2883|Misopates orontium (L.) Raf.|ITIS
  # this is a synonym (5) not an accepted (1)
  if (fix5[$1]) $3 = 5
  if (fix1[$1]) $3 = 1
  
  # fix the case of accepted names where $2 != $5
  # 4647|Elymus violaceus (Hornem.) Böcher ex J. Feilberg|1|1763|\
  #   Elymus violaceus (Hornem.) Feilberg|Panarctic Flora Checklist
  # "(Hornem.) Böcher ex J. Feilberg" != "(Hornem.) Feilberg"

  # if accepted, but the names are diff (and not errorss, as above)
  if (($3 == 1) && ($2 != $5)) {
    # re-write the adjudicated name
    print "swapped: " $1, $2, $5 > "/dev/stderr"
    $2 = $5
  }

  # test that each species string occurs only once
  if (++c2[$2] > 1) print $2 " (adjID = " $1 " ) is a dup " c2[$2]  \
                      > "/dev/stderr"
  
  id_of_name[$2]=$1     # syn ID
  status[$2] = $3       # 1 = accepted, 5 = syn
  accepted_name[$2]=$5  # acc name
  src[$2]=$6            # source

  # test: if there is already an index of a of the accepted name'id_of_name id
  # and if that id is not the same as $4
  if (a[$5]) {
    if (a[$5] != $4) { 
      print $5 " (acc) is not consistent with IDs " a[$5] " vs. " $4    \
        > "/dev/stderr"
    }
  }
  else a[$5]=$4 # load the code of the accepted name
}

END{

  # for (i in status) test[status[i]]++
  # print "5 = " test["5"]
  # print "1 = " test["1"]
  # 5 = 7794 names
  # 1 = 3840 names

  # how to fix this?
  # 217|Agropyron latiglume (Scribn. & J.G. Sm.) Rydb.|5|1763|\
  #   Elymus violaceus (Hornem.) Feilberg|Panarctic Flora Checklist
  #4647|Elymus violaceus (Hornem.) Böcher ex J. Feilberg|1|1763|\
  #   Elymus violaceus (Hornem.) Feilberg|Panarctic Flora Checklist
  # fixed above, overwriting name 1 where status = accepted and names differ

  # main: first parse the names, using the unparse names as keys
  # for each name string in the adjudicated table
  for (i in id_of_name) {
    # parse it
    pn[i] = parse_taxon_name(i, 1)
    pn2[accepted_name[i]] = parse_taxon_name(accepted_name[i], 1)
    # if that succedes for both the syn and the acc
    if (!pn[i] || !pn2[accepted_name[i]])
      print id_of_name[i] > "/dev/stderr"
    if (pn[i] && pn2[accepted_name[i]]) {
      listed[i]++
      listed[accepted_name[i]]++
    }
  }

  # wc
  # 11634  119144 1245159 accs.1
  # 11601   43633 1043578 accs.2 # 33 failures to parse

  # TODO: add code here to drop misapplied names and their synonyms
  
  for (i in id_of_name)
    if (listed[i])
      # only print those for which both the name and syn are present
      
      if (status[i] == 1)
        print "accs-" id_of_name[i], pn[i] , "accepted", \
          "accs-" id_of_name[i], src[i]
      else if (status[i] == 5)
        # 2020-01-15: originally I just used 1 and 5 in the SQL, but
        #   commented this out.  A comment was added here "now
        #   includes name misapplied, etc", with as simple `else, but
        #   I'm not sure why I decided to do this. After the list was
        #   checked by Timm, it is clear that I need to limit it to
        #   just true synonyms
        print "accs-" id_of_name[i], pn[i] , "synonym", "accs-" id_of_name[accepted_name[i]], src[i]

  # Finally, this would not parse, so add
  print "accs-12673||Uva-Ursi||uva-ursi|||(L.) Britton|synonym|accs-1051|Panarctic Flora Checklist"
  
}



# 12673|Uva-Ursi uva-ursi (L.) Britton|5|310|Arctostaphylos uva-ursi (L.) Spreng.|Panarctic Flora Checklist



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
