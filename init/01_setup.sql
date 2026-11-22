-- =====================================================================
-- 01_setup.sql - Creación de la base de datos y del usuario de trabajo
-- Proyecto: Modelo de Recursos Humanos (Entrega 2)
-- Módulo:   Persistencia de Datos y Transaccionalidad - Politécnico Grancolombiano
--
-- Este script lo ejecuta automáticamente el contenedor de MySQL (como root)
-- la PRIMERA vez que arranca con el volumen vacío. Para volver a ejecutarlo:
--     docker compose down -v
--     docker compose up -d
-- =====================================================================

-- Indica a MySQL que el texto de este archivo viene en UTF-8 (utf8mb4).
-- Sin esto, el cliente que ejecuta los scripts de init usa latin1 y las
-- tildes y eñes se guardan dañadas (ej. "Medellín" -> "MedellÃ­n").
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Crea la base de datos "rrhh" solo si no existe todavía.
-- utf8mb4 permite guardar cualquier carácter Unicode (tildes, ñ, emojis) y
-- utf8mb4_unicode_ci compara textos sin distinguir mayúsculas/minúsculas
-- siguiendo las reglas del estándar Unicode.
CREATE DATABASE IF NOT EXISTS rrhh
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Creación del usuario "poli01".
-- Para no dejar la contraseña escrita en este archivo (el repositorio es
-- público), el usuario NO se crea aquí: lo crea la imagen oficial de MySQL
-- antes de ejecutar este script, con las variables MYSQL_USER y
-- MYSQL_PASSWORD de docker-compose.yml (la clave sale de POLI01_PASSWORD en .env).
-- La sentencia que ejecuta la imagen es equivalente a:
--
--     CREATE USER 'poli01'@'%' IDENTIFIED BY '<POLI01_PASSWORD del .env>';
--
-- El host '%' significa que puede conectarse desde cualquier equipo; es
-- necesario porque las conexiones desde Windows (Workbench) llegan al
-- contenedor por la red de Docker y no como 'localhost'.

-- Otorga a "poli01" solo los privilegios necesarios sobre la base "rrhh"
-- (rrhh.* = todas las tablas de esa base y ninguna otra):
--   CREATE, ALTER, DROP     -> crear, modificar y eliminar tablas (DDL)
--   INDEX                   -> crear y eliminar índices
--   REFERENCES              -> definir llaves foráneas (FOREIGN KEY)
--   SELECT, INSERT,
--   UPDATE, DELETE          -> consultar y manipular registros (DML)
-- No se le da GRANT OPTION ni privilegios globales (principio de mínimo privilegio).
GRANT CREATE, ALTER, DROP, INDEX, REFERENCES, SELECT, INSERT, UPDATE, DELETE
    ON rrhh.*
    TO 'poli01'@'%';

-- Recarga las tablas de privilegios para que los permisos apliquen de inmediato.
-- (Con GRANT ya es automático; se deja por claridad y buena práctica.)
FLUSH PRIVILEGES;
