/**
 * Beginning Spatial with SQL Server 2008 (Apress)
 * Alastair Aitchison
 *
 * Chapter Seven : Geocoding
 */

-- Enable the CLR to run user-defined functions
EXEC sp_configure 'clr enabled' , '1'
GO
RECONFIGURE
GO

-- Set the appropriate database security permission
ALTER DATABASE Spatial SET TRUSTWORTHY ON
GO

-- Import the assembly
CREATE ASSEMBLY Geocoder
FROM 'C:\Spatial\Geocoder.dll'  
WITH PERMISSION_SET = EXTERNAL_ACCESS;
GO

-- Import the serialization assemblies
CREATE ASSEMBLY [Geocoder.XmlSerializers]  
FROM 'C:\Spatial\Geocoder.XmlSerializers.dll'  
WITH PERMISSION_SET = SAFE;
GO

-- Create the Geocode function
CREATE FUNCTION dbo.Geocode(
  @AddressLine nvarchar(255), 
  @PrimaryCity nvarchar(32),
  @Subdivision nvarchar(32),
  @Postcode nvarchar(10), 
  @CountryRegion nvarchar(20))
RETURNS nvarchar(255)
AS EXTERNAL NAME
Geocoder.[Geocoder.UserDefinedFunctions].geocode 
GO

-- Use the Geocode function
SELECT dbo.Geocode('2855 Telegraph Avenue','Berkeley','CA','94705','USA')

