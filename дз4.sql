--Триггер с ключевыми словами BEFORE и AFTER
-- Пример триггера, который срабатывает до вставки данных
CREATE TRIGGER before_insert_example
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    -- Проверяем, чтобы зарплата была не меньше минимальной
    IF :NEW.salary < 30000 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Зарплата не может быть меньше 30000!');
    END IF;
END;
-- Пример триггера, который срабатывает после обновления данных
CREATE TRIGGER after_update_example
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Логируем изменения в отдельную таблицу
    INSERT INTO employees_log (employee_id, old_salary, new_salary, changed_on)
    VALUES (:OLD.employee_id, :OLD.salary, :NEW.salary, SYSDATE);
END;
--Операционные триггеры для операций DELETE, INSERT, UPDATE
-- Пример триггера на удаление
CREATE TRIGGER on_delete_example
BEFORE DELETE ON employees
FOR EACH ROW
BEGIN
    -- Логируем удалённые данные
    INSERT INTO deleted_employees (employee_id, name, deleted_on)
    VALUES (:OLD.employee_id, :OLD.name, SYSDATE);
END;
--Ключевые слова INSTEAD OF для представлений
-- Создаём представление
CREATE VIEW active_employees AS
SELECT employee_id, name, salary FROM employees WHERE status = 'ACTIVE';

-- Создаём триггер, который обрабатывает вставку в представление
CREATE TRIGGER instead_of_insert_example
INSTEAD OF INSERT ON active_employees
FOR EACH ROW
BEGIN
    -- Вставляем данные в основную таблицу с предустановленным статусом
    INSERT INTO employees (employee_id, name, salary, status)
    VALUES (:NEW.employee_id, :NEW.name, :NEW.salary, 'ACTIVE');
END;

--2. Практика создания транзакций
--Пример успешной транзакции
BEGIN;
    -- Вставка данных в таблицу сотрудников
    INSERT INTO employees (employee_id, name, salary, status)
    VALUES (101, 'John Doe', 50000, 'ACTIVE');

    -- Вставка данных в журнал
    INSERT INTO employees_log (employee_id, old_salary, new_salary, changed_on)
    VALUES (101, NULL, 50000, SYSDATE);

COMMIT;
-- Успех, так как обе операции выполнены без ошибок
--Пример неудачной транзакции
BEGIN;
    -- Вставка данных в таблицу сотрудников
    INSERT INTO employees (employee_id, name, salary, status)
    VALUES (102, 'Jane Smith', 20000, 'ACTIVE');
    -- Вторая операция вызывает ошибку, так как id уже существует
    INSERT INTO employees_log (employee_id, old_salary, new_salary, changed_on)
    VALUES (102, NULL, 20000, SYSDATE);

ROLLBACK;
-- Транзакция зафейлилась, так как employee_id уже существует в журнале, и произошло откат изменений
--Комментарии
--Неудачная транзакция вызвана нарушением уникальности employee_id в таблице employees_log. Чтобы этого избежать, нужно либо проверять существование записи, либо применять другой ключ.
--3. Использование RAISE внутри триггеров для логирования
-- Создаём таблицу для логов
CREATE TABLE trigger_logs (
    log_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    log_message VARCHAR2(255),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Пример триггера с использованием RAISE
CREATE TRIGGER log_trigger_example
AFTER INSERT OR UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Логируем операцию в таблицу логов
    INSERT INTO trigger_logs (log_message)
    VALUES (
        CASE 
            WHEN INSERTING THEN 'INSERT operation on employees: New record added with ID ' || :NEW.employee_id
            WHEN UPDATING THEN 'UPDATE operation on employees: ID ' || :NEW.employee_id || ' updated'
        END
    );
    -- Пример использования RAISE для ошибок
    IF :NEW.salary < 30000 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Salary below threshold detected!');
    END IF;
END;
--Проверка
-- Вставка сотрудника
INSERT INTO employees (employee_id, name, salary, status)
VALUES (103, 'Alice Johnson', 35000, 'ACTIVE');
-- Обновление данных
UPDATE employees
SET salary = 25000
WHERE employee_id = 103;
-- Проверяем логи
SELECT * FROM trigger_logs;
