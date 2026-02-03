# Lesson 0: The Setup 🛠️

## 🎯 Goal
By the end of this guide, you will have a running SQL Server instance on your machine and a client (VS Code) connected to it.

---

## 1️⃣ Part 1: Prerequisites (Windows Only)
Check if your CPU supports virtualization.

1. Open **Task Manager** (Ctrl + Shift + Esc).
2. Go to the **Performance** tab -> **CPU**.
3. Look for **"Virtualization"** in the bottom right.
   - ✅ It must say **Enabled**.
   - ❌ If **Disabled**: Restart PC, enter BIOS/UEFI, and enable "Intel VT-x" or "AMD-V".

---

## 2️⃣ Part 2: Install Docker Desktop
Docker allows us to run SQL Server in a "container" without heavy installation.

1. Download **Docker Desktop** from [docker.com](https://www.docker.com/).
2. Install and run it.
3. **Verification**: You should see the whale icon in your system tray.

---

## 3️⃣ Part 3: Start SQL Server
Run the command matching your processor in your terminal (PowerShell/Terminal).

### 💻 For Windows, Linux, and Intel Macs
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=MyStrongPassword123!" -p 1433:1433 --name sql_course_db -d mcr.microsoft.com/mssql/server:2022-latest

### 🍎 For Mac with Apple Silicon (M1, M2, M3)
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=MyStrongPassword123!" -p 1433:1433 --name sql_course_db -d mcr.microsoft.com/azure-sql-edge

### 🛠️ Common Docker Commands
* **Check status:** `docker ps`
* **Stop server:** `docker stop sql_course_db`
* **Start again:** `docker start sql_course_db`
* **Remove container:** `docker rm --force sql_course_db`

---

## 4️⃣ Part 4: Connect with VS Code
1. Install the **SQL Server (mssql)** extension in VS Code.
2. Click the **SQL Server icon** on the left bar.
3. Click **Add Connection (+)**:
   - **Hostname:** `localhost`
   - **Database:** (Leave empty)
   - **Auth Type:** `SQL Login`
   - **Username:** `sa`
   - **Password:** `MyStrongPassword123!`
   - **Trust Certificate:** `Yes`

**Verification:** Create `test.sql` and run:
```sql
SELECT @@VERSION;