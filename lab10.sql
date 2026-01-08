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

