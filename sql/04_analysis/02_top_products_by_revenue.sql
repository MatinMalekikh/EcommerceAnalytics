/*
Purpose: Rank products by calculated revenue.
Note: MAX(Description) chooses one description per StockCode when descriptions vary.
*/
USE EcommerceAnalytics;
GO

SELECT TOP (10)
    StockCode,
    MAX(Description) AS ProductName,
    SUM(Quantity) AS UnitsSold,
    COUNT(DISTINCT InvoiceNo) AS NumberOfInvoices,
    CAST(SUM(LineRevenue) AS DECIMAL(18, 2)) AS Revenue
FROM analytics.CleanSales
GROUP BY StockCode
ORDER BY Revenue DESC;
