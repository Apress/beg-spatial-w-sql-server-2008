/**
 * Beginning Spatial with SQL Server 2008 (Apress)
 * Alastair Aitchison
 *
 * Chapter Three : Using .NET Framework
 */

-- Creating spatial data using a static method
DECLARE @myTable table (
FeatureName varchar(32),
FeatureGeometry geometry
)
INSERT INTO @myTable VALUES (
'Statue of Liberty',
geometry::STGeomFromText('POINT(-74.045 40.69)', 4326)
)


-- Retrieving the error message raised by the CLR
BEGIN TRY
DECLARE @polygon geometry
SET @polygon = geometry::STPolyFromText('POLYGON((0 0,10 0,10 10,0 10,2 2))', 2285)
END TRY
BEGIN CATCH
SELECT ERROR_MESSAGE()
END CATCH