# A single regex for matching against species name strings

# Input: pipe-delimited genus_hybrid|genus|species_hybrid|species|
#        rank|infrasp|author_string

# Logic:
#   Genus Author                             : capital forces author (cfa)
#   Genus species                            : matching from front (mff)
#   Genus × species                          : mff & hybrid
#   Genus species Author                     : mff & cfa
#   Genus species Author & Author            : mff & cfa with following space
#   Genus species sub                        : rank needs period
#   Genus species sub Author                 :   & cfa
#   Genus species sub Author & Author        :   & cfa with following space
#   Genus species rank. sub                  : rank has period & mff
#   Genus species rank. sub Author           :   & cfa
#   Genus species rank. sub Author & Author  :   & cfa with following space
#
# Note: gawk's [:alpha:] shortens this Author string:
#   [A-za-z\- ().&;,ÁÅäáâăÉéèěíîíıÖØöóöòøôÜüČçćčğłñńřŞšșțýž']

@include "depunct.awk"

function parse_taxon_name(name, test,    parsed, p, remade) {

 # Clean bad chars:
  gsub(/[¿\/]/,"",name) 
 # see: https://github.com/GlobalNamesArchitecture/gnresolver/issues/112

  
  # Use unwrapped/long lines to view regex structure
  #                 (× )   ( genus 2+   )   (× )   ( species 2+      )    ( rank                         )    ( infrasp         )    ( author string           )
  parsed = gensub(/^([×xX]?)\ ?([A-Z][a-zë]+)\ ?([×xX]?)\ ?([a-z\-ﬂ][a-z\-ﬂ]+)?\ ?(var\.|f\.|forma|subsp\.|prol\.|nothovar\.|lus\.|\[infrasp\.unranked\])?\ ?([a-z\-ﬂ]+)?\ ?([- \[\]().&;,'[:alpha:]]+)?$/, "\\1|\\2|\\3|\\4|\\5|\\6|\\7", "G", name);
  # prob with auct. being drawn into infraspecific rank: made list of
  # rank sympols, from:
  # Full list of IPNI infra ranks: agamosp.  convar.  f.  forma
  #   [infrasp.unranked] lus.  monstr.  mut.  nm.  nothosubsp.
  #   nothovar.  prol.  proles race subf.  subsp.  subspec.  subvar.  var,
  #   var.

  # Can't find a way to catch the auct. in the regex, so fix:
  parsed = gensub(/\|(auctt?)\|\./,"||\\1.","G",parsed)
  
  if (test) {
    # tests
    split(parsed, p, "|");
    remade = parsed;
    gsub("\\|"," ",remade);
    gsub(/\ \ +/," ",remade);
    gsub(/^\ /,"",remade);
    gsub(/\ $/,"",remade)
    if ((parsed !~ /\|/) ||        \
        (p[1] !~ /^[×xX]?$/) ||         \
        (p[2] !~ /^[A-Z][a-zë]+$/) ||                   \
        (p[3] !~ /^[×xX]?$/) ||                             \
        (p[4] !~ /^[a-z\-ﬂ][a-z\-ﬂ]+$/) ||               \
        (p[5] !~ /^([a-z]+\.|\[infrasp\.unranked\])?$/) ||  \
        (p[6] !~ /^([a-z\-ﬂ][a-z\-ﬂ]+$)?/) ||               \
        (depunct(remade) != depunct(name))) {
      print "'" depunct(remade) "'" > "/dev/stderr";
      print "'" depunct(name)  "'" > "/dev/stderr";
      print "** Fail: '" name "' does not match:\n         '" remade \
        "'\n            " parsed "  <- parsed"> "/dev/stderr";
      exit 1;
    }
  }

  # convert hybrid sign
  gsub(/\|[xX]\|/,"|×|", parsed);
  gsub(/^[xX]\|/,"×|", parsed);

  return parsed;
}

