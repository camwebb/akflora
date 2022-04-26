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
        (statusAdjudicatedID = 1 or statusAdjudicatedID = 5) and 
        speciesAccepted.presenceAlaska = 1 AND
        -- just get species, not genera
        nameAdjudicated REGEXP '[^\ ]+\ [^\ ]+';" \
            | mysql -N -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD alaskaFlora \
            | tr "\t" "|" > accs.1

# Every name occurs in the adjudicated table, with a status of the
# link to the accepted name table. The numbers used are the ID numbers
# in the adjudicated table.

# 2020-01-17 I had 1) written the script originally to just get
# accepted and synonym names, then 2) I commented out the WHERE line
# (above), and dealt with filtering these in the awk script. Can't
# remember now why I did (2). Today, a rewrite to exclude all but
# status = 1 or 5. This query:
#   select * from speciesAdjudicated AS A LEFT JOIN
#   speciesAccepted AS B ON A.acceptedID = B.acceptedID LEFT JOIN
#   speciesAdjudicated AS C ON B.nameAccepted = C.nameAdjudicated where
#   A.statusAdjudicatedID = 2 AND C.statusAdjudicatedID != 1;
# finds three cases where there was a misapplied status, 2, pointing
# to a taxon that was not itself accepted:
#    946 Arabis hirsuta (L.) Scop.
#   1240 Artemisia campestris L.
#  10762 Salix lucida Muhl.
# these cases seem unimportant, and none of them has any
# synonyms. There are 117 cases of missapplied -> accepted name and
# these accepted names are already picked up. So seems safe to exclude
# all missapplied statuses. Similar logic for status = 4 = spelling
# variant, which is dealt with by our pipeline.

# Fixes. NB: drop the orth. var. lines (these are dealt with by the
# canonical pipeline.)
sed -i -E \
    -e 's/ ssp\. / subsp. /g' \
    -e 's/, sensu Ottawa Nat\. 23\: 137\. 1909\|/|/g' \
    -e 's/, ined\.\?\|/|/g' \
    -e 's/ThelIdium methorium/Thelidium methorium/g' \
    -e 's/So\?chting, Ka\?rnefelt/Sochting, Karnefelt/g' \
    -e 's/tornoe\?nsis/tornoensis/g' \
    -e 's/Ka\?rnef\./Karnef./g' \
    -e '/ orth\. var\.\|/d' accs.1

# add names missing from the adjudicated table:
echo "1x|Rorippa curvipes Greene|1|4050|Rorippa curvipes Greene|Flora of North America" >> accs.1
echo "2x|Papaver macounii Greene|1|3142|Papaver macounii Greene|Panarctic Flora Checklist" >> accs.1

gawk -f make_table.awk accs.1 > accs.2

# test it:
#   no second key
gawk 'BEGIN{FS=OFS="|"}{if (!$10) print $0}' accs.2
#   no first key for a second key
gawk 'BEGIN{FS=OFS="|"}{s[$1]++;s2[$10]++}END{for (i in s2) if (!s[i]) print "no " i}' accs.2

# make final files
gawk 'BEGIN{FS=OFS="|"}{print $1,$2,$3,$4,$5,$6,$7,$8}' accs.2 > accs
gawk 'BEGIN{FS=OFS="|"}{print $1,$10,$9,$11}' accs.2 > accs_rel

rm -f accs.1 accs.2
