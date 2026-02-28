-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S1: Data Definition Language
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
--
--
-- Opdracht: schrijf SQL-queries om onderstaande resultaten op te vragen,
-- aan te maken, verwijderen of aan te passen in de database van de
-- bedrijfscasus.
--
-- Codeer je uitwerking onder de regel 'DROP VIEW ...' (bij een SELECT)
-- of boven de regel 'ON CONFLICT DO NOTHING;' (bij een INSERT)
-- Je kunt deze eigen query selecteren en los uitvoeren, en wijzigen tot
-- je tevreden bent.
--
-- Vervolgens kun je je uitwerkingen testen door de testregels
-- (met [TEST] erachter) te activeren (haal hiervoor de commentaartekens
-- weg) en vervolgens het hele bestand uit te voeren. Hiervoor moet je de
-- testsuite in de database hebben geladen (bedrijf_postgresql_test.sql).
-- NB: niet alle opdrachten hebben testregels.
--
-- Lever je werk pas in op Canvas als alle tests slagen. Draai daarna
-- alle wijzigingen in de database terug met de queries helemaal onderaan.
-- ------------------------------------------------------------------------


-- S1.1. Geslacht
--
-- Voeg een kolom `geslacht` toe aan de medewerkerstabel.
-- Voeg ook een beperkingsregel `m_geslacht_chk` toe aan deze kolom,
-- die ervoor zorgt dat alleen 'M' of 'V' als geldige waarde wordt
-- geaccepteerd. Test deze regel en neem de gegooide foutmelding op als
-- commentaar in de uitwerking.

ALTER TABLE medewerkers
	ADD COLUMN geslacht VARCHAR(1)
	CONSTRAINT m_geslacht_chk 
	CHECK (geslacht IN ('M', 'V'));

SELECT * FROM medewerkers;

UPDATE medewerkers
SET geslacht = 'X'
WHERE mnr = 7369;

--ERROR:  new row for relation "medewerkers" violates check constraint "m_geslacht_chk"
--Failing row contains (7369, SMIT, N, TRAINER, 7902, 1985-12-17 00:00:00, 800.00, null, 20, X). 

UPDATE medewerkers
SET geslacht = 'V'
WHERE mnr = 7369;

--UPDATE 1

--Query returned successfully in 123 msec.





-- S1.2. Nieuwe afdeling
--
-- Het bedrijf krijgt een nieuwe onderzoeksafdeling 'ONDERZOEK' in Zwolle.
-- Om de onderzoeksafdeling op te zetten en daarna te leiden wordt de
-- nieuwe medewerker A DONK aangenomen. Hij krijgt medewerkersnummer 8000
-- en valt direct onder de directeur.
-- Voeg de nieuwe afdeling en de nieuwe medewerker toe aan de database.


select *
from medewerkers;

INSERT INTO medewerkers
	VALUES (8000, 'DONK', 'A', 'MANAGER', 7839, '1999-01-01 00:00:00', 3000.00, 200.00, 10);

select * from afdelingen

INSERT INTO afdelingen
	VALUES (50, 'ONDERZOEK', 'ZWOLLE', 8000)


-- S1.3. Verbetering op afdelingentabel
--
-- We gaan een aantal verbeteringen doorvoeren aan de tabel `afdelingen`:
--   a) Maak een sequence die afdelingsnummers genereert. Denk aan de beperking
--      dat afdelingsnummers veelvouden van 10 zijn.
--   b) Voeg een aantal afdelingen toe aan de tabel, maak daarbij gebruik van
--      de nieuwe sequence.
--   c) Op enig moment gaat het mis. De betreffende kolommen zijn te klein voor
--      nummers van 3 cijfers. Los dit probleem op.

CREATE SEQUENCE afdelingen_afdelingnr_seq
	INCREMENT 10
	START 0
	MINVALUE 0
	MAXVALUE 1000
	CACHE 1;

CREATE TABLE afdelingen
(
afdelingsnummers INTEGER NOT NULL DEFAULT NEXTVAL('afdelingen_afdelingnr_seq')

)
select * from afdelingen;



-- S1.4. Adressen
--
-- Maak een tabel `adressen`, waarin de adressen van de medewerkers worden
-- opgeslagen (inclusief adreshistorie). De tabel bestaat uit onderstaande
-- kolommen. Voeg minimaal één rij met adresgegevens van A DONK toe.
--
--    postcode      PK, bestaande uit 6 karakters (4 cijfers en 2 letters)
--    huisnummer    PK
--    ingangsdatum  PK
--    einddatum     moet na de ingangsdatum liggen
--    telefoon      10 cijfers, uniek
--    med_mnr       FK, verplicht

CREATE TABLE adressen
(
postcode VARCHAR(6) CONSTRAINT a_postc_ch CHECK(postcode ~ '^[0-9]{4}[A-Za-z]{2}$'),
huisnummer VARCHAR(5) NOT NULL,
ingangsdatum DATE NOT NULL,
einddatum DATE CONSTRAINT a_eindd_ch CHECK (einddatum is NULL OR einddatum > ingangsdatum),
telefoon NUMERIC(10) UNIQUE,
med_mnr NUMERIC(4) NOT NULL,
PRIMARY KEY (postcode, huisnummer, ingangsdatum),
CONSTRAINT a_med_mnr FOREIGN KEY (med_mnr) REFERENCES medewerkers(mnr)
);

INSERT INTO adressen 
VALUES ('8017JZ', 2, '2026-02-28', NULL, 0612345678, 8000)



-- S1.5. Commissie
--
-- De commissie van een medewerker (kolom `comm`) moet een bedrag bevatten als de medewerker een functie als
-- 'VERKOPER' heeft, anders moet de commissie NULL zijn. Schrijf hiervoor een beperkingsregel. Gebruik onderstaande
-- 'illegale' INSERTs om je beperkingsregel te controleren.

select * from medewerkers
ALTER TABLE medewerkers
ADD CONSTRAINT m_comm_chk CHECK ((functie = 'VERKOPER' AND comm is NOT NULL) OR (functie = NULL AND comm = NULL))

INSERT INTO medewerkers (mnr, naam, voorl, functie, chef, gbdatum, maandsal, comm)
VALUES (8001, 'MULLER', 'TJ', 'TRAINER', 7566, '1982-08-18', 2000, 500);

INSERT INTO medewerkers (mnr, naam, voorl, functie, chef, gbdatum, maandsal, comm)
VALUES (8002, 'JANSEN', 'M', 'VERKOPER', 7698, '1981-07-17', 1000, NULL);



-- -------------------------[ HU TESTRAAMWERK ]--------------------------------
-- Met onderstaande query kun je je code testen. Zie bovenaan dit bestand
-- voor uitleg.

SELECT * FROM test_exists('S1.1', 1) AS resultaat
UNION
SELECT * FROM test_exists('S1.2', 1) AS resultaat
UNION
SELECT 'S1.3 wordt niet getest: geen test mogelijk.' AS resultaat
UNION
SELECT * FROM test_exists('S1.4', 6) AS resultaat
UNION
SELECT 'S1.5 wordt niet getest: handmatige test beschikbaar.' AS resultaat
ORDER BY resultaat;


-- Draai alle wijzigingen terug om conflicten in komende opdrachten te voorkomen.
DROP TABLE IF EXISTS adressen;
UPDATE medewerkers SET afd = NULL WHERE mnr < 7369 OR mnr > 7934;
UPDATE afdelingen SET hoofd = NULL WHERE anr > 40;
DELETE FROM afdelingen WHERE anr > 40;
DELETE FROM medewerkers WHERE mnr < 7369 OR mnr > 7934;
ALTER TABLE medewerkers DROP CONSTRAINT IF EXISTS m_geslacht_chk;
ALTER TABLE medewerkers DROP COLUMN IF EXISTS geslacht;