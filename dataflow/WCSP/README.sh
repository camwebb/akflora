# Extraction and assembly of the The Plant List (version 1.1)

# NOTE (2016-12-22): I just realized that this download method is
#   incomplete, because genera in which all species are synonyms of
#   species in other genera are _not listed_ in the ‘full genus list page’
#   (See, e.g., _Lysiella_). There seems no other way to trigger these
#   genera from within TPL. An alternative method is would be to use ITIS
#   and GBIF etc to generate a more complete genus list first.
# 2019-10-28: Now have a maximum genus list from ING.

# 1. Download the page with a list of genera 

rm -rf data
mkdir data
cd data
curl "http://www.theplantlist.org/1.1/browse/-/-/" > genus_list.html

# 2a. Extract the genera from the web page

grep -E '.*genus">' genus_list.html | \
    sed -e 's|^.*/"><i\ class="||g' \
        -e 's/\ genus">/ /g' \
        -e 's|</i></a>\ (<i\ class="family">| |g' \
        -e 's|</i>.*||g' \
        -e 's/×&nbsp;//g' > genus_list
rm genus_list.html

# 2b. Get unique genus names (multiples present due to i. Unresolved
#     taxonomy and ii. diff domains, e.g., Cedrus in angio and gymno)

gawk '{g[$2]++}END{for(i in g) print i}' genus_list | sort > \
    genus_list_unique

# 3. Create a download script

mkdir genera
# (remove the hybrid marks)
cat genus_list_unique | sed -e 's/×\ //g' \
    -e 's|\(.*\)|echo "\1"; curl -s "http://www.theplantlist.org/tpl1.1/search?q=\1\&csv=true" > genera/\1.csv|g' > download.sh

# 4a. Run the script (use nohup if sshing into another 'download' machine)
sh download.sh

# test for failed files:
ls -l genera | sort -k 5 -r | tail

# e.g.: Crepi-Hieracium Vilmorinia Vilfa Sphaeralcea Sebillea
# Schaefferia Poa Nephelochloa Leucaena Hemixanthidium Gaultheria
# Durringtonia Broughtonia Anomobryopsis Alfredia

# cat > failed
# cat failed | sed -e 's|\(.*\)|echo "\1"; curl -s "http://www.theplantlist.org/tpl1.1/search?q=\1\&csv=true" > genera/\1.csv|g' > failed.sh
# sh failed.sh

cat genera/* >> tpl.1
sed -i '/group,Family,Genus/d' tpl.1

# 4b. Get the rest, using the ING list

gawk 'BEGIN{while ((getline < "genus_list_unique")>0) g[$1]++; while ((getline < "../../ING/ING_genus_list_for_tpl")>0) if (!g[$1]) print $1}' > genus_list_extra

mkdir genera2
cat genus_list_extra | sed -e 's|\(.*\)|echo "\1"; curl -s "http://www.theplantlist.org/tpl1.1/search?q=\1\&csv=true" > genera2/\1.csv|g' > download2.sh

sh download2.sh
# consider splitting this up into 4 scripts and running in parallel
# sh download1.sh & ; pid1=$!
# sh download2.sh & ; pid2=$!
# sh download3.sh & ; pid3=$!
# sh download4.sh & ; pid4=$!
# wait  # or... wait pid1; wait pid3; wait pid3; wait pid4; 

# do the fail trick here too

cat genera2/* > tpl.2
sed -i '/group,Family,Genus/d' tpl.2
#  cat genera2/* | sed '1d' > tpl2   # should work but doesn't

cat tpl.1 tpl.2 > tpl.3

# 4c. Pick up a few stragglers: synonyms with no main entry.
# A few (25) fail, e.g. Tridentapelia bijliae (Pillans) G.D.Rowley - kew-2446031. Not in ING! 

gawk '{n=split($0,tmp,","); x[tmp[1]]++; s[tmp[n]]++; delete tmp} END{for (i in s) if (!x[i]) print i}' tpl.3 > stragglers

mkdir strag
cat stragglers | sed -e '/^$/d' -e 's|\(.*\)|echo "\1"; curl -s "http://www.theplantlist.org/tpl1.1/search?q=\1\&csv=true" > strag/\1.csv|g' > download3.sh
sh download3.sh
cat strag/* > stragglers.2
sed -i '/group,Family,Genus/d' stragglers.2

# 5. Combine and exctract just fields needed

# Fields: ID,Major group,Family,Genus hybrid marker, Genus,Species
#   hybrid marker,Species,Infraspecific rank,Infraspecific epithet,
#   Authorship,Taxonomic status in TPL,Nomenclatural status from original
#   data source,Confidence level,Source,Source id,IPNI
#   id,Publication,Collation,Page,Date,Accepted ID

cat stragglers.2 >> tpl.3
# test again
gawk '{n=split($0,tmp,","); x[tmp[1]]++; s[tmp[n]]++; delete tmp} END{for (i in s) if (!x[i]) print i}' tpl.3 

# there were a few | symbols!
sed -i 's/|//g' tpl.3

# tried writing my own CSV parser, but... hard. Consider, e.g., this line:
# kew-437126,...
# conataining ...,"Publ. Mus. Hist. Nat. ""Javier Prado"", Ser. B, Bot.",...
# the content ',' after "" was very tricky. 
#   sed -i -E 's/,"",/,,/g' tpl.3
#   sed -i -E 's/,"",/,,/g' tpl.3
#   sed -i -E 's/([^,"])"+([^",])/\1#\2/g' tpl.3
#   sed -i -E 's/,""+/,"#/g' tpl.3
#   sed -i -E 's/"+",/#",/g' tpl.3
#   gawk 'BEGIN{OFS="|";FPAT = "([^,]*)|(\"[^\"]+\")"}{ print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21}' tpl.3 > tpl.4
#   sed -i -E 's/"//g' tpl.4
# so... use a script, from awk-lib 

cpulimit -l 50 -i gawk -f ../csv.awk tpl.3 > tpl.4

# gcc-99270 ... |"Phil."""""|... correct!

# WCSP from the Plant List
#   - delete duplicate codes and names (just use the first)

gawk 'BEGIN{
        FS=OFS="|"
        while((getline < "tpl.4")>0) 
          if (($14 ~ /WCSP/) && ($11 ~ /(Accepted|Synonym)/)) {
            w[$1]++
            if ($21) w[$21]++
          } 
        close("tpl.4")
        while((getline < "tpl.4")>0) 
          if (w[$1])
            if ((++key[$4 $5 $6 $7 $8 $9 $10]==1) && (++code[$1]==1))
              print $1, $4, $5, $6, $7, $8, $9, $10, $11, $21}' > wcsp

# test duplicate codes 
gawk 'BEGIN{FS="|"}{x[$1]++} END{for (i in x) if (x[i]>1) print i, x[i]}' wcsp

# test duplicate names
gawk 'BEGIN{FS=OFS="|"}{k = $2 $3 $4 $5 $6 $7 $8; x[k]++; id[k] = id[k] "," $1}END{for (i in x) if (x[i]>1) print i "  " x[i] "  " id[i]}' wcsp

# test complete synonyms with
gawk 'BEGIN{FS=OFS="|"}{x[$1]++; s[$21]++} END{for (i in s) if (!x[i]) print i " has no line"}' wcsp

# final fixes
sed -i 's/|var|/|var.|/g' wcsp
sed -i 's/|var. schneideri|/|var.|schneideri/g' wcsp

# gawk 'BEGIN{FS=OFS="|"} {if ($11 == "Accepted") print $1, $1, "accepted", "WCSP"; else print $1, $21, "synonym", "WCSP"}' wcsp > wcsp_rel

# tidy up

gzip tpl.3
gzip tpl.4
gzip wcsp
mv tpl.3.gz tpl.4.gz wcsp.gz ..

cd ..

rm -rf data
