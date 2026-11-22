-- 01_setup.sql - Base de datos y permisos del usuario de trabajo
-- Proyecto: Modelo de Recursos Humanos (Entrega 2)
-- Se ejecuta automáticamente solo la primera vez (volumen vacío).

-- Indica que este archivo está en UTF-8 para que tildes y eñes se guarden bien.
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Crea la base de datos "rrhh" solo si no existe todavía.
-- utf8mb4 permite guardar cualquier carácter Unicode (tildes, ñ, emojis) y
-- utf8mb4_unicode_ci compara textos sin distinguir mayúsculas/minúsculas
-- siguiendo las reglas del estándar Unicode.
CREATE DATABASE IF NOT EXISTS rrhh
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- El usuario 'poli01'@'%' lo crea la imagen de MySQL con la clave POLI01_PASSWORD
-- del .env, para no dejarla escrita en un repositorio público. Equivale a:
--     CREATE USER 'poli01'@'%' IDENTIFIED BY '...';
-- '%' permite conexiones desde fuera del contenedor (por ejemplo, Workbench).

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
