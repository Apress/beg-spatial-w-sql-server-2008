/**
 * Beginning Spatial with SQL Server 2008 (Apress)
 * Alastair Aitchison
 *
 * Chapter One : Defining Spatial Information
 */

-- Viewing the list of supported geodetic spatial reference systems
-- that can be used to specify co-ordinates in the geography datatype.
SELECT 
  * 
FROM
  sys.spatial_reference_systems


-- Retrieving the Well-Known Text representation of a particular
-- spatial reference system (EPSG:4326)
SELECT
  well_known_text
FROM
  sys.spatial_reference_systems
WHERE
  authority_name = 'EPSG'
  AND 
  authorized_spatial_reference_id = 4326