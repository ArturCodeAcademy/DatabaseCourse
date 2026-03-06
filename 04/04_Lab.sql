/*
============================================================
04_Lab.sql — Lesson 4: JOINs
============================================================

How to use this lab:
1) Run the whole script once to create and populate all tables.
2) Read the demo queries in order.
3) Execute them one by one and inspect the results.
4) Then solve the tasks at the bottom.

Main lesson goals:
- Understand why data is split into tables
- Practice INNER JOIN, LEFT JOIN, FULL JOIN, CROSS JOIN
- Always use aliases (c.CustomerName, o.OrderDate, oi.Quantity, p.Price)
- Learn common JOIN mistakes
- Learn how to find "orphans" with LEFT JOIN

Important:
Some rows in this lab are intentionally "broken" or unmatched.
They are here to help explain JOIN behavior.
*/

USE SqlCourse;
GO

------------------------------------------------------------
-- 1) CLEANUP
------------------------------------------------------------
IF OBJECT_ID('dbo.OrderItems', 'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.Colors', 'U') IS NOT NULL DROP TABLE dbo.Colors;
IF OBJECT_ID('dbo.Sizes', 'U') IS NOT NULL DROP TABLE dbo.Sizes;
GO

------------------------------------------------------------
-- 2) CREATE TABLES
------------------------------------------------------------
CREATE TABLE dbo.Customers (
    CustomerId   INT PRIMARY KEY,
    CustomerName NVARCHAR(100),
    City         NVARCHAR(50)
);
GO

CREATE TABLE dbo.Products (
    ProductId    INT PRIMARY KEY,
    ProductName  NVARCHAR(100),
    Price        DECIMAL(10,2)
);
GO

CREATE TABLE dbo.Orders (
    OrderId      INT PRIMARY KEY,
    CustomerId   INT NULL,      -- NULL allowed on purpose for teaching JOINs
    OrderDate    DATE
);
GO

CREATE TABLE dbo.OrderItems (
    OrderItemId  INT PRIMARY KEY,
    OrderId      INT,
    ProductId    INT,
    Quantity     INT
);
GO

CREATE TABLE dbo.Colors (
    ColorName NVARCHAR(30)
);
GO

CREATE TABLE dbo.Sizes (
    SizeName NVARCHAR(10)
);
GO

------------------------------------------------------------
-- 3) INSERT DATA
------------------------------------------------------------
INSERT INTO dbo.Customers (CustomerId, CustomerName, City)
VALUES
(1, 'Alice',   'New York'),
(2, 'Bob',     'Chicago'),
(3, 'Charlie', 'Miami'),
(4, 'Diana',   'Seattle'),
(5, 'Ethan',   'Austin'),
(6, 'Fiona',   'Boston');
GO

INSERT INTO dbo.Products (ProductId, ProductName, Price)
VALUES
(1, 'Laptop',    1200.00),
(2, 'Mouse',       25.00),
(3, 'Keyboard',    80.00),
(4, 'Monitor',    300.00),
(5, 'Headphones', 150.00);
GO

INSERT INTO dbo.Orders (OrderId, CustomerId, OrderDate)
VALUES
(101, 1,   '2024-01-10'),
(102, 1,   '2024-01-15'),
(103, 2,   '2024-02-01'),
(104, 3,   '2024-02-12'),
(105, 5,   '2024-03-05'),
(106, NULL,'2024-03-07'), -- order without customer
(107, 999, '2024-03-08'); -- invalid customer reference for demo
GO

INSERT INTO dbo.OrderItems (OrderItemId, OrderId, ProductId, Quantity)
VALUES
(1, 101, 1,   1),
(2, 101, 2,   2),
(3, 102, 3,   1),
(4, 103, 2,   3),
(5, 103, 4,   1),
(6, 104, 5,   2),
(7, 105, 1,   1),
(8, 105, 4,   2),
(9, 999, 2,   1),   -- invalid order reference for demo
(10,104, 999, 1);   -- invalid product reference for demo
GO

INSERT INTO dbo.Colors (ColorName)
VALUES ('Black'), ('White'), ('Blue'), ('Red');
GO

INSERT INTO dbo.Sizes (SizeName)
VALUES ('S'), ('M'), ('L');
GO

------------------------------------------------------------
-- 4) QUICK LOOK AT THE DATA
------------------------------------------------------------
SELECT * FROM dbo.Customers ORDER BY CustomerId;
SELECT * FROM dbo.Products  ORDER BY ProductId;
SELECT * FROM dbo.Orders    ORDER BY OrderId;
SELECT * FROM dbo.OrderItems ORDER BY OrderItemId;
GO

/*
Notice:
- Diana and Fiona have no orders
- Order 106 has NULL CustomerId
- Order 107 points to customer 999 (does not exist)
- OrderItem 9 points to OrderId 999 (does not exist)
- OrderItem 10 points to ProductId 999 (does not exist)

These rows are useful because they show what happens with different JOIN types.
*/

------------------------------------------------------------
-- 5) INNER JOIN: ONLY MATCHES
------------------------------------------------------------

-- Basic example: customers who actually have orders
SELECT
    c.CustomerName,
    o.OrderId,
    o.OrderDate
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerId = o.CustomerId
ORDER BY o.OrderId;
GO

-- Meaning:
-- Only rows where c.CustomerId = o.CustomerId are returned.
-- Customers without orders are removed.
-- Orders with NULL / invalid CustomerId are also removed.

-- Another INNER JOIN example:
-- Show products inside each order item (only valid product matches survive)
SELECT
    oi.OrderItemId,
    oi.OrderId,
    p.ProductName,
    oi.Quantity,
    p.Price
FROM dbo.OrderItems AS oi
INNER JOIN dbo.Products AS p
    ON oi.ProductId = p.ProductId
ORDER BY oi.OrderItemId;
GO

-- Multi-table INNER JOIN:
-- customer -> order -> order item -> product
SELECT
    c.CustomerName,
    o.OrderId,
    p.ProductName,
    oi.Quantity,
    p.Price,
    oi.Quantity * p.Price AS LineTotal
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerId = o.CustomerId
INNER JOIN dbo.OrderItems AS oi
    ON o.OrderId = oi.OrderId
INNER JOIN dbo.Products AS p
    ON oi.ProductId = p.ProductId
ORDER BY o.OrderId, p.ProductName;
GO

------------------------------------------------------------
-- 6) LEFT JOIN: EVERYTHING FROM LEFT TABLE
------------------------------------------------------------

-- Show all customers, even if they have no orders
SELECT
    c.CustomerId,
    c.CustomerName,
    o.OrderId,
    o.OrderDate
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
    ON c.CustomerId = o.CustomerId
ORDER BY c.CustomerId, o.OrderId;
GO

-- Notice:
-- Diana and Fiona will still appear.
-- Their OrderId and OrderDate will be NULL.

-- Classic orphan search:
-- Find customers with no orders
SELECT
    c.CustomerId,
    c.CustomerName
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
    ON c.CustomerId = o.CustomerId
WHERE o.OrderId IS NULL
ORDER BY c.CustomerId;
GO

-- Another orphan search:
-- Find products that were never used in OrderItems
SELECT
    p.ProductId,
    p.ProductName
FROM dbo.Products AS p
LEFT JOIN dbo.OrderItems AS oi
    ON p.ProductId = oi.ProductId
WHERE oi.OrderItemId IS NULL
ORDER BY p.ProductId;
GO

-- Reverse idea:
-- Show all orders and customer names if they exist
SELECT
    o.OrderId,
    o.CustomerId,
    c.CustomerName
FROM dbo.Orders AS o
LEFT JOIN dbo.Customers AS c
    ON o.CustomerId = c.CustomerId
ORDER BY o.OrderId;
GO

-- Here order 106 and 107 remain visible,
-- but CustomerName becomes NULL because no match exists.

------------------------------------------------------------
-- 7) FULL JOIN: EVERYTHING FROM BOTH SIDES
------------------------------------------------------------

SELECT
    c.CustomerId,
    c.CustomerName,
    o.OrderId,
    o.CustomerId AS OrderCustomerId
FROM dbo.Customers AS c
FULL JOIN dbo.Orders AS o
    ON c.CustomerId = o.CustomerId
ORDER BY c.CustomerId, o.OrderId;
GO

-- FULL JOIN shows:
-- 1) matched rows
-- 2) customers without orders
-- 3) orders without real customers

------------------------------------------------------------
-- 8) CROSS JOIN: ALL POSSIBLE COMBINATIONS
------------------------------------------------------------

-- Every size with every color
SELECT
    s.SizeName,
    c.ColorName
FROM dbo.Sizes AS s
CROSS JOIN dbo.Colors AS c
ORDER BY s.SizeName, c.ColorName;
GO

-- Count how many combinations were generated
SELECT COUNT(*) AS TotalCombinations
FROM dbo.Sizes AS s
CROSS JOIN dbo.Colors AS c;
GO

-- If there are 3 sizes and 4 colors,
-- the result is 12 rows.

------------------------------------------------------------
-- 9) COMMON MISTAKES
------------------------------------------------------------

-- ERROR DEMO 1: Wrong join key
-- This query runs, but logic is wrong.
-- CustomerId should not be matched to OrderId.
SELECT
    c.CustomerName,
    o.OrderId
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerId = o.OrderId
ORDER BY o.OrderId;
GO

-- FIX:
SELECT
    c.CustomerName,
    o.OrderId
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerId = o.CustomerId
ORDER BY o.OrderId;
GO

-- ERROR DEMO 2: LEFT JOIN accidentally becomes INNER JOIN
-- Because WHERE o.OrderId IS NOT NULL removes NULL rows
SELECT
    c.CustomerName,
    o.OrderId
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
    ON c.CustomerId = o.CustomerId
WHERE o.OrderId IS NOT NULL
ORDER BY c.CustomerName;
GO

-- Correct orphan search:
SELECT
    c.CustomerName
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
    ON c.CustomerId = o.CustomerId
WHERE o.OrderId IS NULL
ORDER BY c.CustomerName;
GO

-- ERROR DEMO 3: Ambiguous column name
-- Uncomment to see the error
-- SELECT CustomerId
-- FROM dbo.Customers AS c
-- INNER JOIN dbo.Orders AS o
--     ON c.CustomerId = o.CustomerId;

-- FIX: prefix the column with the alias
SELECT
    c.CustomerId,
    c.CustomerName,
    o.OrderId
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerId = o.CustomerId;
GO

-- ERROR DEMO 4: Missing ON in a normal JOIN
-- Uncomment to see the syntax problem
-- SELECT *
-- FROM dbo.Customers AS c
-- INNER JOIN dbo.Orders AS o;

------------------------------------------------------------
-- 10) EXTRA TEACHING EXAMPLES
------------------------------------------------------------

-- A) Show all ordered products with readable business columns
SELECT
    o.OrderId,
    o.OrderDate,
    c.CustomerName,
    p.ProductName,
    oi.Quantity,
    p.Price,
    oi.Quantity * p.Price AS LineTotal
FROM dbo.Orders AS o
LEFT JOIN dbo.Customers AS c
    ON o.CustomerId = c.CustomerId
LEFT JOIN dbo.OrderItems AS oi
    ON o.OrderId = oi.OrderId
LEFT JOIN dbo.Products AS p
    ON oi.ProductId = p.ProductId
ORDER BY o.OrderId, p.ProductName;
GO

-- B) Total value per order
SELECT
    o.OrderId,
    SUM(oi.Quantity * p.Price) AS OrderTotal
FROM dbo.Orders AS o
INNER JOIN dbo.OrderItems AS oi
    ON o.OrderId = oi.OrderId
INNER JOIN dbo.Products AS p
    ON oi.ProductId = p.ProductId
GROUP BY o.OrderId
ORDER BY o.OrderId;
GO

-- C) Total spent per customer
SELECT
    c.CustomerName,
    SUM(oi.Quantity * p.Price) AS TotalSpent
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
    ON c.CustomerId = o.CustomerId
INNER JOIN dbo.OrderItems AS oi
    ON o.OrderId = oi.OrderId
INNER JOIN dbo.Products AS p
    ON oi.ProductId = p.ProductId
GROUP BY c.CustomerName
ORDER BY TotalSpent DESC;
GO

-- D) Number of orders per customer, including customers with zero orders
SELECT
    c.CustomerName,
    COUNT(o.OrderId) AS OrdersCount
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
    ON c.CustomerId = o.CustomerId
GROUP BY c.CustomerName
ORDER BY OrdersCount DESC, c.CustomerName;
GO

------------------------------------------------------------
-- 11) YOUR TURN (25 TASKS)
------------------------------------------------------------

-- [SECTION A: BASIC INNER JOIN]
-- 1. Show CustomerName + OrderId + OrderDate.
-- 2. Show OrderId + ProductName + Quantity.
-- 3. Show CustomerName + ProductName for every ordered product.
-- 4. Show OrderId, ProductName, Quantity, Price, LineTotal.
-- 5. Show all orders made by Alice.

-- [SECTION B: LEFT JOIN / ORPHANS]
-- 6. Show all customers with their orders (including customers without orders).
-- 7. Find customers with no orders.
-- 8. Find products never used in OrderItems.
-- 9. Find orders that do not match a real customer.
-- 10. Find order items that do not match a real product.

-- [SECTION C: FULL JOIN]
-- 11. Show all customers and all orders in one result.
-- 12. Show only rows that exist on one side but not both.
-- 13. Show all products and order items in one result.

-- [SECTION D: CROSS JOIN]
-- 14. Generate all Size + Color combinations.
-- 15. Count how many total combinations exist.
-- 16. Show the combinations sorted by Size, then Color.

-- [SECTION E: MULTI-JOIN REPORTS]
-- 17. Total value of each order.
-- 18. Total spent by each customer.
-- 19. Number of orders per customer.
-- 20. Number of products in each order.
-- 21. Average product price inside each order.

-- [SECTION F: THINKING TASKS]
-- 22. Why is one giant table worse than Customers + Orders + Products?
-- 23. Which JOIN is best for finding "orphans"?
-- 24. What happens if you use the wrong key in ON?
-- 25. Rewrite one query using aliases c, o, oi, p only.

/*
END OF LAB
*/
