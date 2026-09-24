SET LINESIZE 150 PAGESIZE 100 -- iestata izvades platumu un lapas garumu sqlplus

-- rindu skaitam jāsakrīt ar prepare_data.py izvadi
SELECT 'STOPS' tabula, COUNT(*) rindas FROM STOPS -- saskaita pieturu rindas
UNION ALL SELECT 'ROUTES', COUNT(*) FROM ROUTES -- saskaita maršrutu rindas
UNION ALL SELECT 'STOP_TYPES', COUNT(*) FROM STOP_TYPES -- saskaita pieturu veidu rindas
UNION ALL SELECT 'ROUTE_STOPS', COUNT(*) FROM ROUTE_STOPS -- saskaita pieturu secības rindas
UNION ALL SELECT 'ROAD_CLASSES', COUNT(*) FROM ROAD_CLASSES -- saskaita ielu klašu rindas
UNION ALL SELECT 'ROADS', COUNT(*) FROM ROADS -- saskaita ielu rindas
UNION ALL SELECT 'WALK_ZONES', COUNT(*) FROM WALK_ZONES -- saskaita gājēju zonu rindas
UNION ALL SELECT 'CATCHMENTS', COUNT(*) FROM CATCHMENTS -- saskaita pieejamības zonu rindas
UNION ALL SELECT 'BUILDING_TYPES', COUNT(*) FROM BUILDING_TYPES -- saskaita ēku tipu rindas
UNION ALL SELECT 'BUILDINGS', COUNT(*) FROM BUILDINGS -- saskaita ēku rindas
UNION ALL SELECT 'BUILDING_ADDRESSES', COUNT(*) FROM BUILDING_ADDRESSES; -- saskaita adrešu rindas

-- pārbauda ģeometriju korektumu, true vai oracle kļūdas kods, piemēram 13349 nozīmē pašķrustošanos
SELECT slanis, rezultats, COUNT(*) skaits FROM ( -- ārējais vaicājums grupē rezultātus pēc slāņa
  SELECT 'STOPS' slanis, SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(geom, 0.05), 1, 5) rezultats FROM STOPS -- pārbauda pieturu ģeometriju
  UNION ALL SELECT 'ROUTES', SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(geom, 0.05), 1, 5) FROM ROUTES -- pārbauda maršrutu ģeometriju
  UNION ALL SELECT 'ROADS', SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(geom, 0.05), 1, 5) FROM ROADS -- pārbauda ielu ģeometriju
  UNION ALL SELECT 'CATCHMENTS', SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(geom, 0.05), 1, 5) FROM CATCHMENTS -- pārbauda zonu ģeometriju
  UNION ALL SELECT 'BUILDINGS', SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(geom, 0.05), 1, 5) FROM BUILDINGS -- pārbauda ēku ģeometriju
) GROUP BY slanis, rezultats ORDER BY slanis, rezultats; -- sakārto rezultātu pēc slāņa un koda

-- maršruta garumam jāsakrīt ar prepare_data.py aprēķinu, 13590 m un 11650 m
SELECT shape_id, headsign, ROUND(SDO_GEOM.SDO_LENGTH(geom, 0.05, 'unit=M')) garums_m FROM ROUTES; -- rēķina katra maršruta virziena garumu metros

-- zonu laukumam jābūt tuvu teorētiskajam, 300 m aplim aptuveni 282743 kvadrātmetri, 600 m aptuveni 1130973 kvadrātmetri
SELECT radius_m, ROUND(AVG(SDO_GEOM.SDO_AREA(geom, 0.05, 'unit=SQ_M'))) vid_laukums_m2 FROM CATCHMENTS GROUP BY radius_m; -- rēķina vidējo zonas laukumu katram rādiusam
