

for i in `find ../tiff/[89]* -name "*-1.tiff" | sort`
do
    DIR=`dirname "$i"`
    FILE=`basename "$i"`
    TXT=${FILE/1.tiff/t.txt}
    OUT=${FILE/.tiff/.csv}
    OUTM=${FILE/1.tiff/1b.png}
    NAME=`gawk 'NR == 1 {print gensub(/ *[/|].*$/,"","G",$0)}' $DIR/$TXT`
    echo $i $NAME

    convert $i -resize 500x500 -threshold 35% txt: | \
        grep 000000 | sed 's/:.*$//g' > map
    # ./map2points | gawk -v x="$NAME" '{print $0 "," x}' >> out.csv
    cpulimit -l 80 -i ./map2points > $DIR/$OUT
    mv map.png $DIR/$OUTM
    
done

