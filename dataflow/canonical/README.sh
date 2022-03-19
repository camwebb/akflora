# Assembling a canonical names list for Alaska

# This list should be _wider_ than just the plants in AK, just the
# accepted, just the correct variants. I.e., make a list that should
# have all the available names in it, or as many as can be picked up
# in canonical form. Sources IPNI > Trop > WCSP (FNA does not have
# GUIDs yet, plus the author citations are not abbreviated, so harder
# to reconcile).

# See http://alaskaflora.org/pages/blog5.html

if [ $# -eq 0 ]
then
    exit
fi

if [ $1 = "rough" ]
then
    

    # 1. Assemble rough lists: ACCS + ALA + PAF + FNA + Hulten + GBIF for
    # Yukon extension + reviewed taxa. First column should be unique

    cat ../ACCS/accs ../ALA/ala ../PAF/paf ../FNA/fna ../Hulten/hulten \
        ../taxon_review/all_reviewed_2022-03-16 | \
        gawk 'BEGIN{FS="|"}{print $2, $3, $4, $5, $6, $7, $8}' | \
        sed -E -e 's/^ *//g' -e 's/ *$//g' -e 's/  +/ /g' -e 's/×/x/g' | \
        gawk 'BEGIN{FS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} \
                  {n[$1]++}END{for (i in n) print i}' > all_rough

    # these names choke GNR, remove first:
    sed -i -e '/Alnus x purpusii Callier/d' all_rough

    echo "Size of rough list = " `wc all_rough | gawk '{print $1}'`

elif [ $1 = "gna" ]
then

    # 2. Run through GNR
    rm -f names4gnr-* gnr.out
    
    # split into batches of 1,000 for GNR
    gawk '{print $0 > "names4gnr-" int(++i/995)+1 }' all_rough

    for infile in names4gnr-*
    do
        echo "Running GNA on " $infile
        # gawk -v INFILE=$infile -f gnr.awk >> gnr.out
        gawk -v INFILE=$infile -f gnv.awk >> gnv.out
        if [ $? -eq 1 ]
        then
            echo "GNR failed on file $infile Exiting"
            exit 1
        fi
    done

    # parse

    grep "ipni-" gnv.out | gawk -i "taxon-tools.awk" 'BEGIN{FS=OFS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} {code[$3] = $2} END{for (i in code) {p = parse_taxon_name(i, 1); if (p) print code[i], p}}' > ipni_base

    echo "Size of IPNI base list = " `wc ipni_base | gawk '{print $1}'`
    
    grep "trop-" gnv.out | gawk -i "taxon-tools.awk" 'BEGIN{FS=OFS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} {code[$3] = $2} END{for (i in code) {p = parse_taxon_name(i, 1); if (p) print code[i], p}}' > trop_base

    echo "Size of TROP base list = " `wc trop_base | gawk '{print $1}'`

    # Some errors but these are errors in GNR records
    # ** Fail: 'Hordeum x caespitosum 8999+' does not match:
    #          Hordeum x caespitosum 8999+  <- parsed
    # ** Fail: 'Botrychium virginianum var. ? simplex A. Gray' does not match:
    #          Botrychium virginianum var. ? simplex A. Gray  <- parsed
    # ** Fail: 'Sphagnum riparium var. > *fallax Sanio' does not match:
    #          Sphagnum riparium var. > *fallax Sanio  <- parsed

    rm -f names4gnr-* gnr.out
    
elif [ $1 = "wscp" ]
then

    # 3. Find matches of Alaska rough list in WCSP
    # this takes a long time. I ran it on a cluster

    gunzip -kc ../WCSP/wcsp.gz > wcsp
    echo "Size of WCSP total PL list = " `wc wcsp | gawk '{print $1}'`

    # Convert all_rough into a delimited list

    # a few fixes
    sed -i -E -e 's/Uva\-Ursi/Uva-ursi/g' -e 's/\?//g' -e 's/,\ sensu.*$//g' \
        all_rough

    gawk -i "taxon-tools.awk" 'BEGIN{FS=OFS="|"; PROCINFO["sorted_in"] = \
           "@ind_str_asc"} {p = parse_taxon_name($1, 1); if (p) print ++n, p}' \
         all_rough > all_rough.listA

    # lots of fails in accs:
    # 'Betula neoalaskana × glandulosa '
    # 'Caloplaca tornoe?nsis H. Magn.'
    # 'Cetraria fastigata (Del. ex Nyl. in Norrl.) Ka?rnef.'
    # 'Chamaepericlymenum canadense × suecicum '
    # 'Coniferous Shrub (blank)'
    # 'ThelIdium methorium (Nyl.) Hellb.'
    # etc.

    function alphaloop() {
        for i in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
        do
            echo $i
            gawk -v letter=$i 'BEGIN{FS="|"} $3 ~ letter {print $0}' \
                 all_rough.listA > listA_$i
            gawk -v letter=$i 'BEGIN{FS="|"; PROCINFO["sorted_in"] = \
             "@ind_str_asc"} $3 ~ letter {code[$2 "|" $3 "|" $4 "|" $5 \
             "|" $6 "|" $7 "|" $8]=$1} END{for (i in code) \
             print code[i] "|" i}' wcsp > listB_$i
            matchnames -a listA_$i -b listB_$i -o all2wcsp_match_$i -F -e 5 -q
        done
    }

    export -f alphaloop
    # gets hot! use cpulimit if you have it
    cpulimit -l 50 -i bash -c alphaloop

    # gather the parts
    rm -f all2wcsp_all
    for i in `ls all2wcsp_match_*`
    do
        echo $i
        grep -v no_match $i >> all2wcsp_all
    done

    rm -f listA_* listB_* all2wcsp_match_* all_rough* wcsp

    # summarize_field 3 all2wcsp_all 
    # auto_basexin                   :    240
    # auto_basio+                    :     50
    # auto_basio-                    :     30
    # auto_exin+                     :     38
    # auto_exin-                     :     61
    # auto_fuzzy                     :    344
    # auto_in+                       :     36
    # auto_irank                     :   1095
    # auto_punct                     :    950
    # exact                          :   3042

    gawk 'BEGIN{FS="|"; PROCINFO["sorted_in"] = "@ind_str_asc"} {code[$11 "|" $12 "|" $13 "|" $14 "|" $15 "|" $16 "|" $17]=$2} END{for (i in code) print code[i] "|" i}' all2wcsp_all > wcsp_base
    rm -f all2wcsp_all

    echo "Size of WCSP base list = " `wc wcsp_base | gawk '{print $1}'`

elif [ $1 = ipni2ipni ]
then
    # 4. Need to reconcile trop to ipni, to remove the variants
    #    NB 2022-03-18: should have started with a IPNI to IPNI to remove the
    #    very similar names!!
    cp -f ipni_base ipni_listA
    cp -f ipni_base ipni_listB

    # -f would help reduce a few more, but _very_ slow
    # Some remain like this:
    #   ipni-707247-1   Aconitum chamissonianum Rchb.
    #   ipni-1000424-2  Aconitum chamissonianum Reichenb.
    matchnames -a ipni_listA -b ipni_listB -o ipni2ipni_match -q

    # summarize_field 3 ipni2ipni_match 
    # auto_basexin    :    221
    # auto_basio+     :    756
    # auto_basio-     :      2
    # auto_exin+      :    170
    # auto_exin-      :    160
    # auto_in+        :     98
    # auto_in-        :     98
    # auto_irank      :     37
    # auto_punct      :     18
    # no_match        :  14826

    # keep: no_match, auto_basio+, auto_exin+
    gawk 'BEGIN{FS="|"
          while ((getline < "ipni2ipni_match")>0)
            if ($3 == "no_match") keep[$1] = 1
          close("ipni2ipni_match")
          while ((getline < "ipni2ipni_match")>0)
            if ($3 ~ /(auto_basio\+|auto_exin\+)/) { keep[$1]=1; keep[$2] =0 }
          }
          (keep[$1]) {print $0}' ipni_base > ipni_base.2
    
    rm ipni_list* ipni2ipni_match ipni_base

    # wc -l ipni_base*
    # 16386 ipni_base
    # 15024 ipni_base.2

elif [ $1 = trop2ipni ]
then
    # 4. Need to reconcile trop to ipni, to remove the variants
    
    cp -f trop_base trop_listA
    cp -f ipni_base.2 ipni_listB
    touch trop2ipni_match_manual
    rm trop2ipni_match
    
    matchnames -a trop_listA -b ipni_listB -o trop2ipni_match -f -q \
               -m trop2ipni_match_manual

    sed -E '/(\|manual|\|auto_punct|\|exact|\|auto_in)/ d' trop2ipni_match | \
        gawk 'BEGIN{FS=OFS="|"}{print $1, $4, $5, $6, $7, $8, $9, $10}' \
             > trop_base.2

    cat ipni_base.2 trop_base.2 > ipni+trop_base
    rm trop2ipni_match trop_listA ipni_listB
    
    # summarize_field 1 ipni+trop_base | grep " 2"
    # all unique

elif [ $1 = wcsp2base ]
then
    # 5. Need to reconcile wcsp to trop + ipni, to remove the variants

    cp wcsp_base wcsp_listA
    cp ipni+trop_base ipni+trop_listB
    rm wcsp2i+t_match
    touch wcsp2i+t_match_manual

    matchnames -a wcsp_listA -b ipni+trop_listB -o wcsp2i+t_match -f -q \
               -m wcsp2i+t_match_manual

    sed -E '/(\|manual|\|auto_punct|\|exact|\|auto_in)/ d' wcsp2i+t_match | gawk 'BEGIN{FS=OFS="|"}{print $1, $4, $5, $6, $7, $8, $9, $10}' > wcsp_base.2

    cat ipni_base.2 trop_base.2 wcsp_base.2 | sort > canon

    # tidy

    # rm -f trop_base.2 wcsp_base.2 ipni_base ipni+trop_base trop_base wcsp_base     wcsp2i+t_match trop2ipni_match

    # Summarize

    echo "IPNI names in canon list: " `grep -c "ipni-" canon`
    echo "TROP names in canon list: " `grep -c "trop-" canon`
    echo "WCSP names in canon list: " `grep -c "kew-" canon`

fi

exit

# 6. Reconcile ALA to Canon list

gawk 'BEGIN{FS=OFS="|"}{print $1, $2, $3, $4, $5, $6, $7, $8}' \
     ../ALA/ala > ala.1

# echo "Skipping manual stage (matchnames -a ala -b canon)"
matchnames -a ala.1 -b canon -o ala2canon_match -f -q
echo "ALA names: " `wc ala | gawk '{print $1}'`
echo "Reconciling ALA to Canon. Matching: " \
  `grep -vc no_match ala2canon_match`
echo "Reconciling ALA to Canon. No match: " \
  `grep -c no_match ala2canon_match` 

rm -f ala.1 

# 7. Reconcile PAF to Canon list

gawk 'BEGIN{FS=OFS="|"}{print $1, $2, $3, $4, $5, $6, $7, $8}'  \
     ../PAF/paf > paf.1

echo "Skipping manual stage (matchnames -a paf -b canon)"
matchnames -a paf.1 -b canon -o paf2canon_match -f -q

echo "PAF names: " `wc paf | gawk '{print $1}'`
echo "Reconciling PAF to Canon. Matching: " \
  `grep -vc no_match paf2canon_match` 
echo "Reconciling PAF to Canon. No match: " \
  `grep -c no_match paf2canon_match` 

rm -f paf.1 


# 7. Reconcile WCSP to Canon list

gunzip -k -c ../WCSP/wcsp.gz > wcsp
gawk 'BEGIN{FS="|"}{g[$3]++}END{for (i in g) print i}' \
     canon | sort > canon_gen
# only load genera in canon list, and the syns

gawk 'BEGIN{
        FS=OFS="|"
        while ((getline < "canon_gen") > 0) g[$0]++
        while((getline < "wcsp")>0)
          if (g[$3]) {
            w[$1]++
            if ($10) w[$10]++
          } 
        close("wcsp")
        while((getline < "wcsp")>0) 
          if (w[$1]) print $0
      }' > wcsp.1

# reformat and change names from canon
gawk 'BEGIN{FS=OFS="|"}{print "_" $1, $2, $3, $4, $5, $6, $7, $8}' wcsp.1 > wcsp.2

# echo "Skipping manual stage (matchnames -a paf -b canon)"
matchnames -a wcsp.2 -b canon -o wcsp2canon_match -f -e 2 -q

# There were identifiers that were some exactly the same in canon and wcsp, so
# we added '_' to wcsp. Now remove:

sed -i 's/^_//g' wcsp2canon_match

echo "WCSP names: " `wc wcsp.2 | gawk '{print $1}'`
echo "Reconciling WCSP to Canon. Matching: " \
  `grep -vc no_match wcsp2canon_match` 
echo "Reconciling WCSP to Canon. No match: " \
  `grep -c no_match wcsp2canon_match` 

mv -f wcsp.1 ../WCSP/wcsp_ak
rm -f wcsp wcsp.2 canon_gen

# leave wcsp.1 for the DB


# 7. Reconcile ACCS to Canon list

matchnames -a ../ACCS/accs -b canon -o accs2canon_match -f -e 3 -q
# manually created a accs2canon_match.new after messing with ACCS 2020-01-17

# 8. FNA

# Make abbrevs file, using matchnames, and 
# gawk -f findabbrev.awk | sort >> abbrevs
# then comb through abbrev and cf. with IPNI
# Hidden API: https://www.ipni.org/api/1/download?q=author%20std%3ABr.

gawk 'BEGIN{FS=OFS="|"; while ((getline < "abbrevs")>0) {if ($0 !~ /^#/) {g[++i]=$1;a[i]=$2}}}{for (x = 1; x<=i; x++) gsub(g[x],a[x],$8); print $1, $2, $3, $4, $5, $6, $7, $8}' ../FNA/fna > fna

matchnames -a fna -b canon -o fna2canon_match -f -e 4 -q

rm -f fna







