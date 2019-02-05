# Generate an Alaska names list from the Panarctic Flora

# See LICENSE file for data licensing

# Data history: In 2018, with permission of the PAF editors, Christian
#   Svindseth made the sqlite3 file running http://panarcticflora.org/
#   available to Cam Webb. Webb converted the encoding to UTF-8 and
#   loaded the data into a mysql/mariaDB DB. In Dec 2018 Reidar Elven
#   authorized the sharing of the raw data. The `paf.sql` file in this
#   github repo is the first public uploading of these data.

# paf.sql made with:
#   mysqldump -R -u ... -p... paf | sed 's/),(/),\n (/g' > paf.sql
# (The breaking of lines allows diff to find updates)

source ../ENV.sh


# 1. Load PAF data into a mysql/mariaDB database

echo "Loading PAF data into DB" > "/dev/stderr"
mysql -u $AKFLORA_DBUSER -p$AKFLORA_DBPASSWORD --show-warnings < paf.sql

# 2. Query the db

# this is needed to allow the connection to close - some sort of bug
#  --connect-timeout=1 does not help, exec <&- does not help
echo "(waiting 10 seconds)"
sleep 10
echo "(back again)"

echo "SELECT paf_id, ranking, name, label, subspecies, variety, 
             author, original_author, syns , specifier, affinis
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
        c.inak IS NOT NULL;" | mysql -N -u $AKFLORA_DBUSER \
        -p$AKFLORA_DBPASSWORD --show-warnings paf | sed 's/NULL//g' > paf.1


# 3. Parse the synonyms out of the PAF text

# NB: The PAF synonyms are in the references table.
# I used the file `syn_parse_tests` to help construct the logic of the
# parse_syns.awk script.

gawk -f parse_syns.awk paf.1 > paf.2

# 4. Manual check (use datacheck-mode.el to assist) and build a patch

# cp paf.2 paf.3
# emacs paf.3
# diff paf.2 paf.3 > p1.patch

# NB: some duplicates were present:
# cat paf.3 | sort | uniq -d
#  100101   | Lastrea dilatata var. alpina Moore
#  3309044  | Carex capillaris var. robustior Drejer ex Lange
#  340602   | Hordeum boreale Scribn. & J.G. Sm.
#  420408   | Stellaria biflora L.
#  671611   | Cardamine digitata Richardson
# also:
# Warning: paf-340906, Hierochloë pauciflora R. Br. is both acc and syn
# Warning: paf-671611, Cardamine digitata Richardson is both acc and syn

echo "Manual checking of PAF data skipped..."

# 5. Run the patch to automate the manual editing

patch -o paf.3 paf.2 p1.patch
if [ $? -ne 0 ] ; then exit ; fi


# 6. Add a unique code to syn and create lookup

gawk -i "taxon-tools.awk" -f create_syn_lookup.awk > paf

# NB: Allow this:
# Warning: paf-343001, Dupontia fisheri R. Br. is both acc and syn
#  (paf-343001b-s1)


# 7. Clean up
rm -f paf.1 paf.2 paf.3


# Notes:

# This script is useful for accessing PAF info:
# echo "select paf_id,ranking,name,label,subspecies,variety,author,\
#   original_author, syns from entries left join ( select entry_id , \
#   GROUP_CONCAT(\`raw\` SEPARATOR '^') as syns from \`references\` \
#   group by entry_id ) as b on entries.id = b.entry_id where \
#   ( ranking = 'species' or ranking = 'subspecies' ) \
#   AND entries.paf_id = '$1';" | mysql -N -u cam -ptesttest paf | \
#     sed 's/NULL//g'
