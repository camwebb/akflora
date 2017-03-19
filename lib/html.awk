function htmlHeader(title) 
{
  # Use html5
  print "Content-type: text/html\n" ;
  print "<!DOCTYPE html>";
  print "<html xmlns=\"http://www.w3.org/1999/xhtml\"> \
         <head><title>" title "</title>                         \
         <meta http-equiv=\"Content-Type\" content=\"text/html; \
           charset=utf-8\" /><link rel=\"stylesheet\" \
           href=\"css/default.css\" type=\"text/css\" />        \
           <link href=\"img/akflora.ico\" rel=\"shortcut icon\" \
           type=\"image/x-icon\"/> </head><body>";
}

function defaultpage()
{
  htmlHeader("Flora of Alaska");
  
  print "<div style=\"padding:50px;\"><img src=\"img/whitemntns_sm.jpg\"><h1 style=\"font-family:sans-serif;\">Dynamic Flora of Alaska</h1><p style=\"max-width:800px;\">A <i>live</i> biodiversity informatics mashup of <a href=\"http://arctos.database.museum/uam_herb_all\">specimens</a>, <a href=\"http://www.inaturalist.org/projects/plants-and-fungi-of-alaska\">observations</a>, images, <a href=\"http://www.theplantlist.org/\">names</a>, taxon concepts, <a href=\"http://www.biodiversitylibrary.org/\">literature</a>, and characters.</p><p>A project of <a href=\"https://www.uaf.edu/museum/collections/herb/\">ALA</a> (Herbarium of the University of Alaska's Museum of the North in Fairbanks). <a href=\"mailto:info@alaskaflora.org\">Contact us</a>.</p><!-- <p>(Made with <a href=\"https://www.gnu.org/software/gawk/manual/gawk.html\"><tt>gawk</tt></a> and <a href=\"https://www.dreamhost.com/r.cgi?108617\">Dreamhost</a>)</p> -->";

  print "<b>Query our Alaska Names database</b> for correct spelling and accepted names. Enter your genus of interest here:</p><form method=\"get\" action=\"./do\"><input type=\"text\" name=\"g\" size =\"20\"/><input type=\"hidden\" name=\"method\" value=\"gquery\"/><input type=\"submit\" value=\"go\"/></form>";
  
  htmlFooter()
}


function blank()
{
  htmlHeader("blank");
  print "<div class=\"gen\"><div id=\"title\"><b>blank</b></div></div>";
  htmlFooter();
}

function htmlFooter()
{
  print "</body></html>\n";
}
  
