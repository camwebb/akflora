# Master control script for assembling data for the Flora of Alaska

# Get environment variables
source ENV.sh

# Generate ACCS Alaska Checklist
# **NB do not run this unless you have the ACCS alaskaFlora database**
if [ $AKFLORA_ACCSDB -eq 1 ]
then
    echo "Extracting ACCS data"
    cd ACCS
    sh README.sh
    cd ..
fi

# Generate FNA Alaska checklist
if [ $AKFLORA_FNAXML -eq 1 ]
then
    echo "Generating FNA data"
    cd FNA
    sh README.sh
    cd ..
fi

# Generate PAF Alaska checklist
echo "Generating FNA data"
cd PAF
sh README.sh
cd ..




