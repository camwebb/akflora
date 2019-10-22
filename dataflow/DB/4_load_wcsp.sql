SELECT 'Making table wcsp_tmp';

CREATE TABLE `wcsp_tmp` (
  `code` varchar(20) NOT NULL,
  `genhyb` enum('×') DEFAULT NULL,
  `genus` varchar(22) NOT NULL,
  `sphyb` enum('×') DEFAULT NULL,
  `species` varchar(50) NOT NULL,
  `ssptype` varchar(20) DEFAULT NULL,
  `ssp` varchar(30) DEFAULT NULL,
  `author` varchar(100) DEFAULT NULL,
  `status` varchar(12) NOT NULL,
  `accsyn` varchar(20) DEFAULT NULL
) ;

SELECT '... reading new data';
LOAD DATA LOCAL INFILE 'wcsp' INTO TABLE `wcsp_tmp` FIELDS TERMINATED BY '|' ;

-- create md5sum for name strings
ALTER TABLE `wcsp_tmp` ADD `md5sum` VARCHAR(50) NULL DEFAULT NULL ;
UPDATE `wcsp_tmp` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`,
  `sphyb` , `species` , `ssptype` , `ssp` , `author`));
ALTER TABLE `wcsp_tmp` ADD UNIQUE INDEX `md5sum` (`md5sum`);

-- find new names and insert
SELECT '... inserting into `names`';
INSERT INTO `names` (`genhyb`, `genus`, `sphyb` , `species` , `ssptype` ,
    `ssp` , `author`)
  SELECT DISTINCT `wcsp_tmp`.`genhyb`, `wcsp_tmp`.`genus`, `wcsp_tmp`.`sphyb`,
    `wcsp_tmp`.`species` , `wcsp_tmp`.`ssptype` , `wcsp_tmp`.`ssp` ,
    `wcsp_tmp`.`author`
  FROM `wcsp_tmp`
  LEFT JOIN `names` AS `A` ON  `wcsp_tmp`.`md5sum` = `A`.`md5sum`
  WHERE `A`.`md5sum` IS NULL ;

-- Remake names.md5sum as a check
UPDATE `names` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` ,
  `species` , `ssptype` , `ssp` , `author`)); 

-- Some of the canonical names had uids that are the same as wcsp
-- (because they came from wcsp) - these do not need to be added.
--   (names and uids have been checked by compare_wcsp_uids.awk)
ALTER TABLE `wcsp_tmp` ADD `in_uids` INT(1) NULL DEFAULT 0 ;
UPDATE wcsp_tmp, uids SET in_uids = 1 WHERE wcsp_tmp.`code` = uids.`code`;
ALTER TABLE `wcsp_tmp` ADD INDEX `in_uids` (`in_uids`);

SELECT '... inserting into `uids`';
INSERT INTO `uids` (`code`, `authority`, `nameID`) 
SELECT DISTINCT wcsp_tmp.`code`, 'wcsp' , `names`.`id`
    FROM `wcsp_tmp`, `names`
    WHERE wcsp_tmp.md5sum = `names`.`md5sum`
    AND wcsp_tmp.`in_uids` != 1 ;
-- Records: 184133  Duplicates: 0  Warnings: 0

-- wcsp_ortho
SELECT 'Making table wcsp_ortho and reading in data';
CREATE TABLE `wcsp_ortho` (
  `code_wcsp`   varchar(30) NOT NULL,
  `code_canon` varchar(30) NOT NULL,
  `type`       varchar(15) NOT NULL
);
LOAD DATA LOCAL INFILE 'wcsp_ortho' INTO TABLE `wcsp_ortho`
  FIELDS TERMINATED BY '|' ;
ALTER TABLE wcsp_ortho ADD COLUMN fromID int(11) FIRST;
ALTER TABLE wcsp_ortho ADD COLUMN toID int(11) AFTER `fromID`;
update wcsp_ortho, uids set wcsp_ortho.fromID = uids.nameID
  where uids.code = wcsp_ortho.code_wcsp;
update wcsp_ortho, uids set wcsp_ortho.toID = uids.nameID
  where uids.code = wcsp_ortho.code_canon;

-- ALTER TABLE `wcsp_ortho` ADD UNIQUE INDEX `fromID` (`fromID`);
-- ALTER TABLE `wcsp_ortho` ADD INDEX `toID` (`toID`);
-- ALTER TABLE `wcsp_ortho` DROP COLUMN code_wcsp;
-- ALTER TABLE `wcsp_ortho` DROP COLUMN code_canon;
-- RENAME TABLE `wcsp_ortho` TO `ortho`;

-- Load the non-exact matches (new ones only):
INSERT INTO `ortho` (fromID, toID, `type`) SELECT wcsp_ortho.fromID,
  wcsp_ortho.toID, wcsp_ortho.`type`
  FROM `wcsp_ortho` LEFT JOIN ortho ON ortho.fromID = wcsp_ortho.fromID  WHERE
  ortho.fromID IS NULL AND
  wcsp_ortho.fromID != wcsp_ortho.toID;
-- Load the non_matches (new ones only):
INSERT INTO `ortho` (fromID, toID, `type`) SELECT wcsp_ortho.fromID, --
  wcsp_ortho.toID, 'self'
  FROM `wcsp_ortho` LEFT JOIN ortho ON ortho.fromID = wcsp_ortho.fromID  WHERE
  ortho.fromID IS NULL
  AND wcsp_ortho.fromID = wcsp_ortho.toID AND wcsp_ortho.`type` != 'exact';

select if((select count(*) from names) != (select count(*) from ortho),'names and ortho not same','names and ortho same') as 'query';

DROP TABLE `wcsp_ortho`;


-- Relationships

ALTER TABLE `wcsp_tmp`
 ADD INDEX `code` (`code`);
ALTER TABLE `wcsp_tmp`
 ADD INDEX `accsyn` (`accsyn`);
ALTER TABLE `wcsp_tmp`
 ADD INDEX `status` (`status`);

-- test via FK

ALTER TABLE `wcsp_tmp` ADD FOREIGN KEY (`code`) REFERENCES `uids`(`code`) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE `wcsp_tmp` ADD FOREIGN KEY (`accsyn`) REFERENCES `uids`(`code`) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE `wcsp_tmp`
  ADD COLUMN `fromID` int(11) NULL DEFAULT NULL FIRST; 
ALTER TABLE `wcsp_tmp`
  ADD COLUMN `toID` int(11) NULL DEFAULT NULL AFTER `fromID`; 

UPDATE `wcsp_tmp`, uids SET `wcsp_tmp`.`fromID` = `uids`.`nameID` WHERE `uids`.`code` = `wcsp_tmp`.`code` ;

UPDATE `wcsp_tmp`, uids SET `wcsp_tmp`.`toID` = `uids`.`nameID` WHERE `uids`.`code` = `wcsp_tmp`.`accsyn` ;

UPDATE `wcsp_tmp` SET `wcsp_tmp`.`status` = 'accepted' WHERE `status` = 'Accepted' ;
UPDATE `wcsp_tmp` SET `wcsp_tmp`.`status` = 'synonym' WHERE `status` = 'Synonym' ;

-- copy to main rel

INSERT INTO `rel` (`fromID`, `toID`, `status`, `source`, `refs`)
  SELECT `fromID`, `toID`, `status`, 'WCSP', NULL FROM `wcsp_tmp`
  WHERE `status` = 'accepted' OR `status` = 'synonym' ;

-- wcsp_ortho

SELECT 'Making table ortho';

DROP TABLE IF EXISTS `wcsp_ortho`;
CREATE TABLE `wcsp_ortho` (
  `code_wcsp`   varchar(30) NOT NULL,
  `code_canon` varchar(30) NOT NULL,
  `type`       varchar(15) NOT NULL
);

LOAD DATA LOCAL INFILE 'wcsp_ortho' INTO TABLE `wcsp_ortho`
  FIELDS TERMINATED BY '|' ;


ALTER TABLE wcsp_ortho ADD COLUMN fromID int(11) FIRST;

ALTER TABLE wcsp_ortho ADD COLUMN toID int(11) AFTER `fromID`;

update wcsp_ortho, uids set wcsp_ortho.fromID = uids.nameID
  where uids.code = wcsp_ortho.code_wcsp;

update wcsp_ortho, uids set wcsp_ortho.toID = uids.nameID
  where uids.code = wcsp_ortho.code_canon;

-- ALTER TABLE `wcsp_ortho` ADD UNIQUE INDEX `fromID` (`fromID`);
-- ALTER TABLE `wcsp_ortho` ADD INDEX `toID` (`toID`);
-- ALTER TABLE `wcsp_ortho` DROP COLUMN code_wcsp;
-- ALTER TABLE `wcsp_ortho` DROP COLUMN code_canon;
-- RENAME TABLE `wcsp_ortho` TO `ortho`;

-- Load the non-exact matches (new ones only):
INSERT INTO `ortho` (fromID, toID, `type`) SELECT wcsp_ortho.fromID,
  wcsp_ortho.toID, wcsp_ortho.`type`
  FROM `wcsp_ortho` LEFT JOIN ortho ON ortho.fromID = wcsp_ortho.fromID  WHERE
  ortho.fromID IS NULL AND
  wcsp_ortho.fromID != wcsp_ortho.toID;
-- Load the non_matches (new ones only):
INSERT INTO `ortho` (fromID, toID, `type`) SELECT wcsp_ortho.fromID, --
  wcsp_ortho.toID, 'self'
  FROM `wcsp_ortho` LEFT JOIN ortho ON ortho.fromID = wcsp_ortho.fromID  WHERE
  ortho.fromID IS NULL
  AND wcsp_ortho.fromID = wcsp_ortho.toID AND wcsp_ortho.`type` != 'exact';

select if((select count(*) from names) != (select count(*) from ortho),'names and ortho not same','names and ortho same') as 'query';

DROP TABLE `wcsp_ortho`;

-- -- wcsp_ortho

-- SELECT 'Making table wcsp_ortho';

-- DROP TABLE IF EXISTS `wcsp_ortho`;
-- CREATE TABLE `wcsp_ortho` (
--   `code_wcsp`   varchar(30) NOT NULL,
--   `code_canon` varchar(30) NOT NULL,
--   `type`       varchar(15) NOT NULL
-- );

-- LOAD DATA LOCAL INFILE 'wcsp_ortho' INTO TABLE `wcsp_ortho`
--   FIELDS TERMINATED BY '|' ;


-- ALTER TABLE wcsp_ortho ADD COLUMN fromID int(11) FIRST;

-- ALTER TABLE wcsp_ortho ADD COLUMN toID int(11) AFTER `fromID`;

-- update wcsp_ortho, uids set wcsp_ortho.fromID = uids.nameID
--   where uids.code = wcsp_ortho.code_wcsp;

-- update wcsp_ortho, uids set wcsp_ortho.toID = uids.nameID
--   where uids.code = wcsp_ortho.code_canon;

-- INSERT INTO `ortho` (`fromID`, `toID`, `type`)
--   SELECT `wcsp_ortho`.`fromID`, `wcsp_ortho`.`toID`, `wcsp_ortho`.`type`
--   FROM `wcsp_ortho`
--   LEFT JOIN `ortho` ON ortho.fromID = wcsp_ortho.fromID
--   WHERE ortho.fromID IS NULL;

-- DROP TABLE wcsp_ortho ;



