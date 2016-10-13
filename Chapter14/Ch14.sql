/**
 * Beginning Spatial with SQL Server 2008 (Apress)
 * Alastair Aitchison
 *
 * Chapter Fourteen : Improving Spatial Performance
 */
 
-- Creating a table of pseudo-random point data
CREATE TABLE RandomPoints (
  id int identity(1,1),
  geom geometry,
  geog geography
)
GO
DECLARE @i int = 1
DECLARE @lat float, @long float
WHILE @i < 10000
BEGIN
  SET @lat = (RAND() * 180) - 90
  SET @long = (RAND() * 360) - 180
  INSERT INTO RandomPoints (geom, geog) VALUES (
    geometry::Point(@lat, @long, 4326),
    geography::Point(@lat, @long, 4326)
  )
  SET @i = @i + 1
END
GO


-- Adding a primary key to the table
ALTER TABLE RandomPoints 
ADD CONSTRAINT idxCluster PRIMARY KEY CLUSTERED (id ASC)
GO

-- Creating a geometry index
CREATE SPATIAL INDEX idxGeometry ON RandomPoints ( geom )
USING GEOMETRY_GRID 
WITH (
  BOUNDING_BOX = (-180, -90, 180, 90),
  GRIDS = (
    LEVEL_1 = MEDIUM,
    LEVEL_2 = MEDIUM,
    LEVEL_3 = MEDIUM,
    LEVEL_4 = MEDIUM), 
  CELLS_PER_OBJECT = 16
)
GO

-- Creating a geography index
CREATE SPATIAL INDEX idxGeography ON RandomPoints ( geog )
USING  GEOGRAPHY_GRID 
WITH (
  GRIDS = (
    LEVEL_1 = MEDIUM,
    LEVEL_2 = MEDIUM,
    LEVEL_3 = MEDIUM,
    LEVEL_4 = MEDIUM), 
  CELLS_PER_OBJECT = 16
)


-- Employing the index in a SELECT query using an index hint
DECLARE @Window geometry
SET @Window = geometry::STPolyFromText('POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))', 4326)
SELECT *
FROM RandomPoints
WITH(INDEX(idxGeometry))
WHERE geom.STIntersects(@Window) = 1

