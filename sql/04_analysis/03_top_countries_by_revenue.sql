/*
Purpose: Rank countries by calculated revenue.
NumberOfCustomers counts distinct non-null CustomerID values only.
*/
USE EcommerceAnalytics;
GO

SELECT TOP (10)
    Country,
    COUNT(DISTINCT InvoiceNo) AS NumberOfInvoices,
    COUNT(DISTINCT CustomerID) AS NumberOfCustomers,
    SUM(Quantity) AS UnitsSold,
    CAST(SUM(LineRevenue) AS DECIMAL(18, 2)) AS Revenue
FROM analytics.CleanSales
GROUP BY Country
ORDER BY Revenue DESC;
