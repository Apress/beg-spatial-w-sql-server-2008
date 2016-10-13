'Import references for generic .NET functionality
Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Data.SqlTypes
Imports Microsoft.SqlServer.Server
Imports System.Net
'Import the web reference to the MapPoint Web Service
Imports Geocoder.MapPoint

Partial Public Class UserDefinedFunctions
    <Microsoft.SqlServer.Server.SqlFunction()> _
    Public Shared Function geocode( _
    ByVal AddressLine As SqlString, _
    ByVal PrimaryCity As SqlString, _
    ByVal Subdivision As SqlString, _
    ByVal PostalCode As SqlString, _
    ByVal CountryRegion As SqlString) As SqlString

        'Initialize the MapPoint Find service
        Dim findService As New FindServiceSoap

        'Provide the logon credentials
        Dim UserName As String = "ENTER YOUR ACCOUNT ID HERE"
        Dim Password As String = "ENTER YOUR PASSWORD HERE"
        findService.Credentials = New Net.NetworkCredential(UserName, Password)

        'FindAddressSpecification contains the details passed to the Find service
        Dim findAddressSpec As New FindAddressSpecification
        'Build a new address object from the parameters provided to the function
        Dim address As New Address
        address.AddressLine = AddressLine.ToString
        Address.PrimaryCity = PrimaryCity.ToString
        Address.Subdivision = Subdivision.ToString
        Address.PostalCode = PostalCode.ToString
        Address.CountryRegion = CountryRegion.ToString
        findAddressSpec.InputAddress = Address
        'Specify the data source in which to search for the address
        findAddressSpec.DataSourceName = "MapPoint.NA"

        'Create the options to limit the result set
        Dim findOptions As New FindOptions
        'Filter the results to only show LatLong information
        findOptions.ResultMask = FindResultMask.LatLongFlag
        'Only return the first matching result
        Dim findRange As New FindRange
        findRange.StartIndex = 0
        FindRange.Count = 1
        findOptions.Range = FindRange
        'Apply the options to the specification
        findAddressSpec.Options = findOptions

        'Call the MapPoint Web Service and retrieve the results
        Dim findResults As FindResults
        findResults = findService.FindAddress(findAddressSpec)
        'Create the WKT representation of the geocoded result
        Dim WKT As New SqlString
        If findResults.Results.Length > 0 Then
            WKT = "POINT(" & _
            findResults.Results(0).FoundLocation.LatLong.Longitude & " " & _
            findResults.Results(0).FoundLocation.LatLong.Latitude & ")"
        Else
            WKT = "POINT EMPTY"
        End If

        'Return the result to SQL Server
        Return WKT

    End Function
End Class