function error(msg) {
  print "<pre>" ;
  print msg ;
  print "Exiting. Please return to previous page.";
  print "</pre>" ;
  htmlFooter() ;
  exit;
}

## Note - errors if two columns have same name since field is used as key
function queryDB( query            , row, i, cmd ) {
  gsub(/`/,"\\`",query);  # if writing directly, need: \\\`
  gsub(/\n/," ",query);
  gsub(/\ \ */," ",query);
  cmd = "/bin/echo -e \"" query "\" | mysql -u " USER " -p" PASSWORD " -h " HOST " -B --column-names --default-character-set=utf8 " DBNAME ;
  # print cmd;
  row = -1;
  FS = "\t";
  while ((cmd | getline ) > 0)
	{
	  row++;
	  if (row == 0) 
		{
		  DBQc = NF;
		  for (i = 1; i <= NF; i++)
			{
			  DBQf[i] = $i;
			}
		}
	  for (i = 1; i <= NF; i++)
		{
		  DBQ[row, DBQf[i]] = $i;
          # print row, i,  $i;
		}
	}
  close(cmd);
  DBQr = row;
}

function clearDBQ() {

  delete DBQ;
  delete DBQf;
  DBQr = 0;
  DBQc = 0;
}

function printTable(width,    widthstr,   i, j) 
{
  if (width) widthstr = "width=\"" width "\"";
  print "<table border=\"1\" " widthstr ">";
  print "<tr>";
  for (i = 1; i <= DBQc; i++) print "<th>" DBQf[i] "</th>";
  print "</tr>";
  for (i = 1; i <= DBQr; i++)
	{
	  print "<tr>";
	  for (j = 1; j <= DBQc; j++)
		{
          if (DBQ[i,DBQf[j]] == "NULL") DBQ[i,DBQf[j]] = "&#160;" ;
		  print "<td>" DBQ[i,DBQf[j]] "</td>";
		}
	   print "</tr>";
	}
  print "</table>";
}

function printTableLinks( links,       link, tmp1, tmp2, i, j) 
{
  # parse links
  split(links, tmp1, "|");
  for (i in tmp1) {
    split(tmp1[i], tmp2, "~");
    link[tmp2[1]] = tmp2[2];
  }
  
  print "<table border=\"1\">";
  print "<tr>";
  for (i = 1; i <= DBQc; i++) print "<th>" DBQf[i] "</th>";
  print "</tr>";
  for (i = 1; i <= DBQr; i++)
	{
	  print "<tr>";
	  for (j = 1; j <= DBQc; j++)
		{
          # empty?
          if (DBQ[i,DBQf[j]] == "NULL") DBQ[i,DBQf[j]] = "&#160;"
          # linked?
          else if (link[DBQf[j]])
            DBQ[i,DBQf[j]] = gensub("!", DBQ[i,DBQf[j]], "G", link[DBQf[j]]);
		  print "<td>" DBQ[i,DBQf[j]] "</td>";
		}
	   print "</tr>";
	}
  print "</table>";
}


# decode urlencoded string
function urldecode(text,   hex, i, hextab, decoded, len, c, c1, c2, code) {
	
  split("0 1 2 3 4 5 6 7 8 9 a b c d e f", hex, " ")
  for (i=0; i<16; i++) hextab[hex[i+1]] = i
  
  # urldecode function from Heiner Steven
  # http://www.shelldorado.com/scripts/cmds/urldecode

  # decode %xx to ASCII char 
  decoded = ""
  i = 1
  len = length(text)
  
  while ( i <= len ) {
    c = substr (text, i, 1)
    if ( c == "%" ) {
      if ( i+2 <= len ) {
	c1 = tolower(substr(text, i+1, 1))
	c2 = tolower(substr(text, i+2, 1))
	if ( hextab [c1] != "" || hextab [c2] != "" ) {
	  # print "Read: %" c1 c2;
	  # Allow: 
	  # 20 begins main chars, but dissallow 7F (wrong in orig code!)
	       # tab, newline, formfeed, carriage return
	  if ( ( (c1 >= 2) && ((c1 c2) != "7f") )  \
	       || (c1 == 0 && c2 ~ "[9acd]") )
	  {
	    code = 0 + hextab [c1] * 16 + hextab [c2] + 0
	    # print "Code: " code
	    c = sprintf ("%c", code)
	  } else {
	    # for dissallowed chars
	    c = " "
	  }
	  i = i + 2
	}
      }
    } else if ( c == "+" ) {	# special handling: "+" means " "
      c = " "
    }
    decoded = decoded c
    ++i
  }
  
  # change linebreaks to \n
  gsub(/\r\n/, "\n", decoded);
  
  # remove last linebreak
  sub(/[\n\r]*$/,"",decoded);
  
  return decoded
}

function iNatProject(cmd, json, i) {

  gsub(/,/,"%2C",f["users"]);

  htmlHeader("Plants and Fungi of Alaska, by users");
  # print "<pre>";
  print "<h1>Plants and Fungi of Alaska, by users</h1>";
  cmd = "curl -s -X GET --header 'Accept: application/json' 'https://api.inaturalist.org/v1/observations?project_id=plants-and-fungi-of-alaska&page=1&user_id=" f["users"] "'";
  RS="\x04";
  cmd | getline json ;
  close(cmd);
  parse_json(json);
  # PROCINFO["sorted_in"] = "@ind_num_asc";
  # walk_array(JSONPATH, "JSONPATH");
  nresults = JSONPATH["\"total_results\""] ;
  print "<p><b>Total obs: " nresults "</b></p>";
  print "<table>";

  x = 0;

  for (i = 0 ; (i < nresults) && (i < 30) ; i++ ) {
    # print ++x, i, JSONPATH["\"results\"",i,"\"user\"","\"login_exact\""], JSONPATH["\"results\"",i,"\"id\""];
    print "<tr><td>" ++x "</td><td>" gensub(/"/,"","G", JSONPATH["\"results\"",i,"\"user\"","\"login_exact\""]) "</td><td>Id: <a href=\"https://www.inaturalist.org/observations/" JSONPATH["\"results\"",i,"\"id\""] "\">" JSONPATH["\"results\"",i,"\"id\""] "</a></td></tr>" ;
  }

  pages = int(nresults / 30) + int(((nresults % 30) + 29) / 30);
  for (p = 2 ; p <= pages ; p++) {
    delete JSONPATH;
    cmd = "curl -s -X GET --header 'Accept: application/json' 'https://api.inaturalist.org/v1/observations?project_id=plants-and-fungi-of-alaska&page=" p "&user_id=" f["users"] "'";
    cmd | getline json ;
    close(cmd);
    parse_json(json);

    for (i = 0 ; i < (nresults - ((p-1)*30)) && i < 30 ; i++ ) {
     # print ++x, i, JSONPATH["\"results\"",i,"\"user\"","\"login_exact\""], JSONPATH["\"results\"",i,"\"id\""];
      print "<tr><td>" ++x "</td><td>" gensub(/"/,"","G", JSONPATH["\"results\"",i,"\"user\"","\"login_exact\""]) "</td><td>Id: <a href=\"https://www.inaturalist.org/observations/" JSONPATH["\"results\"",i,"\"id\""] "\">" JSONPATH["\"results\"",i,"\"id\""] "</a></td></tr>" ;
    }
  }
  print "</table>";
  # print "</pre>";
  htmlFooter();
}

function walk_array(arr, name,      i)
{
  PROCINFO["sorted_in"] = "@ind_str_asc";
    for (i in arr) {
        if (isarray(arr[i]))
            walk_array(arr[i], (name "[" i "]"))
        else
            printf("%s[%s] = %s\n", name, i, arr[i])
    }
}
