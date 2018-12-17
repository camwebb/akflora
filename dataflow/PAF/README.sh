# Making updates bit by bit to DB. Do this to allow versioning

# mysqldump -u ... -p... paf | sed 's/),(/),\n (/g' > db/paf.sql

# The synonyms are in the references table.

echo "SELECT paf_id, ranking, name, label, subspecies, variety, 
             author, original_author, syns , specifier
      FROM entries 
      LEFT JOIN 
        ( SELECT entry_id , GROUP_CONCAT(\`raw\` SEPARATOR '^') AS syns 
          FROM \`references\` 
          GROUP BY entry_id ) AS b 
        ON entries.id = b.entry_id 
      LEFT JOIN 
        ( SELECT DISTINCT entry_id AS inak FROM entries 
            LEFT JOIN distributions ON entries.id = distributions.entry_id
            WHERE ((area = 'AN' OR area = 'AW') AND 
                    distribution != '-') OR geography LIKE '%ALA%') AS c
        ON entries.id = c.inak
      WHERE ( ranking = 'species' OR ranking = 'subspecies' ) AND
        c.inak IS NOT NULL;" | mysql -N -u cam -ptesttest paf | sed 's/NULL//g' > paf.1

gawk -f lib/parse_syns.awk paf.1 > paf.2

# Manual check (use emacsmode.el) and build a patch

patch -o paf.3 paf.2 patch/p1.patch
if [ $? -ne 0 ] ; then exit ; fi

# some duplicates:

# cat paf.3 | sort | uniq -d
#  100101   | Lastrea dilatata var. alpina Moore
#  3309044  | Carex capillaris var. robustior Drejer ex Lange
#  340602   | Hordeum boreale Scribn. & J.G. Sm.
#  420408   | Stellaria biflora L.
#  671611   | Cardamine digitata Richardson
# also:
# Warning: paf-340906, Hierochloë pauciflora R. Br. is both acc and syn
# Warning: paf-671611, Cardamine digitata Richardson is both acc and syn

patch -o paf.4 paf.3 patch/p2.patch
if [ $? -ne 0 ] ; then exit ; fi

# cat paf.4 | sort | uniq -d  # OK

# add a unique code to syn

gawk -f lib/make_all_names_list.awk | sort > paf.5

# Allow this:
# Warning: paf-343001, Dupontia fisheri R. Br. is both acc and syn (paf-343001b-s1)




