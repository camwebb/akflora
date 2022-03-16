# Extracting parts from scanned Hultén

 * Keys not OCRd. Files named <page>-k1, <page>-k2 ... 

## Text parsing convertions and decisions

General format, 6 blocks sparated by empty lines (checked on
2021-04-21). A dash is used as a place marker when no text for that
block appears in account.

**Block 1**: one line only. `matchable_name` [ `/ Hulten_name` ]?
[ `| common name` ]?.  `Hulten_name` is the default infraspecific name
Hulten gives when another infraspecific taxa is given. Sometimes
(rarely) this term will be of the form `subsp. multiflora var. frigida
(Buchenau) Sam.` when the full Hulten name was `Luzula multiflora
(Retz.) Lej. subsp. multiflora var. frigida (Buchenau) Sam.` and the
matchable name is `Luzula multiflora var. frigida (Buchenau) Sam.` On
2021-01-14 I went back through every treatment up to p416 to double
check this, scanning for infra name the same as sp name, but without
an author.

**Block 2**: synonyms of the `matchable_name`. Where Hulten has added
a default infrapecific epithet, the synonyms refer to _species_ name
(which is the `matchable_name`.  Where the `matchable_name` is an
infraspecific name, sometimes Hulten provides synonyms for the
species. These are included, but behind `;SPSYN`, as
comments. Information for a synonym that is not part of a standard
name and authority are included behind `;`. All text after `;` will
not be parsed. On 2021-04-21 I checked for any synonyms of the form
`Genus species Author (var.|subsp.) infra ...` and removed the species
`Author`.
   
The following blocks more-or-less reflect the paragraph structure in
H., but H. was not 100% strict, and occasionally combined two sections
in one, or reverse the order.

**Block 3**: Description

**Block 4**: Ecology notes. And “Described from...” which ususally in
H. occurs in the same paragraph.

**Block 5**: Taxonomy notes

**Block 6**: Cultural/usage notes

----


2020-02-07: To save time, I stopped giving the full original name for
subspecies with the authorship for the species. Also stopped making
initial letters of specific epithets into lowercase. Can be fixed with
software.

2020-02-12: Realized that where H gives ‘S. sp Auth. subsp. s’ and
there is another subsp. ‘y’, he is just being strict by creating a
subsp. s with no auth. But to match these, they should be just ‘S. sp
Auth.’ : 035 1; 025 1; 027 1; 028 2; 049 1; 090 1; 094 2; 094 3; 107
2; 111 2; 112 1; 117 1; 129 2; 129 3; 149 3; 153 1; 174 2; 185 2; 187
1; 188 2; 188 3; 193 2; 194 1; 195 2; 201 1

## Fixing

      $ hulten2info       367
      $ hulten2info --tes 367
      
If the illutration causes the incorrect parsing:

 1. Edit the page in gimp. Ctrl-R to select, Shft-B to paint selection white
    Overwrite
 2. `$ hulten2info --nop 367`
 3. Check
 4. `$ hulten2info --pgo 367`
 5. In GThumb, crop the image that caused the fail, and Save As the now missing
    Image
 6. `$ hulten2info --tes 367`
 
 
## Pages

 * 45: white out illustr in 045.tiff, run --mod -> OK, run --extract,
   manually select image
 * 49
 
