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

WHERE InvoiceNo NOT IN ('541431', '581483')

GROUP BY
    StockCode,
    Description

ORDER BY
    TotalRevenue DESC;