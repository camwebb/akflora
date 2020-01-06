
echo "59c59
< 36. *Maundiaceae Nakai 
---
> 36 []. *Maundiaceae Nakai 
425c425
< 318 [—].*Nyssaceae Juss. ex Dumort., nom. cons. 
---
> 318 [—]. *Nyssaceae Juss. ex Dumort., nom. cons. 
509c509
< 384 [—].*Mazaceae Reveal 
---
> 384 [—]. *Mazaceae Reveal " > p1.patch

patch -o apg2016_appendix.2 apg2016_appendix p1.patch

gawk '{
  gsub(/[*‘’]/,"",$0)
  if ($1 ~ /ales$/)
    order = $1
  else if ($3 ~ /aceae$/)
    print $1 "|" $3 "|" order }' \
     apg2016_appendix.2 | sort -n > f2o

echo "Check: 416 lines in f2o:"
wc f2o

rm apg2016_appendix.2 p1.patch

