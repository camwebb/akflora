SELECT 'Making table paf_tmp';

DROP TABLE IF EXISTS `paf_tmp`;
CREATE TABLE `paf_tmp` (
  `paf_code` varchar(30),
  `genhyb` enum('×') DEFAULT NULL,
  `genus` varchar(20) DEFAULT NULL,
  `sphyb` enum('×') DEFAULT NULL,
  `species` varchar(50) DEFAULT NULL,
  `ssptype` varchar(20) DEFAULT NULL,
  `ssp` varchar(30) DEFAULT NULL,
  `author` varchar(100) DEFAULT NULL
) ;

LOAD DATA LOCAL INFILE 'paf-names' INTO TABLE `paf_tmp` FIELDS TERMINATED BY '|' ;

ALTER TABLE `paf_tmp` ADD `md5sum` VARCHAR(50) NULL DEFAULT NULL ;

SELECT 'Making md5sum';

UPDATE `paf_tmp` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`));

ALTER TABLE `paf_tmp` ADD UNIQUE INDEX `md5sum` (`md5sum`);

-- SELECT DISTINCT `paf_tmp`.paf_code, B.code  FROM `paf_tmp` LEFT JOIN `names` AS `A` ON  `paf_tmp`.`md5sum` = `A`.`md5sum` LEFT JOIN uids AS B ON A.id = B.nameID WHERE `A`.`md5sum` IS NOT NULL;
-- nice! But...:

-- SELECT DISTINCT `paf_tmp`.paf_code FROM `paf_tmp` LEFT JOIN `names` AS `A` ON  `paf_tmp`.`md5sum` = `A`.`md5sum` WHERE `A`.`md5sum` IS NULL;
-- 1660 not matched. Ah well.

SELECT 'Inserting names';

INSERT INTO `names` (`genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`)
    SELECT DISTINCT `paf_tmp`.`genhyb`, `paf_tmp`.`genus`, `paf_tmp`.`sphyb` , `paf_tmp`.`species` , `paf_tmp`.`ssptype` , `paf_tmp`.`ssp` , `paf_tmp`.`author`
    FROM `paf_tmp` LEFT JOIN `names` AS `A` ON  `paf_tmp`.`md5sum` = `A`.`md5sum` WHERE `A`.`md5sum` IS NULL ;

SELECT 'Remaking names.md5sum as a check';
UPDATE `names` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`)); 

INSERT INTO `uids` (`code`, `authority`, `nameID`) 
SELECT DISTINCT paf_tmp.`paf_code`, 'PAF' , `names`.`id`
    FROM `paf_tmp`,`names`
    WHERE paf_tmp.md5sum = `names`.`md5sum` ;

-- -> 2822 PAF names in DB (acc and syn)

SELECT 'making paf_rel';

DROP TABLE IF EXISTS paf_rel;
CREATE TABLE `paf_rel` (
  `code` varchar(20) NOT NULL,
  `status` varchar(10) DEFAULT NULL,
  `comments` varchar(200) DEFAULT NULL,
  `tocode` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
  
LOAD DATA LOCAL INFILE 'paf-rel' INTO TABLE `paf_rel` FIELDS TERMINATED BY '|' ;

ALTER TABLE `paf_rel`
 ADD KEY `code` (`code`);
ALTER TABLE `paf_rel`
 ADD KEY `tocode` (`tocode`);

-- test via FK

ALTER TABLE `paf_rel` ADD FOREIGN KEY `fk_code` (`code`) REFERENCES `uids`(`code`) ON DELETE RESTRICT ON UPDATE RESTRICT;

-- failed first time paf-863101-s10 missing. Not sure why.
-- select uids.code, paf_rel.code from paf_rel LEFT JOIN uids ON uids.code = paf_rel.code where uids.code IS NULL;

ALTER TABLE `paf_rel` ADD FOREIGN KEY `fk_tocode` (`tocode`) REFERENCES `uids`(`code`) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE `paf_rel`
  ADD COLUMN `fromID` int(11) NULL DEFAULT NULL; 
ALTER TABLE `paf_rel`
  ADD COLUMN `toID` int(11) NULL DEFAULT NULL; 

UPDATE `paf_rel`, uids SET `paf_rel`.`fromID` = `uids`.`nameID` WHERE `uids`.`code` = `paf_rel`.`code` ;

UPDATE `paf_rel`, uids SET `paf_rel`.`toID` = `uids`.`nameID` WHERE `uids`.`code` = `paf_rel`.`tocode` ;
--2823

INSERT INTO rel (status, comments, fromID, toID) select status, comments, fromID, toID from paf_rel;

-- OK

-- Add this earlier!!!! Above
ALTER TABLE `rel` ADD `source` VARCHAR(10) NULL DEFAULT NULL ;
update rel set source = 'ALA' where comments != 'PAF 2018' OR comments IS NULL;
update rel set source = 'PAF' where comments = 'PAF 2018';

-- Compare!

-- select rel.source, rel.status, A.genhyb, A.genus, A.sphyb, A.species, A.ssptype, A.ssp, A.author, B.genhyb, B.genus, B.sphyb, B.species, B.ssptype, B.ssp, B.author from rel left join names as A on rel.fromID = A.id left join names as B on rel.toID = B.id ORDER BY A.genus, A.species;

SELECT
 A.genhyb, A.genus, A.sphyb, A.species,
   A.ssptype, A.ssp, A.author,
 B.source, B.status, B.genhyb, B.genus, B.sphyb, B.species,
   B.ssptype, B.ssp, B.author,
 C.source, C.status, C.genhyb, C.genus, C.sphyb, C.species,
   C.ssptype, C.ssp, C.author
FROM
 (SELECT DISTINCT genhyb, genus, sphyb, species,
   ssptype, ssp, author, names.id AS nID
   FROM rel, names where names.id = rel.toID) AS A
LEFT JOIN 
 (SELECT DISTINCT genhyb, genus, sphyb, species,
   ssptype, ssp, author, names.id AS nID, source, status
   FROM rel, names where names.id = rel.fromID AND
   rel.source = 'ALA') AS B
ON A.nID = B.nID
LEFT JOIN 
 (SELECT DISTINCT genhyb, genus, sphyb, species,
   ssptype, ssp, author, names.id AS nID, source, status
   FROM rel, names where names.id = rel.fromID AND
   rel.source = 'PAF') AS C
ON A.nID = C.nID
ORDER BY A.genus, A.species;

