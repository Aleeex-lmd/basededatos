## Realiza una copia de seguridad lógica de tu base de datos completa, teniendo en cuenta los siguientes requisitos:

- La copia debe estar encriptada y comprimida.
- Debe realizarse en un conjunto de ficheros con un tamaño máximo de 75 MB.
- Programa la operación para que se repita cada día a una hora determinada.


Lo primero que aremos sera definir el directorio para el backup

```sql
CREATE OR REPLACE DIRECTORY BACKUP_DIR AS '/u01/app/oracle/fast_recovery_area/XE/backup';
```

- Ahora que lo tenemos definido crearemos la copia de respaldo con las condiciones que se nos han puesto

```sql
expdp system/asangom04 FULL=Y DIRECTORY=BACKUP_DIR DUMPFILE=backup_oracle_$(date +%H-%M%d_%m_%Y)_%U.dmp LOGFILE=backup_oracle.log FILESIZE=75M COMPRESSION=ALL ENCRYPTION=ALL ENCRYPTION_PASSWORD=micontraseña
```

- Ahora explicaremos el comando por partes

    - expdp → Es la herramienta de Oracle Data Pump Export. Sirve para hacer una copia lógica de la base de datos (estructura + datos).
    - system → usuario de Oracle con permisos de exportación
    - asangom04 → contraseña del usuario
    - FULL=Y Para que el backup sea de la estructura logica la forma de hacerse es esta, en caso de que fuese solo de metadatos deberiamos poner "Metadatas Only"
    - DIRECTORY=BACKUP_DIR Es el directorio en el cual vamos a guardar vamos a guardar los backups, este directorio lo definimos anteriormente
    - DUMPFILE=backup_oracle_$(date +%H-%M_%d_%m_%Y)_%U.dmp Con esto definimos el nombre del backup, esta puesto asi para que el backup se guarde con la fecha en la que se ha realizado
    - LOGFILE=backup_oracle.log Es el archivo donde se guardan los logs de los backups, por si ocurre algun error que quede registrado
    - FILESIZE=75M Establecemos el tamaño máximo que tendra el archivo de backup, este no podrá superar los 75mb
    - COMPRESSION=ALL Esto es para que comprima todo el backup y no solo los metadatos
    - ENCRYPTION=ALL Lo mismo pero aplicado a la encriptación 
    - ENCRYPTION_PASSWORD=micontraseña Estqblecemos la contraseña para el cifrado, sin esta no podremos ver el contenidode nuestro backup

- Ahora que ya sabemos como funciona el comando de backup lo programaremos para que este se ejecute todos los días a la misma hora

# Usar crom

```sql
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'BACKUP_DIARIO',
    job_type        => 'EXECUTABLE',
    job_action      => '/bin/bash',
    number_of_arguments => 2,
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY;BYHOUR=2;BYMINUTE=0;BYSECOND=0',
    enabled         => FALSE
  );

  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('BACKUP_DIARIO',1,'-c');

  DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE(
    'BACKUP_DIARIO',
    2,
    'expdp system/asangom04 FULL=Y DIRECTORY=BACKUP_DIR DUMPFILE=backup_oracle_$(date +%H-%M%d_%m_%Y)_%U.dmp LOGFILE=backup_oracle.log FILESIZE=75M COMPRESSION=ALL ENCRYPTION=ALL ENCRYPTION_PASSWORD=micontraseña'
  );

  DBMS_SCHEDULER.ENABLE('BACKUP_DIARIO');
END;
/
```

- Ahora explicaremos como funciona
    - Usamos DBMS_SCHEDULER.CREATE_JOB porque es la opción más sencilla para crear una tarea programada desde oracle
    - Con job_name le damos nombre a la tarea
    - Con job_type le decimos que va a ser un ejecutable, o sea un comando que va a tener que ejecutar
    - Con job_action seleccionamos como será la ejecución, en este caso será en bash
    - Los argumentos son dos, el primero qe es para que use bash -c u el ejecutor del comando
    - El start_date es para que tome la hora actual como referencia
    - El repeat_interval es para hacer que se repita diariamente a las dos de la mañana
    - El enabled false es para que cree el job pero que no lo comience a ejecutar directamente
    - El primer argumento sirve para configurar el proximo comando, hace que sea un /bin/bash -c, si este no tuviera el -c el comando no funcionaría correctamente
    - Y el segundo argumento ya es para crear el backup
    - Al finar cuando ya está todo cofigurado lo activamos

## Restaura la copia de seguridad lógica creada en el punto anterior

```
expdp system/asangom04 FULL=Y DIRECTORY=BACKUP_DIR DUMPFILE=backup_oracle_11_05_2026_%U.dmp LOGFILE=backup_oracle.log FILESIZE=75M COMPRESSION=ALL ENCRYPTION=ALL ENCRYPTION_PASSWORD=micontraseña
```

Con esto ya habriamos restaurado la copia de seguridad

## Pon tu base de datos en modo ArchiveLog y realiza con RMAN una copia de seguridad física en caliente

- Primero comprobaremos el estado de la base de datos para que se vea que aún no está en modo ArchiveLog

- En este comando nos tenemos que fijar en la colomna ARCHIVER

```sql
select * from v$instance;
```

- Y en este nos tenemos que fijar enla columna LOG_MODE

```sql
select name, log_mode from v$database;
```

- Tambien lo podemos ver con el siguiente comando

```sql
archive log list
```

- Ahora que ya hemos visto que la base de datos no está en modo archive log lo que haremos es detener la instancia

```
shutdown immediate
```

- Y la montamos con el siguiente comando

```sql
startup mount
```

- Ahora que ya tenemos la base de datos montada la ponemos en modo ArchiveLog

```sql
alter database archivelog;
```

- Y la abrimos para que los usuarios puedan conectarse

```sql
alter database open;
```

- Ahora podemos ver que esta en modo ArchiveLog con los siguientes comandos, uno que usa select y otro que no necesita select

- Como vemos, está en modo ArchiveLog

```sql
select name, log_mode from v$database;
```

- Tambien se puede ver de la siguiente forma

```sql
archive log list
```

- Podemos ver el destino de los ficheros de log si nos fijamos en la linea `db_recovery_file_dest` del siguiente comando

```sql
show parameter db_recovery_file_dest
```

- Y podemos comprobar que verdaderamente estan ahí usando un comando tan sencillo como puede ser un `ls`

- Tambien podríamos cambiar el lugar donde se guardan, o añadir otro se puede hacer de la siguiente forma (el máximo son 30) usando el siguiente comando

```sql
ALTER SYSTEM SET log_archive_dest_1='LOCATION=';
```

- A continuación usaremos RMAN para hacer una copia de seguiridad en caliente

```
rman
```

- Seleccionaremos el target que en este caso será la raíz 

```sql
CONNECT TARGET /
```

- Y hacemos backup con el siguiente comando

```
BACKUP DATABASE;
```

- Cuando termine comprobamos que se ha hecho la copia de seguridad


