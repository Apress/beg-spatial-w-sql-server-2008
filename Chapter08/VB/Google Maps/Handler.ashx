<%@ WebHandler Language="VB" Class="Handler" %>

Imports System
Imports System.Web
Imports System.Data.SqlClient
Imports System.Configuration
Imports System.Text

Public Class Handler : Implements IHttpHandler

  Public Sub ProcessRequest(ByVal context As HttpContext) _
  Implements IHttpHandler.ProcessRequest

    'Set the response headers
    context.Response.ContentType = "text/xml"
    context.Response.Charset = "iso-8859-1"
    context.Response.CacheControl = "no-cache"
    context.Response.Expires = 0

    'Define the connection to the database
    Dim myConn As SqlConnection = New SqlConnection( _
      "server=ENTERYOURSERVERNAMEHERE;" & _
      "Trusted_Connection=yes;" & _
      "database=Spatial")

    'Open the connection
    myConn.Open()

    'Define the query to execute
    Dim myQuery As String = "exec dbo.uspGeoRSSFeeder"

    'Set the query to run against the connection
    Dim myCMD As New SqlCommand(myQuery, myConn)

    'Create a reader for the results
    Dim myReader As SqlDataReader = myCMD.ExecuteReader()

    'Read through the results
    While myReader.Read()

      'Write the GeoRSS response back to the client
      context.Response.Write(myReader("GeoRSSFeed").ToString)

    End While

    'Close the reader
    myReader.Close()

    'Close the connection
    myConn.Close()

  End Sub

  Public ReadOnly Property IsReusable() As Boolean _
  Implements IHttpHandler.IsReusable
    Get
      Return False
    End Get
  End Property

End Class
