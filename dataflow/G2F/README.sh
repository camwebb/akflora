
source ../ENV.sh

# 0. Starting list of genera from the DB
# echo "select distinct genus from names, ak where names.id = ak.nameID and ak.in_ak = 1;" | mysql -u XXX -pXXX akflora | sort > akflora_g

echo "Genera in base list:" 
wc akflora_g

# 1. get APG4 from the publication

echo "59c59
< 36. *Maundiaceae Nakai 
---
> 36 []. *Maundiaceae Nakai 
425c425
< 318 [—].*Nyssaceae Juss. ex Dumort., nom. cons. 
---
> 318 [—]. *Nyssaceae Juss. ex Dumort., nom. cons. 
509c509
< 384 [—].*Mazaceae Reveal 
---
> 384 [—]. *Mazaceae Reveal " > p1.patch

patch -o apg2016_appendix.2 sources/apg2016_appendix p1.patch

gawk '{
  gsub(/[*‘’]/,"",$0)
  if ($1 ~ /ales$/)
    order = $1
  else if ($3 ~ /aceae$/)
    print $1 "|" $3 "|" order }' \
     apg2016_appendix.2 | sort -n > apg4_f2o

echo "Check: 416 lines in f2o:"
wc apg4_f2o

rm apg2016_appendix.2 p1.patch

# 2. get PPG from the publication

gawk '$1 == "Order" { order = $2 }
      $1 == "Family" { fam = $2 }
      $0 ~ /^            / { print $1 "|" fam "|" order }' \
     sources/ppg_classification > ppg_g2o

echo "Check: 337 lines in ppg_g2o:"
wc ppg_g2o

# 3. Get Kew Plant List hierarchy (contains errors, e.g.,
# Bassia|Sapotaceae, Alliaria|Meliaceae, Honckenya|Malvaceae,
# Lobaria|Saxifragaceae|A)

cp ../WCSP/g2f kew_g2f

# 4. Get ACCS classification

echo "select genusAccepted, family, category
      from hierarchy, family, category where 
        hierarchy.familyID = family.familyID and 
        category.categoryID = hierarchy.categoryID 
        order by category, family, genusAccepted;" | \
  mysql -N -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD alaskaFlora \
  | tr "\t" "|" | sed -E -e 's/\|Eudicot$/|A/g' \
                      -e 's/\|Monocot$/|A/g' \
                      -e 's/\|Gymnosperm$/|G/g' \
                      -e 's/\|Fern$/|P/g' \
                      -e 's/\|Horsetail$/|P/g' \
                      -e 's/\|Lycopod$/|L/g' \
                      -e 's/\|Quillwort$/|L/g' \
                      -e 's/\|Moss$/|B/g' \
                      -e 's/\|Hornwort$/|B/g' \
                      -e 's/\|Liverwort$/|B/g' \
                      -e 's/\|Algae$/|C/g' \
                      -e 's/\|Lichen$/|F/g' \
                      > accs_g2f 

# https://en.wikipedia.org/wiki/Embryophyte
# 
#     A --+
#         |--+ seed
#     G --+  |
#            |--+ 
#     P -----+  |
#               |--+ vasc
#     L --------+  |
#                  |--+ land
#     B -----------+  |
#                     |---- . . . . . . -- F(ungi + lichens)
#     C --------------+ charophyta

# 5. test base list, against ACCS

echo "How many genera in base list not in accs?"
gawk 'BEGIN{FS=OFS="|"; 
      while ((getline < "accs_g2f")) f[$2]++; 
      while ((getline < "akflora_g") > 0) 
        if (!f[$2]) print $2}' | wc

# 408 genera names not in ACCS

# ACCS fams vs APG4

echo "Which ACCS families are not in APG4?"

gawk 'BEGIN{FS=OFS="|"; while ((getline < "apg4_f2o")) f[$2]++; while ((getline < "accs_g2f") > 0) if (!f[$2] && ($3 ~ "cot")) print $2}' | sort | uniq

# Alliaceae
# Fumariaceae
# Hydrophyllaceae
# Linnaeaceae
# Parnassiaceae
# Ruscaceae
# Sparganiaceae
# Valerianaceae

# against kew list (but kew list has no lichen)

echo "How many genera in base list not in Kew list?"

gawk 'BEGIN{FS=OFS="|"; 
      while ((getline < "kew_g2f")) g[$1]++; 
      while ((getline < "akflora_g") > 0) 
        if (!g[$1]) print $1}' | sort

# 254 genera names not in Kew

# 6. Integrate

echo "Intgrating..."
gawk 'BEGIN{FS=OFS="|"; 
      while ((getline < "kew_g2f"))  { f[$1]=$2;c[$1]=$3; if ($4) w[$1]="K" } 
      while ((getline < "accs_g2f")) { f2[$1]=$2;c2[$1]=$3 } 
      while ((getline < "ppg_g2o"))  { f3[$1]=$2 }
      while ((getline < "apg4_f2o")) { a[$2]=1  }
      while ((getline < "akflora_g") > 0) { 
        F = C = S = W = "" ; g = $1
        # ferns
        if (f3[g]) { F = f3[g]; C = "P" ; S = "ppg" }
        # kew only (no lichens)
        else if (f[g] && !f2[g]) {F=f[g]; C=c[g]; S="kew"; W=w[g] }
        # accs only
        else if (!f[g] && f2[g]) {F=f2[g]; C=c2[g]; S="accs" }
        # both agree (can disregard warning in kew list)
        else if (f[g] && f2[g] && (f[g] == f2[g])) {F=f2[g]; C=c2[g]; S="both"}
        # disagree (may be due to errors in kew list)
        else if (f[g] && f2[g] && (f[g] != f2[g])) 
          {F=f2[g]; C=c2[g]; S="diff(" f[g] "/" f2[g] ")"; W = w[g] "D" }
        # check fams are in APG
        if (F && (C == "A") && !a[F]) W = W "A"
        if (!F) W = W "F"
        print g,  F, C, S, W
      }}' > g2f.1

# grep -E "[A-Z]$" g2f.1 > g2f_fixes
# emacs g2f_fixes

# For accepted names, there can only be one genus-to-family
# relationship. Therefore if there is at least one accepted name in a
# genus, the family of that species is used for the whole genus, even
# if it contains synonyms that are now in a different family.  For
# genera that no longer contain any accepted names, and for which the
# species are synonyms of species in several families, one family is
# chosen in an attempt to indicate the family of the majority of
# synonym species. E.g., Acetosella: Oxalidaceae and Polygonaceae, but
# Oxalidaceae seems dominant.
#
# Where there is a difference between families of accepted names in
# the Kew list and ACCS, generally follow ACCS. 

# Combine

gawk 'BEGIN{FS=OFS="|"; 
      while ((getline < "g2f.1"))     { f[$1]=$2;c[$1]=$3 }
      while ((getline < "g2f_fixes")) { f[$1]=$2;c[$1]=$3 }
      for (i in f) print i, f[i], c[i] }' | sort > g2f

rm accs_g2f g2f.1 kew_g2f

