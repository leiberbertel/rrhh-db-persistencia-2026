# Base de datos RRHH con Docker (MySQL 8.4)

Proyecto académico — Politécnico Grancolombiano <br>
Módulo **Persistencia de Datos y Transaccionalidad** — Entrega 2: Modelo de Recursos Humanos.

Esta carpeta levanta un servidor **MySQL 8.4** dentro de Docker y crea automáticamente:

- la base de datos **`rrhh`** (utf8mb4 / utf8mb4_unicode_ci)
- el usuario **`poli01`** con permisos sobre `rrhh`
- las tablas (`init/02_tablas.sql`) y los datos de prueba (`init/03_datos.sql`)

No hace falta instalar MySQL Server en Windows. Solo se necesita **Docker Desktop**.

---

## Contenido del repositorio

```
.
├── docker-compose.yml   ← configuración del contenedor MySQL
├── .env.example         ← plantilla de variables (claves y puerto)
├── .env                 ← sus valores locales (NO se sube a git; cada uno crea el suyo)
├── .gitignore
├── README.md
└── init/                ← scripts que MySQL ejecuta en orden la primera vez
    ├── 01_setup.sql     ← crea la base rrhh y da permisos a poli01
    ├── 02_tablas.sql    ← CREATE TABLE del modelo
    └── 03_datos.sql     ← INSERT de datos de prueba
```

## Datos de conexión

| Campo      | Valor                                         |
|------------|-----------------------------------------------|
| Host       | `127.0.0.1`                                   |
| Puerto     | `3306` (o el valor de `MYSQL_PORT` en `.env`) |
| Usuario    | `poli01`                                      |
| Contraseña | el valor de `POLI01_PASSWORD` en su `.env`    |
| Base       | `rrhh`                                        |
| Root       | usuario `root`, clave `MYSQL_ROOT_PASSWORD` del `.env` |

> **Las contraseñas no están en el repositorio.** Cada integrante las define en su propio `.env`. El usuario `poli01` lo crea la imagen de MySQL con `POLI01_PASSWORD`, y `init/01_setup.sql` le da los permisos. Si cambia una clave en `.env` después de la primera ejecución, debe reiniciar desde cero (ver más abajo) para que aplique.
>
> MySQL solo acepta conexiones desde el mismo PC (`127.0.0.1`), no desde otros equipos de la red.

---

## 1. Requisitos

- **Windows 10 (versión 22H2) u 11**, 64 bits.
- **Virtualización activada en la BIOS/UEFI** (Intel VT-x o AMD-V / SVM).
  Para comprobarlo: `Ctrl + Shift + Esc` → pestaña **Rendimiento** → **CPU** → debe decir *Virtualización: Habilitado*.
  Si dice *Deshabilitado*, reinicie el PC, entre a la BIOS (normalmente con `F2`, `F10`, `Supr` o `Esc`) y active la opción *Intel Virtualization Technology* o *SVM Mode*.
- **WSL2** (Subsistema de Windows para Linux). Abra **PowerShell como administrador** y ejecute:

  ```powershell
  wsl --install
  ```

  Reinicie el PC cuando lo pida. Para confirmar:

  ```powershell
  wsl --status
  ```

  Debe decir *Versión predeterminada: 2*. Si no, ejecute `wsl --update` y luego `wsl --set-default-version 2`.
- Unos **5 GB** libres de disco.

## 2. Instalar Docker Desktop

1. Descárguelo de la página oficial: <https://www.docker.com/products/docker-desktop/> → **Download for Windows – AMD64**.
2. Ejecute el instalador. Deje marcada la opción **Use WSL 2 instead of Hyper-V**.
3. Reinicie el PC si lo pide.
4. Abra **Docker Desktop** desde el menú Inicio. Acepte los términos (puede omitir el inicio de sesión con *Skip*).
5. Espere a que abajo a la izquierda aparezca **Engine running** (en verde).

### Verificar la instalación

Abra **PowerShell** (no hace falta que sea administrador) y ejecute:

```powershell
docker --version
```

```powershell
docker compose version
```

Ambos deben mostrar un número de versión. Si dicen *no se reconoce como comando*, cierre y vuelva a abrir PowerShell.

---

## 3. Levantar la base de datos

1. Descargue el repositorio. Con Git:

   ```powershell
   git clone https://github.com/leiberbertel/rrhh-db-persistencia-2026.git
   ```

   O sin Git: en <https://github.com/leiberbertel/rrhh-db-persistencia-2026>, botón verde **Code → Download ZIP** y descomprímalo (la carpeta se llamará `rrhh-db-persistencia-2026-main`).
2. Abra PowerShell **dentro de la carpeta descargada** (la que contiene `docker-compose.yml`):

   ```powershell
   cd rrhh-db-persistencia-2026
   ```

   Truco: en el Explorador de archivos, abra la carpeta, escriba `powershell` en la barra de direcciones y presione Enter.
3. Cree su archivo `.env` a partir de la plantilla:

   ```powershell
   Copy-Item .env.example .env
   ```

   Ábralo con el Bloc de notas (`notepad .env`) y cambie `MYSQL_ROOT_PASSWORD` y `POLI01_PASSWORD` por claves propias. **Nunca suba este archivo a GitHub** (el `.gitignore` ya lo impide).
4. Levante el contenedor (la primera vez descarga la imagen, ~200 MB):

   ```powershell
   docker compose up -d
   ```

   `-d` significa que queda corriendo en segundo plano.

### Revisar el estado

```powershell
docker compose ps
```

En la columna **STATUS** debe aparecer `Up ... (healthy)`. Los primeros 30–60 segundos dirá `(health: starting)`: es normal, MySQL está ejecutando los scripts de `init/`.

### Revisar los logs

```powershell
docker compose logs mysql
```

Para seguirlos en vivo (salir con `Ctrl + C`):

```powershell
docker compose logs -f mysql
```

Busque estas líneas, que confirman que todo salió bien:

```
running /docker-entrypoint-initdb.d/01_setup.sql
running /docker-entrypoint-initdb.d/02_tablas.sql
running /docker-entrypoint-initdb.d/03_datos.sql
MySQL init process done. Ready for start up.
ready for connections ... port: 3306
```

### Prueba rápida desde la terminal

```powershell
docker exec -it mysql-rrhh mysql -u poli01 -p -e "SHOW GRANTS; SHOW TABLES FROM rrhh;"
```

Le pedirá la contraseña (`Enter password:`): escriba la de `POLI01_PASSWORD` y presione Enter. Al escribirla no se ve nada en pantalla; es normal.

---

## 4. Conectarse desde MySQL Workbench

1. Abra MySQL Workbench → clic en el **+** junto a *MySQL Connections*.
2. Complete:
   - **Connection Name:** `RRHH Docker`
   - **Hostname:** `127.0.0.1` (use esto y **no** `localhost`)
   - **Port:** `3306` (o el de su `.env`)
   - **Username:** `poli01`
   - **Password:** clic en *Store in Vault…* → la clave de `POLI01_PASSWORD` de su `.env`
3. Clic en **Test Connection** → debe decir *Successfully made the MySQL connection*.
   (Si aparece una advertencia de versión de servidor no soportada, dé clic en *Continue Anyway*.)
4. **OK** y doble clic sobre la conexión. En el panel *Schemas* debe aparecer `rrhh`.

---

## 5. Comandos del día a día

| Qué quiero hacer                         | Comando                       |
|------------------------------------------|-------------------------------|
| Encender la base                         | `docker compose up -d`        |
| Ver si está encendida y sana             | `docker compose ps`           |
| Apagarla (conserva los datos)            | `docker compose stop`         |
| Apagar y quitar el contenedor (conserva datos) | `docker compose down`   |
| **Borrar todo y empezar de cero**        | `docker compose down -v`      |

### Reiniciar desde cero

Los scripts de `init/` **solo se ejecutan cuando el volumen está vacío** (la primera vez). Si alguien cambia `02_tablas.sql` o `03_datos.sql`, hay que borrar el volumen para que se vuelvan a ejecutar:

```powershell
docker compose down -v
```

```powershell
docker compose up -d
```

> ⚠️ `-v` borra **todos** los datos de la base. Úselo solo cuando quiera recrearla.

---

## 6. Errores comunes

### "Bind for 127.0.0.1:3306 failed: port is already allocated" / "Only one usage of each socket address"
Ya tiene otro MySQL (por ejemplo, uno instalado con XAMPP o MySQL Installer) usando el puerto 3306.

- **Solución:** abra `.env` y cambie `MYSQL_PORT=3306` por `MYSQL_PORT=3307`. Luego:

  ```powershell
  docker compose up -d
  ```

  En Workbench use el puerto **3307**.
- Para ver qué programa usa el puerto: `netstat -ano | findstr :3306`.

### Docker Desktop no arranca / "Docker Desktop is starting…" eternamente / "WSL 2 installation is incomplete"
- Confirme que la **virtualización** está habilitada (ver Requisitos).
- En PowerShell como administrador: `wsl --update` y luego `wsl --shutdown`; vuelva a abrir Docker Desktop.
- Reinicie el PC.
- Si el comando `docker` responde *failed to connect to the docker API … dockerDesktopLinuxEngine*, significa que **Docker Desktop no está abierto**: ábralo y espere a *Engine running*.

### "Access denied for user 'poli01'@'localhost'" o "...@'172.x.x.x'"
- Verifique usuario y contraseña (la de `POLI01_PASSWORD` en su `.env`; distingue mayúsculas).
- Si cambió `POLI01_PASSWORD` en `.env` **después** de la primera ejecución, la clave vieja sigue vigente hasta que reinicie desde cero (`docker compose down -v` y `docker compose up -d`).
- En Workbench use **`127.0.0.1`** como host, no `localhost`.
- El usuario fue creado como `'poli01'@'%'` (cualquier host). Si alguien lo creó a mano como `'poli01'@'localhost'`, las conexiones desde Windows no coinciden con ese host y se rechazan. Revise con:

  ```powershell
  docker exec -it mysql-rrhh mysql -u root -p -e "SELECT user, host FROM mysql.user;"
  ```

  Debe aparecer `poli01 | %`. Si no, reinicie desde cero (`docker compose down -v` y `docker compose up -d`).

### "required variable MYSQL_ROOT_PASSWORD is missing" / "Falta POLI01_PASSWORD en .env"
No existe el archivo `.env` o le falta esa línea. Créelo con `Copy-Item .env.example .env`, ponga las claves y vuelva a ejecutar `docker compose up -d`.

### Las tildes salen dañadas ("MedellÃ­n", "BogotÃ¡")
Cada script de `init/` debe tener, después de `USE rrhh;`, la línea:

```sql
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Sin ella, el cliente que ejecuta los scripts dentro del contenedor usa latin1 y guarda mal los caracteres. Guarde además los `.sql` como **UTF-8** (en VS Code/Bloc de notas: *Guardar como → Codificación UTF-8*) y reinicie desde cero.

### Las tablas no aparecen / el contenedor se reinicia solo
Hubo un error de SQL en algún script de `init/`. Revise `docker compose logs mysql`, busque la línea `ERROR`, corrija el script y reinicie desde cero.

---

## 7. Evidencias (pantallazos que cada integrante debe tomar)

Guarde cada imagen con su nombre, por ejemplo `apellido_01_docker_version.png`.

1. **Administrador de tareas → Rendimiento → CPU** mostrando *Virtualización: Habilitado*.
2. **PowerShell** con la salida de `wsl --status`.
3. **Docker Desktop** abierto mostrando *Engine running*.
4. **PowerShell** con `docker --version` y `docker compose version`.
5. **PowerShell** con la salida de `docker compose up -d`.
6. **PowerShell** con `docker compose ps` mostrando `(healthy)`.
7. **PowerShell** con `docker compose logs mysql` donde se vean las líneas `running /docker-entrypoint-initdb.d/...` y `ready for connections`.
8. **Docker Desktop → Containers** mostrando `mysql-rrhh` en verde (*Running*).
9. **PowerShell** con la salida de `SHOW GRANTS` del usuario `poli01` (comando de la *Prueba rápida*).
10. **MySQL Workbench**: ventana de configuración de la conexión (host `127.0.0.1`, usuario `poli01`) con el mensaje *Successfully made the MySQL connection*.
11. **MySQL Workbench**: panel *Schemas* con la base `rrhh` desplegada mostrando sus tablas, y el resultado de `SELECT * FROM empleados;`.
