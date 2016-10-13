/**
 * Beginning Spatial with SQL Server 2008 (Apress)
 * Alastair Aitchison
 *
 * Chapter Eight : Syndication
 */

-- Create the table
CREATE TABLE PropertiesForSale (
  id int,
  address varchar(255),
  location geography,
  price money,
  description varchar(max),
  listdate datetime
)
GO


-- Insert sample data
INSERT INTO PropertiesForSale VALUES
(1,
'Pilgrims Way, Chew Stoke, Somerset',
geography::Point(51.354940,-2.635765,4326),
750000,
'Grade II Listed former Rectory, with magnificent architectural features and stunning gardens.',
'2008-08-01 17:00:00'
),
(2,
'Moulsford, Wallingford, Oxfordshire',
geography::Point(51.549963,-1.149013,4326),
1650000,
'Situated on the River Thames, this period house features landscaped gardens extending up to 240ft, and private mooring.',
'2008-07-25 14:30:00'
),
(3,
'Pantings Lane, Highclere, Newbury',
geography::Point(51.347206,-1.375828,4326),
965000,
'A newly developed 5-bedroom house on the edge of Highclere, with very high build specifications used throughout.',
'2008-07-25 12:00:00'
)
GO


-- Create stored procedure to generate GeoRSS
CREATE PROCEDURE [dbo].[uspGeoRSSFeeder]
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

-- Declare an XML variable to hold the GeoRSS output
DECLARE @GeoRSS xml;

/**
 * Create the elements of the feed using SELECT … FOR XML and AsGml()
**/
WITH XMLNAMESPACES (
  'http://www.opengis.net/gml' AS gml,
  'http://www.georss.org/georss' AS georss
)
SELECT @GeoRSS =
  (SELECT
    [address] AS title,
    [description] + ' £' + CAST([price] AS varchar(32)) AS description,
    'http://www.beginningspatial.com/' + CAST([id] AS varchar(8)) AS link,
    LEFT(DATENAME(dw, [listdate]),3) + ', '
    + STUFF(CONVERT(nvarchar,[listdate],113),21,4,' GMT') AS pubDate,
    location.AsGml() AS [georss:where]
  FROM
    PropertiesForSale
  FOR XML PATH('item'), ROOT('channel')
)

/**
 * Style the results using XQuery
 **/
SELECT @GeoRSS.query('
<rss version="2.0"
  xmlns:georss="http://www.georss.org/georss"
  xmlns:gml="http://www.opengis.net/gml">
<channel>
  <title>SQL Server GeoRSS Feed</title>
  <description>This feed contains information about some fictional properties for 
sale in order to demonstrate how to syndicate spatial data using the GeoRSS format. 
</description>
  <link>http://www.beginningspatial.com</link>
  {
    for $e in channel/item
    return
    <item>
    <title> { $e/title/text() }</title>
    <description> { $e/description/text() }</description>
    <link> { $e/link/text() }</link>
    <pubDate>  { $e/pubDate/text() }</pubDate>
    <georss:where>
      {
        for $child in $e/georss:where/*
        return
        if (fn:local-name($child) = "Point") then  <gml:Point> { $child/* } </gml:Point>
        else  if (fn:local-name($child) = "LineString") then  <gml:LineString> { $child/* } </gml:LineString>
        else  if (fn:local-name($child) = "Polygon") then  <gml:Polygon> { $child/* } </gml:Polygon>
        else  if (fn:local-name($child) = "MultiPoint") then  <gml:MultiPoint> { $child/* } </gml:MultiPoint>
        else  if (fn:local-name($child) = "MultiCurve") then  <gml:MultiCurve> { $child/* } </gml:MultiCurve>
        else  if (fn:local-name($child) = "MultiSurface") then  <gml:MultiSurface> { $child/* } </gml:MultiSurface>
        else  if (fn:local-name($child) = "MultiGeometry") then  <gml:MultiGeometry> { $child/* } </gml:MultiGeometry>
        else  ()
      }
    </georss:where>
  </item>
  }
</channel>
</rss>
') AS GeoRSSFeed
END
GO