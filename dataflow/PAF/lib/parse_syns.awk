# This script parses the references section for each PAF entry, in
# which are the synonym statements

# Parsing strategy:
# 1. Char-by-char with lookahead
# 2. Names all bounded by '___'
# 3. if a name is followed by var. or subsp. the following name is
#    appended
# 4. After a name, an author is expected. The end of the author is
#    almost always marked with a comma. This will fail in the cases where
#    authors incl. A, B & C. A lookahead for a & flags this to stderr for
#    manual intervention.

# Issues:
# - Clifford Herbarium holotypes are also bounded by ___ added backtrack warn
# - Some names have no author. ...



BEGIN{
  FS="\t"
  OFS = "|"
  D = 0
  OUT = 2
}

# Make the author strings with basionyms
($8)                     {auth = "(" $8 ") " $7}
(!$8)                    {auth = $7}

# If an aggregate, fix name
$3 ~ /\ aggregate/       {$3 = $4}

# Sort out the var vs subsp vs sp
$2 == "subspecies" && $5 {subt = "subsp.|" $5}
$2 == "subspecies" && $6 {gsub(/(_|\])/,"",$6); subt = "var.|" $6}
$2 == "species"          {subt = "|"}


{
  gsub(/(\\t|`|\*)/, "", $9)

  # parse the synonyms
  n1 = nn = ssp = var = frm = author = hyb = dummy = 0
  for (i = 1; i <= length($9); i++) {
    c = substr($9, i, 1)
    if (D) printf c

    # newly come upon a name?
    if ((c == "_") && !n1) {
      i+=2
      n1 = 1
      
      # flag as dummy name, do not increment nn
      if ((substr($9, i-20, 20) ~ /Clifford/) ||    \
          (substr($9, i-3, 1) == "[")) {
        if (D) printf "<DUMMYIN>"
        dummy = 1
        continue
      }

      # waiting for a var or ssp or forma or hyb?
      if (var) {
        name[nn] = name[nn] " var. "
        var = 0
      }
      else if (ssp) {
        name[nn] = name[nn] " subsp. "
        ssp = 0
      }
      else if (frm) {
        name[nn] = name[nn] " f. "
        frm = 0
      }
      else if (hyb) {
        name[nn] = name[nn] " × "
        hyb = 0
      }
      else nn++

      if (D) printf "<ENTER %d %d %d>", nn, var+ssp+frm+hyb, author
    }
    
    # in a name, newly ending
    else if ((c == "_") && n1) {
      i+=2
      n1 = 0

      # switch off dummy name flag
      if (dummy) {
        dummy = 0
        if (D) printf "<DUMMYOUT>"
        continue
      }
      
      # check for upcoming syn
      if (substr($9,i,10) ~ /su?b?sp\./) ssp = 1
      else if (substr($9,i,10) ~ /var\./) var = 1
      else if (substr($9,i,10) ~ /\ f\.\ /) frm = 1
      else if (substr($9,i,10) ~ /\ x /) hyb = 1
      else author = 1
      if (D) printf "<LEAVE %d %d %d>", nn, var+ssp+frm+hyb, author
    }

    # collect names
    else if (n1 && !dummy) name[nn] = name[nn] c
    
    # collect authors
    else if (author) {
      if (c == ",") {
        if (substr($9,i,15) ~ /&/) {
          # print $1 " syn WARNING" >> "/dev/stderr"
          warn[nn] = "*"
        }
        author = 0
        if (D) printf "<ENDAUTH %d %d %d>", nn, var+ssp+frm+hyb, author
      }
      else au[nn] = au[nn] c
    }
  }
  
  if (D) print "\n"

  if (OUT == "1") {
  
    # Make a synonym string
    syns = ""
    if (nn) {
      syns = name[1] au[1]
      for (i = 2 ; i <= nn ; i++) syns = syns "^" name[i] au[i]
    }

    print $1 "|" substr($3,1,index($3," ")-1) "|"                       \
      substr($3,index($3," ")+1) "|" subt "|"                           \
      auth "|" syns
  }
  if (OUT == "2") {
    if (nn)
      for (i = 1 ; i <= nn ; i++) printf "%1s%-8s | %s\n", warn[i], $1, name[i] au[i]
    # else print $1, $3, "" , "-"
  }
  
  delete name
  delete au
  delete warn
}
