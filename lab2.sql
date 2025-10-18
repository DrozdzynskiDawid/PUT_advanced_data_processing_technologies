-- zad. 1 i 2
create table movies as select * from ztpd.movies;
-- zad. 3
select id, title from movies where cover is null;
-- zad. 4
select id, title, DBMS_LOB.GETLENGTH(cover) as filesize from movies where cover is not null;
-- zad. 5
select id, title, DBMS_LOB.GETLENGTH(cover) as filesize from movies where cover is null;
-- zad. 6
select * from all_directories;
-- /u01/app/oracle/oradata/DBLAB03/directories/tpd_dir
-- zad. 7
update movies set cover = EMPTY_BLOB(), mime_type = 'image/jpeg' where id = 66;
-- zad. 8
select id, title, DBMS_LOB.GETLENGTH(cover) as filesize from movies where id in (65,66);
-- zad. 9
DECLARE
    lobd blob;
    fils BFILE := BFILENAME('TPD_DIR','escape.jpg');
BEGIN
    SELECT cover INTO lobd FROM movies where id=66 FOR UPDATE;
    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(lobd,fils,DBMS_LOB.GETLENGTH(fils));
    DBMS_LOB.FILECLOSE(fils);
    COMMIT;
END;
/
-- zad. 10
create table temp_covers (
    movie_id number(12),
    image BFILE,
    mime_type varchar2(50)
);
-- zad. 11
DECLARE
    fils BFILE := BFILENAME('TPD_DIR','eagles.jpg');
BEGIN
    INSERT INTO temp_covers values(65, fils, 'image/jpeg');
    COMMIT;
END;
/
-- zad. 12
select movie_id, DBMS_LOB.GETLENGTH(image) as filesize from temp_covers where movie_id = 65;
-- zad. 13
DECLARE
    temp blob;
    fils BFILE;
    mimetype varchar2(100);
BEGIN
    SELECT image, mime_type INTO fils, mimetype FROM temp_covers where movie_id = 65 FOR UPDATE;
    dbms_lob.createtemporary(temp, TRUE);
    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(temp,fils,DBMS_LOB.GETLENGTH(fils));
    DBMS_LOB.FILECLOSE(fils);
    UPDATE movies SET cover = temp, mime_type = mimetype WHERE id = 65;
    dbms_lob.freetemporary(temp);
    COMMIT;
END;
/
-- zad. 14
select id, title, DBMS_LOB.GETLENGTH(cover) as filesize from movies where id in (65,66);
-- zad. 15
drop table movies;