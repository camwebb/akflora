
ARCTOS_CFID=""

# 2023-04-11: count = 230978

rm -f guid2url
for i in `seq 0 23`
do
    echo "${i}0000"
    curl -s -L 'https://arctos.database.museum/tools/userSQL.cfm'   \
         -H "Cookie: cfid=$ARCTOS_CFID; cftoken=0" \
         --data 'action=run' \
         --data 'format=csv' \
         --data-urlencode "sqltxt=SELECT DISTINCT flat.guid, media.media_uri FROM flat, media_relations, media WHERE flat.collection_object_id = media_relations.cataloged_item_id AND media_relations.media_id = media.media_id AND guid ~ '^UAMb?:(Herb|Alg)' AND media.mime_type = 'image/jpeg' ORDER BY guid LIMIT 10000 OFFSET ${i}0000" \
        | sed -e 's/"//g' -e 's/,/ /g' | tail -n +2 >> guid2url
done
