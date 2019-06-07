
SELECT
 `ortho`.`type`,
 CONCAT_WS(' ', A.genhyb, A.genus, A.sphyb, A.species,
   A.ssptype, A.ssp, A.author) as A, 
 CONCAT_WS(' ', B.genhyb, B.genus, B.sphyb, B.species,
   B.ssptype, B.ssp, B.author) as B, A.codes as Ac, B.codes as Bc
FROM
 `ortho`
 LEFT JOIN
 (SELECT names.*, group_concat(code) AS codes FROM names, uids
  WHERE uids.nameID = names.id  
  GROUP BY names.id) AS A ON A.id = ortho.fromID
 LEFT JOIN
 (SELECT names.*, group_concat(code) AS codes FROM names, uids
  WHERE uids.nameID = names.id  
  GROUP BY names.id) AS B ON B.id = ortho.toID
-- WHERE A.codes REGEXP ','
  ;
