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

echo "select concat('accs-', adjudicatedID) as guid, \
  concat_ws(' ', nameAdjudicated, authAdjudicated) as name \
  from speciesAdjudicated where nameAdjudicated REGEXP '[^\ ]+\ [^\ ]+';" \
    | mysql -N -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD alaskaFlora | \
    tr "\t" "|" > accs
