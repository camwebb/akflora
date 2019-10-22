# Assembling names into a database

For each new resource:

 1. Add all new names to `names` table (a name is new if its md5sum is
    not matched in `names.md5sum`).  For the original canonical list,
    the status of `names.canonical` is set to `T`. 

 2. Insert the (new) uid strings into `uids` for all new names
    added. For the original canonical list, link the canonical name to
    the canonical uid. The form of the uid is a string of characters
    followed by a dash followed by another identifier. The prefix is:
    
    * `ipni` : the IPNI number (including the version element:
      `\-[0-9]+`). URL: `https://www.ipni.org/n/<identifier>`
    * `trop` : the Tropicos code. URL:
      `http://www.tropicos.org/Name/<identifier>` 
    * `ala` : An internal identifier for all ALA names
    * `paf` : the PAF identifier. URL:
      `http://panarcticflora.org/flora#paf-<identifier>`
    * `kew` : The WCSP identifier. URL:
      `https://wcsp.science.kew.org/namedetail.do?name_id=<identifier>`
    
 3. Prior to adding a resource, the names in it should be checked
    against the canonical list, using `matchnames`. The mappings of
    variation from names used in the resource to the canonical set are
    added to the `ortho` table. If there is no mapping, `ortho`.`type`
    is set to `"self"` and `toID` is set to the same name.

If the resource makes statements about synonymy relationships among
names, add these to table `rel`. As with `ortho`, `type` is set to
`"self"` and `toID` is set to the same name.
 
Here’s the ER diagram of the database:

<img width="50%" src="schema.png"/>

Please read the individual (commented) SQL files for details.

## Queries and mapping

  Src1   o   Can  o  Src2    Result
  =====  == ===== == =====   ======

1   A*   =    A   =    A*    S1==S2  

2   A*   =    A   <-   B*    S1==S2

3   A*   ->   B   <-   C*    S1==S2

4   A*   =    A  
              B   =    B*    S1!=S2

5   A*   =    A  
              C   <-   B*    S1!=S2


4   A*   =    A
              B      B*    S1!=S2


    A    ->   B   =    B   
    |s                 |s
    v                  v
    C    =    C   =    C


## Notes

 * _Bassia_ is a homonym. An acanth and a sapot! So we loaded a lot of
   tropical Sapotaceae into wcsp!
   
   
