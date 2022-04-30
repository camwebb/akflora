
// SELECT guid,
//   (partdetail::json->>0)::json->>'bc' AS bc ,
//   REGEXP_REPLACE(imageurl,'.+','1') AS img
//   FROM flat 
//   WHERE (partdetail::json->>0)::json->>'bc' IS NOT NULL AND
//   (guid_prefix = 'UAM:Herb' OR guid_prefix = 'UAMb:Herb');

// sounds from mixkit.co
var audio_noguid = new Audio('fail.wav');
var audio_noimg  = new Audio('bleep.wav');
var audio_img    = new Audio('double.wav');

function clickPress(event) {
    var found = -1;
    var imagetext = "<br/> NO IMAGE 😐";
    var fullguid = "";
    if (event.keyCode == 13) {
        for (i = 0 ; i < bc.length; i++) {
            if (document.getElementById("box").value == bc[i]) {
                found = i
            }
        }
        if (found >= 0) {
            if (coll[found] == "c") {
                fullguid = "UAMb:Herb:" + guid[found];
            }
            else {
                fullguid = "UAM:Herb:" + guid[found];
            }
            if (img[found] == 1) {
                imagetext = "<br/> IMAGED 🙂";
            }
            document.getElementById("out").innerHTML = "Barcode: " +
                document.getElementById("box").value + "<br/>GUID → " +
                fullguid +
                imagetext;
            if (img[found] == 1) {
                audio_img.play();
            }
            else {
                audio_noimg.play();
            }                
        }
        else {
            document.getElementById("out").innerHTML = "No GUID 😦";
            audio_noguid.play();
        }
        document.getElementById("box").value = "";
        
    }
}

