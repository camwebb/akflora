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

{
  # Use unwrapped/long lines to view regex structure
  #                 (× )   ( genus 2+   )   (× )   ( species 2+      )    ( rank                         )    ( infrasp         )    ( author string           )
  parsed = gensub(/^(×?)\ ?([A-Z][a-zë]+)\ ?(×?)\ ?([a-z\-ﬂ][a-z\-ﬂ]+)?\ ?([a-z]+\.|\[infrasp\.unranked\])?\ ?([a-z\-ﬂ][a-z\-ﬂ]+)?\ ?([- \[\]().&;,'[:alpha:]]+)?$/, "\\1|\\2|\\3|\\4|\\5|\\6|\\7", "G", $0);

  # tests
  split(parsed, p, "|");
  remade = parsed;
  gsub("\\|"," ",remade);
  gsub(/\ \ +/," ",remade);
  gsub(/^\ /,"",remade);
  gsub(/\ $/,"",remade)
  if ((parsed !~ /\|/) ||          \
      (p[1] !~ /^×?$/) ||          \
      (p[2] !~ /^[A-Z][a-zë]+$/) || \
      (p[3] !~ /^×?$/) ||                               \
      (p[4] !~ /^[a-z\-ﬂ][a-z\-ﬂ]+$/) ||                \
      (p[5] !~ /^([a-z]+\.|\[infrasp\.unranked\])?$/) || \
      (p[6] !~ /^([a-z\-ﬂ][a-z\-ﬂ]+$)?/) ||              \
      (remade != $0)) {
    print "** Fail: '" $0 "'\n         '" remade "'\n            " \
      parsed > "/dev/stderr";
  }
  else print parsed;
}
