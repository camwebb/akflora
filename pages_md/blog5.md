% Blog 5: Phenotype data entry and sharing

# Blog 4: Phenotype data entry and sharing

_Posted by [Cam](people.html#cam) on 2019-02-28_

I got diverted from “name wrangling” these past few weeks, and have
been thinking about morphological characters and pehenotypes. Among
the goals of the NSF-funded project is to develop a taxon × character
matrix for all the ca. 2,300 taxa we will eventually have in the
Flora. This matrix can be used for analyses and in descriptions of
taxa, but the main use will be in an interactive identification key
for Alaskan plants. An interactive key differs from a traditional
dischotomous key primarily in allowing the user to start with any
character they may have handy, rather than pre-determining the first
character couplet. An interactive key is essentially the cumulative
application of character filters on the taxon × character matrix until
a single or small number of taxa remain.

Our plan in the proposal was to assemble data on enough characters to
reduce the number of taxa to a size where visual scanning of thumbnail
images would permit rapid selection of a final identified taxon. The
primary trade-off for us in chosing the numnber of characters to score
is “descriminatory capability” (i.e., reducing the potential taxa list
as much as possible) vs. time needed to assemble the matrix. Since we
intend the interactive key to be usable by interested but relatively
untrained members of the public, the set of available characters is
fairly constrained to those that do not need botanical experience
(e.g., not “placentation type”) or special equipment (e.g., not “hairs
stellate”).

After discussion among the Flora of Alaska Executive Committee, and
some initial trial and error, we have settled on these 12 characters:

 * Whole plant phenotypes
    * Plant habit: tree, shrub, grass-like or forb
    * Plant stem: caulescent or acaulescent
 * Leaf phenotypes
    * Leaf insertion: alternate or opposite
    * Leaf form: simple or not (including palmate, pinnate, trifoliate)
    * Leaf margin: entire or not
    * Leaf primary venation: parallel or not
 * Flower/fruit phenotypes
    * Inflorescence of multiple flowers: yes or no (solitary flowers)
    * Flower with pedicel: “stalked” or not
    * Flower symmetry:  actinomorphic or zygomorphic    
    * Flower color: blue, brown, green, orange, pink, purple, red,
      white, or yellow
    * Ovary position: inferior, semi-inferior or superior 
    * Fruit fleshiness: dry or fleshy

## Phenotype data interoperability

As you know by now, _interoperability_ is the name of the game with
this project, and as we set out to record these morphological data, we
need to try to maximize the possibility that they can be re-used by
other projects. So, “how best to standardize and share phenotype
data?” Vast numbers of taxon × character matrices (and individual ×
character matrices) have been assembled (see e.g.,
[Morphobank](https://morphobank.org/), but most of the matrices cannot
easily be “aligned” with other matrices: even though the taxa may
overlap, the characters are seldom standardized and often have
definitions that are ideosyncratic to a particular project. This
situtation is in contrast to the taxa × sequence data, which _can_
generally be aligned, and thus can be contributed to vastly resources
like [Genbank](https://www.ncbi.nlm.nih.gov/genbank/).

To answer the above questions about character standardization, we need
to take a detour into the nuts and bolts of systematically recording
phenotype data, whether for identification or for mophological
analysis purposes. The simplest “model” of phenotype is `Character +
Character state`, e.g., “leaf insertion into stem” (= `Character`) +
“opposite” (= `Character state`). This was the approach taken by the
the pioneering [DELTA](https://www.delta-intkey.com/) system
(DEscription Language for TAxonomy; see also
[OpenDelta](http://downloads.ala.org.au/p/Open%20DELTA) and
[FreeDelta](http://freedelta.sourceforge.net/fde/)), as well as that
of MacClade, and its descendant
[Mesquite](https://www.mesquiteproject.org/). This model was also
adopted by the
[Structured Descriptive Data](https://github.com/tdwg/sdd)
serialization standard of [TDWG](https://www.tdwg.org/).

This two-part descriptive approach was critiqued in an
[important paper](http://dx.doi.org/10.2307/25065431) by Pullan et
al. (2005), who had proposed a three-part “descriptive element” (part of the Prometheus II project):
`Structure + Property + Score`. And in another lineage of this
phenotype conversation, growing out of the gene annotation and Open
Biological and Biomedical Ontology (OBO) community,
[Paula Mabee](https://www.usd.edu/faculty-and-staff/Paula-Mabee),
[Jim Balhoff](https://www.mendeley.com/profiles/jim-balhoff/) and
[Phenoscape](https://phenoscape.org/) collegues have developed the
[Entity-Quality formalism](https://wiki.phenoscape.org/wiki/EQ_for_character_matrices),
where a complex `Quality` “inheres” in an `Entity`. The three
approaches line up so:

<table class="blog5_tab">
<tr><th>System</th><th>Thing</th><th>Quality</th><th>Quality value</th></tr>
<tr><td>1. DELTA, Mesquite, etc.</td><td colspan="2">Character<br/><i>(Leaf insertion)</i></td><td>State<br/><i>(opposite)</i></td></tr>
<tr><td>2. Prometheus II<br/>(Pullen et al. 2005)</td><td>Structure<br/><i>(Leaf)</i></td><td>Property<br/><i>(insertion geometry)</i></td><td>Score<br/><i>(opposite)</i></td></tr>
<tr><td>3. EQ Model<br/>(Phenoscape)</td><td>Entity<br/><i>(Leaf)</i></td><td colspan="2">Quality<br/><i>(opposite insertion,<br/>= subclass of ‘insertion geometry’)</i></td></tr>
</table>

There is no reason why a standardized set of Character/States (Model
1) could not have been developed for plants (and there were/are
probably a number of efforts to do this that I don’t know
of). However, conceiving of the problem in terms of Entities and
Qualities simplifies the matter of standardization _ontologically_,
because there have existed for a number of years unique Taxon-specific
“Entity ontology” projects, e.g., the
[Plant Ontology](http://browser.planteome.org/amigo), the
[Mammalian Phenotype ontology](http://obofoundry.org/ontology/mp.html)
and even the _Xenopus laevis_ Anatomy
Ontology(http://www.xenbase.org/anatomy/xao.do?method=display). These
ontologies are careful class- and subclass-based abstractions of the
anatomy of a group of organisms. For example, the _calyx_ is a
subclass of _collective phyllome structure_ and also a _part of_ a
_flower_.  Because they all grew out of a “super-project” (OBO) they
share common properties and permit cross-ontology statements.  

When we combine the Plant Ontology (PO) with the Phenotype and Trait
Ontology (PATO)---an ontology of generic phenotypic qualities, e.g.,
“divided”, “red”---plant phenotypes can theoretically be defined and
standardized efficiently. I tried playing with this approach back in
[2011](http://xmalesia.info/doc/datamodel.html) but at the time found
many of the necessary entities and qualities missing from PO and
PATO. However, in the years since, there has been further development
of these ontologies and now many “Character/State” statements can be
encoded directly as “Entity/Quality” statements. And of particular note is a FLOPO

Traits 10.1038/s41559-018-0667-3

ALA: Rachael Gallagher 
Using trait data to support biodiversity research in https://www.idigbio.org/wiki/index.php/Digital_Data_in_Biodiversity_Research_Conference,_Berkeley
https://www.idigbio.org/wiki/images/9/9f/IDigBio_Traits_Discussion_-_Participants_and_agenda.pdf




One major advantage
Ontology based... 

Two are needed: a structural ontology... and a 


Functionally, it doesn’t matter how you score the character in a local
database... 




https://www.researchgate.net/publication/221502264_A_Universal_Character_Model_and_Ontology_of_Defined_Terms_for_Taxonomic_Description/download






The authors also 








We just
hired a project researcher, Brian



 Taxon that inverse('member of taxon') some (Organism that 'has phenotype' some 'Leaf insertion not alternate')
 
 Organism that 'has phenotype' some 'Leaf insertion not alternate'
 
 Phenotype that 'Leaf insertion not alternate'
 
RDF open world 

A >  B  :: B rdfs:subClassOf     A
A <  B  :: A rdfs:subClassOf     B
A == B  :: A owl:equivalentClass B
A >< B  ::   ( no statement needed, assumed by OWA )
A |  B  :: A owl:disjointWith    B


(1) The FNA Categorical Glossary:
http://www.huntbotanical.org/databases/show.php?4
Can be queried here: http://fmhibd.library.cmu.edu/HIBD-DB/FNA/findrecords.php

This resource covers a large proportion of the terms used in the FNA,
but is not complete.

(2) The FloraTerms TDWG resource: https://terms.tdwg.org/wiki/FloraTerms

This project originated from the development of the FNA Categorical
Glossary. It extracts and enhances terms from the FNA Categorical
Glossary, through the use of CharaParser on the FNA. It was intended
to be a simple, collaborative space for the agreement on definitions
by botanists. Its terms are more simple than PATO's.

In fact, a few of us proposed that we should begin contributing to
this resource again, and attempt to revive it under our new project
building a Carex ontology for a treatment authoring tool.

(3) Planteome has been amenable to accepting contributed terms, and so
another approach would be creating a set of definitions de novo, and
contribute what is developed.

Lastly, a final consensus of our discussion was that we will need an
answer to this question for our work in the future. If we can
collaborate in some way to advance this cause, please reach out.


