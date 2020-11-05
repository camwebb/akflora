% Blog 8: A taxon concept mapping tool

# Blog 8: A taxon concept mapping tool

_Posted by [Cam](people.html#cam) on 2020-11-03_

A central goal of this project is to confront the issue of _Taxon
Concepts_, and develop solutions to manage taxon concepts for plants
in the flora of Alaska.  

## Taxon Concepts

It has long been recognized that taxonomic names alone are not
sufficient to communicate specific definitions (circumscriptions) of
taxonomic groups of organisms, because the same name may be used in
different ways by different taxonomists. The name is anchored only to
a single type specimen, and not to an understanding, concept or
definition of the taxon that ‘surrounds’ that single organism. Some
taxonomists may take a broad view of a named taxon and lump together
several pre-existing taxa, while other taxonomists may take a narrow
view.  This ambiguity presents many problems to users of names, for
example making it difficult to combine specimens for ecological
distribution modeling.

The solution is to always specify the particular _usage_ of a name,
with a reference to the publication or person using it.  So,
functionally, a Taxon Concept (TC; also known as a Taxonomic Name
Usage, TNU) is the join between a name and a publication.  It is easy
to model this in a database, but very few biodiversity databases offer
this facility. Our goal for the flora of Alaska is to list not just
names, but also the various taxon concepts applied to each taxon, and
their _interrelationships_.  

Because taxon concepts represent sets of
organisms, they can be related to each other using set relationship
terms: _is congruent with_, _includes_, _overlaps with_, _intersects_
and _is disjunct from_.  For instance, we can say that Jane’s concept
of species A is broader than John’s and _includes_ John’s concept.
These relationships are very useful to users of taxonomic names,
permitting an understanding of the range of ways a name has been
applied.

If we knew all the set members (organisms) of each taxon concept we
could compute these set relationship terms for each pairwise
comparison of taxon concepts. However, usually these
interrelationships (or _mappings_, or _alignments_) have to be
inferred by careful reading of taxonomic documents, a time-intensive
human task, which is often cited as a barrier to the widespread
adoption of taxon-concept-based approaches to biodiversity information
management. A goal of our project is to explore whether this task can
be shared out to non-specialists, who, with training, may be able to
act as ‘taxonomic detectives’ and record details of taxon concepts and
their relationships found in the literature.  To this end, we are
fortunate to have been joined by
[Kimberly Cook](people.html#kimberly), who since the summer has been
working through taxa in some complex genera (_Erigeron_, _Bromus_,
_Achillea_,...), producing high quality data on taxon concepts and
relationships.

## The tcm web app

We have tried a variety of approaches to managing information on taxon
concepts and relationships, and settled on a four-table data structure:
Publications, Names, Taxon Concepts, and Taxon Concept Relationships.
This structure can be implemented in a spreadsheet (see [example][1]),
but is more robust in a dedicated relational database.

The general structure of such a database is not original, and has been
implemented several times before, e.g., in [ConceptMapper][4],
[TaxLink][5], and in the [Berlin Model][6] that underlies [EDIT][7],
the European Distributed Institute of Taxonomy.  However, I was not
able to easily install or borrow code from these other initiatives,
and so made a simple (single Awk script) web app and database for
Kimberly to use when entering and editing TC data. The app
(imaginatively called `tcm`!) has a
[homepage][2] on Github, with installation instructions; “some
assembly is required”, but installation should only take a few minutes
for someone with basic Unix and web development skills.

The ER diagram of the database is:

<img src="../img/tcmschema.png" style="width:60%;margin-left: auto; 
     margin-right: auto; margin-top:20px;margin-bottom:20px;display:block;"/>

The basic workflow is:

  1. Enter publication details,
  2. Enter a name, referencing its original publication,
  3. Create a taxon concept, linking a name with the publication it is used in, 
     <img src="../img/tcm1.png" style="width:80%;margin-left: auto; 
     margin-right: auto; margin-top:20px;margin-bottom:20px;display:block;"/>
  4. Create a relationship between two concepts, with a reference to the 
     source publication in which the relationship was discussed. 
     <img src="../img/tcm2.png" style="width:80%;margin-left: auto; 
     margin-right: auto; margin-top:20px;margin-bottom:20px;display:block;"/>

These relationships can be view a visual graph, which helps a lot in
the development of chains of relationships. The app uses
[graphviz](https://www.graphviz.org) to generate an image file, which
can be downloaded.  <img src="../img/tcm3.png"
style="width:80%;margin-left: auto; margin-right: auto;
margin-top:20px;margin-bottom:20px;display:block;"/>

The taxon concept relationships can also be exported as RDF, using the
[TDWG ontology][3]. The app is very much a work in progress, as
Kimberly and I discover useful, new bells and whistles, but the first
release works well, and may be of use to others.

[1]: https://docs.google.com/spreadsheets/d/1i4SvHvxFmf5AAnqxA696BVBOgTqadwL9FygvfSpcV8E/edit#gid=1163411256
[2]: https://github.com/akflora/akflora/tree/master/alaskaflora.org/tcm
[3]: http://tdwg.github.io/ontology/ontology/voc/TaxonConcept.rdf
[4]: http://seek.ecoinformatics.org/Wiki.jsp%3Fpage=ConceptMapper.html
[5]: https://www.jstor.org/stable/1224722
[6]: https://www.researchgate.net/publication/281269078
[7]: https://cybertaxonomy.eu/

----

<div id="disqus_thread"></div><script>
var disqus_config = function () {
this.page.url = 'https://alaskaflora.org/pages/blog8.html';  // Edit
this.page.identifier = 'alaskaflora_blog8';                  // Edit
};(function() {  var d = document, s = d.createElement('script');
s.src = 'https://alaskaflora-org.disqus.com/embed.js';
s.setAttribute('data-timestamp', +new Date());
(d.head || d.body).appendChild(s);
})(); </script>
