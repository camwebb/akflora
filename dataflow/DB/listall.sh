source ../ENV.sh

# Fix a few errors in g2f
# 1. check for Plantlist duplicate genera with:
#   gawk 'BEGIN{FS="|"; while ((getline < "g2f")>0) d[$1]=$4; FS="\t"; while ((getline < "list.csv")>0) { split($2,x," "); if (d[x[1]]>1) print x[1]}}' | uniq
# Bassia says Sapot
# Mertensia OK
# Alliaria
# Honckenya
# Wilhelmsia
# Urtica OK
# Ugh - Lobaria in ACCS is a lichen, in WCSP is an A in Saxifrag
#     - need to remake ACCS with just seed plants
mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     -e "UPDATE g2f SET fam = 'Amaranthaceae' WHERE gen = 'Bassia';
         UPDATE g2f SET fam = 'Brassicaceae' WHERE gen = 'Alliaria';
         UPDATE g2f SET fam = 'Caryophyllaceae' WHERE gen = 'Honckenya';
         UPDATE g2f SET fam = 'Caryophyllaceae' WHERE gen = 'Wilhelmsia';
         UPDATE g2f SET class = 'B' WHERE gen = 'Lobaria';" \
      akflora

mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     akflora < listall.sql > list.csv

gawk '
  BEGIN{
    FS="\t"
    ORS = ""
    print "---\n"
    print "title: \\bf List of Alaskan Seed Plant names\n"
    print "subtitle: Compiled from ALA, ACCS, PAF, WCSP, FNA\n"
    print "author: C. Webb\n"
    print "date: \\today\n---\n\n"
    print "\\raggedright\n\n"
  }
  {
    gsub(/`/,"\x27",$0)
    if (fam != $1) {
      print "# " $1 "\n\n"
      fam = $1
    }
    n[$2]++
    print "**" $2 "** (GUID: " $3 "). In Alaska according to **" \
      gensub(/,/,"**, **","G",$4) "**" \
      ". An _accepted name_ according to **" gensub(/,/,"**, **","G",$5) "**."
    if ($6 != "NULL") 
      print " A _synonym_ of:\n\n * " gensub(/\\n/,"\n * ","G",$6) "\n"
    else { print "\n" ; nosyn++ }
    print "\n"
  }
  END{ print "# Totals\n\nTotal " NR " names. Names without synonyms: " nosyn "\n" }
  ' list.csv > list.md

pandoc -s -o FoA_names_list_2020-01-02.pdf -M geometry='margin=1.2in' -M fontfamily=palatino list.md

rm -f list.md list.csv

