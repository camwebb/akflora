
// SELECT guid,
//     (partdetail::json->>0)::json->>'bc' AS bc ,
//     REGEXP_REPLACE(imageurl,'.+','1') AS img ,
//     CASE 
//       WHEN othercatalognumbers ~ 'ALAAC'
//       THEN REGEXP_REPLACE(othercatalognumbers,'^.*ALAAC ([ABLV]?[0-9]+).*$', '\1')
//     ELSE NULL 
//     END
//  AS alaac
//  FROM flat 
//    WHERE (partdetail::json->>0)::json->>'bc' IS NOT NULL AND
// guid ~ 'UAMb?:(Herb|Alg)' ;

// sounds from mixkit.co
var audio_noguid = new Audio('fail.wav');
var audio_noimg  = new Audio('bleep.wav');
var audio_img    = new Audio('double.wav');

function clickPress(event) {
    var found = -1;
    var imagetext = "<br/> NO IMAGE 😐";
    var alaactext ;
    var c = "";
    if (event.keyCode == 13) {
        for (i = 0 ; i < bc.length; i++) {
            if (document.getElementById("box").value == bc[i]) {
                found = i
            }
        }
        if (found >= 0) {
            if (coll[found] == "c") { c = "b" }
            if (img[found] == 1) {
                imagetext = "<br/> IMAGED 🙂";
            }
            if (alaac[found] != "") {
                alaactext =  "<br/> ALAAC = " + alaac[found] ;
            }
            document.getElementById("out").innerHTML = 
                document.getElementById("box").value + " → " +
                "<a target=\"_blank\" " +
                "href=\"https://arctos.database.museum/guid/UAM" +
                c + ":Herb:" + guid[found] + "\">" +
                "UAM" + c + ":Herb:" + guid[found] + "</a>" +
                alaactext +
                imagetext;
            if (img[found] == 1) {
                audio_img.play();
            }
            else {
                audio_noimg.play();
            }                
        }
        else {
            document.getElementById("out").innerHTML = "GUID not found 😦" ;
                //+ "<br/>" + "<form action=\"https://arctos.database.museum/" +
                //"SpecimenResults.cfm\" method=\"post\" target=\"_blank\">" +
                //"<input type=\"hidden\" name=\"OIDType\" value=\"ALAAC\"/>" +
                //"<input type=\"hidden\" name=\"oidOper\" value=\"IS\"/>" +
                //"<span style=\"font-size: 15px;\">Search by ALAAC: " +
                //"<input type=\"text\" name=\"OIDNum\" size=\"10\"/> " +
                //"<input type=\"submit\" value=\"Search\"/></span></form>" ;
            audio_noguid.play();
        }
        document.getElementById("box").value = "";
        
    }
}

