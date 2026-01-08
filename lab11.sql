-- PART 1
-- zad.1
create table cytaty as select * from ztpd.cytaty;

-- zad.2
select autor, tekst from cytaty
where lower(tekst) like '%optymista%' and lower(tekst) like '%pesymista%';

-- zad.3
create index TEKST_IDX on cytaty(tekst)
indextype is CTXSYS.CONTEXT;

-- zad.4
select autor, tekst
from cytaty
where contains(tekst, 'optymista AND pesymista') > 0;

-- zad.5
select autor, tekst
from cytaty
where contains(tekst, 'pesymista NOT optymista') > 0;

-- zad.6
select autor, tekst
from cytaty
where contains(tekst, 'near((pesymista, optymista), 3)') > 0;

-- zad.7
select autor, tekst
from cytaty
where contains(tekst, 'near((pesymista, optymista), 10)') > 0;

-- zad.8
select autor, tekst
from cytaty
where contains(tekst, 'życi%') > 0;

-- zad.9
select autor, tekst, score(1) as dopasowanie
from cytaty
where contains(tekst, 'życi%', 1) > 0;

-- zad.10
select autor, tekst, score(1) as dopasowanie
from cytaty
where contains(tekst, 'życi%', 1) > 0
order by score(1) desc
fetch first 1 row only;

-- zad.11
select autor, tekst
from cytaty
where contains(tekst, 'fuzzy(probelm)') > 0;

-- zad.12
insert into cytaty
values (39, 'Bertrand Russell', 'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.');
commit;

-- zad.13
select autor, tekst
from cytaty
where contains(tekst, 'głupcy') > 0;
-- Zapytanie nie zwraca nic, ponieważ rekord został dodany po nałożeniu indeksu.

-- zad.14
select * from DR$TEKST_IDX$I order by token_text;

-- zad.15
drop index tekst_idx;
create index TEKST_IDX on cytaty(tekst)
indextype is CTXSYS.CONTEXT;

-- zad.16
select * from DR$TEKST_IDX$I where lower(token_text) = 'głupcy';

select autor, tekst
from cytaty
where contains(tekst, 'głupcy') > 0;

-- zad.17
drop index tekst_idx;
drop table cytaty;

-- PART 2
-- zad.1
create table quotes as select * from ztpd.quotes;

-- zad.2
create index text_idx on quotes(text)
indextype is CTXSYS.CONTEXT;

-- zad.3
select *
from quotes
where contains(text, 'work') > 0;

select *
from quotes
where contains(text, '$work') > 0;

select *
from quotes
where contains(text, 'working') > 0;

select *
from quotes
where contains(text, '$working') > 0;

-- zad.4
select *
from quotes
where contains(text, 'it') > 0;
-- System nie zwrócił wyników, ponieważ "it" jest na liście stop words, podczas tworzenia indeksu zostało zignorowane.

-- zad.5
select * from ctx_stoplists;
-- System wykorzystywał DEFAULT_STOPLIST.

-- zad.6
select * from ctx_stopwords;

-- zad.7
drop index text_idx;
create index text_idx on quotes(text)
indextype is CTXSYS.CONTEXT
parameters('stoplist CTXSYS.EMPTY_STOPLIST');

-- zad.8
select *
from quotes
where contains(text, 'it') > 0;
-- Tym razem są 4 rekordy w wyniku.

-- zad.9
select *
from quotes
where contains(text, 'fool AND humans') > 0;

-- zad.10
select *
from quotes
where contains(text, 'fool AND computer') > 0;

-- zad.11
select *
from quotes
where contains(text, '(fool AND humans) WITHIN SENTENCE') > 0;
-- ORA-29902: błąd podczas wykonywania podprogramu ODCIIndexStart()
--ORA-20000: Oracle Text error:
--DRG-10837: sekcja SENTENCE nie istnieje
--
--https://docs.oracle.com/error-help/db/ora-29902/29902. 00000 -  "Error while processing the ODCIINDEXSTART routine for index %s.%s.\n%s"
--*Cause:    Processing the ODCIINDEXSTART routine caused an error, or
--           its implementation returned the ODCI_ERROR return code.
--*Action:   Review the error messages associated with this error and take the
--           appropriate action to resolve them.
--*Params:   1) index_owner
--           2) index_name: The name of the index.
--           3) error_summary: A string describing the underlying errors
--           encountered by the ODCIINDEXSTART routine; either by being
--           raised from the implementation of the routine or by being
--           registered in the SYS.ODCI_WARNINGS$ table prior to
--           returning the ODCI_ERROR return code.

-- Nie istnieje sekcja SENTENCE, ponieważ nie została zdefiniowana przy tworzeniu indeksu.

-- zad.12
drop index text_idx;

-- zad.13
BEGIN
    CTX_DDL.CREATE_SECTION_GROUP('moje_sekcje', 'NULL_SECTION_GROUP');
    CTX_DDL.ADD_SPECIAL_SECTION('moje_sekcje', 'SENTENCE');
    CTX_DDL.ADD_SPECIAL_SECTION('moje_sekcje', 'PARAGRAPH');
END;

-- zad.14
create index text_idx on quotes(text)
indextype is CTXSYS.CONTEXT
parameters('section group moje_sekcje stoplist CTXSYS.EMPTY_STOPLIST');

-- zad.15
select *
from quotes
where contains(text, '(fool AND humans) WITHIN SENTENCE') > 0;

select *
from quotes
where contains(text, '(fool AND computer) WITHIN SENTENCE') > 0;
-- Po dodaniu sekcji zapytania działają.

-- zad.16
select *
from quotes
where contains(text, 'humans') > 0;
-- Tak, ponieważ dzieli 'non-humans' na kilka tokenów.

-- zad.17
drop index text_idx;

BEGIN
    CTX_DDL.CREATE_PREFERENCE('moj_lekser', 'BASIC_LEXER');
    CTX_DDL.SET_ATTRIBUTE('moj_lekser', 'printjoins', '-');
END;

create index text_idx on quotes(text)
indextype is CTXSYS.CONTEXT
parameters('section group moje_sekcje stoplist CTXSYS.EMPTY_STOPLIST lexer moj_lekser');

-- zad.18
select * from quotes where contains(text, 'humans') > 0;
-- Nie, tym razem system nie zwrócił rekordu z 'non-humans'.

-- zad.19
select * from quotes where contains(text, 'non\-humans') > 0;

-- zad.20
drop index text_idx;
drop table quotes;
BEGIN
    CTX_DDL.DROP_PREFERENCE('moj_lekser');
    CTX_DDL.DROP_SECTION_GROUP('moje_sekcje');

END;
