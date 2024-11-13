--1.создание таблицы courses
CREATE TABLE courses (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    is_exam BOOLEAN,
    min_grade INT,
    max_grade INT
);
--2.создание таблицы table
CREATE TABLE groups (
    id INT PRIMARY KEY,
    full_name VARCHAR(100),
    short_name VARCHAR(10),
    students_ids VARCHAR(255) -- Хранение списка id студентов в виде строки
);
--3.создание таблицы students
CREATE TABLE students (
    id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    group_id INT,
    courses_ids VARCHAR(255), -- Хранение списка id курсов в виде строки
    FOREIGN KEY (group_id) REFERENCES groups(id)
);
--4.создание таблицы course_grades
CREATE TABLE course_grades (
    student_id INT,
    course_id INT,
    grade INT,
    grade_str VARCHAR(10),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);
--вставка данных курсов, групп, студентов и оценок студентов в таблицу
INSERT INTO courses (id, name, is_exam, min_grade, max_grade)
VALUES
(1, 'Mathematics', TRUE, 0, 100),
(2, 'History', FALSE, 0, 100),
(3, 'Programming', TRUE, 0, 100);
INSERT INTO groups (id, full_name, short_name, students_ids)
VALUES
(1, 'Computer Science', 'CS', '1,2'),
(2, 'History and Literature', 'HL', '3,4');
INSERT INTO students (id, first_name, last_name, group_id, courses_ids)
VALUES
(1, 'John', 'Doe', 1, '1,3'),
(2, 'Jane', 'Smith', 1, '1,3'),
(3, 'Alice', 'Brown', 2, '2'),
(4, 'Bob', 'Johnson', 2, '2');
INSERT INTO course_grades (student_id, course_id, grade, grade_str)
VALUES
(1, 1, 85, 'B'),
(2, 1, 90, 'A'),
(3, 2, 70, 'C'),
(4, 2, 80, 'B'),
(1, 3, 95, 'A'),
(2, 3, 88, 'B');
-- фильтрация и агрегассия
--1.фильтрация студентов по курсам
SELECT s.first_name, s.last_name, cg.grade, cg.grade_str
FROM students s
JOIN course_grades cg ON s.id = cg.student_id
WHERE cg.course_id = 1;
--2.агрегассия оценок по курсу
SELECT AVG(grade) AS average_grade
FROM course_grades
WHERE course_id = 1;
--3.количество студентов в каждой группе
SELECT g.full_name, COUNT(s.id) AS student_count
FROM groups g
JOIN students s ON g.id = s.group_id
GROUP BY g.full_name;
--4.максимальная и минимальная оценка по курсу
SELECT course_id, MAX(grade) AS max_grade, MIN(grade) AS min_grade
FROM course_grades
GROUP BY course_id;