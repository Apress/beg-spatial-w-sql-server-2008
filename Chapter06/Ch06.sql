/**
 * Beginning Spatial with SQL Server 2008 (Apress)
 * Alastair Aitchison
 *
 * Chapter Six : Importing Spatial Data
 */

-- Add a geography column to the table
ALTER TABLE [eqs7day-M1]
ADD Location geography
GO

-- Populate the Location column with points representing the epicenter
-- of each earthquake based on Lat / Lon values
UPDATE [eqs7day-M1]
SET Location = 
  geography::Point(Lat, Lon, 4326)


-- Populate the Location column with points representing the hypocenter 
-- of each earthquake based on Lat / Lon / Depth values
UPDATE [eqs7day-M1]
SET Location = 
  geography::STPointFromText(
    'POINT('
      + CAST(Lon AS varchar(255)) + ' '
      + CAST(Lat AS varchar(255)) + ' '
      + CAST (-Depth AS varchar(255)) + ')',
    4326)


-- Search for the SRID of the spatial reference system using geographic
-- coordinates based on the NAD83 datum
SELECT
  spatial_reference_id 
FROM 
  sys.spatial_reference_systems 
WHERE 
  well_known_text LIKE 'GEOGCS%"NAD83"%'
