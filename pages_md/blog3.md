% Variations of a taxonomic name

# Variations of a taxonomic name

_Posted by [Cam](people.html#cam) on 2018-12-19_

## The problem 

A single taxonomic name often occurs in different forms in different
publications. In terms of character string differences, the variation
may be slight (e.g., a missing space after an author’s initials, or a
single character mispelling of a specific epithet), or major (e.g., a
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
also many reccomendations and often several “correct” ways to cite a
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
to the same name as _first published_.  No judgement about the taxon
concept (or circumscription) of the names is being attempted at this
step.  The most reliable way to solve this question is to track down
the usage(s) of both names in the primary literature and carefully
determine if the autors were refering to the same name as originally
published. While this approach is feasible in the case of a taxonomist
performing a revision, it is too slow to incorporate when assembling
large lists of names, as in the data integrations step of our flora of
Alaska project. What is needed is a sensible, transparent algorithm
(set of rules) that can be applied by a machine, with human judgement
being required in only a small number of cases. As long as the
original names are preserved and the details of the automated judgment
are recorded, then even if a few matches might later be found to be
incorrect, no information is lost.  This process of designing a
taxonomic matching algorithm and associated software tool has occupied
me for the past few weeks.

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
that match (e.g., mispelling, differences in author string). For our
project’s purpose---building a network of data integrated by
names---using the match scores these tools offer is not
sufficient.

### Botanical names, deconstructed

Because there are general rules that govern the construction of
taxonomic names, some additional pattern-matching can be applied in
comparing the different elements of two similar names. This can then
produce an estimate of the liklihood that two name strings actually
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

These codes are:

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
 * `author_string`: The whole author string.

### Matching two variants

The presence or absence of, or variation in, these elements in two
names that are being matched indicates different kinds of choices or
errors by the person citing the name, and thus can give an indication
of the liklihood that the matched names refer to the same name. Here
is our current logic, which is encoded into the `matchnames` software
tool (below). The types of variation are approximately ranked in order
of decreasing likelihood that the names are truly the same:

<table>
  <tr>
    <th>Variation</th>
    <th>E.g.</th>
    <th>Likely cause of variation</th>
    <th>Liklihood that names refer to same name [3]</th>
    <th>(Match code; see below)</th>
  </tr>

<!-- punct -->
<tr><td>Spacing differences, missing periods, differences in ASCII
vs. non-ASCII characters (accents, etc.) in
`author_string`</td><td>[A]</td><td>Minor formatting choices, errors in
encoding</td><td>Very high</td><td>`auto_punct`</td></tr>

<!-- author variations --> 
<tr><td>Missing initials for an author, or different abbreviations of
author’s surnames, in `author_string`</td><td>[B]</td><td>Choices and/or errors by the
citing authors</td><td>Very high</td><td>`manual`</td></tr>

<!-- g+s variations -->
<tr><td>Spelling variation in `gen`, `sp`, `infr` with (essentially)
the same author string.</td><td>[A]</td><td>Copying
errors</td><td>High</td><td>`manual`</td></tr>

<!-- in -->
<tr><td>Missing `in_auth` in one of the names</td><td>[X]</td><td>One of the citing authors failed to include the _in_ author</td><td>High</td><td>`auto_in+`, `auto_in-`</td></tr>

<!-- basio +/- -->
<tr><td>One name with a basionym, the other without</td><td>[D]</td><td>One of the citing authors failed to include the basionym</td><td>Medium</td><td>`auto_basio+`, `auto_basio-`</td></tr> 

<!-- ex -->
<tr><td>Missing `ex_auth` (or `ex_bas`) in one of the names</td><td>[X]</td><td>One of the citing authors failed to include the _ex_ author</td><td>Medium</td><td>`auto_ex+`, `auto_ex-`</td></tr> 

<!-- ex to main -->
<tr><td>`auth` in one name is `ex_auth` in the other</td><td>[X]</td><td>Confusion by citing author [5]</td><td>Medium</td><td>`manual?`</td></tr> 

<!-- one of & auth -->
<tr><td>`auth` differs in one name missing one of a pair of names (sep. by “&” or “et.”)</td><td>[J]</td><td>More likely to be an error (missing name) than a republication of the same `taxon_name` by a different author team</td><td>Medium</td><td>`manual?`</td></tr> 

<!-- diff basio -->
<tr><td>Different basionym author (`basio`), same primary author (`auth`)</td><td>[C]</td><td>This should not happen [1], and is likely to be an error</td><td>Medium</td><td>`auto_basio`</td></tr> 

<!-- cfo -->
<tr><td>Same `canonical_form` and `auth`, different `irank`</td><td>[A]</td><td>An error by citing author [2]</td><td>Low</td><td>`auto_rank`</td></tr>

<!-- diff auth initials -->
<tr><td>Same `taxon_name`, different `auth` initials</td><td>[I]</td><td>Probably separate publications of the name, but could be error</td><td>Low</td><td>`no_match`</td></tr>

<!-- diff auth -->
<tr><td>Same `taxon_name`, clearly different `auth`</td><td>[A]</td><td>Separate publications of the name</td><td>Very low</td><td>`no_match`</td></tr>
      
</table>

<script> 
function showhide() {
    var x = document.getElementById("notes");
    if (x.style.display == "none") {
        x.style.display = "block";
    } else {
        x.style.display = "none";
    }
}
</script>

<div style="text-align: right;"><button onclick="showhide()">Show/hide notes for this table</button></div>

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
 as implied by the `auth` name, and should be effectively interchangable.

Examples:

 * **A**: _Ciminalis prostrata_ (Haenke) Á. Löve & D. Löve
     vs. _Ciminalis prostrata_ (Haenke) A.Love & D.Love
 * **B**: _Mertensia paniculata_ var. _eastwoodae_ (J.F.Macbr.) Hultén
     vs. _Mertensia paniculata_ var. _eastwoodiae_ (Macbride) Hultén;
     _Carex halleri_ W.W.H.Gunn vs. _Carex halleri_ Gunnerus;
     _Ranunculus auricomus_ L.f. vs. _Ranunculus auricomus_ L. [4]
 * **C**: _Alnaster sinuata_ (Regel) Czerep. vs. _Alnaster sinuatus_
     (Rydb.) Czerep.
 * **D**: _Fauria crista-gallii_ (Menzies) Makino vs. _Fauria
     crista-galli_ Makino
 * **E**: _Thelypteris phegopteris_ (L.) Sloss. vs. _Thelypteris
     phegopteris_ Sloss. in Rydb.
 * **F**: _Calypso bulbosa_ (L.) vs. _Calypso bulbosa_ (L.) Oakes
 * **G**: _Lloydia serotina_ (L.) Rchb. vs. _Lloydia serotina_ (L.)
     Salisb. ex Rchb.
 * **H**: _Puccinellia interior_ T.Sorensen vs. _Puccinellia interior_
     T.J. Sørensen ex Hultén; _Pulsatilla dahurica_ (Fisch.) Sprengel
           vs. _Pulsatilla dahurica_ (Fisch. ex DC.) Spreng.
 * **I**: _Glyceria pauciflora_ C.Presl vs. _Glyceria pauciflora_ J.Presl
 * **J**: _Arnica alpina_ (L.) Olin vs. _Arnica alpina_ (L.) Olin & Ladau
 
</div>


<table>
<tr><td colspan="3"><center>Confidence of match</center></td></tr>
<tr>
  <th>Very High and High</th>
  <th>Medium</th>
  <th>Low</th>
</tr>
<tr>
  <td>`auto_punct`, `manual`, `auto_in`</td>
  <td>`auto_basio+`, `auto_basio-`, `auto_basio`, `auto_ex+`, `auto_ex-`, `manual?`</td>
  <td>`auto_rank`, `manual??`</td>
</tr>
</table>

To go beyond a general, numeric match





To deal with this problem of i) needing more taxonomic precision in
judging name similarity, while ii) not having time to check every
fuzzy match (and definitely not having time to return to the primary
literature for every name encountered), I created a tool that applies
a sequence of taxonomic, rule-based transformations to the names, and
if a match is then found, records the kind of match. A limited number
of non-matching names is subsequently presented to an operator for a
human judgement based on details that are more nuanced than could be easily
automated.

The tool is called `matchnames` (available on [Github](...)). Full
details of use are in the tool’s [`man` page](...). The general
logical sequence (and output match codes) is as follows:

1. Is there an exact match to all parts of the name (genus hybrid
marker, genus name, species hybrid marker, species epithet,
infraspecific rank signifier, infraspecific rank, author sting)? If
so match code is: **exact**.
2. Both query name and reference names
are “de-punctuated” to remove the effect of mis-matching spaces,
periods, non-ASCII author name characters, etc. The depunctuation
procedure is: a) converting non-ASCII characters into their
appropriate ASCII character (e.g., “ï” to “i”), b) converting “and”
into “&”, c) removing all punctuation other than “(“, “)” and “&”, d) 
converting to lower-case. If an exact match exists between the
depunctuated query string and a depunctuated reference name, the
match code is: **auto_punct**.  
3. If the author is missing in the query name, accept the reference
name (with author) if there is _only one_ with exactly the same 
(when matching to IPNI or TROPICOS
only).
4. If basionyms are different or missing, a match is allowed (e.g., _Cardaminopsis umbrosa_ Czerep. vs. _Cardaminopsis umbrosa_ (Turcz.) Czerep.). Match code:
**auto_basio**.
5. If the names and author strings are the same after all _ex_ and _in_
elements have been stripped, a match is allowed (e.g., _Papaver
nudicaule_ subsp. _americanum_ Rändel vs. _Papaver nudicaule_
subsp. _americanum_ Rändel ex D.F.Murray). Match code:
**auto_exin**.
6. If the names and author strings are the same after all _ex_ and
_in_ and basionym elements have been stripped, a match is
allowed. Match code: **auto_basexin**.
7. If there are any reference names that may match approximately the query
name, move to “manual matching” (below). Match code: **manual** or
**manual?**.
8. Record a failure to match. Match code: **no_match**.

### Manual matching

The human operator can then apply further rules which are harder to
program for automated decision-making. This is our current rule-set
(Cam & Steffi, Dec 2018):

Accept a match:

 1. Spelling variations in the query name or author string.
 2. If the query name is obviously missing one or more authors seperated by an
 “&” in the reference string.
 3. If the query and reference name differ in “var.” vs. “subsp.”
 _and_ the author strings are the same.

Reject a match:

 1. When the two author strings are clearly representing
 non-overlapping lists of authors.
 2. If the query name contains only the basionym author, and the
 reference name has the basionym author plus the revising author, or
 vice versa.
 3. When the query name is of species rank and the reference name of
 infraspecific rank, or vice versa.
 4. If the query name is followed by “auct.”

Note again: when a manual match is accepted, the matching name is not
being accepted as the _same_ as the query name, only that it is judged
worth recording as a possible, adjudicated match with a good
possibility that it represents the intention of the creator of the
query name.

With large lists this can be a time consuming phase, and is prone to
errors due to concentration lapses. Some of these decisions might be
achieved with clever code, but I haven’t done that yet.








 (e.g., in the synonym lists of .

There are two parts to this question of name variation: i) how to
structure the taxonomic name database, and ii) how to assess that the
variations refer to the “same name”.

## Database structure

“How much detail to keep?” is a perenial question when modeling
anything. In the case of modeling the taxonomic relationships among
names, the specific question is 

The two general options in modeling this name string variation in a
database are: i) to maintain a single canonical name and to resolve
variation prior to entering names into the database, or ii) to
preserve all name variation in the database and record the resolution
of variation within the database:

<pre>
Data Source X:  Aaaa aaaa  is accepted,
                Aaaa bbbc  is a synonym of Aaaa aaaa

We assessed:    Aaaa bbbb  is the “correct” spelling of Aaaa bbbc


Approach 1:     Names      Status/mapping     Source  (Optional notes)
                =========  =================  ======  ==================
                Aaaa aaaa  accepted           X
                Aaaa bbbb  syn. of Aaaa aaaa  X       spelled as “Aaaa
                                                      bbbc” in Src X

Approach 2:     Names      Status/Mapping     Source
                =========  =================  ======
                Aaaa aaaa  accepted           X
                Aaaa bbbc  syn. of Aaaa aaaa  X
                Aaaa bbbc  ~= Aaaa bbbb       Assessed
</pre>

Because full recording of data provenance is a core design element of
this project, I have chosen to go with the second approach. However,
this way adds a layer of complexity, as every query of the taxonomic
relationship of two names requires that any orthographic variation be
resolved as well (though this resolution may be pre-calculated and
cached).

Although the above diagram shows a single data table, in practice, it
seems conceptually clearer to have two tables: a taxonomic
relationship table and an orthographic mapping table (especially since
eventually we need to model the taxonomic relationships as
concept-to-concept relationships, not just name-to-name
relationships).  So for the moment, my data modeling approach is this:

<pre>
+----------+          +-------------+          +----------------+
| Source   |          | Name        |          | Ortho. mapping |
+==========+          +=============+          +----------------+
| name     | -------> | row id      | <===---- | from name      |
+----------+          +-------------+     |    +----------------+
| source   |          | name string |     +--- | to name        |
+----------+          +-------------+          +----------------+
| (guid)   |                                   | how assessed   |
+----------+                                   +----------------+
</pre>

...with additional tables to store name-to-name synonymy relationships,
and taxon concept relationships.

### (An aside: Use a graph database?)

Since I first became enamoured with RDF and the smeantic web, I’ve
kept an eye on graph databases, and played around with triple
stores ([4store](https://github.com/4store/4store),
[Allegrograph](https://franz.com/agraph/support/documentation/current/agraph-introduction.html),
[StarDog](https://www.stardog.com/),
[ClioPatria](https://cliopatria.swi-prolog.org/home)) and
[Neo4j](https://neo4j.com/) and
[TinkerPop/Gremlin](https://tinkerpop.apache.org/). I also have a
frequently re-occuring desire to learn Prolog, and the conceptual
similarity between querying triples and Prolog’s declarative pattern
matching tempts me to invest in learning
[ClioPatria](https://cliopatria.swi-prolog.org/home), a Prolog-based
triple store. So as it became clear that the flora project database
would need to include name-to-name mappings, possibly in chains of
arbitrary length, I wondered seriously if I should switch to a graph
database for the underlying engine for this project.
[Gremlin](https://tinkerpop.apache.org/docs/3.3.4/tutorials/gremlins-anatomy/),
[Cypher](https://neo4j.com/cypher-graph-query-language/) and
[SPARQL 1.1](https://www.w3.org/TR/sparql11-query/#propertypath-arbitrary-length)
(and Prolog) all allow for searching over arbitrary length property
paths.

In the end I’m deciding to stick to a SQL RDMS solution for reasons of
familiarity, stability, speed, and hopeful longevity of the
database. But what nailed it was discovering that MariaDB, which is my
choice of DB platform, now has
[Recursive Common Table Expressions](https://mariadb.com/kb/en/library/recursive-common-table-expressions-overview/),
which permit following a data link chain of arbitrary length until
some condition is met. So now I could query across multiple
name-to-name orthographic mappings, if needed. Indeed, I hope I won’t
need this (SQL is hard enough and ugly enough as it is!), but the
facility is there.

## Canonical names

Even if we preserve all name variation in the database, the final
Flora will need a name string to be chosen for presentation. The
choice of which variant is somewhat arbitrary --- is the abbreviated
author’s name really “better” than the full name? --- but having a
“canonical” name string for a name will simplify matters. By making all
orthographic match assessments only one step from a canonical name, we
perhaps will remove the need for recursive searches along orthographic
name-to-name chains (see above). 

So which name to chose? I had stated in the
[first blog post](blog1.html) that we would use
[The Plant List](http://www.theplantlist.org/) as our reference
set. Rod Page rightly took issue with this, asking “why not
IPNI?” Unfortunately, IPNI does not contain all the names we may want
(neither does The Plant List), so I’ve decided to use a hierarchy of
sources to come up with our canonical names set:

 1. IPNI
 2. Tropicos
 3. WCSP (as found in The Plant List)
 
I’d have liked to include the Flora of North America (FNA) in this
list, probably at rank 2. There’s a team in Ottawa working on parsing
and databasing the FNA accounts (including James Macklin, Jocelyn
Pender, and Joel Sachs), and they have kindly given me access to the
FNA names data, but it will take a while to come to grips with this
resource. We will definitely link our Flora to the FNA work, and may
include their names in the above canonical name list, but not quite yet.


## Appendix: Examples of judgment calls made during manual matching

The exact question being asked is: “Despite the variation, do these
two name strings refer to the same name as published in the same
source?” No judgement about the taxon concept (or circumscription) of
the names is being attempted.  Symbol key: `!=` means not the same
name; `~=` means judged to be the same name; `?=` means judged to be
the same name with low confidence.

<pre>
** 1a. Different publishing authors **

    Androsace chamaejasme Host
 != Androsace chamaejasme Wulfen

    Arabis holboelii var. retrofracta (Graham) Rydb.
 != Arabis holboellii var. retrofracta (Graham) Jeps.

    Packera ogotorukensis (Packer) W.A.Weber & A.Love
 != Packera ogotorukensis (Packer) Á. Löve & D. Löve

    Carex media var. stevenii (Holm) Kalela
 != Carex media var. stevenii (T. Holm) Fernald

    Ranunculus auricomus L.f.
 != Ranunculus auricomus L. & W.Koch

    Parnassia kotzebuei Cham. & Schltdl.
 != Parnassia kotzebuei Cham. ex Spreng. {but see ‘missing ex author’ below}

    Papaver radicatum subsp. porsildii (Knaben) D.Love
 ?= Papaver radicatum subsp. porsildii (Knaben) Á.Löve


** 1b. Diff. authors (basionym author vs. new publishing author) **

    Glyceria pauciflora C.Presl
 != Glyceria pauciflora (ex C.Presl) J.Presl

    Myosotis palustris L.
 != Myosotis palustris (L.) Nath.

    Alnus fruticosa (Rupr.) Ledeb.
 != Alnus fruticosa Rupr.

    Platanthera convallariaefolia (Fisch. ex Lindl.) Lindl.
 ?= Platanthera convallariifolia Fisch. ex Lindl.


** 1c. Overlapping but different authors **

    Draba eschscholtzii Pohle
 != Draba eschscholtzii Pohle & N. Busch

    Carex anthoxanthea C.Presl
 != Carex anthoxanthea J. Presl & C. Presl

    Solidago simplex Humb., Bonpl. & Kunth
 != Solidago simplex Kunth

    Potentilla elegans Cham. & Schltdl.
 != Potentilla elegans Schltdl.

    Arctous rubra (Rehder & E.H.Wilson) Nakai & Koidz.
 != Arctous rubra (Rehder & E.H.Wilson) Nakai


** 1d. Obviously incomplete author **

    Symphyotrichum pygmaeum (Lindl.) & Selliah
 ~= Symphyotrichum pygmaeum (Lindl.) Brouillet & Selliah


** 2. Different ranks **

    Aconitum delphinifolium subsp. delphinifolium
 != Aconitum delphiniifolium var. delphiniifolium


** 3a. Different basionyms **

    Mertensia paniculata var. eastwoodae (J.F.Macbr.) Hultén
 ~= Mertensia paniculata var. eastwoodiae (Macbride) Hultén

    Alnaster sinuata (Regel) Czerep.
 ?= Alnaster sinuatus (Rydb.) Czerep.


** 3b. Missing basionym **

    Fauria crista-gallii (Menzies) Makino
 ~= Fauria crista-galli Makino

    Alnaster sinuata (Regel) Czerep.
 ~= Alnaster sinuatus Czerep.

    Thelypteris phegopteris (L.) Sloss.
 ~= Thelypteris phegopteris Sloss. in Rydb.


** 4. Missing author, same basionym **

    Calypso bulbosa (L.)
 ?= Calypso bulbosa (L.) Oakes

    Matteuccia struthiopteris var. pensylvanica (Willd.)
 ?= Matteuccia struthiopteris var. pensylvanica (Willd.) C.V. Morton

    Cirsium edule var. macounii (Greene)
 ?= Cirsium edule var. macounii (Greene) D.J. Keil


** 5. Same author as ‘ex author’ **

    Trisetum sibiricum subsp. litoralis (Rupr.) Roshev.
 ~= Trisetum sibiricum subsp. litorale Rupr. ex Roshev.
 
    Lloydia serotina (L.) Rchb.
 ~= Lloydia serotina (L.) Salisb. ex Rchb.

    Castilleja pallida subsp. mexiae Eastw. ex Pennell
 ~= Castilleja pallida subsp. mexiae Pennell

    Colophospermum mopane (Benth.) Leonard
 ~= Colophospermum mopane (J. Kirk ex Benth.) J. Léonard

    Carex sprengelii Sprengel
 ~= Carex sprengelii Dewey ex Spreng.

    Carex chordorrhiza Ehrh. ex L.f.
 ~= Carex chordorrhiza L.f.

    Eriophorum callitrix Cham. ex C.A.Mey.
 ~= Eriophorum callitrix C.A.Mey.


** 6. Missing ‘ex author’ **

    Colophospermum mopane (Benth.) Leonard
 ~= Colophospermum mopane (J.Kirk ex Benth.) J.Léonard

    Cystopteris montana (Lam.) Bernh.
 ~= Cystopteris montana (Lam.) Bernh.; Desv.

    Sparganium minimum (C.Hartm.) Fr.
 ~= Sparganium minimum Fr. ex Wallr.

    Artemisia lagocephala var. kruhsiana (Besser) Glehn
 ~= Artemisia lagocephala var. kruhsiana (Besser) Gehn ex Hultén

    Cardaminopsis umbrosa (Turcz.) Czern.
 ~= Cardaminopsis umbrosa (Turcz. ex Steud.) Czerep.

    Cardamine pennsylvanica Muhl.
 ~= Cardamine pensylvanica Muhl. ex Willd.

    Callitriche verna L. emend. Kütz.
 ~= Callitriche verna L.

    Puccinellia interior T.Sorensen
 ~= Puccinellia interior T.J. Sørensen ex Hultén

    Equisetum fluviatile L. ampl. Ehrh.
 ~= Equisetum fluviatile L.

    Puccinellia langeana subsp. asiatica T.Sorensen
 ~= Puccinellia langeana subsp. asiatica T.J. Sørensen ex Hultén

    Pulsatilla dahurica (Fisch.) Sprengel
 ~= Pulsatilla dahurica (Fisch. ex DC.) Spreng.

    Saxifraga caespitosa subsp. sileneflora (Sternb.) Hultén
 ~= Saxifraga cespitosa subsp. sileneflora (Sternb. ex Cham.) Hultén

    Rorippa curvisiliqua (Hook.) Besser
 ~= Rorippa curvisiliqua (Hook.) Bessey ex Britton

    Digitaria ischaemum (Schreb.) Schreb. ex Muhl.
 ~= Digitaria ischaemum (Schreb.) Muhl.


** 8. Fuzzy-matched author **

    Osmorhiza depauperata L.Ll.Phillips
 ~= Osmorhiza depauperata Phil.

    Carex halleri W.W.H.Gunn
 ~= Carex halleri Gunnerus


    Ranunculus auricomus L.f.
 ~= Ranunculus auricomus L.      (L. and L. ‘filius’ are diff auths, but
                                  this was a typo)


** Too tricky to make a call **

    Glyceria pauciflora C.Presl
 ?= Glyceria pauciflora J.Presl
 ?= Glyceria pauciflora (ex C.Presl) J.Presl
 ?= Glyceria pauciflora J.Presl in C.Presl
 ?= Glyceria pauciflora J.Presl & C.Presl



making a call - an authjor was forgotten

    Arnica alpina (L.) Olin
 ~= Arnica alpina (L.) Olin & Ladau

    Eriophorum callitrix Cham. ex C.A.Mey.
 ~= Eriophorum callitrix C.A.Mey.

 Juncus castaneus [Clairv.] bracket?
</pre>

----

<div id="disqus_thread"></div><script>
var disqus_config = function () {
this.page.url = 'https://alaskaflora.org/pages/blog2.html';  // Edit
this.page.identifier = 'alaskaflora_blog2';                  // Edit
};(function() {  var d = document, s = d.createElement('script');
s.src = 'https://alaskaflora-org.disqus.com/embed.js';
s.setAttribute('data-timestamp', +new Date());
(d.head || d.body).appendChild(s);
})(); </script>


