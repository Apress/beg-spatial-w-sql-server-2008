/**
 * Beginning Spatial with SQL Server 2008 (Apress)
 * Alastair Aitchison
 *
 * Chapter Twelve : Modifying Spatial Data
 */
 
-- Testing whether a geometry is valid using STIsValid()
DECLARE @Polygon geometry
SET @Polygon = 
  geometry::STPolyFromText('POLYGON((0 0, 4 0, 4 3, 2 3, 2 4, 2 3, 0 3, 0 0))', 0)
SELECT
  @Polygon AS Shape,
  @Polygon.STIsValid() AS IsValid


-- Validating a geometry using MakeValid()
DECLARE @Invalid geometry
SET @Invalid = 
  geometry::STPolyFromText('POLYGON((0 0, 4 0, 4 3, 2 3, 2 4, 2 3, 0 3, 0 0))', 0)
DECLARE @Valid geometry
SET @Valid = @Invalid.MakeValid()
SELECT 
  @Invalid AS Shape,
  @Invalid.STAsText() AS WKT
UNION ALL SELECT
  @Valid AS Shape, 
  @Valid.STAsText() AS WKT


-- Creating the union of two geometries using STUnion()
DECLARE @NorthIsland geography
SET @NorthIsland = geography::STPolyFromText(
  'POLYGON((175.3 -41.5, 178.3 -37.9, 172.8 -34.6, 175.3 -41.5))',
  4326)
DECLARE @SouthIsland geography
SET @SouthIsland = geography::STPolyFromText(
  'POLYGON((169.3 -46.6, 174.3 -41.6, 172.5 -40.7, 166.3 -45.8, 169.3 -46.6))',
  4326)
DECLARE @NewZealand geography = @NorthIsland.STUnion(@SouthIsland)
SELECT 
  @NorthIsland AS Shape,
  @NorthIsland.STAsText() AS WKT
UNION ALL SELECT
  @SouthIsland AS Shape,
  @SouthIsland.STAsText() AS WKT
UNION ALL SELECT
  @NewZealand AS Shape,
  @NewZealand.STAsText() AS WKT


-- Aggregating a geometry column using STUnion()
DECLARE @GeomTable TABLE (
  GeomColumn geometry
)
INSERT INTO @GeomTable VALUES
  (geometry:: STPointFromText('POINT(12 9)', 0)),
  (geometry:: STLineFromText('LINESTRING(5 2, 9 4)', 0)),
  (geometry:: STPolyFromText('POLYGON((2 0, 4 3, 5 8, 2 4, 2 0))', 0))
DECLARE @Geom geometry
DECLARE @MultiGeom geometry = 
  geometry::STGeomFromText('GEOMETRYCOLLECTION EMPTY', 0)
DECLARE GeomCursor CURSOR FOR SELECT GeomColumn FROM @GeomTable 
OPEN GeomCursor
FETCH NEXT FROM GeomCursor INTO @Geom
WHILE @@FETCH_STATUS = 0
BEGIN
  SET @MultiGeom = @MultiGeom.STUnion(@Geom)
  FETCH NEXT FROM GeomCursor INTO @Geom
END
CLOSE GeomCursor
DEALLOCATE GeomCursor
SELECT @MultiGeom.STAsText()


-- Identifying the intersection between two geometries using STIntersection()
DECLARE @Marshes geography
SET @Marshes = geography::STPolyFromText(
  'POLYGON(( 
    12.94 41.57, 12.71 41.46, 12.91 41.39, 13.13 41.26, 13.31 41.33, 12.94 41.57))',
  4326)
DECLARE @ViaAppia geography
SET @ViaAppia = geography::STLineFromText(
  'LINESTRING(
    12.51 41.88, 13.25 41.28, 13.44 41.35, 13.61 41.25, 13.78 41.23, 13.89 41.11, 
    14.22 41.10, 14.47 41.02, 14.79 41.13, 14.99 41.04, 15.48 40.98, 15.82 40.96, 
    17.19 40.51, 17.65 40.50, 17.94 40.63)',
  4326)
SELECT 
  @ViaAppia AS Shape,
  @ViaAppia.STAsText() AS WKT
UNION ALL SELECT
  @Marshes AS Shape,
  @Marshes.STAsText() AS WKT
UNION ALL SELECT
  @ViaAppia.STIntersection(@Marshes) AS Shape,
  @ViaAppia.STIntersection(@Marshes).STAsText() AS WKT


-- Identifying the difference between two geometries using STDifference()
DECLARE @Radar geography
SET @Radar = geography::STMPointFromText(
  'MULTIPOINT(
    -2.597 52.398, -2.289 53.755, -0.531 51.689, -6.340 54.500, -5.223 50.003,
    -0.559 53.335, -4.445 51.980, -4.231 55.691, -2.036 57.431, -6.183 58.211,
    -3.453 50.963, 0.604 51.295,  -1.654 51.031, -2.199 49.209, -6.259 53.429,
    -8.923 52.700)', 4326)
DECLARE @RadarCoverage geography
SET @RadarCoverage = @Radar.STBuffer(75000)
DECLARE @BritishIsles geography
SET @BritishIsles = geography::STMPolyFromText(
  'MULTIPOLYGON(
    ((0.527 52.879, -3.164 56.0197, -1.626 57.631, -4.087 57.654, -2.989 58.582, 
    -5.0977 58.514, -6.504 56.240, -4.746 54.670, -3.516 54.848, -3.252 53.432, 
    -4.614 53.301, -4.922 51.697, -3.12 51.505, -5.625 50.032, 1.626 51.286, 
    0.791 51.423, 1.890 52.291, 1.274 52.959, 0.527 52.879)),
    ((-6.548 52.123, -5.317 54.518, -7.734 55.276, -9.976 53.354, -9.888 51.369, 
    -6.548 52.123)))', 4326)
SELECT 
  @BritishIsles AS Shape,
  @BritishIsles.STAsText() AS WKT
UNION ALL SELECT
  @Radar AS Shape,
  @Radar.STAsText() AS WKT
UNION ALL SELECT
  @BritishIsles.STDifference(@RadarCoverage) AS Shape,
  @BritishIsles.STDifference(@RadarCoverage).STAsText() AS WKT


-- Determining the symmetric difference between two geometries using STSymDifference()
DECLARE @KWEST geography, @KEAST geography
SET @KWEST = geography::Point(41.86, -87.88, 4269).STBuffer(10000)
SET @KEAST = geography::Point(41.89, -87.79, 4269).STBuffer(8000)
SELECT 
  @KEAST.STSymDifference(@KWEST) AS Shape,
  @KEAST.STSymDifference(@KWEST).STAsText() AS WKT


-- Simplifying a geometry using Reduce()
DECLARE @LineString geometry
SET @LineString = geometry::STLineFromText(
  'LINESTRING(130 33, 131 33.5, 131.5 32.9, 133 32.5, 135 33, 137 32, 138 31,
  140 30)',  0)
SELECT
  @LineString AS Shape,
  @LineString.STAsText() AS WKT
UNION ALL SELECT
  @LineString.Reduce(1) AS Shape,
  @LineString.Reduce(1).STAsText() AS WKT


-- Creating a buffer around a geometry using STBuffer()
DECLARE @Restaurant geography
SET @Restaurant = geography::STGeomFromText('POINT(1.3033 52.6285)', 4326)
DECLARE @FreeDeliveryZone geography
SET @FreeDeliveryZone = @Restaurant.STBuffer(5000)
SELECT 
  @FreeDeliveryZone AS Shape,
  @FreeDeliveryZone.STAsText() AS WKT


-- Creating a simple buffer using BufferWithTolerance()
DECLARE @Restaurant geography
SET @Restaurant = geography::STGeomFromText('POINT(1.3033 52.6285)', 4326)
DECLARE @FreeDeliveryZone geography
SET @FreeDeliveryZone = @Restaurant.BufferWithTolerance(5000, 250, 'false')
SELECT
  @FreeDeliveryZone AS Shape,
  @FreeDeliveryZone.STAsText() AS WKT
  
  
-- Creating the convex hull of a geometry using STConvexHull()
DECLARE @H5N1 geometry
SET @H5N1 = geometry::STMPointFromText(
  'MULTIPOINT(
    105.968 20.541, 105.877 21.124, 106.208 20.28, 101.803 16.009, 99.688 16.015,
    99.055 14.593, 99.055 14.583, 102.519 16.215, 100.914 15.074, 102.117 14.957,
    100.527 14.341, 99.699 17.248, 99.898 14.608, 99.898 14.608, 99.898 14.608,
    99.898 14.608, 100.524 17.75, 106.107 21.11, 106.91 11.753, 107.182 11.051,
    105.646 20.957, 105.857 21.124, 105.867 21.124, 105.827 21.124, 105.847 21.144,
    105.847 21.134, 106.617 10.871, 106.617 10.851, 106.637 10.851, 106.617 10.861,
    106.627 10.851, 106.617 10.881, 108.094 11.77, 108.094 11.75, 108.081 11.505,
    108.094 11.76, 105.899 9.546, 106.162 11.414, 106.382 20.534, 106.352 20.504, 
    106.342 20.504, 106.382 20.524, 106.382 20.504, 105.34 20.041, 105.34 20.051, 
    104.977 22.765, 105.646 20.977, 105.646 20.937, 99.688 16.015, 100.389 13.927,
    101.147 16.269, 101.78 13.905, 99.704 17.601, 105.604 10.654, 105.817 21.124, 
    106.162 11.404, 106.362 20.504)',
  4326)
SELECT 
  @H5N1 AS Shape
UNION ALL SELECT
  @H5N1.STConvexHull() AS Shape