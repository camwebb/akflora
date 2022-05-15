-- SELECT
--   N1.name AS canon,
--   U1.code,
--   S1.syn,
--   O1.name AS srcName, A1.src AS akSrc
--   FROM
--   names AS N1
--   LEFT JOIN
--     ( SELECT nameID, GROUP_CONCAT(code) AS code
--       FROM uids
--       GROUP BY nameID
--     )
--   AS U1 ON N1.id = U1.nameID
--   LEFT JOIN names AS O1 ON O1.orthoID = N1.id
--   LEFT JOIN
--     ( SELECT nameID, GROUP_CONCAT(source) AS src
--       FROM ak
--       WHERE in_ak = 1
--       GROUP BY nameID
--     )
--   AS A1 ON O1.id = A1.nameID
--   LEFT JOIN
--     ( SELECT toID, GROUP_CONCAT(fromID) AS syn
--       FROM rel
--       GROUP BY toID
--     )
--   AS S1 ON N1.id = S1.toID
--   WHERE
--   A1.src IS NOT NULL;

-- -- synonyms

-- SELECT DISTINCT
--   N1.name AS canon,
--   N1.id, O1.id, R1.fromID, A1.src
--   FROM
--     names AS N1
--   RIGHT JOIN names AS O1 ON O1.orthoID = N1.id
--   RIGHT JOIN rel   AS R1 ON R1.toID = O1.id
--   LEFT JOIN
--     ( SELECT nameID, GROUP_CONCAT(source) AS src
--       FROM ak
--       WHERE in_ak = 1
--       GROUP BY nameID
--     )
--   AS A1 ON O1.id = A1.nameID
--   WHERE R1.status = 'accepted'
--   AND   A1.src IS NOT NULL;


-- synonyms 2


SELECT
  g2f.fam,
  N1.name AS canon,
  U1.code AS canonUID,
  A1.akStmt, S1.accStmt, S2.synStmt
  -- anchor in the full name list
  FROM names AS N1
  -- join the chosen UIDs from the canonical name list, where they exist
  LEFT JOIN uids  AS U1 ON N1.canuidID = U1.id
  -- join the statements about being in AK, filter that this is not null
  LEFT JOIN
    ( SELECT orthoID, GROUP_CONCAT(ak.source) AS akStmt
      FROM names, ak
      WHERE names.id = ak.nameID
      AND in_ak = 1
      GROUP BY orthoID
    ) AS A1 ON N1.id = A1.orthoID
  -- join the statements about the name being accepted, filter this != null
  LEFT JOIN
    ( SELECT orthoID, GROUP_CONCAT(rel.source) AS accStmt
      FROM names, rel
      WHERE names.id = rel.fromID
      AND rel.status = 'accepted'
      GROUP BY orthoID
    ) AS S1 ON N1.id = S1.orthoID
  -- join the statements about synonyms, where they exist
  LEFT JOIN
    ( SELECT orthoID, GROUP_CONCAT(X1.syn SEPARATOR '; ') AS synStmt
      FROM names, (
        SELECT fromID, CONCAT_WS('', '{#bf ', source, '}:',name) AS syn
        FROM rel, names WHERE rel.toID = names.id AND rel.status = 'synonym'
      ) AS X1
      WHERE X1.fromID = names.id
      GROUP BY orthoID
    ) AS S2 ON N1.id = S2.orthoID
  -- just the angiosperms and gymnosperms
  LEFT JOIN g2f ON N1.genus = g2f.gen
  WHERE A1.orthoID IS NOT NULL
  AND   S1.orthoID IS NOT NULL
  AND   (g2f.`class` = 'A' OR g2f.`class` = 'G' OR g2f.`class` = 'P')
  ORDER BY g2f.fam, N1.name ;

