/*
=====================================================
 Purpose:
   Create staging tables in BankMarketingDW
   to temporarily store raw data from CSV files
   before transforming and loading into Star Schema
Schema : DW
Author : 
Date   : 
=====================================================

*/

USE BankMarketingDW;

GO

/*
=====================================================
Table : dw.stg_bank_full
Source: bank-full.csv (17 columns, 45,211 rows)
Purpose: 
	Store raw bank marketing data including
	client demographics, campaign details,
	nd subscription outcome
 =====================================================
*/
IF OBJECT_ID ('DW.stg_bank_full','U') IS NOT NULL
	DROP TABLE DW.stg_bank_full;
GO

CREATE TABLE DW.stg_bank_full 
(
	age			INT,
	job			NVARCHAR(50),
	marital		NVARCHAR(20),
	education	NVARCHAR(50),
	[default]	NVARCHAR(10),
	balance		DECIMAL(10,2),
	housing		NVARCHAR(10),
	loan		NVARCHAR(10),
	contact		NVARCHAR(20),
	day			INT,
	month		NVARCHAR(50),
	duration	INT,
	campaign	INT,
	pdays		INT,
	previous	INT,
	poutcome	NVARCHAR(20),
	y			NVARCHAR(5)
	
);

GO
/* 
=====================================================
Table : dw.stg_bank_additional
Source: bank-additional.csv (21 columns, 41,188 rows)
Purpose: 
	Store enriched bank marketing data with
    5 additional macroeconomic indicators
    not available in stg_bank_full
=====================================================
*/
IF OBJECT_ID('DW.stg_bank_additional','U') IS NOT NULL
	DROP TABLE DW.stg_bank_additional
GO

CREATE TABLE DW.stg_bank_additional
(
	age			   INT,
	job			   NVARCHAR(50),
	marital		   NVARCHAR(20),
	education	   NVARCHAR(50),
	[default]	   NVARCHAR(10),
	housing		   NVARCHAR(10),
	loan		   NVARCHAR(10),
	contact		   NVARCHAR(20),
	[month]		   NVARCHAR(5),
	day_of_week    NVARCHAR(5),
	duration	   INT,
	campaign	   INT,
	pdays		   INT,
	previous	   INT,
	poutcome	   NVARCHAR(20),
	emp_var_rate   DECIMAL(5,2),
	cons_price_idx DECIMAL(8,3),
	cons_conf_idx  DECIMAL(6,2),
	euribor3m	   DECIMAL(6,3),
	nr_employed    DECIMAL(8,1),
	y			   NVARCHAR(5)
);
