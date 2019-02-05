declare namespace bio = "http://www.github.com/biosemantics" ;
declare variable $file external ; 
for $name in /bio:treatment/taxon_identification
return
  concat(
    $file,
    "|",
    $name/taxon_name[@rank="genus"]/string(),
    "|",
    $name/taxon_name[@rank="species"]/string(),
    "|",
    $name/taxon_name[@rank="species"]/@authority/string(),
    "|",
    $name/taxon_name[@rank="subspecies"]/string(),
    "|",
    $name/taxon_name[@rank="subspecies"]/@authority/string(),
    "|",
    $name/taxon_name[@rank="variety"]/string(),
    "|",
    $name/taxon_name[@rank="variety"]/@authority/string(),
    "|",
    $name[@status="ACCEPTED"]/../description[@type="distribution"]/string(),
    "|",
    $name/@status/string()
)
  