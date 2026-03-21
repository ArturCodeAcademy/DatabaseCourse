# 06_Theory.md
# Lesson 6 — DML: Changing Data (INSERT, UPDATE, DELETE, TRUNCATE, Soft Delete)

## 🎯 Goal
By the end of this lesson, you can:
- explain what **DML** is and when it is used,
- understand the *start* of **ACID** and why transactions matter,
- write `INSERT` (single-row and multi-row “bulk” insert),
- write safe `UPDATE` statements (and avoid the classic “UPDATE without WHERE” disaster),
- understand the difference between `DELETE` and `TRUNCATE`,
- implement **Soft Delete** using an `IsDeleted` flag.

---

## 1) What is DML?
**DML (Data Manipulation Language)** is the part of SQL used to **change the data** inside tables.

Core DML commands:
- `INSERT` — add new rows
- `UPDATE` — modify existing rows
- `DELETE` — remove rows

Related (often grouped with DML in practice):
- `TRUNCATE TABLE` — remove *all* rows quickly (with important differences)

---

## 2) ACID (the beginning) — why “changing data” is risky
When you change data, you want the DB to be reliable even if:
- your app crashes,
- the server loses power,
- multiple users write at the same time,
- part of an operation fails.

That’s why relational DBMSs (like SQL Server) support **ACID** properties.

### A — Atomicity
“All or nothing.”  
A multi-step change should either:
- fully succeed, or
- fully roll back (undo).

### C — Consistency
The database should not end up in an invalid state.
Constraints and rules (PK, checks, etc.) help maintain consistency.

### I — Isolation
Multiple transactions running at the same time should not corrupt each other.
(We will go deeper later. For now, know this is about concurrency.)

### D — Durability
Once the DB says “COMMIT succeeded”, the data should survive a crash.

### Transactions (your safety belt)
A **transaction** groups multiple changes into one logical unit.

Typical pattern:

```sql
BEGIN TRAN;

-- one or more INSERT/UPDATE/DELETE
-- verify with SELECT if needed

COMMIT;   -- keep changes
-- or
ROLLBACK; -- undo changes
```

---

## 3) INSERT — adding data

### 3.1 Insert one row
```sql
INSERT INTO dbo.Users (Email, FullName, City)
VALUES ('amy@example.com', 'Amy Adams', 'Boston');
```

### 3.2 Insert many rows (bulk-style)
SQL Server supports inserting multiple rows in one statement:

```sql
INSERT INTO dbo.Users (Email, FullName, City)
VALUES
  ('mike@example.com', 'Mike Stone', 'Chicago'),
  ('sara@example.com', 'Sara Kim', 'Austin');
```

### 3.3 Common mistakes
- forgetting the column list (dangerous when schema changes),
- wrong column order,
- inserting `NULL` into a `NOT NULL` column,
- inserting duplicates into a column that must be unique.

✅ Rule: always write the column list explicitly.

---

## 4) UPDATE — modifying data (and the #1 danger)

### 4.1 The classic disaster: UPDATE without WHERE
This is the SQL horror story:

```sql
UPDATE dbo.Users
SET City = 'New York';
```

If you forget `WHERE`, you update **every row**.

This is why:
- you test on small data,
- you use transactions,
- you check how many rows will be affected.

### 4.2 Safe update workflow (professional habit)
1) Write a `SELECT` first to confirm the target rows:
```sql
SELECT *
FROM dbo.Users
WHERE City = 'Austin';
```

2) Then update **the same filter**:
```sql
UPDATE dbo.Users
SET City = 'San Diego'
WHERE City = 'Austin';
```

3) Verify the result:
```sql
SELECT *
FROM dbo.Users
WHERE City = 'San Diego';
```

### 4.3 Use `@@ROWCOUNT` to see impact
Immediately after `INSERT/UPDATE/DELETE` you can check:

```sql
SELECT @@ROWCOUNT AS RowsAffected;
```

This is a quick sanity check (especially inside a transaction).

---

## 5) DELETE vs TRUNCATE

### 5.1 DELETE
`DELETE` removes rows. It can be filtered:

```sql
DELETE FROM dbo.Users
WHERE City = 'Boston';
```

Important notes:
- it logs row-by-row changes,
- it can be slow on huge tables,
- identity values usually do **not** reset automatically.

### 5.2 TRUNCATE TABLE
`TRUNCATE TABLE` removes **all rows** from a table, no `WHERE` allowed:

```sql
TRUNCATE TABLE dbo.TempEvents;
```

Important notes:
- very fast for clearing whole tables,
- typically uses less logging than massive DELETE,
- **resets IDENTITY** back to its seed (usually back to 1),
- cannot run if the table is referenced by a foreign key (even if that referencing table is empty).

✅ Simple rule:
- If you need “remove some rows” → `DELETE ... WHERE ...`
- If you need “wipe the table completely (fast) and reset identity” → `TRUNCATE TABLE`

---

## 6) Soft Delete (IsDeleted flag)
Sometimes you **should not physically delete rows**, because:
- you need audit/history,
- you want undo/restore,
- other records might reference this row,
- you need “deleted” items for reporting.

Soft delete pattern:
- add `IsDeleted BIT NOT NULL DEFAULT 0`
- optionally add `DeletedAt DATETIME2 NULL`

Soft delete operation:
```sql
UPDATE dbo.Users
SET IsDeleted = 1,
    DeletedAt = SYSDATETIME()
WHERE UserId = 7;
```

Then your “normal” queries should filter out deleted rows:
```sql
SELECT UserId, Email, FullName, City
FROM dbo.Users
WHERE IsDeleted = 0;
```

✅ Soft delete is a business choice. It trades:
- more complexity in queries
for
- safer history and recoverability.

---

## ✅ Lesson summary
You can now:
- use `INSERT` (single and multi-row),
- write safe `UPDATE` with `WHERE`,
- understand why `UPDATE` without `WHERE` is dangerous,
- remove rows with `DELETE`,
- wipe a table with `TRUNCATE TABLE` and understand the tradeoffs,
- implement Soft Delete with `IsDeleted`.

---

# 🧪 Practice Tasks (after running `06_Lab.sql`)

## A) INSERT
1) Insert 1 new user (your own name/email).
2) Insert 3 users in a single statement (multi-row insert).
3) Try inserting a duplicate Email. Explain why it fails (or why it succeeds if you removed the constraint).

## B) UPDATE (safe habits)
4) Update one user’s city by `UserId`.
5) Update all users in a specific city to a new city.
6) Write a `SELECT` first, then run the matching `UPDATE`.
7) Use `@@ROWCOUNT` to confirm how many rows you changed.

## C) DELETE
8) Delete users from one city (use `WHERE`).
9) Delete exactly one user by `UserId`.
10) Explain why `DELETE` without `WHERE` is dangerous.

## D) TRUNCATE
11) In the `dbo.TempEvents` table:
    - insert a few rows,
    - `DELETE` all rows,
    - insert again and observe identity values,
    - `TRUNCATE` the table,
    - insert again and observe identity reset.

## E) Soft Delete
12) Soft-delete a user by setting `IsDeleted = 1`.
13) Write a query that returns only active users (`IsDeleted = 0`).
14) Restore the user (set `IsDeleted = 0` and `DeletedAt = NULL`).
