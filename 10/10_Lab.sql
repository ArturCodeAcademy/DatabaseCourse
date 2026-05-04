/*
============================================================
10_Lab.sql — Lesson 10: Transactions + Rollback + Blocking
============================================================

This lab is self-contained:
1) Creates a sandbox database (SqlCourse) if missing
2) Creates small tables for transaction demos:
   - BankAccounts (transfer demo)
   - LockDemo (blocking demo)
3) Demonstrates:
   - BEGIN TRAN / COMMIT / ROLLBACK
   - Failure simulation with TRY/CATCH + rollback
   - Blocking demo with two sessions (A and B)

Run section by section.

*/

------------------------------------------------------------
-- 0) Create and use sandbox DB
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
IF OBJECT_ID('dbo.BankAccounts', 'U') IS NOT NULL DROP TABLE dbo.BankAccounts;
IF OBJECT_ID('dbo.LockDemo', 'U') IS NOT NULL DROP TABLE dbo.LockDemo;
GO

CREATE TABLE dbo.BankAccounts
(
    AccountId   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_BankAccounts PRIMARY KEY,
    AccountName NVARCHAR(50) NOT NULL,
    Balance     DECIMAL(12,2) NOT NULL CONSTRAINT CK_BankAccounts_Balance CHECK (Balance >= 0),
    UpdatedAt   DATETIME2(0) NOT NULL CONSTRAINT DF_BankAccounts_UpdatedAt DEFAULT (SYSDATETIME())
);
GO

CREATE TABLE dbo.LockDemo
(
    RowId     INT NOT NULL CONSTRAINT PK_LockDemo PRIMARY KEY,
    ValueText NVARCHAR(100) NOT NULL
);
GO

------------------------------------------------------------
-- 2) Seed data
------------------------------------------------------------
INSERT INTO dbo.BankAccounts (AccountName, Balance)
VALUES
(N'Checking',  500.00),
(N'Savings',  1200.00),
(N'Business',  300.00);
GO

INSERT INTO dbo.LockDemo (RowId, ValueText)
VALUES (1, N'Original value');
GO

------------------------------------------------------------
-- 3) Preview
------------------------------------------------------------
SELECT * FROM dbo.BankAccounts ORDER BY AccountId;
SELECT * FROM dbo.LockDemo;
GO

------------------------------------------------------------
-- 4) BEGIN TRAN / ROLLBACK demo (safe practice)
------------------------------------------------------------

/*
Goal: update one row inside a transaction, verify, then ROLLBACK.
*/

BEGIN TRAN;

    UPDATE dbo.BankAccounts
    SET Balance = Balance + 100,
        UpdatedAt = SYSDATETIME()
    WHERE AccountName = N'Checking';

    SELECT @@ROWCOUNT AS RowsUpdated;

    -- Verify the temporary change (still not committed)
    SELECT * FROM dbo.BankAccounts WHERE AccountName = N'Checking';

ROLLBACK;

-- Confirm value returned back
SELECT * FROM dbo.BankAccounts WHERE AccountName = N'Checking';
GO

------------------------------------------------------------
-- 5) BEGIN TRAN / COMMIT demo
------------------------------------------------------------

BEGIN TRAN;

    UPDATE dbo.BankAccounts
    SET Balance = Balance - 50,
        UpdatedAt = SYSDATETIME()
    WHERE AccountName = N'Savings';

    SELECT @@ROWCOUNT AS RowsUpdated;
    SELECT * FROM dbo.BankAccounts WHERE AccountName = N'Savings';

COMMIT;

-- Confirm the change persisted
SELECT * FROM dbo.BankAccounts WHERE AccountName = N'Savings';
GO

------------------------------------------------------------
-- 6) Failure simulation (TRY/CATCH) — rollback everything on error
------------------------------------------------------------

/*
Scenario: transfer money from Savings -> Business
- Subtract 200 from Savings
- Add 200 to Business
Then we simulate a failure (THROW) to prove rollback works.

After the script, balances must remain unchanged.
*/

DECLARE @FromAccount NVARCHAR(50) = N'Savings';
DECLARE @ToAccount   NVARCHAR(50) = N'Business';
DECLARE @Amount      DECIMAL(12,2) = 200.00;

-- Snapshot balances BEFORE
SELECT * FROM dbo.BankAccounts WHERE AccountName IN (@FromAccount, @ToAccount) ORDER BY AccountId;
GO

BEGIN TRY
    BEGIN TRAN;

        -- Step 1: subtract
        UPDATE dbo.BankAccounts
        SET Balance = Balance - @Amount,
            UpdatedAt = SYSDATETIME()
        WHERE AccountName = @FromAccount;

        IF @@ROWCOUNT <> 1
            THROW 50001, 'FromAccount not found.', 1;

        -- Optional validation: prevent negative balance
        IF EXISTS (
            SELECT 1
            FROM dbo.BankAccounts
            WHERE AccountName = @FromAccount AND Balance < 0
        )
            THROW 50002, 'Insufficient funds.', 1;

        -- Step 2: add
        UPDATE dbo.BankAccounts
        SET Balance = Balance + @Amount,
            UpdatedAt = SYSDATETIME()
        WHERE AccountName = @ToAccount;

        IF @@ROWCOUNT <> 1
            THROW 50003, 'ToAccount not found.', 1;

        -- Step 3: simulate a crash/failure
        THROW 50010, 'Simulated failure after updates. Transaction should roll back.', 1;

        COMMIT; -- not reached

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;

    -- Show the error
    SELECT
        ERROR_NUMBER()  AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Snapshot balances AFTER (must match the BEFORE snapshot)
SELECT * FROM dbo.BankAccounts WHERE AccountName IN (N'Savings', N'Business') ORDER BY AccountId;
GO

------------------------------------------------------------
-- 7) Blocking demo (two sessions)
------------------------------------------------------------

/*
============================================================
BLOCKING DEMO INSTRUCTIONS
============================================================

Open TWO query windows (two sessions) in VS Code / ADS.

-------------------------
SESSION A (locker)
-------------------------
1) Run the Session A block below.
2) IMPORTANT: Do NOT COMMIT or ROLLBACK until you run Session B.
   While the transaction is open, the row is locked.

-------------------------
SESSION B (reader)
-------------------------
1) Run the Session B block in the second window.
2) The SELECT will WAIT (appear to “hang”) because Session A holds an X lock.
3) Then go back to Session A and COMMIT or ROLLBACK.
4) Session B will instantly finish.

If you do NOT see blocking, use the SERIALIZABLE line in Session B (it forces locking reads).

============================================================
*/

-- =========================
-- SESSION A (run in Window A)
-- =========================
/*
BEGIN TRAN;

    UPDATE dbo.LockDemo
    SET ValueText = N'Locked by Session A (not committed yet)'
    WHERE RowId = 1;

    -- Keep the transaction open so locks are held
    -- (Now switch to Session B and run its SELECT)
    SELECT 'Session A has updated the row and is holding locks...' AS Info;

-- After testing Session B, choose ONE:
-- COMMIT;
-- ROLLBACK;
*/

-- =========================
-- SESSION B (run in Window B)
-- =========================
/*
-- Optionally force locking reads even if row-versioning is enabled:
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- To avoid waiting forever, you can set a timeout (milliseconds):
-- SET LOCK_TIMEOUT 5000;  -- 5 seconds

SELECT RowId, ValueText
FROM dbo.LockDemo
WHERE RowId = 1;

-- If you set LOCK_TIMEOUT and it times out, you will see an error instead of waiting.
*/

------------------------------------------------------------
-- 8) YOUR TURN — Practice
------------------------------------------------------------

/*
A) Basics
1) Do an UPDATE in a transaction, verify with SELECT, then ROLLBACK.
2) Repeat but COMMIT.

B) Failure simulation
3) Change @Amount to a value that causes insufficient funds and confirm rollback happens.
4) Remove the simulated THROW and confirm COMMIT persists (optional challenge: implement success path).

C) Blocking
5) Repeat the blocking demo and test:
   - with LOCK_TIMEOUT (e.g., 2000 ms)
   - without LOCK_TIMEOUT (waits until Session A commits)
*/

