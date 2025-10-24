-- zad.1
create table DOKUMENTY (
    id number(12) primary key,
    dokument CLOB
);

-- zad.2
DECLARE
    temp CLOB;
BEGIN
    temp := '';
    FOR i IN 1..10000 LOOP
        temp := temp || 'Oto tekst. ';
    END LOOP;
    
    INSERT INTO DOKUMENTY VALUES (1, temp);
    COMMIT;
END;
/

-- zad.3
select * from dokumenty;
select upper(dokument) as tresc from dokumenty;
select length(dokument) as rozmiar from dokumenty;
select dbms_lob.getlength(dokument) as rozmiar from dokumenty;
select substr(dokument,5,1000) as fragment from dokumenty;
select dbms_lob.substr(dokument,1000,5) as fragment from dokumenty;

-- zad.4
INSERT INTO DOKUMENTY VALUES (2, EMPTY_CLOB());

-- zad.5
INSERT INTO DOKUMENTY VALUES (3, NULL);
COMMIT;

-- zad.6
select * from dokumenty;
select upper(dokument) as tresc from dokumenty;
select length(dokument) as rozmiar from dokumenty;
select dbms_lob.getlength(dokument) as rozmiar from dokumenty;
select substr(dokument,5,1000) as fragment from dokumenty;
select dbms_lob.substr(dokument,1000,5) as fragment from dokumenty;

-- zad.7
DECLARE
    lobd clob;
    fils BFILE := BFILENAME('TPD_DIR','dokument.txt');
    doffset integer := 1;
    soffset integer := 1;
    langctx integer := 0;
    warn integer := null;
BEGIN
    SELECT dokument INTO lobd FROM dokumenty WHERE id=2 FOR UPDATE;
    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADCLOBFROMFILE(lobd, fils, DBMS_LOB.LOBMAXSIZE, doffset, soffset, 873, langctx, warn); -- 873 to utf-8
    DBMS_LOB.FILECLOSE(fils);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Status operacji: '||warn);
END;
/

-- zad.8
UPDATE dokumenty SET dokument = BFILENAME('TPD_DIR','dokument.txt')
WHERE id=3;

-- zad.9
select * from dokumenty;

-- zad.10
select dbms_lob.getlength(dokument) as rozmiar from dokumenty;

-- zad.11
DROP TABLE dokumenty;

-- zad.12
CREATE OR REPLACE FUNCTION CLOB_CENSOR (
    clob_object IN OUT CLOB,
    text IN VARCHAR2
) RETURN CLOB IS
    position INTEGER := 1;
    v_text_length INTEGER := LENGTH(text);
    v_replacement VARCHAR2(4000);
BEGIN
    v_replacement := RPAD('.', v_text_length, '.');
    
    LOOP
        position := INSTR(clob_object, text, position);
        EXIT WHEN position = 0;

        DBMS_LOB.WRITE(clob_object, v_text_length, position, v_replacement);
        position := position + v_text_length;
    END LOOP;

    RETURN clob_object;
END CLOB_CENSOR;
/

-- zad.13
create table biographies as select * from ztpd.biographies;
select * from biographies;

DECLARE
    v_clob CLOB;
BEGIN
    SELECT bio INTO v_clob FROM biographies where id = 1 for update;

    v_clob := CLOB_CENSOR(v_clob, 'Cimrman');

    UPDATE biographies SET bio = v_clob where id = 1;
    COMMIT;
END;
/

select * from biographies;

-- zad.14
drop table biographies;
