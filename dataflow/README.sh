# Master control script for assembling data for the Flora of Alaska

# Get environment variables
source ENV.sh

# Generate ACCS Alaska Checklist
if [ $AKFLORA_ACCSDB -eq 1 ]
then
    echo "Extracting ACCS data"
    cd ACCS
    sh README.sh
    cd ..
fi

# Generate ALA checklist
echo "Generating ALA data"
cd ALA
sh README.sh
cd ..

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

# Generate WCSP list
echo "Generating WCSP data"
cd WCSP
sh README.sh
cd ..


