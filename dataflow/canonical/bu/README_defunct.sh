
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


