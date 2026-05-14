-- Crea un rol ROLPRACTICA con los privilegios (no roles) necesarios para conectarse a la base de datos, crear tablas y vistas e insertar datos en la tabla EMP de SCOTT.
CREATE ROLE ROLPRACTICA;
GRANT CONNECT to ROLPRACTICA;
GRANT CREATE TABLE to ROLPRACTICA;
GRANT CREATE VIEW to ROLPRACTICA;
GRANT INSERT on SCOTT.EMP to ROLPRACTICA;

--     2. Crea un usuario USRPRACTICA con el tablespace USERS por defecto y averigua que cuota se le ha asignado por defecto en cada tablespace. Ponle una cuota de 1M en USERS.
CREATE USER USERPRACTICA IDENTIFIED BY "USERPRACTICA" DEFAULT TABLESPACE USERS; 

    SELECT tablespace_name, username, bytes, max_bytes
    FROM dba_ts_quotas;

    ALTER TABLESPACE "USERS" RESIZE 1G;

    -- no se puede porque es smallfile, habria que editar los datafiles uno a uno

-- Modifica el usuario USRPRACTICA para que tenga cuota 0 en el tablespace SYSTEM.
ALTER USER USERPRACTICA QUOTA 0 ON SYSTEM;

--    4. Concede a USRPRACTICA el ROLPRACTICA.
GRANT ROLPRACTICA to USERPRACTICA;

-- Concede a USRPRACTICA el privilegio de crear tablas, insertar y modificar datos en el esquema de cualquier otro usuario. Prueba el privilegio. Comprueba si puede modificar la estructura o eliminar las tablas creadas.
GRANT CREATE ANY TABLE to USERPRACTICA;
GRANT INSERT ANY TABLE to USERPRACTICA;
GRANT ALTER ANY TABLE to USERPRACTICA;

CREATE TABLE USERPRACTICA2.Prueba (
    NUMERO INT,
    NOMBRE VARCHAR2(4))
    TABLESPACE pruebadatafilesistem2
;
CREATE TABLESPACE pruebadatafilesistem
DATAFILE '/u01/app/oracle/oradata/XE/pruebadatafilesistem.dbf' SIZE 500M
AUTOEXTEND ON NEXT 100M MAXSIZE 800M
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 10M
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLE Prueba2 (
    NUMERO INT,
    NOMBRE VARCHAR2(4))
    TABLESPACE pruebadatafilesistem2
;

--- ERROR at line 1:
-- ORA-01950: no privileges on tablespace 'PRUEBADATAFILESISTEM'

CREATE USER USERPRACTICA2 IDENTIFIED BY "USERPRACTICA2" DEFAULT TABLESPACE USERS; 
GRANT CONNECT to USERPRACTICA2;
GRANT CREATE TABLE to USERPRACTICA2;
GRANT CREATE TABLESPACE to USERPRACTICA2;

CREATE TABLESPACE pruebadatafilesistem2q