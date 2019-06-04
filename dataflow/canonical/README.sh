# Assembling a canonical names list for Alaska

# This list should be _wider_ than just the plants in AK, just the
# accepted, just the correct variants. I.e., make a list that should
# have all the available names in it, or as many as can be picked up
# in canonical form. Sources IPNI > Trop > WCSP (FNA does not have
# GUIDs yet, plus the author citations are not abbreviated, so harder
# to reconcile).

# See http://alaskaflora.org/pages/blog5.html


# 1. Assemble rough lists: ACCS + ALA + PAF + FNA (should add Hulten
# at some point)

# 1a. ACCS
gawk 'BEGIN{FS="|"}{print $1 "|" $2, $3, $4, $5, $6, $7, $8}' \
     ../ACCS/accs > accs
# tidy up (GNR chokes on ×)
sed -i -e 's/| */|/g' -e 's/ *$//g' -e 's/  */ /g' \
    -e 's/×/x/g' accs

# 1b. ALA
gawk 'BEGIN{FS="|"}{print $1 "|" $2, $3, $4, $5, $6, $7, $8}' \
     ../ALA/ala > ala
sed -i -e 's/| */|/g' -e 's/ *$//g' -e 's/  */ /g' \
    -e 's/×/x/g' ala

# 1c. PAF
gawk 'BEGIN{FS="|"}{print $1 "|" $2, $3, $4, $5, $6, $7, $8}' \
     ../PAF/paf > paf
sed -i -e 's/| */|/g' -e 's/ *$//g' -e 's/  */ /g' \
    -e 's/×/x/g' paf

# 1d. FNA
gawk 'BEGIN{FS="|"}{print $1 "|" $2, $3, $4, $5, $6, $7, $8}' \
     ../FNA/fna > fna
sed -i -e 's/| */|/g' -e 's/ *$//g' -e 's/  */ /g' \
    -e 's/×/x/g' fna

# remove duplicates
cat accs ala paf fna | gawk 'BEGIN{FS="|"; PROCINFO["sorted_in"] \
   = "@ind_str_asc"}{n[$2]=$1}END{for (i in n) print n[i] "|" i}' > all_rough

rm -f accs fna

# split into batches of 1,000 for GNR
gawk 'BEGIN{FS="|"}{print $1 "|" $2 > "names4gnr-"  int(++i/995)+1 }' all_rough

echo "Size of rough list = " `wc all_rough | gawk '{print $1}'`

# 2. Run through GNR
rm -f gnr.out
for infile in names4gnr*
do
     echo "Running GNA on " $infile
     gawk -v INFILE=$infile -f gnr.awk >> gnr.out
done

# parse

grep "ipni-" gnr.out | gawk -i "taxon-tools.awk" 'BEGIN{FS=OFS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} {code[$4] = $3} END{for (i in code) {p = parse_taxon_name(i, 1); if (p) print code[i], p}}' > ipni_base

echo "Size of IPNI base list = " `wc ipni_base | gawk '{print $1}'`

grep "trop-" gnr.out | gawk -i "taxon-tools.awk" 'BEGIN{FS=OFS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} {code[$4] = $3} END{for (i in code) {p = parse_taxon_name(i, 1); if (p) print code[i], p}}' > trop_base

echo "Size of TROP base list = " `wc trop_base | gawk '{print $1}'`

# Some errors but these are errors in GNR records
# ** Fail: 'Hordeum x caespitosum 8999+' does not match:
#          Hordeum x caespitosum 8999+  <- parsed
# ** Fail: 'Botrychium virginianum var. ? simplex A. Gray' does not match:
#          Botrychium virginianum var. ? simplex A. Gray  <- parsed
# ** Fail: 'Sphagnum riparium var. > *fallax Sanio' does not match:
#          Sphagnum riparium var. > *fallax Sanio  <- parsed

rm -f names4gnr-* gnr.out

# 3. Find matches of Alaska rough list in WCSP

gunzip -kc ../WCSP/wcsp.gz > wcsp
echo "Size of WCSP total PL list = " `wc wcsp | gawk '{print $1}'`

# Convert all_rough into a delimited list

# a few fixes
sed -i -E -e 's/Uva\-Ursi/Uva-ursi/g' -e 's/\?//g' -e 's/,\ sensu.*$//g' \
    all_rough

gawk -i "taxon-tools.awk" 'BEGIN{FS=OFS="|"; PROCINFO["sorted_in"] = \
  "@ind_str_asc"} {p = parse_taxon_name($2, 1); if (p) print $1, p}' \
     all_rough > all_rough.listA

# lots of fails in accs:
# 'Betula neoalaskana × glandulosa '
# 'Caloplaca tornoe?nsis H. Magn.'
# 'Cetraria fastigata (Del. ex Nyl. in Norrl.) Ka?rnef.'
# 'Chamaepericlymenum canadense × suecicum '
# 'Coniferous Shrub (blank)'
# 'ThelIdium methorium (Nyl.) Hellb.'
# etc.

function alphaloop() {
    for i in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
    do
        echo $i
        gawk -v letter=$i 'BEGIN{FS="|"} $3 ~ letter {print $0}' \
             all_rough.listA > listA_$i
        gawk -v letter=$i 'BEGIN{FS="|"; PROCINFO["sorted_in"] = \
           "@ind_str_asc"} $5 ~ letter {code[$4 "|" $5 "|" $6 "|" $7 \
           "|" $8 "|" $9 "|" $10]=$1} END{for (i in code) \
           print code[i] "|" i}' wcsp > listB_$i
        matchnames -a listA_$i -b listB_$i -o all2wcsp_match_$i -F -e 5 -q
    done
}

export -f alphaloop
# gets hot! use cpulimit if you have it
cpulimit -l 50 -i bash -c alphaloop

# gather the parts
rm -f all2wcsp_all
for i in `ls all2wcsp_match_*`
do
    echo $i
    grep -v no_match $i >> all2wcsp_all
done

rm -f listA_* listB_* all2wcsp_match_* all_rough* wcsp

# summarize_field 3 all2wcsp_all 
# auto_basexin                   :    240
# auto_basio+                    :     50
# auto_basio-                    :     30
# auto_exin+                     :     38
# auto_exin-                     :     61
# auto_fuzzy                     :    344
# auto_in+                       :     36
# auto_irank                     :   1095
# auto_punct                     :    950
# exact                          :   3042

gawk 'BEGIN{FS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} {code[$11 "|" $12 "|" $13 "|" $14 "|" $15 "|" $16 "|" $17]=$2} END{for (i in code) print code[i] "|" i}' all2wcsp_all > wcsp_base
rm -f all2wcsp_all

echo "Size of WCSP base list = " `wc wcsp_base | gawk '{print $1}'`


# 4. Need to reconcile trop to ipni, to remove the variants

cp trop_base trop_listA
cp ipni_base ipni_listB

echo "Skipping manual stage (matchnames -a trop_listA -b ipni_listB)"
# {{{
# matchnames -a trop_listA -b ipni_listB -o trop2ipni_match -f -q
# rm -f trop_listA ipni_listB
# }}}

# grep -c "|manual" trop2ipni_match 
# 47

sed -E '/(\|manual|\|auto_punct|\|exact|\|auto_in)/ d' trop2ipni_match | gawk 'BEGIN{FS=OFS="|"}{print $1, $4, $5, $6, $7, $8, $9, $10}' > trop_base.2

cat ipni_base trop_base.2 > ipni+trop_base

# summarize_field 1 ipni+trop_base | grep " 2"
# all unique

# 5. Need to reconcile wcsp to trop + ipni, to remove the variants

cp wcsp_base wcsp_listA
cp ipni+trop_base ipni+trop_listB

echo "Skipping manual stage (matchnames -a wcsp_listA -b ipni+trop_listB)"
# {{{
# matchnames -a wcsp_listA -b ipni+trop_listB -o wcsp2i+t_match -f -q
# rm -f wcsp_listA ipni+trop_listB
# }}}

sed -E '/(\|manual|\|auto_punct|\|exact|\|auto_in)/ d' wcsp2i+t_match | gawk 'BEGIN{FS=OFS="|"}{print $1, $4, $5, $6, $7, $8, $9, $10}' > wcsp_base.2

cat ipni_base trop_base.2 wcsp_base.2 | sort > canon

# tidy

rm -f trop_base.2 wcsp_base.2 ipni_base ipni+trop_base trop_base wcsp_base \
   wcsp2i+t_match trop2ipni_match

# Summarize

echo "IPNI names in canon list: " `grep -c "ipni-" canon`
echo "TROP names in canon list: " `grep -c "trop-" canon`
echo "WCSP names in canon list: " `grep -c "kew-" canon`


# 6. Reconcile ALA to Canon list

gawk 'BEGIN{FS=OFS="|"}{print $1, $2, $3, $4, $5, $6, $7, $8}' \
     ../ALA/ala > ala.1

# echo "Skipping manual stage (matchnames -a ala -b canon)"
matchnames -a ala.1 -b canon -o ala2canon_match -f -q
echo "ALA names: " `wc ala | gawk '{print $1}'`
echo "Reconciling ALA to Canon. Matching: " \
  `grep -vc no_match ala2canon_match`
echo "Reconciling ALA to Canon. No match: " \
  `grep -c no_match ala2canon_match` 

# 7. Reconcile PAF to Canon list

gawk 'BEGIN{FS=OFS="|"}{print $1, $2, $3, $4, $5, $6, $7, $8}'  \
     ../PAF/paf > paf.1

echo "Skipping manual stage (matchnames -a paf -b canon)"
matchnames -a paf.1 -b canon -o paf2canon_match -f -q

echo "PAF names: " `wc paf | gawk '{print $1}'`
echo "Reconciling PAF to Canon. Matching: " \
  `grep -vc no_match paf2canon_match` 
echo "Reconciling PAF to Canon. No match: " \
  `grep -c no_match paf2canon_match` 

# rm -f ala.1 paf.1 # ala2canon_match paf paf2canon_match

# mysql --show-warnings -u cam -pPASS < load_canon.sql


