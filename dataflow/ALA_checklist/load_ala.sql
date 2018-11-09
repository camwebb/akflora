-- mysqll --show-warnings

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

DROP TABLE IF EXISTS `names`;

CREATE TABLE `names` (
  `alaid` varchar(10) NOT NULL,
  `genhyb` enum('×') DEFAULT NULL,
  `genus` varchar(20) DEFAULT NULL,
  `sphyb` enum('×') DEFAULT NULL,
  `species` varchar(50) DEFAULT NULL,
  `ssptype` enum('subsp.','var.','f.') DEFAULT NULL,
  `ssp` varchar(30) DEFAULT NULL,
  `author` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA LOCAL INFILE 'ala-names' INTO TABLE `names` FIELDS TERMINATED BY '|' ;

ALTER TABLE `names`
 ADD PRIMARY KEY `alaid` (`alaid`);

ALTER TABLE `names` ADD `md5sum` VARCHAR(50) NULL DEFAULT NULL ;

UPDATE `names` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` , `species` , `ssptype` , `ssp` , `author`)); 

-- Now relationships

-- 1: ID
-- 2: Status
-- 3: In AK
-- 4: Comments
-- 5: Ref
-- 6: Acc name

DROP TABLE IF EXISTS `rel`;

CREATE TABLE `rel` (
  `alaid` varchar(10) NOT NULL,
  `status` varchar(10) DEFAULT NULL,
  `inak` enum('T','F') DEFAULT NULL,
  `comments` varchar(200) DEFAULT NULL,
  `refs` varchar(500) DEFAULT NULL,
  `toid` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  
LOAD DATA LOCAL INFILE 'ala-rel' INTO TABLE `rel` FIELDS TERMINATED BY '|' ;

ALTER TABLE `rel`
 ADD PRIMARY KEY `alaid` (`alaid`),
 ADD KEY `toid` (`toid`);

ALTER TABLE `rel` ADD FOREIGN KEY (`toid`) REFERENCES `rel`(`alaid`) ON DELETE RESTRICT ON UPDATE RESTRICT;

