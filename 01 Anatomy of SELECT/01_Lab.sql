
/*
============================================================
01_Lab.sql — Lesson 1: Anatomy of SELECT (SQL Server)
============================================================

This script:
1) Creates a database (SqlCourse) if missing
2) Creates a single table: dbo.Employees (with a Primary Key)
3) Inserts sample data (includes duplicates for DISTINCT)
4) Shows examples:
   - SELECT columns vs SELECT *
   - Aliases (AS)
   - DISTINCT
   - TOP (N)

How to use:
- Run section by section (recommended).
- Safe to re-run: the table is dropped and recreated.

*/

/*
------------------------------------------------------------
-- 0) Create and use a sandbox database
------------------------------------------------------------
*/
IF DB_ID('SqlCourse') IS NULL
BEGIN
    CREATE DATABASE SqlCourse;
END
GO
USE SqlCourse;
GO

------------------------------------------------------------
-- 1) Create the first table (Employees)
--    Primary Key: EmployeeId
------------------------------------------------------------
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL
    DROP TABLE dbo.Employees;
GO

CREATE TABLE dbo.Employees
(
    -- Primary Key (PK): unique row identifier
    EmployeeId INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Employees PRIMARY KEY,

    FirstName  NVARCHAR(50) NOT NULL,
    LastName   NVARCHAR(50) NOT NULL,
    Department NVARCHAR(50) NOT NULL,
    City       NVARCHAR(50) NOT NULL,
    Salary     INT NOT NULL,

    -- Just a useful column for realism
    CreatedAt  DATETIME2(0) NOT NULL
        CONSTRAINT DF_Employees_CreatedAt DEFAULT (SYSDATETIME())
);
GO

------------------------------------------------------------
-- 2) Insert sample data
--    (We intentionally repeat City and Department values)
------------------------------------------------------------
INSERT INTO dbo.Employees (FirstName, LastName, Department, City, Salary, CreatedAt)
VALUES
(N'John',        N'Parker',   N'IT',      N'New York',      4500, '2025-01-05'),
(N'Emily',       N'Johnson',  N'HR',      N'Chicago',       3200, '2025-01-06'),
(N'Michael',     N'Turner',   N'IT',      N'Austin',        5200, '2025-01-07'),
(N'Sarah',       N'Collins',  N'Sales',   N'Seattle',       4100, '2025-01-08'),
(N'Daniel',      N'Reed',     N'Sales',   N'New York',      3900, '2025-01-08'),
(N'Olivia',      N'Bennett',  N'Finance', N'Boston',        6000, '2025-01-09'),
(N'Ethan',       N'Murphy',   N'IT',      N'Denver',        5200, '2025-01-10'),
(N'Madison',     N'Hughes',   N'HR',      N'Miami',         3300, '2025-01-10'),
(N'Christopher', N'Ward',     N'Finance', N'Chicago',       6100, '2025-01-11'),
(N'Ava',         N'Brooks',   N'IT',      N'San Francisco', 4500, '2025-01-12'),
(N'Jessica',     N'Foster',   N'Sales',   N'Los Angeles',   4200, '2025-01-12'),
(N'William',     N'Hayes',    N'IT',      N'Austin',        4800, '2025-01-13');
GO

------------------------------------------------------------
-- 3) SELECT basics
------------------------------------------------------------

-- 3.1 SELECT * (OK for quick exploration; avoid as default in production)
SELECT *
FROM dbo.Employees;
GO

-- 3.2 Select only the columns you need (good habit)
SELECT EmployeeId, FirstName, LastName
FROM dbo.Employees;
GO

-- 3.3 A typical “UI list” style query (no *)
SELECT EmployeeId, FirstName, LastName, Department, City
FROM dbo.Employees;
GO

------------------------------------------------------------
-- 4) Aliases (AS)
------------------------------------------------------------

-- 4.1 Column aliases: cleaner output names
SELECT
    EmployeeId AS [ID],
    FirstName  AS [First Name],
    LastName   AS [Last Name],
    Salary     AS MonthlySalary
FROM dbo.Employees;
GO

-- 4.2 Table alias: shorter references (useful immediately and later)
SELECT
    e.EmployeeId,
    e.FirstName,
    e.LastName,
    e.Department,
    e.City
FROM dbo.Employees AS e;
GO

------------------------------------------------------------
-- 5) DISTINCT
------------------------------------------------------------

-- 5.1 Unique departments
SELECT DISTINCT Department
FROM dbo.Employees;
GO

-- 5.2 Unique cities
SELECT DISTINCT City
FROM dbo.Employees;
GO

-- 5.3 Unique combinations (Department + City)
SELECT DISTINCT Department, City
FROM dbo.Employees;
GO

------------------------------------------------------------
-- 6) TOP (N)
------------------------------------------------------------

-- 6.1 TOP for previewing data
-- IMPORTANT: Without sorting (covered later), TOP does not guarantee which rows you get.
SELECT TOP (5)
    EmployeeId, FirstName, LastName, Department
FROM dbo.Employees;
GO

-- 6.2 TOP with different columns
SELECT TOP (3)
    EmployeeId, FirstName, City, Salary
FROM dbo.Employees;
GO

------------------------------------------------------------
-- 7) YOUR TURN (Tasks)
-- Write your solutions below (no need to change the data above).
------------------------------------------------------------

/*
A) Warm-up
1) Return all columns from dbo.Employees (one time only).
2) Return only: EmployeeId, FirstName, LastName.
3) Return only: FirstName, Department, City.

B) No SELECT * habit
4) Write a “UI employee list” query:
   EmployeeId, FirstName, LastName, Department, City
5) Write (as comments) why SELECT * is risky in production.

C) Aliases
6) FirstName as Name, LastName as Surname, Salary as MonthlySalary.
7) EmployeeId as ID, CreatedAt as Created.
8) Use a table alias e and reference columns as e.ColumnName.

D) DISTINCT
9) Unique Department
10) Unique City
11) Unique pairs: Department + City
12) Compare row counts:
    - SELECT City FROM dbo.Employees;
    - SELECT DISTINCT City FROM dbo.Employees;
    Write what you observe (as comments).

E) TOP
13) TOP (3) employees (no *)
14) TOP (5) with EmployeeId, FirstName, City
15) Explain (as comments): Why TOP (5) is not “highest salaries”?

F) Mini challenges
16) Report-style output with aliases: ID, Name, Surname, Dept, City
17) Unique cities with output column name AvailableCities
18) Make the query clean and readable: consistent aliases, no *

*/

-- Solutions area:

-- 1)
-- SELECT ...

