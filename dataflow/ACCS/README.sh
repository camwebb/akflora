# The Comprehensive checklist of Alaska Center for Conservation
# Science (ACCS) was developed by Timm Nawrocki, Matt Carlson and
# Justin Fulkerson. It appears on the <https://floraofalaska.org/>
# website and is a key building block of the new Flora of Alaska.

# 2022-04-26: The ACCS list is in the process of becoming the Flora of
# Alaska Checklist. Numerous opinions from the Flora of Alaska
# Taxonomy Sub-committee are now included.

rm -f accs

# test:

gawk 'BEGIN{FS="|"}
      $4 == 1 && $1 != $5 \
        {print $1 ": status = accepted but code != code_accepted"}
      $4 == 9 && $1 == $5 \
        {print $1 ": status = synonym but code == code_accepted"}
      {if (++c[$1] > 1) print $1 ": duplicate code"}' \
        v2/taxon_all.psv
     
gawk '
  BEGIN{
    FS=OFS="|"
    while ((getline < "v2/author.psv")>0) 
      auth[$1] = $2        
    while ((getline < "v2/taxon_source.psv")>0) 
      s[$1] = $2        
    while ((getline < "v2/taxon_accepted.psv")>0) 
      src[$1] = s[$5]        
    while ((getline < "v2/taxon_all.psv")>0)
      # no genera:
      if (match($2,/ /)) {
        if ($4 == 1)
          print $1, $2, auth[$3], "accepted", $1, src[$1]
        else if ($4 == 9)
          print $1, $2, auth[$3], "synonym", $5, src[$5]
      }
  }' > accs.1

# Fixes.

# failing in parsenames:
# Muellerella lichenicola (Sommerf.: Fr.) D. Hawksw.
# Petasites frigidus subsp. ×vitifolius (Greene) Chern.
# Petasites frigidus var. ×vitifolius (Greene) Cherniawsky & R.J. Bayer
# ThelIdium methorium (Nyl.) Hellb.
# Uva-Ursi uva-ursi (L.) Britton

sed -i -E \
    -e 's/ ssp\. / subsp. /g' \
    -e 's/Sommerf\.:/Sommerf./g' \
    -e 's/subsp\. ×vitifolius/subsp. vitifolius/g' \
    -e 's/var\. ×vitifolius/var. vitifolius/g' \
    -e 's/ThelIdium methorium/Thelidium methorium/g' \
    -e 's/Uva-Ursi uva-ursi/Uvaursi uvaursi/g'    accs.1

gawk '
  @include "taxon-tools.awk"
  BEGIN{FS=OFS="|"}
  {
    gsub(/  */," ", $2)
    gsub(/( *$|^ *)/, "", $2)
    # some rank label fixing:
    gsub(/ ssp\. /, " subsp. ", $2)
    print $1, parse_taxon_name(($2 " " $3), 1)
  }' accs.1 > accs

# Unfix
sed -i -E -e 's/Uvaursi\|\|uvaursi/Uva-ursi||uva-ursi/g' accs

gawk 'BEGIN{FS=OFS="|"}{print $1, $5, $4, $6}' accs.1 > accs_rel

rm accs.1

