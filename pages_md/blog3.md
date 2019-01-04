% Blog 3: Variations of a taxonomic name

# Blog 3: Variations of a taxonomic name

_Posted by [Cam](people.html#cam) on 2019-01-03_

## The problem 

A single taxonomic name often occurs in different forms in different
publications. In terms of character string differences, the variation
may be slight (e.g., a missing space after an author’s initials, or a
single character misspelling of a specific epithet), or major (e.g., a
missing basionym). Consider: `Ciminalis prostrata (Haenke) Á. Löve &
D. Löve` vs. `Ciminalis prostrata (Haenke) A.Love & D.Love`
vs. `Ciminalis prostrata Love & Love`. These variations sometimes
arise via copying or data entry errors, but more often are created
through the choices of how to encode the history of a name that are
made by authors citing an earlier name: to add the basionym or not, to
treat a validly publishing author as an “ex” author or as the main
author, and how to abbreviate the authors’ names. While the
_[International Code of Nomenclature for algae, fungi, and plants](https://www.iapt-taxon.org/nomen/main.php)_
contains precise rules for name citation (Articles 46-50), there are
also many recommendations, and often several “correct” ways to cite a
name. The Code has also evolved over time, and many citations were
published before clear rules existed. Hence the same name is often
cited validly in a variety of forms, as well as being cited in
erroneous ways.  These citations find their way into databases and
therefore present problems for the integration of data, whether it is
linking synonyms to valid names, or linking secondary data from
different sources.

## Name matching

How do we then determine if two variants of a names are really “the
same?”  I.e., despite the variation, do these two name strings refer
to the same name as _first published_.  No judgment about the taxon
concept (or circumscription) of the names is being attempted at this
step.  The most reliable way to solve this question is to track down
the usage(s) of both names in the primary literature and carefully
determine if the authors were referring to the same name as originally
published. While this approach is feasible in the case of a taxonomist
performing a revision, it is too slow to incorporate when assembling
large lists of names, as in the data integration step of our flora of
Alaska project. What is needed is a sensible, transparent algorithm
(set of rules) that can be applied by a machine, with human judgment
being required in only a small number of cases. As long as the
original names are preserved and the details of the automated judgment
are recorded, then even if a few matches might later be found to be
incorrect, no information is lost.  This process of designing a
taxonomic matching algorithm and associated software tool has occupied
me for the past weeks.

### Existing tools 

There do exist online now at least two good tools to help match
submitted names to various large names databases: The Global Names
[Resolver](http://resolver.globalnames.org/) of GNA and iPlant’s
[TNRS](http://tnrs.iplantcollaborative.org/) (Taxonomic Name
Resolution Service). Both of these offer approximate (fuzzy) matching
of submitted names to sources such as IPNI and Tropicos. TNRS returns
an overall, numeric match score, as does GNR. GNR also returns one of
five `match_type` values (Exact match, Exact match by canonical form
of a name, Fuzzy match by canonical form, Partial exact match by
species part of canonical form, Partial fuzzy match by species part of
canonical form). However, where an non-exact match is found, both
tools still require manual checking to confirm the exact nature of
that match (e.g., misspelling, differences in author string). 

The majority of mismatches are due to minor variations in the author
string and often an exact match between _intended_ names can be
inferred using some “taxonomic logic.” This additional taxonomic
resolution is not available in any existing tool that I know of.

### Botanical names, deconstructed

Because there are general rules that govern the construction of
taxonomic names, some additional pattern-matching can be applied in
comparing the different elements of two similar names. This can then
produce an estimate of the likelihood that two name strings actually
refer to the same name.

The most common elements of a (hypothetical) _botanical_ name are these:

<pre>
Salix alaxensis subsp. glauca (Andersson ex DC.) R. Coville ex Jones in Smith
<---> <-------> <----> <---->  <-------> <---->  <-------->    <--->    <--->
 gen     sp     irank   infr     basio   ex_bas     auth      ex_auth  in_auth 

<--------------------------->    =  taxon_name

<------------->    +   <---->    =  canonical_form

            author_string  =   <-------------------------------------------->
</pre>

(The codes used in this blog are:

 * `gen`: Genus.
 * `sp`: Specific epithet.
 * `irank`: Infraspecific rank.
 * `infr`: Infraspecific epithet.
 * `basio`: Basionym author(s): the author of the specific epithet
   before a change of genus or of infraspecific rank.
 * `ex_bas`: _ex_ Author(s) of basionym (see `ex_auth`). 
 * `auth`: Primary author of name: the author responsible for first
   publishing the combination of `gen` and `sp` (and `irank` and
   `infr` if they exist).
 * `ex_auth`: _ex_ Author(s) for primary author: if the publication of
   the name by `auth` was invalid, the `ex_auth` was the author who
   subsequently published the combination validly.
 * `in_auth`: _in_ Author(s) for primary author: if `auth` or
   `ex_auth` were responsible for the combination but were not
   actually the authors of the publication in which that combination
   first appeared, the author(s) of the publication are should be
   added after _in_, usually with some bibliographic citation details
   following.
 * `taxon_name`: `gen` and `sp` (and `irank` and `infr` if they exist)
 * `canonical_form`: `gen` and `sp` and `infr` without `irank`.
 * `author_string`: The whole author string.)

### Matching two variants

The presence or absence of, or variation in, these elements in two
names that are being matched indicates different kinds of choices or
errors by the person citing the name, and thus can give an indication
of the likelihood that the matched names refer to the same name. Here
is our current logic, which is encoded into the `matchnames` software
tool (<a href="#mn">below</a>). The types of variation are
approximately ranked in order of _decreasing likelihood_ that the names
are truly the same:


<table id="tab">
  <tr>
    <th>Variation</th>
    <th>E.g.</th>
    <th>Likely cause of variation</th>
    <th>Likelihood that names refer to same name [3]</th>
    <th>(Match code; see <a href="#mn">below</a>)</th>
  </tr>

<!-- punct --> <tr><td>Spacing differences, missing periods,
differences in ASCII vs. non-ASCII characters (accents, etc.) in
`author_string`</td><td>[<a href="#eg">A</a>]</td><td>Minor formatting
choices, variation in encoding</td><td>Very
high</td><td>`auto_punct`</td></tr>

<!-- author variations --> 
<tr><td>Missing initials for an author, or different abbreviations of
author’s surnames, in `author_string`</td><td>[<a href="#eg">B</a>]</td><td>Choices and/or errors by the
citing authors</td><td>Very high</td><td>`manual`</td></tr>

<!-- g+s variations -->
<tr><td>Spelling variation in `gen`, `sp`, `infr` with (essentially)
the same `auth`</td><td>[<a href="#eg">B1</a>]</td><td>Copying
errors</td><td>High</td><td>`manual`</td></tr>

<!-- in -->
<tr><td>Missing `in_auth` in one of the names</td><td>[<a href="#eg">C</a>, <a href="#eg">D2</a>]</td><td>One of the citing authors failed to include the _in_ author</td><td>High</td><td>`auto_in+`, `auto_in-`</td></tr>

<!-- basio +/- -->
<tr><td>One name with a basionym, the other without</td><td>[<a href="#eg">D</a>]</td><td>One of the citing authors failed to include the basionym</td><td>Medium</td><td>`auto_basio+`, `auto_basio-`</td></tr> 

<!-- ex -->
<tr><td>Missing `ex_auth` (or `ex_bas`) in one of the names</td><td>[<a href="#eg">E</a>]</td><td>One of the citing authors failed to include the _ex_ author</td><td>Medium</td><td>`auto_exin+`, `auto_exin-`</td></tr> 

<!-- ex to main -->
<tr><td>`auth` in one name is `ex_auth` in the other</td><td>[<a href="#eg">F</a>]</td><td>Confusion by citing author [5]</td><td>Medium</td><td>`manual?`</td></tr> 

<!-- 2nd of & auth -->
<tr><td>`auth` differs: 2nd author missing from a pair of authors (sep. by “&” or “et.”)</td><td>[<a href="#eg">G</a>]</td><td>More likely to be an error (missing author) than a republication of the same `taxon_name` by a different author team [6]</td><td>Medium</td><td>`manual?`</td></tr> 

<!-- diff basio -->
<tr><td>Different basionym author (`basio`), same primary author (`auth`)</td><td>[<a href="#eg">H</a>]</td><td>This should not happen [1], and is likely to be an error</td><td>Medium</td><td>`auto_basexin`</td></tr> 

<!-- Obviously incomplete author -->
<tr><td>Obviously incomplete author list in `auth`</td><td>[<a href="#eg">I</a>]</td><td>An error</td><td>Medium</td><td>`manual?`</td></tr> 

<!-- missing auth -->
<tr><td>Same `basio`, missing `auth`</td><td>[<a href="#eg">J</a>]</td><td>An error [7]</td><td>Low</td><td>`manual??`</td></tr> 

<!-- cfo -->
<tr><td>Same `canonical_form` and `auth`, different `irank`</td><td>[<a href="#eg">K</a>]</td><td>An error by citing author [2]</td><td>Low</td><td>`auto_irank`, `manual??`</td></tr>

<!-- diff auth initials -->
<tr><td>Same `taxon_name`, different `auth` initials</td><td>[<a href="#eg">L</a>]</td><td>Probably separate publications of the name, but could be error</td><td>Low</td><td>`manual??`</td></tr>

<!-- missing first auth -->
<tr><td>Same `taxon_name`, missing first author in `auth`</td><td>[<a href="#eg">M</a>]</td><td>Maybe separate publications of the name, but may also be error [6]</td><td>Low</td><td>`manual??`</td></tr>

<!-- diff auth -->
<tr><td>Same `taxon_name`, clearly different `auth`</td><td>[<a href="#eg">N</a>]</td><td>Separate publications of the name [6]</td><td>Very low</td><td>`no_match`</td></tr>
      
</table>

<script>
function showhide(z) {
    var x = document.getElementById(z);
    if (x.style.display == "none") {
        x.style.display = "block";
    } else {
        x.style.display = "none";
    }
}
</script>

<div style="text-align: right;"><button onclick="showhide('notes')">Show/hide notes for this table</button></div>

<div id="notes" style="display:none;">

Notes:

 1. The basionym author (of the specific or infraspecific epithet)
 should not change, even if a second new combination is made, since
 the epithet can only have one author.
 2. It is indeed possible that the same author will have published an
 infraspecific epithet twice, with different ranks, but seems quite
 unlikely. It seems more likely that one citing author gave an
 incorrect rank. However, the overall confidence in the names being
 the same is low.
 3. When two or more of these variations are combined (e.g., example
 B, below), they should generally reduce the likelihood of the two
 names matching, though probably less than additively.
 4. “L.” and “L.f.” (= filius) are different people, but in this case
 the difference was a copying error.
 5. Since the `ex_auth` publication is a valid _republication_ of the
 `auth` publication it should refer to exactly the same taxon concept
 as implied by the `auth` name, and should be effectively interchangeable.
 6. A erroneously missing author in a string of authors is 
 more likely when the missing author is a second (or third author) than a first
 author.
 7. Care (i.e., further research) is needed if there are several
 alternate names that match `basio` but differ in `auth`.
 
</div>

<a name="eg"></a><div style="text-align: right;"><button onclick="showhide('example')">Show/hide examples for this table</button></div>

<div id="example" style="display:none;">

Examples:
<pre>
  A:  Ciminalis prostrata (Haenke) Á. Löve & D. Löve
      Ciminalis prostrata (Haenke) A.Love & D.Love
     
  B1: Mertensia paniculata var. eastwoodae (J.F.Macbr.) Hultén
      Mertensia paniculata var. eastwoodiae (Macbride) Hultén

  B2: Carex halleri W.W.H.Gunn
      Carex halleri Gunnerus

  B3: Ranunculus auricomus L.f.
      Ranunculus auricomus L.       [4]

  C:  Athyrium filix-femina subsp. cyclosorum (Rupr.) C.Chr.
      Athyrium filix-femina subsp. cyclosorum (Rupr.) C.Chr. in Hultén
     
  D1: Fauria crista-gallii (Menzies) Makino
      Fauria crista-galli Makino

  D2: Thelypteris phegopteris Sloss. in Rydb.
      Thelypteris phegopteris (L.) Sloss.

  E1: Puccinellia interior T.Sorensen
      Puccinellia interior T.J. Sørensen ex Hultén
     
  E2: Pulsatilla dahurica (Fisch.) Sprengel
      Pulsatilla dahurica (Fisch. ex DC.) Spreng.

  F:  Lloydia serotina (L.) Rchb.
      Lloydia serotina (L.) Salisb. ex Rchb.

  G1: Arnica alpina (L.) Olin
      Arnica alpina (L.) Olin & Ladau

  G2: Draba eschscholtzii Pohle
      Draba eschscholtzii Pohle & N. Busch

  H:  Alnaster sinuata (Regel) Czerep.
      Alnaster sinuatus (Rydb.) Czerep.

  I:  Symphyotrichum pygmaeum (Lindl.) & Selliah
      Symphyotrichum pygmaeum (Lindl.) Brouillet & Selliah

  J1: Calypso bulbosa (L.)
      Calypso bulbosa (L.) Oakes

  J2: Matteuccia struthiopteris var. pensylvanica (Willd.)
      Matteuccia struthiopteris var. pensylvanica (Willd.) C.V. Morton

  K:  Vaccinium uliginosum subsp. vulcanorum (Kom.) Jurtzev
      Vaccinium uliginosum var. vulcanorum (Kom.) Jurtzev

  L:  Glyceria pauciflora C.Presl
      Glyceria pauciflora J.Presl

  M:  Potentilla elegans Cham. & Schltdl.
      Potentilla elegans Schltdl.          [6]

  N1: Carex media var. stevenii (Holm) Kalela
      Carex media var. stevenii (T. Holm) Fernald

  N2: Myosotis palustris L.
      Myosotis palustris (L.) Nath.

</pre>
</div>
<p/>

These potential reasons for a mismatch between two citations of the
same name can be classed so that at a later date users can limit the
accepted matches to certain levels of confidence:

<table>
<tr>
  <th>Confidence of match</th>
  <th>Match codes</th>
</tr>
<tr>
  <td>Very High and High</td>
  <td>`auto_punct`, `manual`, `auto_in+`, `auto_in-`</td>
</tr>
<tr>
  <td>Medium</td>
  <td>`auto_basio+`, `auto_basio-`, `auto_exin+`, `auto_exin-`, `manual?`, `auto_basexin`</td>
</tr>
<tr>
  <td>Low</td>
  <td>`auto_irank`, `manual??`</td>
</tr>
<tr>
  <td>Very low; not a match</td>
  <td>`no_match`</td>
</tr>
</table>

## The `matchnames` program <a name="mn"></a>

To deal with this problem of i) needing more taxonomic precision in
judging name similarity than that provided by a generic fuzzy-match
score, while ii) not having time to check every fuzzy match (and
definitely not having time to return to the primary literature for
every name encountered), I created a tool that applies a sequence of
taxonomic, rule-based transformations to the names, and then if a
match is found records the kind of match. A limited number of
non-matching names is subsequently presented to an operator for a
human judgment based on details that are more nuanced than could be
easily automated.

The tool is called `matchnames` (available on
[Github](https://github.com/camwebb/taxon-tools)). Full details of use
are in the tool’s
[`man` page](https://github.com/camwebb/taxon-tools/blob/master/doc/matchnames.md). The
sequence of matching logic (and output match codes) follows the above
framework of potential reasons for name mismatch:

1. Is there an exact match to all parts of the name (genus hybrid
marker, genus name, species hybrid marker, species epithet,
infraspecific rank signifier, infraspecific rank, author sting)? If
so match code is: `exact`.
2. Both query name and reference names
are “de-punctuated” to remove the effect of mis-matching spaces,
periods, non-ASCII author name characters, etc. The depunctuation
procedure is: a) converting non-ASCII characters into their
appropriate ASCII character (e.g., “ï” to “i”), b) converting “and” or “et”
into “&”, c) removing all punctuation other than “(“, “)” and “&”, d) 
converting to lower-case. If an exact match exists between the
depunctuated query string and a depunctuated reference name, the
match code is: `auto_punct`.  
3. If the author is missing in the query name, accept the reference
name (with author) if there is _only one_ with exactly the same 
(when matching to IPNI or TROPICOS
only). Match code: `auto_noauth`.
4. If one basionym is missing, a match is allowed (e.g., _Cardaminopsis umbrosa_ Czerep. vs. _Cardaminopsis umbrosa_ (Turcz.) Czerep.). Match code:
`auto_basio+`, `auto_basio-`.
5. If the names and author strings are the same after all _in_
elements have been stripped, a match is allowed. Match code:
`auto_in+`, `auto_in-`.
6. If the names and author strings are the same after all _ex_ and _in_
elements have been stripped, a match is allowed (e.g., _Papaver
nudicaule_ subsp. _americanum_ Rändel vs. _Papaver nudicaule_
subsp. _americanum_ Rändel ex D.F.Murray). Match code:
`auto_exin+`, `auto_exin-`.
7. If the names and author strings are the same after all _ex_ and
_in_ and basionym elements have been stripped, a match is
allowed. Match code: `auto_basexin`.
8. If all elements of the name match except for the infraspecific rank, 
record the match as: `auto_irank`.
9. If there are any reference names (list B) that may match the query name 
approximately, move to “manual matching” (below). Match code: `manual`, `manual?` or `manual??`.
10. Record a failure to match. Match code: `no_match`.

### Manual matching

The human operator can then apply further rules which are hard to
program for automated decision-making. This is our current rule-set, following the <a href="#tab">above</a> table:

Accept a match at high confidence (`manual`):

 1. Missing initials for an author, or different abbreviations of
 author’s surnames, in `author_string`,
 2. Spelling variation in `gen`, `sp`, `infr` with (essentially) the
 same `auth`.

Accept a match at medium confidence (`manual?`):

 1. `auth` in one name is `ex_auth` in the other,
 2. `auth` differs: 2nd author missing from a pair of authors (sep. by
 “&” or “et.”)
 3. Obviously incomplete author list in `auth`
 
Accept a match at low confidence (`manual??`):
 
 1. Same `basio`, missing `auth`
 2. Same `taxon_name`, different `auth` initials 
 3. Same `taxon_name`, missing first author in `auth`
 
Reject the match (`no_match`):

 1. When the two author strings are clearly representing
 different (sets of) of authors.
 2. If the query name contains only the basionym author, and the
 reference name has the basionym author plus the revising author, or
 vice versa.
 3. When the query name is of species rank and the reference name of
 infraspecific rank, or vice versa.
 4. If the query name is followed by “auct.”

With large lists this manual checking can be a time consuming phase,
and is prone to operator errors due to concentration lapses. Some of
these decisions might still yet be achieved with clever code.

## Summary

Using the `matchnames` tool it is possible in a matter of only a few
hours to compare a list of Alaskan plant names to other resources,
such as IPNI and Tropicos. The type of orthographic match can be
recorded, as can the original names, and the date and name of the
operator. Thus if in the future, after further research, a particular match  is
deemed to actually be incorrect, no data has been lost and the match
status can simply be corrected. In the next post I’ll talk about the data model we’re using to store these orthographic matches.

----

<div id="disqus_thread"></div><script>
var disqus_config = function () {
this.page.url = 'https://alaskaflora.org/pages/blog3.html';  // Edit
this.page.identifier = 'alaskaflora_blog3';                  // Edit
};(function() {  var d = document, s = d.createElement('script');
s.src = 'https://alaskaflora-org.disqus.com/embed.js';
s.setAttribute('data-timestamp', +new Date());
(d.head || d.body).appendChild(s);
})(); </script>


