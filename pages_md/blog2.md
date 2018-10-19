% Names, names, names!

# Names, names, names!

## About names

Taxonomic names are, among other things, the identifier strings that
traditionally link together data in different resources. From, e.g,
the publication that contains the original description of a species,
to, e.g., an ecological record of the species that occur at a
site. Names have been called
“[key to the big new biology](https://doi.org/10.1016/j.tree.2010.09.004)”
and a wide array of online resources offer information on taxonomic
names, both as primary representations of taxonomic research and
literature, and as aggregators and integrators of others’ lists. For
example, using the
[Global Names Resolver](http://resolver.globalnames.org/) on
“_Antennaria alpina_ var. _media_ (Greene) Jeps.”, 17 matching
resources are found including GBIF Backbone taxonomy, VASCAN, IPNI,
uBio name bank, Catalog of Life, ITIS, EOL and Tropicos.

The eventual usefulness of our flora project will partially depend on
how well we link to and integrate the data already in these taxonomic
resources. As we set out, it is thus important to step back and ask
how can we best use these resources?  Which should we focus on
(there are too many to attempt to integrate every one)? And how should
we link to them?  

## What name resources are out there?

To answer the above questions requires some research as to what is
actually available. These seem to be the major resources for plant
names, and relevant to our project:

 * **Biota of North America Program’s Taxonomic Data Center** (BONAP’s TDC) The work of John T. Kartesz and assistants [→](http://www.bonap.org/) 
 * **Catalog of Life** (CoL) A product of ITIS and the
   [Species 2000](http://www.sp2000.org/) federation
   [→](http://www.catalogueoflife.org/col/)
 * **GBIF Backbone Taxonomy** (AKA(?): GBIF’s Electronic Catalogue of
   Names of Known Organisms, ECAT)
   [→](https://www.gbif.org/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c)
   and [→](https://github.com/gbif/checklistbank)
 * **GRIN-Global Taxonomy** From the U.S. National Plant Germplasm
     System [→](https://npgsweb.ars-grin.gov/gringlobal/search.aspx)
 * **International Plant Names Index** (IPNI) Derived from the _Index
     Kewensis_ project, the oldest name indexing project
     [→](http://www.ipni.org/)
 * **Integrated Taxonomic Information System** (ITIS) [→](https://www.itis.gov/)
 * **NCBI Taxonomy** [→](https://www.ncbi.nlm.nih.gov/taxonomy)
 * **Pan Arctic Flora** (PAF)
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
     coming online right now (Oct 2018)
     
## What’s in a “names resource”?

Before I compare the above resources, I’ll step back a bit and
consider what a comprehensive, generic names resource would consist
of. A minimal list would be something like:

 * Canonical spelling of name and author string
 * Citation for the original use of a name
 * GUIDs for names
 * Statements about accepted names and synonymy, with
   references to the underlying opinions

A graphical template for how these elements
fit together might then look like this:

<img src="../img/nameparts.png" alt="Elements of names databases" style="width:80%;margin-left: auto; margin-right: auto; display:block;"/>

I’ve also added basic distribution data to the above graph. Our
project is not yet attempting to integrating occurences, but since we
are working on a regional flora, we need to restrict the list of taxa
to just those occuring in Alaska, and a number of online name
resources also offer presence or absence by greographical region (BONAP,
USDA-PLANTS).

## How do the names resources compare?

Here’s a breakdown of different online names resources relevant to our
Alaska flora project. I’ve divided them into two classes: 1) those
primarily containing _original_ online representations of names
databases and/or primary taxonomic literature, and 2) aggregators that
primarily integrate and _re-serve_ data from the first class. This
classification is imperfect, since many resources in class (2) also
incorporate primary data (e.g., The Plant List, the Catalog of Life,
uBIO, ?WFO), as well as involve manual checking of names, which is a form of
primary data generation. This classification is only with reference to
serving taxonomic names; “aggregators” for names may be primary
sources for other data (e.g., distribution data in USDA PLANTS).

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

  <!-- IPNI -->
  <tr>
    <td><b>IPNI</b></td>
    <td>Y</td>
    <td>Y</td>
    <td>n</td>
    <td>n</td>
    <td>n / n</td>
    <td>Y</td>
    <td><a href="http://www.ipni.org/understand_the_data.html">Y</a></td>
  </tr>

  <!-- TROPICOS -->
  <tr>
    <td><b>Tropicos</b></td>
    <td>Y</td>
    <td>Y</td>
    <td>Y</td>
    <td>Y</td>
    <td>Y / Y</td>
    <td>Y</td>
    <td>n [6]</td>
  </tr>


  <!-- GRIN -->
  <tr>
    <td><b>GRIN</b></td>
    <td>Y</td>
    <td>~ [1]</td>
    <td>Y</td>
    <td>~ [1]</td>
    <td>Y / ~ [1]</td>
    <td>N</td>
    <td><a href="https://npgsweb.ars-grin.gov/gringlobal/taxon/abouttaxonomy.aspx">Y</a></td>
  </tr>

  <!-- BONAP -->
  <tr>
    <td><b>BONAP</b></td>
    <td>N</td>
    <td>[1]</td>
    <td>[3]</td>
    <td>[1]</td>
    <td>Y / [1]</td>
    <td>[3]</td>
    <td><a href="http://www.bonap.org/Documentation.html">Y</a></td>
  </tr>

  <!-- VASCAN -->
  <tr>
    <td><b>VASCAN</b></td>
    <td>~ [2]</td>
    <td>n</td>
    <td>Y</td>
    <td>Y</td>
    <td>Y / n</td>
    <td>n</td>
    <td><a href="http://data.canadensys.net/vascan/about">Y</a></td>
  </tr>

  <!-- PAF -->
  <tr>
    <td><b>PAF</b> [5] </td>
    <td>~ [2]</td>
    <td>Y</td>
    <td>Y</td>
    <td>~</td>
    <td>Y / ~</td>
    <td>n</td>
    <td><a href="http://nhm2.uio.no/paf/introduction#section-1.2">Y</a></td>
  </tr>

  <!-- Class 2 --> 
  <tr>
    <td colspan="8"><i>2. Aggregators</i></td>
  </tr>
  <!-- COL -->
  <tr>
    <td><b>COL</b></td>
    <td>?</td>
    <td>?</td>
    <td>?</td>
    <td>?</td>
    <td>? / ?</td>
    <td>?</td>
    <td>?</td>
  </tr>
  <!-- PLANTS -->
  <tr>
    <td><b>PLANTS</b></td>
    <td>Y</td>
    <td>[1]</td>
    <td>Y</td>
    <td>[1]</td>
    <td>Y / [1]</td>
    <td>Y</td>
    <td>N</td>
  </tr>
  <!-- uBio -->
  <tr>
    <td><b>uBio</b></td>
    <td>Y</td>
    <td>n</td>
    <td>Y</td>
    <td>n</td>
    <td>n / n</td>
    <td>Y</td>
    <td><a href="http://ubio.org/index.php?pagename=name_sources">Y</a></td>
  </tr>
  <!-- The Plant List -->
  <tr>
    <td><b>The Plant List</b></td>
    <td>Y</td>
    <td>Y</td>
    <td>Y</td>
    <td>n</td>
    <td>n / n</td>
    <td>Y</td>
    <td><a href="http://www.theplantlist.org/1.1/about/">Y</a></td>
  </tr>
  <tr>
    <td><b>ITIS</b></td>
    <td>Y</td>
    <td>n</td>
    <td>Y</td>
    <td>n</td>
    <td>n / n</td>
    <td>Y</td>
    <td><a href="https://www.itis.gov/itis_primer.html">Y</a></td>
  </tr>
  <tr>
    <td><b>GBIF</b></td>
    <td>Y</td>
    <td>[4]</td>
    <td>[4]</td>
    <td>[4]</td>
    <td>Y / Y</td>
    <td>Y</td>
    <td>Y: <a href="https://github.com/gbif/checklistbank/blob/master/checklistbank-nub/nub-sources.tsv">1</a><a href="https://www.gbif.org/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c">2</a></td>
  </tr>
  <tr>
    <td><b>NCBI</b></td>
    <td>Y</td>
    <td>n</td>
    <td>n</td>
    <td>n</td>
    <td>n / n</td>
    <td>Y</td>
    <td><a href="https://www.ncbi.nlm.nih.gov/books/NBK21100/">Y</a></td>
  </tr>

  <!-- WFO -->
  <tr>
    <td><b>WFO</b></td>
    <td>?</td>
    <td>?</td>
    <td>?</td>
    <td>?</td>
    <td>? / ?</td>
    <td>?</td>
    <td><a href="https://www.ncbi.nlm.nih.gov/books/NBK21100/">?</a></td>
  </tr>
  

</table>

<i>Notes on this table</i>: 

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
       accessed using (e.g.) `curl -d searchText=Castilleja "http://bonap.net/TDC/Nomenclator/NomenclatorLists`
    4. Via Catalogue of Life.
    5. Because Dave Murray contributed to both the ALA checklist and
       PAF, PAF is less a general name resource than a local list to
       be integrated (see below). However it is useful to list it here
       for comparison.
    6. But see: “The History of Tropicos”, by Rebecca Rea
       (unpub. report), and “Tropicos: the Missouri Botanical Garden
       Plant Database” by Marshall Crosby and George Van Brunt in
       _Nature Notes_, 2011, 83(6): 11-13
       ([file](http://www.wgnss.org/uploads/2/5/0/0/25004974/2012_06_naturenotes.pdf)). Thanks to Heather Stimmel @ MOBOT for sharing these. 

## Data flow
    
In deciding which data to incorporate and how to use available GUIDs,
it’s necessary to understand the flow of primary data through the
aggregators. Here’s a sketch of my understanding of how these data
flow. As with the rest of this blog post, I may have missed resources
or misinterpreted what I read on the websites, and I invite you to
correct me with a comment below.

<img src="../img/namesflow.png" alt="Flow of data through aggregators" style="width:80%;margin-left: auto; margin-right: auto; display:block;"/>


## Using these data <a href="#data">*</a>



Our need to is reconcile the names we already have (in ALA, ACCS lsit, and PAF) to existing resources. 

The first step of our data integration project is reconcile existing
data sets about the taxonomy of Alaska plants with external names
resources that will permit linkage to the larger world of plant
information. In the “local” class, I include:

 * The existing [ALA Alaskan Plant Checklist](ALA_checklist.html)
   (~4,000 names), developed by Dave Murray and colleagues at ALA over
   the past ~30 years
 * The [checklist](https://floraofalaska.org/comprehensive-checklist/)
   developed by botanists at the
   [Alsakan Alaska Center for Conservation Science](http://accs.uaa.alaska.edu/), managed by [Timm Nawrocki](http://accs.uaa.alaska.edu/staff/timm-nawrocki/)
   (~11,700 names, combining the ALA checklist with other data)
  * The [Pan-arctic flora](http://nhm2.uio.no/paf/), which will be a
    core resource for the new Alaska flora and was also edited by Dave
    Murray, and,
  * The scanned, OCR version of Hultén’s flora

Each of these may have binomial and author spelling variations that
have not been fuzzy matched and “pinned” to a canonical string in a
shared, online resource (such as the International Plant Names Index).

Prior to the Name Resolver to the Global Names Architecture, the name
reconciliation strategy might have been:

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
API, and recive back matches for online names servers and their GUIDs
for our names. We can store local i) our local name, ii) the canonical
name for each match and its GUID according to each online resource,
iii) metadata about the match (e.g., “according to GNR on
<date>”). Taxa that don’t match, or match with low values, will need
to be examined by hand, and if found to be valid (in a variety of
senses), accepted to the local canonical list.

A huge amount of thought and effort has gone into creating online
names resources, but no single online list exists to which we can
reconcile our names, and from there link out to all other online plant
data (taxonomic, occurence, etc). 

!!! No! GNA _will_ give guids for all units!



This blog post (probably the first of several on names) is about our
strategy for assembling this ‘canonical’ list of external names, sources
and GUIDs.

----



  






Criteria:

Original source vs. aggregator
Easy of data access (dump/API)

Rank:
IPNI, PAF, PL, USDA PLANTS




 But these
character strings (e.g., _Antennaria alpina_ var. _media_ (Greene)
Jeps.) have a number of problems when used as identifiers for linking
information about biological organisms. They can refer to different
concepts of a taxon by different taxonomists - more on this
later. They are also highly prone to copying errors: misspellings of
the Latin binomial, and variation in abbreviating the author string.
This was less of a problem when all data processing was mediated by a
human researcher, but a large problem for computers.  Hence the value
of using an external GUID (Globally Unique Identifier) to stand in for
the name, when linking data.  The big question for us as we start this
project is which system of GUIDs will be most effective. There are now
many 




Make a graph: 

 Base taxonomic research on L (IPNI, PAF...) - also symbols for API/website
 Aggregators in middle and on right (PL, ...) 

State: we want to use Base Tax resources that have web access as priorities...

Original sources

 * IPNI
 
 * GRIN Taxonomy for Plants
 * INGL Index Nominum Genericorum
 * NCBI

 * Mabberly 
 
 * IRMNG

 * TNRS
 * ALA
 
 * CiteBank
 * BHL
 
 * TAXAMATCH (Tony Rees)

 * Index Fungorum
 * PAF
 * BioCASE
 * EoL
 * FNA/eFloras
 
 * PESI  (
http://www.eu-nomen.eu/
 ) 

 * Catalog of Life yes API
 * Species 2000
 * ITIS  yes API - https://www.itis.gov/ITISWebService/services/ITISService/getFullRecordFromTSN?tsn=527195 (but no original source info)

 * The Plant List
 * USDA PLANTS - cannot access literature data.
 * Topicos

Agregators

 * ION: Index of Organismal Names
 * uBio
 * GNA (GNR, GNUB - not working, BioGUID - not working...)
 * ECAT (from GBIF)
 
 * BONAP
 
 * VASCAN
 
Synonymic Checklists of the Vascular Plants of the World
Short name: 	World Plants
Version: 	Apr 2018
Release date: 	2018-04-13
Authors/editors: 	Hassler M.


Cannot use CoL because the webservice does says Infraspecific but does not give var., f. or ssp.!!!!

----

(<a name="data">*</a>) The word “data” - singular or plural?! This [review in Wikipedia](https://en.wikipedia.org/wiki/Data_(word)) is helpful. I’ll probably mix the singular/plural usage here, inconsistently, as I do in daily speech!

----

Frustrated how hard it is to find how each list was put together!

<!-- literature and plazi.org -->

Consider: 

* https://plants.sc.egov.usda.gov/java/reference?symbol=CACAA
 * https://npgsweb.ars-grin.gov/gringlobal/taxon/abouttaxonomy.aspx?language=en&chapter=hist
 * https://www.gbif.org/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c
 * http://plazi.org/about/members/
 * http://globalnames.org/bibliography/

