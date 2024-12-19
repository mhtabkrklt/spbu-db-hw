-- Создание временной таблицы для анализа заказов за первый квартал 2024 года
CREATE TEMPORARY TABLE TempOrders AS
SELECT 
    o.order_id,
    o.order_date,
    o.total_price,
    c.name AS customer_name
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE o.order_date BETWEEN '2024-01-01' AND '2024-03-31';

-- Пример анализа: суммарные доходы и количество заказов
SELECT 
    COUNT(order_id) AS total_orders,
    SUM(total_price) AS total_revenue
FROM TempOrders;

-- Удаление временной таблицы
DROP TEMPORARY TABLE IF EXISTS TempOrders;

-- Создание представления для отчёта о доходах по категориям товаров
CREATE VIEW RevenueByCategory AS
SELECT 
    p.category AS product_category,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM OrderItems oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Использование представления для анализа
SELECT * 
FROM RevenueByCategory
WHERE total_revenue > 1000;

-- Проверка существования ID пользователя перед добавлением заказа
DO BEGIN
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE customer_id = 1) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer ID does not exist.';
    ELSE
        INSERT INTO Orders (customer_id, total_price, order_date) 
        VALUES (1, 500.00, CURRENT_DATE);
    END IF;
END;

-- Проверка существования ID товара перед добавлением элемента заказа
DO BEGIN
    IF NOT EXISTS (SELECT 1 FROM Products WHERE product_id = 2) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product ID does not exist.';
    ELSE
        INSERT INTO OrderItems (order_id, product_id, quantity, price) 
        VALUES (1, 2, 3, 100.00);
    END IF;
END;