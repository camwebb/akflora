# The synonyms are in the references table.

echo "SELECT paf_id, ranking, name, label, subspecies, variety, 
             author, original_author, syns 
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

