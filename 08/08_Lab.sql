/*
============================================================
08_Lab.sql — Lesson 8: Functions (Strings, Dates, CASE WHEN)
============================================================

Dataset: Customer Support Tickets (NOT related to homework datasets).
Focus functions:
- Strings: CONCAT, SUBSTRING, LEN, REPLACE
- Dates: DATEDIFF, DATEADD
- Logic: CASE WHEN

Run section by section.

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
-- 1) Recreate tables (safe to rerun)
------------------------------------------------------------
IF OBJECT_ID('dbo.Tickets', 'U') IS NOT NULL DROP TABLE dbo.Tickets;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
GO

CREATE TABLE dbo.Customers
(
    CustomerId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Customers PRIMARY KEY,
    CustomerCode NVARCHAR(20) NOT NULL CONSTRAINT UQ_Customers_Code UNIQUE,
    FirstName    NVARCHAR(50) NOT NULL,
    LastName     NVARCHAR(50) NOT NULL,
    Email        NVARCHAR(100) NOT NULL CONSTRAINT UQ_Customers_Email UNIQUE,
    City         NVARCHAR(50) NOT NULL
);
GO

CREATE TABLE dbo.Tickets
(
    TicketId    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Tickets PRIMARY KEY,
    TicketCode  NVARCHAR(20) NOT NULL CONSTRAINT UQ_Tickets_Code UNIQUE,  -- e.g. TCK-2025-0001
    CustomerId  INT NOT NULL,
    Title       NVARCHAR(120) NOT NULL,
    Status      NVARCHAR(20) NOT NULL CONSTRAINT CK_Tickets_Status CHECK (Status IN ('Open','In Progress','Closed')),
    Priority    NVARCHAR(10) NOT NULL CONSTRAINT CK_Tickets_Priority CHECK (Priority IN ('Low','Medium','High')),
    CreatedAt   DATETIME2(0) NOT NULL,
    ClosedAt    DATETIME2(0) NULL,

    CONSTRAINT FK_Tickets_Customers FOREIGN KEY (CustomerId)
        REFERENCES dbo.Customers(CustomerId)
);
GO

------------------------------------------------------------
-- 2) Insert sample data
------------------------------------------------------------
INSERT INTO dbo.Customers (CustomerCode, FirstName, LastName, Email, City)
VALUES
(N'CUS-1001', N'Alyssa', N'Nguyen', N'alyssa.nguyen@example.com', N'Boston'),
(N'CUS-1002', N'Brian',  N'Holt',   N'brian.holt@example.com',   N'Chicago'),
(N'CUS-1003', N'Carla',  N'James',  N'carla.james@example.com',  N'Austin'),
(N'CUS-1004', N'Devon',  N'Wright', N'devon.wright@example.com', N'Denver'),
(N'CUS-1005', N'Erin',   N'Lopez',  N'erin.lopez@example.com',   N'Seattle'),
(N'CUS-1006', N'Frank',  N'Kim',    N'frank.kim@example.com',    N'New York');
GO

-- Tickets: mix of dates (some older, some recent), some closed, some open.
INSERT INTO dbo.Tickets (TicketCode, CustomerId, Title, Status, Priority, CreatedAt, ClosedAt)
VALUES
(N'TCK-2025-0001', 1, N'Cannot reset password',              N'Closed',      N'High',   '2026-01-05 09:10', '2025-01-05 14:20'),
(N'TCK-2025-0002', 2, N'Billing charge looks incorrect',     N'In Progress', N'High',   '2026-02-11 10:05', NULL),
(N'TCK-2025-0003', 3, N'App crashes on startup',             N'Open',        N'High',   '2026-03-01 08:30', NULL),
(N'TCK-2025-0004', 4, N'Update email address request',       N'Closed',      N'Low',    '2026-03-10 16:00', '2025-03-12 09:00'),
(N'TCK-2025-0005', 5, N'Cannot download invoice PDF',        N'Open',        N'Medium', '2026-03-21 11:45', NULL),
(N'TCK-2025-0006', 6, N'Feature request: dark mode',         N'In Progress', N'Low',    '2026-04-02 13:15', NULL),
(N'TCK-2025-0007', 1, N'Login works but MFA code not sent',  N'Open',        N'High',   '2026-04-12 07:55', NULL),
(N'TCK-2025-0008', 2, N'Address update needed for delivery', N'Closed',      N'Medium', '2026-04-20 09:40', '2025-04-20 18:10'),
(N'TCK-2025-0009', 3, N'Coupon code not applying',           N'Open',        N'Medium', '2026-05-05 12:00', NULL),
(N'TCK-2025-0010', 4, N'Unable to cancel subscription',      N'In Progress', N'High',   '2026-05-12 15:20', NULL),
(N'TCK-2025-0011', 5, N'Typo on the dashboard label',        N'Closed',      N'Low',    '2026-05-25 10:10', '2025-05-25 11:05'),
(N'TCK-2025-0012', 6, N'Account locked after 3 attempts',    N'Open',        N'High',   '2026-06-01 06:40', NULL);
GO

------------------------------------------------------------
-- 3) Quick preview
------------------------------------------------------------
SELECT TOP (20)
    t.TicketId, t.TicketCode, t.Title, t.Status, t.Priority, t.CreatedAt, t.ClosedAt,
    c.CustomerCode, c.FirstName, c.LastName, c.Email, c.City
FROM dbo.Tickets AS t
JOIN dbo.Customers AS c ON c.CustomerId = t.CustomerId
ORDER BY t.TicketId;
GO

------------------------------------------------------------
-- 4) String functions: CONCAT, LEN, SUBSTRING, REPLACE
------------------------------------------------------------

-- 4.1 CONCAT: build a display field "FullName <Email>"
SELECT
    t.TicketCode,
    CONCAT(c.FirstName, N' ', c.LastName, N' <', c.Email, N'>') AS CustomerDisplay
FROM dbo.Tickets AS t
JOIN dbo.Customers AS c ON c.CustomerId = t.CustomerId
ORDER BY t.TicketId;
GO

-- 4.2 LEN: title length
SELECT
    TicketCode,
    Title,
    LEN(Title) AS TitleLength
FROM dbo.Tickets
ORDER BY TicketId;
GO

-- 4.3 SUBSTRING: extract year from TicketCode like 'TCK-2025-0012'
SELECT
    TicketCode,
    SUBSTRING(TicketCode, 5, 4) AS TicketYear
FROM dbo.Tickets
ORDER BY TicketId;
GO

-- 4.4 SUBSTRING: extract the numeric part from TicketCode
SELECT
    TicketCode,
    SUBSTRING(TicketCode, 10, 4) AS TicketNumber
FROM dbo.Tickets
ORDER BY TicketId;
GO

-- 4.5 REPLACE: remove dashes from TicketCode
SELECT
    TicketCode,
    REPLACE(TicketCode, N'-', N'') AS CleanCode
FROM dbo.Tickets
ORDER BY TicketId;
GO

------------------------------------------------------------
-- 5) Date functions: DATEDIFF, DATEADD
------------------------------------------------------------

-- 5.1 How many days ago a ticket was created?
SELECT
    TicketCode,
    CreatedAt,
    DATEDIFF(DAY, CreatedAt, SYSDATETIME()) AS DaysSinceCreated
FROM dbo.Tickets
ORDER BY DaysSinceCreated DESC;
GO

-- 5.2 Due date: 7 days after CreatedAt
SELECT
    TicketCode,
    CreatedAt,
    DATEADD(DAY, 7, CreatedAt) AS DueDate
FROM dbo.Tickets
ORDER BY CreatedAt;
GO

-- 5.3 Filter: tickets created in the last 30 days (relative to today)
SELECT
    TicketCode,
    Title,
    CreatedAt
FROM dbo.Tickets
WHERE DATEDIFF(DAY, CreatedAt, SYSDATETIME()) <= 30
ORDER BY CreatedAt DESC;
GO

------------------------------------------------------------
-- 6) CASE WHEN: build labels/buckets
------------------------------------------------------------

-- 6.1 TicketAgeBucket based on days since created
SELECT
    TicketCode,
    CreatedAt,
    DATEDIFF(DAY, CreatedAt, SYSDATETIME()) AS DaysOpen,
    CASE
        WHEN DATEDIFF(DAY, CreatedAt, SYSDATETIME()) BETWEEN 0 AND 2 THEN '0-2 days'
        WHEN DATEDIFF(DAY, CreatedAt, SYSDATETIME()) BETWEEN 3 AND 7 THEN '3-7 days'
        ELSE '8+ days'
    END AS TicketAgeBucket
FROM dbo.Tickets
ORDER BY DaysOpen DESC;
GO

-- 6.2 SLA status: overdue if open and past due date
SELECT
    TicketCode,
    Status,
    CreatedAt,
    DATEADD(DAY, 7, CreatedAt) AS DueDate,
    CASE
        WHEN ClosedAt IS NULL AND SYSDATETIME() > DATEADD(DAY, 7, CreatedAt) THEN 'Overdue'
        ELSE 'On Time'
    END AS SlaStatus
FROM dbo.Tickets
ORDER BY TicketId;
GO

------------------------------------------------------------
-- 7) Combine everything into a report (functions + CASE)
------------------------------------------------------------

SELECT
    t.TicketCode,
    REPLACE(t.TicketCode, N'-', N'') AS CleanCode,
    t.Title,
    LEN(t.Title) AS TitleLength,
    DATEDIFF(DAY, t.CreatedAt, SYSDATETIME()) AS DaysOpen,
    DATEADD(DAY, 7, t.CreatedAt) AS DueDate,
    CASE
        WHEN DATEDIFF(DAY, t.CreatedAt, SYSDATETIME()) BETWEEN 0 AND 2 THEN '0-2 days'
        WHEN DATEDIFF(DAY, t.CreatedAt, SYSDATETIME()) BETWEEN 3 AND 7 THEN '3-7 days'
        ELSE '8+ days'
    END AS TicketAgeBucket,
    CASE
        WHEN t.ClosedAt IS NULL AND SYSDATETIME() > DATEADD(DAY, 7, t.CreatedAt) THEN 'Overdue'
        ELSE 'On Time'
    END AS SlaStatus,
    CONCAT(c.FirstName, N' ', c.LastName) AS CustomerName,
    c.City
FROM dbo.Tickets AS t
JOIN dbo.Customers AS c ON c.CustomerId = t.CustomerId
ORDER BY
    CASE WHEN t.ClosedAt IS NULL AND SYSDATETIME() > DATEADD(DAY, 7, t.CreatedAt) THEN 0 ELSE 1 END,
    DATEDIFF(DAY, t.CreatedAt, SYSDATETIME()) DESC;
GO

------------------------------------------------------------
-- 8) YOUR TURN — Practice (write solutions below)
------------------------------------------------------------

/*
A) Strings
1) Return TicketCode plus CleanCode (no dashes).
2) Extract the year from TicketCode.
3) Show Title and TitleLength.
4) Build: CustomerFullName <Email> using CONCAT.
5) ShortTitle: first 12 characters of Title.

B) Dates
6) DaysSinceCreated for each ticket.
7) DueDate = CreatedAt + 7 days.
8) Tickets created in last 30 days (filter).

C) CASE WHEN
9) TicketAgeBucket: 0-2, 3-7, 8+ days.
10) SlaStatus: Overdue if open and past due, else On Time.

D) Combine
11) Build a full report like section 7 (your own formatting is fine).
12) Sort Overdue first, then DaysOpen DESC.

*/

-- Solutions area:

-- 1)
-- SELECT ...

