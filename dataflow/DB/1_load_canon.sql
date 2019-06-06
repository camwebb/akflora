-- -- mysqll --show-warnings

SELECT 'Making DB';

DROP DATABASE IF EXISTS `akflora`;
CREATE DATABASE `akflora` CHARSET 'utf8' COLLATE 'utf8_bin';
-- NB!! https://stackoverflow.com/questions/4558707/case-sensitive-collation-in-mysql#4558736

USE `akflora`;

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
  `author` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE '../canonical/ipni_base' INTO TABLE `names` FIELDS TERMINATED BY '|' ;

ALTER TABLE `names`
  ADD COLUMN `id` int(11) PRIMARY KEY AUTO_INCREMENT FIRST;

ALTER TABLE `names`
  ADD UNIQUE KEY `code` (`code`);

ALTER TABLE `names` ADD `md5sum` VARCHAR(50) NULL DEFAULT NULL ;

SELECT 'Making names md5sum';

UPDATE `names` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`)); 

ALTER TABLE `names`
  ADD KEY `md5sum` (`md5sum`);


-- ALTER TABLE `names` ADD `canon` TINYINT(1) NULL DEFAULT NULL ;
-- update names set canon = 1;

-- PART 2

SELECT 'Making table uids';

-- Codes

-- DROP TABLE IF EXISTS `uids`;

CREATE TABLE `uids` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `authority` varchar(20) NOT NULL,
  `canon` TINYINT(1) NULL DEFAULT NULL,
  `nameID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `uids`
 ADD KEY `nameID` (`nameID`);
ALTER TABLE `uids`
 ADD UNIQUE KEY `code` (`code`);
ALTER TABLE `uids`
 ADD UNIQUE KEY `name_canon` (`nameID`, `canon`);
-- test with: insert into uids (code, canon, nameID, authority) values ('foo', 1, 8838, 'FOO');

ALTER TABLE `uids` ADD FOREIGN KEY `fk_nameID` (`nameID`) REFERENCES `names`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

INSERT INTO `uids` (`code`, `authority`, `canon`, `nameID`) 
    SELECT `code`, 'IPNI', 1, `id` 
    FROM `names`;

ALTER TABLE `names` DROP `code`;

-- PART 3  TROP

SELECT 'TROP';

DROP TABLE IF EXISTS `tmp_trop`;
CREATE TABLE `tmp_trop` (
  `code` varchar(20) NOT NULL,
  `genhyb` enum('×') DEFAULT NULL,
  `genus` varchar(20) DEFAULT NULL,
  `sphyb` enum('×') DEFAULT NULL,
  `species` varchar(50) DEFAULT NULL,
  `ssptype` varchar(20) DEFAULT NULL,
  `ssp` varchar(30) DEFAULT NULL,
  `author` varchar(150) DEFAULT NULL
) DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE '../canonical/trop_base' INTO TABLE `tmp_trop` FIELDS TERMINATED BY '|' ;

ALTER TABLE `tmp_trop` ADD `md5sum` VARCHAR(50) NULL DEFAULT NULL ;

SELECT 'Making trop md5sum';

UPDATE `tmp_trop` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`)); 

ALTER TABLE `tmp_trop`
  ADD KEY `md5sum` (`md5sum`);

ALTER TABLE `tmp_trop` ADD `new` TINYINT(1) NULL DEFAULT NULL ;

UPDATE tmp_trop, names set `new` = 0 WHERE tmp_trop.md5sum = names.md5sum;
UPDATE tmp_trop set `new` = 1 WHERE `new` IS NULL;

-- Old way: INSERT INTO `names` (`genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`, `md5sum`) SELECT DISTINCT tmp_trop.`genhyb`, tmp_trop.`genus`, tmp_trop.`sphyb` , tmp_trop.`species` , tmp_trop.`ssptype` , tmp_trop.`ssp` , tmp_trop.`author`, tmp_trop.`md5sum` FROM tmp_trop LEFT JOIN `names` ON names.md5sum = tmp_trop.md5sum WHERE `names`.md5sum IS NULL;

INSERT INTO `names` (`genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`, `md5sum`) SELECT DISTINCT tmp_trop.`genhyb`, tmp_trop.`genus`, tmp_trop.`sphyb` , tmp_trop.`species` , tmp_trop.`ssptype` , tmp_trop.`ssp` , tmp_trop.`author`, tmp_trop.`md5sum` FROM tmp_trop WHERE tmp_trop.new = 1;

INSERT INTO `uids` (`code`, authority, nameID) SELECT `code`, 'TROP', names.id from tmp_trop, names where tmp_trop.md5sum = names.md5sum;

UPDATE uids, names, tmp_trop set canon = 1 WHERE uids.nameID = names.id AND names.md5sum = tmp_trop.md5sum and tmp_trop.new = 1;

DROP TABLE tmp_trop;

-- PART 4 WCSP

SELECT 'WCSP';

DROP TABLE IF EXISTS `tmp_wcsp`;
CREATE TABLE `tmp_wcsp` (
  `code` varchar(20) NOT NULL,
  `genhyb` enum('×') DEFAULT NULL,
  `genus` varchar(20) DEFAULT NULL,
  `sphyb` enum('×') DEFAULT NULL,
  `species` varchar(50) DEFAULT NULL,
  `ssptype` varchar(20) DEFAULT NULL,
  `ssp` varchar(30) DEFAULT NULL,
  `author` varchar(150) DEFAULT NULL
) DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE '../canonical/wcsp_base' INTO TABLE `tmp_wcsp` FIELDS TERMINATED BY '|' ;

ALTER TABLE `tmp_wcsp` ADD `md5sum` VARCHAR(50) NULL DEFAULT NULL ;

SELECT 'Making wcsp md5sum';

UPDATE `tmp_wcsp` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`)); 

ALTER TABLE `tmp_wcsp`
  ADD KEY `md5sum` (`md5sum`);

ALTER TABLE `tmp_wcsp` ADD `new` TINYINT(1) NULL DEFAULT NULL ;

UPDATE tmp_wcsp, names set `new` = 0 WHERE tmp_wcsp.md5sum = names.md5sum;
UPDATE tmp_wcsp set `new` = 1 WHERE `new` IS NULL;

-- Old way: INSERT INTO `names` (`genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`, `md5sum`) SELECT DISTINCT tmp_wcsp.`genhyb`, tmp_wcsp.`genus`, tmp_wcsp.`sphyb` , tmp_wcsp.`species` , tmp_wcsp.`ssptype` , tmp_wcsp.`ssp` , tmp_wcsp.`author`, tmp_wcsp.`md5sum` FROM tmp_wcsp LEFT JOIN `names` ON names.md5sum = tmp_wcsp.md5sum WHERE `names`.md5sum IS NULL;

INSERT INTO `names` (`genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`, `md5sum`) SELECT DISTINCT tmp_wcsp.`genhyb`, tmp_wcsp.`genus`, tmp_wcsp.`sphyb` , tmp_wcsp.`species` , tmp_wcsp.`ssptype` , tmp_wcsp.`ssp` , tmp_wcsp.`author`, tmp_wcsp.`md5sum` FROM tmp_wcsp WHERE tmp_wcsp.new = 1;

INSERT INTO `uids` (`code`, authority, nameID) SELECT `code`, 'WCSP', names.id from tmp_wcsp, names where tmp_wcsp.md5sum = names.md5sum;

UPDATE uids, names, tmp_wcsp set canon = 1 WHERE uids.nameID = names.id AND names.md5sum = tmp_wcsp.md5sum and tmp_wcsp.new = 1;

DROP TABLE tmp_wcsp;

-- select * from uids where nameID = 10504;
-- +-------+---------------+-----------+-------+--------+
-- | id    | code          | authority | canon | nameID |
-- +-------+---------------+-----------+-------+--------+
-- | 27354 | trop-26300007 | TROP      |  NULL |  10504 |
-- | 36859 | kew-309015    | WCSP      |  NULL |  10504 |
-- |  7630 | ipni-603593-1 | IPNI      |     1 |  10504 |
-- +-------+---------------+-----------+-------+--------+

-- select count(*) from names;
--     18048 

-- select count(*), authority from names, uids where names.id = uids.nameID and uids.canon = 1 group by uids.authority;
-- +----------+-----------+
-- | count(*) | authority |
-- +----------+-----------+
-- |    10518 | IPNI      |
-- |     6854 | TROP      |
-- |      676 | WCSP      |
-- +----------+-----------+


