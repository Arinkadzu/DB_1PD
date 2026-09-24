-- 5 slāņi, katram slānim ir pamattabula ar ģeometriju un atribūtu tabulas
BEGIN -- bloks, kas atkārtotas palaišanas gadījumā notīra veco stāvokli
  FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN ( -- iet cauri visām 11 tabulām, ja tās jau eksistē
      'ROUTE_STOPS', 'ROUTES', 'CATCHMENTS', 'WALK_ZONES', 'STOPS', 'STOP_TYPES', -- pirmā puse tabulu nosaukumu saraksta
      'ROADS', 'ROAD_CLASSES', 'BUILDING_ADDRESSES', 'BUILDINGS', 'BUILDING_TYPES')) LOOP -- otrā puse tabulu nosaukumu saraksta
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE'; -- izdzēš tabulu kopā ar ārējām atslēgām
  END LOOP; -- cikla beigas
  DELETE FROM user_sdo_geom_metadata -- notīra arī veco ģeometrijas metadatu ierakstu
   WHERE table_name IN ('STOPS', 'ROUTES', 'ROADS', 'CATCHMENTS', 'BUILDINGS'); -- tikai piecām ģeometrijas tabulām
  COMMIT; -- saglabā dzēšanu
END; -- bloka beigas
-- palaiž PL/SQL bloku
/ 

-- 1. slānis, pieturas kā punkti
CREATE TABLE STOP_TYPES ( -- klasifikators pieturas veidam
  stop_type   VARCHAR2(10) CONSTRAINT pk_stop_types PRIMARY KEY, -- pieturas veida kods
  description VARCHAR2(100) NOT NULL -- pieturas veida apraksts latviešu valodā
);

CREATE TABLE STOPS ( -- pamattabula ar pieturas ģeometriju
  stop_id   VARCHAR2(10) CONSTRAINT pk_stops PRIMARY KEY, -- Rīgas satiksmes pieturas kods
  stop_name VARCHAR2(100) NOT NULL, -- pieturas nosaukums
  stop_type VARCHAR2(10) NOT NULL CONSTRAINT fk_stops_type REFERENCES STOP_TYPES, -- saite uz pieturas veidu
  lon       NUMBER(9, 6), -- oriģinālā WGS84 garuma koordināta
  lat       NUMBER(9, 6), -- oriģinālā WGS84 platuma koordināta
  geom      SDO_GEOMETRY -- ģeometrija LKS-92 sistēmā kā punkts
);

-- 2. slānis, maršruta līnijas
CREATE TABLE ROUTES ( -- pamattabula ar maršruta virziena ģeometriju
  shape_id     VARCHAR2(30) CONSTRAINT pk_routes PRIMARY KEY, -- maršruta virziena identifikators
  direction_id NUMBER(1) NOT NULL, -- virziens, 0 nozīmē uz lidostu, 1 uz Abrenes ielu
  headsign     VARCHAR2(50), -- galapunkts, kas redzams uz transportlīdzekļa
  geom         SDO_GEOMETRY -- ģeometrija kā līnija
);

-- pieturu secība katrā maršruta virzienā, viena līnija atbilst vairākām pieturām
CREATE TABLE ROUTE_STOPS ( -- atribūtu tabula, kas savieno maršrutu un pieturas
  shape_id VARCHAR2(30) CONSTRAINT fk_route_stops_route REFERENCES ROUTES, -- saite uz maršruta virzienu
  stop_seq NUMBER(3), -- pieturas secības numurs maršrutā
  stop_id  VARCHAR2(10) NOT NULL CONSTRAINT fk_route_stops_stop REFERENCES STOPS, -- saite uz pieturu
  CONSTRAINT pk_route_stops PRIMARY KEY (shape_id, stop_seq) -- katrai secībai katrā virzienā ir jābūt unikālai
);

-- 3. slānis, ielas kā līnijas
CREATE TABLE ROAD_CLASSES ( -- klasifikators ielas klasei
  class_code  VARCHAR2(20) CONSTRAINT pk_road_classes PRIMARY KEY, -- OSM highway vērtība
  class_rank  NUMBER(2) NOT NULL, -- ranga skaitlis, mazāks skaitlis nozīmē svarīgāku ielu
  description VARCHAR2(100) NOT NULL -- ielas klases apraksts latviešu valodā
);

CREATE TABLE ROADS ( -- pamattabula ar ielas ģeometriju
  road_id    NUMBER CONSTRAINT pk_roads PRIMARY KEY, -- OSM way identifikators
  class_code VARCHAR2(20) NOT NULL CONSTRAINT fk_roads_class REFERENCES ROAD_CLASSES, -- saite uz ielas klasi
  road_name  VARCHAR2(200), -- ielas nosaukums
  maxspeed   NUMBER(3), -- atļautais ātrums kilometros stundā
  oneway     CHAR(1) CONSTRAINT ck_roads_oneway CHECK (oneway IN ('Y', 'N')), -- vai iela ir vienvirziena
  lanes      NUMBER(2), -- joslu skaits
  geom       SDO_GEOMETRY -- ģeometrija kā līnija
);

-- 4. slānis, pieturu pieejamības zonas kā poligoni
CREATE TABLE WALK_ZONES ( -- klasifikators zonas rādiusam
  radius_m    NUMBER(4) CONSTRAINT pk_walk_zones PRIMARY KEY, -- rādiuss metros
  walk_min    NUMBER(2) NOT NULL, -- aptuvenais gājiena laiks minūtēs
  description VARCHAR2(100) -- zonas apraksts
);

CREATE TABLE CATCHMENTS ( -- pamattabula ar zonas ģeometriju
  catchment_id NUMBER CONSTRAINT pk_catchments PRIMARY KEY, -- zonas identifikators
  stop_id      VARCHAR2(10) NOT NULL CONSTRAINT fk_catchments_stop REFERENCES STOPS, -- saite uz pieturu, ap kuru zona veidota
  radius_m     NUMBER(4) NOT NULL CONSTRAINT fk_catchments_zone REFERENCES WALK_ZONES, -- saite uz rādiusa veidu
  geom         SDO_GEOMETRY -- ģeometrija kā poligons
);

-- 5. slānis, ēkas kā poligoni
CREATE TABLE BUILDING_TYPES ( -- klasifikators ēkas tipam
  type_code   VARCHAR2(40) CONSTRAINT pk_building_types PRIMARY KEY, -- OSM building vērtība
  category    VARCHAR2(20) NOT NULL, -- ēkas kategorija, piemēram dzīvojamā
  description VARCHAR2(100) NOT NULL -- ēkas tipa apraksts
);

CREATE TABLE BUILDINGS ( -- pamattabula ar ēkas ģeometriju
  building_id NUMBER CONSTRAINT pk_buildings PRIMARY KEY, -- ēkas identifikators
  osm_type    CHAR(1) CONSTRAINT ck_buildings_osm_type CHECK (osm_type IN ('W', 'R')), -- W nozīmē way, R nozīmē relation
  osm_id      NUMBER NOT NULL, -- oriģinālais OSM objekta id
  type_code   VARCHAR2(40) NOT NULL CONSTRAINT fk_buildings_type REFERENCES BUILDING_TYPES, -- saite uz ēkas tipu
  levels      NUMBER(3), -- stāvu skaits, ja zināms
  geom        SDO_GEOMETRY -- ģeometrija kā poligons
);

-- adrese ir tikai daļai ēku, tāpēc tā ir atsevišķā tabulā
CREATE TABLE BUILDING_ADDRESSES ( -- atribūtu tabula ar ēkas adresi
  building_id  NUMBER CONSTRAINT pk_building_addresses PRIMARY KEY -- ēkas identifikators, vienlaikus arī atslēga
                      CONSTRAINT fk_addresses_building REFERENCES BUILDINGS, -- saite uz ēku tabulu
  street       VARCHAR2(200), -- ielas nosaukums adresē
  house_number VARCHAR2(20) NOT NULL -- mājas numurs
);
