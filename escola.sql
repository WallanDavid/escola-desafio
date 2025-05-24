-- DROP das tabelas para limpar o banco (sem conflitos)
DROP TABLE IF EXISTS subject_prerequisite CASCADE;
DROP TABLE IF EXISTS class_schedule CASCADE;
DROP TABLE IF EXISTS class CASCADE;
DROP TABLE IF EXISTS subject CASCADE;
DROP TABLE IF EXISTS professor CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS title CASCADE;
DROP TABLE IF EXISTS room CASCADE;
DROP TABLE IF EXISTS building CASCADE;

-- Criar tabelas base

CREATE TABLE building (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE room (
  id SERIAL PRIMARY KEY,
  building_id INTEGER NOT NULL REFERENCES building(id)
);

CREATE TABLE department (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE title (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE professor (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  department_id INTEGER REFERENCES department(id),
  title_id INTEGER REFERENCES title(id)
);

CREATE TABLE subject (
  id SERIAL PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE subject_prerequisite (
  subject_id INTEGER NOT NULL REFERENCES subject(id),
  prerequisite_id INTEGER NOT NULL REFERENCES subject(id),
  PRIMARY KEY (subject_id, prerequisite_id)
);

CREATE TABLE class (
  id SERIAL PRIMARY KEY,
  subject_id INTEGER NOT NULL REFERENCES subject(id),
  professor_id INTEGER NOT NULL REFERENCES professor(id),
  semester VARCHAR(10) NOT NULL
);

CREATE TABLE class_schedule (
  id SERIAL PRIMARY KEY,
  class_id INTEGER NOT NULL REFERENCES class(id),
  room_id INTEGER NOT NULL REFERENCES room(id),
  day_of_week INTEGER NOT NULL, -- 1 = Monday ... 5 = Friday
  start_time TIME NOT NULL,
  end_time TIME NOT NULL
);

-- Inserção dos dados (exemplo básico, complete conforme necessário)

INSERT INTO building (name) VALUES ('Prédio Principal');
INSERT INTO building (name) VALUES ('Anexo');

INSERT INTO room (building_id) VALUES (1);
INSERT INTO room (building_id) VALUES (1);
INSERT INTO room (building_id) VALUES (2);

INSERT INTO department (name) VALUES ('Matemática'), ('Física'), ('Química');
INSERT INTO title (name) VALUES ('Professor'), ('Doutor');

INSERT INTO professor (name, department_id, title_id) VALUES
  ('Chaves', 1, 1),
  ('Dona Florinda', 2, 2),
  ('Professor Girafales', 3, 2);

INSERT INTO subject (code, name) VALUES
  ('MAT101', 'Matemática Básica'),
  ('FIS101', 'Física Básica'),
  ('QUI101', 'Química Básica');

INSERT INTO subject_prerequisite (subject_id, prerequisite_id) VALUES
  ((SELECT id FROM subject WHERE code='FIS101'), (SELECT id FROM subject WHERE code='MAT101')),
  ((SELECT id FROM subject WHERE code='QUI101'), (SELECT id FROM subject WHERE code='FIS101'));

INSERT INTO class (subject_id, professor_id, semester) VALUES
  ((SELECT id FROM subject WHERE code='MAT101'), (SELECT id FROM professor WHERE name='Chaves'), '2025-1'),
  ((SELECT id FROM subject WHERE code='FIS101'), (SELECT id FROM professor WHERE name='Dona Florinda'), '2025-1'),
  ((SELECT id FROM subject WHERE code='QUI101'), (SELECT id FROM professor WHERE name='Professor Girafales'), '2025-1');

INSERT INTO class_schedule (class_id, room_id, day_of_week, start_time, end_time) VALUES
  ((SELECT id FROM class WHERE subject_id = (SELECT id FROM subject WHERE code='MAT101')), 1, 1, '08:00', '10:00'),
  ((SELECT id FROM class WHERE subject_id = (SELECT id FROM subject WHERE code='MAT101')), 1, 3, '08:00', '10:00'),
  ((SELECT id FROM class WHERE subject_id = (SELECT id FROM subject WHERE code='FIS101')), 2, 2, '10:00', '12:00'),
  ((SELECT id FROM class WHERE subject_id = (SELECT id FROM subject WHERE code='QUI101')), 3, 4, '14:00', '16:00');

-- Consulta 1: Quantidade de horas que cada professor tem comprometido em aulas

SELECT
  p.name AS professor,
  SUM(EXTRACT(EPOCH FROM (cs.end_time - cs.start_time)) / 3600) AS total_horas
FROM
  professor p
JOIN class c ON p.id = c.professor_id
JOIN class_schedule cs ON c.id = cs.class_id
GROUP BY p.name
ORDER BY p.name;

-- Consulta 2: Lista de salas com horários livres e ocupados

WITH horario_funcionamento AS (
  SELECT
    generate_series(1, 5) AS day_of_week,
    generate_series(
      '2000-01-01 08:00:00'::timestamp,
      '2000-01-01 16:00:00'::timestamp,
      '1 hour'::interval
    ) AS start_timestamp
),
horarios_ocupados AS (
  SELECT room_id, day_of_week, start_time, end_time
  FROM class_schedule
),
horarios_livres AS (
  SELECT
    hf.day_of_week,
    hf.start_timestamp::time AS start_time,
    (hf.start_timestamp + interval '1 hour')::time AS end_time,
    r.id AS room_id
  FROM horario_funcionamento hf
  CROSS JOIN room r
  LEFT JOIN horarios_ocupados ho ON ho.room_id = r.id
    AND ho.day_of_week = hf.day_of_week
    AND hf.start_timestamp::time >= ho.start_time AND hf.start_timestamp::time < ho.end_time
  WHERE ho.room_id IS NULL
)
SELECT
  r.id AS room_id,
  r.building_id,
  hl.day_of_week,
  hl.start_time,
  hl.end_time,
  'Livre' AS status
FROM horarios_livres hl
JOIN room r ON r.id = hl.room_id
ORDER BY r.id, hl.day_of_week, hl.start_time;
