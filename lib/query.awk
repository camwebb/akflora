function simplequery(               q) {

  htmlHeader("Name Query");

  q = "SELECT taxon.g AS 'Genus', taxon.s AS 'Species', taxon.t AS 'Type', taxon.sub AS 'Ssp.', taxon.a AS 'Author', t1.listsrc AS 'Found in', t1.listCode AS 'Code', t1.accsyn AS 'Status', t3.listCode AS 'Acc. code', t2.g AS 'Acc. genus', t2.s AS 'Acc. species', t2.t AS 'Acc. type', t2.sub AS 'Acc. ssp.', t2.a AS 'Acc. author' FROM `taxon` LEFT JOIN `tlink` AS t1 ON t1.taxonID = taxon.id LEFT JOIN taxon as t2 ON t2.id = t1.tsynofID LEFT JOIN tlink AS t3 ON t2.id = t3.taxonID WHERE taxon.g LIKE '%" f["g"] "%' AND ((t1.listsrc = 'Murray') OR (t1.listsrc = 'ThePlantListV2')) order by taxon.g, taxon.s, taxon.t, taxon.sub;";
  queryDB( q );
  print "<h1>Name query for genus <i>" f["g"] "</i></h1>";
  printTable();
  clearDBQ();
  htmlFooter() ;
  exit;
}

