-- mysql -N -u cam -ptesttest tmp_ala < sql/query1.sql | sed 's/NULL//g' | tr "\t" "|" > out.csv
SELECT
 A.nID AS 'fromID' , A.genhyb, A.genus, A.sphyb, A.species,
   A.ssptype, A.ssp, A.author,
 B.nID AS 'toID ALA', B.source, B.status, B.genhyb, B.genus, B.sphyb, B.species,
   B.ssptype, B.ssp, B.author,
 C.nID AS 'toID PAF', C.source, C.status, C.genhyb, C.genus, C.sphyb, C.species,
   C.ssptype, C.ssp, C.author,
 IF(B.status IS NOT NULL AND C.status IS NOT NULL,
    IF(((B.status = C.status) AND (B.nID = C.nID)), 'same', 'different'), NULL) AS `BvC`
FROM
 -- could also just use all names, filtering by no match
 (SELECT DISTINCT genhyb, genus, sphyb, species,
   ssptype, ssp, author, names.id AS nID
   FROM rel, names where names.id = rel.fromID) AS A
LEFT JOIN 
 (SELECT DISTINCT genhyb, genus, sphyb, species,
   ssptype, ssp, author, names.id AS nID, source, status, fromID
   FROM rel, names where names.id = rel.toID AND
   rel.source = 'ALA') AS B
ON A.nID = B.fromID
LEFT JOIN 
 (SELECT DISTINCT genhyb, genus, sphyb, species,
   ssptype, ssp, author, names.id AS nID, source, status, fromID
   FROM rel, names where names.id = rel.toID AND
   rel.source = 'PAF') AS C
ON A.nID = C.fromID
HAVING `BvC` = 'different'
  -- IS NOT NULL
ORDER BY A.genus, A.species;
