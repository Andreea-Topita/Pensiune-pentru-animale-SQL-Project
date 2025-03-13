CREATE TABLE propr_animal (
    id_proprietar NUMBER(3) NOT NULL,
    nume_prop     VARCHAR2(50) NOT NULL,
    email         VARCHAR2(50),
    cnp           CHAR(13) NOT NULL
);

ALTER TABLE propr_animal
    ADD CONSTRAINT prop_animal_nume_prop_ck
        CHECK ( REGEXP_LIKE ( nume_prop,
                              '^[A-Za-z]+([ -][A-Za-z]+)*$' )
                AND length(nume_prop) > 1 );

ALTER TABLE propr_animal
    ADD CONSTRAINT prop_animal_email_ck CHECK ( REGEXP_LIKE ( email,
                                                              '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' ) );

ALTER TABLE propr_animal
    ADD CONSTRAINT prop_animal_cnp_ck CHECK ( REGEXP_LIKE ( cnp,
                                                            '^[0-9]{13}$' ) );

ALTER TABLE propr_animal ADD CONSTRAINT proprietar_animal_pk PRIMARY KEY ( id_proprietar );

ALTER TABLE propr_animal ADD CONSTRAINT proprietar_animal_cnp_uk UNIQUE ( cnp );

ALTER TABLE propr_animal ADD CONSTRAINT proprietar_animal_email_uk UNIQUE ( email );

CREATE TABLE detalii_propr (
    adresa        VARCHAR2(60) NOT NULL,
    telefon       VARCHAR2(15) NOT NULL,
    id_proprietar NUMBER(3) NOT NULL
);

ALTER TABLE detalii_propr
    ADD CONSTRAINT detalii_prop_adresa_ck CHECK ( REGEXP_LIKE ( adresa,
                                                                '^[A-Za-z0-9\s,\.]+( [A-Za-z0-9\s,\.]+)*$' ) );

ALTER TABLE detalii_propr
    ADD CONSTRAINT detalii_prop_telefon_ck CHECK ( REGEXP_LIKE ( telefon,
                                                                 '^\+?[0-9\s\(\)-]+$' ) );

CREATE UNIQUE INDEX detalii_propr__idx ON
    detalii_propr (
        id_proprietar
    ASC );

ALTER TABLE detalii_propr ADD CONSTRAINT detalii_prop_telefon_uk UNIQUE ( telefon );

CREATE TABLE animal (
    id_animal     NUMBER(3) NOT NULL,
    nume_animal   VARCHAR2(30) NOT NULL,
    tip           VARCHAR2(30) NOT NULL,
    rasa          VARCHAR2(30),
    varsta        NUMBER(3),
    id_proprietar NUMBER(3) NOT NULL
);

ALTER TABLE animal
    ADD CONSTRAINT animal_nume_animal_ck
        CHECK ( REGEXP_LIKE ( nume_animal,
                              '^[A-Za-z\s-]+$' )
                AND length(nume_animal) > 1 );

ALTER TABLE animal
    ADD CONSTRAINT animal_tip_ck CHECK ( tip IN ( 'caine', 'pisica' ) );

ALTER TABLE animal
    ADD CONSTRAINT animal_rasa_ck CHECK (rasa IS NULL OR REGEXP_LIKE ( rasa,
                                                        '^[A-Za-z]+$' ) );
                                                        

ALTER TABLE animal ADD CONSTRAINT animal_varsta_ck CHECK (varsta IS NULL OR varsta >= 0 );

ALTER TABLE animal ADD CONSTRAINT animale_pk PRIMARY KEY ( id_animal );

CREATE TABLE tip_cusca (
    id_tip         NUMBER(5) NOT NULL,
    marime_cusca   VARCHAR2(3) NOT NULL,
    tip_animal     VARCHAR2(50) NOT NULL,
    pret_pe_noapte NUMBER(4)
);

ALTER TABLE tip_cusca
    ADD CONSTRAINT tip_cusca_marime_ck
        CHECK ( marime_cusca IN ( 'L', 'M', 'S' ) );

ALTER TABLE tip_cusca
    ADD CONSTRAINT tip_cusca_tip_anim_ck CHECK ( tip_animal IN ( 'caine', 'pisica' ) );

ALTER TABLE tip_cusca
    ADD CONSTRAINT tip_cusca_pret_ck
        CHECK ( pret_pe_noapte > 0
                AND pret_pe_noapte <= 1000 );

ALTER TABLE tip_cusca ADD CONSTRAINT tip_cusca_pk PRIMARY KEY ( id_tip );


CREATE TABLE cusca (
    nr_cusca NUMBER(4) NOT NULL,
    etaj     NUMBER(2) NOT NULL,
    id_tip   NUMBER(5) NOT NULL
);

ALTER TABLE cusca
    ADD CONSTRAINT cusca_etaj_ck CHECK ( etaj IN ( 1, 2 ) );

ALTER TABLE cusca ADD CONSTRAINT cusca_pk PRIMARY KEY ( nr_cusca );

CREATE TABLE rezervare (
    id_rezervare         NUMBER(3) NOT NULL,
    data_check_in        DATE NOT NULL,
    data_check_out       DATE NOT NULL,
    cost_rezervare       NUMBER(4),
    cost_total_rezervare NUMBER(4),
    nr_cusca             NUMBER(4) NOT NULL,
    id_animal            NUMBER(3) NOT NULL
);

ALTER TABLE rezervare ADD CONSTRAINT rez_data_check_out_ck CHECK ( data_check_out >= data_check_in );

ALTER TABLE rezervare ADD CONSTRAINT rez_cost_rez_ck CHECK ( cost_rezervare >= 0 );

ALTER TABLE rezervare ADD CONSTRAINT rez_cost_total_rezervare_ck CHECK ( cost_total_rezervare >= 0 );

ALTER TABLE rezervare ADD CONSTRAINT rezervari_pk PRIMARY KEY ( id_rezervare );

CREATE TABLE optiune_supl (
    id_optiune       NUMBER(3) NOT NULL,
    denumire_optiune VARCHAR2(50) NOT NULL,
    cost_optiune     NUMBER(4) NOT NULL
);

ALTER TABLE optiune_supl
    ADD CONSTRAINT opt_supl_denumire_optiune_ck CHECK ( REGEXP_LIKE ( denumire_optiune,
                                                                      '^[A-Za-z0-9\s,\.]+( [A-Za-z0-9\s,\.]+)*$' ) );

ALTER TABLE optiune_supl ADD CONSTRAINT opt_supl_cost_optiune_ck CHECK ( cost_optiune >= 0 );

ALTER TABLE optiune_supl ADD CONSTRAINT optiuni_suplimentare_pk PRIMARY KEY ( id_optiune );

CREATE TABLE consum_optiune (
    rezervare_id_rezervare  NUMBER(3) NOT NULL,
    optiune_supl_id_optiune NUMBER(3) NOT NULL,
    cantitate               NUMBER(3) NOT NULL,
    cost_total_opt          NUMBER(4)
);

ALTER TABLE consum_optiune ADD CONSTRAINT consum_optiuni_cantitate_ck CHECK ( cantitate >= 0 );

ALTER TABLE consum_optiune ADD CONSTRAINT cons_opt_cost_total_opt_ck CHECK ( cost_total_opt >= 0 );

ALTER TABLE consum_optiune ADD CONSTRAINT consum_optiune_pk PRIMARY KEY ( rezervare_id_rezervare,
                                                                          optiune_supl_id_optiune );
                                                                

ALTER TABLE rezervare
    ADD CONSTRAINT animal_rezervare_fk
        FOREIGN KEY ( id_animal )
            REFERENCES animal ( id_animal )
            NOT DEFERRABLE;

ALTER TABLE consum_optiune
    ADD CONSTRAINT consum_optiune_optiune_supl_fk
        FOREIGN KEY ( optiune_supl_id_optiune )
            REFERENCES optiune_supl ( id_optiune )
            NOT DEFERRABLE;

ALTER TABLE consum_optiune
    ADD CONSTRAINT consum_optiune_rezervare_fk
        FOREIGN KEY ( rezervare_id_rezervare )
            REFERENCES rezervare ( id_rezervare )
            NOT DEFERRABLE;

ALTER TABLE rezervare
    ADD CONSTRAINT cusca_rezervare_fk
        FOREIGN KEY ( nr_cusca )
            REFERENCES cusca ( nr_cusca )
            NOT DEFERRABLE;

ALTER TABLE animal
    ADD CONSTRAINT prop_animal_animal_fk
        FOREIGN KEY ( id_proprietar )
            REFERENCES propr_animal ( id_proprietar )
            NOT DEFERRABLE;

ALTER TABLE detalii_propr
    ADD CONSTRAINT proprietar_animal_detalii_fk
        FOREIGN KEY ( id_proprietar )
            REFERENCES propr_animal ( id_proprietar )
            NOT DEFERRABLE;

ALTER TABLE cusca
    ADD CONSTRAINT tip_cusca_cusca_fk
        FOREIGN KEY ( id_tip )
            REFERENCES tip_cusca ( id_tip )
            NOT DEFERRABLE;

CREATE OR REPLACE TRIGGER Trg1_rezervare_BRIU 
    BEFORE INSERT OR UPDATE ON rezervare 
    FOR EACH ROW 
BEGIN
    IF ( :new.data_check_in <= SYSDATE ) 
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'Data invalida: ' || TO_CHAR( :new.data_check_in, 'DD.MM.YYYY HH24:MI:SS') || ' trebuie sa fie mai mare decat data curenta.');
    END IF;
END; 
/

CREATE OR REPLACE TRIGGER Trg2_rez_check_in_BRIU 
    BEFORE INSERT OR UPDATE ON rezervare 
    FOR EACH ROW 
BEGIN
	IF TO_NUMBER(TO_CHAR(:NEW.data_check_in, 'HH24')) < 12 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ora check-in trebuie să fie după 12:00:00.');
	END IF;
END; 
/

CREATE OR REPLACE TRIGGER Trg3_rez_check_out_BRIU 
    BEFORE INSERT OR UPDATE ON rezervare 
    FOR EACH ROW 
BEGIN
	IF TO_NUMBER(TO_CHAR(:NEW.data_check_out, 'HH24')) > 10 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Ora check-out trebuie să fie înainte de ora 10:00.');
	END IF;
END; 
/

CREATE SEQUENCE animal_id_animal_seq START WITH 100 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER animal_id_animal_trg BEFORE
    INSERT ON animal
    FOR EACH ROW
    WHEN ( new.id_animal IS NULL )
BEGIN
    :new.id_animal := animal_id_animal_seq.nextval;
END;
/

CREATE SEQUENCE cusca_nr_cusca_seq START WITH 1000 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER cusca_nr_cusca_trg BEFORE
    INSERT ON cusca
    FOR EACH ROW
    WHEN ( new.nr_cusca IS NULL )
BEGIN
    :new.nr_cusca := cusca_nr_cusca_seq.nextval;
END;
/

CREATE SEQUENCE optiune_supl_id_optiune_seq START WITH 50 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER optiune_supl_id_optiune_trg BEFORE
    INSERT ON optiune_supl
    FOR EACH ROW
    WHEN ( new.id_optiune IS NULL )
BEGIN
    :new.id_optiune := optiune_supl_id_optiune_seq.nextval;
END;
/

CREATE SEQUENCE propr_animal_id_proprietar_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER propr_animal_id_proprietar_trg BEFORE
    INSERT ON propr_animal
    FOR EACH ROW
    WHEN ( new.id_proprietar IS NULL )
BEGIN
    :new.id_proprietar := propr_animal_id_proprietar_seq.nextval;
END;
/

CREATE SEQUENCE rezervare_id_rezervare_seq START WITH 200 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER rezervare_id_rezervare_trg BEFORE
    INSERT ON rezervare
    FOR EACH ROW
    WHEN ( new.id_rezervare IS NULL )
BEGIN
    :new.id_rezervare := rezervare_id_rezervare_seq.nextval;
END;
/

CREATE SEQUENCE tip_cusca_id_tip_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tip_cusca_id_tip_trg BEFORE
    INSERT ON tip_cusca
    FOR EACH ROW
    WHEN ( new.id_tip IS NULL )
BEGIN
    :new.id_tip := tip_cusca_id_tip_seq.nextval;
END;
/

------------------------------------------------------------------

SELECT column_name FROM user_tab_columns WHERE table_name = 'PROPR_ANIMAL';
SELECT constraint_name, constraint_type, search_condition
FROM user_constraints
WHERE table_name = 'PROPR_ANIMAL';

ALTER TABLE detalii_propr
DROP CONSTRAINT detalii_prop_adresa_ck;

ALTER TABLE detalii_propr
DROP CONSTRAINT detalii_prop_telefon_ck;

SELECT table_name FROM user_tables WHERE table_name = 'DETALII_PROPR';
SELECT table_name FROM user_tables WHERE table_name = 'PROPR_ANIMAL';

SELECT constraint_name, constraint_type, search_condition
FROM user_constraints
WHERE table_name = 'DETALII_PROPR';

commit;
-- ca sa sterg autoincrementul si sa o iau de la inceput

DROP TABLE cusca CASCADE CONSTRAINTS;

DROP SEQUENCE cusca_nr_cusca_seq;

DROP TABLE cusca CASCADE CONSTRAINTS;

DROP TABLE rezervare CASCADE CONSTRAINTS;
DROP TRIGGER Trg2_rezervare_BRIU;
DROP TRIGGER Trg3_rezervare_BRIU;

DELETE FROM detalii_propr
WHERE adresa = 'Strada Aroneanu 4, bloc 320' 
AND telefon = '0734172992'
AND id_proprietar = (SELECT id_proprietar FROM propr_animal WHERE nume_prop = 'Timisag Crina-Maria');

SELECT constraint_name, constraint_type, search_condition
FROM user_constraints
WHERE table_name = 'ANIMAL';

ALTER TABLE animal DROP CONSTRAINT animal_rasa_ck;

DELETE FROM cusca
WHERE etaj = 1 AND id_tip = 1;

commit;