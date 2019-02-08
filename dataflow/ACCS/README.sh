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

echo "select speciesAdjudicated.adjudicatedID, concat_ws(' ', nameAdjudicated, authAdjudicated) as n1, statusAdjudicatedID, speciesAccepted.acceptedID, concat_ws(' ', nameAccepted, authAccepted) as n2 from speciesAdjudicated left join speciesAccepted on speciesAdjudicated.acceptedID = speciesAccepted.acceptedID where (statusAdjudicatedID = 1 or statusAdjudicatedID = 5) and nameAdjudicated REGEXP '[^\ ]+\ [^\ ]+';" | mysql -N -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD alaskaFlora | tr "\t" "|" > accs.1

sed -i -e 's/ ssp. / subsp. /g' accs.1

gawk -f make_table.awk accs.1 > accs

rm -f accs.1
