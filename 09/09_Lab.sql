/*
============================================================
09_Lab.sql — Lesson 9: VIEWs + Stored Procedures (Programmability)
============================================================

Dataset: Online Store (Users, Products, Orders, OrderItems)
Purpose:
- VIEW: store complex JOIN + aggregation as a reusable “virtual table”
- Stored Procedures: parameterized logic (e.g. @UserId) + basic business rules

Run section by section.

*/

------------------------------------------------------------
-- 0) Create and use sandbox DB
------------------------------------------------------------
IF DB_ID('SqlCourse') IS NULL
BEGIN
    CREATE DATABASE SqlCourse;
END
GO

USE SqlCourse;
GO

------------------------------------------------------------
-- 1) Drop objects (safe to rerun)
------------------------------------------------------------
IF OBJECT_ID('dbo.vw_OrderSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_OrderSummary;
GO

IF OBJECT_ID('dbo.sp_GetUserOrders', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetUserOrders;
IF OBJECT_ID('dbo.sp_CreateOrder', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_CreateOrder;
IF OBJECT_ID('dbo.sp_AddOrderItem', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_AddOrderItem;
GO

IF OBJECT_ID('dbo.OrderItems', 'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
GO

------------------------------------------------------------
-- 2) Create tables
------------------------------------------------------------

CREATE TABLE dbo.Users
(
    UserId    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Users PRIMARY KEY,
    Email     NVARCHAR(100) NOT NULL CONSTRAINT UQ_Users_Email UNIQUE,
    FirstName NVARCHAR(50) NOT NULL,
    LastName  NVARCHAR(50) NOT NULL,
    City      NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT (SYSDATETIME())
);
GO

CREATE TABLE dbo.Products
(
    ProductId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Products PRIMARY KEY,
    Sku         NVARCHAR(30) NOT NULL CONSTRAINT UQ_Products_Sku UNIQUE,
    ProductName NVARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL CONSTRAINT CK_Products_Price CHECK (Price >= 0),
    IsActive    BIT NOT NULL CONSTRAINT DF_Products_IsActive DEFAULT (1)
);
GO

CREATE TABLE dbo.Orders
(
    OrderId    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Orders PRIMARY KEY,
    UserId     INT NOT NULL,
    OrderDate  DATE NOT NULL,
    Status     NVARCHAR(20) NOT NULL CONSTRAINT CK_Orders_Status CHECK (Status IN ('Paid','Shipped','Cancelled')),
    CreatedAt  DATETIME2(0) NOT NULL CONSTRAINT DF_Orders_CreatedAt DEFAULT (SYSDATETIME()),

    CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId)
        REFERENCES dbo.Users(UserId)
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

    CONSTRAINT UQ_OrderItems_OrderProduct UNIQUE (OrderId, ProductId)
);
GO

------------------------------------------------------------
-- 3) Insert sample data
------------------------------------------------------------

INSERT INTO dbo.Users (Email, FirstName, LastName, City)
VALUES
(N'ava.harris@example.com',  N'Ava',   N'Harris',  N'Boston'),
(N'liam.turner@example.com', N'Liam',  N'Turner',  N'Chicago'),
(N'mia.walker@example.com',  N'Mia',   N'Walker',  N'Austin'),
(N'noah.young@example.com',  N'Noah',  N'Young',   N'Denver'),
(N'emma.king@example.com',   N'Emma',  N'King',    N'Seattle');
GO

INSERT INTO dbo.Products (Sku, ProductName, Price, IsActive)
VALUES
(N'SKU-TSHIRT-01', N'T-Shirt',               19.99, 1),
(N'SKU-MUG-01',    N'Coffee Mug',            12.00, 1),
(N'SKU-MOUSE-01',  N'Wireless Mouse',        24.50, 1),
(N'SKU-USB-C-01',  N'USB-C Cable 1m',         9.99, 1),
(N'SKU-BOOK-01',   N'SQL Quickstart Book',   29.99, 1),
(N'SKU-LAMP-01',   N'Desk Lamp',             35.00, 1),
(N'SKU-MAT-01',    N'Yoga Mat',              22.00, 1),
(N'SKU-DUMB-01',   N'Dumbbell 10kg',         45.00, 1);
GO

INSERT INTO dbo.Orders (UserId, OrderDate, Status)
VALUES
(1, '2025-02-02', 'Paid'),
(1, '2025-03-10', 'Cancelled'),
(2, '2025-02-05', 'Shipped'),
(3, '2025-02-18', 'Paid'),
(3, '2025-04-01', 'Paid'),
(4, '2025-03-15', 'Cancelled'),
(5, '2025-03-20', 'Paid'),
(2, '2025-04-11', 'Shipped'),
(5, '2025-04-12', 'Paid');
GO

-- Capture UnitPrice at purchase time (it can differ from current Product.Price)
INSERT INTO dbo.OrderItems (OrderId, ProductId, Quantity, UnitPrice)
VALUES
(1, 4, 2,  9.99),  -- USB-C x2
(1, 3, 1, 24.50),  -- Mouse x1
(2, 6, 1, 35.00),  -- Lamp (cancelled order)
(3, 5, 1, 29.99),  -- Book
(3, 2, 2, 12.00),  -- Mug x2
(4, 7, 1, 22.00),  -- Yoga mat
(4, 4, 1,  9.99),  -- USB-C
(5, 8, 1, 45.00),  -- Dumbbell
(5, 5, 1, 29.99),  -- Book
(6, 1, 1, 19.99),  -- T-Shirt (cancelled order)
(7, 3, 1, 24.50),  -- Mouse
(7, 4, 3,  9.99),  -- USB-C x3
(8, 2, 1, 12.00),  -- Mug
(9, 6, 1, 35.00),  -- Lamp
(9, 4, 1,  9.99);  -- USB-C
GO

------------------------------------------------------------
-- 4) VIEW: save a complex JOIN + aggregation
------------------------------------------------------------

/*
vw_OrderSummary returns one row per order:
- order info (OrderId, OrderDate, Status)
- user info (UserCode via UserId, FullName, City)
- computed fields:
    ItemsCount (sum of quantities)
    OrderTotal (sum of quantity * unitprice)
*/
CREATE VIEW dbo.vw_OrderSummary
AS
SELECT
    o.OrderId,
    o.OrderDate,
    o.Status,
    u.UserId,
    CONCAT(u.FirstName, N' ', u.LastName) AS FullName,
    u.City,
    SUM(oi.Quantity) AS ItemsCount,
    SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
FROM dbo.Orders AS o
JOIN dbo.Users AS u
    ON u.UserId = o.UserId
JOIN dbo.OrderItems AS oi
    ON oi.OrderId = o.OrderId
GROUP BY
    o.OrderId, o.OrderDate, o.Status,
    u.UserId, u.FirstName, u.LastName, u.City;
GO

-- Using the view (much simpler than repeating JOINs)
SELECT *
FROM dbo.vw_OrderSummary
ORDER BY OrderTotal DESC;
GO

------------------------------------------------------------
-- 5) Stored Procedure: parameterized reads (@UserId)
------------------------------------------------------------

CREATE PROCEDURE dbo.sp_GetUserOrders
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        os.OrderId,
        os.OrderDate,
        os.Status,
        os.ItemsCount,
        os.OrderTotal
    FROM dbo.vw_OrderSummary AS os
    WHERE os.UserId = @UserId
    ORDER BY os.OrderDate DESC, os.OrderId DESC;
END
GO

-- Execute procedure
EXEC dbo.sp_GetUserOrders @UserId = 1;
EXEC dbo.sp_GetUserOrders @UserId = 3;
GO

------------------------------------------------------------
-- 6) Stored Procedure: create an order (write logic)
------------------------------------------------------------

/*
sp_CreateOrder inserts a new order for a user and returns the new OrderId.
*/
CREATE PROCEDURE dbo.sp_CreateOrder
    @UserId INT,
    @OrderDate DATE,
    @Status NVARCHAR(20) = 'Paid',
    @NewOrderId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Basic validation
    IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE UserId = @UserId)
    BEGIN
        RAISERROR('UserId does not exist.', 16, 1);
        RETURN;
    END

    IF @Status NOT IN ('Paid','Shipped','Cancelled')
    BEGIN
        RAISERROR('Invalid Status.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.Orders (UserId, OrderDate, Status)
    VALUES (@UserId, @OrderDate, @Status);

    SET @NewOrderId = CAST(SCOPE_IDENTITY() AS INT);
END
GO

-- Example usage
DECLARE @OrderId INT;
EXEC dbo.sp_CreateOrder
    @UserId = 1,
    @OrderDate = '2025-05-01',
    @Status = 'Paid',
    @NewOrderId = @OrderId OUTPUT;

SELECT @OrderId AS NewOrderId;
GO

------------------------------------------------------------
-- 7) Stored Procedure: add an order item (business rule)
------------------------------------------------------------

/*
sp_AddOrderItem:
- validates OrderId exists
- validates ProductId exists and product is active
- copies current Product.Price into UnitPrice (price snapshot)
*/
CREATE PROCEDURE dbo.sp_AddOrderItem
    @OrderId INT,
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Quantity < 1 OR @Quantity > 100
    BEGIN
        RAISERROR('Quantity must be between 1 and 100.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Orders WHERE OrderId = @OrderId)
    BEGIN
        RAISERROR('OrderId does not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE ProductId = @ProductId AND IsActive = 1)
    BEGIN
        RAISERROR('Product does not exist or is inactive.', 16, 1);
        RETURN;
    END

    DECLARE @UnitPrice DECIMAL(10,2);

    SELECT @UnitPrice = Price
    FROM dbo.Products
    WHERE ProductId = @ProductId;

    INSERT INTO dbo.OrderItems (OrderId, ProductId, Quantity, UnitPrice)
    VALUES (@OrderId, @ProductId, @Quantity, @UnitPrice);

    SELECT @@ROWCOUNT AS RowsInserted;
END
GO

-- Add items into the new order we created above (find the newest order for UserId = 1)
DECLARE @NewestOrderId INT =
(
    SELECT TOP (1) OrderId
    FROM dbo.Orders
    WHERE UserId = 1
    ORDER BY OrderId DESC
);

EXEC dbo.sp_AddOrderItem @OrderId = @NewestOrderId, @ProductId = 4, @Quantity = 2; -- USB-C
EXEC dbo.sp_AddOrderItem @OrderId = @NewestOrderId, @ProductId = 2, @Quantity = 1; -- Mug
GO

-- Verify via view
SELECT *
FROM dbo.vw_OrderSummary
WHERE OrderId = (
    SELECT TOP (1) OrderId
    FROM dbo.Orders
    WHERE UserId = 1
    ORDER BY OrderId DESC
);
GO

------------------------------------------------------------
-- 8) YOUR TURN — Practice (write solutions below)
------------------------------------------------------------

/*
A) VIEW tasks
1) Query dbo.vw_OrderSummary and sort by OrderTotal DESC.
2) Create dbo.vw_UserSpend (Paid only): UserId, FullName, TotalPaidSpend.
3) Create dbo.vw_ProductSales (Paid only): Sku, ProductName, UnitsSold, Revenue.

B) Stored procedure tasks (read)
4) Execute dbo.sp_GetUserOrders for 2 different users.
5) Add optional @Status parameter to dbo.sp_GetUserOrders (NULL = no filter).

C) Stored procedure tasks (write / business logic)
6) Execute dbo.sp_CreateOrder for an existing user and capture OrderId.
7) Add 2 items into that order using dbo.sp_AddOrderItem.
8) Try Quantity = 0 and explain what happens.
9) Create dbo.sp_CancelOrder @OrderId:
   - only cancel if status is NOT 'Shipped'
   - set Status = 'Cancelled'
10) Create dbo.sp_GetOrderTotal @OrderId that returns OrderId + OrderTotal.

D) Refactor / compare
11) Write a SELECT with joins that produces the same output as vw_OrderSummary.
12) Explain (as comments): why is the view version easier to maintain?

E) Extra
13) Create sp_GetUserLifetimeSpend @UserId (Paid only).
14) Create sp_AddUser (Email must be unique).
15) Create sp_SetProductActive @Sku, @IsActive.

*/

-- Solutions area:

-- 1)
-- SELECT ...

