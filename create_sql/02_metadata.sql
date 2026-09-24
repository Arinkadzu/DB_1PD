-- koordinātu sistēma ir LKS-92, SRID 3059, mērvienība metrs
-- robežas ir faktiskās datu robežas no prepare_data.py izvades, noapaļotas uz āru līdz 100 m
-- precizitāte visur ir 0.05 m, punkti tuvāk par 5 cm tiek uzskatīti par vienu punktu

INSERT INTO USER_SDO_GEOM_METADATA (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID) VALUES ('STOPS', 'GEOM', -- reģistrē pieturu ģeometrijas metadatus
  SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 498700, 508000, 0.05), -- x ass robežas un precizitāte
                SDO_DIM_ELEMENT('Y', 308600, 311500, 0.05)), 3059); -- y ass robežas un koordinātu sistēmas kods

INSERT INTO USER_SDO_GEOM_METADATA (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID) VALUES ('ROUTES', 'GEOM', -- reģistrē maršruta ģeometrijas metadatus
  SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 498700, 508100, 0.05), -- x ass robežas
                SDO_DIM_ELEMENT('Y', 308500, 311600, 0.05)), 3059); -- y ass robežas

INSERT INTO USER_SDO_GEOM_METADATA (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID) VALUES ('ROADS', 'GEOM', -- reģistrē ielu ģeometrijas metadatus
  SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 496000, 510000, 0.05), -- x ass robežas, plašākas nekā citiem slāņiem
                SDO_DIM_ELEMENT('Y', 305600, 314900, 0.05)), 3059); -- y ass robežas

-- zonas robežas atbilst pieturām ar 600 m rezervi
INSERT INTO USER_SDO_GEOM_METADATA (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID) VALUES ('CATCHMENTS', 'GEOM', -- reģistrē pieejamības zonu ģeometrijas metadatus
  SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 498100, 508600, 0.05), -- x ass robežas
                SDO_DIM_ELEMENT('Y', 308000, 312100, 0.05)), 3059); -- y ass robežas

INSERT INTO USER_SDO_GEOM_METADATA (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID) VALUES ('BUILDINGS', 'GEOM', -- reģistrē ēku ģeometrijas metadatus
  SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 496900, 509800, 0.05), -- x ass robežas
                SDO_DIM_ELEMENT('Y', 306800, 313500, 0.05)), 3059); -- y ass robežas

COMMIT; -- saglabā visus piecus metadatu ierakstus
