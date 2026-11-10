USE EcommerceAnalytics;
GO

SELECT
    Country,

    COUNT(*) AS TotalSalesLines,

    COUNT(DISTINCT InvoiceNo) AS TotalOrders,

    SUM(Quantity) AS TotalUnitsSold,

    SUM(LineRevenue) AS TotalRevenue,

    SUM(LineRevenue) / COUNT(DISTINCT InvoiceNo)
        AS AverageRevenuePerOrder

FROM analytics.CleanSales

WHERE StockCode = 'M'

GROUP BY Country

ORDER BY TotalRevenue DESC;