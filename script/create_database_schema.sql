/*

==============================================================
Create Bank Marketing Data Warehouse (Kimball Approach)
==============================================================

SCRIPT PURPOSE:

    This script initializes a fresh Data Warehouse for the
    Bank Marketing project using the Kimball methodology.

    Execution workflow:
        1. Checks if the 'BankMarketingDW' database exists.
        2. If it exists, the database will be dropped safely.
        3. Recreates the database from scratch.
        4. Sets up the foundational schema following the Kimball approach:
              - Dim_Customer   : Customer details
              - Dim_Date       : Date dimension
              - Dim_Contact    : Contact method dimension
              - Dim_Campaign   : Marketing campaign dimension
              - Fact_Marketing : Fact table recording each contact event

    This Star Schema design ensures:
        - Clear separation between facts and dimensions
        - Ease of analysis for BI tools and ML models
        - Scalable and maintainable data structure
        - Support for Customer profiling and marketing analytics

    Intended Environment:
        Development and Testing only.

==============================================================
CRITICAL WARNING:
==============================================================

    Executing this script will permanently delete the
    'BankMarketingDW' database if it already exists.

    All data and objects in the database will be lost irreversibly.

    Before executing:
        - Ensure full backups have been completed.
        - Verify you are connected to the correct SQL Server instance.
        - Confirm proper authorization.

    DO NOT run this script in a Production environment.

    Proceed with caution.

==============================================================
*/
USE master
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'BankMarketingDW')
BEGIN
    ALTER DATABASE BankMarketingDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BankMarketingDW
END
GO

CREATE DATABASE BankMarketingDW
GO

USE BankMarketingDW
GO
CREATE SCHEMA DW
