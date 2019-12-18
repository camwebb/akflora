-- PART 1: Names

SELECT '... making DB';
DROP DATABASE IF EXISTS `akflora`;
CREATE DATABASE `akflora` CHARSET 'utf8' COLLATE 'utf8_bin';
-- collate: NB!! https://stackoverflow.com/questions/4558707/
--        case-sensitive-collation-in-mysql#4558736
USE `akflora`;

SELECT '... making `names`';
CREATE TABLE `names` (
  `code`    VARCHAR(20)  NOT NULL,
  `genhyb`  ENUM('×')      DEFAULT NULL,
  `genus`   VARCHAR(20)  NOT NULL,
  `sphyb`   ENUM('×')      DEFAULT NULL,
  `species` VARCHAR(50)  NOT NULL,
  `ssptype` VARCHAR(20)    DEFAULT NULL,
  `ssp`     VARCHAR(30)    DEFAULT NULL,
  `author`  VARCHAR(150)   DEFAULT NULL
) ;
-- ENGINE=InnoDB ; -- Not needed. SHOW ENGINES: InnoDB is default

LOAD DATA LOCAL INFILE 'canon' INTO TABLE `names`
  FIELDS TERMINATED BY '|' ;

ALTER TABLE `names`
  ADD COLUMN `id` INT(11) AUTO_INCREMENT PRIMARY KEY FIRST;
ALTER TABLE `names` ADD UNIQUE KEY `code` (`code`);
ALTER TABLE `names` ADD `md5sum` VARCHAR(50) UNIQUE KEY NULL DEFAULT NULL ;

SELECT '... making names md5sum';
UPDATE `names` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` ,
  `species` , `ssptype` , `ssp` , `author`));
-- SHOW CREATE TABLE `names`;

-- PART 2 UIDS

SELECT '... making table `uids`';
CREATE TABLE `uids` (
  `id`        INT(11)     AUTO_INCREMENT PRIMARY KEY,
  `code`      VARCHAR(20) UNIQUE KEY NOT NULL,
  `nameID`    INT(11)     NOT NULL,
  INDEX (`nameID`),
  FOREIGN KEY `fk_nameID` (`nameID`) REFERENCES `names`(`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ;

INSERT INTO `uids` (`code`, `nameID`) SELECT `code`, `id` FROM `names`;

ALTER TABLE `names` DROP `code`;

ALTER TABLE `names` ADD `can` TINYINT(1) NULL DEFAULT NULL ;
UPDATE `names` SET `can` = 1 ;
ALTER TABLE `names` ADD `canuidID` INT(11) NULL DEFAULT NULL ;
UPDATE `names`, `uids` SET `names`.`canuidID`= `uids`.id
WHERE `names`.`id`= `uids`.`nameID` ;


-- PART 3 MAKE ORTHO (self-to-self)

SELECT '... making ortho cols in names';
-- ... a 1:1 link, which means ortho could be part of names
ALTER TABLE `names` ADD `orthoID`   INT(11) NULL DEFAULT NULL ;
ALTER TABLE `names` ADD `ortho_type` VARCHAR(15) NULL DEFAULT NULL;
ALTER TABLE `names` ADD FOREIGN KEY `fk_orthoID` (`orthoID`) REFERENCES `names`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
-- add data
UPDATE names SET orthoID = id, `ortho_type` = 'self';


-- PART 4 MAKE REL
SELECT '... making rel';

CREATE TABLE `rel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fromID` int(11) DEFAULT NULL,
  `toID` int(11) DEFAULT NULL,
  `source` varchar(10) DEFAULT NULL,
  -- redundant, but helpful
  `status` enum('accepted','synonym') DEFAULT NULL,
  `refs` varchar(10000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_fromID` (`fromID`),
  KEY `fk_toID` (`toID`),
  CONSTRAINT `fk_fromID` FOREIGN KEY (`fromID`) REFERENCES `names` (`id`),
  CONSTRAINT `fk_toID` FOREIGN KEY (`toID`) REFERENCES `names` (`id`)
);

-- PART 5 MAKE AK
SELECT '... making ak';

CREATE TABLE `ak` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nameID` int(11) DEFAULT NULL,
  `in_ak` TINYINT(1) DEFAULT NULL,
  `source` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ak_nameID` (`nameID`),
  CONSTRAINT `ak_nameID` FOREIGN KEY (`nameID`) REFERENCES `names` (`id`)
);





