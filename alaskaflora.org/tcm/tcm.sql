SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `irank`;

CREATE TABLE `irank` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(10) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO `irank` VALUES (1,'ssp.'),(2,'var.'),(3,'f.');

DELIMITER ;;
CREATE  TRIGGER `lockirank_i` BEFORE INSERT ON `irank` FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot edit table'; END ;;
DELIMITER ;

DELIMITER ;;
CREATE  TRIGGER `lockirank_u` BEFORE UPDATE ON `irank` FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot edit table'; END ;;
DELIMITER ;

DELIMITER ;;
CREATE  TRIGGER `lockirank_d` BEFORE DELETE ON `irank` FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot edit table'; END ;;
DELIMITER ;

DROP TABLE IF EXISTS `name`;

CREATE TABLE `name` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(50) COLLATE utf8_bin NOT NULL,
  `pubID` int(11) NOT NULL,
  `genus` varchar(100) COLLATE utf8_bin NOT NULL,
  `species` varchar(100) COLLATE utf8_bin NOT NULL,
  `irankID` int(11) DEFAULT NULL,
  `infrasp` varchar(50) COLLATE utf8_bin DEFAULT NULL,
  `author` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `url` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `notes` varchar(1000) COLLATE utf8_bin DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `genus` (`genus`,`species`,`author`),
  KEY `pubID` (`pubID`),
  KEY `irankID` (`irankID`),
  CONSTRAINT `name_ibfk_1` FOREIGN KEY (`pubID`) REFERENCES `pub` (`id`),
  CONSTRAINT `name_ibfk_2` FOREIGN KEY (`irankID`) REFERENCES `irank` (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `pub`;

CREATE TABLE `pub` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(50) COLLATE utf8_bin NOT NULL,
  `pubtypeID` int(11) DEFAULT NULL,
  `author` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `year` varchar(20) COLLATE utf8_bin DEFAULT NULL,
  `title` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `journal` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `volume` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `pages` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `publisher` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `address` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `doi` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `url` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `bhlPf` int(11) DEFAULT NULL,
  `bhlPl` int(11) DEFAULT NULL,
  `notes` varchar(1000) COLLATE utf8_bin DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `pubtypeID` (`pubtypeID`),
  CONSTRAINT `pub_ibfk_1` FOREIGN KEY (`pubtypeID`) REFERENCES `pubtype` (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DELIMITER ;;
CREATE  TRIGGER `pubinfo_i` BEFORE INSERT ON `pub` FOR EACH ROW BEGIN IF NEW.title IS NULL AND NEW.doi IS NULL AND NEW.url IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot add or update row: either cite or DOI or URL is needed'; END IF; END ;;
DELIMITER ;

DELIMITER ;;
CREATE  TRIGGER `pubinfo_u` BEFORE UPDATE ON `pub` FOR EACH ROW BEGIN IF NEW.title IS NULL AND NEW.doi IS NULL AND NEW.url IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot add or update row: either cite or DOI or URL is needed'; END IF; END ;;
DELIMITER ;

DROP TABLE IF EXISTS `pubtype`;

CREATE TABLE `pubtype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(50) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO `pubtype` VALUES (1,'article'),(2,'book'),(3,'in book'),(4,'report'),(5,'online resource'),(6,'treatment');

DROP TABLE IF EXISTS `rel`;

CREATE TABLE `rel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(50) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO `rel` VALUES (1,'intersects'),(2,'is congruent with'),(3,'overlaps'),(4,'includes'),(5,'is included in'),(6,'is disjunct with');

DELIMITER ;;
CREATE  TRIGGER `lockrel_i` BEFORE INSERT ON `rel` FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot edit table rel'; END ;;
DELIMITER ;

DELIMITER ;;
CREATE  TRIGGER `lockrel_u` BEFORE UPDATE ON `rel` FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot edit table rel'; END ;;
DELIMITER ;

DELIMITER ;;
CREATE  TRIGGER `lockrel_d` BEFORE DELETE ON `rel` FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot edit table rel'; END ;;
DELIMITER ;

DROP TABLE IF EXISTS `syn`;

CREATE TABLE `syn` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(30) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO `syn` VALUES (1,'same name as'),(2,'is synonym for'),(3,'has synonym'),(4,'is pro parte synonym for'),(5,'has pro parte synonym');

DELIMITER ;;
CREATE  TRIGGER `locksyn_i` BEFORE INSERT ON `syn` FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot edit table'; END ;;
DELIMITER ;

DELIMITER ;;
CREATE  TRIGGER `locksyn_u` BEFORE UPDATE ON `syn` FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot edit table'; END ;;
DELIMITER ;

DELIMITER ;;
CREATE  TRIGGER `locksyn_d` BEFORE DELETE ON `syn` FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot edit table'; END ;;
DELIMITER ;

DROP TABLE IF EXISTS `tc`;

CREATE TABLE `tc` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(50) COLLATE utf8_bin NOT NULL,
  `nameID` int(11) NOT NULL,
  `pubID` int(11) NOT NULL,
  `bhlPf` int(11) DEFAULT NULL,
  `bhlPl` int(11) DEFAULT NULL,
  `foak` int(1) DEFAULT NULL,
  `notes` varchar(1000) COLLATE utf8_bin DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nameID_2` (`nameID`,`pubID`),
  UNIQUE KEY `code` (`code`),
  KEY `nameID` (`nameID`),
  KEY `pubID` (`pubID`),
  CONSTRAINT `tc_ibfk_1` FOREIGN KEY (`nameID`) REFERENCES `name` (`id`),
  CONSTRAINT `tc_ibfk_2` FOREIGN KEY (`pubID`) REFERENCES `pub` (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DROP TABLE IF EXISTS `tcm`;

CREATE TABLE `tcm` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tc1ID` int(11) NOT NULL,
  `relID` int(11) NOT NULL,
  `uncertain` tinyint(1) DEFAULT NULL,
  `synID` int(11) DEFAULT NULL,
  `tc2ID` int(11) NOT NULL,
  `pubID` int(11) NOT NULL,
  `graph` tinyint(4) DEFAULT NULL,
  `notes` varchar(1000) COLLATE utf8_bin DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tc1ID_2` (`tc1ID`,`relID`,`tc2ID`),
  KEY `tc1ID` (`tc1ID`),
  KEY `relID` (`relID`),
  KEY `tc2ID` (`tc2ID`),
  KEY `pubID` (`pubID`),
  KEY `synID` (`synID`),
  CONSTRAINT `tcm_ibfk_1` FOREIGN KEY (`tc1ID`) REFERENCES `tc` (`id`),
  CONSTRAINT `tcm_ibfk_2` FOREIGN KEY (`tc2ID`) REFERENCES `tc` (`id`),
  CONSTRAINT `tcm_ibfk_3` FOREIGN KEY (`relID`) REFERENCES `rel` (`id`),
  CONSTRAINT `tcm_ibfk_4` FOREIGN KEY (`pubID`) REFERENCES `pub` (`id`),
  CONSTRAINT `tcm_ibfk_5` FOREIGN KEY (`synID`) REFERENCES `syn` (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

DELIMITER ;;
CREATE  TRIGGER `tc1_ne_tc2` BEFORE INSERT ON `tcm` FOR EACH ROW BEGIN
          IF NEW.tc1ID = NEW.tc2ID
          THEN
               SIGNAL SQLSTATE '45000'
                  SET MESSAGE_TEXT = 'Cannot add or update row: tc1 must not equal tc2';
          END IF;
     END ;;
DELIMITER ;

DELIMITER ;;
CREATE  TRIGGER `tc1_ne_tc2_u` BEFORE UPDATE ON `tcm` FOR EACH ROW BEGIN IF NEW.tc1ID = NEW.tc2ID THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot add or update row: tc1 must not equal tc2'; END IF; END ;;
DELIMITER ;

