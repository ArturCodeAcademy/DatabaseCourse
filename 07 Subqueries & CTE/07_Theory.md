# 07_Theory.md
# Lesson 7 — Complex Queries: Subqueries & CTE (WITH)

## 🎯 Goal
By the end of this lesson, you can:
- use **subqueries** inside `WHERE` (especially `IN (SELECT ...)`) to filter data,
- understand what a subquery returns (scalar vs list),
- write **CTEs** using `WITH ... AS (...)` to make SQL more readable,
- use **multiple CTEs** to split complex logic into clear steps.

Dataset used in this lesson: a small **online store** (Customers, Products, Orders).

---

## 1) What is a subquery?
A **subquery** is a query inside another query.

You can think of it as:
- an **inner query** that produces a result,
- and an **outer query** that uses that result.

In this lesson we focus on subqueries inside `WHERE` (filtering).

---

## 2) Subquery result shapes (critical idea)

### A) Scalar subquery (one value)
Returns one value (1 row × 1 column).  
Used with `=`, `>`, `<`, etc.

Example: customers who placed the **earliest** order:
```sql
SELECT c.CustomerCode, c.FirstName, c.LastName
FROM dbo.Customers AS c
WHERE c.CustomerId = (
    SELECT TOP (1) o.CustomerId
    FROM dbo.Orders AS o
    ORDER BY o.OrderDate ASC
);
```

### B) List subquery (many rows, one column)
Returns a set/list of values.  
Used with `IN (...)`.

Example: customers who have **any cancelled order**:
```sql
SELECT c.CustomerCode, c.FirstName, c.LastName
FROM dbo.Customers AS c
WHERE c.CustomerId IN (
    SELECT o.CustomerId
    FROM dbo.Orders AS o
    WHERE o.Status = 'Cancelled'
);
```

> In SQL Server, the inner query can return many rows — `IN` checks if the outer value exists in that list.

---

## 3) Subqueries in WHERE: `IN (SELECT ...)`

### The pattern
```sql
SELECT <columns>
FROM <table>
WHERE <id_column> IN (
    SELECT <id_column>
    FROM <other_table>
    WHERE <condition>
);
```

Read it as:
> “Keep rows where this ID appears in the inner query’s result.”

Common use cases:
- “customers who have orders”
- “products that were ever sold”
- “customers who bought from a certain category”
- “orders that contain a specific SKU”

---

## 4) `IN` vs a chain of `OR`
These are equivalent:

```sql
WHERE City = 'Boston'
   OR City = 'Chicago'
   OR City = 'Seattle'
```

Cleaner:
```sql
WHERE City IN ('Boston', 'Chicago', 'Seattle')
```

Same idea applies to subqueries: `IN (SELECT ...)` is a clean “set membership” check.

---

## 5) `NOT IN` — the NULL trap
`NOT IN` looks simple:

```sql
WHERE CustomerId NOT IN (SELECT CustomerId FROM dbo.VipList)
```

⚠️ If the inner query returns `NULL` even once, `NOT IN` can produce surprising results (often returning **zero rows**).

Why?
- comparisons with `NULL` are **UNKNOWN**
- `NOT IN` becomes “UNKNOWN” for many values
- `WHERE` keeps only **TRUE**, not UNKNOWN

✅ Safer options:
1) Filter NULLs out inside the subquery:
```sql
WHERE CustomerId NOT IN (
    SELECT CustomerId
    FROM dbo.VipList
    WHERE CustomerId IS NOT NULL
)
```

2) Use `NOT EXISTS` (optional idea):
```sql
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.VipList v
    WHERE v.CustomerId = c.CustomerId
)
```

---

## 6) CTE: Common Table Expression (`WITH`)
A **CTE** is a named, temporary result set defined inside a query.

It exists only for the single statement that follows it.

### Basic syntax
```sql
WITH CteName AS (
    SELECT ...
)
SELECT ...
FROM CteName;
```

### SQL Server tip: start with a semicolon
If your CTE is not the first statement in the batch:
```sql
;WITH Cte AS (...)
SELECT ...
```

---

## 7) Why CTEs are useful
CTEs make SQL readable by:
- naming intermediate steps,
- reducing deep nesting,
- letting you build complex logic like a pipeline.

### Example: “Customer lifetime spend (paid orders only)”
This is easier with steps:

1) filter only paid orders
2) compute revenue per order
3) sum per customer
4) show only high-value customers

```sql
;WITH PaidOrders AS (
    SELECT o.OrderId, o.CustomerId
    FROM dbo.Orders o
    WHERE o.Status = 'Paid'
),
OrderRevenue AS (
    SELECT po.CustomerId, po.OrderId,
           SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
    FROM PaidOrders po
    JOIN dbo.OrderItems oi ON oi.OrderId = po.OrderId
    GROUP BY po.CustomerId, po.OrderId
),
CustomerSpend AS (
    SELECT CustomerId,
           SUM(OrderTotal) AS LifetimeSpend
    FROM OrderRevenue
    GROUP BY CustomerId
)
SELECT c.CustomerCode, c.FirstName, c.LastName, cs.LifetimeSpend
FROM CustomerSpend cs
JOIN dbo.Customers c ON c.CustomerId = cs.CustomerId
WHERE cs.LifetimeSpend >= 500;
```

---

## ✅ Lesson summary
You can now:
- use `IN (SELECT ...)` to filter by “membership in a set,”
- understand scalar vs list subqueries,
- avoid the `NOT IN` + `NULL` trap,
- write CTEs to make complex logic readable,
- split one complex query into multiple steps using multiple CTEs.

---

# 🧪 Practice Tasks (after running `07_Lab.sql`)

## A) Subqueries with IN (core)
1) Customers who have **any cancelled order**.
2) Customers who have **any paid order**.
3) Products that were ever ordered (appear in OrderItems).
4) Customers who bought a product from the category **'Electronics'**.
5) Customers who bought the SKU **'SKU-USB-C-01'**.

## B) NOT IN tasks (and the NULL trap)
6) Products that were **never ordered**.
7) Customers who are **not** in the VIP list (do it with `NOT IN` and observe the NULL problem).
8) Fix task #7 by filtering NULLs inside the subquery.

## C) Scalar subqueries (one value)
9) Products priced above the **average product price**.
10) Customers who placed an order on the **earliest order date**.

## D) CTE — single step
11) Create a CTE `PaidOrders` and select from it.
12) Create a CTE `CancelledOrders` and show customer info for them.

## E) CTE — multi-step (break logic into steps)
13) Lifetime spend per customer (paid orders only).
14) Top 5 customers by lifetime spend (use a CTE, then order by).
15) Product revenue leaderboard:
    - total revenue per product (paid orders only),
    - show top 5 products.

## F) Extra (more reps / “think like SQL”)
16) Customers who bought from **at least 2 distinct categories** (CTE step for categories per customer).
17) Customers whose average paid order total is >= 150 (CTE: order totals → avg per customer).
18) Find “one-time buyers”: customers with exactly 1 paid order (CTE + HAVING).
19) Rewrite one IN-subquery solution using a CTE instead (same result, different structure).
20) Rewrite one CTE solution as a nested subquery and compare readability.
