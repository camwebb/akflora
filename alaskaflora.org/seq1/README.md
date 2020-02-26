# Webapp for entering herbarium samples

To generate ala table, run this in the SQL interface of arctos:

      SELECT GUID, PARTDETAIL, FORMATTED_SCIENTIFIC_NAME, 
        IDENTIFICATION_ID ,OTHERCATALOGNUMBERS FROM flat 
        WHERE SUBSTR(GUID,1,8) = 'UAM:Herb';

      gawk -f csv.awk ArctosUserSql_8B33D449AF.csv > plants
      gawk -f clean.awk plants > plants.csv

Note the existence of the same barcode for diff GUIDS. E.g., H1214771
= UAM:Herb:125364 and UAM:Herb:145305




