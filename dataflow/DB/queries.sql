ALTER TABLE names ADD COLUMN name VARCHAR(200);
UPDATE names SET name =
  CONCAT_WS(' ',genhyb,genus,sphyb,species,ssptype,ssp,author);

-- 1. Ortho list:

SELECT
 `ortho`.`type`,
 CONCAT_WS(' ', A.genhyb, A.genus, A.sphyb, A.species,
   A.ssptype, A.ssp, A.author) as `from`, 
 CONCAT_WS(' ', B.genhyb, B.genus, B.sphyb, B.species,
   B.ssptype, B.ssp, B.author) as `to`, A.codes as `fromC`, B.codes as `toC`
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
 WHERE `ortho`.`type` != 'self'
  ;


-- 2. Find ala syns diff from paf syns

-- ALA code -> ALA syn
--     v         v
--   canon* ->  canon
--     =         !=
--   canon* ->  canon
--     ^         ^
-- PAF code -> PAF syn
--
--  canon* -(unortho)-> ALA,PAF -(syn)-> ALAsyn,PAFsyn -(ortho)-> compare


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

-- ALTER TABLE names DROP COLUMN `name`;


-- 3. For each PAF accepted name, which matching ALA names are not accepted?
--    paf=statusA -(ortho)-> canon -(unortho)-> ala?statusA

SELECT PN.name AS 'PAF_acc', AN.name AS 'ALA_not'
  -- start with PAF accepted names (see filter in WHERE)
  FROM      rel AS P
  -- ortho
  LEFT JOIN ortho AS O1 ON P.fromID = O1.fromID
  -- unortho
  LEFT JOIN ortho AS O2 ON O1.toID = O2.toID
  -- get status, and filter in WHERE
  LEFT JOIN rel AS A ON O2.fromID = A.fromID
  -- get the names themselves
  LEFT JOIN names AS PN ON P.fromID = PN.id
  LEFT JOIN names AS AN ON A.fromID = AN.id
WHERE
  -- filter input
  P.status = 'accepted' AND P.source = 'PAF' AND
  -- filter output
  A.status = 'synonym' AND A.source = 'ALA'
;  

-- 33

-- 3. For each ALA accepted name, which matching PAF names are not accepted?

SELECT AN.name AS 'ALA_acc', PN.name AS 'PAF_not'
  -- start with PAF accepted names (see filter in WHERE)
  FROM      rel AS A
  -- ortho
  LEFT JOIN ortho AS O1 ON A.fromID = O1.fromID
  -- unortho
  LEFT JOIN ortho AS O2 ON O1.toID = O2.toID
  -- get status, and filter in WHERE
  LEFT JOIN rel AS P ON O2.fromID = P.fromID
  -- get the names themselves
  LEFT JOIN names AS AN ON A.fromID = AN.id
  LEFT JOIN names AS PN ON P.fromID = PN.id
WHERE
  -- filter input
  A.status = 'accepted' AND A.source = 'ALA' AND
  -- filter output
  P.status = 'synonym' AND P.source = 'PAF'
;  
-- 65

-- 5. For each PAF name, which matching ALA names have a diff status? Simpler

SELECT
  R1.source AS 'src1', N1.name AS 'name1',
  R1.status AS 'status1', S1.name AS 'syn1',
  R2.source AS 'src2', N2.name AS 'name2',
  R2.status AS 'status2', S2.name AS 'syn2'
  -- start with Rel 1
  FROM      rel AS R1
  -- ortho
  LEFT JOIN ortho AS O1 ON R1.fromID = O1.fromID
  -- unortho
  LEFT JOIN ortho AS O2 ON O1.toID = O2.toID
  -- get Rel 2 status
  LEFT JOIN rel AS R2 ON O2.fromID = R2.fromID
  -- get the names themselves
  LEFT JOIN names AS N1 ON R1.fromID = N1.id
  LEFT JOIN names AS N2 ON R2.fromID = N2.id
  LEFT JOIN names AS S1 ON R1.toID = S1.id
  LEFT JOIN names AS S2 ON R2.toID = S2.id
WHERE
  R1.`source` = 'ALA' AND R2.`source` = 'PAF' AND
  R1.status != R2.status
  ORDER BY N1.name
;  


