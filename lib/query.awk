function gquery(               q) {

  htmlHeader("Genus Query");

  q = "\
    SELECT DISTINCT\
      taxon.g AS 'Genus',\
      REPLACE(taxon.xs,'1','×') AS 'hyb.',\
      taxon.s AS 'Species',\
      taxon.t AS 'Subtype',\
      taxon.sub AS 'Ssp.',\
      taxon.a AS 'Author',\
      tpl.listCode AS 'PL code',\
      t1.accsyn AS 'ALA status',\
      t2.g AS 'Acc. genus',\
      REPLACE(t2.xs,'1','×') AS 'Acc. hyb.',\
      t2.s AS 'Acc. species',\
      t2.t AS 'Acc. subtype',\
      t2.sub AS 'Acc. ssp.',\
      t2.a AS 'Acc. author',\
      tpl2.listCode AS 'Acc. PL'\
    FROM `taxon`\
    LEFT JOIN `tlink` AS t1 ON t1.taxonID = taxon.id\
    LEFT JOIN `tlink` AS tpl ON tpl.taxonID = taxon.id AND tpl.listsrc = 'ThePlantListV2'\
    LEFT JOIN taxon as t2 ON t2.id = t1.tsynofID\
    LEFT JOIN tlink AS tpl2 ON tpl2.taxonID = t2.id AND tpl2.listsrc = 'ThePlantListV2'\
    WHERE taxon.g LIKE '" f["g"] "'\
    AND (t1.listsrc = 'Murray')\
    ORDER BY taxon.g, taxon.s, taxon.t, taxon.sub;\
  ";

  queryDB( q );
  print "<h1>Name query for genus <i>" toupper(substr(f["g"],1,1)) tolower(substr(f["g"], 2)) "</i></h1>";
  #printTable();

  printTableLinks("PL code~<a href=\"http://www.theplantlist.org/tpl1.1/record/!\" target=\"_blank\">!</a>|Acc. PL~<a href=\"http://www.theplantlist.org/tpl1.1/record/!\" target=\"_blank\">!</a>");
  clearDBQ();

  print "<br/><br/><span style=\"font-size:80%;\"><p>This table gives all records in our ALA checklist for occurences of the requested genus name. Where the taxon has been determined to be a synonym of another taxon, the accepted ('Acc.') name and source code is also given. 'TPL' = name code from the <a href=\"http://www.theplantlist.org/\">The Plant List (v. 1.1)</a>. Note that Plant List opinions about synonymy may differ from this accumulated ALA understanding.</p></span>";
  print "<p>[ <a href=\"pages/ALA_checklist.html\">BACK</a> ]</p>";
  
  htmlFooter() ;
  exit;
}

