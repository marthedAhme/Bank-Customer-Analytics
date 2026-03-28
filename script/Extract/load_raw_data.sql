/*
====================================================================================================
Procedure Name: DW.load_data
Description:    This procedure performs the ETL (Extract, Load) process for bank marketing data.
                It truncates the staging tables and reloads them from CSV files.
                
Steps:
    1. Initialize timing variables to monitor performance.
    2. Truncate and Bulk Insert data into 'DW.stg_bank_full'.
    3. Truncate and Bulk Insert data into 'DW.stg_bank_additional'.
    4. Calculate and print the duration for each step and the total execution time.
    5. Handle errors using TRY...CATCH block.

Author: [Your Name/Project Name]
Date: 2024-xx-xx
====================================================================================================
*/

CREATE OR ALTER PROCEDURE DW.load_data AS 
BEGIN
    DECLARE 
        @start_batch DATETIME,
        @end_batch DATETIME,
        @start_time DATETIME,
        @end_time DATETIME
    BEGIN TRY

        SET @start_batch = GETDATE();
        PRINT '-----------------------------------';
        PRINT 'Loading DW.stg_bank_full';
        PRINT '-----------------------------------';

        SET @start_time = GETDATE();
        PRINT 'Truncate Table: DW.stg_bank_full';
        TRUNCATE TABLE DW.stg_bank_full;

        PRINT 'Insert data into the table: DW.stg_bank_full';
        BULK INSERT DW.stg_bank_full
        FROM 'C:\SQL_DB\Projects\Bank_analysis\bank_marketing\bank\bank-full.csv'
        WITH(
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ';',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            MAXERRORS = 1000
        );

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '----------------'

        SET @start_time = GETDATE();
        PRINT '-----------------------------------';
        PRINT 'Loading DW.stg_bank_additional';
        PRINT '-----------------------------------';

        PRINT 'Truncate Table: DW.stg_bank_additional';
        TRUNCATE TABLE DW.stg_bank_additional;

        PRINT 'Insert data into the table: DW.stg_bank_additional';
        BULK INSERT DW.stg_bank_additional
        FROM 'C:\SQL_DB\Projects\Bank_analysis\bank_marketing\bank-additional\bank-additional\bank-additional.csv'
        WITH
        (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ';',
            ROWTERMINATOR = '\n'
        );

        SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '----------------'

        SET  @end_batch = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '---------------'
        PRINT '======================================='
		PRINT ' Loading date is Completed';
		PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '======================================='

    END TRY

    BEGIN CATCH
        PRINT '=============================================================';
		PRINT 'ERROR OCCURED DURING LOADING DATE';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '============================================================='
    END CATCH
END

EXEC DW.load_data
