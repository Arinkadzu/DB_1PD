-- sql loader kontroles fails ēku adresēm, tā ir 5. slāņa atribūtu tabula
LOAD DATA -- sāk datu ielādes aprakstu
CHARACTERSET UTF8 -- fails lasāms kā utf8
INFILE 'building_addresses.dat' -- datu fails, no kura tiek ņemtas rindas
APPEND -- rindas pievieno tabulai, nedzēšot veco saturu
INTO TABLE BUILDING_ADDRESSES -- mērķa tabula
FIELDS TERMINATED BY '|' -- lauki datu failā atdalīti ar simbolu
TRAILING NULLCOLS -- trūkstošie lauki rindas beigās kļūst par null
(building_id INTEGER EXTERNAL, street CHAR(400), house_number) -- ēkas id, ielas nosaukums un mājas numurs
