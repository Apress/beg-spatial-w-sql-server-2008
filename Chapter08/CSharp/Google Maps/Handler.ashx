<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;
using System.Text;

public class Handler : IHttpHandler
{

  public void ProcessRequest(HttpContext context)
  {
    // Set the response headers
    context.Response.ContentType = "text/xml";
    context.Response.Charset = "iso-8859-1";
    context.Response.CacheControl = "no-cache";
    context.Response.Expires = 0;

    // Define a connection to the database
    SqlConnection myConn = new SqlConnection(
      @"server=ENTERYOURSERVERNAMEHERE;
      Trusted_Connection=yes;
      database=Spatial");

    // Open the connection
    myConn.Open();
    
    // Define the query to execute
    string myQuery = "exec dbo.uspGeoRSSFeeder";

    // Set the query to run against the connection
    SqlCommand myCMD = new SqlCommand(myQuery, myConn);

    // Create a reader for the results
    SqlDataReader myReader = myCMD.ExecuteReader();

    // Read through the results
    while (myReader.Read())
    {
      // Write the GeoRSS response back to the client
      context.Response.Write(myReader["GeoRSSFeed"].ToString());
    }

    // Close the reader
    myReader.Close();

    // Close the connection
    myConn.Close();
  }

  public bool IsReusable
  {
    get { return false; }
  }
}
