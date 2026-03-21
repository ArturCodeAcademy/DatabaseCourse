# Homework — University Exam Grades Database (SQL Server)

## 🎯 Goal
Design a small **relational database** for a university exam grading system, **build it in SQL Server**, **fill it with data**, and then write a set of **useful + interesting queries** (with and without aggregation).

> Deliverable: one `.sql` file that contains:
> 1) your DDL (CREATE TABLE + constraints),
> 2) your inserts (data),
> 3) your solutions to the query tasks (each task clearly labeled).

---

## ✅ Business story (what we are modeling)
A university has:
- **Students**
- **Subjects**
- **Semesters**
- **Exam results** (a student receives a grade for a subject in a semester)
- Students may have **multiple attempts** (retakes) for the same subject in the same semester.

We want to answer questions like:
- Who are the top students this semester?
- Which subjects are the hardest (lowest average, highest fail rate)?
- Who failed too many exams?
- Who needed the most retakes?

---

# Part 1 — Design the database (DDL)

## 1) Create a database
Create a database named:

- `UniversityGrades`

---

## 2) Tables you must create (minimum required)

### A) `dbo.Students`
Required columns:
- `StudentId` (INT IDENTITY, Primary Key)
- `StudentNumber` (NVARCHAR(20), UNIQUE, NOT NULL) — like “S2025-0001”
- `FirstName` (NVARCHAR(50), NOT NULL)
- `LastName` (NVARCHAR(50), NOT NULL)
- `Major` (NVARCHAR(80), NOT NULL)
- `EnrollmentYear` (INT, NOT NULL, CHECK: >= 2000 and <= current year)

**Recommended:**
- `BirthDate` (DATE, NULL)

---

### B) `dbo.Subjects`
Required columns:
- `SubjectId` (INT IDENTITY, Primary Key)
- `SubjectCode` (NVARCHAR(20), UNIQUE, NOT NULL) — like “CS101”
- `SubjectName` (NVARCHAR(100), NOT NULL)
- `Credits` (TINYINT, NOT NULL, CHECK: between 1 and 15)

---

### C) `dbo.Semesters`
Required columns:
- `SemesterId` (INT IDENTITY, Primary Key)
- `AcademicYear` (INT, NOT NULL, CHECK: >= 2000 and <= current year)
- `Term` (TINYINT, NOT NULL, CHECK: Term IN (1,2)) — 1 = Fall, 2 = Spring (or vice versa, your choice)
- `StartDate` (DATE, NOT NULL)
- `EndDate` (DATE, NOT NULL)

Rules:
- `(AcademicYear, Term)` must be UNIQUE
- `StartDate < EndDate`

---

### D) `dbo.ExamResults`
This is the main fact table.

Required columns:
- `ExamResultId` (INT IDENTITY, Primary Key)
- `StudentId` (INT, NOT NULL, FK -> dbo.Students)
- `SubjectId` (INT, NOT NULL, FK -> dbo.Subjects)
- `SemesterId` (INT, NOT NULL, FK -> dbo.Semesters)
- `AttemptNo` (TINYINT, NOT NULL, DEFAULT 1, CHECK: >= 1 and <= 5)
- `ExamDate` (DATE, NOT NULL)
- `Grade` (INT, NOT NULL, CHECK: between 0 and 100)

Rules:
- A student can have multiple attempts, but each attempt must be unique:
  - UNIQUE (`StudentId`, `SubjectId`, `SemesterId`, `AttemptNo`)

Optional (recommended):
- A computed column `IsPassed`:
  - Passed if Grade >= 50 (or your own threshold)
- Or store `IsPassed` as BIT and enforce consistency yourself.

---

## 3) Constraint requirements (must have)
- Primary Keys on every table
- Foreign Keys in `ExamResults`
- CHECK constraints for:
  - `Grade` range
  - `Credits` range
  - `AttemptNo` range
  - `Term` allowed values
  - `StartDate < EndDate`
- UNIQUE constraints:
  - `Students.StudentNumber`
  - `Subjects.SubjectCode`
  - `Semesters (AcademicYear, Term)`
  - `ExamResults (StudentId, SubjectId, SemesterId, AttemptNo)`

---

# Part 2 — Fill the database with data (INSERT)

## Data requirements (minimum)
Insert at least:
- **15 students**
- **10 subjects**
- **4 semesters** (2 academic years × 2 terms)
- **200 exam result rows** in `ExamResults`

Rules for realism:
- At least **30%** of students should have **at least one retake** (`AttemptNo > 1`)
- At least **10%** of all exam results should be **fails** (Grade < 50)
- At least **5%** should be very high (Grade >= 90)

✅ Tip: use multi-row INSERT for speed.

---

# Part 3 — Query tasks (write SQL)

**Important rules for queries**
- Every task must be labeled in your `.sql` file:
  - `-- Task 1`, `-- Task 2`, etc.
- Use readable formatting.
- Prefer explicit column lists (avoid `SELECT *` in final answers).

---

## Section A — Basic SELECT (no aggregation)
### Task 1
List all students (StudentNumber, FullName, Major) sorted by LastName then FirstName.

### Task 2
Show all exam results for a specific student number (e.g., `S2025-0001`):
- Semester (AcademicYear, Term)
- SubjectCode, SubjectName
- AttemptNo, ExamDate, Grade
Sorted by semester, then subject, then attempt.

### Task 3
Show all failed exams (Grade < 50) in a chosen semester (pick one AcademicYear+Term).

### Task 4
Find students who had **any retake** (AttemptNo > 1). Return StudentNumber + FullName.

### Task 5
Find all exam results where a student passed only on a retake:
- attempt 1 failed (<50)
- attempt 2 (or later) passed (>=50)
Return StudentNumber, SubjectCode, Semester, AttemptNo, Grade.

### Task 6
Return all subjects that had **at least one fail** in the entire dataset.

---

## Section B — Aggregation (GROUP BY / HAVING)
### Task 7
Average grade per subject (SubjectCode, SubjectName, AvgGrade) across all semesters.

### Task 8
Fail rate per subject:
- TotalAttempts
- FailAttempts (Grade < 50)
- FailRatePercent (FailAttempts * 100.0 / TotalAttempts)

### Task 9
Average grade per student per semester:
- StudentNumber, FullName
- AcademicYear, Term
- AvgGrade

### Task 10
Top 5 students in a chosen semester by average grade (min 4 exams in that semester).
Return StudentNumber, FullName, ExamsCount, AvgGrade.

### Task 11
Subjects with average grade below 60 **and** at least 20 attempts (HAVING).

### Task 12
Students who failed **2 or more distinct subjects** in a chosen semester.

---

## Section C — “Interesting” queries (mix)
### Task 13
For each student and subject, return the **best grade** (MAX Grade) across attempts within the same semester.

### Task 14
Hardest subject per semester:
For each semester, find the subject with the **lowest average grade** (min 10 attempts).

### Task 15
Retake leaderboard:
Students ranked by total number of retake attempts (AttemptNo > 1), descending.
Return StudentNumber, FullName, RetakeCount.

### Task 16
Show students who improved:
Pick two consecutive semesters and find students whose average grade increased by **>= 10 points**.

> Hint: compute avg per student per semester, then join semesters or use a CTE.

---

## Section D — Bonus (optional, for extra points)
### Bonus 1
Create a `VIEW` named `vw_ExamResultsDetailed` that shows:
StudentNumber, FullName, Major, SubjectCode, SubjectName, AcademicYear, Term, AttemptNo, ExamDate, Grade.

### Bonus 2
Create a stored procedure `sp_AddExamResult` that inserts one exam result and validates:
- AttemptNo not duplicated,
- Grade 0..100,
- FK existence.
(You can start simple.)

### Bonus 3
Make a “Dean’s List” query:
Students with AvgGrade >= 85 in a semester **and** zero fails in that semester.

---

# Part 4 — Submission checklist
Before you submit, confirm:
- [ ] All tables created with correct constraints
- [ ] Data requirements met (counts + retake/fail ratios)
- [ ] All tasks answered with SQL
- [ ] Queries run without errors
- [ ] The script can be executed from top to bottom on a clean DB

---

# Starter skeleton (copy into your .sql file)

```sql
-- =========================================
-- Homework: UniversityGrades
-- =========================================

-- 0) Create DB
-- CREATE DATABASE UniversityGrades;
-- GO
-- USE UniversityGrades;
-- GO

-- 1) DDL: create tables here

-- 2) INSERT: seed data here

-- 3) Tasks:
-- Task 1:
-- SELECT ...

```
