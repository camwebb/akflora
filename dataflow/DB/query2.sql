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

-- ALTER TABLE names ADD COLUMN name VARCHAR(200);
-- UPDATE names SET name =
--   CONCAT_WS(' ',genhyb,genus,sphyb,species,ssptype,ssp,author);

-- start with same names in both:

-- for each of ALA and PAF develop a can -rel-> can mapping:

SELECT * FROM
( select fromID, toID from rel, ortho where rel.source = "ALA" and rel







SELECT *
FROM
 (SELECT id, CONCAT_WS(' ',genhyb,genus,sphyb,species,ssptype,ssp,author) AS n
 FROM `names`) AS A
 LEFT JOIN
 (SELECT id, CONCAT_WS(' ',genhyb,genus,sphyb,species,ssptype,ssp,author) AS n
 FROM `names`) AS A
 
 ;

-- mysql -N -u cam -ptesttest tmp_ala < sql/query1.sql | sed 's/NULL//g' | tr "\t" "|" > out.csv
-- SELECT
--  A.nID AS 'fromID' , A.genhyb, A.genus, A.sphyb, A.species,
--    A.ssptype, A.ssp, A.author,
--  B.nID AS 'toID ALA', B.source, B.status, B.genhyb, B.genus, B.sphyb, B.species,
--    B.ssptype, B.ssp, B.author,
--  C.nID AS 'toID PAF', C.source, C.status, C.genhyb, C.genus, C.sphyb, C.species,
--    C.ssptype, C.ssp, C.author,
--  IF(B.status IS NOT NULL AND C.status IS NOT NULL,
--     IF(((B.status = C.status) AND (B.nID = C.nID)), 'same', 'different'), NULL) AS `BvC`
-- FROM
--  -- could also just use all names, filtering by no match
--  (SELECT DISTINCT genhyb, genus, sphyb, species,
--    ssptype, ssp, author, names.id AS nID
--    FROM rel, names where names.id = rel.fromID) AS A
-- LEFT JOIN 
--  (SELECT DISTINCT genhyb, genus, sphyb, species,
--    ssptype, ssp, author, names.id AS nID, source, status, fromID
--    FROM rel, names where names.id = rel.toID AND
--    rel.source = 'ALA') AS B
-- ON A.nID = B.fromID
-- LEFT JOIN 
--  (SELECT DISTINCT genhyb, genus, sphyb, species,
--    ssptype, ssp, author, names.id AS nID, source, status, fromID
--    FROM rel, names where names.id = rel.toID AND
--    rel.source = 'PAF') AS C
-- ON A.nID = C.fromID
-- HAVING `BvC` = 'different'
--   -- IS NOT NULL
-- ORDER BY A.genus, A.species;
