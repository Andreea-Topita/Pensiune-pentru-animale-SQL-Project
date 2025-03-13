--4.Testare a operatiilor de vizualizare si validare la adaugare/modificare/stergere

--Vizualizare: date din mai multe dabele folosind join uri, evitand afisarea cheilor primare/straine

--1. Vizualizarea rezervarilor curente si a animalelor
SELECT 
    r.id_rezervare, 
    r.data_check_in, 
    a.nume_animal 
FROM 
    rezervare r
JOIN animal a ON r.id_animal = a.id_animal
JOIN cusca c ON r.nr_cusca = c.nr_cusca;

-- 2. Vizualizare nume proprietar si informatii despre animalele sale.
SELECT p.nume_prop, a.nume_animal, a.tip, a.rasa, a.varsta
FROM propr_animal p
JOIN animal a ON p.id_proprietar = a.id_proprietar;


-- 3. Vizualizare detalii despre rezervare,data check in si check out, cusca asociata, etaj si  tip de cusca
SELECT r.id_rezervare, r.data_check_in, r.data_check_out, c.nr_cusca, c.etaj, c.id_tip
FROM rezervare r
JOIN cusca c ON r.nr_cusca = c.nr_cusca;

-- 4. Vizualizare nume animal, tipul si adresa impreuna cu telefonul stapanului
SELECT a.nume_animal, a.tip, d.adresa, d.telefon
FROM animal a
JOIN detalii_propr d ON a.id_proprietar = d.id_proprietar;

-- 5. Vizualizare rezervare si detalii despre optiunile suplimentare a fiecarei rezervari
SELECT r.id_rezervare, 
       c.cantitate,  
       o.denumire_optiune,
       c.cost_total_opt
FROM rezervare r
JOIN consum_optiune c ON r.id_rezervare = c.rezervare_id_rezervare
JOIN optiune_supl o ON c.optiune_supl_id_optiune = o.id_optiune;

-- 6. Vizualizare rezervari pentru caini si pentru pisici 
SELECT r.id_rezervare, 
       a.nume_animal, 
       a.tip, 
       r.data_check_in, 
       r.data_check_out
FROM rezervare r
JOIN animal a ON r.id_animal = a.id_animal
WHERE a.tip = 'caine';

SELECT r.id_rezervare, 
       a.nume_animal, 
       a.tip, 
       r.data_check_in, 
       r.data_check_out
FROM rezervare r
JOIN animal a ON r.id_animal = a.id_animal
WHERE a.tip = 'pisica';

-- 7. Vizualizare animal care are rezervare intr o anumita perioada.
SELECT r.id_rezervare, 
       a.nume_animal, 
       r.data_check_in, 
       r.data_check_out
FROM rezervare r
JOIN animal a ON r.id_animal = a.id_animal
WHERE r.data_check_in >= TO_DATE('2024-12-10', 'YYYY-MM-DD') 
  AND r.data_check_out <= TO_DATE('2024-12-25', 'YYYY-MM-DD');
  
-- 8. Vizualizare nume proprietar, animal, tipul animalului, rasa si varsta
SELECT p.nume_prop, a.nume_animal, a.tip, a.rasa, a.varsta
FROM propr_animal p
JOIN animal a ON p.id_proprietar = a.id_proprietar;

---------------------------------------------------------------------
-- 2. validare la adaugare/modificare/stergere . se va testa, pe rand, functionarea tuturor constrangerilor
--de tip pk,nn,uk,ck,fk . 

----PROPRIETAR ANIMAL

--Testare PK - id_proprietar 
INSERT INTO propr_animal (id_proprietar, nume_prop, email, cnp)
VALUES (1, 'Ana Ionescu', 'ana.ion@yahoo.com', '1134167810124');
--EROARE: restricţia unică (BD142.PROPRIETAR_ANIMAL_PK) nu este respectată 

-- Testare NN nume_prop si cnp
INSERT INTO propr_animal (nume_prop, email, cnp)
VALUES (NULL, 'maria.popescu@email.com', '2345678901234');
--Eroare: RA-01400: nu poate fi inserat NULL în ("BD142"."PROPR_ANIMAL"."NUME_PROP")

INSERT INTO propr_animal (nume_prop, email, cnp)
VALUES ('Andrei Popa', 'andrei.popa@gmail.com', NULL);
--Eroare: ORA-01400: nu poate fi inserat NULL în ("BD142"."PROPR_ANIMAL"."CNP")

-- Testare UK
--cnp duplicat
INSERT INTO propr_animal (nume_prop, email, cnp)
VALUES ('Alexandru Mihai', 'alexandru.ionescu@email.com', '1234567890123');
--Error report -ORA-00001: restricţia unică (BD142.PROPRIETAR_ANIMAL_CNP_UK) nu este respectată

--Testare CK
--nume prop invalid
INSERT INTO propr_animal (nume_prop, email, cnp)
VALUES ('Ion123 Popescu', 'ion123.popescu@gmail.com', '3456789012345');
--Error report -ORA-02290: regulă de constrângere (BD142.PROP_ANIMAL_NUME_PROP_CK) violată

--cnp invalid, mai scurt de 13 caractere
INSERT INTO propr_animal (nume_prop, email, cnp)
VALUES ('Radu Ionescu', 'radu.ionescu@yahoo.com', '12345678');
--Error report -ORA-02290: regulă de constrângere (BD142.PROP_ANIMAL_CNP_CK) violată

-----DETALII PROP
--Testare FK
-- incercam sa inseram o valoare in detalii_propr cu id_proprietar care nu exista in propr_animal
INSERT INTO detalii_propr (adresa, telefon, id_proprietar)
VALUES ('Str. Lunga 15, Bucuresti', '+40123456789', 999);
--Error report - ORA-02291: constrângere de integritate (BD142.PROPRIETAR_ANIMAL_DETALII_FK) violată - cheia părinte negăsită

--Testare ck pentru adresa si telefon
INSERT INTO detalii_propr (adresa, telefon, id_proprietar)
VALUES ('Str. Lunga #15, Bucuresti', '+40123456789', 1);
-- Error report -ORA-02290: regulă de constrângere (BD142.DETALII_PROP_ADRESA_CK) violată

INSERT INTO detalii_propr (adresa, telefon, id_proprietar)
VALUES ('Str. Lunga 15, Bucuresti', '123a56789', 1);
--Error report -ORA-02290: regulă de constrângere (BD142.DETALII_PROP_TELEFON_CK) violată


---- ANIMAL
--Testare pk duplicat
INSERT INTO animal (id_animal, nume_animal, tip, id_proprietar)
VALUES (100, 'Rex', 'caine', 1); 
--Error report -ORA-00001: restricţia unică (BD142.ANIMALE_PK) nu este respectată
UPDATE animal 
SET id_animal = 100 
WHERE id_animal = 101; 
--RA-00001: restricţia unică (BD142.ANIMALE_PK) nu este respectată

--valid:
UPDATE animal 
SET nume_animal = 'Miki' 
WHERE id_animal = 100;

--Testare NN
--nume animal, tip si id prop
INSERT INTO animal (id_animal, nume_animal, tip, id_proprietar)
VALUES (101, NULL, 'caine', 1);
--Error: ORA-01400: nu poate fi inserat NULL în ("BD142"."ANIMAL"."NUME_ANIMAL")
UPDATE animal 
SET nume_animal = NULL 
WHERE id_animal = 104;
--QL Error: ORA-01407: nu poate fi actualizat ("BD142"."ANIMAL"."NUME_ANIMAL") cu NULL

--Testare UK nu am in animal

--Testare FK
INSERT INTO animal (id_animal, nume_animal, tip, id_proprietar)
VALUES (104, 'Charlie', 'caine', 999); 
--id nu exista
--ORA-00001: restricţia unică (BD142.ANIMALE_PK) nu este respectată

DELETE FROM propr_animal WHERE id_proprietar = 1;
--ORA-02292: constrângerea de integritate (BD142.PROP_ANIMAL_ANIMAL_FK) violată - găsită înregistrarea copil

--Testare CK
INSERT INTO animal (id_animal, nume_animal, tip, id_proprietar)
VALUES (105, 'Rex123', 'caine', 1);
--ORA-02290: regulă de constrângere (BD142.ANIMAL_NUME_ANIMAL_CK) violată

--incerc sa inserez un tip de animal care nu e permis
INSERT INTO animal (id_animal, nume_animal, tip, id_proprietar)
VALUES (106, 'Luna', 'papagal', 1);
--ORA-02290: regulă de constrângere (BD142.ANIMAL_TIP_CK) violată

UPDATE animal 
SET tip = 'papagal'
WHERE id_animal = 108;
--SQL Error: ORA-01407: nu poate fi actualizat ("BD142"."ANIMAL"."NUME_ANIMAL") cu NULL

--valoare negativa pentru varsta
INSERT INTO animal (id_animal, nume_animal, tip, varsta, id_proprietar)
VALUES (107, 'Bella', 'pisica', -2, 1);
--ORA-02290: regulă de constrângere (BD142.ANIMAL_VARSTA_CK) violată

--Testare trigger
INSERT INTO animal (id_animal, nume_animal, tip, id_proprietar)
VALUES (7,'Milo', 'caine',6);
--ORA-02291: constrângere de integritate (BD142.PROP_ANIMAL_ANIMAL_FK) violată - cheia părinte negăsită

--REZERVARE
--FK
DELETE FROM rezervare
WHERE id_rezervare = 204;
--RA-02292: constrângerea de integritate (BD142.CONSUM_OPTIUNE_REZERVARE_FK) violată - găsită înregistrarea copil

-- inseram o rezervare cu id existent  PK
INSERT INTO rezervare (id_rezervare, data_check_in, data_check_out, cost_rezervare, cost_total_rezervare, nr_cusca, id_animal)
VALUES (200, TO_DATE('2024-12-20 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-12-25 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 500, 600, 1, 101);
--RA-00001: restricţia unică (BD142.REZERVARI_PK) nu este respectată

--modificam id ul unei rezervari intr o valoare duplicata PK
UPDATE rezervare 
SET id_rezervare = 200 
WHERE id_rezervare = 201;
-- restricţia unică (BD142.REZERVARI_PK) nu este respectată

--data check out la null TRIGGER SI NULL NU AM VOIE
UPDATE rezervare 
SET data_check_out = NULL 
WHERE id_rezervare = 200;
--04088: eroare în timpul execuţiei triggerului 'BD142.TRG1_REZERVARE_BRIU'

--syergerea unui aniamal asociat unei rezervari FK
DELETE FROM animal WHERE id_animal = 101;
--ORA-02292: constrângerea de integritate (BD142.ANIMAL_REZERVARE_FK) violată - găsită înregistrarea copil

--CUSCA

--inserare a unei custi cu acelasi numar, restrictie PK
INSERT INTO cusca (nr_cusca, etaj, id_tip)
VALUES (1000, 1, 1);
--ORA-00001: restricţia unică (BD142.CUSCA_PK) nu este respectată

--etaj invalid PK
INSERT INTO cusca (nr_cusca, etaj, id_tip)
VALUES (1001, 3, 1); 
--ORA-00001: restricţia unică (BD142.CUSCA_PK) nu este respectată

--CK
UPDATE cusca
SET etaj = 5
WHERE nr_cusca = 1000;
--ORA-02290: regulă de constrângere (BD142.CUSCA_ETAJ_CK) violată

--tip inexistent PK
INSERT INTO cusca (nr_cusca, etaj, id_tip)
VALUES (1002, 1, 9999);
--ORA-00001: restricţia unică (BD142.CUSCA_PK) nu este respectată

--id tip utilizat in tabela cusca  FK
DELETE FROM tip_cusca WHERE id_tip = 1;
--ORA-02292: constrângerea de integritate (BD142.TIP_CUSCA_CUSCA_FK) violată - găsită înregistrarea copil

--TIP CUSCA

--incercare de inserare a unui id tip deja existent PK
INSERT INTO tip_cusca (id_tip, marime_cusca, tip_animal, pret_pe_noapte)
VALUES (1, 'S', 'caine', 50);
--ORA-00001: restricţia unică (BD142.TIP_CUSCA_PK) nu este respectată

--CK: incercare de inserare a unei marimi care nu exista
INSERT INTO tip_cusca (id_tip, marime_cusca, tip_animal, pret_pe_noapte)
VALUES (7, 'XL', 'caine', 60);
--ORA-02290: regulă de constrângere (BD142.TIP_CUSCA_MARIME_CK) violată

--tip invalid CK
INSERT INTO tip_cusca (id_tip, marime_cusca, tip_animal, pret_pe_noapte)
VALUES (7, 'M', 'iepure', 40);
--ORA-02290: regulă de constrângere (BD142.TIP_CUSCA_TIP_ANIM_CK) violată

--CK pret negativ
INSERT INTO tip_cusca (id_tip, marime_cusca, tip_animal, pret_pe_noapte)
VALUES (7, 'M', 'pisica', -20);
--ORA-02290: regulă de constrângere (BD142.TIP_CUSCA_PRET_CK) violată

--NULL
INSERT INTO tip_cusca (id_tip, marime_cusca, pret_pe_noapte)
VALUES (8, 'S', 70);
--ORA-01400: nu poate fi inserat NULL în ("BD142"."TIP_CUSCA"."TIP_ANIMAL")

UPDATE tip_cusca
SET marime_cusca = 'XXL'
WHERE id_tip = 5;
--ORA-02290: regulă de constrângere (BD142.TIP_CUSCA_MARIME_CK) violată

--FK
DELETE FROM tip_cusca
WHERE id_tip = 1;
--ORA-02292: constrângerea de integritate (BD142.TIP_CUSCA_CUSCA_FK) violată - găsită înregistrarea copil

--OPTIUNE SUPLIMENTARA

--PK deja existent
INSERT INTO optiune_supl (id_optiune, denumire_optiune, cost_optiune)
VALUES (50, 'Ingrijire medicala', 100);
--ORA-00001: restricţia unică (BD142.OPTIUNI_SUPLIMENTARE_PK) nu este respectată

--CK
INSERT INTO optiune_supl (denumire_optiune, cost_optiune)
VALUES ('Ingrijire@medicala', 200);
--ORA-02290: regulă de constrângere (BD142.OPT_SUPL_DENUMIRE_OPTIUNE_CK) violată

UPDATE optiune_supl 
SET denumire_optiune = 'Ingrijire/medicala';
--ORA-02290: regulă de constrângere (BD142.OPT_SUPL_DENUMIRE_OPTIUNE_CK) violată

--cost negativ
INSERT INTO optiune_supl (denumire_optiune, cost_optiune)
VALUES ('Plimbare', -10);
--RA-02290: regulă de constrângere (BD142.OPT_SUPL_COST_OPTIUNE_CK) violată

--CONSUM OPTIUNE

--PK duplicat pentru cheia primara
INSERT INTO consum_optiune (rezervare_id_rezervare, optiune_supl_id_optiune, cantitate, cost_total_opt)
VALUES (200, 50, 2, 200);
--ORA-00001: restricţia unică (BD142.CONSUM_OPTIUNE_PK) nu este respectată

-- 0 rows updated
UPDATE consum_optiune
SET rezervare_id_rezervare = 200, optiune_supl_id_optiune = 1
WHERE rezervare_id_rezervare = 201 AND optiune_supl_id_optiune = 2;

-- not null
INSERT INTO consum_optiune (rezervare_id_rezervare, optiune_supl_id_optiune, cantitate, cost_total_opt)
VALUES (200, 50, NULL, 200);
--SQL Error: ORA-01400: nu poate fi inserat NULL în ("BD142"."CONSUM_OPTIUNE"."CANTITATE")

--CK 
INSERT INTO consum_optiune (rezervare_id_rezervare, optiune_supl_id_optiune, cantitate, cost_total_opt)
VALUES (200, 50, -1, 200);
--ORA-02290: regulă de constrângere (BD142.CONSUM_OPTIUNI_CANTITATE_CK) violată

INSERT INTO consum_optiune (rezervare_id_rezervare, optiune_supl_id_optiune, cantitate, cost_total_opt)
VALUES (200, 50, 2, -50);
--ORA-02290: regulă de constrângere (BD142.CONS_OPT_COST_TOTAL_OPT_CK) violată

--FK 999 NU EXISTA
INSERT INTO consum_optiune (rezervare_id_rezervare, optiune_supl_id_optiune, cantitate, cost_total_opt)
VALUES (999,50, 2, 200);
--ORA-02291: constrângere de integritate (BD142.CONSUM_OPTIUNE_REZERVARE_FK) violată - cheia părinte negăsită

--OPTIUNE nu exista
INSERT INTO consum_optiune (rezervare_id_rezervare, optiune_supl_id_optiune, cantitate, cost_total_opt)
VALUES (200, 999, 2, 200);
--RA-02291: constrângere de integritate (BD142.CONSUM_OPTIUNE_OPTIUNE_SUPL_FK) violată - cheia părinte negăsită


commit;