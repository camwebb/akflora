% Blog 7: Assembling the canonical names list

# Blog 7: Assembling the canonical names list

_Posted by [Cam](people.html#cam) on 2019-04-30_

Hi again! Back to _names_ after our recent foray into phenotypes.

Having got hold of most of the “engines”, taken them apart, laid out
the parts, tried to jam them together several times, I’m now ready to
document the details of assembling our integrated names list.  Work
over the past months has been “two steps forward, one-and-a-half steps
back” as I learned about the complexities an limitations of each
source database database and the challenges of integrating
them. Actually, I think that’s how the work will be all the way
through this project! But I think I now have a good base _canonical
names list_. This is the definition of our master list of names:

 1. Names from “core” online names resources (i.e., not derived; see
 [blog 2](blog2.html)),
 2. Unique, and sourced preferentially by the highest name resource
 “quality” (IPNI > Tropicos > World Checklist of Selected Plant
 Families),
 3. Internally reconciled to remove duplicates and orthographic variants,
 4. Each with a Globally Unique Identifier (with a live URL), and,
 5. Including almost all names applied to Alaskan plants (at least
 which are available online).

The list itself makes no note of status (currently accepted
vs. synonym); that comes next.

The steps to assemble this list were to:

 1. Obtain a “rough list” of names for Alaskan plants from a variety
 of sources: the ACCS checklist (currently
 [here](https://floraofalaska.org/comprehensive-checklist/)), the ALA
 herbarium checklist assembled by Dave Murray and colleagues
 ([here](ALA_checklist.html)), the Alaskan names in the
 [Panarctic Flora](http://panarcticflora.org), and the Alaska names in
 FNA (thanks to the FNA/Botanical Knowledge Portal group at the Ottawa
 Research and Development Centre, AAFC).
 2. Find all the fuzzy-matching names in IPNI using GNR, and 
 find all the fuzzy-matching names in Tropicos using GNR.
 3. Find all the fuzzy-matching names in the World Checklist of Selected
 Plant Families, via a download of The Plant List, and matching using
 `matchnames` ([Blog 3](blog3.html)). 
 4. Reconcile the Tropicos names to the IPNI names using `matchnames`,
 to remove the Tropicos duplicates of IPNI names.
 5. Reconcile the WCSP names to the IPNI-plus-Tropicos names using
 `matchnames`.

The resulting list contains 19,452 names (13,775 with an IPNI GUID,
4,890 with a Tropicos GUID, and 787 with a PlantList GUID).

<img src="../img/assembly1.png" alt="overview diagram" style="width:80%;margin-left: auto; margin-right: auto; display:block;"/>

Remember, this canonical list of names includes both accepted and
synonyms.  As we move towards the goal of an _accepted_ names, we can
then take our lists of names with taxonomic status, from, e.g., the
ALA checklist and the PAF checklist and reconcile these to the
canonical list to get a “clean” name (i.e., as originally spelled, and
with standardized authors) for each name we wish to accept and its
synonyms. In this way, we were able to get clean names for 3,358 out
of 3,740 names from the ALA checklist, and 2,405 out of 2,823 names
from the Alaskan plants in PAF.




----

<div id="disqus_thread"></div><script>
var disqus_config = function () {
this.page.url = 'https://alaskaflora.org/pages/blog7.html';  // Edit
this.page.identifier = 'alaskaflora_blog7';                  // Edit
};(function() {  var d = document, s = d.createElement('script');
s.src = 'https://alaskaflora-org.disqus.com/embed.js';
s.setAttribute('data-timestamp', +new Date());
(d.head || d.body).appendChild(s);
})(); </script>
