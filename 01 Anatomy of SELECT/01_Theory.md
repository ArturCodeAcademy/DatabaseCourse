# Lesson 1 — Anatomy of SELECT (DQL)

## 🎯 Goal
By the end of this lesson, you can:
- explain what a **Database** is and what a **DBMS** (Database Management System) does,
- explain what a **relational database** is (in simple terms),
- explain what a **table** is (rows/columns) and why we store data in tables,
- explain a **Primary Key** in plain language,
- write basic `SELECT` queries and read them confidently,
- avoid `SELECT *` as a default habit,
- use **aliases (AS)** for readability,
- use **DISTINCT** to remove duplicates,
- use **TOP (N)** to preview data.

---

## 0) Foundations: Database vs DBMS

### What is a Database (DB)?
A **database** is an organized collection of data stored so we can:
- store it safely,
- find it quickly,
- keep it consistent,
- share it between many users/apps.

A database is not “a file with data” in the casual sense. It’s a managed system of structures (tables) plus rules, indexes, logs, and metadata.

### What is a DBMS?
A **DBMS** (Database Management System) is the software that manages databases.

**Microsoft SQL Server** is a DBMS. It provides:
- storage engine (writes/reads data on disk),
- query engine (executes SQL),
- security (logins/permissions),
- concurrency (many users at the same time),
- reliability features (transactions, logging, recovery),
- tooling (backup/restore, monitoring, etc.).

You write SQL → the DBMS executes it → it returns a result.

---

## 1) What is a relational database?
A **relational database** stores data in **tables** and supports **relationships** between tables using keys (IDs).

Key ideas:
- data is split into tables by meaning (employees, orders, products),
- each row is a record,
- each column is an attribute,
- rows are uniquely identifiable (usually by a primary key).

In Lesson 1 we use only one table, but we build the correct relational mindset:
- structured data,
- clear meaning per table,
- a reliable unique identifier (Primary Key).

---

## 2) What is a table?

A **table** is a structured collection of data organized into:

- **Columns** (fields): each column has a name and a data type  
  Example: `FirstName` is text, `Salary` is a number.
- **Rows** (records): each row is one “thing”  
  Example: one employee, one product, one order.

Think of it like a spreadsheet, but stricter:
- columns have types and rules,
- data consistency is enforced by the DBMS,
- the DBMS can optimize storage and querying.

### Example table: `dbo.Employees`
- `EmployeeId` — unique identifier of a person (ID)
- `FirstName`, `LastName` — text columns
- `Department` — text
- `City` — text
- `Salary` — numeric
- `CreatedAt` — date/time when the record was created

---

## 3) Primary Key (PK) — simple explanation

A **Primary Key** is a column (or set of columns) that:
- uniquely identifies each row,
- cannot be `NULL`,
- cannot repeat.

### Why do we need it?
Real-world values repeat:
- names repeat (`John` can exist many times),
- cities repeat,
- salaries repeat.

So we need a guaranteed way to say:
> “This exact row is this exact employee.”

That is the Primary Key.

### Common pattern in SQL Server: `IDENTITY`
Often the primary key is an auto-incrementing integer:

```sql
EmployeeId INT IDENTITY(1,1) PRIMARY KEY
```

Meaning:
- first inserted row gets `1`,
- next gets `2`,
- then `3`, etc.

---

## 4) What is DQL?
**DQL (Data Query Language)** is the part of SQL used to **read** data.

The most important command is:

- `SELECT`

This lesson is only about querying (reading), not modifying data.

---

## 5) The basic shape of a SELECT query

Minimal useful form:

```sql
SELECT <columns>
FROM <table>;
```

Example:

```sql
SELECT FirstName, LastName
FROM dbo.Employees;
```

Read it like a sentence:
> “Select first name and last name from Employees.”

### Result set (important concept)
A `SELECT` returns a **result set** (a temporary table-like output):
- it does not change the table,
- it just returns data.

---

## 6) Syntax order vs logical execution order

### Syntax order (how we write it)
In this lesson we write:

```sql
SELECT ...
FROM ...
```

Optionally with:

```sql
SELECT DISTINCT ...
FROM ...
```

or:

```sql
SELECT TOP (N) ...
FROM ...
```

### Logical execution order (how SQL Server thinks)
Even though we write `SELECT` first, SQL Server conceptually processes like this:

1) **FROM** — locate the source table  
2) **SELECT** — build the output columns (projection)  
3) **DISTINCT** — remove duplicate output rows (if requested)  
4) **TOP (N)** — return only the first N output rows (if requested)

Why this matters:
- it trains you to think: **FROM gives rows, SELECT shapes columns**,
- it explains why `DISTINCT` affects the output, not the underlying table.

---

## 7) `SELECT *` — why it’s bad in production

`SELECT *` means:
> “Return all columns from the table.”

### Why it’s risky
1) **You fetch data you don’t need**  
   Most screens/reports need only a few columns.

2) **More data = slower**  
   More network traffic + more memory + more processing.

3) **Schema changes can break things**  
   Add a column → `SELECT *` returns a different shape than before.

4) **Security / privacy risk**  
   If later a table gets sensitive columns, `SELECT *` may expose them.

✅ Rule:
- use `SELECT *` only for quick exploration,
- otherwise: **list columns explicitly**.

---

## 8) Aliases (AS)

Aliases rename columns (and tables) in the query/result.

### Column aliases
```sql
SELECT
    FirstName AS [First Name],
    Salary    AS MonthlySalary
FROM dbo.Employees;
```

Notes:
- brackets `[ ]` are useful if you want spaces in output names,
- `AS` is optional but recommended for readability.

### Table aliases
```sql
SELECT e.FirstName, e.LastName
FROM dbo.Employees AS e;
```

Why it’s useful:
- shorter queries,
- cleaner reading,
- prepares you for multi-table queries later (not in this lesson).

---

## 9) DISTINCT — remove duplicates

`DISTINCT` removes duplicate **rows** in the result set.

Example:
```sql
SELECT DISTINCT City
FROM dbo.Employees;
```

Important:
- `DISTINCT` applies to the entire selected row,
- `SELECT DISTINCT Department, City` means unique combinations of the pair.

---

## 10) TOP (N) — preview a few rows

`TOP (N)` returns only the first N rows of the result set:

```sql
SELECT TOP (5) EmployeeId, FirstName, City
FROM dbo.Employees;
```

⚠️ Without sorting (covered later), “first N rows” is **not guaranteed** to be consistent.
So use `TOP` mainly to preview data.

---

## ✅ Lesson summary
After this lesson you should be comfortable with:
- DB vs DBMS vs relational DB,
- tables, rows, columns, primary key,
- `SELECT <cols> FROM <table>`,
- why `SELECT *` is risky,
- aliases (`AS`) for clean output,
- `DISTINCT` for unique outputs,
- `TOP (N)` for previewing.

---

# 🧪 Practice Tasks (after running `01_Lab.sql`)

## A) Basic SELECT
1) Return all columns from `dbo.Employees` (one time only).
2) Return only: `EmployeeId`, `FirstName`, `LastName`.
3) Return only: `FirstName`, `Department`, `City`.

## B) Break the `SELECT *` habit
4) Write a query safe for a UI “employee list” screen:
   - `EmployeeId`, `FirstName`, `LastName`, `Department`, `City`
5) Write 3–5 sentences: why is `SELECT *` dangerous in production?  
   Mention performance + schema changes + security.

## C) Aliases (AS)
6) Return `FirstName` as `Name`, `LastName` as `Surname`, `Salary` as `MonthlySalary`.
7) Return `EmployeeId` as `ID` and `CreatedAt` as `Created`.
8) Use a table alias `e` and reference columns like `e.FirstName`, `e.LastName`, etc.
9) Create a clean “report” output with aliases:
   - `ID`, `Name`, `Surname`, `Dept`, `City`

## D) DISTINCT
10) Return unique `Department`.
11) Return unique `City`.
12) Return unique pairs: `Department` + `City`.
13) Compare:
    - `SELECT City FROM dbo.Employees;`
    - `SELECT DISTINCT City FROM dbo.Employees;`
    Write what you observe.

## E) TOP (N)
14) Return `TOP (3)` employees (choose any columns, but no `*`).
15) Return `TOP (5)` with: `EmployeeId`, `FirstName`, `City`.
16) Explain in 2–3 sentences: why `TOP (5)` does not mean “highest salaries”?

## F) Extra tasks (more reps)
17) Return unique cities and name the output column `AvailableCities`.
18) Return `TOP (10)` with a clean set of columns (no `*`), using a table alias.
19) Use `DISTINCT` on two columns and explain what “unique row” means in that case.
20) Rewrite one of your earlier queries to make it more readable (formatting + aliases).
