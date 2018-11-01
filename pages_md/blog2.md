% Names, names, names!

# Names, names, names!

_Posted by [Cam](people.html#cam) on 2018-10-31_

_(In which I discuss issues with matching taxonomic names in different databases
, and compare the universe of online name resources.)_

Taxonomic names are, among other things, the identifiers, or labels,
that traditionally link together data in different information resources; for
example, from the publication that contains the original description
of a species... to an ecological record of that species occurring at a
site. Being vital informatics links, names have been called
“[key to the big new biology](https://doi.org/10.1016/j.tree.2010.09.004)”
and a wide array of online resources offer information structured
around biological names (e.g., the
[Encyclopedia of Life](https://www.eol.org/) and
[Wikispecies](https://species.wikimedia.org/wiki/Main_Page)). Many
sites also offer information about the names themselves, both as
primary representations of taxonomic research and literature, and as
aggregators and integrators of others’ lists (e.g.,
[IPNI](http://www.ipni.org/) and
[The Plant List](http://www.theplantlist.org/)).

The eventual usefulness of our flora project will partially depend on
how well we link to and integrate the data already in these online
resources, especially the taxonomic ones. As we set out, it is thus
important to step back and ask how we can best use these resources.
Which should we focus on? (There are too many to attempt to integrate
every one.) And how should we link to them?
This blog post outlines the issues and how we intend to move forward
with names.

## Online resources for taxonomic names

I’ll start with online taxonomic name resources (including sites that
are primarily checklists), before moving on to more general biological
resources (which will also be integrated via names).

### What name resources are out there?

These seem to be the major resources for plant names themselves, and
relevant to our project (i.e., leaving out
[APNI](https://www.anbg.gov.au/apni/)):

 * **Biota of North America Program’s Taxonomic Data Center** (BONAP’s TDC) The work of John T. Kartesz and assistants [→](http://www.bonap.org/) 
 * **Catalog of Life** (CoL) A product of ITIS and the
   [Species 2000](http://www.sp2000.org/) federation
   [→](http://www.catalogueoflife.org/col/)
 * **GBIF Backbone Taxonomy** (_aka(?)_: GBIF’s Electronic Catalogue of
   Names of Known Organisms, ECAT)
   [→](https://www.gbif.org/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c)
   and [→](https://github.com/gbif/checklistbank)
 * **Global Names Architecture** (GNA) A major “meta-project” to link
     names in these other resources [→](http://globalnames.org/)
 * **GRIN-Global Taxonomy** From the U.S. National Plant Germplasm
     System [→](https://npgsweb.ars-grin.gov/gringlobal/search.aspx)
 * **International Plant Names Index** (IPNI) Derived from the _Index
     Kewensis_ project, the oldest name indexing project
     [→](http://www.ipni.org/)
 * **Integrated Taxonomic Information System** (ITIS) US Government shared names system [→](https://www.itis.gov/)
 * **NCBI Taxonomy** Collating and organizing names submitted to GENBANK [→](https://www.ncbi.nlm.nih.gov/taxonomy)
 * **Pan Arctic Flora** (PAF) Important source of names for the Alaska Flora [→](http://panarcticflora.org)
 * **The Plant List** Major attempt to gather all plant names, out of
     Kew [→](http://www.theplantlist.org/).
 * **PLANTS** database, out of USDA
     [→](https://plants.sc.egov.usda.gov/java/)
 * **Tropicos** from the Missouri Botanical Garden
     [→](http://www.tropicos.org/)
 * **Universal Biological Indexer and Organizer** (uBio) Aggregating
     names since 2002, from [MBL](http://www.mbl.edu/). Not sure if it
     is currently maintained; GNA seems to be its successor. There was
     also an associated resource from MBL called CU*STAR
     [→](http://ubio.org)
 * **Database of Vascular Plants of Canada** (VASCAN) Comprehensive
     list of all vascular plants reported in Canada & Greenland. 
     [→](http://data.canadensys.net/vascan/search)
 * **World Flora Online** (WFO) The successor to The Plant List. Data just
     coming online right now (Oct 2018) [→](http://worldfloraonline.org/)
     
### What’s in a “name resource”?

Before I compare the above resources, I’ll step back a bit and
consider what a comprehensive, generic taxonomic name resource would
consist of. A minimal list would be something like:

 * Canonical spelling of name and author string.
 * Citation for the original use of a name.
 * Globally unique identifiers (GUIDs) for names. Because of problems
   with variations in spelling (see below), having a permanent,
   web-accessible identifier enables end-users to be sure they are
   talking about the same _name entity_ and worry less about local variation
   in spelling. See this [TDWG GUID](https://github.com/tdwg/guid-as)
   statement.
 * Statements about which names are currently _accepted_ by
   taxonomists as the canonical label, and about synonymy, with
   references to the underlying opinions.

A graphical template for how these elements
fit together might then look like this:

<img src="../img/nameparts.png" alt="Elements of names databases" style="width:80%;margin-left: auto; margin-right: auto; display:block;"/>

I’ve also added basic distribution data to the above graph (D1, D2). In this first phase our
project is not yet integrating occurrences, but since we
are working on a regional flora it will be convenient to restrict the
list of taxa to just those occurring in Alaska and nearby lands. A
number of online name resources offer presence or absence by
geographical region (BONAP, USDA-PLANTS).

### How do these various name resources compare?

I’ve divided the above name resources into two classes: 1) those
primarily containing _original_ online representations of names
databases and/or primary taxonomic literature, and 2) aggregators that
primarily integrate and _re-serve_ data from the first class. This
classification is imperfect, since many resources in class 2 also
incorporate primary data (e.g., The Plant List, the Catalog of Life,
uBIO, ?WFO), as well as involve manual checking of names, which is a
form of primary data generation. This classification is only with
reference to serving taxonomic names; “aggregators” for names may be
primary sources for other data (e.g., distribution data in USDA
PLANTS).

<table>
  <tr>
    <th>Resource</th>
    <th>GUIDs (A2, C4)</th>
    <th>Orig. publ. (A3)</th>
    <th>Status (B1, C1, C3)</th>
    <th>Status ref. (B2, C2)</th>
    <th>Distrib.(D1)/(D2)</th>
    <th>API</th>
    <th>Source desc.</th>
  </tr>
  
  <tr>
    <td colspan="8"><i>1. Primary data sources</i></td>
  </tr>

  <!-- BONAP -->
  <tr>
    <td><b>BONAP</b><a href="http://www.bonap.org/">→</a></td>
    <td>n</td>
    <td>[1]</td>
    <td>[3]</td>
    <td>[1]</td>
    <td>Y / [1]</td>
    <td>[3]</td>
    <td><a href="http://www.bonap.org/Documentation.html">Y</a></td>
  </tr>

  <!-- GRIN -->
  <tr>
    <td><b>GRIN</b><a href="https://npgsweb.ars-grin.gov/gringlobal/search.aspx">→</a></td>
    <td>Y</td>
    <td>Y</td>
    <td>Y</td>
    <td>[1]</td>
    <td>Y / [1]</td>
    <td>n</td>
    <td><a href="https://npgsweb.ars-grin.gov/gringlobal/taxon/abouttaxonomy.aspx">Y</a></td>
  </tr>

  <!-- IPNI -->
  <tr>
    <td><b>IPNI</b><a href="http://www.ipni.org/">→</a></td>
    <td>Y</td>
    <td>Y</td>
    <td>n</td>
    <td>n</td>
    <td>n / n</td>
    <td>Y</td>
    <td><a href="http://www.ipni.org/understand_the_data.html">Y</a></td>
  </tr>

  <!-- PAF -->
  <tr>
    <td><b>PAF</b><a href="http://panarcticflora.org/">→</a> [5] </td>
    <td>[2]</td>
    <td>Y</td>
    <td>Y</td>
    <td>~</td>
    <td>Y / ~</td>
    <td>n</td>
    <td><a href="http://panarcticflora.org/introduction#section-1.2">Y</a></td>
  </tr>

  <!-- PLANTS -->
  <tr>
    <td><b>PLANTS</b><a href="https://plants.sc.egov.usda.gov/java/">→</a></td>
    <td>Y</td>
    <td>[1]</td>
    <td>Y</td>
    <td>[1]</td>
    <td>Y / [1]</td>
    <td>[7]</td>
    <td>n</td>
  </tr>

  <!-- TROPICOS -->
  <tr>
    <td><b>Tropicos</b><a href="http://www.tropicos.org/">→</a></td>
    <td>Y</td>
    <td>Y</td>
    <td>Y</td>
    <td>Y</td>
    <td>Y / Y</td>
    <td>Y</td>
    <td>n [6]</td>
  </tr>
  <tr/>

  <!-- VASCAN -->
  <tr>
    <td><b>VASCAN</b><a href="http://data.canadensys.net/vascan/">→</a></td>
    <td>[2]</td>
    <td>n</td>
    <td>Y</td>
    <td>Y</td>
    <td>Y / n</td>
    <td>Y</td>
    <td><a href="http://data.canadensys.net/vascan/about">Y</a></td>
  </tr>

  <!-- Class 2 --> 
  <tr>
    <td colspan="8"><i>2. Aggregators</i></td>
  </tr>
  <!-- COL -->
  <tr>
    <td><b>COL</b><a href="http://www.catalogueoflife.org/col/">→</a></td>
    <td>Y</td>
    <td>Y</td>
    <td>Y</td>
    <td>n</td>
    <td>n / n</td>
    <td>n</td>
    <td><a href="http://www.catalogueoflife.org/col/info/about">Y</a></td>
  </tr>
  <!-- GBIF -->
  <tr>
    <td><b>GBIF</b><a href="http://gbif.org/">→</a></td>
    <td>Y</td>
    <td>[4]</td>
    <td>[4]</td>
    <td>[4]</td>
    <td>Y / Y</td>
    <td>Y</td>
    <td>Y: <a href="https://github.com/gbif/checklistbank/blob/master/checklistbank-nub/nub-sources.tsv">1</a> <a href="https://www.gbif.org/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c">2</a></td>
  </tr>
  <!-- GNA -->
  <tr>
    <td><b>GNA</b><a href="http://globalnames.org/">→</a></td>
    <td>Y</td>
    <td>n</td>
    <td>n</td>
    <td>n</td>
    <td>n / n</td>
    <td>Y</td>
    <td><a href="http://resolver.globalnames.org/about">~</a></td>
  </tr>
  <!-- ITIS -->
  <tr>
    <td><b>ITIS</b><a href="https://www.itis.gov/">→</a></td>
    <td>Y</td>
    <td>n</td>
    <td>Y</td>
    <td>Y</td>
    <td>n / n</td>
    <td>Y</td>
    <td><a href="https://www.itis.gov/itis_primer.html">Y</a></td>
  </tr>
  <!-- NCBI -->
  <tr>
    <td><b>NCBI</b><a href="https://www.ncbi.nlm.nih.gov/taxonomy">→</a></td>
    <td>Y</td>
    <td>n</td>
    <td>n</td>
    <td>n</td>
    <td>n / n</td>
    <td>Y</td>
    <td><a href="https://www.ncbi.nlm.nih.gov/books/NBK21100/">Y</a></td>
  </tr>
  <!-- The Plant List -->
  <tr>
    <td><b>The Plant List</b><a href="http://www.theplantlist.org/">→</a></td>
    <td>Y</td>
    <td>Y</td>
    <td>Y</td>
    <td>n</td>
    <td>n / n</td>
    <td>[7]</td>
    <td><a href="http://www.theplantlist.org/1.1/about/">Y</a></td>
  </tr>
  <!-- uBio -->
  <tr>
    <td><b>uBio</b><a href="http://ubio.org/">→</a></td>
    <td>Y</td>
    <td>n</td>
    <td>Y</td>
    <td>n</td>
    <td>n / n</td>
    <td>Y</td>
    <td><a href="http://ubio.org/index.php?pagename=name_sources">Y</a></td>
  </tr>
  <!-- WFO -->
  <tr>
    <td><b>WFO</b><a href="http://worldfloraonline.org/">→</a></td>
    <td>Y</td>
    <td>Y</td>
    <td>Y</td>
    <td>n</td>
    <td>n / n</td>
    <td>n</td>
    <td>n</td>
  </tr>
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

 * Columns:
    * Codes in the header (e.g., “C1”) refer to graph above
    * ‘API’ - the existence of an API or structured data dump
    * ‘Source desc.’ - how clearly (and/or easily) it is to find out exactly 
       how the data were compiled. 
 * Cell values: ‘Y’- yes, ‘n’ - no; ‘~’ - partial. 
 * Footnotes:
    1. General lists of documentation provided without indication of what
       the publications are evidence for
    2. Internal accession numbers evident, but probably not intended as 
       permanent GUIDs
    3. Synonymy lists on this [page](http://bonap.net/TDC/Nomenclator) can be 
       accessed using (e.g.) `curl -d searchText=Castilleja "http://bonap.net/TDC/Nomenclator/NomenclatorLists"`
    4. Via the “Reference Taxon” source (e.g., Catalogue of Life, or VASCAN)
    5. Because Dave Murray contributed to both the ALA checklist and
       PAF, PAF is less a general name resource than a local list to
       be integrated (see below). However it is useful to list it here
       for comparison.
    6. But see: “The History of Tropicos”, by Rebecca Rea
       (unpub. report), and “Tropicos: the Missouri Botanical Garden
       Plant Database” by Marshall Crosby and George Van Brunt in
       _Nature Notes_, 2011, 83(6): 11-13
       ([file](http://www.wgnss.org/uploads/2/5/0/0/25004974/2012_06_naturenotes.pdf)). Thanks to Heather Stimmel @ MOBOT for sharing these. 
    7. Via data download.

</div>

### Data flow
    
In deciding which taxonomic data to incorporate and how to use
available GUIDs, it’s necessary to understand the flow of primary taxonomic data
through the aggregators. Here’s a sketch of my current understanding
of how these data flow, developed via reading i) the “How we made
this” pages for each resource, and ii) the reference section for names
in that resource. As with the rest of this blog post, I may have
missed resources or misinterpreted what I read on the websites, and I
invite you to please correct me with a comment below!

<img src="../img/namesflow.png" alt="Flow of data through aggregators" style="width:80%;margin-left: auto; margin-right: auto; display:block;"/>

## Other resources linked by taxonomic names

Besides online resources primarily focused on taxonomic names and
their synonyms, there are of course many biological
databases that might be integrated via taxonomic names. The
resources we are already committed to drawing upon are:

 * The
   [Flora of North America](http://www.efloras.org/flora_page.aspx?flora_id=1)
   project (FNA): an almost complete revision of all plant taxa in the USA (more info [here](http://floranorthamerica.org/)).
 * The [ARCTOS](https://arctos.database.museum/) museum management
   database: containing metadata for all the ALA herbarium sheets.
 * [iNaturalist](https://www.inaturalist.org/home), an outstanding
   repository of biological observations backed by images.

## Orthography and fuzzy matching

Linking among databases would not be a difficult problem if the
characters of a name (e.g., `Antennaria alpina var. media (Greene)
Jeps.`) never varied. But these strings are prone to copying (typing)
errors and other orthographic variation, e.g., in abbreviating and
punctuating the author string. An author like “Jo Bloggs”, might
appear as `Bloggs`, `Blog.`, `J. Bloggs` or `J.Bloggs`, despite
[official recommendations](https://en.wikipedia.org/wiki/Author_citation_(botany)#Abbreviation). I
just learned that IPNI has a policy of removing spaces after periods,
which differs from policies elsewhere, and from the natural inclination of
many people. (FYI:
[this](https://en.wikipedia.org/wiki/Author_citation_(botany))
Wikipedia article on author citations in botanical names is super, and
one I frequently revisit.)

Short of comparing every pair of names by hand, some sort of
computational tool is needed to determine if a name in database A is the
same as in database B.  Much thought has gone into this problem (e.g.,
[Boyle et al. 2013](http://dx.doi.org/10.1186/1471-2105-14-16), [Rees 2014](https://dx.doi.org/10.1371%2Fjournal.pone.0107510),
[Horn 2016](https://dx.doi.org/10.3897%2FBDJ.4.e7971),
[Patterson et al. 2016](https://dx.doi.org/10.3897%2FBDJ.4.e8080)). Solutions
can involve both ‘fuzzy matching’ (finding a match when not all
characters of a string are identical, similar to
[BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi)ing nucleotides), and
the applications of rules (such as checking against a list of author abbreviations).

For locally matching a name to a list I’ve been using a home-cooked
approach (I’ll post the code in in a subsequent blog):

 1. Check first for an exact match,
 2. Check for a punctuation mismatch, by matching a simplified version
   of each name, made by:
    * converting ` and ` to `&`
    * deleting spaces
    * deleting periods
    * collapsing non-ASCII characters to the corresponding ASCII
      character (e.g., `Å` to `A`)
    * converting to lowercase,
 3. Checking for missing/different characters in string 2 using
    `agrep` (approximate `grep`) from the
    [TRE](https://laurikari.net/tre/) library.
 4. Manual selection/checking of poor matches and non-matches.
    
However, for matching to existing external lists (i.e., online databases)
more capable solutions exist:

 * The Taxonomic Name Resolution Service
   ([TNRS](http://tnrs.iplantcollaborative.org/index.html)), which
   matches a given name to Tropicos, PLANTS, NCBI and the Plantlist.
 * The Global Names Resolver
   ([GNR](http://resolver.globalnames.org/)), which (as of 2018-10-31)
   matches to
   [182 sources](http://resolver.globalnames.org/data_sources),
   including all in the table above (except the Plantlist, and FNA),
   plus iNaturalist. The [API](http://resolver.globalnames.org/api)
   returns the original GUID in each source dataset, with information
   about the nature of the match (exact, fuzzy, fuzzy on species part,
   etc.). As its creators intended, GNR is an invaluable resource for
   knitting together datasets by taxonomic name, and we will use it
   extensively! Prior to a centralized service like GNR, to get the
   same comprehensiveness one would have needed to do a `(n*n-1)/2`
   local comparison of every downloaded name list with every other
   one.

## Work plan for using these data

Now to work! As I see it now, there are three intertwined elements of
our reconciliation process:

 1. Assembling a rough list from our various “local” sources. This
 combined list will be that from which accepted names will eventually
 be chosen by the Flora of Alaska taxonomists. I’ll use use the
 “home-cooked” method above to reconcile these lists against each
 other. The local sources are:
    * The existing [ALA Alaskan Plant Checklist](ALA_checklist.html)
      (~4,000 names), developed by Dave Murray and colleagues at ALA over
      the past ~30 years,
    * The
      [checklist](https://floraofalaska.org/comprehensive-checklist/)
      developed by botanists at the
      [Alaska Center for Conservation Science](http://accs.uaa.alaska.edu/),
      managed by
      [Timm Nawrocki](http://accs.uaa.alaska.edu/staff/timm-nawrocki/)
      (~11,700 names, combining the ALA checklist with other data),
    * The scanned, OCR version of Hultén’s Flora of Alaska.
 2. Fixing “bad” names in our local list, by reconciling with a
 limited, “canonical” set of external sources. We could just go with
 IPNI, but unfortunately before 1971 infraspecific names were
 [not included](http://www.ipni.org/about_the_index.html) in _Index
 Kewensis_. So other name resources will be needed. Some ranking of
 external resources is also necessary in order to decide which
 variation in name should be accepted in the case of differing
 opinions. In theory, all primary resources should have gone back to
 the original publication and copied the name string from there, but
 no doubt there will be differences. Our current ranking is: IPNI >
 Tropicos > VASCAN > PLANTS > maybe BONAP (if needed). GNR can be used
 for these reconciliations (except for BONAP).
 3. Linking out to resources from those corrected names (the Plantlist will be important for this).

Clear as mud? Let’s see how it goes...

_(Phew! This blog is definitely TLDR. I’ll try to keep it shorter next time.)_

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

<!-- 
Notes:

  * Cannot use CoL because the webservice does says Infraspecific but does not give var., f. or ssp.
  * Frustrated how hard it is to find how each list was put together!
  * Not concerned with classification ... (above sp?)
  * Other resources not discussed: INGL Index Nominum Genericorum, Mabberly 
    IRMNG, ARCTOS, CiteBank, BHL, Index Fungorum, FNA/eFloras, PESI 
    (http://www.eu-nomen.eu/)
-->

