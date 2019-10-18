-- PART 1: Names

SELECT 'Making DB';
DROP DATABASE IF EXISTS `akflora`;
CREATE DATABASE `akflora` CHARSET 'utf8' COLLATE 'utf8_bin';
-- NB!! https://stackoverflow.com/questions/4558707/case-sensitive-collation-in-mysql#4558736
USE `akflora`;

SELECT 'Making names';
-- DROP TABLE IF EXISTS `names`; -- not needed
CREATE TABLE `names` (
  `code` varchar(20) NOT NULL,
  `genhyb` enum('×') DEFAULT NULL,
  `genus` varchar(20) DEFAULT NULL,
  `sphyb` enum('×') DEFAULT NULL,
  `species` varchar(50) DEFAULT NULL,
  `ssptype` varchar(20) DEFAULT NULL,
  `ssp` varchar(30) DEFAULT NULL,
  `author` varchar(150) DEFAULT NULL
) ;
-- ENGINE=InnoDB ; -- Not needed. SHOW ENGINES: InnoDB is default

LOAD DATA LOCAL INFILE 'canon' INTO TABLE `names` FIELDS TERMINATED BY '|' ;

ALTER TABLE `names`
  ADD COLUMN `id` int(11) PRIMARY KEY AUTO_INCREMENT FIRST;
ALTER TABLE `names`
  ADD UNIQUE KEY `code` (`code`);
ALTER TABLE `names` ADD `md5sum` VARCHAR(50) NULL DEFAULT NULL ;

SELECT 'Making names md5sum';
UPDATE `names` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`)); 
ALTER TABLE `names` ADD UNIQUE INDEX `md5sum` (`md5sum`);
-- Alternatively?: ALTER TABLE `names` ADD KEY `md5sum` (`md5sum`);


-- PART 2 UIDS

SELECT 'Making table uids';
CREATE TABLE `uids` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `authority` varchar(20) NOT NULL,
  `nameID` int(11) NOT NULL
) ;

ALTER TABLE `uids` ADD KEY `nameID` (`nameID`);
ALTER TABLE `uids` ADD UNIQUE KEY `code` (`code`);

ALTER TABLE `uids` ADD FOREIGN KEY `fk_nameID` (`nameID`) REFERENCES `names`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
INSERT INTO `uids` (`code`, `authority`, `nameID`) 
    SELECT `code`, UPPER(SUBSTR(`code`,1,4)), `id` 
    FROM `names`;

ALTER TABLE `names` DROP `code`;

ALTER TABLE `names` ADD `can` TINYINT(1) NULL DEFAULT NULL ;
UPDATE `names` SET `can` = 1 ;
ALTER TABLE `names` ADD `canuidID` INT(11) NULL DEFAULT NULL ;
UPDATE `names`, `uids` SET `names`.`canuidID`= `uids`.id WHERE `names`.`id`= `uids`.`nameID` ;
update uids set authority = 'WCSP' where authority = 'KEW-';

-- select count(*), authority from names, uids where names.id = uids.nameID and names.can = 1 group by uids.authority;
-- +----------+-----------+
-- | count(*) | authority |
-- +----------+-----------+
-- |    13775 | IPNI      |
-- |     4890 | TROP      |
-- |      787 | WCSP      |
-- +----------+-----------+

-- add a dependent lookup
-- ALTER TABLE `names` ADD COLUMN can_id INT(11) 
--  AS (IF(`names`.`can` = 1, id, NULL)) PERSISTENT ;
-- Fails! see https://jira.mariadb.org/browse/MDEV-13320

-- PART 3 MAKE ORTHO (self-to-self)

SELECT 'Making table ortho';

-- DROP TABLE IF EXISTS `ortho`;
CREATE TABLE `ortho` (
  `id`             int(11) PRIMARY KEY AUTO_INCREMENT,
  `fromID`   int(11) NOT NULL,
  `toID` int(11) NOT NULL,
  `type`       varchar(15) NOT NULL
);

ALTER TABLE `ortho` ADD UNIQUE INDEX `fromID` (`fromID`);
-- ... a 1:1 link, which means ortho could be part of names
ALTER TABLE `ortho` ADD INDEX `toID` (`toID`);
ALTER TABLE `ortho` ADD FOREIGN KEY `fk_fromID` (`fromID`) REFERENCES `names`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `ortho` ADD FOREIGN KEY `fk_toID` (`toID`) REFERENCES `names`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
-- ... how to set this to only be canonical names?
-- ALTER TABLE `ortho` ADD CONSTRAINT `is_canon` CHECK (`toID` IN (SELECT id FROM `names` WHERE `can` = 1)); -- doesn't work
-- need to regularly: select * from ortho left join names on ortho.toID = names.id where names.can != 1;

INSERT INTO `ortho` (fromID, toID, `type`) SELECT id, id, 'self' FROM `names`;


