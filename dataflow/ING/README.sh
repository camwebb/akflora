# Get the list of genera from Index Nominum Genericorum

# Note, we have no permission to republish these data, so they will
# need to be regenerated as needed.

gawk -f getING.awk

# get the four-letter results:
# cat > 4letter
# grep 300 4letter
# lept 300
# micr 300
# para 300
# poly 300
# pseu 300
# tric 300

gawk -v pre=pseu -f getING.awk 
gawk -v pre=pseud -f getING.awk 
gawk -v pre=pseudo -f getING.awk 
gawk -v pre=lept -f getING.awk 
gawk -v pre=micr -f getING.awk 
gawk -v pre=micro -f getING.awk 
gawk -v pre=para -f getING.awk 
gawk -v pre=poly -f getING.awk 
gawk -v pre=tric -f getING.awk 
gawk -v pre=trich -f getING.awk 

# wc ING*
#    3930    3930   55999 ING_extras
#   64211   64211  755882 ING_list
# cat ING_list ING_extras | sort | uniq | wc
#   65335   65335  772630

cat ING_list ING_extras | sort | uniq > ING_genus_list

grep "&" ING_genus_list | sed -E 's/^.*(&[^;]+;).*$/\1/g' | sort | uniq
# &euml;
# &iuml;
# &ouml;

cp ING_genus_list ING_genus_list_for_tpl
sed -i 's/&euml;/e/g' ING_genus_list_for_tpl
sed -i 's/&iuml;/i/g' ING_genus_list_for_tpl
sed -i 's/&ouml;/o/g' ING_genus_list_for_tpl

rm ING_list ING_extras


