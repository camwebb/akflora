xq 'for $t in //taxon for $xy in $t//xy return concat($t/@id/string(), "|" ,$t/name/string(), "|" , $xy/string())' ../hulten.xml | gawk 'BEGIN{FS=OFS="|"}{name[$1] = $2; split($3,x,",") ; if (x[1] < min[$1]) min[$1] = x[1]} END{for(i in min) if (min[i] > -141) print i, name[i], min[i]}' > poss_out
mkdir maps
gawk 'BEGIN{FS=OFS="|"}{print $2; system("cp ../tiff/" gensub(/-.*/,"","G",$1) "/"$1"-1.tiff maps")}' poss_out

gawk 'BEGIN{FS=OFS="|"}{print $1,""}' poss_out | sort > out_edit

qiv maps/*

emacs out_edit

gawk 'BEGIN{FS=OFS="|"} $2 == "c" || $2 == "y" {print $1}' out_edit > not_in_alaska

gawk 'BEGIN{FS=OFS="|"} $2 == "y" {print $1}' out_edit > not_in_alaska_but_in_yt

gawk 'BEGIN{FS=OFS="|"} $2 == "c" {print $1}' out_edit > not_in_alaska_or_yt

xq 'for $t in //taxon return concat($t/@id/string(), "|" ,$t/name/string())' ../hulten.xml > names

echo -e "# Not in Alaska but in YT:\n" > readable
gawk 'BEGIN{FS="|"; while ((getline < "names")>0) name[$1]=$2}{print name[$1]}' not_in_alaska_but_in_yt | sort >> readable
echo -e "\n# Not in Alaska or YT:\n" >> readable
gawk 'BEGIN{FS="|"; while ((getline < "names")>0) name[$1]=$2}{print name[$1]}' not_in_alaska_or_yt | sort >> readable

rm -f maps/*
