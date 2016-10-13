// Importt references for generic .NET functionality
using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Net;

// Import the web reference to the MapPoint Web Service
using Geocoder.MapPoint;

namespace Geocoder
{
public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction()]
    public static SqlString geocode(
        SqlString AddressLine,
        SqlString PrimaryCity,
        SqlString Subdivision,
        SqlString PostalCode,
        SqlString CountryRegion)
    {
        // Initialize the MapPoint Find service
        FindServiceSoap findService = new FindServiceSoap();

        // Provide the logon credentials
        string UserName = "ENTER YOUR ACCOUNT ID HERE";
        string Password = "ENTER YOUR PASSWORD HERE";
        findService.Credentials = new NetworkCredential(UserName, Password);

        // FindAddressSpecification contains the details passed to the Find service
        FindAddressSpecification findAddressSpec = new FindAddressSpecification();
        // Build a new address object from the parameters provided to the function
        Address address = new Address();
        address.AddressLine = AddressLine.ToString();
        address.PrimaryCity = PrimaryCity.ToString();
        address.Subdivision = Subdivision.ToString();
        address.PostalCode = PostalCode.ToString();
        address.CountryRegion = CountryRegion.ToString();
        // Add the address to search for to the specification
        findAddressSpec.InputAddress = address;
        // Specify the data source in which to search for the address
        findAddressSpec.DataSourceName = "MapPoint.NA";

        // Create the options to limit the result set
        FindOptions findOptions = new FindOptions();
        // Filter the results to only show LatLong information
        findOptions.ResultMask = FindResultMask.LatLongFlag;
        // Only return the first matching result
        FindRange findRange = new FindRange();
        findRange.StartIndex = 0;findRange.Count = 1;
        findOptions.Range = findRange;
        // Apply the options to the specification
        findAddressSpec.Options = findOptions;

        // Call the MapPoint Web Service and retrieve the results
        FindResults findResults;findResults = findService.FindAddress(findAddressSpec);

        // Create the WKT representation of the geocoded result
        SqlString WKT = new SqlString();
        if (findResults.Results.Length > 0)
        {
            WKT = "POINT(" +
                findResults.Results[0].FoundLocation.LatLong.Longitude + " " +
                findResults.Results[0].FoundLocation.LatLong.Latitude + ")";
        }
        else
        {
            WKT = "POINT EMPTY";
        }

        // Return the result to SQL Server
        return WKT;
    }
}
}