-- sql loader kontroles fails 3. slānim, ielas
-- ģeometrija ir objekts, jo sdo_geometry nav parasta kolonna
-- punktu skaits katrai ielai ir atšķirīgs, tāpēc masīva garums nav konstants
LOAD DATA -- sāk datu ielādes aprakstu
CHARACTERSET UTF8 -- fails lasāms kā utf8
INFILE 'roads.dat' -- datu fails, no kura tiek ņemtas rindas
APPEND -- rindas pievieno tabulai, nedzēšot veco saturu
INTO TABLE ROADS -- mērķa tabula
FIELDS TERMINATED BY '|' -- lauki datu failā atdalīti ar simbolu
TRAILING NULLCOLS -- trūkstošie lauki rindas beigās kļūst par null
(
  road_id    INTEGER EXTERNAL, -- ielas identifikators
  class_code, -- ielas klases kods
  road_name  CHAR(400), -- ielas nosaukums
  maxspeed   INTEGER EXTERNAL, -- atļautais ātrums
  oneway, -- vai iela ir vienvirziena
  lanes      INTEGER EXTERNAL, -- joslu skaits
  geom COLUMN OBJECT ( -- ģeometrijas kolonna kā objekts
    sdo_gtype     INTEGER EXTERNAL, -- ģeometrijas tips
    sdo_srid      INTEGER EXTERNAL, -- koordinātu sistēmas kods
    sdo_elem_info VARRAY TERMINATED BY '|/' (elements FLOAT EXTERNAL), -- struktūras masīvs ar mainīgu garumu
    sdo_ordinates VARRAY TERMINATED BY '|/' (ordinates FLOAT EXTERNAL) -- koordinātu masīvs ar mainīgu garumu
  )
)
