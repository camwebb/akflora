SELECT '... making table tmp_names';

CREATE TABLE `tmp_names` (
  `code`    varchar(20) NOT NULL,
  `genhyb`  enum('×')     DEFAULT NULL,
  `genus`   varchar(22) NOT NULL,
  `sphyb`   enum('×')     DEFAULT NULL,
  `species` varchar(50) NOT NULL,
  `ssptype` varchar(20)   DEFAULT NULL,
  `ssp`     varchar(30)   DEFAULT NULL,
  `author`  varchar(100)  DEFAULT NULL,
  INDEX (`code`)
) ;

SELECT '... reading new names data';
LOAD DATA LOCAL INFILE 'names' INTO TABLE `tmp_names` FIELDS TERMINATED BY '|' ;

-- create md5sum for name strings
ALTER TABLE `tmp_names` ADD `md5sum` VARCHAR(50) NULL DEFAULT NULL ;
UPDATE `tmp_names` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`,
  `sphyb` , `species` , `ssptype` , `ssp` , `author`));
ALTER TABLE `tmp_names` ADD UNIQUE INDEX `md5sum` (`md5sum`);

-- find new names and insert
SELECT '... inserting into `names`';
INSERT INTO `names` (`genhyb`, `genus`, `sphyb` , `species` , `ssptype` ,
    `ssp` , `author`)
  SELECT DISTINCT `tmp_names`.`genhyb`, `tmp_names`.`genus`,
    `tmp_names`.`sphyb`, `tmp_names`.`species` , `tmp_names`.`ssptype` ,
    `tmp_names`.`ssp` , `tmp_names`.`author`
  FROM `tmp_names` LEFT JOIN `names` AS `A` ON
    `tmp_names`.`md5sum` = `A`.`md5sum`
  WHERE `A`.`md5sum` IS NULL ;

-- Remake names.md5sum as a check
UPDATE `names` SET `md5sum` = MD5(concat_ws(' ',  `genhyb`, `genus`, `sphyb` ,
  `species` , `ssptype` , `ssp` , `author`));

-- UIDS

-- first test to see that the names and uids 
SELECT '... testing to see that same UID = same name. Nothing should follow...';

SELECT `uids`.`code` FROM `names`, `uids`, `tmp_names` WHERE
  `names`.`id` = `uids`.nameID AND
  `uids`.`code`= tmp_names.`code` AND
  `names`.md5sum != tmp_names.md5sum ; 

SELECT '... inserting into `uids`';
INSERT INTO `uids` (`code`, `nameID`)
  SELECT tmp_names.`code`, names.id FROM
    tmp_names LEFT JOIN uids ON uids.`code` = tmp_names.`code`
    LEFT JOIN names ON tmp_names.md5sum = names.md5sum
    WHERE uids.`code` IS NULL;

-- test with: SELECT nameID, GROUP_CONCAT(`code`) FROM uids GROUP BY nameID
--   ORDER BY GROUP_CONCAT(`code`) ;

-- Ortho
SELECT '... making table tmp_ortho and reading in data';
CREATE TABLE `tmp_ortho` (
  `code_from`   varchar(30) UNIQUE NOT NULL,
  `code_to` varchar(30) NOT NULL,
  `type`       varchar(15) NOT NULL,
  INDEX (code_to)
);

LOAD DATA LOCAL INFILE 'ortho' INTO TABLE `tmp_ortho`
  FIELDS TERMINATED BY '|' ;

ALTER TABLE tmp_ortho ADD COLUMN fromID int(11) FIRST;
ALTER TABLE tmp_ortho ADD COLUMN toID int(11) AFTER `fromID`;
UPDATE tmp_ortho, uids set tmp_ortho.fromID = uids.nameID
  where uids.code = tmp_ortho.code_from;
UPDATE tmp_ortho, uids set tmp_ortho.toID = uids.nameID
  where uids.code = tmp_ortho.code_to;
ALTER TABLE `tmp_ortho` ADD UNIQUE INDEX `fromID` (`fromID`);
ALTER TABLE `tmp_ortho` ADD INDEX `toID` (`toID`);
ALTER TABLE `tmp_ortho` DROP COLUMN code_from;
ALTER TABLE `tmp_ortho` DROP COLUMN code_to;

SELECT '... these ortho mappings are not being overwritten:';
SELECT names.id, names.orthoID FROM names, tmp_ortho
  WHERE tmp_ortho.fromID = `names`.`id` AND
    `names`.orthoID IS NOT NULL  AND
    `names`.orthoID != `names`.`id`;

-- Load the non-exact matches (new ones only):
UPDATE `names`, tmp_ortho
  SET `names`.orthoID = tmp_ortho.toID,
      `names`.ortho_type = tmp_ortho.`type`
  WHERE tmp_ortho.fromID = `names`.`id` AND
  -- so that existing (non-self) ortho information is not overwritten
    ( `names`.orthoID IS NULL OR `names`.orthoID = `names`.id) ;

-- test
select '... testing all names have orthos (nothing should follow):' as q;
select * from names where orthoID is null;

-- Relationships

SELECT '... making table tmp_rel and reading in data';
CREATE TABLE `tmp_rel` (
  `code_from`   varchar(30)    UNIQUE NOT NULL,
  `code_to`     varchar(30)    NOT NULL,
  `status`      varchar(15)    NOT NULL,
  `refs`        varchar(10000) NULL DEFAULT NULL,
  INDEX (code_to)
);

LOAD DATA LOCAL INFILE 'rel' INTO TABLE `tmp_rel`
  FIELDS TERMINATED BY '|' ;

ALTER TABLE tmp_rel ADD COLUMN fromID int(11) FIRST;
ALTER TABLE tmp_rel ADD COLUMN toID int(11) AFTER `fromID`;
UPDATE tmp_rel, uids set tmp_rel.fromID = uids.nameID
  where uids.code = tmp_rel.code_from;
UPDATE tmp_rel, uids set tmp_rel.toID = uids.nameID
  where uids.code = tmp_rel.code_to;
ALTER TABLE `tmp_rel` ADD UNIQUE INDEX `fromID` (`fromID`);
ALTER TABLE `tmp_rel` ADD INDEX `toID` (`toID`);
ALTER TABLE `tmp_rel` DROP COLUMN code_from;
ALTER TABLE `tmp_rel` DROP COLUMN code_to;

ALTER TABLE `tmp_rel` ADD FOREIGN KEY (`fromID`) REFERENCES `names` (id) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `tmp_rel` ADD FOREIGN KEY (`toID`) REFERENCES   `names` (id) ON DELETE RESTRICT ON UPDATE RESTRICT;

INSERT INTO `rel` (`fromID`, `toID`, `status`, `source`, `refs`)
  SELECT `fromID`, `toID`, `status`, @in_src, `refs` FROM `tmp_rel`;

DROP TABLE tmp_ortho ;
DROP TABLE tmp_names ;
DROP TABLE tmp_rel ;



