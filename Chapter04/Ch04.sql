/**
 * Beginning Spatial with SQL Server 2008 (Apress)
 * Alastair Aitchison
 *
 * Chapter Four : Creating Spatial Data
 */

-- Creating a geography Point from WKT
DECLARE @Edinburgh geography 
SET @Edinburgh = geography::STPointFromText('POINT(-3.19 55.95)', 4326)


-- Creating a geometry Point from WKT
DECLARE @Point geometry 
SET @Point = geometry::STPointFromText('POINT(258647 665289)', 27700)


-- Creating a LineString from WKT
DECLARE @SydneyHarbourBridge geography
SET @SydneyHarbourBridge = 
  geography::STLineFromText(
    'LINESTRING(
      151.209 -33.855,
      151.212 -33.850
    )',
    4326
  )


-- Creating a Polygon from WKT
SELECT 
geography::STPolyFromText(
  'POLYGON(
  (
    -77.0532238483429 38.870863029297695,
    -77.05468297004701 38.87304314667469,
    -77.05788016319276 38.872800914712734,
    -77.05849170684814 38.870219840133124,
    -77.05556273460388 38.8690670969385,
    -77.0532238483429 38.870863029297695
    ),
   (
    -77.05582022666931 38.8702866652523,
    -77.0569360256195 38.870737733163644,
    -77.05673217773439 38.87170668418343,
    -77.0554769039154 38.871848684516294,
    -77.05491900444031 38.87097997215688,
    -77.05582022666931 38.8702866652523
    )
  )',
 4326
)

-- Creating a MultiPoint from WKT
DECLARE @Pyramids geometry
SET @Pyramids = 
  geometry::STMPointFromText(
    'MULTIPOINT(783718 3447847, 784048 3448284, 783348 3447613)',
    32635
)


-- Creating a MultiLineString from WKT
DECLARE @MultiLineString geometry
SET @MultiLineString = 
geometry::STMLineFromText(
  'MULTILINESTRING((10 20, 3 4, 43 42),(44 10, 20 40))',
  20539
)


-- Creating a MultiPolygon from WKT
DECLARE @MultiPolygon geometry
SET @MultiPolygon = 
geometry::STMPolyFromText(
  'MULTIPOLYGON(((10 20, 30 40, 44 50, 10 20)),((5 0, 20 40, 30 34, 5 0)))',
  0
)


-- Creating a GeometryCollection from WKT
DECLARE @GeometryCollection geometry;
SET @GeometryCollection = geometry::STGeomCollFromText(
 'GEOMETRYCOLLECTION(
  POLYGON((5 5, 10 5, 10 10, 5 5)),
  POINT(10 10))',
  0
)

-- Using the STGeomFromText() method to create any kind of geometry
DECLARE @myTable TABLE (
  GeographyColumn geography
)
INSERT INTO @myTable (Geographycolumn) VALUES 
  (geography::STGeomFromText('POINT(-122.34 47.65)', 4326))
INSERT INTO @myTable (Geographycolumn) VALUES 
  (geography::STGeomFromText('LINESTRING(32.51 -23.34, 33.98 -12.10)', 4326))


-- Using the Parse() method with a default SRID
DECLARE @LineString geography
SET @LineString = geography::Parse('LINESTRING(120 50, 128 52)')


-- Using STAsText() to return the WKT representation of a geometry
DECLARE @Point geometry
SET @Point = geometry::STPointFromText('POINT(30 20 10 5)', 0)
SELECT @Point.STAsText()


-- Using ToString() to return the WKT representation of a geometry
DECLARE @Point geometry
SET @Point = geometry::STPointFromText('POINT(30 20 10 5)', 0)
SELECT @Point.ToString()


-- Using AsTextZM() to return the WKT representation of a geometry
DECLARE @GeometryCollection geometry;
SET @GeometryCollection = geometry::STGeomCollFromText(
  'GEOMETRYCOLLECTION(
    LINESTRING(5 5 2 0, 10 5 2 3),
    POINT(10 10 4 3))', 
  0
)
SELECT @GeometryCollection.AsTextZM()


-- Creating a Point from WKB
DECLARE @ByteOrder bit
DECLARE @GeometryType int
DECLARE @longitude float
DECLARE @latitude float
SET @ByteOrder = 0
SET @GeometryType = 1
SET @longitude = 21.01
SET @latitude = 52.23
DECLARE @WKB varbinary(max)
SET @WKB = 
 CAST(@ByteOrder AS binary(1))
 + CAST(@GeometryType AS binary(4))
 + CAST(@longitude AS binary(8))
 + CAST(@latitude AS binary(8))
DECLARE @Point geography
SET @Point = geography::STPointFromWKB(@WKB, 4326)


-- Creating a LineString from WKB
DECLARE @ByteOrder bit
DECLARE @GeometryType int
DECLARE @NumPoints int
DECLARE @x1 float
DECLARE @y1 float
DECLARE @x2 float
DECLARE @y2 float
SET @ByteOrder = 0
SET @GeometryType = 2
SET @NumPoints = 2
SET @x1 = 16
SET @y1 = 7
SET @x2 = 23
SET @y2 = 10
DECLARE @WKB varbinary(max)
SET @WKB = 
 CAST(@ByteOrder AS binary(1))
 + CAST(@GeometryType AS binary(4))
 + CAST(@NumPoints AS binary(4))
 + CAST(@x1 AS binary(8))
 + CAST(@y1 AS binary(8))
 + CAST(@x2 AS binary(8))
 + CAST(@y2 AS binary(8))
DECLARE @LineString geometry
SET @LineString = geometry::STLineFromWKB(@WKB, 0)
SELECT @LineString.STAsText()

-- Creating a Polygon from WKB
DECLARE @ByteOrder bit
DECLARE @GeometryType int
DECLARE @NumRings int
DECLARE @Ext_NumPoints int
DECLARE @Ext_x1 float, @Ext_y1 float
DECLARE @Ext_x2 float, @Ext_y2 float
DECLARE @Ext_x3 float, @Ext_y3 float
DECLARE @Ext_x4 float, @Ext_y4 float
DECLARE @Int_NumPoints int
DECLARE @Int_x1 float, @Int_y1 float
DECLARE @Int_x2 float, @Int_y2 float
DECLARE @Int_x3 float, @Int_y3 float
DECLARE @Int_x4 float, @Int_y4 float
SET @ByteOrder = 0
SET @GeometryType = 3
SET @NumRings = 2
SET @Ext_NumPoints = 5
SET @Ext_x1 = -4
SET @Ext_y1 = -5
SET @Ext_x2 = -4
SET @Ext_y2 = 10
SET @Ext_x3 = 12
SET @Ext_y3 = 10
SET @Ext_x4 = 12
SET @Ext_y4 = -5
SET @Int_NumPoints = 4
SET @Int_x1 = 3
SET @Int_y1 = 1
SET @Int_x2 = 3
SET @Int_y2 = 5
SET @Int_x3 = 7
SET @Int_y3 = 3
DECLARE @WKB varbinary(max)
SET @WKB = 
 CAST(@ByteOrder AS binary(1))
 + CAST(@GeometryType AS binary(4))
 + CAST(@NumRings AS binary(4))
 + CAST(@Ext_NumPoints AS binary(4))
 + CAST(@Ext_x1 AS binary(8)) + CAST(@Ext_y1 AS binary(8))
 + CAST(@Ext_x2 AS binary(8)) + CAST(@Ext_y2 AS binary(8))
 + CAST(@Ext_x3 AS binary(8)) + CAST(@Ext_y3 AS binary(8))
 + CAST(@Ext_x4 AS binary(8)) + CAST(@Ext_y4 AS binary(8))
 + CAST(@Ext_x1 AS binary(8)) + CAST(@Ext_y1 AS binary(8))
 + CAST(@Int_NumPoints AS binary(4))
 + CAST(@Int_x1 AS binary(8)) + CAST(@Int_y1 AS binary(8))
 + CAST(@Int_x2 AS binary(8)) + CAST(@Int_y2 AS binary(8))
 + CAST(@Int_x3 AS binary(8)) + CAST(@Int_y3 AS binary(8))
 + CAST(@Int_x1 AS binary(8)) + CAST(@Int_y1 AS binary(8))
DECLARE @polygon geometry
SET @polygon = geometry::STPolyFromWKB(@WKB, 0)
SELECT @polygon.STAsText()


--Creating a Geometry Collection from WKB
SELECT geometry::STGeomCollFromWKB(
0x00000000070000000200000000014044333333333333C002888A47ECFE9B0102000000020000009BFEEC478A8802C033333333333344406666666666F65340B81E85EB51B81B40, 0)


-- Converting between WKT and WKB
DECLARE 
  @WKT varchar(255) = 'POINT(52 8)',
  @WKB varbinary(max),
  @SRID int = 0,
  @Geometry1 geometry,
  @Geometry2 geometry
SET @Geometry1 = geometry::STGeomFromText(@WKT, @SRID)
SET @WKB = @Geometry1.STAsBinary()
SET @Geometry2 = geometry::STGeomFromWKB(@WKB, @SRID)
SELECT
  @Geometry1.STAsText(),
  @Geometry2.STAsText()


-- Creating a Point from GML
DECLARE @Point geography
SET @Point = geography::GeomFromGml('
  <Point xmlns="http://www.opengis.net/gml">
    <pos>10 30</pos>
  </Point>',
4326)


-- Creating a LineString from GML
DECLARE @LineString geometry
SET @LineString = geometry::GeomFromGml('
<LineString xmlns="http://www.opengis.net/gml">
  <posList>-6 4 3 -5</posList>
</LineString>',
0)


-- Creating a Polygon from GML
DECLARE @Polygon geometry
SET @polygon = geometry::GeomFromGml('
<Polygon xmlns="http://www.opengis.net/gml">
  <exterior>
    <LinearRing>
      <posList>0 0 100 0 100 100 0 100 0 0</posList>
    </LinearRing>
  </exterior>
  <interior>
    <LinearRing>
      <posList>10 10 20 10 20 20 10 20 10 10</posList>
    </LinearRing>
  </interior>
  <interior>
    <LinearRing>
      <posList>75 10 80 10 80 20 75 20 75 10</posList>
    </LinearRing>
  </interior>
</Polygon>', 0)


-- Creating a MultiPoint from GML
DECLARE @MultiPoint geometry
SET @MultiPoint = geometry::GeomFromGml('
<MultiPoint xmlns="http://www.opengis.net/gml">
  <pointMembers>
    <Point>
      <pos>2 3</pos>
    </Point>
    <Point>
      <pos>4 10</pos>
    </Point>
  </pointMembers>
</MultiPoint>', 0)


-- Creating a MultLineString from GML
DECLARE @MultiLineString geometry
SET @MultiLineString = geometry::GeomFromGml('
<MultiCurve xmlns="http://www.opengis.net/gml">
  <curveMembers>
    <LineString>
      <posList>2 3 4 10</posList>
    </LineString>
    <LineString>
      <posList>4 10 15 40</posList>
    </LineString>
  </curveMembers>
</MultiCurve>', 0)


-- Creating a MultiPolygon from GML
DECLARE @MultiPolygon geometry
SET @MultiPolygon = geometry::GeomFromGml('
<MultiSurface xmlns="http://www.opengis.net/gml">
  <surfaceMembers>
    <Polygon>
      <exterior>
        <LinearRing>
          <posList>2 3 5 3 6 8 2 7 2 3</posList>
        </LinearRing>
      </exterior>
    </Polygon>
    <Polygon>
      <exterior>
        <LinearRing>
          <posList>10 20 20 20 20 30 10 30 10 20</posList>
        </LinearRing>
      </exterior>
    </Polygon>
  </surfaceMembers>
</MultiSurface>', 0)


-- Creating a Geometry Collection from GML
DECLARE @GeometryCollection geometry
SET @GeometryCollection = geometry::GeomFromGml('
<MultiGeometry xmlns="http://www.opengis.net/gml">
  <geometryMembers>
    <Point>
      <pos>15 10</pos>
    </Point>
    <LineString>
      <posList>4 10 2 3</posList>
    </LineString>
  </geometryMembers>
</MultiGeometry>', 0)


-- Representing an existing geometry as GML
DECLARE @Linestring geometry
SET @Linestring  = geometry::STLineFromText('LINESTRING(0 0, 12 10, 15 4)', 0)
SELECT @Linestring.AsGml()


-- Creating a point using Point()
SELECT 
geography::Point(30,2,4269)