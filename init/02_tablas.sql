USE rrhh;
-- Indica que este archivo está en UTF-8 para que tildes y eñes se guarden bien
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 02_tablas.sql
-- Modelo físico de la base de datos de Recursos Humanos (MySQL 8.4, InnoDB)
-- Orden de creación: primero las tablas padre, luego las hijas.

-- Tabla padre: países
CREATE TABLE paises (
  pais_ID      INT AUTO_INCREMENT PRIMARY KEY,
  pais_nombre  VARCHAR(60) NOT NULL
) ENGINE=InnoDB;

-- Hija de paises: una ciudad pertenece a un país
CREATE TABLE ciudades (
  ciud_ID       INT AUTO_INCREMENT PRIMARY KEY,
  ciud_nombre   VARCHAR(60) NOT NULL,
  ciud_pais_ID  INT NOT NULL,
  CONSTRAINT fk_ciud_pais FOREIGN KEY (ciud_pais_ID) REFERENCES paises (pais_ID)
) ENGINE=InnoDB;

-- Nieta de paises: una localización está en una ciudad
CREATE TABLE localizaciones (
  localiz_ID         INT AUTO_INCREMENT PRIMARY KEY,
  localiz_direccion  VARCHAR(100) NOT NULL,
  localiz_ciudad_ID  INT NOT NULL,
  CONSTRAINT fk_localiz_ciudad FOREIGN KEY (localiz_ciudad_ID) REFERENCES ciudades (ciud_ID)
) ENGINE=InnoDB;

-- Un departamento funciona en una localización
CREATE TABLE departamentos (
  dpto_ID          INT AUTO_INCREMENT PRIMARY KEY,
  dpto_nombre      VARCHAR(60) NOT NULL,
  dpto_localiz_ID  INT NOT NULL,
  CONSTRAINT fk_dpto_localiz FOREIGN KEY (dpto_localiz_ID) REFERENCES localizaciones (localiz_ID)
) ENGINE=InnoDB;

-- Tabla padre: cargos con su rango salarial
CREATE TABLE cargos (
  cargo_ID             INT AUTO_INCREMENT PRIMARY KEY,
  cargo_nombre         VARCHAR(60) NOT NULL,
  cargo_sueldo_minimo  DECIMAL(10,2) NOT NULL,
  cargo_sueldo_maximo  DECIMAL(10,2) NOT NULL,
  CONSTRAINT chk_cargo_sueldos CHECK (cargo_sueldo_maximo >= cargo_sueldo_minimo)
) ENGINE=InnoDB;

-- Empleados: cargo y departamento actuales; empl_gerente_ID apunta a la misma tabla
CREATE TABLE empleados (
  empl_ID              INT AUTO_INCREMENT PRIMARY KEY,
  empl_primer_nombre   VARCHAR(40) NOT NULL,
  empl_segundo_nombre  VARCHAR(40) NULL,
  empl_email           VARCHAR(100) NOT NULL,
  empl_fecha_nac       DATE NOT NULL,
  empl_sueldo          DECIMAL(10,2) NOT NULL,
  empl_comision        DECIMAL(10,2) NULL,
  empl_cargo_ID        INT NOT NULL,
  empl_gerente_ID      INT NULL,
  empl_dpto_ID         INT NOT NULL,
  CONSTRAINT uq_empl_email   UNIQUE (empl_email),
  CONSTRAINT fk_empl_cargo   FOREIGN KEY (empl_cargo_ID)   REFERENCES cargos (cargo_ID),
  CONSTRAINT fk_empl_gerente FOREIGN KEY (empl_gerente_ID) REFERENCES empleados (empl_ID) ON DELETE SET NULL,
  CONSTRAINT fk_empl_dpto    FOREIGN KEY (empl_dpto_ID)    REFERENCES departamentos (dpto_ID)
) ENGINE=InnoDB;

-- Tabla asociativa: cargo y departamento que tenía cada empleado al retirarse.
-- emphist_empl_ID no lleva llave foránea a propósito: en la entrega 3 el empleado
-- se borra de EMPLEADOS después de copiarlo aquí, y la llave bloquearía el borrado.
CREATE TABLE historico (
  emphist_ID            INT AUTO_INCREMENT PRIMARY KEY,
  emphist_empl_ID       INT NOT NULL,
  emphist_fecha_retiro  DATE NOT NULL,
  emphist_cargo_ID      INT NOT NULL,
  emphist_dpto_ID       INT NOT NULL,
  INDEX idx_hist_empl (emphist_empl_ID),
  CONSTRAINT fk_hist_cargo FOREIGN KEY (emphist_cargo_ID) REFERENCES cargos (cargo_ID),
  CONSTRAINT fk_hist_dpto  FOREIGN KEY (emphist_dpto_ID)  REFERENCES departamentos (dpto_ID)
) ENGINE=InnoDB;
