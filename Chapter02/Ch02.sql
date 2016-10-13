/**
 * Beginning Spatial with SQL Server 2008 (Apress)
 * Alastair Aitchison
 *
 * Chapter Two : Implementing Spatial Data
 */

-- Retrieving the linear unit of measure for a given
-- spatial reference system
SELECT
  unit_of_measure
FROM
  sys.spatial_reference_systems
WHERE
  authority_name = 'EPSG'
  AND
  authorized_spatial_reference_id = 4326


-- Expressing the results of a linear measure
DECLARE @Paris geography = geography::Point(48.87, 2.33, 4326)
DECLARE @Berlin geography = geography::Point(52.52, 13.4, 4326)
SELECT @Paris.STDistance(@Berlin)


-- You CANNOT convert between datatypes like this:
/*
DECLARE @geog geography
SET @geog = geography::STGeomFromText('POINT(23 32)',4326)
SELECT CAST(@geog AS geometry)
*/

-- Instead, you must do it like this:
DECLARE @geog geography
SET @geog = geography::STGeomFromText('POINT(23 32)',4326)
DECLARE @geom geometry
SET @geom = geometry::STGeomFromWKB(@geog.STAsBinary(), @geog.STSrid)


-- Creating a new table with a geometry column
CREATE TABLE [dbo].[Cities] (
    [CityName] [varchar](255) NOT NULL,
    [CityLocation] [geometry] NOT NULL
)
GO


-- Adding a new geography column to an existing table
CREATE TABLE [dbo].[Customers] (
  CustomerID int,
  FirstName varchar(50),
  Surname varchar (50),
  Address varchar (255),
  Postcode varchar (10),
  Country varchar(32)
)
GO
ALTER TABLE [dbo].[Customers]
ADD CustomerLocation geography
GO


-- Enforcing a common SRID
ALTER TABLE [dbo].[Customers] 
ADD CONSTRAINT [enforce_srid_geographycolumn] 
CHECK (CustomerLocation.STSrid = 4326)
GO