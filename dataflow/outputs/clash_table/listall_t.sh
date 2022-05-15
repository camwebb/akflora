source ../ENV.sh

# # Now fixed in G2F

# # Fix a few errors in g2f
# # 1. check for Plantlist duplicate genera with:
# #   gawk 'BEGIN{FS="|"; while ((getline < "g2f")>0) d[$1]=$4; FS="\t"; while ((getline < "list.csv")>0) { split($2,x," "); if (d[x[1]]>1) print x[1]}}' | uniq
# # Bassia says Sapot
# # Mertensia OK
# # Alliaria
# # Honckenya
# # Wilhelmsia
# # Urtica OK
# # Ugh - Lobaria in ACCS is a lichen, in WCSP is an A in Saxifrag
# #     - need to remake ACCS with just seed plants
# mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
#      -e "UPDATE g2f SET fam = 'Amaranthaceae' WHERE gen = 'Bassia';
#          UPDATE g2f SET fam = 'Brassicaceae' WHERE gen = 'Alliaria';
#          UPDATE g2f SET fam = 'Caryophyllaceae' WHERE gen = 'Honckenya';
#          UPDATE g2f SET fam = 'Caryophyllaceae' WHERE gen = 'Wilhelmsia';
#          UPDATE g2f SET class = 'B' WHERE gen = 'Lobaria';" \
#       akflora



mysql -N --show-warnings -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD \
     akflora < listall_t.sql > list.csv

gawk '
  BEGIN{
    FS="\t"
  }
  {
    gsub(/`/,"\x27",$0)
    gsub(/#/,"\\",$0)
    gsub(/NULL/,"",$0)
    gsub(/&/,"\\\\&",$0)
    gsub(/_/," ",$0)
    # gsub(/ACCS/,"A",$0)
    if (fam != $1) {
      print " & & & & & & & & & & & & \\\\"
      print " & {\\bf " toupper($1) "} & & & & & & & & & & & \\\\"
      print " & & & & & & & & & & & & \\\\"
      fam = $1
    }
    split($4,AK,",")
    ak_paf = ak_fna = ak_gbif = ak_accs = " "
    for (i in AK) {
      if      (AK[i] == "FNA")  ak_fna = "F"
      else if (AK[i] == "PAF")  ak_paf = "P"
      else if (AK[i] == "GBIF") ak_gbif = "G"
      else if (AK[i] == "ACCS") ak_accs = "A"
    }
    split($5,AC,",")
    ac_paf = ac_fna = ac_accs = ac_foak = ac_hulten = ac_ala = " "
    for (i in AC) {
      if      (AC[i] == "FNA")    ac_fna = "F"
      else if (AC[i] == "PAF")    ac_paf = "P"
      else if (AC[i] == "ACCS")   ac_accs = "A"
      else if (AC[i] == "FoAK")   ac_foak = "$*$"
      else if (AC[i] == "Hulten") ac_hulten = "H"
      else if (AC[i] == "ALA")    ac_ala = "a"
    }
    print ac_foak " & \\hangindent=1em {\\bf " $2 "} & " $3 " & " ak_accs " & " ak_paf " & " ak_fna " & " ak_gbif " & " ac_accs " & " ac_paf " & " ac_fna " & " ac_hulten " & " ac_ala " & \\hangindent=1em " gensub(/ACCS/,"A","G",$6) "\\\\" # \\hline
  }
  ' list.csv > list_t.tex

pdflatex listall_t.tex

# pandoc -s -o FoA_names_list.pdf -M geometry='margin=1.2in' -M fontfamily=palatino list.md

# rm -f list.md list.csv

