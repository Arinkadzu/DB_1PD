-- sql loader kontroles fails 5. slānim, ēkas
-- poligoniem var būt caurumi un vairākas daļas, tāpēc struktūras masīva garums ir mainīgs
LOAD DATA -- sāk datu ielādes aprakstu
CHARACTERSET UTF8 -- fails lasāms kā utf8
INFILE 'buildings.dat' -- datu fails, no kura tiek ņemtas rindas
APPEND -- rindas pievieno tabulai, nedzēšot veco saturu
INTO TABLE BUILDINGS -- mērķa tabula
FIELDS TERMINATED BY '|' -- lauki datu failā atdalīti ar simbolu
TRAILING NULLCOLS -- trūkstošie lauki rindas beigās kļūst par null
(
  building_id INTEGER EXTERNAL, -- ēkas identifikators
  osm_type, -- osm objekta veids
  osm_id      INTEGER EXTERNAL, -- oriģinālais osm identifikators
  type_code, -- ēkas tipa kods
  levels      INTEGER EXTERNAL, -- stāvu skaits
  geom COLUMN OBJECT ( -- ģeometrijas kolonna kā objekts
    sdo_gtype     INTEGER EXTERNAL, -- ģeometrijas tips
    sdo_srid      INTEGER EXTERNAL, -- koordinātu sistēmas kods
    sdo_elem_info VARRAY TERMINATED BY '|/' (elements FLOAT EXTERNAL), -- struktūras masīvs ar mainīgu garumu
    sdo_ordinates VARRAY TERMINATED BY '|/' (ordinates FLOAT EXTERNAL) -- koordinātu masīvs ar mainīgu garumu
  )
)
