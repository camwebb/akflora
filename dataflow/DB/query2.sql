-- Find ala syns diff from paf syns

-- ALA code -> ALA syn
--     v         v
--   canon  ->  canon
--     =         !=
--   canon  ->  canon
--     ^         ^
-- PAF code -> PAF syn
--
--  canon -(unortho)-> ALA,PAF -(syn)-> ALAsyn,PAFsyn -(ortho)-> compare

ALTER TABLE names ADD COLUMN name VARCHAR(200);
UPDATE names SET name =
  CONCAT_WS(' ',genhyb,genus,sphyb,species,ssptype,ssp,author);

-- start with same names in both:

-- for each of ALA and PAF develop a can -rel-> can mapping:

SELECT C1.name AS 'canon', `ON`.name AS 'ortho', A3.name AS 'ala', A.refs AS 'ala-refs', P3.name AS 'paf', P.refs AS 'paf-refs' FROM `names` AS C1
  RIGHT JOIN ortho AS O ON C1.id = O.toID
  LEFT JOIN `names` AS `ON` ON O.fromID = `ON`.id
  LEFT JOIN rel AS A ON O.fromID = A.fromID AND A.`source` = 'ALA' 
  LEFT JOIN rel AS P ON O.fromID = P.fromID AND P.`source` = 'PAF' 
  LEFT JOIN ortho AS A2 ON A.toID = A2.fromID
  LEFT JOIN `names` AS A3 ON A2.toID = A3.id
  LEFT JOIN ortho AS P2 ON P.toID = P2.fromID
  LEFT JOIN `names` AS P3 ON P2.toID = P3.id
  WHERE A2.toID != P2.toID ;

ALTER TABLE names DROP COLUMN `name`;



