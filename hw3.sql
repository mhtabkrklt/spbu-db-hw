-- Создание временной таблицы high_sales_products, содержащей продукты, проданные в количестве более 10 единиц за последние 7 дней
CREATE TEMP TABLE high_sales_products AS
SELECT product_id, SUM(quantity) AS total_sales
FROM sales
WHERE sale_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY product_id
HAVING SUM(quantity) > 10;

-- Проверим данные
SELECT * FROM high_sales_products;
--2 Создание CTE для подсчета общего количества продаж и среднего количества продаж для каждого сотрудника за последние 30 дней
WITH employee_sales_stats AS (
    SELECT e.employee_id, e.name, SUM(s.quantity) AS total_sales, 
           AVG(s.quantity) OVER () AS avg_sales
    FROM employees e
    JOIN sales s ON e.employee_id = s.employee_id
    WHERE s.sale_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY e.employee_id, e.name
)
SELECT * 
FROM employee_sales_stats
WHERE total_sales > avg_sales;
--3 Иерархическая структура сотрудников, показывающая всех сотрудников, которые подчиняются конкретному менеджеру
WITH employee_hierarchy AS (
    SELECT e1.employee_id AS manager_id, e2.employee_id AS employee_id, e2.name
    FROM employees e1
    JOIN employees e2 ON e1.employee_id = e2.manager_id
    WHERE e1.employee_id = 1  -- Замените на ID нужного менеджера
)
SELECT * FROM employee_hierarchy;
--4-Топ-3 продукта по количеству продаж за текущий месяц и за прошлый месяц.
WITH monthly_sales AS (
    SELECT product_id, SUM(quantity) AS total_sales,
           date_part('month', sale_date) AS sale_month
    FROM sales
    WHERE sale_date >= CURRENT_DATE - INTERVAL '2 months'
    GROUP BY product_id, sale_month
)
SELECT product_id, total_sales, sale_month
FROM monthly_sales
WHERE sale_month = date_part('month', CURRENT_DATE)
ORDER BY total_sales DESC
LIMIT 3
UNION ALL
SELECT product_id, total_sales, sale_month
FROM monthly_sales
WHERE sale_month = date_part('month', CURRENT_DATE) - 1
ORDER BY total_sales DESC
LIMIT 3;
--5-Создание индекса для таблицы sales по полям employee_id и sale_date, чтобы ускорить запросы, фильтрующие данные по сотрудникам и датам
CREATE INDEX idx_employee_sales ON sales(employee_id, sale_date);

-- Пример запроса, использующего этот индекс
EXPLAIN ANALYZE
SELECT * FROM sales
WHERE employee_id = 2 AND sale_date BETWEEN '2024-10-01' AND '2024-10-31';
--6  Анализ запроса, который находит общее количество проданных единиц каждого продукта
EXPLAIN ANALYZE
SELECT product_id, SUM(quantity) AS total_sales
FROM sales
GROUP BY product_id;
