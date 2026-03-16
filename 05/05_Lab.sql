/*
============================================================
05_Lab.sql — Lesson 5: DDL — Creating the World
============================================================

How to use this lab:
1) Read the examples first.
2) Run the safe statements one by one.
3) Uncomment error demos only when you want to test validation.

This lab focuses on:
- CREATE DATABASE
- CREATE TABLE
- data types
- PK, FK, DEFAULT, CHECK
*/

------------------------------------------------------------
-- 1) CREATE DATABASE
------------------------------------------------------------

-- Uncomment if you want to create a fresh database:
-- CREATE DATABASE SqlCourse_DDL;
-- GO

USE SqlCourse;
GO

------------------------------------------------------------
-- 2) CLEANUP
------------------------------------------------------------
IF OBJECT_ID('dbo.OrderLines', 'U') IS NOT NULL DROP TABLE dbo.OrderLines;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
GO

------------------------------------------------------------
-- 3) CREATE TABLE: Customers
------------------------------------------------------------
CREATE TABLE dbo.Customers (
    CustomerId INT PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    City NVARCHAR(50) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'New'
);
GO

------------------------------------------------------------
-- 4) CREATE TABLE: Products
------------------------------------------------------------
CREATE TABLE dbo.Products (
    ProductId INT PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    Stock INT NOT NULL DEFAULT 0 CHECK (Stock >= 0),
    CreatedAt DATE NOT NULL DEFAULT GETDATE()
);
GO

------------------------------------------------------------
-- 5) CREATE TABLE: Orders
------------------------------------------------------------
CREATE TABLE dbo.Orders (
    OrderId INT PRIMARY KEY,
    CustomerId INT NOT NULL,
    OrderDate DATE NOT NULL DEFAULT GETDATE(),
    OrderStatus NVARCHAR(20) NOT NULL DEFAULT 'New'
        CHECK (OrderStatus IN ('New', 'Paid', 'Shipped', 'Cancelled')),
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerId)
        REFERENCES dbo.Customers(CustomerId)
);
GO

------------------------------------------------------------
-- 6) CREATE TABLE: OrderLines
------------------------------------------------------------
CREATE TABLE dbo.OrderLines (
    OrderLineId INT PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice > 0),
    CONSTRAINT FK_OrderLines_Orders
        FOREIGN KEY (OrderId)
        REFERENCES dbo.Orders(OrderId),
    CONSTRAINT FK_OrderLines_Products
        FOREIGN KEY (ProductId)
        REFERENCES dbo.Products(ProductId)
);
GO

------------------------------------------------------------
-- 7) INSERT VALID DATA
------------------------------------------------------------
INSERT INTO dbo.Customers (CustomerId, FullName, Email, City)
VALUES
(1, N'Alice Johnson', 'alice@example.com', N'New York'),
(2, N'Bob Smith', 'bob@example.com', N'Chicago'),
(3, N'Мария Иванова', 'maria@example.com', N'Warsaw');
GO

INSERT INTO dbo.Products (ProductId, ProductName, Price, Stock)
VALUES
(1, N'Laptop', 1200.00, 10),
(2, N'Mouse', 25.00, 100),
(3, N'Keyboard', 80.00, 50);
GO

INSERT INTO dbo.Orders (OrderId, CustomerId, OrderStatus)
VALUES
(1001, 1, 'New'),
(1002, 2, 'Paid');
GO

INSERT INTO dbo.OrderLines (OrderLineId, OrderId, ProductId, Quantity, UnitPrice)
VALUES
(1, 1001, 1, 1, 1200.00),
(2, 1001, 2, 2, 25.00),
(3, 1002, 3, 1, 80.00);
GO

------------------------------------------------------------
-- 8) CHECK WHAT WAS CREATED
------------------------------------------------------------
SELECT * FROM dbo.Customers;
SELECT * FROM dbo.Products;
SELECT * FROM dbo.Orders;
SELECT * FROM dbo.OrderLines;
GO

------------------------------------------------------------
-- 9) DEMO: DEFAULT VALUES
------------------------------------------------------------
INSERT INTO dbo.Customers (CustomerId, FullName, Email, City)
VALUES (4, N'Diana Miller', 'diana@example.com', N'Seattle');
GO

INSERT INTO dbo.Orders (OrderId, CustomerId)
VALUES (1003, 4);
GO

SELECT * FROM dbo.Customers WHERE CustomerId = 4;
SELECT * FROM dbo.Orders WHERE OrderId = 1003;
GO

------------------------------------------------------------
-- 10) DEMO: COMMON ERRORS (Uncomment to test)
------------------------------------------------------------

-- ERROR DEMO 1: Duplicate PK
-- INSERT INTO dbo.Customers (CustomerId, FullName, Email)
-- VALUES (1, N'Another Alice', 'another@example.com');

-- ERROR DEMO 2: CHECK violation (negative price)
-- INSERT INTO dbo.Products (ProductId, ProductName, Price, Stock)
-- VALUES (10, N'Broken Product', -50.00, 5);

-- ERROR DEMO 3: CHECK violation (negative stock)
-- INSERT INTO dbo.Products (ProductId, ProductName, Price, Stock)
-- VALUES (11, N'Strange Product', 99.00, -1);

-- ERROR DEMO 4: FK violation (customer does not exist)
-- INSERT INTO dbo.Orders (OrderId, CustomerId)
-- VALUES (2001, 999);

-- ERROR DEMO 5: FK violation (product does not exist)
-- INSERT INTO dbo.OrderLines (OrderLineId, OrderId, ProductId, Quantity, UnitPrice)
-- VALUES (10, 1001, 999, 1, 10.00);

-- ERROR DEMO 6: CHECK violation (invalid status)
-- INSERT INTO dbo.Orders (OrderId, CustomerId, OrderStatus)
-- VALUES (2002, 1, 'Unknown');

-- ERROR DEMO 7: CHECK violation (quantity must be > 0)
-- INSERT INTO dbo.OrderLines (OrderLineId, OrderId, ProductId, Quantity, UnitPrice)
-- VALUES (11, 1001, 1, 0, 1200.00);

------------------------------------------------------------
-- 11) EXTRA TEACHING EXAMPLES
------------------------------------------------------------
INSERT INTO dbo.Customers (CustomerId, FullName, Email, City)
VALUES (5, N'李华', 'lihua@example.com', N'Beijing');
GO

SELECT CustomerId, FullName, City
FROM dbo.Customers
WHERE CustomerId = 5;
GO

SELECT
    ProductName,
    Price,
    Stock,
    Price * Stock AS StockValue
FROM dbo.Products
ORDER BY ProductId;
GO

------------------------------------------------------------
-- 12) YOUR TURN (25 TASKS)
------------------------------------------------------------

-- [SECTION A: DATABASE / TABLE THINKING]
-- 1. Write a CREATE DATABASE statement for ShopSchool.
-- 2. Why is NVARCHAR safer than VARCHAR for multilingual names?
-- 3. Why is DECIMAL better than FLOAT for money?
-- 4. Which constraint prevents duplicate IDs?
-- 5. Which constraint prevents invalid references between tables?

-- [SECTION B: SIMPLE TABLE CREATION]
-- 6. Create a dbo.Categories table with CategoryId + CategoryName.
-- 7. Create a dbo.Suppliers table with SupplierId + SupplierName + City.
-- 8. Add a CHECK example for a rating from 1 to 5.
-- 9. Add a DEFAULT example for CreatedDate.
-- 10. Add NOT NULL to a required column.

-- [SECTION C: VALIDATION THINKING]
-- 11. What happens if Price = -10?
-- 12. What happens if Stock = -1?
-- 13. What happens if OrderStatus = 'Unknown'?
-- 14. What happens if Order.CustomerId does not exist in Customers?
-- 15. What happens if you insert duplicate ProductId?

-- [SECTION D: PRACTICAL DESIGN]
-- 16. Create a table for Reviews with PK and CHECK (Rating BETWEEN 1 AND 5).
-- 17. Create a table for Payments with positive Amount.
-- 18. Create a table for Addresses linked to Customers.
-- 19. Add a DEFAULT status to a new table.
-- 20. Add a FOREIGN KEY from a child table to a parent table.

-- [SECTION E: READING EXISTING STRUCTURE]
-- 21. Which columns in dbo.Products are protected by CHECK?
-- 22. Which tables use FOREIGN KEY?
-- 23. Which columns use DEFAULT?
-- 24. Which columns are good candidates for NVARCHAR?
-- 25. Design your own small schema: Students + Courses + Enrollments.

/*
END OF LAB
*/
