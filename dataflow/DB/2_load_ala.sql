SELECT 'Making table ala_tmp';

DROP TABLE IF EXISTS `ala_tmp`;
CREATE TABLE `ala_tmp` (
  `code` varchar(30),
  `genhyb` enum('×') DEFAULT NULL,
  `genus` varchar(20) DEFAULT NULL,
  `sphyb` enum('×') DEFAULT NULL,
  `species` varchar(50) DEFAULT NULL,
  `ssptype` varchar(20) DEFAULT NULL,
  `ssp` varchar(30) DEFAULT NULL,
  `author` varchar(100) DEFAULT NULL,
  `accsyn` varchar(30) DEFAULT NULL
) ;

LOAD DATA LOCAL INFILE 'ala' INTO TABLE `ala_tmp` FIELDS TERMINATED BY '|' ;

ALTER TABLE `ala_tmp` ADD `md5sum` VARCHAR(50) NULL DEFAULT NULL ;

SELECT 'Making md5sum';

UPDATE `ala_tmp` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`));

ALTER TABLE `ala_tmp` ADD UNIQUE INDEX `md5sum` (`md5sum`);

SELECT 'Inserting names';

INSERT INTO `names` (`genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`)
    SELECT DISTINCT `ala_tmp`.`genhyb`, `ala_tmp`.`genus`, `ala_tmp`.`sphyb` , `ala_tmp`.`species` , `ala_tmp`.`ssptype` , `ala_tmp`.`ssp` , `ala_tmp`.`author`
    FROM `ala_tmp` LEFT JOIN `names` AS `A` ON  `ala_tmp`.`md5sum` = `A`.`md5sum` WHERE `A`.`md5sum` IS NULL ;

SELECT 'Remaking names.md5sum as a check';
UPDATE `names` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`)); 

-- test
select count(*) as '...new ALA names:' from names where `can` IS NULL;

INSERT INTO `uids` (`code`, `authority`, `nameID`) 
SELECT DISTINCT ala_tmp.`code`, 'ALA' , `names`.`id`
    FROM `ala_tmp`,`names`
    WHERE ala_tmp.md5sum = `names`.`md5sum` ;

SELECT 'making ala_rel';

DROP TABLE IF EXISTS ala_rel;
CREATE TABLE `ala_rel` (
  `code` varchar(20) NOT NULL,
  `tocode` varchar(20) DEFAULT NULL,
  `refs` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE 'ala_refs' INTO TABLE `ala_rel` FIELDS TERMINATED BY '|' ;

ALTER TABLE `ala_rel`
 ADD INDEX `code` (`code`);
ALTER TABLE `ala_rel`
 ADD INDEX `tocode` (`tocode`);
ALTER TABLE `ala_rel`
  ADD COLUMN `status` ENUM('accepted','synonym') NULL DEFAULT NULL
  AFTER `tocode`; 
ALTER TABLE `ala_rel`
 ADD COLUMN `source` varchar(10) DEFAULT 'ALA' AFTER `status`;
UPDATE `ala_rel` SET `status` = 'accepted' WHERE `tocode` = 'accepted';
UPDATE `ala_rel` SET `status` = 'synonym' WHERE `tocode` != 'accepted';
UPDATE `ala_rel` SET `tocode` = NULL WHERE `tocode` = 'accepted';

-- test via FK

ALTER TABLE `ala_rel` ADD FOREIGN KEY `fk_code` (`code`) REFERENCES `uids`(`code`) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE `ala_rel` ADD FOREIGN KEY `fk_tocode` (`tocode`) REFERENCES `uids`(`code`) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE `ala_rel`
  ADD COLUMN `fromID` int(11) NULL DEFAULT NULL FIRST; 
ALTER TABLE `ala_rel`
  ADD COLUMN `toID` int(11) NULL DEFAULT NULL AFTER `fromID`; 

UPDATE `ala_rel`, uids SET `ala_rel`.`fromID` = `uids`.`nameID` WHERE `uids`.`code` = `ala_rel`.`code` ;

UPDATE `ala_rel`, uids SET `ala_rel`.`toID` = `uids`.`nameID` WHERE `uids`.`code` = `ala_rel`.`tocode` ;

-- move to main rel

RENAME TABLE `ala_rel` TO `rel`;
alter TABLE `rel` DROP FOREIGN KEY `fk_code`;
alter TABLE `rel` DROP FOREIGN KEY `fk_tocode`;
alter TABLE `rel` DROP COLUMN `code`;
alter TABLE `rel` DROP COLUMN `tocode`;


-- Compare!

-- select rel.source, rel.status, A.genhyb, A.genus, A.sphyb, A.species, A.ssptype, A.ssp, A.author, B.genhyb, B.genus, B.sphyb, B.species, B.ssptype, B.ssp, B.author from rel left join names as A on rel.fromID = A.id left join names as B on rel.toID = B.id ORDER BY A.genus, A.species;

-- SELECT
--  A.genhyb, A.genus, A.sphyb, A.species,
--    A.ssptype, A.ssp, A.author,
--  B.source, B.status, B.genhyb, B.genus, B.sphyb, B.species,
--    B.ssptype, B.ssp, B.author,
--  C.source, C.status, C.genhyb, C.genus, C.sphyb, C.species,
--    C.ssptype, C.ssp, C.author
-- FROM
--  (SELECT DISTINCT genhyb, genus, sphyb, species,
--    ssptype, ssp, author, names.id AS nID
--    FROM rel, names where names.id = rel.toID) AS A
-- LEFT JOIN 
--  (SELECT DISTINCT genhyb, genus, sphyb, species,
--    ssptype, ssp, author, names.id AS nID, source, status
--    FROM rel, names where names.id = rel.fromID AND
--    rel.source = 'ALA') AS B
-- ON A.nID = B.nID
-- LEFT JOIN 
--  (SELECT DISTINCT genhyb, genus, sphyb, species,
--    ssptype, ssp, author, names.id AS nID, source, status
--    FROM rel, names where names.id = rel.fromID AND
--    rel.source = 'ala') AS C
-- ON A.nID = C.nID
-- ORDER BY A.genus, A.species;

