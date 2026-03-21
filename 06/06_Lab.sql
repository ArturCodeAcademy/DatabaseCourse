/*
============================================================
06_Lab.sql — Lesson 6: DML (INSERT, UPDATE, DELETE, TRUNCATE, Soft Delete)
============================================================

This lab is self-contained:
1) Creates a sandbox database (SqlCourse) if missing
2) Creates dbo.Users (supports Soft Delete)
3) Inserts sample data
4) Demonstrates:
   - INSERT (single and multi-row)
   - UPDATE (safe patterns + a safe demo of “UPDATE without WHERE” inside a rollback)
   - DELETE
   - TRUNCATE vs DELETE (identity reset demo)
   - Soft Delete (IsDeleted flag)

Run section by section.
*/

------------------------------------------------------------
-- 0) Create and use a sandbox database
------------------------------------------------------------
IF DB_ID('SqlCourse') IS NULL
BEGIN
    CREATE DATABASE SqlCourse;
END
GO

USE SqlCourse;
GO

------------------------------------------------------------
-- 1) Recreate tables (safe to rerun)
------------------------------------------------------------

-- Main table for DML practice
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL
    DROP TABLE dbo.Users;
GO

CREATE TABLE dbo.Users
(
    UserId     INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Users PRIMARY KEY,

    Email      NVARCHAR(100) NOT NULL,
    FullName   NVARCHAR(100) NOT NULL,
    City       NVARCHAR(50)  NOT NULL,

    -- Soft delete fields
    IsDeleted  BIT NOT NULL
        CONSTRAINT DF_Users_IsDeleted DEFAULT (0),
    DeletedAt  DATETIME2(0) NULL,

    CreatedAt  DATETIME2(0) NOT NULL
        CONSTRAINT DF_Users_CreatedAt DEFAULT (SYSDATETIME())
);

-- Optional: keep Email unique (common real-world rule)
-- (Comment out if you want to allow duplicates for exercises.)
ALTER TABLE dbo.Users
ADD CONSTRAINT UQ_Users_Email UNIQUE (Email);
GO

-- Separate table for TRUNCATE/DELETE identity demo
IF OBJECT_ID('dbo.TempEvents', 'U') IS NOT NULL
    DROP TABLE dbo.TempEvents;
GO

CREATE TABLE dbo.TempEvents
(
    EventId   INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_TempEvents PRIMARY KEY,
    EventName NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME2(0) NOT NULL
        CONSTRAINT DF_TempEvents_CreatedAt DEFAULT (SYSDATETIME())
);
GO

------------------------------------------------------------
-- 2) Seed data (Users)
------------------------------------------------------------
INSERT INTO dbo.Users (Email, FullName, City)
VALUES
(N'john.parker@example.com',   N'John Parker',   N'New York'),
(N'emily.johnson@example.com', N'Emily Johnson', N'Chicago'),
(N'michael.turner@example.com',N'Michael Turner',N'Austin'),
(N'sarah.collins@example.com', N'Sarah Collins', N'Seattle'),
(N'daniel.reed@example.com',   N'Daniel Reed',   N'Boston'),
(N'olivia.bennett@example.com',N'Olivia Bennett',N'Boston'),
(N'ethan.murphy@example.com',  N'Ethan Murphy',  N'Denver'),
(N'madison.hughes@example.com',N'Madison Hughes',N'Miami');
GO

------------------------------------------------------------
-- 3) Preview current data
------------------------------------------------------------
SELECT UserId, Email, FullName, City, IsDeleted, DeletedAt, CreatedAt
FROM dbo.Users
ORDER BY UserId;
GO

------------------------------------------------------------
-- 4) INSERT examples
------------------------------------------------------------

-- 4.1 Insert a single row
INSERT INTO dbo.Users (Email, FullName, City)
VALUES (N'amy.adams@example.com', N'Amy Adams', N'Boston');
SELECT @@ROWCOUNT AS RowsInserted;
GO

-- 4.2 Insert multiple rows in one statement (bulk-style)
INSERT INTO dbo.Users (Email, FullName, City)
VALUES
  (N'mike.stone@example.com', N'Mike Stone', N'Chicago'),
  (N'sara.kim@example.com',   N'Sara Kim',   N'Austin'),
  (N'leo.harris@example.com', N'Leo Harris', N'Denver');
SELECT @@ROWCOUNT AS RowsInserted;
GO

-- Preview after inserts
SELECT UserId, Email, FullName, City
FROM dbo.Users
ORDER BY UserId;
GO

------------------------------------------------------------
-- 5) UPDATE examples (SAFE patterns)
------------------------------------------------------------

-- 5.1 Update one row by UserId
UPDATE dbo.Users
SET City = N'San Diego'
WHERE UserId = 3;

SELECT @@ROWCOUNT AS RowsUpdated;
GO

-- Verify
SELECT UserId, FullName, City
FROM dbo.Users
WHERE UserId = 3;
GO

-- 5.2 Update multiple rows by a filter
UPDATE dbo.Users
SET City = N'New York'
WHERE City = N'Boston';

SELECT @@ROWCOUNT AS RowsUpdated;
GO

-- Verify
SELECT UserId, FullName, City
FROM dbo.Users
WHERE City IN (N'New York', N'Boston')
ORDER BY UserId;
GO

------------------------------------------------------------
-- 5.3 Safe demo: the “UPDATE without WHERE” disaster
-- We run it INSIDE a transaction and ROLLBACK so data stays safe.
------------------------------------------------------------
BEGIN TRAN;

    -- ⚠️ DO NOT DO THIS IN REAL LIFE:
    UPDATE dbo.Users
    SET City = N'Atlantis';

    SELECT @@ROWCOUNT AS RowsUpdated_NoWhere;

    -- Check the (temporary) damage:
    SELECT TOP (5) UserId, FullName, City
    FROM dbo.Users
    ORDER BY UserId;

ROLLBACK;  -- Undo everything in this transaction
GO

-- Confirm rollback worked (cities should be normal)
SELECT TOP (10) UserId, FullName, City
FROM dbo.Users
ORDER BY UserId;
GO

------------------------------------------------------------
-- 6) DELETE examples
------------------------------------------------------------

-- 6.1 Delete by a condition (safe)
DELETE FROM dbo.Users
WHERE City = N'Miami';

SELECT @@ROWCOUNT AS RowsDeleted;
GO

-- Verify
SELECT UserId, FullName, City
FROM dbo.Users
ORDER BY UserId;
GO

-- 6.2 Delete exactly one row by UserId (safe)
DELETE FROM dbo.Users
WHERE UserId = 2;

SELECT @@ROWCOUNT AS RowsDeleted;
GO

-- Verify
SELECT UserId, FullName, City
FROM dbo.Users
ORDER BY UserId;
GO

------------------------------------------------------------
-- 7) DELETE vs TRUNCATE (identity behavior demo)
------------------------------------------------------------

-- 7.1 Insert 3 events
INSERT INTO dbo.TempEvents (EventName)
VALUES (N'Event A'), (N'Event B'), (N'Event C');

SELECT EventId, EventName
FROM dbo.TempEvents
ORDER BY EventId;
GO

-- 7.2 DELETE all rows (identity does NOT reset automatically)
DELETE FROM dbo.TempEvents;

-- Insert again and observe EventId continues from the last value
INSERT INTO dbo.TempEvents (EventName)
VALUES (N'Event D');

SELECT EventId, EventName
FROM dbo.TempEvents
ORDER BY EventId;
GO

-- 7.3 TRUNCATE all rows (identity resets)
TRUNCATE TABLE dbo.TempEvents;

-- Insert again and observe EventId starts from 1 again
INSERT INTO dbo.TempEvents (EventName)
VALUES (N'Event E');

SELECT EventId, EventName
FROM dbo.TempEvents
ORDER BY EventId;
GO

------------------------------------------------------------
-- 8) Soft Delete (IsDeleted)
------------------------------------------------------------

-- 8.1 Soft delete a user (mark as deleted, keep the row)
UPDATE dbo.Users
SET IsDeleted = 1,
    DeletedAt = SYSDATETIME()
WHERE UserId = 1;

SELECT @@ROWCOUNT AS RowsSoftDeleted;
GO

-- 8.2 Query only “active” users
SELECT UserId, Email, FullName, City
FROM dbo.Users
WHERE IsDeleted = 0
ORDER BY UserId;
GO

-- 8.3 Query deleted users
SELECT UserId, Email, FullName, City, IsDeleted, DeletedAt
FROM dbo.Users
WHERE IsDeleted = 1
ORDER BY UserId;
GO

-- 8.4 Restore a soft-deleted user
UPDATE dbo.Users
SET IsDeleted = 0,
    DeletedAt = NULL
WHERE UserId = 1;

SELECT @@ROWCOUNT AS RowsRestored;
GO

-- Verify restoration
SELECT UserId, Email, FullName, City, IsDeleted, DeletedAt
FROM dbo.Users
WHERE UserId = 1;
GO

------------------------------------------------------------
-- 9) YOUR TURN — Practice (write solutions below)
------------------------------------------------------------

/*
A) INSERT
1) Insert 1 new user (your own name/email).
2) Insert 3 users in a single statement (multi-row insert).
3) Try inserting a duplicate Email (should fail because of UQ_Users_Email). Explain why.

B) UPDATE (safe habits)
4) Update one user’s city by UserId.
5) Update all users in a specific city to a new city.
6) Write a SELECT first, then run the matching UPDATE.
7) Use @@ROWCOUNT to confirm how many rows you changed.

C) DELETE
8) Delete users from one city (use WHERE).
9) Delete exactly one user by UserId.
10) Explain why DELETE without WHERE is dangerous.

D) TRUNCATE
11) In dbo.TempEvents:
    - insert a few rows,
    - DELETE all rows,
    - insert again and observe identity values,
    - TRUNCATE the table,
    - insert again and observe identity reset.

E) Soft Delete
12) Soft-delete a user (IsDeleted = 1, DeletedAt = SYSDATETIME()).
13) Query only active users (IsDeleted = 0).
14) Restore the user (IsDeleted = 0, DeletedAt = NULL).
*/

-- Solutions area:

-- 1)
-- INSERT INTO ...

