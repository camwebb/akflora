% Names, names, names!

Taxonomic names are, among other things, the identifiers, or labels,
that traditionally link together data in different information resources; for
example, from the publication that contains the original description
of a species... to an ecological record of the species that occur at a
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
Which should we focus on (there are too many to attempt to integrate
every one)? And how should we link to them?
This blog post outlines the issues and how we intend to move forward
with names.

## Online resources for taxonomic names

I’ll start with online taxonomic name resources (including sites that
are primarily checklists), before moving on to more general biological
resources (which will also be integrated via names).

### What name resources are out there?

These seem to be the major resources for plant names themselves, and
relevant to our project (e.g., leaving out the super
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

I’ve also added basic distribution data to the above graph. Our
project is not yet attempting to integrating occurrences, but since we
are working on a regional flora, it will be convenient to restrict the
list of taxa to just those occurring in Alaska and nearby lands, and a
number of online name resources also offer presence or absence by
geographical region (BONAP, USDA-PLANTS).

### How do these various name resources compare?

I’ve divided the above name resources into two classes: 1) those
primarily containing _original_ online representations of names
databases and/or primary taxonomic literature, and 2) aggregators that
primarily integrate and _re-serve_ data from the first class. This
classification is imperfect, since many resources in class (2) also
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

<div style="text-align: right;"><button onclick="showhide()">Show notes for this table</button></div>

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
   database: conatinaing metadata for all the ALA herbarium sheets.
 * [iNaturalist](https://www.inaturalist.org/home), an outstanding
   repository of biological observations backed by images.

## Orthography and fuzzy matching



But these character strings (e.g., _Antennaria alpina_
var. _media_ (Greene) Jeps.) have a number of problems when used for
linking information. They can refer to different mental concepts of a
taxon used by different taxonomists - much more on this “taxon
concept” problem later. But they are also troublesome in a simple
informatics context: they are highly prone to copying errors and other
orthographic variation, e.g., misspellings of the Latin binomial, and
variation in abbreviating the author string.  This was a small problem
when all data processing was mediated by the intelligence of a human
researcher, but is a much larger problem for a computer looking for an
exact string to match to.

The problem becomes 

One solution to this issue is to use an independent identifier, like a
serial number, in place (or alongside) the name. If two users refer to
the same identifier then they can be sure they are communicating about
the same shared taxonomic name, even if locally they may spell the
name differently (intentionally or not). 

We will have such an
identifier in our local taxonomic database. If 


  Hence the value of using an external GUID
(Globally Unique Identifier) to stand in for the name, when linking
data.  The big question for us as we start this project is which
system of GUIDs will be most effective. There are now many

 * Agrep
 * TNRS
 * GNR

## Work plan for using these data

The first step of our data integration project is reconcile existing
“local” data sets about the taxonomy of Alaska plants with external
name resources that will permit linkage to the larger world of plant
information. In the “local” class, I include:

 * The existing [ALA Alaskan Plant Checklist](ALA_checklist.html)
   (~4,000 names), developed by Dave Murray and colleagues at ALA over
   the past ~30 years
 * The [checklist](https://floraofalaska.org/comprehensive-checklist/)
   developed by botanists at the
   [Alaska Center for Conservation Science](http://accs.uaa.alaska.edu/), managed by
   [Timm Nawrocki](http://accs.uaa.alaska.edu/staff/timm-nawrocki/)
   (~11,700 names, combining the ALA checklist with other data)
  * The [Pan-arctic flora](http://panarcticflora.org), which will be a
    core resource for the new Alaska flora and was also edited by Dave
    Murray, and,
  * The scanned, OCR version of Hultén’s Flora of Alaska.

Each of these may have binomial and author spelling variations that
must be fuzzy matched and “pinned” to a canonical (local) string.
Prior to the Name Resolver to the Global Names Architecture (GNR), the
name reconciliation strategy might have been:

 1. To assemble a local ‘canonical’ list of external names, sources
    and GUIDs to which we could reconcile our local lists. We could try
    to reconcile every relevant online list with every other online
    list, but this `(n*n-1)/2` comparison would be hugely
    time-consuming, and, given also that different online lists vary
    in their “value” (see below), our strategy would instead be to grow
    a single list of external names by ranking potential resources
    (e.g., `IPNI > The Plant List > ...`) and reconciling subsequent
    additions to that growing list. E.g. `A; A compare B gives Ab; C
    compare Ab gives Abc; D...`).
  2. Reconcile our local list of Alaska names to the canonical list.

Now, with the existence of GNR, we can send each local name to the GNR
API, and receive back matches for online names servers and their GUIDs
for our names. We can store local i) our local name, ii) the canonical
name for each match and its GUID according to each online resource,
iii) metadata about the match (e.g., “according to GNR on
<date>”). Taxa that don’t match, or match with low values, will need
to be examined by hand, and if found to be valid (in a variety of
senses), accepted to the local canonical list.

A huge amount of thought and effort has gone into creating online
name resources, but no single online list exists to which we can
reconcile our names, and from there link out to all other online plant
data (taxonomic, occurrence, etc). 

Similar service by TNRS





<!-- 
Notes:

  * Cannot use CoL because the webservice does says Infraspecific but does not give var., f. or ssp.
  * Frustrated how hard it is to find how each list was put together!
  * Not concerned with classification ... (above sp?)
  * Other resources not discussed: INGL Index Nominum Genericorum, Mabberly 
    IRMNG, ARCTOS, CiteBank, BHL, Index Fungorum, FNA/eFloras, PESI 
    (http://www.eu-nomen.eu/)
-->

Using the
[Global Names Resolver](http://resolver.globalnames.org/) on
“_Antennaria alpina_ var. _media_ (Greene) Jeps.”, 17 matching
resources are found including GBIF Backbone taxonomy, VASCAN, IPNI,
uBio name bank, Catalog of Life, ITIS, EOL and Tropicos.
