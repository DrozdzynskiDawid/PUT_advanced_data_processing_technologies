-- Ćwiczenie 1
-- A
INSERT INTO USER_SDO_GEOM_METADATA
    VALUES (
    'FIGURY',
    'KSZTALT',
    MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', 0, 9, 0.01),
        MDSYS.SDO_DIM_ELEMENT('Y', 0, 8, 0.01)
        ),
        NULL
);

-- B
SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000,8192,10,2,0) FROM FIGURY;

-- C
CREATE INDEX FIGURY_IDX
ON FIGURY(KSZTALT)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

-- D
SELECT ID FROM FIGURY
WHERE SDO_FILTER(KSZTALT, SDO_GEOMETRY(2001, null, SDO_POINT_TYPE(3,3,null), null, null)) = 'TRUE';
-- W wyniku są wszystkie figury, ponieważ SDO_FILTER korzysta ze zbioru kandydatów pierwszej fazy zapytania

-- E
SELECT ID FROM FIGURY
WHERE SDO_RELATE(KSZTALT, SDO_GEOMETRY(2001, null, SDO_POINT_TYPE(3,3,null), null, null), 'mask=ANYINTERACT') = 'TRUE';
-- W tym przypadku wynik jest zgodny z rzeczywistością


-- Ćwiczenie 2
-- A
SELECT
    neighbors.CITY_NAME as MIASTO,
    ROUND(SDO_NN_DISTANCE(1)) AS ODL
FROM
    MAJOR_CITIES neighbors,
    MAJOR_CITIES warsaw
WHERE
    warsaw.CITY_NAME = 'Warsaw'
AND
    SDO_NN(
        neighbors.GEOM,
        warsaw.GEOM,
        'sdo_num_res=10 unit=km',
        1
    ) = 'TRUE'
AND
    neighbors.CITY_NAME != 'Warsaw';
    
-- B
SELECT
    neighbors.CITY_NAME as MIASTO
FROM
    MAJOR_CITIES neighbors,
    MAJOR_CITIES warsaw
WHERE
    warsaw.CITY_NAME = 'Warsaw'
AND
    SDO_WITHIN_DISTANCE(
        neighbors.GEOM,
        warsaw.GEOM,
        'distance=100 unit=km'
    ) = 'TRUE'
AND
    neighbors.CITY_NAME != 'Warsaw';
    
-- C
SELECT
    b.CNTRY_NAME as KRAJ,
    c.CITY_NAME as MIASTO
FROM
    COUNTRY_BOUNDARIES b,
    MAJOR_CITIES c
WHERE
    b.CNTRY_NAME = 'Slovakia'
AND
    SDO_RELATE(
        b.GEOM,
        c.GEOM,
        'mask=CONTAINS'
    ) = 'TRUE';

-- D
SELECT
    other.CNTRY_NAME as PANSTWO,
    ROUND(SDO_GEOM.SDO_DISTANCE(
        poland.GEOM,
        other.GEOM,
        0.001,
        'unit=km'
    )) AS ODL
FROM
    COUNTRY_BOUNDARIES poland,
    COUNTRY_BOUNDARIES other
WHERE
    poland.CNTRY_NAME = 'Poland'
    AND other.CNTRY_NAME != 'Poland'
    AND other.CNTRY_NAME NOT IN (
        SELECT
            neighbors.CNTRY_NAME
        FROM
            COUNTRY_BOUNDARIES poland_inner,
            COUNTRY_BOUNDARIES neighbors
        WHERE
            poland_inner.CNTRY_NAME = 'Poland'
            AND neighbors.CNTRY_NAME != 'Poland'
            AND SDO_RELATE(
                    poland_inner.GEOM,
                    neighbors.GEOM,
                    'mask=TOUCH'
                ) = 'TRUE'
    );
    
-- Ćwiczenie 3
-- A
SELECT B.CNTRY_NAME, ROUND(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(A.GEOM, B.GEOM, 1), 1, 'unit=km')) as ODLEGLOSC
FROM COUNTRY_BOUNDARIES A, COUNTRY_BOUNDARIES B
WHERE A.CNTRY_NAME = 'Poland' AND ROUND(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(A.GEOM, B.GEOM, 1), 1, 'unit=km')) > 0 AND B.CNTRY_NAME != 'Poland';

-- B
SELECT CNTRY_NAME FROM (
    SELECT A.CNTRY_NAME,
        ROUND(SDO_GEOM.sdo_area(A.GEOM, 1, 'unit=SQ_KM')) POWIERZCHNIA
    FROM COUNTRY_BOUNDARIES A
    ORDER BY 2 DESC
    FETCH FIRST 1 ROW ONLY
);

-- C
SELECT
    ROUND(
        SDO_GEOM.SDO_AREA(
            (SELECT SDO_AGGR_MBR(c.GEOM)
             FROM MAJOR_CITIES c
             WHERE c.CITY_NAME IN ('Warsaw', 'Lodz')),
            1,
            'unit=SQ_KM'
        )
    ) AS SQ_KM
FROM
    DUAL;
    
-- D
SELECT
    SDO_GEOM.SDO_UNION(p.GEOM, c.GEOM).SDO_GTYPE AS GTYPE
FROM
    COUNTRY_BOUNDARIES p,
    MAJOR_CITIES c
WHERE
    p.CNTRY_NAME = 'Poland'
    AND c.CITY_NAME = 'Prague';

-- E
SELECT
    c.CITY_NAME,
    b.CNTRY_NAME
FROM
    MAJOR_CITIES c,
    COUNTRY_BOUNDARIES b
WHERE
    SDO_CONTAINS(b.GEOM, c.GEOM) = 'TRUE'
ORDER BY
        ROUND(SDO_GEOM.SDO_DISTANCE(
        c.GEOM,
        SDO_GEOM.SDO_CENTROID(b.GEOM, 1),
        0.001,
        'unit=km'
    )) ASC
FETCH FIRST 1 ROW ONLY;

-- F
SELECT
    r.NAME,
    SUM(ROUND(
        SDO_GEOM.SDO_LENGTH(
            SDO_GEOM.SDO_INTERSECTION(r.GEOM, p.GEOM, 0.001),
            1
        ) / 1000
    , 2)) AS DLUGOSC
FROM
    RIVERS r,
    COUNTRY_BOUNDARIES p
WHERE
    p.CNTRY_NAME = 'Poland'
AND
    SDO_ANYINTERACT(r.GEOM, p.GEOM) = 'TRUE'
GROUP BY r.NAME;