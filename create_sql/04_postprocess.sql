-- daļai OSM ēku kāda virsotne atrodas tuvāk par 5 cm citai malai
-- oracle pēc precizitātes to uzskata par pašķrustošanos, kļūda 13349
-- sdo_util.rectify_geometry izlabo šādas ģeometrijas
UPDATE BUILDINGS -- labo ēku ģeometriju tabulā
   SET geom = SDO_UTIL.RECTIFY_GEOMETRY(geom, 0.05) -- pārraksta ģeometriju, izmantojot 0.05 m precizitāti
 WHERE SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(geom, 0.05) <> 'TRUE'; -- labo tikai tās ēkas, kurām validācija neizdevās

-- 4. slānis ir pieturu pieejamības zonas
-- katrai pieturai tiek uzbūvēts buferis katram walk_zones rādiusam
-- sdo_buffer ap punktu dod apli ar loka elementiem
-- sdo_arc_densify aizstāj lokus ar nogriežņiem, lai zonas varētu attēlot jebkurā rīkā
INSERT INTO CATCHMENTS (catchment_id, stop_id, radius_m, geom) -- ievieto jaunu zonu katrai pieturas un rādiusa kombinācijai
SELECT ROW_NUMBER() OVER (ORDER BY s.stop_id, z.radius_m), -- rēķina jaunu unikālu id katrai rindai
       s.stop_id, -- pieturas identifikators
       z.radius_m, -- zonas rādiuss
       SDO_GEOM.SDO_ARC_DENSIFY(SDO_GEOM.SDO_BUFFER(s.geom, z.radius_m, 0.05), 0.05, 'arc_tolerance=0.5') -- buferis ap pieturu, pēc tam nogludināts uz nogriežņiem
  FROM STOPS s CROSS JOIN WALK_ZONES z; -- katra pietura tiek savienota ar katru rādiusu

COMMIT; -- saglabā jaunās zonas
