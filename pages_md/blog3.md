% Modeling names


One of the key steps in data modelling - how much detail to keep. With names,
single table?: GoodName Syn SpellinvariationNotes... But... one of our key goals is to keep all provenance information. So need to keep each name and statments about that name. 

Expands to Network!

(Aside, graph DBs? CioPatra)

But can be done with recursive SQL. 



Fork in the road - how much complexity to keep. All of it, at first.

Engine?  GraphDB (gremlin... ugh, new complex). Go with RDF - I know
it. Allegrograph? Yes.. ttl, ... or PROLOG+RDF = (?) ?

But may also be able to do it in SQL, with recursion?

# Model, query, reasoning... 

resaoing via custom logical queries? or a reasoner, or PROLOG!?  


# Recursion... 

Not poss in sparql See refs (Bookmarked)

could do property paths in SPARQL1.1, but would need to model ortho properties as :Rel1 { :Name1 :ortho :Name2 } Rel1 :prop “something” 
Need named graphs and GRAPH in SPARQL. All Fine in Allegrograph

Recursion is poss in MariaDB

But prolog? Obviously... but... need to learn properly

Again back to mariaDB

# Matching

More detail and rules than GNR.

All mappings are recorded (name in, name mapped to, when, how, by who) so all choices can be examined and possibly rejected later.

A majority of matches can be made automatically:

 * `if` “Exact string match” `then` “auto” status `exact`
 * `else if` “De-punctuation match” (remove spaces, periods; collapse accents, etc. to ASCII; lowercase) `then` “auto” status `depunct`
 * `else if` The name is missing the basionym (e.g., _Cardaminopsis
    umbrosa_ Czerep. vs. _Cardaminopsis umbrosa_ (Turcz.) Czerep.) `then` “auto” status `depunct_basio`
 * `else if` The name is missing the `ex ...` element (e.g., _Papaver
   nudicaule_ subsp. _americanum_ Rändel vs. _Papaver nudicaule_
   subsp. _americanum_ Rändel ex D.F.Murray)
   `then` “auto” status `depunct_ex`
 * `else if` The name is missing both the basionym and the `ex ...` element
   `then` “auto” status `depunct_basio_ex`
 * `else if` “fuzzy match _plus_ manual choice” status `manual`
 * `else` status `no_match`
 
The penultimate step requires involves i) matching the de-punctuted
query string against a list of depunctuated strings from the reference
names. e.g.:

 * `carexmediavarstevenii(holm)fernald`
 * `carexcapillarissubspfuscidula(vikrecz)alove&dlove`
 * `carexpyrenaicasubspmicropoda(camey)hulten`
 * `carexfestivavarhaydeniana(olney)wboott`
 * `carexrigidasubspbigelowii(torrexschwein)steffen`
 * `carexatratavarchalciolepis(holm)kuk`
 * `carexcapitatavararctogena(harrysm)hulten`
 * `carexcircinatakurtz`
 * `carexacutinalhbailey`

Using `agrep` (from the [TRE](https://laurikari.net/tre/)
library). The settings used are `agrep -k -5 "querystring"
referencelistfile`. This means a match is returned when the query
string is a substring of the reference string with at most 5 errors
(character mis-matches, character insertions or character deletions).
With an error setting of 5, the query string can be up to 5 characters
_longer_ than the reference string; a setting of more than 5 tends to
return too many false positives and increases the number of
comparisons the operator must examine.  We could use the `-w` option
of `agrep` and not treat the query string as a substring, but this
would mean that we would fail to match a query string lacking authors
against a reference name with the author (if the author string was
more the 5 characters).

The matching name, or names, are then presented to the operator for a
decision on whether to accept or reject the match. Here the operator
must judge the _intention_ or meaning implied by the creator of the
query name. Was there an error (spelling, incomplete author citation,
“incorrect” author abbreviation)? What would have been the full name
if only a partial name was given? Etc... These are our (i.e., Steffi and
Cam) working set of rules:

Accept a match:

 1. Spelling variations in the query name or author string.
 2. If the query name is missing one or more authors seperated by an
 “&” in the reference string.
 3. If the author is missing in the query name, accept the reference
 name if there is only one. (When matching to IPNI or TROPICOS
 only.) The fuzzy match should present all reference names with
 authors when queried for a name without an author, so it is likely
 that every potential name appears in the choice. <!-- could be
 automated -->
 4. If the query and reference name differ in “var.” vs. “subsp.”
 _and_ the author strings are the same.

Reject a match:

 1. When the two author strings are clearly representing
 non-overlapping (abbreviated) lists of authors.
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


IPNI > FNA > TROP > WCSP


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


** Different ”simple” authors **

    Androsace chamaejasme Host
 != Androsace chamaejasme Wulfen

    Glechoma hederacaea L.
 != Glechoma hederacea Maxim.

    Arabis holboelii var. retrofracta (Graham) Rydb.
 != Arabis holboellii var. retrofracta (Graham) Jeps.

    Packera ogotorukensis (Packer) W.A.Weber & A.Love
 != Packera ogotorukensis (Packer) Á. Löve & D. Löve

    Carex media var. stevenii (Holm) Kalela
 != Carex media var. stevenii (T. Holm) Fernald

    Ranunculus auricomus L.f.
 != Ranunculus auricomus L. & W.Koch

    Parnassia kotzebuei Cham. & Schltdl.
 != Parnassia kotzebuei Cham. ex Spreng.  (but see ‘missing ex author’ below)

** Different basionyms **

    Mertensia paniculata var. eastwoodae (J.F.Macbr.) Hultén
 != Mertensia paniculata var. eastwoodiae (Macbride) Hultén

    Alnaster sinuata (Regel) Czerep.
 != Alnaster sinuatus (Rydb.) Czerep.


** Basionym vs new definition **

    Glyceria pauciflora C.Presl
 != Glyceria pauciflora (ex C.Presl) J.Presl

    Myosotis palustris L.
 != Myosotis palustris (L.) Nath.

    Alnus fruticosa (Rupr.) Ledeb.
 != Alnus fruticosa Rupr.

    Platanthera convallariaefolia (Fisch. ex Lindl.) Lindl.
 != Platanthera convallariifolia Fisch. ex Lindl.

** Overlapping but different authors **

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

** Different ranks **

    Aconitum delphinifolium subsp. delphinifolium
 != Aconitum delphiniifolium var. delphiniifolium

** Missing basionym **

    Fauria crista-gallii (Menzies) Makino
 ~= Fauria crista-galli Makino

    Alnaster sinuata (Regel) Czerep.
 ~= Alnaster sinuatus Czerep.

    Thelypteris phegopteris (L.) Sloss.
 ~= Thelypteris phegopteris Sloss. in Rydb.

** Missing author, same basionym **

    Calypso bulbosa (L.)
 ~= Calypso bulbosa (L.) Oakes

    Matteuccia struthiopteris var. pensylvanica (Willd.)
 ~= Matteuccia struthiopteris var. pensylvanica (Willd.) C.V. Morton

    Cirsium edule var. macounii (Greene)
 ~= Cirsium edule var. macounii (Greene) D.J. Keil



** Same author as ‘ex author’ **

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

** Missing ‘ex author’ **

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

** Incomplete author **

    Symphyotrichum pygmaeum (Lindl.) & Selliah
 ~= Symphyotrichum pygmaeum (Lindl.) Brouillet & Selliah


** Fuzzy author **

    Osmorhiza depauperata L.Ll.Phillips
 ~= Osmorhiza depauperata Phil.

    Carex halleri W.W.H.Gunn
 ~= Carex halleri Gunnerus

    Papaver radicatum subsp. porsildii (Knaben) D.Love
 ~= Papaver radicatum subsp. porsildii (Knaben) Á.Löve

** Only one **

    Juniperus communis subsp. nana (Willd.) Syme
 ~= Juniperus communis subsp. nana


