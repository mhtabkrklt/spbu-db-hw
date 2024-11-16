-- Создание таблицы student_courses
CREATE TABLE student_courses (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    UNIQUE (student_id, course_id)
);
-- Создание таблицы group_courses
CREATE TABLE group_courses (
    id SERIAL PRIMARY KEY,
    group_id INT NOT NULL,
    course_id INT NOT NULL,
    UNIQUE (group_id, course_id)
);
-- Удаление неактуальных полей с использованием ALTER TABLE
ALTER TABLE courses
DROP COLUMN IF EXISTS courses_ids;
-- Добавление уникального ограничения на поле name в таблице courses
ALTER TABLE courses
ADD CONSTRAINT unique_course_name UNIQUE (name);
-- Создание индекса на поле group_id в таблице students
CREATE INDEX idx_students_group_id ON students (group_id);
-- Запрос для вывода списка всех студентов с их курсами
SELECT s.id AS student_id, s.name AS student_name, c.name AS course_name
FROM students s
JOIN student_courses sc ON s.id = sc.student_id
JOIN courses c ON sc.course_id = c.id;
-- Запрос для нахождения студентов с средней оценкой выше, чем у любого другого студента в их группе
SELECT s.id, s.name, AVG(sc.grade) AS avg_grade
FROM students s
JOIN student_courses sc ON s.id = sc.student_id
GROUP BY s.id, s.name, s.group_id
HAVING AVG(sc.grade) > ALL (
    SELECT AVG(sc2.grade)
    FROM students s2
    JOIN student_courses sc2 ON s2.id = sc2.student_id
    WHERE s2.group_id = s.group_id
    GROUP BY s2.id
);
-- Подсчет количества студентов на каждом курсе
SELECT c.id AS course_id, c.name AS course_name, COUNT(sc.student_id) AS student_count
FROM courses c
JOIN student_courses sc ON c.id = sc.course_id
GROUP BY c.id, c.name
ORDER BY student_count DESC
LIMIT 100;
-- Нахождение средней оценки на каждом курсе
SELECT c.id AS course_id, c.name AS course_name, AVG(sc.grade) AS avg_grade
FROM courses c
JOIN student_courses sc ON c.id = sc.course_id
GROUP BY c.id, c.name
ORDER BY avg_grade DESC
LIMIT 100;