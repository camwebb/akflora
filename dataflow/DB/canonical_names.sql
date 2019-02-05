-- was: (associated can with uids)

-- ALTER TABLE `uids` ADD `can` TINYINT(1) NULL DEFAULT NULL ;
-- UPDATE uids SET can = 1 WHERE authority = 'IPNI';
-- UPDATE uids SET can = 1 WHERE id IN (SELECT DISTINCT A.id FROM uids AS A LEFT JOIN uids AS B ON (A.nameID = B.nameID) WHERE A.authority = 'TROP' AND B.authority != 'IPNI') ;
-- select DISTINCT names.* from names, uids where names.id = uids.nameID and uids.can IS NULL; -> 5717 rows

-- this is better:

ALTER TABLE `names` ADD `can` TINYINT(1) NULL DEFAULT NULL ;
ALTER TABLE `names` ADD `cansrc` VARCHAR(5) NULL DEFAULT NULL ;

update names set can = 1, cansrc = 'IPNI' where id in (select DISTINCT nameID from uids where authority = 'IPNI') and can is NULL;

update names set can = 1, cansrc = 'TROP' where id in (select DISTINCT nameID from uids where authority = 'TROP') and can IS NULL;


