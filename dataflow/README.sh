# Master control script for assembling data for the Flora of Alaska

# Get environment variables
source ENV.sh

# Generate ACCS Alaska Checklist
# **NB do not run this unless you have the ACCS alaskaFlora database**
if [ $AKFLORA_ACCSDB -eq 1 ]
then
    echo "Extracting ACCS data" > "/dev/stderr"
    cd ACCS
    sh README.sh
fi

