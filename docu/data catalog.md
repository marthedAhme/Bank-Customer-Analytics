# 🏦 Bank Customer Analytics — Data Catalog

> A large-scale SQL Server project simulating a real-world banking environment with **12.8 million rows** of transactional data, built entirely using advanced T-SQL techniques.

---

## 📌 Project Overview

| Property | Details |
|----------|---------|
| **Database** | SQL Server 2016+ |
| **Language** | T-SQL |
| **Total Rows** | ~12,800,005 |
| **Domain** | Banking & Financial Analytics |
| **Purpose** | Portfolio project demonstrating large-scale data engineering and advanced SQL analytics |

---

## 🗂️ Database Schema

```
BankAnalytics
│
├── Customers       (1,000,000 rows)
├── Branches        (5 rows)
├── Accounts        (1,500,000 rows)  ──► FK → Customers, Branches
├── Transactions    (10,000,000 rows) ──► FK → Accounts
└── Loans           (300,000 rows)    ──► FK → Customers
```

---

## 📋 Table Definitions

### 1. `Customers`
Stores core profile data for each bank customer.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `customer_id` | INT | PK, IDENTITY(1,1) | Auto-generated unique customer ID |
| `full_name` | NVARCHAR(100) | NOT NULL | Customer's full name |
| `age` | INT | CHECK (18–90) | Customer age |
| `gender` | CHAR(1) | CHECK ('M','F') | M = Male, F = Female |
| `city` | NVARCHAR(50) | — | City of residence |
| `join_date` | DATE | DEFAULT GETDATE() | Date customer joined the bank |

**Sample Data:**
```sql
customer_id | full_name             | age | gender | city      | join_date
------------+-----------------------+-----+--------+-----------+----------
1           | Ahmed Al Mansouri     | 34  | M      | Dubai     | 2021-03-15
2           | Fatima Al Zaabi       | 27  | F      | Abu Dhabi | 2019-08-22
3           | Khalid Al Rashid      | 51  | M      | Sharjah   | 2017-11-01
```

---

### 2. `Branches`
Stores physical bank branch locations across the UAE.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `branch_id` | INT | PK, IDENTITY(1,1) | Auto-generated branch ID |
| `branch_name` | NVARCHAR(100) | NOT NULL | Name of the branch |
| `city` | NVARCHAR(50) | — | City where branch is located |

**All 5 Branches:**
```sql
branch_id | branch_name                | city
----------+----------------------------+---------
1         | Dubai Main Branch          | Dubai
2         | Abu Dhabi Central          | Abu Dhabi
3         | Sharjah Downtown           | Sharjah
4         | Ajman Branch               | Ajman
5         | Ras Al Khaimah Branch      | RAK
```

---

### 3. `Accounts`
Each customer can hold multiple accounts across different branches.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `account_id` | INT | PK, IDENTITY(1,1) | Auto-generated account ID |
| `customer_id` | INT | FK → Customers, NOT NULL | Owning customer |
| `branch_id` | INT | FK → Branches, NOT NULL | Branch where account was opened |
| `account_type` | NVARCHAR(20) | CHECK ('Savings','Current','Fixed') | Type of account |
| `balance` | DECIMAL(15,2) | DEFAULT 0 | Current account balance (AED) |
| `open_date` | DATE | DEFAULT GETDATE() | Account opening date |

**Balance Distribution:**
| Segment | Condition | Approximate % |
|---------|-----------|---------------|
| High Value | AED 100,000 – 1,000,000 | 10% |
| Mid Value | AED 10,000 – 100,000 | 30% |
| Standard | AED 500 – 10,000 | 60% |

---

### 4. `Transactions`
Records every financial movement across all accounts — the largest table at 10 million rows.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `transaction_id` | INT | PK, IDENTITY(1,1) | Auto-generated transaction ID |
| `account_id` | INT | FK → Accounts, NOT NULL | Account involved |
| `amount` | DECIMAL(15,2) | NOT NULL | Transaction amount (AED) |
| `trans_type` | NVARCHAR(20) | CHECK ('Deposit','Withdrawal','Transfer') | Type of transaction |
| `transaction_date` | DATETIME | DEFAULT GETDATE() | Date and time of transaction |

**Amount Ranges by Type:**
| Transaction Type | Amount Range (AED) |
|-----------------|-------------------|
| Deposit | 100 – 50,000 |
| Withdrawal | 50 – 10,000 |
| Transfer | 1,000 – 100,000 |

**Date Coverage:** Transactions span **5 years** back from the current date.

---

### 5. `Loans`
Tracks loan details and repayment status per customer.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `loan_id` | INT | PK, IDENTITY(1,1) | Auto-generated loan ID |
| `customer_id` | INT | FK → Customers, NOT NULL | Borrowing customer |
| `loan_amount` | DECIMAL(15,2) | NOT NULL | Total loan value (AED) |
| `interest_rate` | DECIMAL(5,2) | — | Annual interest rate (%) |
| `start_date` | DATE | — | Loan start date |
| `due_date` | DATE | — | Loan repayment due date |
| `status` | NVARCHAR(20) | CHECK ('Active','Paid','Overdue') | Current loan status |

**Loan Status Distribution:**
| Status | Share |
|--------|-------|
| Active | ~33% |
| Paid | ~33% |
| Overdue | ~33% |

**Loan Amount Range:** AED 5,000 – 1,000,000  
**Interest Rate Range:** 1.5% – 6.5% annually

---

## 🔗 Entity Relationship Diagram

```
Customers ──────────────────────────────────────────┐
    │                                                │
    │ 1:N                                            │ 1:N
    ▼                                                ▼
Accounts ──── N:1 ──── Branches              Loans
    │
    │ 1:N
    ▼
Transactions
```

---

## ⚡ Performance & Indexing

Five covering indexes were created after data generation to ensure fast query response on large tables:

| Index Name | Table | Columns | Includes |
|-----------|-------|---------|---------|
| `IX_Transactions_AccountId_Date` | Transactions | account_id, transaction_date | amount, trans_type |
| `IX_Transactions_Date` | Transactions | transaction_date | amount, trans_type, account_id |
| `IX_Accounts_CustomerId` | Accounts | customer_id | balance, account_type, branch_id |
| `IX_Loans_Status` | Loans | status | customer_id, loan_amount, due_date |
| `IX_Customers_City` | Customers | city | full_name, age, gender, join_date |

---

## 📊 Analytics Performed

| # | Analysis | SQL Technique |
|---|----------|--------------|
| 1 | Top 10 customers by balance | `RANK()` Window Function |
| 2 | Transaction volume per branch | Multi-table `JOIN` + `GROUP BY` |
| 3 | Monthly trend + running total | `SUM OVER()` + `LAG()` |
| 4 | Overdue loans + risk classification | `CASE WHEN` scoring |
| 5 | City ranking by average balance | `PERCENT_RANK()` + `NTILE()` |
| 6 | Customer segmentation (RFM-style) | CTE + multi-metric logic |
| 7 | Year-over-year customer growth | `LAG()` + YoY % calculation |
| 8 | Anomaly detection (Z-score method) | `STDEV()` + `CROSS JOIN` |
| 9 | Account summary dashboard | `CREATE VIEW` |
| 10 | Full customer report | `STORED PROCEDURE` + error handling |

---

## 🛠️ Data Generation Methodology

Data was generated programmatically using set-based T-SQL — no manual inserts, no CSV imports, no external tools.

| Technique | Purpose |
|-----------|---------|
| Recursive CTEs + CROSS JOINs | Build number series up to 1M without loops |
| `CHECKSUM(NEWID())` | Fast pseudo-random value generation |
| Batched INSERTs (10 × 1M) | Prevent transaction log overflow on Transactions table |
| `DATEADD` with random offsets | Realistic date distribution across 5 years |
| Modulo arithmetic | Deterministic mapping to name/city pools |
| Right-skewed CASE logic | Realistic balance distribution |

---

## 🗃️ Files in This Repository

| File | Description |
|------|-------------|
| `BankAnalytics_Project.sql` | Table creation + 10 analytical queries + stored procedure + view |
| `BankAnalytics_BigData_Generator.sql` | Generates 12.8M rows using advanced T-SQL techniques |
| `DATA_CATALOG.md` | This file — full documentation of the database schema |

---

## 🚀 How to Run

```sql
-- 1. Open SQL Server Management Studio (SSMS)
-- 2. Run BankAnalytics_BigData_Generator.sql  (creates DB + generates all data)
-- 3. Run BankAnalytics_Project.sql            (runs all 10 analytical queries)
-- Estimated total runtime: 5–10 minutes
```

**Requirements:** SQL Server 2016 or later · SSMS 18+

---

## 👤 Author

**Marthed Amin Murtada Ahmed**  
Data Analyst | SQL · R · Python · Power BI  
🔗 [LinkedIn](https://linkedin.com) · [GitHub](https://github.com) · [Kaggle](https://kaggle.com)
