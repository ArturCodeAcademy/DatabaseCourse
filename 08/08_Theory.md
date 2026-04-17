# 08_Theory.md
# Lesson 8 — Functions in SQL Server (Strings, Dates, CASE WHEN)

## 🎯 Goal
By the end of this lesson, you can:
- use common **string functions**: `CONCAT`, `SUBSTRING`, `LEN`, `REPLACE`,
- use common **date functions**: `DATEDIFF`, `DATEADD`,
- use `CASE WHEN` to build “if-then” logic inside SQL,
- combine functions to produce clean, readable output for reports and dashboards.

This lesson is **practical**: functions are tools you use every day to shape data.

---

## 1) What is a function in SQL?
A **function** returns a value.

Most functions you’ll use are **scalar functions**:
- they run per row,
- they return one value per row.

Example:
```sql
SELECT
  TicketId,
  LEN(Title) AS TitleLength
FROM dbo.Tickets;
```

### Where can functions be used?
- `SELECT` (most common: formatting output)
- `WHERE` (filtering, but be careful with performance later)
- `ORDER BY`
- `GROUP BY` (advanced usage later)

---

# Part A — String functions

## 2) CONCAT — join strings safely
**Purpose:** build readable text from multiple pieces.

### Syntax
```sql
CONCAT(value1, value2, value3, ...)
```

### Why CONCAT is safer than `+`
- `CONCAT` treats `NULL` as empty string in many cases, which often avoids unexpected NULL outputs.
- With `+`, if one part is NULL, the whole expression can become NULL.

Example:
```sql
SELECT CONCAT(FirstName, ' ', LastName) AS FullName
FROM dbo.Customers;
```

---

## 3) LEN — length of a string
**Purpose:** count characters in a string.

### Syntax
```sql
LEN(expression)
```

Example:
```sql
SELECT Title, LEN(Title) AS TitleLength
FROM dbo.Tickets;
```

**Note:** `LEN` does not count trailing spaces at the end of a string.

---

## 4) SUBSTRING — take part of a string
**Purpose:** extract a piece of text by position.

### Syntax
```sql
SUBSTRING(expression, start, length)
```

Example (extract year from ticket code like `TCK-2025-0007`):
```sql
SELECT
  TicketCode,
  SUBSTRING(TicketCode, 5, 4) AS TicketYear
FROM dbo.Tickets;
```

- `start` is 1-based (first character is position 1)
- `length` is how many characters you want

---

## 5) REPLACE — replace characters inside a string
**Purpose:** clean or normalize text.

### Syntax
```sql
REPLACE(expression, search, replacement)
```

Example:
```sql
SELECT
  TicketCode,
  REPLACE(TicketCode, '-', '') AS CodeNoDashes
FROM dbo.Tickets;
```

Common use cases:
- remove dashes/spaces,
- replace “bad” characters,
- normalize formatting.

---

# Part B — Date functions

## 6) DATEDIFF — how much time passed?
**Purpose:** return the difference between two dates in a chosen unit.

### Syntax
```sql
DATEDIFF(datepart, startdate, enddate)
```

Common dateparts:
- `DAY`, `HOUR`, `MINUTE`, `MONTH`, `YEAR`

Example:
```sql
SELECT
  TicketId,
  CreatedAt,
  DATEDIFF(DAY, CreatedAt, SYSDATETIME()) AS DaysSinceCreated
FROM dbo.Tickets;
```

### Important: DATEDIFF counts boundaries
`DATEDIFF(DAY, '2025-01-01 23:59', '2025-01-02 00:01')` returns **1** day
because it crossed a day boundary.

So think of DATEDIFF as:
> “How many date-part boundaries were crossed?”

---

## 7) DATEADD — add time to a date
**Purpose:** compute deadlines, reminders, offsets.

### Syntax
```sql
DATEADD(datepart, number, date)
```

Example: deadline 7 days after created:
```sql
SELECT
  TicketId,
  CreatedAt,
  DATEADD(DAY, 7, CreatedAt) AS DueDate
FROM dbo.Tickets;
```

---

# Part C — CASE WHEN (if-then logic)

## 8) CASE WHEN — “if-then” inside SQL
**Purpose:** create categories, labels, flags, buckets.

### Syntax
```sql
CASE
  WHEN condition1 THEN result1
  WHEN condition2 THEN result2
  ELSE default_result
END
```

Example: bucket by priority
```sql
SELECT
  TicketId,
  Priority,
  CASE
    WHEN Priority = 'High' THEN 'P1'
    WHEN Priority = 'Medium' THEN 'P2'
    ELSE 'P3'
  END AS PriorityBucket
FROM dbo.Tickets;
```

### CASE is evaluated top-to-bottom
First matching `WHEN` wins. So order matters.

---

## 9) Combining functions (real-life pattern)
Most real queries combine functions.

Example: SLA label for open tickets:
- compute due date,
- compute days open,
- classify with CASE.

You’ll do this in the lab.

---

## ✅ Lesson summary
You should now be able to:
- format strings with `CONCAT`,
- measure strings with `LEN`,
- extract parts with `SUBSTRING`,
- clean text with `REPLACE`,
- compute time differences with `DATEDIFF`,
- build dates with `DATEADD`,
- add business logic using `CASE WHEN`.

---

# 🧪 Practice Tasks (after running `08_Lab.sql`)

## A) Strings
1) Return `TicketCode` plus a “clean” code without dashes (use `REPLACE`).
2) Extract the year from `TicketCode` (use `SUBSTRING`).
3) Show each ticket title and its length (use `LEN`).
4) Build a display field: `CustomerFullName <Email>` using `CONCAT`.
5) Create a “short title” that keeps only the first 12 characters of the title (use `SUBSTRING`).

## B) Dates
6) Show how many days ago each ticket was created (use `DATEDIFF`).
7) Create a due date: 7 days after `CreatedAt` (use `DATEADD`).
8) Show tickets created in the last 30 days (use `DATEDIFF` with a filter).

## C) CASE WHEN
9) Create a column `TicketAgeBucket`:
   - `0-2 days`
   - `3-7 days`
   - `8+ days`
10) Create a column `SlaStatus`:
   - `Overdue` if `ClosedAt IS NULL` and today > DueDate
   - `On Time` otherwise

## D) Combine everything
11) Produce a report with:
   - TicketCode, CleanCode, Title, TitleLength,
   - DaysOpen,
   - DueDate,
   - TicketAgeBucket,
   - SlaStatus
12) Sort the report by `SlaStatus` (Overdue first) and then `DaysOpen` desc.
