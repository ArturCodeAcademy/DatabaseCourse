/*
============================================================
07_Lab.sql — Lesson 7: Subqueries (WHERE IN) + CTE (WITH)
============================================================
*/

------------------------------------------------------------
-- 0) Create and use a sandbox database
------------------------------------------------------------
IF DB_ID('SqlCourse') IS NULL
BEGIN
    CREATE DATABASE SqlCourse;
END
GO

USE SqlCourse;
GO

------------------------------------------------------------
-- 1) Drop tables (correct order for FK dependencies)
------------------------------------------------------------
IF OBJECT_ID('dbo.OrderItems', 'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.VipList', 'U') IS NOT NULL DROP TABLE dbo.VipList;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
GO

------------------------------------------------------------
-- 2) Create tables
------------------------------------------------------------

CREATE TABLE dbo.Customers
(
    CustomerId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Customers PRIMARY KEY,
    CustomerCode NVARCHAR(20) NOT NULL CONSTRAINT UQ_Customers_Code UNIQUE,
    FirstName    NVARCHAR(50) NOT NULL,
    LastName     NVARCHAR(50) NOT NULL,
    City         NVARCHAR(50) NOT NULL,
    CreatedAt    DATETIME2(0) NOT NULL CONSTRAINT DF_Customers_CreatedAt DEFAULT (SYSDATETIME())
);
GO

CREATE TABLE dbo.Categories
(
    CategoryId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Categories PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL CONSTRAINT UQ_Categories_Name UNIQUE
);
GO

CREATE TABLE dbo.Products
(
    ProductId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Products PRIMARY KEY,
    Sku         NVARCHAR(30) NOT NULL CONSTRAINT UQ_Products_Sku UNIQUE,
    ProductName NVARCHAR(100) NOT NULL,
    CategoryId  INT NOT NULL,
    Price       DECIMAL(10,2) NOT NULL CONSTRAINT CK_Products_Price CHECK (Price >= 0),
    IsActive    BIT NOT NULL CONSTRAINT DF_Products_IsActive DEFAULT (1),

    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId)
        REFERENCES dbo.Categories(CategoryId)
);
GO

CREATE TABLE dbo.Orders
(
    OrderId      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Orders PRIMARY KEY,
    CustomerId   INT NOT NULL,
    OrderDate    DATE NOT NULL,
    Status       NVARCHAR(20) NOT NULL CONSTRAINT CK_Orders_Status CHECK (Status IN ('Paid','Shipped','Cancelled')),
    ShippingCity NVARCHAR(50) NOT NULL,
    CreatedAt    DATETIME2(0) NOT NULL CONSTRAINT DF_Orders_CreatedAt DEFAULT (SYSDATETIME()),

    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId)
        REFERENCES dbo.Customers(CustomerId)
);
GO

CREATE TABLE dbo.OrderItems
(
    OrderItemId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_OrderItems PRIMARY KEY,
    OrderId     INT NOT NULL,
    ProductId   INT NOT NULL,
    Quantity    INT NOT NULL CONSTRAINT CK_OrderItems_Qty CHECK (Quantity BETWEEN 1 AND 100),
    UnitPrice   DECIMAL(10,2) NOT NULL CONSTRAINT CK_OrderItems_UnitPrice CHECK (UnitPrice >= 0),

    CONSTRAINT FK_OrderItems_Orders   FOREIGN KEY (OrderId)   REFERENCES dbo.Orders(OrderId),
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),

    -- prevent duplicate product lines per order (simple rule for this lab)
    CONSTRAINT UQ_OrderItems_OrderProduct UNIQUE (OrderId, ProductId)
);
GO

-- Helper table to demonstrate NOT IN + NULL trap
CREATE TABLE dbo.VipList
(
    VipId       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_VipList PRIMARY KEY,
    CustomerId  INT NULL, -- nullable on purpose
    Note        NVARCHAR(100) NOT NULL
);
GO

------------------------------------------------------------
-- 3) Insert sample data
------------------------------------------------------------

INSERT INTO dbo.Customers (CustomerCode, FirstName, LastName, City)
VALUES
(N'C-1001', N'Alice',  N'Garcia',  N'Boston'),
(N'C-1002', N'Ben',    N'Miller',  N'Chicago'),
(N'C-1003', N'Chloe',  N'Ng',      N'Seattle'),
(N'C-1004', N'David',  N'Patel',   N'Austin'),
(N'C-1005', N'Emma',   N'Brooks',  N'Denver'),
(N'C-1006', N'Frank',  N'Woods',   N'Boston'),
(N'C-1007', N'Grace',  N'Lee',     N'New York'),
(N'C-1008', N'Henry',  N'Adams',   N'Chicago');
GO

INSERT INTO dbo.Categories (CategoryName)
VALUES
(N'Electronics'),
(N'Home'),
(N'Books'),
(N'Fitness');
GO

INSERT INTO dbo.Products (Sku, ProductName, CategoryId, Price)
VALUES
(N'SKU-USB-C-01',   N'USB-C Cable 1m',                 1,  9.99),
(N'SKU-MOUSE-01',   N'Wireless Mouse',                 1, 24.50),
(N'SKU-HEAD-01',    N'Over-Ear Headphones',            1, 79.00),
(N'SKU-MUG-01',     N'Ceramic Coffee Mug',             2, 12.00),
(N'SKU-LAMP-01',    N'Desk Lamp',                      2, 35.00),
(N'SKU-BOOK-01',    N'SQL Fundamentals (Book)',        3, 29.99),
(N'SKU-BOOK-02',    N'Clean Code (Book)',              3, 39.99),
(N'SKU-YOGA-01',    N'Yoga Mat',                       4, 22.00),
(N'SKU-DUMB-01',    N'Dumbbell 10kg',                  4, 45.00),
(N'SKU-LOCK-01',    N'Notebook Lock (Travel)',         2, 18.00); -- may remain unsold in this dataset
GO

-- Orders: mix of Paid / Shipped / Cancelled
INSERT INTO dbo.Orders (CustomerId, OrderDate, Status, ShippingCity)
VALUES
(1, '2025-02-02', 'Paid',      N'Boston'),
(1, '2025-03-10', 'Cancelled', N'Boston'),
(2, '2025-02-05', 'Shipped',   N'Chicago'),
(3, '2025-02-18', 'Paid',      N'Seattle'),
(3, '2025-04-01', 'Paid',      N'Seattle'),
(4, '2025-03-15', 'Cancelled', N'Austin'),
(5, '2025-03-20', 'Paid',      N'Denver'),
(6, '2025-04-11', 'Shipped',   N'Boston'),
(7, '2025-04-12', 'Paid',      N'New York');
GO

-- OrderItems (UnitPrice captured at purchase time)
INSERT INTO dbo.OrderItems (OrderId, ProductId, Quantity, UnitPrice)
VALUES
-- Order 1 (Customer 1) Paid
(1, 1, 2,  9.99),   -- USB-C x2
(1, 2, 1, 24.50),   -- Mouse x1

-- Order 2 (Customer 1) Cancelled
(2, 3, 1, 79.00),   -- Headphones x1

-- Order 3 (Customer 2) Shipped
(3, 6, 1, 29.99),   -- SQL Book x1
(3, 4, 2, 12.00),   -- Mug x2

-- Order 4 (Customer 3) Paid
(4, 8, 1, 22.00),   -- Yoga mat
(4, 1, 1,  9.99),   -- USB-C

-- Order 5 (Customer 3) Paid
(5, 9, 1, 45.00),   -- Dumbbell
(5, 7, 1, 39.99),   -- Clean Code

-- Order 6 (Customer 4) Cancelled
(6, 5, 1, 35.00),   -- Lamp

-- Order 7 (Customer 5) Paid
(7, 3, 1, 79.00),   -- Headphones
(7, 6, 1, 29.99),   -- SQL Book

-- Order 8 (Customer 6) Shipped
(8, 4, 1, 12.00),   -- Mug

-- Order 9 (Customer 7) Paid
(9, 2, 1, 24.50),   -- Mouse
(9, 1, 3,  9.99);   -- USB-C x3
GO

-- VipList includes a NULL CustomerId to demonstrate NOT IN trap
INSERT INTO dbo.VipList (CustomerId, Note)
VALUES
(1, N'VIP: frequent buyer'),
(3, N'VIP: high spend'),
(NULL, N'Bad data row (NULL CustomerId)'); -- intentionally NULL
GO

------------------------------------------------------------
-- 4) Quick previews
------------------------------------------------------------
SELECT TOP (10) * FROM dbo.Customers ORDER BY CustomerId;
SELECT TOP (10) * FROM dbo.Products  ORDER BY ProductId;
SELECT TOP (10) * FROM dbo.Orders    ORDER BY OrderId;
SELECT TOP (10) * FROM dbo.OrderItems ORDER BY OrderItemId;
GO

------------------------------------------------------------
-- 5) Subqueries in WHERE: IN (SELECT ...)
------------------------------------------------------------

-- 5.1 Customers who have ANY cancelled order
SELECT c.CustomerCode, c.FirstName, c.LastName
FROM dbo.Customers AS c
WHERE c.CustomerId IN (
    SELECT o.CustomerId
    FROM dbo.Orders AS o
    WHERE o.Status = 'Cancelled'
)
ORDER BY c.CustomerCode;
GO

-- 5.2 Products that were ever ordered (appear in OrderItems)
SELECT p.Sku, p.ProductName
FROM dbo.Products AS p
WHERE p.ProductId IN (
    SELECT oi.ProductId
    FROM dbo.OrderItems AS oi
)
ORDER BY p.Sku;
GO

-- 5.3 Customers who bought something from the 'Electronics' category
SELECT c.CustomerCode, c.FirstName, c.LastName
FROM dbo.Customers AS c
WHERE c.CustomerId IN (
    SELECT o.CustomerId
    FROM dbo.Orders o
    JOIN dbo.OrderItems oi ON oi.OrderId = o.OrderId
    JOIN dbo.Products p ON p.ProductId = oi.ProductId
    JOIN dbo.Categories cat ON cat.CategoryId = p.CategoryId
    WHERE o.Status IN ('Paid','Shipped')
      AND cat.CategoryName = 'Electronics'
)
ORDER BY c.CustomerCode;
GO

------------------------------------------------------------
-- 6) Scalar subquery examples (one value)
------------------------------------------------------------

-- 6.1 Products priced above the average product price
SELECT p.Sku, p.ProductName, p.Price
FROM dbo.Products p
WHERE p.Price > (SELECT AVG(Price) FROM dbo.Products)
ORDER BY p.Price DESC;
GO

-- 6.2 Customers who placed an order on the earliest order date
SELECT c.CustomerCode, c.FirstName, c.LastName
FROM dbo.Customers c
WHERE c.CustomerId IN (
    SELECT o.CustomerId
    FROM dbo.Orders o
    WHERE o.OrderDate = (SELECT MIN(OrderDate) FROM dbo.Orders)
)
ORDER BY c.CustomerCode;
GO

------------------------------------------------------------
-- 7) NOT IN + NULL trap demo (important!)
------------------------------------------------------------

-- INTENTION: Customers who are NOT VIP
-- WARNING: VipList.CustomerId contains NULL, so NOT IN can return zero rows or surprising results.
SELECT c.CustomerCode, c.FirstName, c.LastName
FROM dbo.Customers c
WHERE c.CustomerId NOT IN (
    SELECT v.CustomerId
    FROM dbo.VipList v
);
GO

-- Fix: filter NULLs out of the subquery
SELECT c.CustomerCode, c.FirstName, c.LastName
FROM dbo.Customers c
WHERE c.CustomerId NOT IN (
    SELECT v.CustomerId
    FROM dbo.VipList v
    WHERE v.CustomerId IS NOT NULL
)
ORDER BY c.CustomerCode;
GO

------------------------------------------------------------
-- 8) CTE basics: WITH ... AS (...)
------------------------------------------------------------

-- 8.1 Simple CTE: Paid orders
;WITH PaidOrders AS (
    SELECT OrderId, CustomerId, OrderDate
    FROM dbo.Orders
    WHERE Status = 'Paid'
)
SELECT *
FROM PaidOrders
ORDER BY OrderDate, OrderId;
GO

-- 8.2 CTE + join: Paid orders with customer names
;WITH PaidOrders AS (
    SELECT OrderId, CustomerId, OrderDate
    FROM dbo.Orders
    WHERE Status = 'Paid'
)
SELECT
    po.OrderId,
    po.OrderDate,
    c.CustomerCode,
    CONCAT(c.FirstName, N' ', c.LastName) AS FullName,
    c.City
FROM PaidOrders po
JOIN dbo.Customers c ON c.CustomerId = po.CustomerId
ORDER BY po.OrderDate, po.OrderId;
GO

------------------------------------------------------------
-- 9) Multi-step CTE: split complex logic into steps
------------------------------------------------------------

-- 9.1 Pipeline: Paid orders -> revenue per order -> lifetime spend per customer
;WITH PaidOrders AS (
    SELECT OrderId, CustomerId
    FROM dbo.Orders
    WHERE Status = 'Paid'
),
OrderTotals AS (
    SELECT po.CustomerId, po.OrderId,
           SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
    FROM PaidOrders po
    JOIN dbo.OrderItems oi ON oi.OrderId = po.OrderId
    GROUP BY po.CustomerId, po.OrderId
),
CustomerSpend AS (
    SELECT CustomerId,
           COUNT(*) AS PaidOrdersCount,
           SUM(OrderTotal) AS LifetimeSpend
    FROM OrderTotals
    GROUP BY CustomerId
)
SELECT
    c.CustomerCode,
    CONCAT(c.FirstName, N' ', c.LastName) AS FullName,
    cs.PaidOrdersCount,
    cs.LifetimeSpend
FROM CustomerSpend cs
JOIN dbo.Customers c ON c.CustomerId = cs.CustomerId
ORDER BY cs.LifetimeSpend DESC;
GO

-- 9.2 Product revenue leaderboard (paid orders only)
;WITH PaidOrders AS (
    SELECT OrderId
    FROM dbo.Orders
    WHERE Status = 'Paid'
),
PaidItems AS (
    SELECT oi.ProductId,
           oi.Quantity,
           oi.UnitPrice
    FROM dbo.OrderItems oi
    JOIN PaidOrders po ON po.OrderId = oi.OrderId
),
RevenuePerProduct AS (
    SELECT ProductId,
           SUM(Quantity * UnitPrice) AS Revenue
    FROM PaidItems
    GROUP BY ProductId
)
SELECT TOP (5)
    p.Sku,
    p.ProductName,
    rpp.Revenue
FROM RevenuePerProduct rpp
JOIN dbo.Products p ON p.ProductId = rpp.ProductId
ORDER BY rpp.Revenue DESC;
GO

------------------------------------------------------------
-- 10) YOUR TURN — Practice (MORE tasks)
------------------------------------------------------------

/*
========================
A) IN (SELECT ...) basics
========================
1) Customers who have any Shipped order.
2) Customers who have any Paid order.
3) Customers who have both Paid OR Shipped orders (use IN with a subquery).
4) Products ever ordered (distinct products that appear in OrderItems).
5) Customers who bought SKU 'SKU-USB-C-01'.
6) Customers who bought from category 'Books'.
7) Customers who have at least one order shipped to a city different from their Customer.City.

========================
B) NOT IN (and NULL trap)
========================
8) Products never ordered (NOT IN).
9) Customers not in VipList (first do it with NOT IN and observe the problem).
10) Fix #9 by filtering NULLs in the subquery.
11) Customers who never placed any order (NOT IN with Orders.CustomerId).

========================
C) Scalar subqueries
========================
12) Products above average price.
13) Products above the average price of their own category (hint: subquery using CategoryId).
14) Customers who placed an order on the latest OrderDate (MAX).
15) Orders whose total value is above the average order total (use a scalar subquery + derived totals).

========================
D) CTE (single step)
========================
16) Create a CTE CancelledOrders and show OrderId, CustomerId, OrderDate.
17) Join CancelledOrders to Customers and output FullName + OrderDate.

========================
E) CTE (multi-step pipelines)
========================
18) Paid order totals per order (OrderId, CustomerId, OrderTotal).
19) Average paid order total per customer (AvgOrderTotal) + show only AvgOrderTotal >= 50.
20) One-time buyers: customers with exactly 1 paid order.
21) Customers who bought from at least 2 distinct categories (CTE: categories per customer -> count distinct).
22) Top 3 customers by lifetime spend (paid only).
23) Top 3 products by quantity sold (paid only) (CTE: PaidItems -> sum qty).
24) For each city, show total paid revenue (CTE: PaidOrders -> OrderTotals -> join Customers -> group by city).

========================
F) Refactoring / comparison tasks
========================
25) Pick one IN-subquery solution and rewrite it using a CTE.
26) Pick one CTE solution and rewrite it as a nested subquery (no WITH).
27) Choose one of your queries and rewrite it to improve readability:
    - consistent aliases,
    - aligned formatting,
    - avoid SELECT *.

Write your solutions below.
*/

-- Solutions area:

-- 1)
-- SELECT ...

