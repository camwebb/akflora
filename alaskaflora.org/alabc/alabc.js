
// For SQL see: dir 2023-11-16_upgrade_alabc

// sounds from mixkit.co
var audio_noguid = new Audio('fail.wav');
var audio_noimg  = new Audio('bleep.wav');
var audio_img    = new Audio('double.wav');

function clickPress(event) {
    var found = -1;
    var c = "UAM:Herb:";
    var face ;

    if (event.keyCode == 13) {
        for (i = 0 ; i < bc.length; i++) {
            if (document.getElementById("box").value == bc[i]) {
                found = i ;
                break ;
            }
        }
        // if barcode found
        if (found >= 0) {
            if (coll[found] == "c")      { c = "UAMb:Herb:" }
            else if (coll[found] == "a") { c = "UAM:Alg:"   }

            // summary face
            if ((ndng[found] > 0) &&
                (njpg[found] > 0) &&
                (collinfo[found] == 1) && 
                (locninfo[found] == 1) && 
                (georefinfo[found] == 1)) { face = "🙂" }
            else                          { face = "😐" }

            document.getElementById("out").innerHTML =
                "<table>" +
                "<tr><td style=\"min-width:400px;\">Barcode</td><td>" +
                document.getElementById("box").value + "</td></tr>" +
                "<tr><td>GUID</td><td>" +
                "<a target=\"_blank\" " +
                "href=\"https://arctos.database.museum/guid/" +
                c + guid[found] + "\">" +
                c + guid[found] + "</a>" + "</td></tr>" + 
                "<tr><td>ALAAC</td><td>" + alaac[found] + "</td></tr>" +
                "<tr><td><hr/></td><td><hr/></td></tr>" +
                "<tr><td>DNGs</td><td>" + ndng[found] + "</td></tr>" +
                "<tr><td>JPGs</td><td>" + njpg[found] + "</td></tr>" +
                "<tr><td><hr/></td><td><hr/></td></tr>" +
                "<tr><td>Collector info</td><td>" + collinfo[found] +
                "</td></tr>" +
                "<tr><td>Specific locality</td><td>" + locninfo[found] +
                "</td></tr>" +
                "<tr><td>Georef?</td><td>" + georefinfo[found] +
                "</td></tr>" +
                "<tr><td></td><td>" + face + "</td></tr>" +
                "</table>" ;

            // sound for all data 
            if ((ndng[found] > 0) &&
                (njpg[found] > 0) &&
                (collinfo[found] == 1) && 
                (locninfo[found] == 1) && 
                (georefinfo[found] == 1)) {
                audio_img.play();
            }
            else {
                audio_noimg.play();
            }                
        }
        else {
            document.getElementById("out").innerHTML = "Barcode not found 😦" 
                + "<br/>" + "<a href=\"https://arctos.database.museum/"+
                "search.cfm\" target=\"_blank\">Search Arctos for ALAAC</a>" ;
            audio_noguid.play();
        }
        document.getElementById("box").value = "";
        
    }
}

