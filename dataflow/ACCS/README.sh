# The Comprehensive checklist of Alaska Center for Conservation
# Science (ACCS) was developed by Timm Nawrocki, Matt Carlson and
# Justin Fulkerson. It appears on the <https://floraofalaska.org/>
# website and is a key building block of the new Flora of Alaska.

# The underlying SQL database is not publicly available, but this
# derived file is.

# Data License for file: "accs":
#   (c) Alaska Center for Conservation Science 2018
#   CC BY-SA 4.0
#   https://creativecommons.org/licenses/by-sa/4.0/

source ../ENV.sh

rm -f accs

echo "select 
        speciesAdjudicated.adjudicatedID,
        concat_ws(' ', nameAdjudicated, authAdjudicated) as n1, 
        statusAdjudicatedID, 
        speciesAccepted.acceptedID, 
        concat_ws(' ', nameAccepted, authAccepted) as n2, 
        taxonSource.taxonSource 
      from speciesAdjudicated 
      left join speciesAccepted on 
        speciesAdjudicated.acceptedID = speciesAccepted.acceptedID 
      left join taxonSource on 
        taxonSource.taxonSourceID = speciesAccepted.taxonSourceID 
      where 
        -- (statusAdjudicatedID = 1 or statusAdjudicatedID = 5) and 
        -- just get species, not genera
        nameAdjudicated REGEXP '[^\ ]+\ [^\ ]+';" \
            | mysql -N -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD alaskaFlora \
            | tr "\t" "|" > accs.1

# Every name occurs in the adjudicated table, with a status of a link
# to the accepted name table. The numbers used are the ID numbers in
# the adjudicated table.

sed -i -e 's/ ssp. / subsp. /g' accs.1

# fix some errors in names
patch -o accs.2 accs.1 p1.patch

# add a missing name
echo "1x|Rorippa curvipes Greene|1|4050|Rorippa curvipes Greene|Flora of North America" >> accs.2
# echo "2x|Papaver macounii Greene|1|3142|Papaver macounii Greene|Panarctic Flora Checklist" >> accs.2

gawk -f make_table.awk accs.2 > accs.3

# test it
gawk 'BEGIN{FS=OFS="|"}{if (!$10) print $0}' accs.3

gawk 'BEGIN{FS=OFS="|"}{s[$1]++;s2[$10]++}END{for (i in s2) if (!s[i]) print "no " i}' accs.3

gawk 'BEGIN{FS=OFS="|"}{print $1,$2,$3,$4,$5,$6,$7,$8}' accs.3 > accs

gawk 'BEGIN{FS=OFS="|"}{print $1,$10,$9,$11}' accs.3 > accs_rel

rm -f accs.1 accs.2  accs.3
