// USING PERIODIC COMMIT 500
// LOAD CSV FROM 'file:///canon_names'
// AS line FIELDTERMINATOR '|'
// CREATE (:Name {name: line[0], canon: 'yes', genus: line[2], species: line[4]});

// USING PERIODIC COMMIT 500
// LOAD CSV FROM 'file:///paf_names'
// AS line FIELDTERMINATOR '|'
// CREATE (:Name {name: line[0], genus: line[2], species: line[4]});

// USING PERIODIC COMMIT 500
// LOAD CSV FROM 'file:///paf_ortho' AS line FIELDTERMINATOR '|'
// MATCH (a:Name {name: line[0]}), (b:Name {name: line[1]})
// MERGE (a)-[:ORTHO]->(b);

// USING PERIODIC COMMIT 500
// LOAD CSV FROM 'file:///paf_rel' AS line FIELDTERMINATOR '|'
// MATCH (a:Name {name: line[0]}), (b:Name {name: line[1]})
// WHERE line[2] = 'synonym'
// MERGE (a)-[:SYN {accordingto: ['PAF']}]-> (b);

// CREATE (:Source {name: 'PAF'});

// USING PERIODIC COMMIT 500
// LOAD CSV FROM 'file:///paf_rel' AS line FIELDTERMINATOR '|'
// MATCH (a:Name {name: line[0]}), (b:Name {name: line[1]})
// WHERE line[2] = 'synonym'
// MERGE (a)-[:SYN {accordingto: ['PAF']}]-> (b);

// MATCH p=()<-[:ORTHO]-()-[:SYN]->()-[:ORTHO]->() RETURN p LIMIT 20
  
// USING PERIODIC COMMIT 500
// LOAD CSV FROM 'file:///paf_rel' AS line FIELDTERMINATOR '|'
// MATCH (a:Name {name: line[0]})
// WHERE line[2] = 'accepted'
// SET a.acceptedby = coalesce(a.acceptedby,[]) + 'PAF'

// //CREATE (:Source {name: 'PAF'});
  
// // USING PERIODIC COMMIT 500
// // LOAD CSV FROM 'file:///paf_rel' AS line FIELDTERMINATOR '|'
// // MATCH (a:Name {name: line[0]}), (b:Source {name: 'PAF'})
// // MERGE (a) -[:ACCEPTED]-> (b);

USING PERIODIC COMMIT 500
LOAD CSV FROM 'file:///paf_ak' AS line FIELDTERMINATOR '|'
MATCH (a:Name {name: line[0]})
WHERE line[1] = '1'
SET a.inak = coalesce(a.inak,[]) + 'PAF'

       

// -----

// MATCH () -[b:SYN]-> () DELETE b;
// MATCH (n:Name {inak: ['PAF']}) RETURN n LIMIT 25 
// MATCH (n:Name) RETURN n LIMIT 25
// MATCH (n) WHERE EXISTS(n.inakby) RETURN DISTINCT "node" as entity, n.inakby AS inakby LIMIT 25 UNION ALL MATCH ()-[r]-() WHERE EXISTS(r.inakby) RETURN DISTINCT "relationship" AS entity, r.inakby AS inakby LIMIT 25
// MATCH p=()-->() RETURN p LIMIT 25
// MATCH (n) RETURN n LIMIT 25
// MATCH (n:Name) RETURN n LIMIT 25
// MATCH p=()-[r:ACCEPTED]->() RETURN p LIMIT 25
// CREATE (:Source {name: 'PAF'});
// MATCH (n:Name) WHERE exists(n.acceptedby) RETURN n LIMIT 25
// MATCH (n:Name) RETURN n LIMIT 25
// MATCH (n) RETURN n LIMIT 25
// MATCH (n:Name) RETURN n LIMIT 25
// MATCH (n) WHERE EXISTS(n.acceptedby) RETURN n LIMIT 5;
// MATCH (n) WHERE EXISTS(n.acceptedby) RETURN n;
// MATCH (n) WHERE EXISTS(n.acceptedby) RETURN DISTINCT "node" as entity, n.acceptedby AS acceptedby LIMIT 25 UNION ALL MATCH ()-[r]-() WHERE EXISTS(r.acceptedby) RETURN DISTINCT "relationship" AS entity, r.acceptedby AS acceptedby LIMIT 25
// MATCH (n:Name) RETURN n LIMIT 25
// MATCH (n {acceptedby: 'PAF'}) RETURN * LIMIT 25
// :help history
// MATCH () -[b:ACCEPTED]-> () DELETE b;
// MATCH p=(a)<-[:ORTHO]-()-[:SYN]->()-[:ORTHO]->(b) RETURN a.name, b.name;
