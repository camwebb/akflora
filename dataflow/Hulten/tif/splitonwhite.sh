
FILE=p27.tif

# take off the top
convert $FILE -crop 4510x6000+0+450 out.tif

# magick display -crop 4510x6000+0+450 -resize x1080 p26.tif

INWHITE=0

for h in `seq 1000 200 5000`
do
    # are there any dark pixels in a band
    # BLACK=`convert out.tif -crop 4510x10+0+$h -threshold 80% \
    #  -unique-colors txt:- | grep -c "#000000"`
    BLACK=`convert out.tif -crop 4510x10+0+$h -threshold 80% \
      -format %c -define histogram:unique-colors=true histogram:info:- \
         | gawk 'BEGIN{b=0} /#000000/ {gsub(/:/,"",$1); if ($1+0 > 100) b=1} \
           END{print b}'`
    # convert out.tif -crop 4510x50+0+$h -threshold 80% out-$h.tif
    # echo $h $BLACK $INWHITE 
    # record the first
    
    if [ $BLACK -eq 0 -a $INWHITE -eq 0 ]
    then
        let WSTART=h
        let INWHITE=1
    elif [ $BLACK -eq 1 -a $INWHITE -eq 1 ]
    then
        let WEND=h-190
        let INWHITE=0
        # assume that the main break has been found and bail
        break
    fi
    # echo $h $BLACK $INWHITE $WSTART $WEND 
done

let SPLIT=`gawk "BEGIN{print int($WSTART+(($WEND-$WSTART)/2))}"`
echo $WSTART $WEND $SPLIT

# now crop:
let H2=6000-$SPLIT

convert out.tif -crop 4510x$SPLIT+0+0 top.tif
convert out.tif -crop 4510x$H2+0+$SPLIT bot.tif
