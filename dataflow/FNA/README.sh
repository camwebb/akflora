# Extracts core taxonomic data from FNA XML files 

# git clone https://USER@bitbucket.org/aafc-mbb/fna-data-curation.git
# mv fna-data-curation/coarse_grained_fna_xml .
# rm -rf fna-data-curation

for vol in coarse_grained_fna_xml/V*
do
    echo "vol: " $vol
    for file in $vol/*xml
    do
        echo "file: " $file
        FN=`basename $file`
        sed -i 's|xmlns:bio="http://www.github.com/biosemantics".*$|xmlns:bio="http://www.github.com/biosemantics">|g' $file
        xqilla -v file "$FN" -i $file extract.xq >> fna.raw 
    done
done

# clean dashes
sed -i -e 's/—/-/g' fna.raw

gawk -f clean_fna.awk fna.raw > fna.1

# remove dupes (all dropped ones are synonyms)
gawk 'BEGIN{FS=OFS="|"}{if (++uniq[$2 $3 $4 $5 $6 $7 $8] == 1) print $1, $2, $3, $4, $5, $6, $7, $8, $9; else print $1 " " $2 " " $3 " " $4 " " $5 " " $6 " " $7 " " $8 " is a dup" > "/dev/stderr"}' fna.1 > fna

# Tidy up
rm -f fna.raw fna.1
# rm -rf coarse_grained_fna_xml

# Notes:
#
# What are the possible infraspecific ranks?
#
# grep "rank=" coarse_grained_fna_xml/V4/* | awk '{print $3}' | sort | uniq
# 
# rank="species"
# rank="subspecies"
# rank="variety"

