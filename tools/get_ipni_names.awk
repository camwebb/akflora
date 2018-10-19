# get_ipni_names.awk
# Download IPNI data for an input set of taxa
# (c) Cam Webb 2018;
# License: Public Domain/UNLICENSE <https://unlicense.org/>

# Usage: gawk -f get_ipni_names.awk namesfile > ipnidataout
# On another server, check for gawk and curl, and run with
#   nohup gawk -f get_ipni_names.awk namesfile > ipnidataout & 
# Check progress with: tail ipnidataout

BEGIN{
  # Config:
  # Set your INFILE delimiters
  FS =  "|";
  RS = FILERS = "\n";
  # Map your field order, by changing values for variables (1, 2, ...)
  fGen  =  1;  # Genus
  fSp   =  2;  # Species
  fRank =  3;  # Rank of infraspecific epithet [ var. | f. | subsp. ]
  fSsp  =  4;  # Infraspecific epithet

  ORS="";
}

{
  # for each line in the input file
  gsub(/ /,"",$0); # clean any spaces in INFILE
  data = "";

  # Query IPNI API, drop the header line, kill any pipes in data,
  #    switch delimiter to pipe 
  cmd = "curl -s 'http://www.ipni.org/ipni/advPlantNameSearch.do?find_genus=" $fGen "&find_species=" $fSp "&find_infraspecies=" $fSsp "&output_format=delimited-extended' | sed -e '1d' -e 's/|/./g' -e 's/%/|/g'" ;
  
  RS="\x04";
  cmd | getline data;
  close(cmd);
  if (!data) print "# " $fGen " " $fSp " " $fSsp " not found in IPNI\n" ;
  else print data;
  RS = FILERS;
  
}

# The IPNI fields are (http://www.ipni.org/ipni/delimited_help.html):
#  1. Id
#  2. Version
#  3. Family
#  4. Infra family
#  5. Hybrid genus
#  6. Genus
#  7. Infra genus
#  8. Hybrid
#  9. Species
# 10. Species author
# 11. Infra species
# 12. Rank
# 13. Authors
# 14. Basionym author
# 15. Standardised basionym author flag
# 16. Publishing author
# 17. Standardised publishing author flag
# 18. Full name
# 19. Full name without family
# 20. Full name without authors
# 21. Full name without family and authors
# 22. Reference
# 23. Publication
# 24. Standardised publication flag
# 25. Collation
# 26. Publication year full
# 27. Publication year
# 28. publication year note
# 29. Publication year text
# 30. Volume
# 31. Start page
# 32. End page
# 33. Primary pagination
# 34. Secondary pagination
# 35. Reference remarks
# 36. Name status
# 37. Remarks
# 38. Hybrid parents
# 39. Basionym
# 40. Replaced synonym
# 41. Replaced synonym Author team
# 42. Nomenclatural synonym
# 43. Other links
# 44. Same citation as
# 45. Distribution
# 46. Citation type
# 47. Bibliographic reference
# 48. Bibliographic type info
# 49. Collection date as text
# 50. Collection day1
# 51. Collection month1
# 52. Collection year1
# 53. Collection day2
# 54. Collection month2
# 55. Collection year2
# 56. Collection number
# 57. Collector team as text
# 58. Geographic unit as text
# 59. Locality
# 60. Latitude degrees
# 61. Latitude minutes
# 62. Latitude seconds
# 63. North or south
# 64. Longitude degrees
# 65. Longitude minutes
# 66. Longitude seconds
# 67. East or west
# 68. Type remarks
# 69. Type name
# 70. Type locations
# 71. Original taxon name
# 72. Original taxon name author team
# 73. Original replaced synonym
# 74. Original replaced synonym author team
# 75. Original basionym
# 76. Original basionym author team
# 77. Original parent citation taxon name author team
# 78. Original taxon distribution
# 79. Original hybrid parentage
# 80. Original cited type
# 81. Original remarks
