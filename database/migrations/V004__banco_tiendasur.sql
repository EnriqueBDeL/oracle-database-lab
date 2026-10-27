-- database/migrations/V004__banco_tiendasur.sql
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = FREEPDB1;

-- 1. Tablespace Bigfile
DECLARE n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM dba_tablespaces WHERE tablespace_name = 'TBS_TIENDASUR';
  IF n = 0 THEN
    EXECUTE IMMEDIATE 'CREATE BIGFILE TABLESPACE tbs_tiendasur DATAFILE ''/opt/oracle/oradata/FREE/FREEPDB1/tbs_tiendasur01.dbf'' SIZE 256M AUTOEXTEND ON NEXT 64M MAXSIZE 2G';
  END IF;
END;
/

-- 2. Usuario de esquema sin contraseña
DECLARE n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM dba_users WHERE username = 'TIENDASUR';
  IF n = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER tiendasur NO AUTHENTICATION DEFAULT TABLESPACE tbs_tiendasur QUOTA UNLIMITED ON tbs_tiendasur';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE CLUSTER TO tiendasur';
  END IF;
END;
/

-- 3. Estructura de cliente y pedido con sus índices heredados
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE tiendasur.cliente (
    id_cliente NUMBER PRIMARY KEY,
    dni VARCHAR2(10),
    email VARCHAR2(100),
    nombre VARCHAR2(50),
    apellidos VARCHAR2(100),
    telefono VARCHAR2(20),
    pais VARCHAR2(2),
    ciudad VARCHAR2(50),
    fecha_alta DATE
  )';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX tiendasur.ux_cli_email ON tiendasur.cliente(email)';
  EXECUTE IMMEDIATE 'CREATE INDEX tiendasur.ix_cli_pais_ciudad ON tiendasur.cliente(pais, ciudad)';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE tiendasur.pedido (
    id_pedido NUMBER PRIMARY KEY,
    id_cliente NUMBER NOT NULL CONSTRAINT fk_ped_cliente REFERENCES tiendasur.cliente(id_cliente),
    fecha_pedido TIMESTAMP WITH TIME ZONE NOT NULL,
    estado CHAR(1) NOT NULL,
    importe NUMBER(10,2) NOT NULL,
    canal CHAR(1) NOT NULL,
    codigo_postal VARCHAR2(10)
  )';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX tiendasur.ix_ped_cliente ON tiendasur.pedido(id_cliente)';
  EXECUTE IMMEDIATE 'CREATE INDEX tiendasur.ix_ped_fecha ON tiendasur.pedido(fecha_pedido)';
  EXECUTE IMMEDIATE 'CREATE INDEX tiendasur.ix_ped_importe ON tiendasur.pedido(importe)';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- 4. Carga determinista de 100.000 clientes
INSERT /*+ APPEND */ INTO tiendasur.cliente
SELECT n AS id_cliente,
       LPAD(TO_CHAR(n), 8, '0') || CHR(65 + MOD(n, 23)) AS dni,
       'cliente' || n || '@tiendasur.es' AS email,
       'Cliente' || n AS nombre,
       CASE WHEN MOD(ORA_HASH(n, 100, 1), 50) = 0 THEN 'Gonzalez' ELSE 'Apellido' || MOD(n, 500) END AS apellidos,
       '600' || LPAD(TO_CHAR(n), 6, '0') AS telefono,
       CASE WHEN ORA_HASH(n, 100, 2) <= 60 THEN 'ES' ELSE 'FR' END AS pais,
       CASE WHEN n <= 100 THEN 'Lorca' ELSE 'Ciudad' || MOD(n, 1000) END AS ciudad,
       TRUNC(SYSDATE - 365 + MOD(n, 365)) AS fecha_alta
FROM (SELECT LEVEL AS n FROM DUAL CONNECT BY LEVEL <= 100000)
WHERE NOT EXISTS (SELECT 1 FROM tiendasur.cliente WHERE ROWNUM = 1);
COMMIT;

-- 5. Carga determinista de 1.000.000 pedidos
INSERT /*+ APPEND */ INTO tiendasur.pedido
SELECT n AS id_pedido,
       MOD(ORA_HASH(n, 100000, 3), 100000) + 1 AS id_cliente,
       TIMESTAMP '2025-01-01 00:00:00 UTC' + NUMTODSINTERVAL(n * 31.5, 'SECOND') AS fecha_pedido,
       CASE
         WHEN MOD(ORA_HASH(n, 100, 4), 100) < 2 THEN 'P'
         WHEN MOD(ORA_HASH(n, 100, 4), 100) < 7 THEN 'E'
         WHEN MOD(ORA_HASH(n, 100, 4), 100) < 97 THEN 'C'
         ELSE 'D'
       END AS estado,
       ROUND(10 + MOD(ORA_HASH(n, 500, 5), 490), 2) AS importe,
       CASE WHEN MOD(n, 3) = 0 THEN 'W' WHEN MOD(n, 3) = 1 THEN 'A' ELSE 'T' END AS canal,
       TO_CHAR(30000 + MOD(n, 1000)) AS codigo_postal
FROM (SELECT LEVEL AS n FROM DUAL CONNECT BY LEVEL <= 1000000)
WHERE NOT EXISTS (SELECT 1 FROM tiendasur.pedido WHERE ROWNUM = 1);
COMMIT;

-- 6. Estadísticas e histogramas
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS('TIENDASUR', 'CLIENTE', cascade => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1 FOR COLUMNS SIZE 254 pais ciudad');
  DBMS_STATS.GATHER_TABLE_STATS('TIENDASUR', 'PEDIDO', cascade => TRUE,
    method_opt => 'FOR ALL COLUMNS SIZE 1 FOR COLUMNS SIZE 254 estado canal');
END;
/
