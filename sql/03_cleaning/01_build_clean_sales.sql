/*
Purpose: Build the provisional analytics table from raw.OnlineRetail.
Rules:
  - Exclude cancellation invoices whose InvoiceNo begins with C.
  - Keep rows with Quantity > 0.
  - Keep rows with UnitPrice >= 0.
Important:
  - Does not deduplicate exact duplicate rows.
  - Keeps zero-price rows and missing CustomerID/Description values.
  - This script drops and recreates analytics.CleanSales each time it runs.
*/
USE EcommerceAnalytics;
GO

IF SCHEMA_ID(N'analytics') IS NULL
    EXEC(N'CREATE SCHEMA analytics;');
GO

IF OBJECT_ID(N'analytics.CleanSales', N'U') IS NOT NULL
    DROP TABLE analytics.CleanSales;
GO

SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    CAST(Quantity AS DECIMAL(18, 4))
        * CAST(UnitPrice AS DECIMAL(18, 4)) AS LineRevenue
INTO analytics.CleanSales
FROM raw.OnlineRetail
WHERE InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND UnitPrice >= 0;
GO

SELECT
    COUNT_BIG(*) AS CleanSalesRows,
    SUM(LineRevenue) AS CalculatedRevenue,
    COUNT_BIG(CASE WHEN CustomerID IS NULL THEN 1 END) AS MissingCustomerIDs
FROM analytics.CleanSales;
