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

echo "Skipping manual stage (matchnames -a ala -b canon)"
# {{{
# matchnames -a ala -b canon -o ala2canon_match -f -q
# 
# echo "ALA names: " `wc ala | gawk '{print $1}'`
# echo "Reconciling ALA to Canon. Matching: \" \
#   `grep -vc no_match ala2canon_match` 
# echo "Reconciling ALA to Canon. No match: " \
#   `grep -c no_match ala2canon_match` 
# }}}

# 7. Reconcile PAF to Canon list

echo "Skipping manual stage (matchnames -a paf -b canon)"
# {{{
# matchnames -a paf -b canon -o paf2canon_match -f -q
# 
# echo "PAF names: " `wc paf | gawk '{print $1}'`
# echo "Reconciling PAF to Canon. Matching: \" \
#   `grep -vc no_match paf2canon_match` 
# echo "Reconciling PAF to Canon. No match: " \
#   `grep -c no_match paf2canon_match` 
# }}}



### HERE STOP



mysql --show-warnings -u cam -ptesttest < load_canon.sql


#  move ot other README

echo "select concat_ws('-', names.id, uids.authority), genhyb, genus, sphyb, species, ssptype, ssp, author from names , uids where names.id = uids.nameID and uids.canon = 1 order by genus, species, ssp;" | mysql -N -u cam -ptesttest akflora | tr "\t" "|" > canon_listB

gawk 'BEGIN{FS=OFS="|"}{print $1, $2, $3, $4, $5, $6, $7, $8}' ../ALA_checklist/ala-names > ala_listA


# ------------------------------------------------------- ala-1687  --( 762/3740)
#     Schoenoplectus acutis (Muhl. ex Bigelow) A.Love & D.Love
#  1: Schoenoplectus acutus (Muhl. ex Bigelow) A. Love & D. Love
#  2: Schoenoplectus acutus (Muhl. ex Bigelow) Á.Löve & D.Löve
#  3: Schoenoplectus acutus (Muhl. ex J.M.Bigelow) Á.Löve & D.Löve
#   > c
#                 ala-1687 vs. 16414-TROP          
#                          vs. 19328-WCSP          
#                          vs. 8984-IPNI           
#   > 3

cp ../PAF/paf-names paf.listA
sed -i -e 's/\\N//g' paf.listA

matchnames -a paf.listA -b canon_listB -o paf2canon_match -f -q

exit

# -------------------------------------------------------------

# From here on are the first trials of GNR, from ALA_checklist

# 3. GNR

# Split up into chunks for GNA 
#   see https://github.com/GlobalNamesArchitecture/gnresolver/issues/111
#   ah - change × to x and it works, and returns the correct × results.
gawk 'BEGIN{FS="|"}{s = $2 " " $3 " " $4 " " $5 " " $6 " " $7 " " $8 ; gsub(/\\N/,"",s); gsub(/×/,"x",s); gsub(/\ \ +/," ",s); gsub(/^\ /,"",s); gsub(/\ $/,"",s); print $1 "|" s > "names4gnr-"  int(++i/995)+1 }' ala-names

# Run through GNR
for infile in names4gnr*
do
    echo "Running GNA on " $infile
    gawk -v INFILE=$infile -f lib/gnr.awk >> ala-gnr
done

## gawk -i "../../lib/parse_taxon_name.awk" 'BEGIN{FS="|";OFS="|"} {print $1, toupper(substr($3,1,match($3,/\-/)-1)), $3, parse_taxon_name($4, 1), $5}' ala-gnr > ala-gnr-tmp

# TODO: GNR ranks: gawk 'BEGIN{FS="|"}{s[$8]++}END{for (i in s) print i}' ala-gnr-tmp
# prol. var. fo. f. nothovar. [infrasp.unranked] lus. subsp.

rm -f names4gnr*

# ---------------------------------------------------------------------------
# 4. Manual matching on GNR returns

# Make a list of ALA names:
# unique codes for each string

# was: gawk -i "../../lib/parse_taxon_name.awk" 'BEGIN{FS=OFS="|"} {code[$2]=$1} END{for (i in code) print code[i], parse_taxon_name(i, 1)}' ala-gnr | sort > listA

## But, NB! These have been stripped of hybrid signs for GNR! Ugh. Need to use ala-names. See, eg, Geum x macranthum (Kearney) B.Boivin

gawk 'BEGIN{FS=OFS="|"} {gsub(/\\N/,"",$0); print $1, $2, $3, $4, $5, $6, $7, $8}' ala-names | sort > listA

# Make a list of IPNI names:
# unique codes for each string
gawk -i "../../lib/parse_taxon_name.awk" 'BEGIN{FS=OFS="|"} $3 ~ /ipni/ {code[$4]=$3} END{for (i in code) print code[i], parse_taxon_name(i, 1)}' ala-gnr | sort > listBipni
# Make a list of Tropicos names:
gawk -i "../../lib/parse_taxon_name.awk" 'BEGIN{FS=OFS="|"} $3 ~ /trop/ {code[$4]=$3} END{for (i in code) print code[i], parse_taxon_name(i, 1)}' ala-gnr | sort > listBtrop

# ugh - ipni has duplicate IDs for the same name: ipni-1018959-1 ipni-1078427-2

exit;

if [ $MANUAL -eq 1 ]
then
    ../../tools/match_names -a listA -b listBipni -o ala2ipni_match -f
    ../../tools/match_names -a listA -b listBtrop -o ala2trop_match -f
else
    cp manual/ala2* .
fi

rm -f ala-gnr* list* 

# 4b. See how many were not matched

cat ala2ipni_match ala2trop_match > tmp
gawk 'BEGIN{FS=OFS="|"}{a[$1][$3]++}END{for (i in a) for (j in a[i]) if ((a[i]["no_match"]==2) && ($10 !~ /auct\./))print i}' tmp > ala_no_match

# 300+!

# Method 1 for finding some more: manual editing of file
# sed -i -E -e 's/$/|/g' ala_no_match 
# grep -f ala_no_match ala-gnr | sort > ala-poss
# sed -i -E -e '/auct\./ d' -e 's/^/|/g' ala-poss
# emacs ala-poss # add a symbol for new ones to add

# Method 2 for finding some more: use a higher fuzzy value. In fact,
# use `-e 10` from now on.

grep -f ala_no_match listA > listA2 
../../tools/match_names -a listA2 -b listBipni -o test.out -f -e 10
grep "|manual|" test.out >> ala2ipni_match 
../../tools/match_names -a listA2 -b listBtrop -o test.out -f -e 10
grep "|manual|" test.out >> ala2trop_match 

## 5. Load into SQL

gawk 'BEGIN{FS=OFS="|"} $3 !~ /no_match/ {print $1, "IPNI", $2, $11, $12, $13, $14, $15, $16, $17, $3 }' ala2ipni_match > ala-gnr-tmp
gawk 'BEGIN{FS=OFS="|"} $3 !~ /no_match/ {print $1, "TROP", $2, $11, $12, $13, $14, $15, $16, $17, $3 }' ala2trop_match >> ala-gnr-tmp
../../bin/sqlnulls ala-gnr-tmp

mysql -N -u $DBUSER -p$DBPASSWD --show-warnings < load_ala.sql


# To see the ala names still lacking another name:

echo "select ala.code, names.* from (select names.id, uids.code from names, 
   uids where names.id = uids.nameID and uids.authority = 'ALA') as ala 
   left join (select names.id from names, uids where names.id = uids.nameID 
   and uids.authority != 'ALA') as oth on ala.id = oth.id left join ortho 
   on ala.id = ortho.fromID left join names on ala.id = names.id where 
   oth.id IS NULL and ortho.fromID IS NULL;" | mysql -N -u $DBUSER \
       -p$DBPASSWD tmp_ala | gawk 'BEGIN{FS="\t"}{s = $3 " " $4 " " $5 " " \
   $6 " " $7" " $8 " " $9; gsub(/NULL/,"",s); gsub(/^\ */,"",s);\
   gsub(/\ *$/,"",s); gsub(/\ \ */," ",s); print $1 "|" s}' | sort

# 2018-12-05: yay, only down to 200 without matches


# ---------------------------------------------------------------------------

# ** Notes **

# 1. ARCTOS uids in GNR are not good. E.g., arct-'59066' is not the
# same as arct-59066; and arct-'1771237' is not unique. No permanent
# IDs in Arctos - need to access via name only

# 2. To show a single line, with sed: sed -n '11081 p' ala-gnr-tmp

# 3. Manual fixes in DB with: insert into uids (code, authority, nameID)
# values ('288067-2', 'IPNI', 1667);

# 4. To see structure of DB:
#   mkdir tmp_ala
#   java -jar ~/usr/schemaspy/target/schemaspy-6.0.1-SNAPSHOT.jar \
#        -t mariadb -u cam -p testtest -host localhost -o tmp_ala/ \
#        -db tmp_ala -s tmp_ala \
#        -dp /usr/share/java/mariadb-jdbc/mariadb-java-client.jar

# 5. Watch out for correct parsting of 'auct.' should be in author sting
# See parse_taxon_name.awk

# 6. Also, beware of ' and " quote marks in Authority names

# 7. To use " or ' in an inline gawk script use ascii hex: /\x27/

# 8. GNR fails sometimes with 


