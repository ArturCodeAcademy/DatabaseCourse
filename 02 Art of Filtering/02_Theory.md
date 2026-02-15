# Lesson 2 — The Art of Filtering (WHERE & ORDER BY)

## 🎯 Goal
By the end of this lesson, you can:
- use the **WHERE** clause to filter data,
- understand **Boolean logic** (True, False, and the mysterious NULL),
- combine conditions using **AND** and **OR** (and use parentheses correctly),
- search for text patterns using **LIKE**,
- filter ranges with **IN**,
- handle **NULL** values correctly,
- sort your results using **ORDER BY**.

---

## 1) The WHERE Clause
The `WHERE` clause filters rows **before** they are sent to the result set. 

**Logical Order of Execution:**
1. **FROM** (Find the table)
2. **WHERE** (Filter the rows) — *New step!*
3. **SELECT** (Choose columns)
4. **ORDER BY** (Sort the final list)

---

## 2) Comparison Operators
Standard math operators work here:
- `=` (Equals)
- `<>` or `!=` (Not equals)
- `>` / `<` (Greater than / Less than)
- `>=` / `<=` (Greater than or equal / Less than or equal)

---

## 3) Boolean Logic: AND, OR, and Parentheses
When you have multiple conditions, logic kicks in:
- **AND**: BOTH conditions must be true.
- **OR**: AT LEAST ONE condition must be true.

### ⚠️ The Danger of Mixing (Operator Precedence)
SQL evaluates `AND` before `OR`.
**Example:** `WHERE Dept = 'IT' OR Dept = 'HR' AND Salary > 5000`
SQL thinks you want: *(Everyone in IT)* **OR** *(People in HR with high salary)*.

**Solution:** Always use **parentheses** `( )` to be explicit:
`WHERE (Dept = 'IT' OR Dept = 'HR') AND Salary > 5000`

---

## 4) Searching for Patterns (LIKE, IN)

### LIKE (Pattern Matching)
Used for searching text:
- `%` — matches any sequence of characters (including zero).
- `_` — matches exactly one character.

*Example:* `WHERE Name LIKE 'J%'` (Starts with J), `WHERE Email LIKE '%@gmail.com'` (Ends with Gmail).

### IN (The Shortcut)
Instead of writing `City = 'London' OR City = 'Paris' OR City = 'Oslo'`, use:
`WHERE City IN ('London', 'Paris', 'Oslo')`

---

## 5) The Mystery of NULL (Three-Valued Logic)
In SQL, `NULL` is not a value; it is a **mark** meaning "Unknown" or "Missing".

- `Salary = NULL` is **NEVER** true (even if the salary is missing).
- `NULL = NULL` is **FALSE** (Unknown cannot equal Unknown).

**The Only Way to Filter NULLs:**
- `WHERE Salary IS NULL`
- `WHERE Salary IS NOT NULL`

---

## 6) Sorting Results (ORDER BY)
`ORDER BY` defines the final presentation of your data.

- `ASC` (default): Smallest to largest (A-Z, 1-10).
- `DESC`: Largest to smallest (Z-A, 10-1).

**Multi-column sorting:**
`ORDER BY Department ASC, Salary DESC`
(Sort by Department first, then within each department, show highest salaries first).

---

# 🧪 Practice Tasks (Lesson 2)

## A) Basic Filters
1) Find all employees in the 'IT' department.
2) Find employees with a salary greater than 5000.
3) Find employees who do NOT live in 'New York'.

## B) Combining Logic
4) Find employees in 'IT' who earn more than 4000.
5) Find employees who live in 'Austin' OR 'Denver'.
6) Find employees in 'Sales' who earn less than 3000 **OR** all employees in 'HR'.

## C) Text & Ranges
7) Find employees whose `FirstName` starts with 'M'.
8) Find employees whose `LastName` contains the letter 'n'.
9) Use `IN` to find employees in 'IT', 'HR', or 'Finance'.

## D) The NULL Factor
10) Find employees whose `Salary` is missing (if any).
11) Find all employees where the `Department` is NOT missing.

## E) Sorting
12) List all employees sorted by `LastName` (A-Z).
13) List all employees by `Salary` (Highest to Lowest).
14) Sort by `Department` (A-Z), and then by `Salary` (Highest to Lowest) within each department.