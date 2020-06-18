# Webapp for entering herbarium samples

To generate ala table, run this in the SQL interface of arctos:

      SELECT GUID, PARTDETAIL, FORMATTED_SCIENTIFIC_NAME, 
        IDENTIFICATION_ID ,OTHERCATALOGNUMBERS, DEC_LONG, DEC_LAT FROM flat 
        WHERE SUBSTR(GUID,1,8) = 'UAM:Herb';

      gawk -f csv.awk ArctosUserSql_8B33D449AF.csv > plants
      gawk -f clean.awk plants > plants.csv

Note the existence of the same barcode for diff GUIDS. E.g., H1214771
= UAM:Herb:125364 and UAM:Herb:145305

      gawk -f scripts/csv.awk ArctosUserSql_11412E4130.csv > plants
      gawk -f scripts/clean.awk plants > plants.csv
      echo "sample_no,barcode,ala_no,guid,det,sex,notes,long,lat" > \ 
        sample_w_ll.csv 
      gawk 'BEGIN{FS="|" ; OFS="," ; while ((getline < "plants.csv")>0) \
        { lng[$1] = $5; lat[$1] = $6}}{gsub(/,/,";",$0); print $2 ,  \
        $8 , $9, $10,  $11,  $4,  $5, lng[$8] , lat[$8]}' samples >> \
        sample_w_ll.csv
      sort -t "," -k 5 sample_w_ll.csv > out1.csv
      sort -t "," -k 5 sample_w_ll.csv > out2.csv
      ogr2ogr -f KML samples1.kml out1.csv -oo X_POSSIBLE_NAMES=long -oo \
        Y_POSSIBLE_NAMES=lat -oo KEEP_GEOM_COLUMNS=NO
      ogr2ogr -f KML samples2.kml out2.csv -oo X_POSSIBLE_NAMES=long -oo \
        Y_POSSIBLE_NAMES=lat -oo KEEP_GEOM_COLUMNS=NO
      
