/*
============================================================
02_Lab.sql — Lesson 2: The Art of Filtering
============================================================
*/

USE SqlCourse;
GO

------------------------------------------------------------
-- 1) Re-create/Update our table with some NULL values
------------------------------------------------------------
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL
    DROP TABLE dbo.Employees;
GO

CREATE TABLE dbo.Employees
(
    EmployeeId INT IDENTITY(1,1) PRIMARY KEY,
    FirstName  NVARCHAR(50) NOT NULL,
    LastName   NVARCHAR(50) NOT NULL,
    Department NVARCHAR(50) NULL, -- Allow NULL for practice
    City       NVARCHAR(50) NOT NULL,
    Salary     INT NULL           -- Allow NULL for practice
);
GO

------------------------------------------------------------
-- 2) Insert fresh data
------------------------------------------------------------
INSERT INTO dbo.Employees (FirstName, LastName, Department, City, Salary)
VALUES
(N'John',    N'Parker',  N'IT',      N'New York', 4500),
(N'Emily',   N'Johnson', N'HR',      N'Chicago',  3200),
(N'Michael', N'Turner',  N'IT',      N'Austin',   5200),
(N'Sarah',   N'Collins', N'Sales',   N'Seattle',  NULL), -- Salary unknown
(N'Daniel',  N'Reed',    N'Sales',   N'New York', 3900),
(N'Olivia',  N'Bennett', NULL,       N'Boston',   6000), -- Dept unknown
(N'Ethan',   N'Murphy',  N'IT',      N'Denver',   5200),
(N'Madison', N'Hughes',  N'HR',      N'Miami',    3300),
(N'Ava',     N'Brooks',  N'IT',      N'San Francisco', 4500),
(N'William', N'Hayes',   N'IT',      N'Austin',   4800);
GO

------------------------------------------------------------
-- 3) Examples for Lesson 2
------------------------------------------------------------

-- Example: WHERE + Comparison
SELECT * FROM dbo.Employees WHERE Salary >= 5000;

-- Example: LIKE
SELECT * FROM dbo.Employees WHERE FirstName LIKE 'M%';

-- Example: The NULL trap (This returns 0 rows!)
SELECT * FROM dbo.Employees WHERE Salary = NULL;

-- Example: Correct NULL handling
SELECT * FROM dbo.Employees WHERE Salary IS NULL;

-- Example: Sorting
SELECT * FROM dbo.Employees ORDER BY Department ASC, Salary DESC;

------------------------------------------------------------
-- 4) YOUR TURN (Tasks)
------------------------------------------------------------

/*
A) Basic Filters
1) Return employees in 'IT'.
2) Return employees earning > 5000.

B) Logic
3) Employees in 'IT' AND earning > 5000.
4) Employees in 'New York' OR 'Austin'.

C) Patterns
5) First names starting with 'S'.
6) Last names ending with 's'.

D) NULLs
7) Employees with missing Department.
8) Employees with known (NOT NULL) Salary.

E) Sorting
9) All employees by Salary (High to Low).
10) All by City (A-Z) then Salary (High to Low).
*/

-- Solutions area:

-- 1)