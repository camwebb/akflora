-- mysqll --show-warnings

SELECT 'Making DB';

DROP DATABASE IF EXISTS `tmp_ala`;
CREATE DATABASE `tmp_ala` CHARSET 'utf8' COLLATE 'utf8_general_ci';
USE `tmp_ala`;

-- Names first

-- 1: ID
-- 2: Genus hybrid marker
-- 3: Genus
-- 4: Species hybrid marker
-- 5: Species
-- 6: Infraspecific rank
-- 7: Infraspecific epithet
-- 8: Authorship

SELECT 'Making names';

DROP TABLE IF EXISTS `names`;

CREATE TABLE `names` (
  `code` varchar(20) NOT NULL,
  `genhyb` enum('×') DEFAULT NULL,
  `genus` varchar(20) DEFAULT NULL,
  `sphyb` enum('×') DEFAULT NULL,
  `species` varchar(50) DEFAULT NULL,
  `ssptype` varchar(20) DEFAULT NULL,
  `ssp` varchar(30) DEFAULT NULL,
  `author` varchar(100) DEFAULT NULL,
  `inak` enum('T','F') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE 'ala-names' INTO TABLE `names` FIELDS TERMINATED BY '|' ;

ALTER TABLE `names`
  ADD COLUMN `id` int(11) PRIMARY KEY AUTO_INCREMENT FIRST;

ALTER TABLE `names`
  ADD UNIQUE KEY `code` (`code`);

ALTER TABLE `names` ADD `md5sum` VARCHAR(50) NULL DEFAULT NULL ;

SELECT 'Making names md5sum';

UPDATE `names` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`)); 

SELECT 'Making table uids';

-- Codes
DROP TABLE IF EXISTS `uids`;

CREATE TABLE `uids` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `authority` varchar(20) NOT NULL,
  `nameID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `uids`
 ADD KEY `nameID` (`nameID`);
ALTER TABLE `uids`
 ADD UNIQUE KEY `code` (`code`);

ALTER TABLE `uids` ADD FOREIGN KEY `fk_nameID` (`nameID`) REFERENCES `names`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

INSERT INTO `uids` (`code`, `authority`, `nameID`) 
    SELECT `code`, 'ALA', `id` 
    FROM `names`;



-- Now relationships

-- 1: ID
-- 2: Status
-- 4: Comments
-- 5: Ref
-- 6: Acc name

SELECT 'Making table rel';


DROP TABLE IF EXISTS `rel`;

CREATE TABLE `rel` (
  `code` varchar(10) NOT NULL,
  `status` varchar(10) DEFAULT NULL,
  `comments` varchar(200) DEFAULT NULL,
  `refs` varchar(500) DEFAULT NULL,
  `tocode` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  
LOAD DATA LOCAL INFILE 'ala-rel' INTO TABLE `rel` FIELDS TERMINATED BY '|' ;

ALTER TABLE `rel`
  ADD COLUMN `id` int(11) PRIMARY KEY AUTO_INCREMENT FIRST;

ALTER TABLE `rel`
 ADD KEY `code` (`code`);
ALTER TABLE `rel`
 ADD KEY `tocode` (`tocode`);

ALTER TABLE `rel` ADD FOREIGN KEY `fk_code` (`code`) REFERENCES `names`(`code`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `rel` ADD FOREIGN KEY `fk_tocode` (`tocode`) REFERENCES `names`(`code`) ON DELETE RESTRICT ON UPDATE RESTRICT;

-- change codes to IDs

ALTER TABLE `rel`
  ADD COLUMN `fromID` int(11) NULL DEFAULT NULL; 
ALTER TABLE `rel`
  ADD COLUMN `toID` int(11) NULL DEFAULT NULL; 

ALTER TABLE `rel` ADD FOREIGN KEY `fk_fromID` (`fromID`) REFERENCES `names`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `rel` ADD FOREIGN KEY `fk_toID` (`toID`) REFERENCES `names`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

UPDATE `rel`, `names` SET `rel`.`fromID` = `names`.`id` WHERE `names`.`code` = `rel`.`code` ;
UPDATE `rel`, `names` SET `rel`.`toID` = `names`.`id` WHERE `names`.`code` = `rel`.`tocode` ;

ALTER TABLE `rel` DROP FOREIGN KEY `fk_code`;
ALTER TABLE `rel` DROP FOREIGN KEY `fk_tocode`;

ALTER TABLE `rel`
  DROP COLUMN `code`;
ALTER TABLE `rel`
  DROP COLUMN  `tocode`;

ALTER TABLE `names` DROP COLUMN `code`;

----

SELECT 'Making table gnr_tmp';

-- CREATE TEMPORARY TABLE `gnr_tmp` (
CREATE TABLE `gnr_tmp` (
  `ala_code` varchar(30),
  `auth` varchar(5),
  `other_code` varchar(30),
  `genhyb` enum('×') DEFAULT NULL,
  `genus` varchar(20) DEFAULT NULL,
  `sphyb` enum('×') DEFAULT NULL,
  `species` varchar(50) DEFAULT NULL,
  `ssptype` varchar(20) DEFAULT NULL,
  `ssp` varchar(30) DEFAULT NULL,
  `author` varchar(100) DEFAULT NULL,
  `matchtype` varchar(6)
) ;

LOAD DATA LOCAL INFILE 'ala-gnr-tmp' INTO TABLE `gnr_tmp` FIELDS TERMINATED BY '|' ;

ALTER TABLE `gnr_tmp` ADD `md5sum` VARCHAR(50) NULL DEFAULT NULL ;

SELECT 'Making table uids md5sum';

UPDATE `gnr_tmp` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`));

ALTER TABLE `gnr_tmp` ADD INDEX `md5sum` (`md5sum`);
ALTER TABLE `names` ADD INDEX `md5sum` (`md5sum`);

SELECT 'Inserting new names into names';

INSERT INTO `names` (`genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`)
    SELECT DISTINCT `gnr_tmp`.`genhyb`, `gnr_tmp`.`genus`, `gnr_tmp`.`sphyb` , `gnr_tmp`.`species` , `gnr_tmp`.`ssptype` , `gnr_tmp`.`ssp` , `gnr_tmp`.`author`
    FROM `gnr_tmp` LEFT JOIN `names` AS `A` ON  `gnr_tmp`.`md5sum` = `A`.`md5sum` WHERE `A`.`md5sum` IS NULL AND `gnr_tmp`.auth != 'ARCT';
-- delete the ARCT bit when no longer got from GNR

SELECT 'Remaking names.md5sum as a check';
UPDATE `names` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`)); 

-- now add to uids

INSERT INTO `uids` (`code`, `authority`, `nameID`) 
    SELECT DISTINCT gnr_tmp.`other_code`, gnr_tmp.`auth`, `names`.`id`
    FROM `gnr_tmp`,`names`
    WHERE gnr_tmp.md5sum = `names`.`md5sum`  AND `gnr_tmp`.auth != 'ARCT';

-- check






---

--INSERT INTO `uids` (`code`, `authority`, `nameID`) 
--    SELECT DISTINCT gnr_tmp.`other_code`, gnr_tmp.`auth`, `uids`.`id`
--    FROM `gnr_tmp`,`uids`
--    WHERE gnr_tmp.ala_code = uids.`code`;



