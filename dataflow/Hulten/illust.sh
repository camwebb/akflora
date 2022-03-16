
for i in `find tiff -name "*-[0-9]-[Ii].tiff" | sort`
do
    FILE=`basename "$i"`
    echo $FILE
    convert $i -resize 1000x1000 illust/${FILE/-[Ii].tiff/.jpg}
done
