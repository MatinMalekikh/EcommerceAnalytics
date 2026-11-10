/*
Purpose: Ensure the raw schema exists.
Prerequisite: The raw.OnlineRetail table must be imported separately from the source Excel file.
*/
USE EcommerceAnalytics;
GO

IF SCHEMA_ID(N'raw') IS NULL
    EXEC(N'CREATE SCHEMA raw;');
GO

IF SCHEMA_ID(N'analytics') IS NULL
    EXEC(N'CREATE SCHEMA analytics;');
GO
