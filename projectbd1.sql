-- Таблица пользователей
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    registration_date DATE NOT NULL
);

-- Таблица товаров
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    stock INT NOT NULL CHECK (stock >= 0)
);

-- Таблица заказов
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);

-- Таблица элементов заказа
CREATE TABLE OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);
-- Подсчёт заказов за каждый день
SELECT order_date, COUNT(order_id) AS total_orders
FROM Orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY order_date
ORDER BY order_date ASC
LIMIT 100; -- Предотвращает неограниченные выборки

-- Подсчёт заказов за каждый месяц
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, COUNT(order_id) AS total_orders
FROM Orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month ASC
LIMIT 12;
-- Средняя стоимость заказа
SELECT COALESCE(AVG(total_price), 0) AS avg_order_price
FROM Orders
WHERE total_price > 0;
-- Самые популярные товары по количеству продаж
SELECT p.name AS product_name, SUM(oi.quantity) AS total_sold
FROM OrderItems oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.name
ORDER BY total_sold DESC
LIMIT 10;
-- Пример данных для таблицы Customers
INSERT INTO Customers (name, email, registration_date)
VALUES ('Alice', 'alice@example.com', '2024-01-01'),
       ('Bob', 'bob@example.com', '2024-01-05');

-- Пример данных для таблицы Products
INSERT INTO Products (name, price, stock)
VALUES ('Laptop', 1000.00, 50),
       ('Headphones', 100.00, 200),
       ('Mouse', 25.00, 500);

-- Пример данных для таблицы Orders
INSERT INTO Orders (customer_id, total_price)
VALUES (1, 1125.00),
       (2, 100.00);

-- Пример данных для таблицы OrderItems
INSERT INTO OrderItems (order_id, product_id, quantity, price)
VALUES (1, 1, 1, 1000.00), -- Laptop
       (1, 3, 5, 125.00), -- 5 Mouses
       (2, 2, 1, 100.00); -- Headphones