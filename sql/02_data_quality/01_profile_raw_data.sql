/*
Purpose: Basic profiling of the imported source table.
*/
USE EcommerceAnalytics;
GO

SELECT TOP (10) *
FROM raw.OnlineRetail;

SELECT COUNT_BIG(*) AS TotalRows
FROM raw.OnlineRetail;

SELECT COUNT_BIG(*) AS MissingCustomerIDs
FROM raw.OnlineRetail
WHERE CustomerID IS NULL;
