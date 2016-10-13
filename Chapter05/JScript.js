/**
* Declare the Global Variables
*/
var map = null; // the map object             
var shape = null; // the current shape
var shapeType = null; // the type of the VE shape being created
var shapePoints = new Array(); // the array of points in the shape

function initialiseMap() {
  // Create a new map instance
  map = new VEMap('myMap');
  // Define the parameters for the map
  map.LoadMap(new VELatLong(51.5, -0.1), 5, VEMapStyle.Road, false);
  // Attach an event handler when you move the mouse across the map
  map.AttachEvent("onmousemove", DisplayCoords);
}

function DisplayCoords(e) {
  // Retrieve the pixel position of the cursor
  var pix = new VEPixel(e.mapX, e.mapY);
  // Convert the pixel location to latitude / longitude
  var pos = map.PixelToLatLong(pix);
  // Update the page to display current cursor latitude / longitude
  document.getElementById("Latitude").value = pos.Latitude;
  document.getElementById("Longitude").value = pos.Longitude;
}

function createGeometry(shapetype) {
  // Store the type of VEShape we are defining in the global shapeType variable
  shapeType = shapetype;
  // Set the length of the shapePoints array to zero
  shapePoints.length = 0;
  // Attach the addPoint() function to be called every time we click the mouse
  map.AttachEvent("onclick", addPoint);
  // Change the mouse cursor to show we are adding points
  document.getElementById("myMap").childNodes[0].style.cursor = "crosshair";
}

function addPoint(e) {
  // Retrieve the pixel position that we clicked
  var pix = new VEPixel(e.mapX, e.mapY);
  // Convert pixel co-ordinates to Latitude and Longitude
  var pos = map.PixelToLatLong(pix);
  // Add these co-ordinates to the array of points for the current shape 
  shapePoints[shapePoints.length] = pos;
  // Handle different geometries 
  switch (shapeType) {
    // We are drawing a VE Pushpin (i.e. a Point)  
    case VEShapeType.Pushpin:
      // Create a new Pushpin VEShape based on the point defined
      shape = new VEShape(VEShapeType.Pushpin, shapePoints);
      // Add the pushpin to the map
      map.AddShape(shape);
      break;
    // We are defining a LineString or a Polygon 
    case VEShapeType.Polyline:
    case VEShapeType.Polygon:
      // If we have only defined two points for the shape
      if (shapePoints.length == 2) {
        // Create a new Polyline VEShape based on the points defined
        shape = new VEShape(VEShapeType.Polyline, shapePoints);
        // Add the polyline to the map
        map.AddShape(shape);
      }
      // If we have defined more than two points for the shape
      if (shapePoints.length > 2) {
        // Delete the old shape from the map
        map.DeleteShape(shape);
        // Create a new Polyline or Polygon VEShape based on the points defined
        shape = new VEShape(shapeType, shapePoints);
        // Add the shape to the map
        map.AddShape(shape);
      }
      break;
    // If shapeType is any other value    
    default:
      // Stop calling the addPoint() function on every mouseclick
      map.DetachEvent("onclick", addPoint);
      // Throw an error
      throw ("Unexpected shape type");
  }

  // When we have finished the shape definition
  if (shapeType == VEShapeType.Pushpin || e.rightMouseButton == true) {
    // Stop calling the addPoint() function on every mouseclick
    map.DetachEvent("onclick", addPoint);
    // Change the mouse cursor back to normal
    document.getElementById("myMap").childNodes[0].style.cursor = "";
    // Create the WKT representation of this shape
    var WKT = makeWKT(map.GetShapeByID(shape.GetID()))
    // Put the WKT Output on the page
    document.getElementById('WKTOutput').innerText = WKT.toString();
  }
}

function makeWKT(shape) {
  // Define a variable to hold what type of WKT shape we are creating
  var wktShapeType = "";
  // Define the WKT type which corresponds to the VEShapeType we have created
  switch (shape.GetType()) {
    // VEShapeType.Pushpin => WKT POINT 
    case VEShapeType.Pushpin:
      wktShapeType = 'POINT';
      break;
    // VEShapeType.Polyline => WKT LINESTRING 
    case VEShapeType.Polyline:
      wktShapeType = 'LINESTRING';
      break;
    // VEShapeType.Polygon => WKT POLYGON 
    case VEShapeType.Polygon:
      wktShapeType = 'POLYGON';
      break;
    default:
      throw ("Unexpected shape type");
  }
  // Define a new string to hold the point list
  var pointsString = ""
  // Retrieve an array of points that make up this shape
  var points = shape.GetPoints();
  // Retrieve the co-ordinates of the first point
  pointsString = points[0].Longitude + " " + points[0].Latitude;
  // Loop through remaining points in the object definition
  for (var i = 1; i < points.length; i++) {
    // Append the remaining points, with a comma before each co-ordinate pair
    pointsString += ", " + points[i].Longitude + " " + points[i].Latitude;
  }
  // Build the WKT representation of the shape. 
  var WKT = null
  if (wktShapeType == 'POLYGON')
  // Polygons require double brackets around the points of the exterior ring
    WKT = wktShapeType + "((" + pointsString + "))";
  else
  // Other WKT geometry types have single brackets
    WKT = wktShapeType + "(" + pointsString + ")";
  // Return the final WKT representation
  return WKT;
}

function StartAgain() {
  // Delete all shapes from the map
  map.DeleteAllShapes();
  // Reset the cursor to default style
  document.getElementById('myMap').childNodes[0].style.cursor = "";
  // Reset the text
  document.getElementById('WKTOutput').innerText = 'The WKT representation of the geometry will appear here.';
} 
