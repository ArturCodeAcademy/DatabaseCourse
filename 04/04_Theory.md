
# Lesson 4: JOINs — The Most Important SQL Skill 🔗

## Goal
Learn how to connect tables using SQL JOINs.

In real databases, data is stored in multiple related tables. JOIN allows us to combine them.

Topics:
- Normalization (1NF, 2NF, 3NF)
- INNER JOIN
- LEFT JOIN
- FULL JOIN
- CROSS JOIN
- Table aliases

---

# 1. Why Data Is Split Into Tables

Imagine a single giant table:

OrderId | CustomerName | CustomerCity | ProductName | ProductPrice | OrderDate

Problems:
- repeated customer data
- repeated product data
- harder updates
- wasted storage

Instead we split the data:

Customers
CustomerId | Name | City

Products
ProductId | ProductName | Price

Orders
OrderId | CustomerId | OrderDate

Now the tables are clean and reusable.

But we need a way to combine them → JOIN.

---

# 2. Normalization

Normalization reduces data duplication.

## First Normal Form (1NF)

Rules:
- one value per cell
- no repeating groups

Bad:
CustomerId | Phones
1 | 123,456

Good:
CustomerId | Phone
1 | 123
1 | 456

## Second Normal Form (2NF)

Columns must depend on the entire primary key.

If a table uses a composite key (OrderId, ProductId), columns must depend on both.

## Third Normal Form (3NF)

Columns should depend only on the primary key.

Bad design:
CustomerId | CityId | CityName

Better:
Customers(CustomerId, Name, CityId)
Cities(CityId, CityName)

---

# 3. What JOIN Does

JOIN combines rows from two tables.

Example tables:

Customers
CustomerId | Name
1 | Alice
2 | Bob

Orders
OrderId | CustomerId
101 | 1
102 | 1
103 | 2

Query:

SELECT c.Name, o.OrderId
FROM Customers AS c
INNER JOIN Orders AS o
ON c.CustomerId = o.CustomerId;

Result:

Name | OrderId
Alice | 101
Alice | 102
Bob | 103

---

# 4. Table Aliases

Aliases are short names for tables.

FROM Customers AS c
JOIN Orders AS o

Then we use:
c.Name
o.OrderDate

instead of:
Customers.Name
Orders.OrderDate

Benefits:
- shorter queries
- easier to read
- avoids ambiguity

---

# 5. INNER JOIN

Returns only rows that match in both tables.

SELECT c.Name, o.OrderId
FROM Customers c
INNER JOIN Orders o
ON c.CustomerId = o.CustomerId;

Customers without orders are excluded.

---

# 6. LEFT JOIN

Returns:
- all rows from left table
- matching rows from right table
- NULL when there is no match

SELECT c.Name, o.OrderId
FROM Customers c
LEFT JOIN Orders o
ON c.CustomerId = o.CustomerId;

Example result:

Name | OrderId
Alice | 101
Alice | 102
Bob | 103
Charlie | NULL

---

# Finding Orphans

Customers without orders:

SELECT c.Name
FROM Customers c
LEFT JOIN Orders o
ON c.CustomerId = o.CustomerId
WHERE o.OrderId IS NULL;

---

# 7. FULL JOIN

Returns everything from both tables.

SELECT c.Name, o.OrderId
FROM Customers c
FULL JOIN Orders o
ON c.CustomerId = o.CustomerId;

---

# 8. CROSS JOIN

Creates every possible combination.

Sizes
S
M

Colors
Red
Blue

SELECT s.Size, c.Color
FROM Sizes s
CROSS JOIN Colors c;

Result:

S Red
S Blue
M Red
M Blue

---

# 9. Common JOIN Mistakes

Wrong join condition:

ON c.CustomerId = o.OrderId

Missing ON clause.

Not using aliases.

Breaking LEFT JOIN with:

WHERE o.OrderId IS NOT NULL

---

# Summary

JOIN types:

INNER JOIN → only matches
LEFT JOIN → everything from left
FULL JOIN → everything
CROSS JOIN → all combinations

Always use aliases:

c.Name
o.OrderDate
