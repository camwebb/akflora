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

gawk -f clean_fna.awk fna.raw > fna

# Tidy up
rm -f fna.raw
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

