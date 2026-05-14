# Oracle

## Crea un rol ROLPRACTICA con los privilegios (no roles) necesarios para conectarse a la base de datos, crear tablas y vistas e insertar datos en la tabla EMP de SCOTT.

```sql
-- creamos el rol
CREATE ROLE ROLPRACTICA;

-- le damos los privilegios sobre el sistema
GRANT CREATE SESSION TO ROLPRACTICA;
GRANT CREATE TABLE TO ROLPRACTICA;
GRANT CREATE VIEW TO ROLPRACTICA;

-- le damos los privilegios sobre la tabla emp de scott
GRANT INSERT ON SCOTT.EMP TO ROLPRACTICA;
```

## Crea un usuario USRPRACTICA con el tablespace USERS por defecto y averigua que cuota se le ha asignado por defecto en cada tablespace. Ponle una cuota de 1M en USERS

```sql
CREATE USER USERPRACTICA 
IDENTIFIED BY "contraseña"
DEFAULT TABLESPACE users;


SELECT tablespace_name,
       bytes,
       max_bytes
FROM dba_ts_quotas
WHERE username = 'USERPRACTICA';

DROP USER USERPRACTICA;

CREATE USER USERPRACTICA 
IDENTIFIED BY "contraseña"
DEFAULT TABLESPACE users
QUOTA 1M ON users;
```

## Modifica el usuario USRPRACTICA para que tenga cuota 0 en el tablespace SYSTEM

```sql
ALTER USER USERPRACTICA
QUOTA 0 ON SYSTEM;


SELECT username,
       tablespace_name,
       max_bytes
FROM dba_ts_quotas
WHERE username = 'USERPRACTICA';

SELECT username,
       tablespace_name,
       max_bytes
FROM dba_ts_quotas
WHERE username = 'USERPRACTICA'
  AND tablespace_name = 'SYSTEM';
```

## Concede a USRPRACTICA el ROLPRACTICA.

```
GRANT ROLPRACTICA TO USERPRACTICA;
```