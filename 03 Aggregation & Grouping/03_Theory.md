# Lesson 3: Aggregation & Grouping --- From Chaos to Insights 📊

## 🎯 Goal

Learn how to transform raw row-level data into meaningful summary
reports --- just like creating a Pivot Table in Excel.

------------------------------------------------------------------------

# 1️⃣ What is Aggregation?

Aggregation takes a collection of rows and compresses them into a single
summary value.

## The Big Five Functions

  Function        Description
  --------------- ------------------------
  COUNT(\*)       Counts all rows
  COUNT(column)   Counts non-NULL values
  SUM()           Adds numeric values
  AVG()           Calculates average
  MIN()           Lowest value
  MAX()           Highest value

Example:

``` sql
SELECT COUNT(*) AS TotalEmployees
FROM dbo.Employees;
```

------------------------------------------------------------------------

# 2️⃣ GROUP BY --- The Bucket Maker

GROUP BY divides a table into groups based on shared values.

Example:

``` sql
SELECT Department, AVG(Salary) AS AvgSalary
FROM dbo.Employees
GROUP BY Department;
```

⚠ Golden Rule: Every column in SELECT must either: - Be inside an
aggregate function - Or be listed in GROUP BY

------------------------------------------------------------------------

# 3️⃣ Grouping by Multiple Columns

``` sql
SELECT City, Department, COUNT(*) AS EmployeesCount
FROM dbo.Employees
GROUP BY City, Department;
```

------------------------------------------------------------------------

# 4️⃣ WHERE vs HAVING

Execution order:

FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

## WHERE

-   Filters rows BEFORE grouping
-   Cannot use aggregate functions

## HAVING

-   Filters groups AFTER grouping
-   Can use aggregate functions

Wrong:

``` sql
SELECT Department, COUNT(*)
FROM dbo.Employees
WHERE COUNT(*) > 5
GROUP BY Department;
```

Correct:

``` sql
SELECT Department, COUNT(*)
FROM dbo.Employees
GROUP BY Department
HAVING COUNT(*) > 5;
```

------------------------------------------------------------------------

# 🧠 Summary

Aggregation = turn raw data into business insight. GROUP BY = create
buckets. HAVING = filter buckets.
