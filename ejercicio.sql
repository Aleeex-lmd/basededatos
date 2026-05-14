🧱 1. Crear el tablespace temporal TEMP2
CREATE TEMPORARY TABLESPACE TEMP2
TEMPFILE '/u01/app/oracle/oradata/ORCL/temp02.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;


🔹 Ajusta la ruta y tamaños según tu entorno (por ejemplo, /opt/oracle/oradata/...).

⚙️ 2. Generar el script para cambiar los usuarios

El siguiente SQL genera un conjunto de sentencias ALTER USER para todos los usuarios cuyo default tablespace sea USERS:

SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF
SPOOL cambiar_temp.sql

SELECT 'ALTER USER ' || username || ' TEMPORARY TABLESPACE TEMP2;'
FROM dba_users
WHERE default_tablespace = 'USERS';

SPOOL OFF

🧩 3. Ejecutar el script generado

Después de ejecutarlo, se creará un archivo llamado cambiar_temp.sql con líneas como:

ALTER USER HR TEMPORARY TABLESPACE TEMP2;
ALTER USER SCOTT TEMPORARY TABLESPACE TEMP2;
ALTER USER ALEX TEMPORARY TABLESPACE TEMP2;


Entonces puedes aplicarlo así:

@cambiar_temp.sql