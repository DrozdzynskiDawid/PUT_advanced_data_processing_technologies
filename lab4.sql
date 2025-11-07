-- A
CREATE TABLE FIGURY (
    id number(1) primary key,
    ksztalt sdo_geometry
);

-- B
-- koło
INSERT INTO figury VALUES(
  1,
  SDO_GEOMETRY(
    2003,
    NULL,
    NULL,
    SDO_ELEM_INFO_ARRAY(1,1003,4),
    SDO_ORDINATE_ARRAY(
        3,5,
        5,3,
        7,5
    )
  )
);
-- kwadrat
INSERT INTO FIGURY (ID, KSZTALT)
VALUES (
  2,
  MDSYS.SDO_GEOMETRY(
    2003,
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,1),
    MDSYS.SDO_ORDINATE_ARRAY(
      1,1, 
      5,1,
      5,5,
      1,5,
      1,1
    )
  )
);
-- figura nr 3
INSERT INTO FIGURY (ID, KSZTALT)
VALUES (
  3,
  MDSYS.SDO_GEOMETRY(
    2004,
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(
      1, 4, 3,
      1, 2, 1,
      3, 2, 1,
      5, 2, 2
    ),
    MDSYS.SDO_ORDINATE_ARRAY(
      3, 2,
      6, 2,
      7, 3,
      8, 2,
      7, 1
    )
  )
);

-- C
INSERT INTO FIGURY (ID, KSZTALT)
VALUES (
  4,
  MDSYS.SDO_GEOMETRY(
    2003,
    NULL,
    NULL,
    MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,1),
    MDSYS.SDO_ORDINATE_ARRAY(
      1,1, 
      5,1,
      5,5,
      1,5
    )
  )
);

-- D
SELECT
  ID,
  SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(KSZTALT, 0.001) AS WALIDACJA
FROM FIGURY;

-- E
DELETE FROM FIGURY WHERE id=4;
SELECT * FROM FIGURY;

-- F
COMMIT;
