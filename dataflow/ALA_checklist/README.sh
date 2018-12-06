# Making the base ALA checklist
# Cam Webb, 2018-11-08 to 2018-12-03

# This script can be executed to recreate the output data. Set MANUAL=1
#   to re-do the manual checking of GNR output

export MANUAL=0

# 1. Character encoding, cleaning, reformating

rm -f ala.* ala-names* ala-rel* \
   data_in/DFMAccepNameswLit20180609B.TXT \
   ala-gnr names4gnr* ala-gnr_not_found 

gunzip -k data_in/DFMAccepNameswLit20180609B.TXT.gz

# Base file: DFMAccepNameswLit20180609B.TXT
#
# Line-endings: Mac (\n) , delimiters = "\t", columns:
# Family|Name with authors (incl. infraspecific taxa if any)|
#   ALA accepted name with authors|AKflora?|Comments (optional)|Literature
#
# But what encoding? I used Hultén as a key.
#
#   hexdump -C tmp
#   00000000  48 75 6c 74 8e 6e     |Hult.n|
#
# Hex of 8E for é ? Googling got me here:
#   https://en.wikipedia.org/wiki/%C3%89#Character_mappings
# So it's probably https://en.wikipedia.org/wiki/Mac_OS_Roman

iconv -f MACINTOSH -t UTF-8 data_in/DFMAccepNameswLit20180609B.TXT | \
    tr "\r" "\n" | tr "\t" "|" | tail -n +2 > ala.1

# Find non-ASCII in emacs with M-C-s [^^@-^?]
#   (enter as “C-M-s [ ^ C-q 0 0 0 RET - C-q 1 7 7 RET ]”)
# Checked - all looks good.

# Some other formatting issues: 1. Al used the "/" as a delimiter in
# the ref section. Was it in any other field?  gawk 'BEGIN{FS="|"} $1
# ~ "/" {print $0} $2 ~ "/" {print $0} $3 ~ "/" {print $0} $4 ~ "/"
# {print $0} $5 ~ "/" {print $0}' ala.1 No, only in $6. Switch "/" to
# "^". He also has a short version of citation then a ";" and then the
# longer version. Leave these for later when parsing the
# citations. However, he also used "/" in the URLs. Need a fix for
# that. 2. Some extra spaces after (and before?) the field
# delimiters. Clean with sed:

cat ala.1 | \
    sed -e 's|http://mobot.mobot.org/|Mobot-URL|g' | \
    sed -e 's|http://www.mobot.org/Pick/Search/nwgc.html/|CNWG-URL|g' | \
    sed -e 's|http://res.agr.ca/itis/|ITIS-URL|g' | \
    sed -E 's|/|^|g' | \
    sed -E 's/ *\^ */^/g' | \
    sed -E 's/;? *\^$//g' | \
    sed -E 's/ *\| */|/g' | \
    sed -E 's/ *$//g' > ala.2

# There are 116 different citations now: gawk 'BEGIN{FS="|"}{if ($6)
# {n = split($6,x,"^");for (i = 1; i<= n; i++) print x[i]}}' ala.3 | sort |
# uniq | wc --> 116 

# Shortly after 2018-06-09, Al Batten, who had developed and managed
# the ALA 4D database, send me a file, DFMAccepNameswLit20180609B.xls,
# in which he had exported the full citation list for each synonymy
# statement.  A previous dump of the 4D Database (which was used in
# the creation of the ALA ARCTOS database) existed named
# AKANcodesA16Aug2011.xls, from which I had created the online 'ALA
# Checklist' in ca. Nov 2016. Dave may have edited the xls file after
# its dump from 4D and before handing it over to Steffi (and then to
# me). So the first issue was to test for this:
#
#  $ gawk 'BEGIN{FS="\t";while((getline < "allist")>0){syn[$1]=$2}}\
#      {if ((syn[$1]) && (syn[$1] != $2)) \
#      print "name: "$1 "; acc by dave: " $2 "; acc by al: " syn[$1];}' \
#      davelist 
#
# I.e., for each name, if the acc name in al’s list is not the same as
# an accepted name in dave’s list, spit it out. Only a few were different:
#
# name: Atriplex gmelinii C.A.Mey. ex Bong. subsp. gmelinii ; 
#   acc by dave: Atriplex gmelinii C.A.Mey. ex Bong. subsp. gmelinii ; 
#   acc by al: Atriplex gmelinii C.A.Mey. ex Bong. var. gmelinii 
#
# name: Atriplex gmelinii C.A.Mey. ex Bong. var. gmelinii ; 
#   acc by dave: Atriplex gmelinii C.A.Mey. ex Bong. subsp. gmelinii ; 
#   acc by al: Atriplex gmelinii C.A.Mey. ex Bong. var. gmelinii 
#
# name: Eriophorum medium auct.; 
#   acc by dave: Eriophorum russeolum Fr. ex Hartm. subsp. leiocarpum ; 
#   acc by al: Eriophorum russeolum Fr. subsp. leiocarpum
#
# name: Eriophorum russeolum Fr. var. albidum auct.; 
#   acc by dave: Eriophorum russeolum Fr. ex Hartm. subsp. leiocarpum ; 
#   acc by al: Eriophorum russeolum Fr. subsp. leiocarpum 
#
# name: Melandrium macrospermum A.E.Porsild; 
#   acc by dave: Gastrolychnis macrosperma (A.E.Porsild) Tolm. & Kozhanch.; 
#   acc by al: Silene soczaviana (Schischk.) Bocquet var. macrosperma (A.E.Porsild) comb. nov.
# 
# Fix this. Note that Melandrium macrospermum A.E.Porsild had two diff
# accepted names, but with the change, both are to Gastrolychnis
# macrosperma, so one is now deleted.

patch -o ala.3 ala.2 patch/p1.patch
if [ $? -ne 0 ] ; then exit ; fi

# Note: patch will attempt to find the correct location to patch even
# if the line numbers have changed. So edits can be made in the file
# before the patch and it may still work. The exit status test is
# needed though.

# So **THE ALA BASE LIST IS DFMAccepNameswLit20180609B.TXT** This is
# geographically wider than the file I got back in 2016
# (AKANcodesA16Aug2011) which is just for AK plants. But we are not
# using this list as evidence for presence in Alaska.

# A few names are non unique: gawk 'BEGIN{FS="|";OFS="|"}{c[$2]++}END{for
#   (i in c) if (c[i] > 1) print i, c[i]}' ala.3
#
# Platanthera|2
# Carex capillaris L. subsp. fuscidula (V.I.Krecz. ex T.V.Egorova) A.Love & D.Love|2
# Silene uralensis (Rupr.) Bocquet subsp. porsildii Bocquet|2
# Pyrola asarifolia Michx.|2
# Carex capillaris L. subsp. chlorostachys (Steven) A.Love & D.Love|2
#
# Made patch file (deleting the one with less info):

patch -o ala.4 ala.3 patch/p2.patch
if [ $? -ne 0 ] ; then exit ; fi

# Delete genus names only, e.g.
#  Papaveraceae|Papaver|Papaver|F||
#  Asteraceae|Petasites|Petasites|F|consistency|
#  Orchidaceae|Platanthera|Platanthera|T||
#  Polygonaceae|Polygonum|Polygonum|F||
# and drop the fmaily col.

gawk 'BEGIN{FS="|"; OFS="|"} $2 ~ /\ / {print $2, $3, $4, $5, $6}' ala.4 \
     > ala.5

# > wc ala.4
#  3815  48374 461868 ala.4
# > wc ala.5
#  3744  48295 415213 ala.5

# ## Circularity

# Al Mentioned in his email that there were some chains: A -> B and B
# -> C. Better to clean these up before importing.
# gawk 'BEGIN{FS="|";OFS="|"}{acc[$1] = $2}END{for (i in acc) if
#  ((acc[acc[i]]) && (acc[i] != i) && (acc[acc[i]] != acc[i])) print i,
#  acc[i], acc[acc[i]];}' ala.5 | wc --> 21
# 
# Arabis lyrata L. subsp. kamchatica (Fisch.) Hultén|Arabis kamchatica Fisch.|Arabidopsis lyrata (L.) O'Kane & Al-Shehbaz subsp. kamchatica (Fisch. ex DC.) O'Kane & Al-Shehbaz
# Aster sibiricus L. var. pygmaeus (Lindl.) Cody|Eurybia pygmaea (Lindl.) G.L.Nesom|Symphyotrichum pygmaeum (Lindl.)  & Selliah
# Atriplex drymarioides Standl.|Atriplex gmelinii C.A.Mey. ex Bong. subsp. gmelinii |Atriplex gmelinii C.A.Mey. ex Bong. var. gmelinii 
# Cryptogramma crispa (L.) R.Br.|Cryptogramma crispa (L.) R.Br. ex Hook. var. acrostichoides (R.Br.) C.B.Clarke|Cryptogramma acrostichoides R.Br.
# Dryopteris robertiana auct.|Gymnocarpium continentale (Petrov) Pojark.|Gymnocarpium jessoense (Koidz.) Koidz. subsp. parvulum Sarvela
# Gentiana raupii A.E.Porsild|Gentianopsis detonsa (Rottb.) Malte subsp. raupii (A.E.Porsild) A.Love & D.Love|Gentianopsis barbata (Froel.) Malte subsp. raupii (A.E.Porsild) Elven
# Huperzia selago (L.) Bernh. ex Schrank & Mart. subsp. selago |Huperzia haleakalae (Brack.) Holub|Huperzia selago (L.) Bernh. ex Schrank & Mart.
# Neotorularia humilis (C.A.Mey.) Hedge & J.Leonard|Torularia humilis (C.A.Mey.) O.E.Schulz|Braya humilis (C.A.Mey.) B.L.Rob.
# Papaver freedmanianum D.Love|Papaver radicatum Rottb. subsp. kluanensis (D.Love) D.F.Murray|Papaver kluanensis D.Love
# Papaver macounii Greene subsp. alaskanum |Papaver radicatum Rottb. subsp. alaskanum (Hultén) J.P.Anderson|Papaver alaskanum Hultén
# Polygonum scabrum Moench|Polygonum lapathifolium L.|Persicaria lapathifolia (L.) Gray
# Salix glauca L. var. glauca |Salix glauca L. var. stipulata Flod. in Lindem.|Salix glauca L. subsp. acutifolia (Hook.) Hultén
# Salix lasiandra Benth.|Salix lucida Muhl. subsp. lasiandra (Benth.) Argus|Salix lasiandra Benth. var. lasiandra 
# Salix padifolia Rydb.|Salix monticola auct.|Salix pseudomonticola C.R.Ball
# Salix padophylla Rydb.|Salix monticola auct.|Salix pseudomonticola C.R.Ball
# Senecio streptanthifolius Greene var. borealis (Torr. & A.Gray) J.F.Bain|Packera streptanthifolia (Greene) W.A.Weber & A.Love|Packera cymbalarioides (Nutt.) W.A.Weber & A.Love
# Silene acaulis (L.) Jacq. var. subacaulescens (F.N.Williams) Fernald & H.St.John|Silene acaulis (L.) Jacq. subsp. subacaulescens (F.N.Williams) Hultén|Silene acaulis (L.) Jacq.
# Silene involucrata (Cham. & Schltdl.) Bocquet|Gastrolychnis affinis auct.|Silene involucrata (Cham. & Schltdl.) Bocquet subsp. furcata (Raf.) comb. nov.
# Silene involucrata (Cham. & Schltdl.) Bocquet subsp. elatior (Regel) Bocquet|Gastrolychnis affinis auct.|Silene involucrata (Cham. & Schltdl.) Bocquet subsp. furcata (Raf.) comb. nov.
# Silene taimyrensis (Tolm.) Bocquet|Gastrolychnis ostenfeldii (A.E.Porsild) V.V.Petrovsky|Silene ostenfeldii (A.E.Porsild) J.K.Morton
# Silene uralensis (Rupr.) Bocquet|Gastrolychnis apetala (L.) Tolm. & Kozhanch.|Silene uralensis (Rupr.) Bocquet subsp. uralensis 

# Fix this: 

gawk 'BEGIN{FS="|";OFS="|"} \
      {acc[$1] = $2;ak[$1]=$3;com[$1]=$4;lit[$1]=$5} \
      END{for (i in acc) \
            if ((acc[acc[i]]) && (acc[i] != i) && (acc[acc[i]] != acc[i])) \
              { print i, acc[acc[i]], ak[acc[i]], (com[i] "; syn-of-syn: " \
                      i " -> " acc[i] "; "com[acc[i]]), \
                      (lit[i] "^" lit[acc[i]])} \
            else {print i, acc[i], ak[i], com[i], lit[i]}}' ala.5 > ala.6

# > wc ala.6
# 3744  48774 418609 ala.6

# Now, parsing the names into parts, and discarding the species author
# if there is a infraspecific taxon and author.

gawk -f lib/split_name_string.awk ala.6 > ala.7

# New cols are n, gen_x, gen, sp_x, sp, infratype, infra, author,
#  syn_gen_x, syn_gen, syn_sp_x, syn_sp, syn_infratype, syn_infra, syn_author,
#  synonym, inalaska, comments, citations

# Some General tests Authors end with ) or & ...
# gawk 'BEGIN{FS="|"} \
#       $7 ~ /[&)]$/ || $13 ~ /[&)]$/ { print $0 ; fail = 1 } \
#       END{ if (fail) exit 1 }' ala.7
# if [ $? -ne 0 ] ; then exit ; fi
# but I checked back to earlier files and that is how the data are

# Check with gawk 'BEGIN{FS="|"}{x[$1]++}END{for(i in x) print i}' ala.7 | sort
# from $1 to $16
# found some errors - need to fix by hand (×): Search for _ 
#
# genus
#   x_Dupoa
#   x_Elyhordeum
#   x_Elytesion
#
# species
#   x_alaskanum
#   X_ananassa
#   X_arctoalaskensis
#   X_limosoides
#   X_macranthum
#   X_palmerensis
#   X_paludivagans
#   X_physocarpoides
#   X_sepulcralis
#   X_subpaleacea
#   X_treleasianum
#   X_vitifolius
#   canadensis × suecica
#   triste × gracile
#   ...
# author
#   Xstolonifera Coville
#
# syn_gen
#   x_Dupoa
#   x_Elyhordeum
#
# syn_sp
#   x_alaskanum
#   X_ananassa
#   X_arctoalaskensis
#   X_limosoides
#   X_macranthum
#   X_palmerensis
#   X_paludivagans
#   X_physocarpoides
#   X_sepulcralis
#   X_subpaleacea
#   X_treleasianum
#   X_vitifolius
#
# syn_author
#   Xstolonifera Coville
# 
# and  2 cases of forma by hand
# 1515||Agropyron||desertorum|||(Fisch. ex Link) Schult. forma pilosiusculum Melderis||Agropyron||desertorum|||(Fisch. ex Link) Schult. forma pilosiusculum Melderis

patch -o ala.8 ala.7 patch/p3.patch
if [ $? -ne 0 ] ; then exit ; fi

# Check again with:
#   gawk 'BEGIN{FS="|"}{x[$1]++}END{for(i in x) print i}' ala.7 | sort
# from $1 to $16, scanning for bad parsing ... looks good

# A species to be added (get the number from ala.7)

echo "|Pedicularis||pacifica|||(Hultén) Kozhevn.||Pedicularis||pacifica|||(Hultén) Kozhevn.|accepted|T|This was missing in Als list (Cam, 2018-08-21)|" >> ala.8

# found a taxa to remove:
# 2299||Bupleurum||triradiatum|||auct. non Adams ex Hoffm.||Bupleurum||||...

sed -i '/Bupleurum||triradiatum|||auct/ d' ala.8
sed -i '/|Taraxacum||sect.|/ d' ala.8


# 2. Split into two tables: names and relationships (ala-names and ala-rel)
# with to_names_only.awk

gawk -f lib/to_names_only.awk ala.8

# Test with: gawk 'BEGIN{FS="|"}{a[$1]++;b[$6]++}END{for (i in b) if(!a[i])
#   print i}' ala-rel   #  seems OK

# Test with
# gawk 'BEGIN{FS="|"; while ((getline < "/home/cam/akflora/FLOW/2018-08-20_ALAchecklist/1_ALA_list/ala-names") > 0) a[$2 $3 $4 $5 $6 $7 $8]++} { if (!a[$2 $3 $4 $5 $6 $7 $8]) print $0}' ala-names
#
# ala-2120|\N|Eriophorum|\N|scheuchzeri|subsp.|arcticum|\N <- missing in /home/cam/akflora/FLOW/2018-08-20_ALAchecklist/1_ALA_list/ala-names - not sure why

rm -f ala.* data_in/DFMAccepNameswLit20180609B.TXT


# (end clean-up)
# ---------------------------------------------------------------------------

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
