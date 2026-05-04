# 10_Theory.md
# Lesson 10 — Transactions in SQL Server (BEGIN TRAN / COMMIT / ROLLBACK)

## 🎯 Goal
By the end of this lesson, you can:
- explain what a **transaction** is and why we need it,
- use `BEGIN TRAN`, `COMMIT`, and `ROLLBACK`,
- simulate a failure and safely undo changes,
- demonstrate **blocking** (locks) with two sessions: one holds a transaction, the other “hangs” on a read.

---

## 1) What is a transaction?
A **transaction** is a group of one or more SQL statements treated as a single unit:

- **COMMIT** → permanently save changes
- **ROLLBACK** → undo all changes made since the transaction started

Think: “all or nothing”.

### Why transactions exist (real life)
If an operation has multiple steps, you don’t want to end up in a half-finished state.

Example: transferring money:
1) subtract from Account A
2) add to Account B

If step 2 fails, step 1 must be undone → **rollback**.

---

## 2) Basic syntax

### Start / commit
```sql
BEGIN TRAN;

-- changes (INSERT/UPDATE/DELETE)

COMMIT;
```

### Start / rollback
```sql
BEGIN TRAN;

-- changes (INSERT/UPDATE/DELETE)

ROLLBACK;
```

---

## 3) What happens if you forget to COMMIT/ROLLBACK?
If you leave a transaction open:
- locks are held longer than needed,
- other sessions can get blocked,
- your application may “freeze” waiting for locks.

✅ Rule: never leave a transaction open longer than necessary.

---

## 4) Simulating failure (rollback changes)
Two common patterns:

### A) Manual rollback
You run changes, inspect them, then decide:
- `COMMIT` if correct
- `ROLLBACK` if wrong

### B) TRY/CATCH with rollback (safer)
Use `TRY...CATCH` to guarantee rollback on errors.

```sql
BEGIN TRY
    BEGIN TRAN;

    -- statements
    -- if something fails -> jumps to CATCH

    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;

    THROW; -- re-raise the error
END CATCH;
```

**Why this matters:** even if a statement fails in the middle, you won’t leave partial changes behind.

---

## 5) Locks and blocking (why “another student hangs”)
SQL Server uses locks to keep data consistent.

When a transaction updates a row:
- SQL Server takes an **exclusive lock** on that row (X lock),
- the lock is kept until COMMIT/ROLLBACK.

If another session tries to read the same row under locking isolation:
- it needs a **shared lock** (S lock),
- S lock is not compatible with X lock,
- so it **waits** → it “hangs”.

### Why you might not see blocking sometimes
If your database uses **row-versioning** (e.g., READ_COMMITTED_SNAPSHOT ON), some reads don’t block.
In the lab we include steps that still show blocking reliably (using a stricter isolation level).

---

## 6) Practical safety rules (must-have habits)
1) **Always test the WHERE clause with SELECT first**:
   - `SELECT ... WHERE ...`
   - then `UPDATE/DELETE ... WHERE ...`

2) Wrap risky changes in a transaction:
   - do the change
   - verify
   - commit

3) Use `@@ROWCOUNT` after UPDATE/DELETE:
   - confirms how many rows were affected

4) Keep transactions short:
   - do not “think” while holding locks

---

## ✅ Lesson summary
You can now:
- start transactions with `BEGIN TRAN`,
- finalize with `COMMIT` or undo with `ROLLBACK`,
- roll back safely on failure (TRY/CATCH),
- understand and demonstrate blocking caused by locks.

---

# 🧪 Practice Tasks (after running `10_Lab.sql`)

## A) Basics
1) Start a transaction, update one row, verify with SELECT, then ROLLBACK. Confirm the row returned to its original value.
2) Repeat #1 but COMMIT instead.

## B) Failure simulation
3) Run the TRY/CATCH demo and confirm that no partial changes remain after the error.

## C) Blocking (two sessions)
4) Open **two query windows**:
   - Session A: start a transaction and update the same row (keep transaction open).
   - Session B: try to read the same row and observe it waiting (“hang”).
5) In Session B set a lock timeout (e.g., 5 seconds) to see a timeout error instead of waiting forever.
