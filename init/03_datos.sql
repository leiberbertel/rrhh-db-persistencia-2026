USE rrhh;
-- Indica que este archivo está en UTF-8 para que tildes y eñes se guarden bien
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 03_datos.sql
-- Carga de 5 registros de prueba por tabla, en orden: padres, hijas, nietas.
-- Los IDs se escriben explícitos para que las llaves foráneas sean fáciles de seguir.


-- 1. Países (padre)
INSERT INTO paises (pais_ID, pais_nombre) VALUES
  (1, 'Colombia'),
  (2, 'México'),
  (3, 'Perú'),
  (4, 'Chile'),
  (5, 'Argentina');

-- 2. Ciudades (hija de países)
INSERT INTO ciudades (ciud_ID, ciud_nombre, ciud_pais_ID) VALUES
  (1, 'Medellín', 1),
  (2, 'Bogotá', 1),
  (3, 'Ciudad de México', 2),
  (4, 'Lima', 3),
  (5, 'Santiago', 4);

-- 3. Localizaciones (nieta: dependen de ciudades)
INSERT INTO localizaciones (localiz_ID, localiz_direccion, localiz_ciudad_ID) VALUES
  (1, 'Carrera 43A # 1-50', 1),
  (2, 'Calle 72 # 10-34', 2),
  (3, 'Avenida Paseo de la Reforma 222', 3),
  (4, 'Avenida Javier Prado Este 4200', 4),
  (5, 'Avenida Apoquindo 3000', 5);

-- 4. Departamentos (dependen de localizaciones)
INSERT INTO departamentos (dpto_ID, dpto_nombre, dpto_localiz_ID) VALUES
  (1, 'Gerencia', 1),
  (2, 'Talento Humano', 1),
  (3, 'Finanzas', 2),
  (4, 'Tecnología', 1),
  (5, 'Comercial', 3);

-- 5. Cargos (padre)
INSERT INTO cargos (cargo_ID, cargo_nombre, cargo_sueldo_minimo, cargo_sueldo_maximo) VALUES
  (1, 'Gerente general',            12000000.00, 20000000.00),
  (2, 'Analista de talento humano',  3000000.00,  5000000.00),
  (3, 'Contador',                    4000000.00,  6500000.00),
  (4, 'Desarrollador de software',   4500000.00,  8000000.00),
  (5, 'Ejecutivo comercial',         2500000.00,  4500000.00);

-- 6. Empleados (dependen de cargos y departamentos).
--    El gerente va primero, con empl_gerente_ID en NULL; los demás lo referencian.
INSERT INTO empleados (empl_ID, empl_primer_nombre, empl_segundo_nombre, empl_email,
                       empl_fecha_nac, empl_sueldo, empl_comision,
                       empl_cargo_ID, empl_gerente_ID, empl_dpto_ID) VALUES
  (1, 'Laura',     'Marcela', 'laura.marcela@example.com',   '1980-04-12', 15000000.00, NULL,      1, NULL, 1),
  (2, 'Andrés',    'Felipe',  'andres.felipe@example.com',   '1992-09-03',  3800000.00, NULL,      2, 1,    2),
  (3, 'Daniela',   'Andrea',  'daniela.andrea@example.com',  '1988-01-25',  5200000.00, NULL,      3, 1,    3),
  (4, 'Santiago',  'José',    'santiago.jose@example.com',   '1995-06-18',  6000000.00, NULL,      4, 1,    4),
  (5, 'Valentina', 'Sofía',   'valentina.sofia@example.com', '1998-11-30',  3000000.00, 450000.00, 5, 1,    5);

-- 7. Histórico (asociativa): empleados ya retirados (IDs 901-905, que ya no están en EMPLEADOS)
INSERT INTO historico (emphist_ID, emphist_empl_ID, emphist_fecha_retiro, emphist_cargo_ID, emphist_dpto_ID) VALUES
  (1, 901, '2024-03-31', 2, 2),
  (2, 902, '2024-08-15', 4, 4),
  (3, 903, '2025-01-10', 5, 5),
  (4, 904, '2025-06-30', 3, 3),
  (5, 905, '2026-02-28', 5, 5);

-- Verificación: cada tabla debe tener 5 registros
SELECT 'paises' AS tabla, COUNT(*) AS registros FROM paises
UNION ALL SELECT 'ciudades', COUNT(*) FROM ciudades
UNION ALL SELECT 'localizaciones', COUNT(*) FROM localizaciones
UNION ALL SELECT 'departamentos', COUNT(*) FROM departamentos
UNION ALL SELECT 'cargos', COUNT(*) FROM cargos
UNION ALL SELECT 'empleados', COUNT(*) FROM empleados
UNION ALL SELECT 'historico', COUNT(*) FROM historico;
