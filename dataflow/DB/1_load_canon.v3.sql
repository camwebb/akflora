-- -- mysql --show-warnings

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

LOAD DATA LOCAL INFILE 'canon' INTO TABLE `names` FIELDS TERMINATED BY '|' ;

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
    SELECT `code`, UPPER(SUBSTR(`code`,1,4)), 1, `id` 
    FROM `names`;

ALTER TABLE `names` DROP `code`;

update uids set authority = 'WCSP' where authority = 'KEW-';

-- select count(*), authority from names, uids where names.id = uids.nameID and uids.canon = 1 group by uids.authority;
-- +----------+-----------+
-- | count(*) | authority |
-- +----------+-----------+
-- |    13775 | IPNI      |
-- |     4890 | TROP      |
-- |      787 | WCSP      |
-- +----------+-----------+

-- before stripping the auto_punct and manual, was:
-- select count(*), authority from names, uids where names.id = uids.nameID and uids.canon = 1 group by uids.authority;
-- +----------+-----------+
-- | count(*) | authority |
-- +----------+-----------+
-- |    10518 | IPNI      |
-- |     6854 | TROP      |
-- |      676 | WCSP      |
-- +----------+-----------+

