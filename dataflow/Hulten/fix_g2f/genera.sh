
rm genlist

for i in `find ../tiff -name "*-[0-9]-[t].txt" | sort`
do
    FILE=`basename "$i"`
    CODE=${FILE/-t.txt/}
    GEN=`head -n 1 $i | gawk '{print \$1}'`
    echo $CODE"|"$GEN >> genlist
    # convert $i illust/${FILE/-[Ii].tiff/.jpg}
done

gawk 'BEGIN{FS="|"; while ((getline < "g2f_hulten") > 0) g[$1]++}{if (!g[gensub(/é/,"e","G",$2)]) print $0}' genlist


