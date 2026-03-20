/*
========================================================================================
The generated database is the foundation for running analytical queries such as customer 
segmentation, loan risk analysis, branch performance, and anomaly detection — all of 
which demonstrate real Data Analyst skills to potential employers.
========================================================================================

*/
-- Step 1: Drop from master
USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'BankAnalytics')
BEGIN
    ALTER DATABASE BankAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BankAnalytics;
END
GO

CREATE DATABASE BankAnalytics;
GO

USE BankAnalytics;
GO

-- ============================================================
-- CREATE TABLES
-- ============================================================
CREATE TABLE Customers (
    customer_id  INT IDENTITY(1,1) PRIMARY KEY,
    full_name    NVARCHAR(100) NOT NULL,
    age          INT           CHECK (age BETWEEN 18 AND 90),
    gender       CHAR(1)       CHECK (gender IN ('M','F')),
    city         NVARCHAR(50),
    join_date    DATE          DEFAULT GETDATE()
);

CREATE TABLE Branches (
    branch_id    INT IDENTITY(1,1) PRIMARY KEY,
    branch_name  NVARCHAR(100) NOT NULL,
    city         NVARCHAR(50)
);

CREATE TABLE Accounts (
    account_id   INT IDENTITY(1,1) PRIMARY KEY,
    customer_id  INT NOT NULL REFERENCES Customers(customer_id),
    branch_id    INT NOT NULL REFERENCES Branches(branch_id),
    account_type NVARCHAR(20) CHECK (account_type IN ('Savings','Current','Fixed')),
    balance      DECIMAL(15,2) DEFAULT 0,
    open_date    DATE          DEFAULT GETDATE()
);

CREATE TABLE Transactions (
    transaction_id   INT IDENTITY(1,1) PRIMARY KEY,
    account_id       INT NOT NULL REFERENCES Accounts(account_id),
    amount           DECIMAL(15,2) NOT NULL,
    trans_type       NVARCHAR(20) CHECK (trans_type IN ('Deposit','Withdrawal','Transfer')),
    transaction_date DATETIME     DEFAULT GETDATE()
);

CREATE TABLE Loans (
    loan_id       INT IDENTITY(1,1) PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES Customers(customer_id),
    loan_amount   DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,2),
    start_date    DATE,
    due_date      DATE,
    status        NVARCHAR(20) CHECK (status IN ('Active','Paid','Overdue'))
);
GO

-- ============================================================
-- INSERT BRANCHES FIRST (fixes FK error)
-- ============================================================
INSERT INTO Branches (branch_name, city) VALUES
('Dubai Main Branch',      'Dubai'),
('Abu Dhabi Central',      'Abu Dhabi'),
('Sharjah Downtown',       'Sharjah'),
('Ajman Branch',           'Ajman'),
('Ras Al Khaimah Branch',  'RAK');
GO

-- ============================================================
-- GENERATE 1,000,000 CUSTOMERS
-- ============================================================
PRINT 'Generating customers...';
WITH
n1 AS (SELECT 1 x UNION ALL SELECT 1),
n2 AS (SELECT 1 x FROM n1 a, n1 b),
n3 AS (SELECT 1 x FROM n2 a, n2 b),
n4 AS (SELECT 1 x FROM n3 a, n3 b),
n5 AS (SELECT 1 x FROM n4 a, n4 b),
n6 AS (SELECT 1 x FROM n5 a, n5 b),
nums AS (SELECT TOP 1000000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) n FROM n6),
cities AS (SELECT city,rn FROM (VALUES
    ('Dubai',1),('Abu Dhabi',2),('Sharjah',3),('Ajman',4),
    ('RAK',5),('Fujairah',6),('Umm Al Quwain',7),('Al Ain',8)) v(city,rn)),
mnames AS (SELECT nm,rn FROM (VALUES
    ('Ahmed',1),('Mohammed',2),('Khalid',3),('Omar',4),('Sultan',5),
    ('Rashid',6),('Saeed',7),('Hamdan',8),('Faisal',9),('Jaber',10),
    ('Yusuf',11),('Ibrahim',12),('Abdullah',13),('Majid',14),('Tariq',15)) v(nm,rn)),
fnames AS (SELECT nm,rn FROM (VALUES
    ('Fatima',1),('Mariam',2),('Sara',3),('Aisha',4),('Hessa',5),
    ('Noura',6),('Latifa',7),('Reem',8),('Moza',9),('Shamma',10),
    ('Maitha',11),('Asma',12),('Hind',13),('Wafa',14),('Lulwa',15)) v(nm,rn)),
lnames AS (SELECT lnm,rn FROM (VALUES
    ('Al Mansouri',1),('Al Zaabi',2),('Al Rashid',3),('Al Nuaimi',4),
    ('Al Hamadi',5),('Al Ketbi',6),('Al Suwaidi',7),('Al Falasi',8),
    ('Al Mazrouei',9),('Al Dhaheri',10),('Al Blooshi',11),('Al Muhairi',12),
    ('Al Shehhi',13),('Al Khaili',14),('Al Tamimi',15),('Al Qubaisi',16),
    ('Al Maktoum',17),('Al Romaithi',18),('Al Neyadi',19),('Al Ameri',20)) v(lnm,rn))
INSERT INTO Customers (full_name, age, gender, city, join_date)
SELECT
    CASE WHEN n.n % 2 = 0 THEN m.nm + ' ' + l.lnm
                          ELSE f.nm + ' ' + l.lnm END,
    18 + ABS(CHECKSUM(NEWID())) % 62,
    CASE WHEN n.n % 2 = 0 THEN 'M' ELSE 'F' END,
    c.city,
    DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 3650), GETDATE())
FROM nums n
JOIN cities c ON (n.n % 8)  + 1 = c.rn
JOIN mnames m ON (n.n % 15) + 1 = m.rn
JOIN fnames f ON (n.n % 15) + 1 = f.rn
JOIN lnames l ON (n.n % 20) + 1 = l.rn;
PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' customers inserted.';
GO

-- ============================================================
-- GENERATE 1,500,000 ACCOUNTS
-- ============================================================
PRINT 'Generating accounts...';
WITH
n1 AS (SELECT 1 x UNION ALL SELECT 1),
n2 AS (SELECT 1 x FROM n1 a,n1 b),
n3 AS (SELECT 1 x FROM n2 a,n2 b),
n4 AS (SELECT 1 x FROM n3 a,n3 b),
n5 AS (SELECT 1 x FROM n4 a,n4 b),
n6 AS (SELECT 1 x FROM n5 a,n5 b),
nums AS (SELECT TOP 1500000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) n FROM n6),
atypes AS (SELECT atype,rn FROM (VALUES
    ('Savings',1),('Current',2),('Fixed',3)) v(atype,rn))
INSERT INTO Accounts (customer_id, branch_id, account_type, balance, open_date)
SELECT
    (n.n % 1000000) + 1,   -- customer_id: maps to 1..1000000
    (n.n % 5) + 1,         -- branch_id:   maps to 1..5
    at.atype,
    CASE
        WHEN n.n % 10 = 0 THEN ROUND(100000 + (ABS(CHECKSUM(NEWID())) % 900000), 2)
        WHEN n.n % 10 <= 3 THEN ROUND(10000  + (ABS(CHECKSUM(NEWID())) % 90000),  2)
        ELSE                    ROUND(500    + (ABS(CHECKSUM(NEWID())) % 9500),    2)
    END,
    DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 2555), GETDATE())
FROM nums n
JOIN atypes at ON (n.n % 3) + 1 = at.rn;
PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' accounts inserted.';
GO

-- ============================================================
-- GENERATE 10,000,000 TRANSACTIONS (10 batches of 1M)
-- ============================================================
PRINT 'Generating transactions...';
GO
DECLARE @batch INT = 1;
DECLARE @total_accounts INT = (SELECT COUNT(*) FROM Accounts);
PRINT 'Total accounts: ' + CAST(@total_accounts AS VARCHAR);

WHILE @batch <= 10
BEGIN
    PRINT 'Batch ' + CAST(@batch AS VARCHAR) + ' of 10...';
    WITH
    n1 AS (SELECT 1 x UNION ALL SELECT 1),
    n2 AS (SELECT 1 x FROM n1 a,n1 b),
    n3 AS (SELECT 1 x FROM n2 a,n2 b),
    n4 AS (SELECT 1 x FROM n3 a,n3 b),
    n5 AS (SELECT 1 x FROM n4 a,n4 b),
    n6 AS (SELECT 1 x FROM n5 a,n5 b),
    nums AS (SELECT TOP 1000000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) n FROM n6),
    ttypes AS (SELECT ttype,rn FROM (VALUES
        ('Deposit',1),('Withdrawal',2),('Transfer',3)) v(ttype,rn))
    INSERT INTO Transactions (account_id, amount, trans_type, transaction_date)
    SELECT
        (ABS(CHECKSUM(NEWID())) % @total_accounts) + 1,
        CASE (n.n % 3) + 1
            WHEN 1 THEN ROUND(100  + (ABS(CHECKSUM(NEWID())) % 49900), 2)
            WHEN 2 THEN ROUND(50   + (ABS(CHECKSUM(NEWID())) % 9950),  2)
            WHEN 3 THEN ROUND(1000 + (ABS(CHECKSUM(NEWID())) % 99000), 2)
        END,
        tt.ttype,
        DATEADD(MINUTE, -(ABS(CHECKSUM(NEWID())) % 2628000), GETDATE())
    FROM nums n
    JOIN ttypes tt ON (n.n % 3) + 1 = tt.rn;
    SET @batch = @batch + 1;
END;
PRINT '10,000,000 transactions inserted.';
GO

-- ============================================================
-- GENERATE 300,000 LOANS
-- ============================================================
PRINT 'Generating loans...';
WITH
n1 AS (SELECT 1 x UNION ALL SELECT 1),
n2 AS (SELECT 1 x FROM n1 a,n1 b),
n3 AS (SELECT 1 x FROM n2 a,n2 b),
n4 AS (SELECT 1 x FROM n3 a,n3 b),
n5 AS (SELECT 1 x FROM n4 a,n4 b),
nums AS (SELECT TOP 300000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) n FROM n5 a, n5 b),
lstatuses AS (SELECT lstatus,rn FROM (VALUES
    ('Active',1),('Paid',2),('Overdue',3)) v(lstatus,rn))
INSERT INTO Loans (customer_id, loan_amount, interest_rate, start_date, due_date, status)
SELECT
    (n.n % 1000000) + 1,
    ROUND(5000   + (ABS(CHECKSUM(NEWID())) % 995000),    2),
    ROUND(1.5    + (ABS(CHECKSUM(NEWID())) % 50) * 0.1,  2),
    DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 2000), GETDATE()),
    DATEADD(DAY,  (ABS(CHECKSUM(NEWID())) % 1825), GETDATE()),
    ls.lstatus
FROM nums n
JOIN lstatuses ls ON (n.n % 3) + 1 = ls.rn;
PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' loans inserted.';
GO

-- ============================================================
-- VERIFY
-- ============================================================
SELECT 'Customers'    AS [Table], COUNT(*) AS [Rows] FROM Customers
UNION ALL SELECT 'Branches',     COUNT(*) FROM Branches
UNION ALL SELECT 'Accounts',     COUNT(*) FROM Accounts
UNION ALL SELECT 'Transactions', COUNT(*) FROM Transactions
UNION ALL SELECT 'Loans',        COUNT(*) FROM Loans;
GO
