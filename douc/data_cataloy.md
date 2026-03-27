# 📚 Data Catalog — Bank Marketing DW

> **Schema:** `dw` | **Database:** `BankMarketingDW` | **Methodology:** Kimball (Star Schema)

---

## 📌 Table of Contents

- [Project Overview](#-project-overview)
- [Data Sources](#-data-sources)
- [Architecture](#-architecture)
- [Staging Tables](#-staging-tables)
- [Dimension Tables](#-dimension-tables)
- [Fact Table](#-fact-table)
- [Star Schema Diagram](#-star-schema-diagram)
- [Data Dictionary](#-data-dictionary)
- [Citation](#-citation)

---

## 🏦 Project Overview

This project implements a **Data Warehouse** for analyzing Portugal bank marketing campaigns using the **Kimball dimensional modeling methodology (Star Schema)**.

### Business Context
The bank conducted direct phone call campaigns offering clients to subscribe to a **Term Deposit**. The goal is to analyze campaign performance, build client profiles, and predict future subscription outcomes.

### Business Questions Answered
- Which client segments are most likely to subscribe to a term deposit?
- Which campaign strategies yield the highest conversion rates?
- How do macroeconomic indicators (Euribor, employment rate) affect subscription likelihood?
- What is the optimal number of contact attempts per client?

### Project Tasks
| Task | Description |
|------|-------------|
| 📊 Campaign Analysis | Analyze the performance of past marketing campaigns |
| 👤 Client Profiling | Build a profile of clients who subscribe to term deposits |
| 🤖 Predictive Modeling | Predict future campaign results using ML models |
| 💡 Recommendations | Formulate actionable recommendations for future campaigns |

---

## 📂 Data Sources

| File | Rows | Columns | Description |
|------|------|---------|-------------|
| `bank.csv` | 4,521 | 17 | 10% sample — used for quick testing only |
| `bank-full.csv` | 45,211 | 17 | Full dataset with client & campaign data |
| `bank-additional.csv` | 41,188 | 21 | Enriched dataset with 5 macroeconomic indicators |

- **Source:** [UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/datasets/bank+marketing)
- **Description:** [Kaggle Dataset Description](https://www.kaggle.com/volodymyrgavrysh/bank-marketing-campaigns-dataset-description)
- **Period:** Bank marketing campaigns 2008–2010
- **Origin:** Portuguese banking institution

> ⚠️ `bank.csv` is excluded from the warehouse load — it is a subset of `bank-full.csv` used for development and testing only.

---

## 🏗️ Architecture

```
Source CSV Files
      │
      ▼
┌─────────────────────────────┐
│         ETL Layer           │
│  Extract (SSIS / Python)    │
│  Transform (clean, map)     │
│  Load (INSERT into DW)      │
└─────────────────────────────┘
      │
      ▼
┌─────────────────────────────┐
│    Staging Tables (temp)    │
│  dw.stg_bank_full           │
│  dw.stg_bank_additional     │
└─────────────────────────────┘
      │
      ▼
┌─────────────────────────────┐
│   Star Schema (Gold Layer)  │
│                             │
│   DimClient                 │
│   DimDate                   │
│   DimCampaign               │
│   DimEconomicContext        │
│   FactCampaignCall  ◄─────  │
└─────────────────────────────┘
      │
      ▼
┌─────────────────────────────┐
│      Consume Layer          │
│  Power BI  │  SQL Queries   │
│  ML Model  │  KPI Reports   │
└─────────────────────────────┘
```

**Grain:** One row in `FactCampaignCall` = **one phone call to one client in one campaign**

---

## 🗄️ Staging Tables

Staging tables are **temporary** — they store raw CSV data as-is before transformation. They are dropped or truncated after each ETL run.

### `dw.stg_bank_full`
- **Source:** `bank-full.csv`
- **Rows:** 45,211
- **Columns:** 17
- **Purpose:** Raw storage of client demographics, campaign contact details, and subscription outcome

### `dw.stg_bank_additional`
- **Source:** `bank-additional.csv`
- **Rows:** 41,188
- **Columns:** 21
- **Purpose:** Raw storage of enriched data including 5 macroeconomic indicators not present in `bank-full.csv`

---

## 📐 Dimension Tables

### `dw.DimClient`
Stores unique client demographic information.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| `client_key` | INT (PK) | Surrogate key | 1001 |
| `age` | INT | Client age in years | 35 |
| `age_group` | NVARCHAR(20) | Age category | `'25-34'` |
| `job` | NVARCHAR(50) | Occupation type | `'management'` |
| `marital` | NVARCHAR(20) | Marital status | `'married'` |
| `education` | NVARCHAR(50) | Education level | `'university.degree'` |
| `has_default` | BIT | Has credit in default | `0` |
| `has_housing` | BIT | Has housing loan | `1` |
| `has_loan` | BIT | Has personal loan | `0` |
| `balance` | DECIMAL(10,2) | Average yearly balance (€) | `1500.00` |

**Source columns:** `age`, `job`, `marital`, `education`, `default`, `housing`, `loan`, `balance`

---

### `dw.DimDate`
Stores date attributes for each campaign contact.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| `date_key` | INT (PK) | Surrogate key (YYYYMMDD) | 20100315 |
| `full_date` | DATE | Full calendar date | `2010-03-15` |
| `day` | INT | Day of month | 15 |
| `day_of_week` | NVARCHAR(5) | Day name abbreviated | `'mon'` |
| `month` | NVARCHAR(5) | Month name abbreviated | `'mar'` |
| `month_number` | INT | Month number | 3 |
| `quarter` | INT | Quarter of year | 1 |
| `year` | INT | Calendar year | 2010 |

**Source columns:** `day`, `month` (from bank-full) / `day_of_week`, `month` (from bank-additional)

---

### `dw.DimCampaign`
Stores information about the marketing campaign contact attempt.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| `campaign_key` | INT (PK) | Surrogate key | 1 |
| `contact_type` | NVARCHAR(20) | Communication channel | `'cellular'` |
| `campaign_number` | INT | Contact count in current campaign | 3 |
| `previous_contacts` | INT | Contacts before this campaign | 1 |
| `pdays` | INT | Days since last previous contact | 92 |
| `poutcome` | NVARCHAR(20) | Previous campaign outcome | `'success'` |
| `poutcome_flag` | BIT | Previous campaign was successful | `1` |

**Source columns:** `contact`, `campaign`, `previous`, `pdays`, `poutcome`

---

### `dw.DimEconomicContext`
Stores macroeconomic indicators at the time of contact. Available only from `bank-additional.csv`.

| Column | Data Type | Description | Frequency | Example |
|--------|-----------|-------------|-----------|---------|
| `economic_key` | INT (PK) | Surrogate key | — | 1 |
| `month` | NVARCHAR(5) | Reference month | — | `'mar'` |
| `year` | INT | Reference year | — | 2010 |
| `emp_var_rate` | DECIMAL(5,2) | Employment variation rate | Quarterly | `-1.80` |
| `cons_price_idx` | DECIMAL(8,3) | Consumer price index | Monthly | `92.893` |
| `cons_conf_idx` | DECIMAL(6,2) | Consumer confidence index | Monthly | `-46.20` |
| `euribor3m` | DECIMAL(6,3) | Euribor 3-month rate | Daily | `1.313` |
| `nr_employed` | DECIMAL(8,1) | Number of employees (thousands) | Quarterly | `5099.1` |

**Source columns:** `emp_var_rate`, `cons_price_idx`, `cons_conf_idx`, `euribor3m`, `nr_employed`

> ⚠️ This dimension is **NULL** for records sourced from `bank-full.csv` as it lacks macroeconomic data.

---

## 📊 Fact Table

### `dw.FactCampaignCall`
The central fact table. Each row represents **one phone call** made to a client during a marketing campaign.

| Column | Data Type | Description | Type |
|--------|-----------|-------------|------|
| `call_key` | INT (PK) | Surrogate key | Degenerate |
| `client_key` | INT (FK) | Reference to DimClient | FK |
| `date_key` | INT (FK) | Reference to DimDate | FK |
| `campaign_key` | INT (FK) | Reference to DimCampaign | FK |
| `economic_key` | INT (FK) | Reference to DimEconomicContext | FK |
| `duration_secs` | INT | Call duration in seconds | Measure |
| `subscribed_flag` | BIT | Client subscribed? (1=yes, 0=no) | Measure |
| `source_file` | NVARCHAR(30) | Origin file identifier | Metadata |

**Grain:** One row = one call to one client in one campaign

**Measures:**
| Measure | Aggregation | Business Meaning |
|---------|------------|-----------------|
| `duration_secs` | AVG, SUM | Call duration — proxy for client engagement |
| `subscribed_flag` | SUM, AVG | Conversion rate — primary KPI |

> ⚠️ `duration_secs` should **not** be used in predictive models — call duration is only known after the call ends, making it a data leakage risk.

---

## 🌟 Star Schema Diagram

```
                    ┌─────────────────┐
                    │   DimDate       │
                    │─────────────────│
                    │ date_key (PK)   │
                    │ full_date       │
                    │ day             │
                    │ day_of_week     │
                    │ month           │
                    │ quarter / year  │
                    └────────┬────────┘
                             │ 1
                             │
┌─────────────────┐          │          ┌─────────────────┐
│   DimClient     │   Many   │   Many   │   DimCampaign   │
│─────────────────│──────────┤──────────│─────────────────│
│ client_key (PK) │          │          │ campaign_key(PK)│
│ age / age_group │        ──┴──        │ contact_type    │
│ job             │   FactCampaignCall  │ campaign_number │
│ marital         │   ─────────────────│ poutcome        │
│ education       │   call_key (PK)    │ poutcome_flag   │
│ has_default     │   client_key (FK)  └─────────────────┘
│ has_housing     │   date_key (FK)
│ has_loan        │   campaign_key (FK)
│ balance         │   economic_key (FK)
└─────────────────┘   duration_secs
                      subscribed_flag
                             │
                             │ Many
                             │ 1
                    ┌────────┴────────┐
                    │DimEconomicCtx   │
                    │─────────────────│
                    │economic_key(PK) │
                    │emp_var_rate     │
                    │cons_price_idx   │
                    │cons_conf_idx    │
                    │euribor3m        │
                    │nr_employed      │
                    └─────────────────┘
```

**Relationships:** All dimensions relate to the Fact Table as **Many-to-One (N:1)**

---

## 📖 Data Dictionary

### Categorical Values Reference

| Column | Valid Values |
|--------|-------------|
| `job` | `admin.`, `blue-collar`, `entrepreneur`, `housemaid`, `management`, `retired`, `self-employed`, `services`, `student`, `technician`, `unemployed`, `unknown` |
| `marital` | `divorced`, `married`, `single`, `unknown` |
| `education` | `basic.4y`, `basic.6y`, `basic.9y`, `high.school`, `illiterate`, `professional.course`, `university.degree`, `unknown` |
| `default` / `housing` / `loan` | `yes`, `no`, `unknown` |
| `contact` | `cellular`, `telephone` |
| `month` | `jan`, `feb`, `mar`, `apr`, `may`, `jun`, `jul`, `aug`, `sep`, `oct`, `nov`, `dec` |
| `day_of_week` | `mon`, `tue`, `wed`, `thu`, `fri` |
| `poutcome` | `failure`, `nonexistent`, `success` |
| `y` (target) | `yes`, `no` |

### Special Values

| Column | Special Value | Meaning |
|--------|--------------|---------|
| `pdays` | `999` | Client was never previously contacted |
| `pdays` (bank-full) | `-1` | Client was never previously contacted |
| `duration` | `0` | Call never happened → `y` is always `'no'` |

---

## 📜 Citation

> S. Moro, P. Cortez and P. Rita. *"A Data-Driven Approach to Predict the Success of Bank Telemarketing."*
> Decision Support Systems, Elsevier, 62:22-31, June 2014.

This dataset is publicly available for research purposes.

---

*Last updated: 2026 | Maintained by: Data Engineering Team*
