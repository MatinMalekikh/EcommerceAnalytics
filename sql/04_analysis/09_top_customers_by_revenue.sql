USE EcommerceAnalytics;
GO

SELECT TOP 20
    CustomerID,
    Country,
    COUNT(DISTINCT InvoiceNo) AS TotalOrders,
    SUM(Quantity) AS TotalUnitsPurchased,
    SUM(LineRevenue) AS TotalRevenue,
    SUM(LineRevenue) / COUNT(DISTINCT InvoiceNo) AS AverageOrderValue
FROM analytics.CleanSales
WHERE CustomerID IS NOT NULL
GROUP BY
    CustomerID,
    Country
ORDER BY TotalRevenue DESC;