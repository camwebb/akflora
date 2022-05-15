SELECT
  R1.source AS 'src1', N1.name AS 'name1',    A1.in_ak AS 'alsaka1',
  R1.status AS 'status1', R1.refs AS 'refs1', S1.name AS 'syn1', 
  R2.source AS 'src2', N2.name AS 'name2',    A2.in_ak AS 'alsaka2',
  R2.status AS 'status2', R2.refs AS 'refs2', S2.name AS 'syn2'
  -- start with Rel 1
  FROM      rel AS R1
  -- ortho
  LEFT JOIN names AS O1 ON R1.fromID = O1.id
  -- unortho
  LEFT JOIN names AS O2 ON O1.orthoID = O2.orthoID
  -- get Rel 2 status
  LEFT JOIN rel AS R2 ON O2.id = R2.fromID
  -- get the names themselves (redundent, but easier to understand)
  LEFT JOIN names AS N1 ON R1.fromID = N1.id
  LEFT JOIN names AS N2 ON R2.fromID = N2.id
  LEFT JOIN names AS S1 ON R1.toID = S1.id
  LEFT JOIN names AS S2 ON R2.toID = S2.id
  -- get Alaska status
  LEFT JOIN `ak` AS A1 ON R1.fromID = A1.id
  LEFT JOIN `ak` AS A2 ON R2.fromID = A2.id
WHERE
  R1.`source` = @s1 AND R2.`source` = @s2 AND
  R1.status != R2.status AND
  ( A1.in_ak = 1 OR A2.in_ak = 1 )
  ORDER BY N1.name
;  
