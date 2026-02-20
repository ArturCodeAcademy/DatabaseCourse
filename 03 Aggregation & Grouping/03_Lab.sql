
/*
============================================================
03_Lab.sql — Lesson 3: Aggregation & Grouping
============================================================

How to use this lab:
1) Run the whole script once to create and populate the table.
2) Then scroll to the DEMO section and run queries one by one.
3) Finally, solve the 25 tasks at the bottom.

Tip: Many "ERROR DEMO" queries are intentionally commented out.
Uncomment them to see the error message, then re-comment and run the FIX.
*/

USE SqlCourse;
GO

------------------------------------------------------------
-- 1) SETUP: Create a rich dataset for analysis
------------------------------------------------------------
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL
    DROP TABLE dbo.Employees;
GO

CREATE TABLE dbo.Employees (
    EmployeeId INT IDENTITY(1,1) PRIMARY KEY,
    FirstName  NVARCHAR(50),
    LastName   NVARCHAR(50),
    Department NVARCHAR(50),
    City       NVARCHAR(50),
    Salary     INT,
    HireDate   DATE,
    PerformanceScore INT -- 1 (Low) to 5 (High)
);
GO

INSERT INTO dbo.Employees (FirstName, LastName, Department, City, Salary, HireDate, PerformanceScore)
VALUES
('Alice', 'Smith', 'IT', 'New York', 7500, '2020-01-15', 5),
('Bob', 'Jones', 'IT', 'New York', 7100, '2021-03-20', 4),
('Charlie', 'Davis', 'IT', 'Chicago', 6200, '2022-05-10', 3),
('David', 'Miller', 'HR', 'Chicago', 4100, '2019-11-12', 2),
('Eve', 'Wilson', 'HR', 'New York', 4300, '2020-08-25', 4),
('Frank', 'Moore', 'Sales', 'Miami', 4800, '2021-01-10', 5),
('Grace', 'Taylor', 'Sales', 'Miami', 5100, '2022-02-15', 3),
('Henry', 'Anderson', 'Sales', 'Miami', 4400, '2023-03-01', 2),
('Ivy', 'Thomas', 'IT', 'Miami', 7800, '2018-12-01', 5),
('Jack', 'White', 'HR', 'Miami', 3400, '2020-05-20', 1),
('Kelly', 'Harris', 'Finance', 'New York', 8500, '2017-06-14', 5),
('Liam', 'Martin', 'Finance', 'New York', 7900, '2019-09-10', 4),
('Mia', 'Thompson', 'Finance', 'Chicago', 7400, '2021-11-30', 3),
('Noah', 'Garcia', 'Sales', 'Chicago', 4200, '2022-01-05', 4),
('Olivia', 'Martinez', 'IT', 'Seattle', 6900, '2020-04-12', 5),
('Peter', 'Robinson', 'IT', 'Seattle', 6700, '2021-07-22', 2),
('Quinn', 'Clark', 'HR', 'Seattle', 4000, '2023-01-15', 3),
('Ryan', 'Rodriguez', 'Sales', 'Seattle', 4800, '2022-08-10', 4),
('Sophia', 'Lewis', 'Finance', 'Seattle', 8100, '2018-03-05', 5),
('Thomas', 'Lee', 'Sales', 'New York', 5200, '2019-12-20', 3),
('Ursula', 'Walker', 'IT', 'Chicago', 6100, '2020-10-11', 4),
('Victor', 'Hall', 'HR', 'Miami', 3600, '2021-04-05', 2),
('Wendy', 'Allen', 'Finance', 'Miami', 7400, '2022-06-18', 4),
('Xavier', 'Young', 'Sales', 'Austin', 5300, '2023-05-12', 5),
('Yara', 'King', 'IT', 'Austin', 6400, '2021-09-30', 4),
('Zane', 'Wright', 'HR', 'Austin', 3600, '2022-02-14', 2),
('Adam', 'Scott', 'Finance', 'Austin', 7900, '2019-01-20', 5),
('Bella', 'Green', 'Sales', 'Austin', 5000, '2020-11-05', 3);
GO

------------------------------------------------------------
-- 2) QUICK LOOK: Inspect the data
------------------------------------------------------------
SELECT TOP (10) *
FROM dbo.Employees
ORDER BY EmployeeId;
GO

------------------------------------------------------------
-- 3) DEMO: Aggregation Basics (global totals)
------------------------------------------------------------

-- A) COUNT: How many rows?
SELECT COUNT(*) AS TotalEmployees
FROM dbo.Employees;
GO

-- B) SUM / AVG / MIN / MAX on one column
SELECT
    SUM(Salary) AS TotalPayroll,
    AVG(Salary) AS AvgSalary,
    MIN(Salary) AS MinSalary,
    MAX(Salary) AS MaxSalary
FROM dbo.Employees;
GO

-- C) COUNT(*) vs COUNT(column)
-- Our columns are NOT NULL in this dataset, but we can demonstrate the idea with an expression:
-- COUNT counts non-NULL values. Here we return NULL for people whose PerformanceScore is not 5.
SELECT
    COUNT(*) AS AllRows,
    COUNT(CASE WHEN PerformanceScore = 5 THEN 1 END) AS OnlyScore5_Count
FROM dbo.Employees;
GO

-- D) AVG ignores NULLs: use NULLIF to "remove" some rows from the math.
-- Example: average salary excluding employees with score 1 (they become NULL for AVG)
SELECT
    AVG(Salary) AS AvgSalary_All,
    AVG(CASE WHEN PerformanceScore = 1 THEN NULL ELSE Salary END) AS AvgSalary_ExcludingScore1
FROM dbo.Employees;
GO

------------------------------------------------------------
-- 4) DEMO: GROUP BY (single grouping)
------------------------------------------------------------

-- A) Average salary per City
SELECT City, AVG(Salary) AS AvgSalary
FROM dbo.Employees
GROUP BY City
ORDER BY AvgSalary DESC;
GO

-- B) Employees per Department
SELECT Department, COUNT(*) AS EmployeesCount
FROM dbo.Employees
GROUP BY Department
ORDER BY EmployeesCount DESC;
GO

-- C) Total payroll per Department
SELECT Department, SUM(Salary) AS TotalPayroll
FROM dbo.Employees
GROUP BY Department
ORDER BY TotalPayroll DESC;
GO

------------------------------------------------------------
-- 5) DEMO: GROUP BY (multiple grouping)
------------------------------------------------------------

-- A) Count employees in each City + Department combination
SELECT City, Department, COUNT(*) AS EmployeesCount
FROM dbo.Employees
GROUP BY City, Department
ORDER BY City, Department;
GO

-- B) Average salary for each Department in each City
SELECT City, Department, AVG(Salary) AS AvgSalary
FROM dbo.Employees
GROUP BY City, Department
ORDER BY City, Department;
GO

------------------------------------------------------------
-- 6) DEMO: WHERE vs HAVING
------------------------------------------------------------

-- WHERE filters ROWS before grouping.
-- Example: Only include employees hired in 2021 or later, then group by City.
SELECT City, COUNT(*) AS Hired_2021_OrLater
FROM dbo.Employees
WHERE HireDate >= '2021-01-01'
GROUP BY City
ORDER BY Hired_2021_OrLater DESC;
GO

-- HAVING filters GROUPS after grouping.
-- Example: show only cities with average salary above 6000.
SELECT City, AVG(Salary) AS AvgSalary
FROM dbo.Employees
GROUP BY City
HAVING AVG(Salary) > 6000
ORDER BY AvgSalary DESC;
GO

-- Combo: WHERE + GROUP BY + HAVING
-- Example: Only New York and Chicago rows, grouped by Department, keep only departments with avg salary > 5000.
SELECT Department, AVG(Salary) AS AvgSalary
FROM dbo.Employees
WHERE City IN ('New York', 'Chicago')
GROUP BY Department
HAVING AVG(Salary) > 5000
ORDER BY AvgSalary DESC;
GO

------------------------------------------------------------
-- 7) COMMON ERRORS & ANTIFAIL EXAMPLES (Uncomment to see errors)
------------------------------------------------------------

-- ERROR DEMO 1: Non-aggregated column in SELECT
-- SQL Server error: "Column 'dbo.Employees.City' is invalid in the select list because it is not contained
-- in either an aggregate function or the GROUP BY clause."
-- SELECT City, AVG(Salary) AS AvgSalary
-- FROM dbo.Employees;

-- FIX:
SELECT City, AVG(Salary) AS AvgSalary
FROM dbo.Employees
GROUP BY City;
GO

-- ERROR DEMO 2: Aggregate functions in WHERE (not allowed)
-- SELECT Department, COUNT(*) AS Cnt
-- FROM dbo.Employees
-- WHERE COUNT(*) > 5
-- GROUP BY Department;

-- FIX: use HAVING for aggregated filters
SELECT Department, COUNT(*) AS Cnt
FROM dbo.Employees
GROUP BY Department
HAVING COUNT(*) > 5
ORDER BY Cnt DESC;
GO

-- ERROR DEMO 3: HAVING without GROUP BY (usually not what you mean)
-- Some DBs allow it, but it's confusing for beginners.
-- Use a WHERE for row filtering or add GROUP BY for group filtering.

-- ERROR / ANTIPATTERN 4: Grouping by a Primary Key (usually useless)
-- Every group contains only one row, so aggregates are pointless.
SELECT EmployeeId, AVG(Salary) AS AvgSalary
FROM dbo.Employees
GROUP BY EmployeeId
ORDER BY EmployeeId;
GO

-- Better: group by something meaningful (Department)
SELECT Department, AVG(Salary) AS AvgSalary
FROM dbo.Employees
GROUP BY Department
ORDER BY AvgSalary DESC;
GO

-- ANTIPATTERN 5: Filtering after grouping when you meant to filter rows first
-- Example question: "Average salary per city for employees hired after 2021-01-01"
-- Correct: WHERE first, then GROUP BY.
SELECT City, AVG(Salary) AS AvgSalary_HiredAfter2021
FROM dbo.Employees
WHERE HireDate >= '2021-01-01'
GROUP BY City;
GO

------------------------------------------------------------
-- 8) OPTIONAL: Extra Patterns (handy tricks)
------------------------------------------------------------

-- A) Distinct counts: how many unique cities?
SELECT COUNT(DISTINCT City) AS UniqueCities
FROM dbo.Employees;
GO

-- B) Conditional aggregation: count how many "high performers" (score >= 4) per department
SELECT
    Department,
    COUNT(*) AS EmployeesTotal,
    SUM(CASE WHEN PerformanceScore >= 4 THEN 1 ELSE 0 END) AS HighPerformers
FROM dbo.Employees
GROUP BY Department
ORDER BY HighPerformers DESC;
GO

-- C) Range per department (MAX - MIN)
SELECT
    Department,
    MAX(Salary) AS MaxSalary,
    MIN(Salary) AS MinSalary,
    MAX(Salary) - MIN(Salary) AS SalaryGap
FROM dbo.Employees
GROUP BY Department
ORDER BY SalaryGap DESC;
GO

------------------------------------------------------------
-- 9) YOUR TURN (25 TASKS)
------------------------------------------------------------

-- [SECTION A: BASICS]
-- 1. Total employees?
-- 2. Total monthly payroll (Sum of Salary)?
-- 3. Average Performance Score?
-- 4. Most recent HireDate?
-- 5. Number of unique Cities?

-- [SECTION B: SINGLE GROUPING]
-- 6. Employees per Department?
-- 7. Average Salary per City?
-- 8. Total Salary per Department?
-- 9. Highest Performance Score in each City?
-- 10. Avg Salary per Dept, sorted High to Low.

-- [SECTION C: MULTI-LEVEL GROUPING]
-- 11. Count of employees for each City/Dept combination.
-- 12. Average Salary for each Dept in each City.
-- 13. Earliest HireDate for each City/Dept.

-- [SECTION D: HAVING]
-- 14. Depts with more than 5 employees.
-- 15. Cities with Average Salary > 6000.
-- 16. Depts where total payroll is > 25,000.
-- 17. Cities where avg performance < 3.5.

-- [SECTION E: THE COMBO]
-- 18. New York & Chicago only: Avg Salary per Dept where Avg > 5000.
-- 19. Hired after '2021-01-01': City total Salary if total > 10,000.
-- 20. Count 'S' last names per Dept, only if count > 1.
-- 21. Max - Min Salary (Gap) per Department.
-- 22. Report: City, Dept, Count, Avg Salary (Sorted by City).
-- 23. Avg salary per Dept excluding performance score 1.
-- 24. Depts present in more than 3 different Cities.
-- 25. Bonus budget (15% of Salary) per Department.

/*
END OF LAB
*/
