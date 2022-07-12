
// sounds from mixkit.co
var audio_yes    = new Audio('double.wav');

function clickPress(event) {
    var found = -1;
    if (event.keyCode == 13) {
        for (i = 0 ; i < bc.length; i++) {
            if (document.getElementById("box").value == bc[i]) {
                found = i
            }
        }
        if (found >= 0) {
            document.getElementById("out").innerHTML = 
                document.getElementById("box").value + " → " +
                "<a target=\"_blank\" " +
                "href=\"https://arctos.database.museum/guid/"
                + guid[found] + "\">" + guid[found] + "</a>" ;
            audio_yes.play();
        }
        else {
            document.getElementById("out").innerHTML = "Barcode not found 😦" ;
        }
        document.getElementById("box").value = "";
        
    }
}

