/*
Purpose:
Analyze product performance by StockCode and Description.

Note:
Grouping by both StockCode and Description separates records
with NULL descriptions from records with non-NULL descriptions.

As a result, Total Recorded Quantity may differ from a
StockCode-level aggregation when some records have NULL descriptions.
*/


USE EcommerceAnalytics;
GO

SELECT TOP 20
    StockCode,
    Description,

    SUM(Quantity) AS TotalUnitsSold,

    COUNT(*) AS TotalSalesLines,

    COUNT(DISTINCT InvoiceNo) AS TotalOrders,

    SUM(LineRevenue) AS TotalRevenue

FROM analytics.CleanSales

GROUP BY
    StockCode,
    Description

ORDER BY
    TotalRevenue DESC;