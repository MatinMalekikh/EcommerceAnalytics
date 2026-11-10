USE EcommerceAnalytics;
GO

SELECT
    Country,

    COUNT(DISTINCT InvoiceNo) AS TotalOrders,

    COUNT(DISTINCT CustomerID) AS TotalCustomers,

    SUM(Quantity) AS TotalUnitsSold,

    SUM(LineRevenue) AS TotalRevenue,

    SUM(LineRevenue) /
        COUNT(DISTINCT InvoiceNo) AS AverageOrderValue

FROM analytics.CleanSales

GROUP BY Country

ORDER BY TotalRevenue DESC;