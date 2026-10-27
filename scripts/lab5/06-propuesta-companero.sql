-- scripts/lab5/06-propuesta-companero.sql
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = FREEPDB1;
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX tiendasur.ix_ped_estado ON tiendasur.pedido (estado)';
  EXECUTE IMMEDIATE 'CREATE INDEX tiendasur.ix_ped_canal ON tiendasur.pedido (canal)';
  EXECUTE IMMEDIATE 'CREATE INDEX tiendasur.ix_ped_cp_bad ON tiendasur.pedido (codigo_postal)';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
EXIT
