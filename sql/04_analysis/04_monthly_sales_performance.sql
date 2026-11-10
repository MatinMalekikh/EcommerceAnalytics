USE EcommerceAnalytics;
GO

SELECT
    YEAR(InvoiceDate) AS SalesYear,
    MONTH(InvoiceDate) AS SalesMonth,

    COUNT(DISTINCT InvoiceNo) AS TotalOrders,

    SUM(Quantity) AS TotalUnitsSold,

    COUNT(*) AS TotalSalesLines,

    SUM(LineRevenue) AS TotalRevenue,

    SUM(LineRevenue) / COUNT(DISTINCT InvoiceNo)
        AS AverageOrderValue

FROM analytics.CleanSales

GROUP BY
    YEAR(InvoiceDate),
    MONTH(InvoiceDate)

ORDER BY
    SalesYear,
    SalesMonth;