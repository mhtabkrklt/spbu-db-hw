DELIMITER $$

-- Триггер для обновления количества товаров
CREATE TRIGGER UpdateProductStock
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;
    
    -- Проверка текущего запаса
    SELECT stock INTO available_stock 
    FROM Products 
    WHERE product_id = NEW.product_id;

    -- Если запаса недостаточно, отменить операцию
    IF available_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock available for this product.';
    ELSE
        -- Обновление запаса
        UPDATE Products
        SET stock = stock - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;
END;

-- Хранимая процедура для обработки заказа
CREATE PROCEDURE ProcessOrder(
    IN customer_id INT,
    IN product_id INT,
    IN quantity INT,
    IN payment_amount DECIMAL(10, 2)
)
BEGIN
    DECLARE total_price DECIMAL(10, 2);
    DECLARE available_stock INT;

    -- Начало транзакции
    START TRANSACTION;

    -- Проверка наличия товара
    SELECT stock, price INTO available_stock, total_price
    FROM Products
    WHERE product_id = product_id;

    IF available_stock < quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock available for this product.';
        ROLLBACK;
        LEAVE;
    END IF;

    -- Расчёт общей суммы заказа
    SET total_price = total_price * quantity;

    -- Проверка суммы платежа
    IF payment_amount < total_price THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient payment amount.';
        ROLLBACK;
        LEAVE;
    END IF;

    -- Создание нового заказа
    INSERT INTO Orders (customer_id, total_price, order_date)
    VALUES (customer_id, total_price, CURRENT_DATE);

    -- Получение ID созданного заказа
    DECLARE order_id INT;
    SET order_id = LAST_INSERT_ID();

    -- Добавление элементов заказа
    INSERT INTO OrderItems (order_id, product_id, quantity, price)
    VALUES (order_id, product_id, quantity, total_price / quantity);

    -- Обновление запаса товаров
    UPDATE Products
    SET stock = stock - quantity
    WHERE product_id = product_id;

    -- Фиксация транзакции
    COMMIT;
END;
$$

DELIMITER ;
-- Обработка заказа: пользователь 1 покупает 2 единицы товара 1, платит 2000
CALL ProcessOrder(1, 1, 2, 2000.00);