/**
 * Beginning Spatial with SQL Server 2008 (Apress)
 * Alastair Aitchison
 *
 * Chapter Eleven : Examining Properties of Spatial Information
 */
 
-- Determing the type of a geometry using STGeometryType()
DECLARE @MexicoCity geometry
SET @MexicoCity = geometry::STGeomFromText('POINT(486321 2146238)', 32614)
SELECT 
  @MexicoCity AS Shape,
  @MexicoCity.STGeometryType() AS GeometryType


-- Counting the number of dimensions occupied by a geometry using STDimension()
DECLARE @LineString geometry
SET @LineString = geometry::STGeomFromText('LINESTRING(-120 48, -122 47)', 0)
SELECT 
  @LineString AS Shape,
  @LineString.STDimension() AS Dimension


-- Testing whether a geometry is an instance of a specific type using InstanceOf()
DECLARE @MultiPoint geometry
SET @MultiPoint = geometry::STGeomFromText('MULTIPOINT(0 0, 51 2, -3 10.5)', 0)
SELECT 
  @MultiPoint AS Shape,
  @MultiPoint.InstanceOf('GEOMETRYCOLLECTION') AS InstanceOfGeomColl


-- Determining whether a geometry is simple using STIsSimple()
DECLARE @DeliveryRoute geometry
SET @DeliveryRoute = geometry::STLineFromText(
  'LINESTRING(586960 4512940, 586530 4512160, 585990 4512460,
  586325 4513096, 587402 4512517, 587480 4512661)', 32618)
SELECT 
  @DeliveryRoute AS Shape,
  @DeliveryRoute.STIsSimple() AS IsSimple


-- Testing whether a geometry is closed using STIsClosed()
DECLARE @Snowdon geometry
SET @Snowdon = geometry::STMLineFromText(
'
MULTILINESTRING(
 (-4.07668 53.06804 3445,  -4.07694 53.06832 3445,  -4.07681 53.06860 3445,
  -4.07668 53.06869 3445,  -4.07651 53.06860 3445,  -4.07625 53.06832 3445,
  -4.07661 53.06804 3445,  -4.07668 53.06804 3445),
 (-4.07668 53.06776 3412,  -4.07709 53.06795 3412,  -4.07717 53.06804 3412,
  -4.07730 53.06832 3412,  -4.07730 53.06860 3412,  -4.07709 53.06890 3412,
  -4.07668 53.06898 3412,  -4.07642 53.06890 3412,  -4.07597 53.06860 3412,
  -4.07582 53.06832 3412,  -4.07603 53.06804 3412,  -4.07625 53.06791 3412,
  -4.07668 53.06776 3412),
 (-4.07709 53.06768 3379,  -4.07728 53.06778 3379,  -4.07752 53.06804 3379,
  -4.07767 53.06832 3379,  -4.07773 53.06860 3379,  -4.07771 53.06890 3379,
  -4.07728 53.06918 3379,  -4.07657 53.06918 3379,  -4.07597 53.06890 3379,
  -4.07582 53.06879 3379,  -4.07541 53.06864 3379,  -4.07537 53.06860 3379,
  -4.07526 53.06832 3379,  -4.07556 53.06804 3379,  -4.07582 53.06795 3379,
  -4.07625 53.06772 3379,  -4.07668 53.06757 3379,  -4.07709 53.06768 3379))',
  4326)  
SELECT
  @Snowdon AS Shape,
  @Snowdon.STIsClosed() AS IsClosed


-- Testing whether a LineString is a ring using STIsRing()
DECLARE @Speedway geometry
SET @Speedway = geometry::STLineFromText(
   'LINESTRING(565900 4404737, 565875 4405861, 565800 4405987, 565670 4406055,
     565361 4406050, 565222 4405975, 565150 4405825, 565170 4404760, 565222 4404617,
     565361 4404521, 565700 4404524, 565834 4404603, 565900 4404737)', 32616)
SELECT 
  @Speedway AS Shape,
  @Speedway.STIsRing() AS IsRing


-- Counting the number of points in a geometry using STNumPoints()
DECLARE @BermudaTriangle geography
SET @BermudaTriangle = geography::STPolyFromText(
  'POLYGON((-66.07 18.45, -64.78 32.3, -80.21 25.78, -66.07 18.45))',
  4326)
SELECT
  @BermudaTriangle AS Shape,
  @BermudaTriangle.STNumPoints() AS NumPoints


-- Testing whether a geometry is empty using STIsEmpty()
DECLARE @LineString1 geometry
DECLARE @LineString2 geometry
SET @LineString1 = geometry::STLineFromText('LINESTRING(2 4, 10 6)', 0)
SET @LineString2 = geometry::STLineFromText('LINESTRING(0 2, 8 4)', 0)
SELECT 
  @LineString1.STUnion(@LineString2) AS Shape,
  @LineString1.STIntersection(@LineString2).STIsEmpty() AS IsEmpty


-- Retrieving planar coordinate values using STX and STY
DECLARE @Johannesburg geometry
SET @Johannesburg = geometry::STGeomFromText('POINT(604931 7107923)', 32735)
SELECT
  @Johannesburg.STX AS X, 
  @Johannesburg.STY AS Y


-- Retrieving geographic coordinate values using Lat and Long
DECLARE @Colombo geography
SET @Colombo =
  geography::STGeomFromWKB(0x01010000006666666666F65340B81E85EB51B81B40, 4326)
SELECT
  @Colombo.Long AS Longitude,
  @Colombo.Lat AS Latitude


-- Retrieving extended coordinate values using Z and M
DECLARE @Antenna geography
SET @Antenna = 
  geography::STPointFromText('POINT(-89.64778 39.83167 34.7 1000131)',  4269)
SELECT 
  @Antenna.M AS M,
  @Antenna.Z AS Z


-- Returning a specific point from a geometry using STPointN()
DECLARE @LondonMarathon geography
SET @LondonMarathon = geography::STLineFromText(
  'LINESTRING(0.0112 51.4731, 0.0335 51.4749, 0.0527 51.4803, 0.0621 51.4906,
  0.0448 51.4923, 0.0238 51.4870, 0.0021 51.4843, -0.0151 51.4814, -0.0351 51.4861, -0.0460 51.4962, -0.0355 51.5011, -0.0509 51.5013,
  -0.0704 51.4989, -0.0719 51.5084, -0.0493 51.5098, -0.0275 51.5093, -0.0257 51.4963, -0.0134 51.4884, -0.0178 51.5003, -0.0195 51.5046,   -0.0087 51.5072, -0.0278 51.5112, -0.0472 51.5099, -0.0699 51.5084,   -0.0911 51.5105, -0.1138 51.5108, -0.1263 51.5010, -0.1376 51.5031)',   4326)
SELECT 
  @LondonMarathon AS Shape,
  @LondonMarathon.STPointN(14) AS Point14,
  @LondonMarathon.STPointN(14).STAsText() AS WKT


-- Returning the first and last point of a geometry using STStartPoint() and STEndPoint()
DECLARE @TransatlanticCrossing geography
SET @TransatlanticCrossing = geography::STLineFromText('
LINESTRING( 
  -73.88 40.57, -63.57 44.65, -53.36 46.74, -28.63 38.54,
  -28.24 38.42, -9.14 38.71,  -8.22 43.49,  -4.14 50.37)',
  4326
)
SELECT
  @TransatlanticCrossing AS Shape,
  @TransatlanticCrossing.STStartPoint().STAsText() AS StartPoint,
  @TransatlanticCrossing.STEndPoint().STAsText() AS EndPoint 


-- Finding the middle of a polygon using STCentroid()
DECLARE @Colorado geometry
SET @Colorado = geometry::STGeomFromText('POLYGON((-102.0423 36.9931, -102.0518 
41.0025, -109.0501 41.0006, -109.0452 36.9990, -102.0423 36.9931))', 4326)
SELECT 
  @Colorado AS Shape,
  @Colorado.STCentroid() AS Centroid,
  @Colorado.STCentroid().STAsText() AS WKT


-- Finding the middle of a geography instance using EnvelopeCenter()
DECLARE @Utah geography
SET @Utah = geography::STPolyFromText(
  'POLYGON((-109 37, -109 41, -111 41, -111 42, -114 42, -114 37, -109 37))', 4326)
SELECT 
  @Utah AS Shape,
  @Utah.EnvelopeCenter() AS EnvelopeCenter,
  @Utah.EnvelopeCenter().STAsText() AS WKT


-- Returning an abitrary interior point using STPointOnSurface()
DECLARE @Polygon geometry
SET @Polygon = geometry::STGeomFromText('POLYGON((10 2,10 4,5 4,5 2,10 2))',0)
SELECT
  @Polygon AS Shape,
  @Polygon.STPointOnSurface() AS PointOnSurface,
  @Polygon.STPointOnSurface().STAsText() AS WKT


-- Measuring the length of a geometry using STLength()
DECLARE @RoyalMile geography;
SET @RoyalMile = geography::STLineFromText(
  'LINESTRING(-3.20001 55.94821, -3.17227 55.9528)', 4326)
SELECT
  @RoyalMile AS Shape,
  @RoyalMile.STLength() AS Length


-- Measuring the area occupied by a geometry using STArea()
DECLARE @Cost money = 80000
DECLARE @Plot geometry
SET @Plot = geometry::STPolyFromText(
  'POLYGON((633000 4913260, 633000 4913447, 632628 4913447, 632642 4913260, 
    633000 4913260))',
  32631)
SELECT
  @Plot AS Shape,
  @Cost / @Plot.STArea() AS PerUnitAreaCost
  
  
-- Setting or returning the SRID of an instance using STSrid
CREATE TABLE #Imported_Data (
  Location geometry
)
GO

INSERT INTO #Imported_Data VALUES
 (geometry::STGeomFromText('LINESTRING(122 74, 123 72)', 0)),
 (geometry::STGeomFromText('LINESTRING(140 65, 132 63)', 0))
GO

UPDATE #Imported_Data
 SET Location.STSrid = 32731
GO

SELECT 
  Location.STAsText(),
  Location.STSrid
FROM #Imported_Data


-- Isolating the exterior ring of a polygon using STExteriorRing()
DECLARE @A geometry
SET @A = geometry::STPolyFromText(
  'POLYGON((0 0, 4 0, 6 5, 14 5, 16 0, 20 0, 13 20, 7 20, 0 0),
            (7 8,13 8,10 16,7 8))',
   0)
SELECT 
  @A AS Shape,
  @A.STExteriorRing() AS ExteriorRing,
  @A.STExteriorRing().STAsText() AS WKT


-- Counting the interior rings of a polygon using STNumInteriorRing()
DECLARE @Polygon geometry
SET @Polygon = geometry::STPolyFromText('
  POLYGON(
    (0 0, 20 0, 20 10, 0 10, 0 0),
    (3 1,3 8,2 8,3 1),
    (14 2,18 6, 12 4, 14 2))',
    0)
SELECT
  @Polygon AS Shape,
  @Polygon.STNumInteriorRing() AS NumInteriorRing


-- Isolating an individual interior ring using STInteriorRingN()
DECLARE @A geometry
SET @A = geometry::STPolyFromText(
  'POLYGON((0 0, 4 0, 6 5, 14 5, 16 0, 20 0, 13 20, 7 20, 0 0),
    (7 8,13 8,10 16,7 8))', 0)
SELECT 
  @A AS Shape,
  @A.STInteriorRingN(1) AS InteriorRing1,
  @A.STInteriorRingN(1).STAsText() AS WKT


-- Counting the total number of rings in a geography instance using NumRings()
DECLARE @Pentagon geography
SET @Pentagon = geography::STPolyFromText(
  'POLYGON(
    (
      -77.0532238483429 38.870863029297695 ,
      -77.05468297004701 38.87304314667469 ,
      -77.05788016319276 38.872800914712734 ,
      -77.05849170684814 38.870219840133124 ,
      -77.05556273460388 38.8690670969385 ,
      -77.0532238483429 38.870863029297695 
    ),
    (
      -77.05582022666931 38.8702866652523 ,
      -77.0569360256195 38.870737733163644 ,
      -77.05673217773439 38.87170668418343 ,
      -77.0554769039154 38.871848684516294 ,
      -77.05491900444031 38.87097997215688 ,
      -77.05582022666931 38.8702866652523 
    )
  )',
  4326
)
SELECT 
  @Pentagon AS Shape,
  @Pentagon.NumRings() AS NumRings


-- Isolating an individual ring from a geography instance using RingN()
DECLARE @Pentagon geography
SET @Pentagon = geography::STPolyFromText(
  'POLYGON(
    (
      -77.0532238483429 38.870863029297695 ,
      -77.05468297004701 38.87304314667469 ,
      -77.05788016319276 38.872800914712734 ,
      -77.05849170684814 38.870219840133124 ,
      -77.05556273460388 38.8690670969385 ,
      -77.0532238483429 38.870863029297695 
    ),
    (
      -77.05582022666931 38.8702866652523 ,
      -77.0569360256195 38.870737733163644 ,
      -77.05673217773439 38.87170668418343 ,
      -77.0554769039154 38.871848684516294 ,
      -77.05491900444031 38.87097997215688 ,
      -77.05582022666931 38.8702866652523 
    )
  )',
  4326
)
SELECT
  @Pentagon AS Shape,
  @Pentagon.RingN(1) AS Ring1,
  @Pentagon.RingN(1).STAsText() AS WKT


-- Identifying the boundary of a geometry using STBoundary()
DECLARE @A geometry
SET @A = geometry::STPolyFromText(
  'POLYGON((0 0, 4 0, 6 5, 14 5, 16 0, 20 0, 13 20, 7 20, 0 0),
    (7 8,13 8,10 16,7 8))', 0)
SELECT
  @A AS Shape,
  @A.STBoundary() AS Boundary,
  @A.STBoundary().STAsText() AS WKT


-- Identifying the bounding box of a geometry using STEnvelope()
DECLARE @A geometry
SET @A = geometry::STPolyFromText(
  'POLYGON((0 0, 4 0, 6 5, 14 5, 16 0, 20 0, 13 20, 7 20, 0 0),
  (7 8,13 8,10 16,7 8))', 0)
SELECT
  @A AS Shape,
  @A.STEnvelope() AS Envelope,
  @A.STEnvelope().STAsText() AS WKT


-- Identifying the extent of a geography instance using EnvelopeAngle()
DECLARE @NorthernHemisphere geography
SET @NorthernHemisphere = 
  geography::STGeomFromText('POLYGON((0 0.1,90 0.1,180 0.1, -90 0.1, 0 0.1))',4326)
SELECT
  @NorthernHemisphere AS Shape,
  @NorthernHemisphere.EnvelopeAngle() AS EnvelopeAngle


-- Counting the number of elements in an instance using STNumGeometries()
DECLARE @Collection geometry
SET @Collection = geometry::STGeomFromText('
  GEOMETRYCOLLECTION(
    MULTIPOINT((32 2), (23 12)),
    LINESTRING(30 2, 31 5),
    POLYGON((20 2, 23 2.5, 21 3, 20 2))
  )',
  0)

SELECT 
  @Collection AS Shape,
  @Collection.STNumGeometries() AS NumGeometries


-- Isolating an individual geometry from an instance using STGeometryN()
DECLARE @DFWRunways geography
SET @DFWRunways = geography::STMLineFromText(
  'MULTILINESTRING(
    (-97.0214781 32.9125542, -97.0008442 32.8949814),
    (-97.0831328 32.9095756, -97.0632761 32.8902694),
    (-97.0259706 32.9157078, -97.0261717 32.8788783),
    (-97.0097789 32.8983206, -97.0099086 32.8749594),
    (-97.0298833 32.9157222, -97.0300811 32.8788939),
    (-97.0507357 32.9157992, -97.0509261 32.8789717),
    (-97.0546419 32.9158147, -97.0548336 32.8789861)
  )', 4326)
SELECT
  @DFWRunways AS Shape,
  @DFWRunways.STGeometryN(3) AS Geometry3,
  @DFWRunways.STGeometryN(3).STAsText() AS WKT
