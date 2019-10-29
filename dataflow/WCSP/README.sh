# Extraction and assembly of the The Plant List (version 1.1)

# NOTE (2016-12-22): I just realized that this download method is
#   incomplete, because genera in which all species are synonyms of
#   species in other genera are _not listed_ in the ‘full genus list page’
#   (See, e.g., _Lysiella_). There seems no other way to trigger these
#   genera from within TPL. An alternative method is would be to use ITIS
#   and GBIF etc to generate a more complete genus list first.
# 2019-10-28: Now have a maximum genus list from ING. 

# Issues, errors:
#   gcc-43286 - `"` in fields breaks CSV import
#   gcc-54760 - same
#   tro-50124871|...|Synonym|tro-50245423
#     tro-50245423 not in list

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

# 2b. Get unique genus names (multiples present due to i. Unresolved
#     taxonomy and ii. diff domains, e.g., Cedrus in angio and gymno)

gawk '{g[$2]++}END{for(i in g) print i}' genus_list | sort > \
    genus_list_unique

# 3. Create a download script

mkdir genera
# (remove the hybrid marks)
cat genus_list_unique | sed -e 's/×\ //g' \
    -e 's|\(.*\)|echo "\1"; curl -s "http://www.theplantlist.org/tpl1.1/search?q=\1\&csv=true" > genera/\1.csv|g' > download.sh

# 4. Run the script (use nohup if sshing into another 'download' machine)
sh download.sh

# test for failed files:
ls -l genera | sort -k 5 -r | tail

# e.g.:
# Crepi-Hieracium
# Vilmorinia
# Vilfa
# Sphaeralcea
# Sebillea
# Schaefferia
# Poa
# Nephelochloa
# Leucaena
# Hemixanthidium
# Gaultheria
# Durringtonia
# Broughtonia
# Anomobryopsis
# Alfredia

# cat > failed
# cat failed | sed -e 's|\(.*\)|echo "\1"; curl -s "http://www.theplantlist.org/tpl1.1/search?q=\1\&csv=true" > genera/\1.csv|g' > failed.sh

cat genera/* >> tpl.1
sed -i -e '/^.*Major\ group,Family.*$/d' tpl.1

# 4b. Get the rest, using ING

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

cat genera2/* > tpl.2
sed -i '/group,Family,Genus/d' tpl2
#  cat genera2/* | sed '1d' > tpl2   # should work but doesn't

# 5. Combine and exctract just fields needed

# Fields: ID,Major group,Family,Genus hybrid marker, Genus,Species
#   hybrid marker,Species,Infraspecific rank,Infraspecific epithet,
#   Authorship,Taxonomic status in TPL,Nomenclatural status from original
#   data source,Confidence level,Source,Source id,IPNI
#   id,Publication,Collation,Page,Date,Accepted ID

cat tpl.1 tpl.2 > tpl.3
sed -i -E 's/,"",/,,/g' tpl.3
sed -i -E 's/,"",/,,/g' tpl.3
sed -i -E 's/([^,"])"+([^",])/\1#\2/g' tpl.3
sed -i -E 's/,""+/,"#/g' tpl.3
sed -i -E 's/"+",/#",/g' tpl.3

# gawk 'BEGIN{OFS="|";FPAT = "([^,]*)|(\"[^\"]+\")"}{for(i=1;i<=NF;i++) if(substr($i,1,1)=="\"") $i=substr($i,2,length($i)-2); print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21}' tpl.3 > tpl.4
gawk 'BEGIN{OFS="|";FPAT = "([^,]*)|(\"[^\"]+\")"}{ print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21}' tpl.3 > tpl.4
sed -i -E 's/"//g' tpl.4

# # fix a few - some records had """ which did not parse, found via:
# gawk 'BEGIN{FS="|"}{x[$14]++}END{for(i in x) print i, x[i]}' tpl.csv 
# gawk 'BEGIN{FS="|"}$14 == "Unresolved" {print $0}'
# gawk 'BEGIN{FS="|"}$14 == "" {print $1}' tpl.csv
# grep Höltzer tpl.csv
# # manually:
# sed -i '/gcc-17049|/ d' tpl.csv 
# sed -i '/gcc-22474|/ d' tpl.csv
# sed -i '/gcc-18503|/ d' tpl.csv
# sed -i '/ild-47379|/ d' tpl.csv
# sed -i '/ild-47380|/ d' tpl.csv
# sed -i '/gcc-34703|/ d' tpl.csv
# sed -i '/gcc-108480|/ d' tpl.csv
# sed -i '/gcc-17799|/ d' tpl.csv
# sed -i '/gcc-7104|/ d' tpl.csv
# sed -i '/gcc-9594|/ d' tpl.csv
# sed -i '/gcc-144759|/ d' tpl.csv
# sed -i '/gcc-135361|/ d' tpl.csv
# sed -i '/gcc-89224|/ d' tpl.csv
# sed -i '/ild-52413|/ d' tpl.csv
# sed -i '/ild-52414|/ d' tpl.csv
# sed -i '/gcc-88328|/ d' tpl.csv
# sed -i '/gcc-6229|/ d' tpl.csv
# sed -i '/ild-52641|/ d' tpl.csv
# sed -i '/ild-29900|/ d' tpl.csv
# sed -i '/ild-52648|/ d' tpl.csv
# sed -i '/ild-51842|/ d' tpl.csv
# sed -i '/gcc-155879|/ d' tpl.csv
# sed -i '/gcc-28873|/ d' tpl.csv
# sed -i '/gcc-156518|/ d' tpl.csv
# sed -i '/gcc-147121|/ d' tpl.csv
# sed -i '/gcc-148273|/ d' tpl.csv
# sed -i '/gcc-151659|/ d' tpl.csv
# sed -i '/gcc-155168|/ d' tpl.csv
# sed -i '/gcc-150007|/ d' tpl.csv
# # Made a patch

# patch -o tpl.3 tpl.2 fixtpl.patch

# WCSP from the Plant List

# NOTE! searching on WCSP does not add the accepted names where the
# accepted names are not 'according to WCSP'. How does this impact the
# creation of the canonical list?  No problem, because the accepted
# names are generally ipni or tro names. However, for the tcsp_rel
# table, we need to add the accepted names as well.

gawk 'BEGIN{FS=OFS="|"; while((getline < "tpl.4")>0) if ($14 ~ /WCSP/){w[$1]++; if ($21) w[$21]++} ; close("tpl.4");  while((getline < "tpl.4")>0) if (w[$1]) print $0}' > tpl.5

# test with
gawk 'BEGIN{FS=OFS="|"}{x[$1]++; s[$21]++} END{for (i in s) if (!x[i]) print i " has no line"}' tpl.5

# A few (25) fail, e.g. Tridentapelia bijliae (Pillans) G.D.Rowley - kew-2446031. Not in ING! 

gawk 'BEGIN{FS="|"} $14 ~ /WCSP/ {print $0}' tpl.3 > wcsp
# rm -f tpl*

# check via
# gawk 'BEGIN{FS="|"}{x[$8]++}END{for(i in x) print i, x[i]}' wcsp.csv
# a few more fixes:

sed -i 's/|var|/|var.|/g' wcsp
sed -i 's/|var. schneideri|/|var.|schneideri/g' wcsp

gzip tpl.3
gzip wcsp

rm tpl tpl.2

rm -rf data
