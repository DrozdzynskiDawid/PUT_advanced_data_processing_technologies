-- Ćwiczenie 1
-- A
select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||
', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
from all_types t
start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name
 and prior t.owner = t.owner;
 
-- B
select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
and m.owner = 'MDSYS'
order by 1;

-- C
create table MYST_MAJOR_CITIES(
    FIPS_CNTRY VARCHAR2(2),
    CITY_NAME VARCHAR2(40),
    STGEOM ST_POINT
);

-- D
insert into myst_major_cities
select fips_cntry, city_name, st_point(geom) from ztpd.MAJOR_CITIES;

select * from myst_major_cities;

-- Ćwiczenie 2
-- A
INSERT INTO MYST_MAJOR_CITIES
VALUES (
    'PL',
    'Szczyrk', 
    ST_POINT(19.036107, 49.718655, 8307)
);

-- Ćwiczenie 3
-- A
create table MYST_COUNTRY_BOUNDARIES(
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM ST_MULTIPOLYGON
);

-- B
insert into myst_country_boundaries
select fips_cntry, cntry_name, st_multipolygon(geom) from country_boundaries;

select * from myst_country_boundaries;

-- C
select a.STGEOM.ST_GeometryType() as TYP_OBIEKTU, count(*) as ILE
from myst_country_boundaries a
group by a.STGEOM.ST_GeometryType();

-- D
select a.STGEOM.ST_ISSIMPLE()
from myst_country_boundaries a;
-- Tak, wszystkie są uznawane za proste

-- Ćwiczenie 4
-- A
SELECT b.CNTRY_NAME, COUNT(c.CITY_NAME) AS LICZBA_MIAST
FROM MYST_COUNTRY_BOUNDARIES b, MYST_MAJOR_CITIES c
WHERE b.STGEOM.ST_Contains(c.STGEOM) = 1
GROUP BY b.CNTRY_NAME;

-- B
SELECT a.CNTRY_NAME, b.CNTRY_NAME
FROM MYST_COUNTRY_BOUNDARIES a, MYST_COUNTRY_BOUNDARIES b
WHERE b.CNTRY_NAME = 'Czech Republic' AND b.STGEOM.ST_Touches(a.STGEOM) = 1;

-- C
SELECT DISTINCT a.CNTRY_NAME, r.name
FROM MYST_COUNTRY_BOUNDARIES a, RIVERS r
WHERE a.CNTRY_NAME = 'Czech Republic' AND a.STGEOM.ST_Crosses(ST_LINESTRING(r.GEOM)) = 1;

-- D
SELECT a.STGEOM.ST_Area() + b.STGEOM.ST_Area() AS powierzchnia
FROM MYST_COUNTRY_BOUNDARIES a, MYST_COUNTRY_BOUNDARIES b
WHERE a.CNTRY_NAME = 'Czech Republic' 
AND b.CNTRY_NAME = 'Slovakia';

-- E
SELECT a.STGEOM.ST_Difference(st_multipolygon(b.GEOM)) AS wegry_bez_balatonu
FROM MYST_COUNTRY_BOUNDARIES a, WATER_BODIES b
WHERE a.CNTRY_NAME = 'Hungary' 
AND b.NAME = 'Balaton';
-- ST_POLYGON

-- Ćwiczenie 5
-- A
EXPLAIN PLAN FOR
SELECT b.CNTRY_NAME AS NAME, COUNT(*) AS LICZBA_MIAST
FROM MYST_MAJOR_CITIES c, MYST_COUNTRY_BOUNDARIES b
WHERE b.CNTRY_NAME = 'Poland'
AND SDO_WITHIN_DISTANCE(c.STGEOM, b.STGEOM, 'distance=100 unit=km') = 'TRUE'
GROUP BY(b.CNTRY_NAME);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- B
INSERT INTO USER_SDO_GEOM_METADATA (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID)
VALUES (
    'MYST_MAJOR_CITIES',
    'STGEOM',
    SDO_DIM_ARRAY(
        SDO_DIM_ELEMENT('X', -180, 180, 1),
        SDO_DIM_ELEMENT('Y', -90, 90, 1)
        ),
    8307
);

INSERT INTO USER_SDO_GEOM_METADATA (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID)
VALUES (
    'MYST_COUNTRY_BOUNDARIES',
    'STGEOM',
    SDO_DIM_ARRAY(
        SDO_DIM_ELEMENT('X', -180, 180, 1),
        SDO_DIM_ELEMENT('Y', -90, 90, 1)
    ),
    8307
);

-- C
CREATE INDEX CITIES_IDX
ON MYST_MAJOR_CITIES(STGEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

CREATE INDEX COUNTRIES_IDX
ON MYST_COUNTRY_BOUNDARIES(STGEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

-- D
SELECT b.CNTRY_NAME AS NAME, COUNT(*) AS LICZBA_MIAST
FROM MYST_MAJOR_CITIES c, MYST_COUNTRY_BOUNDARIES b
WHERE b.CNTRY_NAME = 'Poland'
AND SDO_WITHIN_DISTANCE(c.STGEOM, b.STGEOM, 'distance=100 unit=km') = 'TRUE'
GROUP BY(b.CNTRY_NAME);

EXPLAIN PLAN FOR
SELECT b.CNTRY_NAME AS NAME, COUNT(*) AS LICZBA_MIAST
FROM MYST_MAJOR_CITIES c, MYST_COUNTRY_BOUNDARIES b
WHERE b.CNTRY_NAME = 'Poland'
AND SDO_WITHIN_DISTANCE(c.STGEOM, b.STGEOM, 'distance=100 unit=km') = 'TRUE'
GROUP BY(b.CNTRY_NAME);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- indeksy są wykorzystywane

