# Lesson 5: DDL — Creating the World 🏗️

## 🎯 Goal

Before we query data, filter data, join tables, or build reports, we must first **create the world where the data will live**.

That is the job of **DDL**.

In this lesson you will learn:

- what **DDL** means
- how to use `CREATE DATABASE`
- how to use `CREATE TABLE`
- how to choose correct **data types**
- why `NVARCHAR` usually takes about twice as much space as `VARCHAR`
- how to protect data with constraints:
  - `PRIMARY KEY`
  - `FOREIGN KEY`
  - `DEFAULT`
  - `CHECK`

This is one of the most practical SQL lessons, because it teaches you how databases are designed from the beginning.

---

# 1️⃣ What Is DDL?

DDL stands for **Data Definition Language**.

It is the part of SQL used to define and change the **structure** of a database.

Think of it like architecture:

- DDL builds the house
- DML (`INSERT`, `UPDATE`, `DELETE`) moves furniture inside
- `SELECT` lets us inspect what is there

DDL commands include:

- `CREATE`
- `ALTER`
- `DROP`

In this lesson, the focus is on **creating things from scratch**.

---

# 2️⃣ CREATE DATABASE

A database is the main container that stores tables, views, procedures, indexes, and other objects.

Example:

```sql
CREATE DATABASE ShopDb;
```

After a database exists, we usually switch into it:

```sql
USE ShopDb;
```

That tells SQL Server:

> “From now on, create and query objects inside this database.”

In your lab, the working database is:

```sql
USE SqlCourse;
```

That means all tables such as `dbo.Customers` and `dbo.Products` are created inside the `SqlCourse` database.

---

# 3️⃣ CREATE TABLE — The Core of Database Design

A table is where data actually lives.

When we write `CREATE TABLE`, we define:

- the table name
- the columns
- the data type of each column
- which values are allowed
- which rules protect data quality

Example:

```sql
CREATE TABLE dbo.Customers (
    CustomerId INT PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    City NVARCHAR(50) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'New'
);
```

This does a lot more than beginners usually notice.

It does **not only create columns** — it also creates rules:

- `CustomerId` must be unique because it is the primary key
- `FullName` cannot be empty because of `NOT NULL`
- `Status` gets `'New'` automatically if you do not provide a value

So `CREATE TABLE` is really **table structure + validation rules** together.

---

# 4️⃣ Data Types — Choosing the Right Container

A data type tells SQL what kind of data a column can store.

This matters because data types affect:

- storage size
- correctness
- speed
- future flexibility

Choosing the wrong data type is one of the most common beginner mistakes.

---

## 4.1 String Types

Strings are text values.

Examples:
- customer names
- cities
- emails
- product names
- status values

Two very common string types in SQL Server are:

- `VARCHAR`
- `NVARCHAR`

---

## 4.2 VARCHAR

`VARCHAR(n)` stores variable-length **non-Unicode** text.

Example:

```sql
Email VARCHAR(150)
```

This means:
- the column can store up to 150 characters
- it uses variable length, so shorter values use less storage
- it is usually best for plain English text or technical strings

Typical use cases:
- email addresses
- URLs
- codes
- identifiers
- English-only text

---

## 4.3 NVARCHAR

`NVARCHAR(n)` stores variable-length **Unicode** text.

Example:

```sql
FullName NVARCHAR(100)
```

Unicode is important because it supports many writing systems, including:

- English
- Russian
- Arabic
- Chinese
- Japanese
- Korean
- accented European characters

This is why in the lab you can safely insert names like:

```sql
N'Мария Иванова'
N'李华'
```

The `N` prefix tells SQL Server that the string literal is Unicode.

Without Unicode support, multilingual text can become broken or unreadable.

---

## 4.4 Why NVARCHAR Usually Takes About 2x More Space Than VARCHAR

This is one of the most famous practical questions in SQL.

### Basic idea:
- `VARCHAR` usually stores simple text using about **1 byte per character**
- `NVARCHAR` usually stores Unicode text using about **2 bytes per character**

So roughly:
- `VARCHAR(100)` → up to about 100 bytes
- `NVARCHAR(100)` → up to about 200 bytes

That is why `NVARCHAR` is more flexible, but heavier.

### Why use NVARCHAR anyway?
Because correctness is more important than saving a little space when your system needs multilingual support.

A good rule:

- use `VARCHAR` for technical text that is clearly ASCII / English-only
  (email, SKU, URL, status code)
- use `NVARCHAR` for human names, cities, comments, titles, and anything that may contain international characters

That is exactly why your lab uses:

```sql
FullName NVARCHAR(100)
City NVARCHAR(50)
Email VARCHAR(150)
```

This is a realistic design.

---

## 4.5 INT

`INT` stores whole numbers.

Example:

```sql
CustomerId INT
Stock INT
Quantity INT
```

Use `INT` when:
- decimal places are not needed
- values are counts or identifiers

Typical examples:
- row IDs
- quantity
- stock amount
- age
- score

---

## 4.6 DECIMAL

`DECIMAL(p, s)` stores exact numeric values.

Example:

```sql
Price DECIMAL(10,2)
```

This means:
- up to 10 total digits
- 2 digits after the decimal point

Examples of valid values:
- `25.00`
- `1200.99`
- `99999999.99` (depending on precision)

`DECIMAL` is the correct choice for:
- money
- price
- tax
- discounts
- financial calculations

### Why not FLOAT for money?

Because `FLOAT` is an approximate type.

Approximate types can introduce tiny rounding problems.

For scientific calculations that is often acceptable.
For money it is dangerous.

So:

✅ Good:
```sql
Price DECIMAL(10,2)
```

❌ Risky:
```sql
Price FLOAT
```

---

## 4.7 DATE

`DATE` stores a date without time.

Example:

```sql
OrderDate DATE
CreatedAt DATE
```

Use it when you only need:
- year
- month
- day

If you need time too, you would use something like `DATETIME` or `DATETIME2`.

In this lesson, `DATE` is enough.

---

# 5️⃣ NULL vs NOT NULL

Every column can either allow missing values or not.

## `NOT NULL`
This means a value is required.

Example:

```sql
FullName NVARCHAR(100) NOT NULL
```

So every inserted row must have a `FullName`.

## `NULL`
This means the value is optional.

Example:

```sql
City NVARCHAR(50) NULL
```

If the city is unknown, SQL allows the row anyway.

### Practical idea:
Use `NOT NULL` when a value is essential.
Use `NULL` only when missing data is truly acceptable.

Beginners often leave everything nullable.
That usually creates weak table design.

---

# 6️⃣ Constraints — Rules That Protect Data

Constraints are one of the most important parts of DDL.

A constraint is a rule enforced by the database.

Instead of trusting every developer or user to behave correctly, we let the database itself protect the data.

In your lab, the most important constraints are:

- `PRIMARY KEY`
- `FOREIGN KEY`
- `DEFAULT`
- `CHECK`

---

# 7️⃣ PRIMARY KEY (PK)

A **Primary Key** uniquely identifies each row in a table.

Example:

```sql
CustomerId INT PRIMARY KEY
```

This means:
- no duplicate values
- no NULL values
- each row has a unique identity

Without a primary key, rows are harder to identify and relationships become unreliable.

### Real examples:
- `CustomerId`
- `ProductId`
- `OrderId`
- `OrderLineId`

These are excellent PK columns because they represent a single unique row.

### Error example
If the table already contains:

```sql
CustomerId = 1
```

then this will fail:

```sql
INSERT INTO dbo.Customers (CustomerId, FullName, Email)
VALUES (1, N'Another Alice', 'another@example.com');
```

Why?
Because PK forbids duplicates.

---

# 8️⃣ FOREIGN KEY (FK)

A **Foreign Key** creates a relationship between two tables.

It says:

> “This value must already exist in another table.”

Example from the lab:

```sql
CONSTRAINT FK_Orders_Customers
    FOREIGN KEY (CustomerId)
    REFERENCES dbo.Customers(CustomerId)
```

This means:
- every `Orders.CustomerId` must exist in `Customers.CustomerId`

So if you try to insert:

```sql
INSERT INTO dbo.Orders (OrderId, CustomerId)
VALUES (2001, 999);
```

it fails if customer `999` does not exist.

That is extremely important because it prevents broken relationships.

### Why FK matters
Without foreign keys, you can easily create “ghost data”:
- orders for customers that do not exist
- order lines for products that do not exist
- payments for invoices that do not exist

FK protects relational integrity.

---

# 9️⃣ DEFAULT

A `DEFAULT` constraint gives a value automatically when no value is provided.

Example:

```sql
Status NVARCHAR(20) NOT NULL DEFAULT 'New'
```

If you insert a row without `Status`, SQL automatically uses `'New'`.

From the lab:

```sql
INSERT INTO dbo.Customers (CustomerId, FullName, Email, City)
VALUES (4, N'Diana Miller', 'diana@example.com', N'Seattle');
```

Even though `Status` is missing, the row works because SQL supplies the default:

```sql
'New'
```

Another example from the lab:

```sql
OrderDate DATE NOT NULL DEFAULT GETDATE()
```

This means:
- if no order date is provided
- SQL automatically inserts today’s date

### Why DEFAULT is useful
It reduces repetitive typing and makes data more consistent.

Good examples:
- new status = `'New'`
- stock = `0`
- created date = current date
- is active = `1`

---

# 🔟 CHECK

A `CHECK` constraint enforces a logical condition.

Example:

```sql
Price DECIMAL(10,2) NOT NULL CHECK (Price > 0)
```

This means:
- price must always be greater than zero

So this fails:

```sql
INSERT INTO dbo.Products (ProductId, ProductName, Price, Stock)
VALUES (10, N'Broken Product', -50.00, 5);
```

Because the rule says `Price > 0`.

Other examples from the lab:

```sql
Stock INT NOT NULL DEFAULT 0 CHECK (Stock >= 0)
```

This prevents negative stock.

```sql
Quantity INT NOT NULL CHECK (Quantity > 0)
```

This prevents zero or negative quantity.

```sql
CHECK (OrderStatus IN ('New', 'Paid', 'Shipped', 'Cancelled'))
```

This restricts values to a controlled list.

### Why CHECK is powerful
It blocks impossible or nonsense data:
- negative price
- negative inventory
- zero quantity in an order
- invalid status like `'Flying'`

This makes reports and calculations much safer.

---

# 1️⃣1️⃣ Understanding the Lab Schema

Your lab creates four main tables:

- `Customers`
- `Products`
- `Orders`
- `OrderLines`

Let’s understand the logic.

---

## Customers

```sql
CREATE TABLE dbo.Customers (
    CustomerId INT PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    City NVARCHAR(50) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'New'
);
```

Meaning:
- every customer has a unique ID
- every customer must have a name
- every customer must have an email
- city is optional
- status becomes `'New'` automatically if omitted

---

## Products

```sql
CREATE TABLE dbo.Products (
    ProductId INT PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    Stock INT NOT NULL DEFAULT 0 CHECK (Stock >= 0),
    CreatedAt DATE NOT NULL DEFAULT GETDATE()
);
```

Meaning:
- each product has a unique ID
- name is required
- price must be positive
- stock starts at 0 if missing
- stock cannot be negative
- created date becomes today by default

This is a very good beginner-friendly table because it combines:
- PK
- NOT NULL
- DEFAULT
- CHECK

in one place.

---

## Orders

```sql
CREATE TABLE dbo.Orders (
    OrderId INT PRIMARY KEY,
    CustomerId INT NOT NULL,
    OrderDate DATE NOT NULL DEFAULT GETDATE(),
    OrderStatus NVARCHAR(20) NOT NULL DEFAULT 'New'
        CHECK (OrderStatus IN ('New', 'Paid', 'Shipped', 'Cancelled')),
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerId)
        REFERENCES dbo.Customers(CustomerId)
);
```

Meaning:
- each order has a unique ID
- every order must belong to a customer
- if the date is omitted, today is used
- order status defaults to `'New'`
- only allowed statuses can be inserted
- customer must exist first

This is a classic parent-child relationship:
- parent = `Customers`
- child = `Orders`

---

## OrderLines

```sql
CREATE TABLE dbo.OrderLines (
    OrderLineId INT PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice > 0),
    CONSTRAINT FK_OrderLines_Orders
        FOREIGN KEY (OrderId)
        REFERENCES dbo.Orders(OrderId),
    CONSTRAINT FK_OrderLines_Products
        FOREIGN KEY (ProductId)
        REFERENCES dbo.Products(ProductId)
);
```

This table connects:
- one order
- one product
- one quantity
- one unit price

Meaning:
- each line belongs to a real order
- each line points to a real product
- quantity must be positive
- price must be positive

This is how real commerce systems usually work.

One order can have many order lines.

---

# 1️⃣2️⃣ Reading the Insert Examples

The lab also teaches by inserting valid data.

Example:

```sql
INSERT INTO dbo.Customers (CustomerId, FullName, Email, City)
VALUES
(1, N'Alice Johnson', 'alice@example.com', N'New York'),
(2, N'Bob Smith', 'bob@example.com', N'Chicago'),
(3, N'Мария Иванова', 'maria@example.com', N'Warsaw');
```

Why is this useful?

Because it shows:
- `NVARCHAR` handles multilingual names
- realistic customer data
- the schema works correctly

Then products are inserted with positive price and stock.
Then orders are inserted only for real customers.
Then order lines are inserted only for real orders and products.

So the data follows all rules successfully.

---

# 1️⃣3️⃣ Default Values in Action

The lab demonstrates how `DEFAULT` works.

Example:

```sql
INSERT INTO dbo.Customers (CustomerId, FullName, Email, City)
VALUES (4, N'Diana Miller', 'diana@example.com', N'Seattle');
```

No `Status` is provided.

But the row still works because:

```sql
Status NVARCHAR(20) NOT NULL DEFAULT 'New'
```

SQL automatically inserts:

```sql
'New'
```

Same for orders:

```sql
INSERT INTO dbo.Orders (OrderId, CustomerId)
VALUES (1003, 4);
```

No `OrderDate` and no `OrderStatus` were provided.

SQL fills them automatically using:
- `GETDATE()` for `OrderDate`
- `'New'` for `OrderStatus`

This is a great example of how database design can reduce repetitive work.

---

# 1️⃣4️⃣ Error Demos — Why Good Constraints Matter

The lab includes commented-out error demos.
These are extremely important because students often learn faster from **bad inserts that fail**.

---

## Duplicate PK

```sql
-- INSERT INTO dbo.Customers (CustomerId, FullName, Email)
-- VALUES (1, N'Another Alice', 'another@example.com');
```

Fails because `CustomerId = 1` already exists.

---

## Negative Price

```sql
-- INSERT INTO dbo.Products (ProductId, ProductName, Price, Stock)
-- VALUES (10, N'Broken Product', -50.00, 5);
```

Fails because of:

```sql
CHECK (Price > 0)
```

---

## Negative Stock

```sql
-- INSERT INTO dbo.Products (ProductId, ProductName, Price, Stock)
-- VALUES (11, N'Strange Product', 99.00, -1);
```

Fails because of:

```sql
CHECK (Stock >= 0)
```

---

## FK Violation: Missing Customer

```sql
-- INSERT INTO dbo.Orders (OrderId, CustomerId)
-- VALUES (2001, 999);
```

Fails because customer `999` does not exist.

---

## FK Violation: Missing Product

```sql
-- INSERT INTO dbo.OrderLines (OrderLineId, OrderId, ProductId, Quantity, UnitPrice)
-- VALUES (10, 1001, 999, 1, 10.00);
```

Fails because product `999` does not exist.

---

## Invalid Status

```sql
-- INSERT INTO dbo.Orders (OrderId, CustomerId, OrderStatus)
-- VALUES (2002, 1, 'Unknown');
```

Fails because `Unknown` is not in the allowed list.

---

## Invalid Quantity

```sql
-- INSERT INTO dbo.OrderLines (OrderLineId, OrderId, ProductId, Quantity, UnitPrice)
-- VALUES (11, 1001, 1, 0, 1200.00);
```

Fails because quantity must be greater than zero.

---

# 1️⃣5️⃣ Why This Lesson Matters in Real Life

Many beginners think SQL is only about querying existing tables.

But in real projects, someone has to decide:

- what tables should exist
- what columns should exist
- what data types should be used
- what values should be blocked
- how tables should be connected

That is database design.

If the design is weak:
- bad data enters the system
- reports become unreliable
- applications break
- business logic becomes messy

If the design is strong:
- invalid data is blocked immediately
- relationships stay clean
- defaults reduce missing values
- checks keep data logical

So DDL is not “boring setup.”
It is the **foundation of everything else**.

---

# 1️⃣6️⃣ Best Practices for Beginners

Here are a few habits worth building early:

## Use `INT` for IDs
Simple and standard.

## Use `DECIMAL` for money
Not `FLOAT`.

## Use `NVARCHAR` for names and cities
Especially if multilingual text is possible.

## Use `VARCHAR` for email and technical strings
Usually enough.

## Add `NOT NULL` where data is required
Do not leave everything optional.

## Add `CHECK` for obvious business rules
Examples:
- price > 0
- quantity > 0
- stock >= 0
- rating between 1 and 5

## Add `DEFAULT` for common values
Examples:
- status = `'New'`
- stock = 0
- date = today

## Use `FOREIGN KEY` for relationships
Do not trust application code alone.

---

# 1️⃣7️⃣ Summary

DDL is how we create the structure of a database.

In this lesson you learned how to:

- create a database with `CREATE DATABASE`
- create tables with `CREATE TABLE`
- choose appropriate data types
- understand the difference between `VARCHAR` and `NVARCHAR`
- use `PRIMARY KEY` to make rows unique
- use `FOREIGN KEY` to protect relationships
- use `DEFAULT` to auto-fill common values
- use `CHECK` to enforce business rules

This is how professional databases are built:
not just with columns, but with **rules**.

---

# 🧠 Final Mental Model

Think of the database as a city:

- `CREATE DATABASE` builds the land
- `CREATE TABLE` builds the houses
- data types decide what each room is for
- `PRIMARY KEY` gives every house an address
- `FOREIGN KEY` creates roads between houses
- `DEFAULT` gives standard starting furniture
- `CHECK` stops impossible things from entering

That is why this lesson is called:

**DDL — Creating the World**
