<%@ WebHandler Language="VB" Class="Handler" %>
Imports System
Imports System.Web
Imports System.Data.SqlClient
Imports System.Configuration
Imports System.Text
Public Class Handler : Implements IHttpHandler
  Public Sub ProcessRequest(ByVal context As HttpContext) _
  Implements IHttpHandler.ProcessRequest
    'Declare the global script variables
    Dim Output As String = "" 'The JavaScript response sent back to the Map API
    Dim MapType As String = context.Request.Params("maptype") 'API to use (VE/GM)
    'Declare the variables used to create each feature
    Dim WKT As String = "" 'The WKT representation provided by the stored proc
    Dim VEGM As String = "" 'The VE/GMaps equivalent representation
    Dim Shape As String = "" 'The unique name of each shape
    Dim ShapeTitle As String = "" 'The title to display for each shape
    Dim ShapeDescription As String = "" 'The description attached to the shape
    Dim id As Integer = 0 'Shape counter
    Dim LineStyle As String = "" 'The line style
    Dim FillStyle As String = "" 'The fill style
    'Set up a connection to SQL server
    Dim myConn As SqlConnection = New SqlConnection("server=ENTERYOURSERVERNAMEHERE;" & _
      "Trusted_Connection=yes;" & _
      "database=Spatial")
    'Open the connection
    myConn.Open()
    'Define the stored procedure to execute
    Dim myQuery As String = "dbo.uspAirportLocator"
    Dim myCMD As New SqlCommand(myQuery, myConn)
    myCMD.CommandType = Data.CommandType.StoredProcedure
    'Send the point the user clicked on to the stored proc
    myCMD.Parameters.Add("@Latitude", Data.SqlDbType.Float)
    myCMD.Parameters("@Latitude").Value = context.Request.Params("lat")
    myCMD.Parameters.Add("@Longitude", Data.SqlDbType.Float)
    myCMD.Parameters("@Longitude").Value = context.Request.Params("long")
    'Create a reader for the result set
    Dim myReader As SqlDataReader = myCMD.ExecuteReader()
    'Go through the results
    While myReader.Read()
      'Set a unique variable name for this shape
      Shape = "shape" + id.ToString
      'Set the title for the shape
      ShapeTitle = myReader("Title").ToString
      'Set the description for the shape
      ShapeDescription = myReader("Description").ToString
      'Set the appropriate styling options for each shape
      Select Case MapType
        Case "GM"
          'Set the color and opacity for fills
          FillStyle = """#0000ff"", 0.5"
          'Set the color, weight, and opacity for lines
          LineStyle = """#ffffff"", 2, 0.7"
        Case "VE"
          'Set the color and opacity for fills
          FillStyle = "new VEColor(0, 0, 255, 0.5)"
          'Set the color and opacity for lines
          LineStyle = "new VEColor(255, 255, 255, 0.7)"
      End Select
      'Convert from WKT to the relevant API constructor for the type of geometry
      Select Case myReader("GeometryType").ToString
        Case "Point"
          'Get the WKT representation of the object
          WKT = myReader("WKT").ToString
          'Replace the double brackets that surround the coordinate point pair
          WKT = Replace(WKT, "POINT (", "")
          'Remove the closing double brackets
          WKT = Replace(WKT, ")", "")
          'Build the appropriate Pushpin/GMarker object from the coordinates
          VEGM = ""
          Dim Coords() As String = Split(Trim(WKT), " ")
          If (MapType = "GM") Then
            VEGM = VEGM + "new google.maps.LatLng(" + Coords(1) + "," + Coords(0) + ")"
            Output += "var " + Shape + "=new google.maps.Marker(" + VEGM + ");"
          ElseIf (MapType = "VE") Then
            VEGM = VEGM + "new VELatLong(" + Coords(1) + "," + Coords(0) + ")"
            Output += "var " + Shape + _
            "=new VEShape(VEShapeType.Pushpin, " + VEGM + ");"
          End If
          'Display descriptive airport information when mouse hovers over point
          Select Case MapType
            Case "GM"
              'Display the shape title and description in an InfoWindow
              Output += "google.maps.Event.addListener(" + Shape + _
              ", ""mouseover"", function() {" + Shape + ".openInfoWindowHtml(""" + _
              ShapeTitle + "<br/>" + ShapeDescription + """);" + "});"
            Case "VE"
              'Set the shape title
              Output += Shape + ".SetTitle('" + ShapeTitle + "');"
              'Set the shape description
              Output += Shape + ".SetDescription('" + ShapeDescription + "');"
          End Select
        Case "Polygon"
          'Get the WKT representation of the object
          WKT = myReader("WKT").ToString
          'Replace the double brackets that surround the coordinate point pairs
          WKT = Replace(WKT, "POLYGON ((", "")
          'Remove the closing double brackets
          WKT = Replace(WKT, "))", "")
          'Create an array of each point in the Polygon
          Dim PointArray() As String = Split(WKT, ",")
          'Build the appropriate VE/GMaps Polygon object from the coordinates
          VEGM = ""
          Dim i As Integer = 0
          While i <= PointArray.Length - 1
            Dim Coords() As String = Split(Trim(PointArray(i)), " ")
            If (MapType = "GM") Then
              VEGM = VEGM + "new google.maps.LatLng(" + Coords(1) + "," + Coords(0) + "),"
            ElseIf (MapType = "VE") Then
              VEGM = VEGM + "new VELatLong(" + Coords(1) + "," + Coords(0) + "),"
            End If
            i = i + 1
          End While
          'Remove the last trailing comma
          VEGM = Left(VEGM, VEGM.Length - 1)
          'Add the constructor for the Polygon, and apply styling options
          If (MapType = "GM") Then
            Output += "var " + Shape + _
            "=new google.maps.Polygon([" + VEGM + "], " + _
            LineStyle + ", " + FillStyle + ");"
          ElseIf (MapType = "VE") Then
            Output += "var " + Shape + _
            "=new VEShape(VEShapeType.Polygon, [" + VEGM + "]);"
            Output += Shape + ".SetLineColor(" + LineStyle + ");"
            Output += Shape + ".SetFillColor(" + FillStyle + ");"
            Output += Shape + ".HideIcon();"
          End If
      End Select
      'Add the shape to the map
      Select Case MapType
        Case "GM"
          Output += "map.addOverlay(" + Shape + ");"
        Case "VE"
          Output += "map.AddShape(" + Shape + ");"
      End Select
      'Increment the shape counter
      id = id + 1
    End While
    'Close the reader
    myReader.Close()
    'Close the connection
    myConn.Close()
    'Tell the browser to handle the response as JavaScript
    context.Response.ContentType = "text/JavaScript"
    'Do not cache the results, so always load new data
    context.Response.CacheControl = "no-cache"
    'Make the response expire immediately
    context.Response.Expires = -1
    'Return the constructed JavaScript
    context.Response.Write(Output)
  End Sub
  ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
    Get
      Return False
    End Get
  End Property
End Class