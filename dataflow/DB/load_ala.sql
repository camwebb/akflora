-- mysqll --show-warnings

SELECT 'Making DB';

DROP DATABASE IF EXISTS `tmp_ala`;
CREATE DATABASE `tmp_ala` CHARSET 'utf8' COLLATE 'utf8_bin';
-- NB!! https://stackoverflow.com/questions/4558707/case-sensitive-collation-in-mysql#4558736

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

-- DROP TABLE IF EXISTS `names`;

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

-- DROP TABLE IF EXISTS `uids`;

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


-- DROP TABLE IF EXISTS `rel`;

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

----  ADD NEW NAMES AND uids from IPNI and TROP

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
  `matchtype` varchar(15)
) ;

LOAD DATA LOCAL INFILE 'ala-gnr-tmp' INTO TABLE `gnr_tmp` FIELDS TERMINATED BY '|' ;

ALTER TABLE `gnr_tmp` ADD `md5sum` VARCHAR(50) NULL DEFAULT NULL ;

SELECT 'Making table uids md5sum';

UPDATE `gnr_tmp` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`));

ALTER TABLE `gnr_tmp` ADD INDEX `md5sum` (`md5sum`);
ALTER TABLE `names` ADD INDEX `md5sum` (`md5sum`);

-- select max(id) from names; -->  3740 

SELECT 'Inserting new names into names';

-- weird, it doesn't add trop-144959531
-- SELECT DISTINCT `gnr_tmp`.`genhyb`, `gnr_tmp`.`genus`, `gnr_tmp`.`sphyb` , `gnr_tmp`.`species` , `gnr_tmp`.`ssptype` , `gnr_tmp`.`ssp` , `gnr_tmp`.`author`     FROM `gnr_tmp` LEFT JOIN `names` AS `A` ON  `gnr_tmp`.`md5sum` = `A`.`md5sum` WHERE `A`.`md5sum` IS NULL AND gnr_tmp.genus = 'Viola' AND gnr_tmp.species = 'langsdorffii';
-- this was due to using utf8_general_ci <- case insensitive!!

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

-- select * from names , uids where uids.nameID = names.id; -> 9705 rows
-- see the multiple IDs:
-- select A.* from (select names.id as id, count(names.id) as cnt from names , uids where uids.nameID = names.id group by names.id) AS A where cnt > 1;
-- select * from names, uids where names.id = uids.nameID AND uids.nameID = 3724;

-- ortho 

CREATE TABLE `ortho` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `fromID` int(11) NOT NULL,
  `toID` int(11) NOT NULL,
  `source` varchar(10) NOT NULL,
  `type` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `ortho` ADD INDEX `fromID` (`fromID`);
ALTER TABLE `ortho` ADD INDEX `toID` (`toID`);

ALTER TABLE `gnr_tmp` ADD COLUMN `alaID` int(11) DEFAULT NULL;
ALTER TABLE `gnr_tmp` ADD COLUMN `otherID` int(11) DEFAULT NULL;

UPDATE gnr_tmp, uids SET gnr_tmp.alaID = uids.nameID WHERE gnr_tmp.ala_code = uids.code;
-- -- test:
-- select * from gnr_tmp where alaID IS NULL;

UPDATE gnr_tmp, uids SET gnr_tmp.otherID = uids.nameID WHERE gnr_tmp.other_code = uids.code;
-- -- test:
-- select * from gnr_tmp where otherID IS NULL AND auth != 'ARCT';
-- -- (WAS Hmm: ala-2531)

INSERT INTO `ortho` ( `fromID`, `toID`, `source` , `type` )
SELECT `alaID`, `otherID`, `auth`, `matchtype` from gnr_tmp WHERE `matchtype` != 'exact';

-- See the matches:
-- select CONCAT_WS(' ',names.genhyb,names.genus,names.sphyb,names.species,names.ssptype,names.ssp,names.author) AS ala, A.source, A.type, CONCAT_WS(' ',B.genhyb,B.genus,B.sphyb,B.species,B.ssptype,B.ssp,B.author) as oth FROM `names` LEFT JOIN `ortho` AS `A` ON `names`.`id` = `A`.`fromID` LEFT JOIN `names` AS B ON A.toID = B.id WHERE A.id IS NOT NULL;

-- See the failures:
-- select ala.id from (select names.id from names, uids where names.id = uids.nameID and uids.authority = 'ALA') as ala left join (select names.id from names, uids where names.id = uids.nameID and uids.authority != 'ALA') as oth on ala.id = oth.id left join `ortho` on ala.id = ortho.fromID where oth.id IS NULL and ortho.fromID IS NULL; --> 350
-- OR :
-- select names.* from (select names.id from names, uids where names.id = uids.nameID and uids.authority = 'ALA') as ala left join (select names.id from names, uids where names.id = uids.nameID and uids.authority != 'ALA') as oth on ala.id = oth.id left join `ortho` on ala.id = ortho.fromID left join names on ala.id = names.id where oth.id IS NULL and ortho.fromID IS NULL;

-- note also you could use "not in" https://stackoverflow.com/a/19725206/563709





