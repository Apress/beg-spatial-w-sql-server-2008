<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Text;

public class Handler : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
      //Declare the global script variables
      string Output = "";
      //The JavaScript response sent back to the Map API
      string MapType = context.Request.Params["maptype"];
      //API to use (VE/GM)
      //Declare the variables used to create each feature
      string WKT = "";
      //The WKT representation provided by the stored proc
      string VEGM = "";
      //The VE/GMaps equivalent representation
      string Shape = "";
      //The unique name of each shape
      string ShapeTitle = "";
      //The title to display for each shape
      string ShapeDescription = "";
      //The description attached to the shape
      int id = 0;
      //Shape counter
      string LineStyle = "";
      //The line style
      string FillStyle = "";
      //The fill style
      //Set up a connection to SQL server
      SqlConnection myConn = new SqlConnection("server=ENTERYOURSERVERNAMEHERE;" + "Trusted_Connection=yes;" + "database=Spatial");
      //Open the connection
      myConn.Open();
      //Define the stored procedure to execute
      string myQuery = "dbo.uspAirportLocator";
      SqlCommand myCMD = new SqlCommand(myQuery, myConn);
      myCMD.CommandType = CommandType.StoredProcedure;
      //Send the point the user clicked on to the stored proc
      myCMD.Parameters.Add("@Latitude", SqlDbType.Float);
      myCMD.Parameters["@Latitude"].Value = context.Request.Params["lat"];
      myCMD.Parameters.Add("@Longitude", SqlDbType.Float);
      myCMD.Parameters["@Longitude"].Value = context.Request.Params["long"];
      //Create a reader for the result set
      SqlDataReader myReader = myCMD.ExecuteReader();
      //Go through the results
      while (myReader.Read())
      {
        //Set a unique variable name for this shape
        Shape = "shape" + id.ToString();
        //Set the title for the shape
        ShapeTitle = myReader["Title"].ToString();
        //Set the description for the shape
        ShapeDescription = myReader["Description"].ToString();
        //Set the appropriate styling options for each shape
        switch (MapType)
        {
          case "GM":
            //Set the color and opacity for fills
            FillStyle = "\"#0000ff\", 0.5";
            //Set the color, weight, and opacity for lines
            LineStyle = "\"#ffffff\", 2, 0.7";
            break;
          case "VE":
            //Set the color and opacity for fills
            FillStyle = "new VEColor(0, 0, 255, 0.5)";
            //Set the color and opacity for lines
            LineStyle = "new VEColor(255, 255, 255, 0.7)";
            break;
        }
        //Convert from WKT to the relevant API constructor for the type of geometry
        switch (myReader["GeometryType"].ToString())
        {
          case "Point":
            //Get the WKT representation of the object
            WKT = myReader["WKT"].ToString();
            //Replace the double brackets that surround the coordinate point pair
            WKT = WKT.Replace("POINT (", "");
            //Remove the closing double brackets
            WKT = WKT.Replace(")", "");
            //Build the appropriate Pushpin/GMarker object from the coordinates
            VEGM = "";
            string[] Coords = WKT.Trim().Split(new char[] {' '});
            if ((MapType == "GM"))
            {
              VEGM = VEGM + "new google.maps.LatLng(" + Coords[1] + "," + Coords[0] + ")";
              Output += "var " + Shape + "=new google.maps.Marker(" + VEGM + ");";
            }
            else if ((MapType == "VE"))
            {
              VEGM = VEGM + "new VELatLong(" + Coords[1] + "," + Coords[0] + ")";
              Output += "var " + Shape + "=new VEShape(VEShapeType.Pushpin, " + VEGM + ");";
            }

            //Display descriptive airport information when mouse hovers over point
            switch (MapType)
            {
              case "GM":
                //Display the shape title and description in an InfoWindow
                Output += "google.maps.Event.addListener(" + Shape + ", \"mouseover\", function() {" + Shape + ".openInfoWindowHtml(\"" + ShapeTitle + "<br/>" + ShapeDescription + "\");" + "});";
                break;
              case "VE":
                //Set the shape title
                Output += Shape + ".SetTitle('" + ShapeTitle + "');";
                //Set the shape description
                Output += Shape + ".SetDescription('" + ShapeDescription + "');";
                break;
            }
            break;
          case "Polygon":
            //Get the WKT representation of the object
            WKT = myReader["WKT"].ToString();
            //Replace the double brackets that surround the coordinate point pairs
            WKT = WKT.Replace("POLYGON ((", "");
            //Remove the closing double brackets
            WKT = WKT.Replace("))", "");
            //Create an array of each point in the Polygon
            string[] PointArray = WKT.Split(new char[] {','});
            //Build the appropriate VE/GMaps Polygon object from the coordinates
            VEGM = "";
            int i = 0;
            while (i <= PointArray.Length - 1)
            {
              string[] PolyCoords = PointArray[i].Trim().Split(new char[] {' '});
              if ((MapType == "GM"))
              {
                VEGM = VEGM + "new google.maps.LatLng(" + PolyCoords[1] + "," + PolyCoords[0] + "),";
              }
              else if ((MapType == "VE"))
              {
                VEGM = VEGM + "new VELatLong(" + PolyCoords[1] + "," + PolyCoords[0] + "),";
              }
              i = i + 1;
            }

            //Remove the last trailing comma
            VEGM = VEGM.Substring(0, VEGM.Length - 1);
            //Add the constructor for the Polygon, and apply styling options
            if ((MapType == "GM"))
            {
              Output += "var " + Shape + "=new google.maps.Polygon([" + VEGM + "], " + LineStyle + ", " + FillStyle + ");";
            }
            else if ((MapType == "VE"))
            {
              Output += "var " + Shape + "=new VEShape(VEShapeType.Polygon, [" + VEGM + "]);";
              Output += Shape + ".SetLineColor(" + LineStyle + ");";
              Output += Shape + ".SetFillColor(" + FillStyle + ");";
              Output += Shape + ".HideIcon();";
            }

            break;
        }
        //Add the shape to the map
        switch (MapType)
        {
          case "GM":
            Output += "map.addOverlay(" + Shape + ");";
            break;
          case "VE":
            Output += "map.AddShape(" + Shape + ");";
            break;
        }
        //Increment the shape counter
        id = id + 1;
      }
      //Close the reader
      myReader.Close();
      //Close the connection
      myConn.Close();
      //Tell the browser to handle the response as JavaScript
      context.Response.ContentType = "text/JavaScript";
      //Do not cache the results, so always load new data
      context.Response.CacheControl = "no-cache";
      //Make the response expire immediately
      context.Response.Expires = -1;
      //Return the constructed JavaScript
      context.Response.Write(Output);
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}