// Declare the global map object
var map = null;

// Set the Load callback
if (window.addEventListener) { window.addEventListener("load", getMap, false); }
else if (window.attachEvent) { window.attachEvent("onload", getMap); }

// Set the unLoad callback
if (window.addEventListener) { window.addEventListener("unload", disposeMap, false); }
else if (window.attachEvent) { window.attachEvent("onunload", disposeMap); }

// This function is called when the page has been loaded
function getMap() {

  // Create a new map object in the divMap container
  map = new VEMap('divMap');

  // Configure the initial map view
  map.LoadMap(new VELatLong(34, -118), 8, VEMapStyle.Road);

  // Call the loadAirportData function when the user clicks the map
  map.AttachEvent("onclick", loadAirportData);
}

// This function creates a cross-browser AJAX object
function GetXmlHttp() {
  var xmlHttp;
  try { xmlHttp = new XMLHttpRequest(); } // Firefox, Opera 8.0+, Safari
  catch (e) {
    try { xmlHttp = new ActiveXObject("Msxml2.XMLHTTP"); } // IE 6.0+
    catch (e) {
      try { xmlHttp = new ActiveXObject("Microsoft.XMLHTTP"); } // Older IE
      catch (e) {
        alert("Your browser does not support AJAX!");
        return false;
      }
    }
  }
  return xmlHttp;
}




function loadAirportData(e) {

  // Clear the map
  map.DeleteAllShapes();

  // Convert the cursor location to latitude / longitude
  var pos = map.PixelToLatLong(new VEPixel(e.mapX, e.mapY));

  //Get the appropriate XMLHTTP object for the browser
  var xmlhttp = GetXmlHttp();

  // If we have a valid XMLHTTP object
  if (xmlhttp) {
    // Define the url of the handler
    var url = "./Handler.ashx";
    // Build the parameters that must be passed
    var params = "lat=" + pos.Latitude + "&long=" + pos.Longitude + "&maptype=VE";
    // Open the XmlHTTP request
    xmlhttp.open("GET", url + '?' + params, true);
    // Fire this when the readyState of the request changes
    xmlhttp.onreadystatechange = function() {
      // readystate 4 indicates that the request is complete  
      if (xmlhttp.readyState == 4) {
        // Read in the JavaScript response from the handler
        var result = xmlhttp.responseText;
        // Update the status message
        window.status = 'Loading Data...';
        try {
          // Execute the dynamically created JavaScript
          eval(result);
          // Update the status message
          window.status = 'Data Loaded!';
        }
        catch (e) {
          // If the response cannot be evaluated
          window.status = 'Data could not be loaded.';
        }
      }
    }
    // Send the XMLHttp Request
    xmlhttp.send(null);
  }
}

// This function is called when the page is unloaded
function disposeMap() {

  // Release all resources assigned to the map
  map.Dispose();

  // Unset the map variable
  map = null;
}
