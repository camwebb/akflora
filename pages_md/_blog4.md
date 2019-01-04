% Databasing name variations

# Databasing name variations

_Posted by [Cam](people.html#cam) on 2018-12-19_

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


