-- ========================================
-- Создание схемы и таблиц
-- ========================================
CREATE SCHEMA IF NOT EXISTS e_commerce.ecommerce;

CREATE TABLE IF NOT EXISTS e_commerce.ecommerce.users (
    user_id BIGINT,
    name VARCHAR,
    email VARCHAR,
    signup_date DATE,
    is_active BOOLEAN,
    country VARCHAR,
    age BIGINT
);

CREATE TABLE IF NOT EXISTS e_commerce.ecommerce.products (
    product_id BIGINT,
    name VARCHAR,
    category VARCHAR,
    price DOUBLE,
    stock_quantity BIGINT,
    tags ARRAY(VARCHAR),
    is_active BOOLEAN,
    created_date DATE
);

CREATE TABLE IF NOT EXISTS e_commerce.ecommerce.orders (
    order_id BIGINT,
    user_id BIGINT,
    order_date DATE,
    total_amount DOUBLE,
    status VARCHAR,
    shipping_city VARCHAR,
    product_categories ARRAY(VARCHAR),
    payment_method VARCHAR,
    created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS e_commerce.ecommerce.order_items (
    order_item_id BIGINT,
    order_id BIGINT,
    product_id BIGINT,
    quantity BIGINT,
    unit_price DOUBLE,
    discount DOUBLE
);

-- ========================================
-- Генерация пользователей (100 000)
-- ========================================
INSERT INTO e_commerce.ecommerce.users
WITH RECURSIVE batches(batch) AS (
    SELECT 0
    UNION ALL
    SELECT batch + 1 FROM batches WHERE batch < 9
)
SELECT
    seq + batch*10000 AS user_id,
    'User_' || CAST(seq + batch*10000 AS VARCHAR) AS name,
    'user' || CAST(seq + batch*10000 AS VARCHAR) || '@mail.com' AS email,
    date_add('day', CAST((seq + batch*10000) % 1000 AS integer), DATE '2020-01-01') AS signup_date,
    ((seq + batch*10000) % 2 = 0) AS is_active,
    CASE WHEN (seq + batch*10000) % 3 = 0 THEN 'Россия' ELSE 'США' END AS country,
    18 + ((seq + batch*10000) % 50) AS age
FROM batches
CROSS JOIN UNNEST(sequence(1,10000)) AS t(seq);

-- ========================================
-- Генерация продуктов (100 000)
-- ========================================
INSERT INTO e_commerce.ecommerce.products
WITH RECURSIVE batches(batch) AS (
    SELECT 0
    UNION ALL
    SELECT batch + 1 FROM batches WHERE batch < 9
)
SELECT
    seq + batch*10000 AS product_id,
    'Product_' || CAST(seq + batch*10000 AS VARCHAR) AS name,
    CASE WHEN (seq + batch*10000) % 3 = 0 THEN 'electronics'
         WHEN (seq + batch*10000) % 3 = 1 THEN 'clothing'
         ELSE 'books' END AS category,
    100 + ((seq + batch*10000) % 10000) AS price,
    1 + ((seq + batch*10000) % 500) AS stock_quantity,
    ARRAY['tag' || CAST(((seq + batch*10000) % 10) AS VARCHAR)] AS tags,
    ((seq + batch*10000) % 2 = 0) AS is_active,
    date_add('day', CAST((seq + batch*10000) % 1000 AS integer), DATE '2020-01-01') AS created_date
FROM batches
CROSS JOIN UNNEST(sequence(1,10000)) AS t(seq);

-- ========================================
-- Генерация заказов (100 000)
-- ========================================
INSERT INTO e_commerce.ecommerce.orders
WITH RECURSIVE batches(batch) AS (
    SELECT 0
    UNION ALL
    SELECT batch + 1 FROM batches WHERE batch < 9
)
SELECT
    seq + batch*10000 AS order_id,
    1 + ((seq + batch*10000) % 200000) AS user_id,
    date_add('day', CAST((seq + batch*10000) % 365 AS integer), DATE '2024-01-01') AS order_date,
    10 + ((seq + batch*10000) % 5000) AS total_amount,
    CASE WHEN (seq + batch*10000) % 3 = 0 THEN 'completed'
         WHEN (seq + batch*10000) % 3 = 1 THEN 'pending'
         ELSE 'shipped' END AS status,
    CASE WHEN (seq + batch*10000) % 3 = 0 THEN 'Москва'
         WHEN (seq + batch*10000) % 3 = 1 THEN 'Санкт-Петербург'
         ELSE 'Казань' END AS shipping_city,
    ARRAY['electronics','books'] AS product_categories,
    CASE WHEN ((seq + batch*10000) % 2 = 0) THEN 'credit_card' ELSE 'paypal' END AS payment_method,
    current_timestamp AS created_at
FROM batches
CROSS JOIN UNNEST(sequence(1,10000)) AS t(seq);

-- ========================================
-- Генерация order_items (100 000)
-- ========================================
INSERT INTO e_commerce.ecommerce.order_items
WITH RECURSIVE batches(batch) AS (
    SELECT 0
    UNION ALL
    SELECT batch + 1 FROM batches WHERE batch < 9
)
SELECT
    seq + batch*10000 AS order_item_id,
    1 + ((seq + batch*10000) % 200000) AS order_id,
    1 + ((seq + batch*10000) % 200000) AS product_id,
    1 + ((seq + batch*10000) % 5) AS quantity,
    100 + ((seq + batch*10000) % 5000) AS unit_price,
    ((seq + batch*10000) % 3) * 5 AS discount
FROM batches
CROSS JOIN UNNEST(sequence(1,10000)) AS t(seq);

