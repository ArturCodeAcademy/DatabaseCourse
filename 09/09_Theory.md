# 09_Theory.md
# Lesson 9 — Programmability in SQL Server: VIEWs & Stored Procedures

## 🎯 Goal
By the end of this lesson, you can:
- create and use a **VIEW** (a “virtual table” that stores a query),
- understand when a VIEW is useful (reuse + readability + security),
- create and execute a **Stored Procedure** (SP),
- pass parameters (e.g. `@UserId`) into a procedure,
- implement simple **business logic** inside the database (validation + calculated fields),
- understand the difference between “query-time logic” and “stored logic”.

---

# Part A — VIEWs

## 1) What is a VIEW?
A **VIEW** is a saved SQL query that behaves like a table **when you SELECT from it**.

Think of it as:
- a **named query** you can reuse,
- a **virtual table** (it does not store rows by itself),
- a way to hide complexity (especially JOINs).

Basic idea:
```sql
CREATE VIEW dbo.vw_Something AS
SELECT ...
FROM ...
JOIN ...
```

Then:
```sql
SELECT *
FROM dbo.vw_Something;
```

### Important: a VIEW does not store data
- A normal table stores data.
- A VIEW stores only the **definition** (the SQL).
When you query a view, SQL Server expands it into the underlying query.

---

## 2) Why use a VIEW?

### A) Reuse
If you keep writing the same JOIN over and over, you will:
- waste time,
- make mistakes,
- create inconsistent reports.

A view lets you write it once and reuse it everywhere.

### B) Readability
Instead of:
```sql
SELECT ...
FROM Orders
JOIN Users ...
JOIN OrderItems ...
JOIN Products ...
```
you can do:
```sql
SELECT ...
FROM dbo.vw_OrderSummary;
```

### C) Security / abstraction
You can give users access to a view without giving them access to the raw tables (common in reporting).

---

## 3) VIEW “gotchas”
- Views are not magic performance boosters by default.
- A view can be updatable in some simple cases, but many views are not (especially those with aggregates).
- Treat views primarily as a **readability + reuse** tool in this course.

---

# Part B — Stored Procedures

## 4) What is a Stored Procedure?
A **Stored Procedure** (SP) is a saved block of SQL that you can execute by name.

Example:
```sql
CREATE PROCEDURE dbo.sp_GetUserOrders
    @UserId INT
AS
BEGIN
    SELECT ...
END
```

Execute:
```sql
EXEC dbo.sp_GetUserOrders @UserId = 3;
```

---

## 5) Why use Stored Procedures?

### A) Reuse and standardization
Instead of copy-pasting “how to fetch user orders”, you call one procedure.

### B) Parameters
Procedures accept parameters (`@UserId`, `@Status`, dates, etc.) so the same logic can work for different inputs.

### C) Business logic in the DB
You can:
- validate input,
- calculate values,
- enforce rules consistently.

### D) Security
You can grant permission to execute a procedure without exposing full table access.

---

## 6) Parameter basics
Parameters are variables that the caller provides.

Example:
```sql
CREATE OR ALTER PROCEDURE dbo.sp_GetUserOrders
    @UserId INT
AS
BEGIN
    SELECT *
    FROM dbo.Orders
    WHERE UserId = @UserId;
END
```

Call:
```sql
EXEC dbo.sp_GetUserOrders @UserId = 1;
```

### Optional parameters (defaults)
```sql
@Status NVARCHAR(20) = NULL
```
Then inside:
```sql
WHERE (@Status IS NULL OR Status = @Status)
```

---

## 7) Procedures + transactions (when changing data)
If a procedure makes multiple changes that must succeed together, you can use a transaction:
```sql
BEGIN TRAN;
-- multiple INSERT/UPDATE/DELETE
COMMIT;
-- or ROLLBACK
```
This connects back to Lesson 6 (ACID & safety).

---

## 8) Our lab scenario (what you will build)
In `09_Lab.sql` you will build a tiny online store:
- `Users`
- `Products`
- `Orders`
- `OrderItems`

You will then:
- create a **view** `vw_OrderSummary` that joins and aggregates data,
- create procedures like:
  - `sp_GetUserOrders @UserId`
  - `sp_CreateOrder @UserId, ...`
  - `sp_AddOrderItem @OrderId, ...` (captures UnitPrice from Products)

---

## ✅ Lesson summary
After this lesson you can:
- create and query a VIEW as a reusable “virtual table”,
- create and run stored procedures,
- pass parameters (`@UserId`) into procedures,
- implement basic business rules in procedures.

---

# 🧪 Practice Tasks (after running `09_Lab.sql`)

## A) VIEW tasks
1) Query `dbo.vw_OrderSummary` and sort by `OrderTotal` descending.
2) Create a new view `dbo.vw_UserSpend` that returns:
   - UserId, FullName, TotalPaidSpend
   (Paid orders only)
3) Create a view `dbo.vw_ProductSales` that returns:
   - ProductId, Sku, ProductName, UnitsSold, Revenue
   (Paid orders only)

## B) Stored procedure tasks (read)
4) Execute `dbo.sp_GetUserOrders` for 2 different users.
5) Add an optional parameter `@Status` to `dbo.sp_GetUserOrders`:
   - If NULL → return all statuses
   - Else → filter by that status

## C) Stored procedure tasks (write / business logic)
6) Execute `dbo.sp_CreateOrder` for an existing user and capture the new `OrderId`.
7) Add 2 items into that order using `dbo.sp_AddOrderItem`.
8) Try adding an item with Quantity = 0. Confirm the procedure rejects it (or fails on CHECK).
9) Create a procedure `dbo.sp_CancelOrder @OrderId` that:
   - only cancels if current status is NOT 'Shipped'
   - sets Status = 'Cancelled'
10) Create `dbo.sp_GetOrderTotal @OrderId` that returns one row with:
   - OrderId, OrderTotal

## D) Refactor / compare
11) Write a SELECT with joins that produces the same output as `vw_OrderSummary`.
12) Explain (as comments): why is the view version easier to maintain?

## E) Extra tasks (more reps)
13) Create `sp_GetUserLifetimeSpend @UserId` (Paid only).
14) Create `sp_AddUser` with parameters (Email must be unique).
15) Create `sp_SetProductActive @Sku, @IsActive` to activate/deactivate products.
