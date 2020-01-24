# Digitizing Hulten

# Extract pages in correctly numbered order

START=25
STOP=29

# page 23 of the pdf is page number 1 of the book
#   but missing pages: 8,9 so taxa start pn 25 = p 45
let ISTART=$START+20
let ISTOP=$STOP+20

cd tif
for p in `seq $ISTART $ISTOP`
do
    let pn=$p-20
    echo "Extracting book page $pn (pdf page $p)"
    pdfimages -f $p -l $p ../hulten.pdf p$pn
    convert p$pn-000.ppm p$pn.tiff
    rm -f p$pn*p[bp]m
done
    



exit

tesseract img-000.ppm out

pdftotext --show-npages hulten.pdf 
pdftotext -bbox -f 100 -l 100 hulten.pdf out

pdfimages -f 100 -l 100 hulten.pdf 100

pdfimages -f 101 -l 101 hulten.pdf 101

qpdf --pages 101 hulten.pdf 
qpdf --show-object hulten.pdf 
qpdf --show-xref hulten.pdf 
qpdf --show-pages --with-images hulten.pdf 
qpdf --show-object=14317 hulten.pdf 
qpdf --show-object=14317 --raw-stream-data hulten.pdf 
qpdf --show-object=14317 --filtered-stream-data hulten.pdf 
qpdf --show-object=14317 --filtered-stream-data --normalize-content=y hulten.pdf
qpdf --show-object=14317 --filtered-stream-data --normalize-content=y hulten.pdf > test

tesseract p50.tif p50.tess.4 --user-words mywords

multi_crop p50.jpg out.jpg
multi_crop -s fuzz p50.jpg 
multicrop p50.jpg mc
multicrop p50.sm.tif mc

convert p50.sm.tif p50.sm.jpg

multicrop -f 30 p50.sm.jpg test.jpg



