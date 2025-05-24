-- DROP das tabelas para limpar o banco (garante que não tenha conflito)
DROP TABLE IF EXISTS subject_prerequisite CASCADE;
DROP TABLE IF EXISTS class_schedule CASCADE;
DROP TABLE IF EXISTS class CASCADE;
DROP TABLE IF EXISTS subject CASCADE;
DROP TABLE IF EXISTS professor CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS title CASCADE;
DROP TABLE IF EXISTS room CASCADE;
DROP TABLE IF EXISTS building CASCADE;

-- Criação das tabelas (use seu código que já funciona)

CREATE TABLE building (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE room (
  id SERIAL PRIMARY KEY,
  building_id INTEGER NOT NULL REFERENCES building(id)
);

-- Crie as outras tabelas (subject, professor, class, class_schedule, etc)
-- Use o mesmo código que você já executou com sucesso

-- Inserção dos dados (sua base de dados)
INSERT INTO building (id, name) VALUES (1, 'Prédio Principal');

INSERT INTO room (id, building_id) VALUES
(1, 1),
(2, 2);

-- Continue com o restante das inserções: professores, matérias, turmas, horários...

-- Consultas que você fez para as perguntas do desafio

-- Quantidade de horas por professor
SELECT p.name AS professor,
       SUM(EXTRACT(EPOCH FROM (cs.end_time - cs.start_time)) / 3600) AS total_horas
FROM professor p
JOIN class c ON p.id = c.professor_id
JOIN class_schedule cs ON c.id = cs.class_id
GROUP BY p.name;

-- Lista de salas com horários livres e ocupados
WITH horario_funcionamento AS (
  SELECT generate_series(1,5) AS day_of_week,
         generate_series('08:00'::time, '17:00'::time, '1 hour'::interval) AS start_time
),
horarios_ocupados AS (
  SELECT room_id, day_of_week, start_time, end_time
  FROM class_schedule
),
horarios_livres AS (
  SELECT hf.day_of_week, hf.start_time, hf.start_time + interval '1 hour' AS end_time, r.id AS room_id
  FROM horario_funcionamento hf
  CROSS JOIN room r
  LEFT JOIN horarios_ocupados ho ON ho.room_id = r.id
    AND ho.day_of_week = hf.day_of_week
    AND hf.start_time >= ho.start_time AND hf.start_time < ho.end_time
  WHERE ho.room_id IS NULL
)
SELECT r.id AS room_id, r.building_id, hl.day_of_week, hl.start_time, hl.end_time,
       'Livre' AS status
FROM horarios_livres hl
JOIN room r ON r.id = hl.room_id
ORDER BY r.id, hl.day_of_week, hl.start_time;
