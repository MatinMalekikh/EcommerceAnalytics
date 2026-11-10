/*
Purpose: Summarize invoice count, units, and calculated revenue by calendar month.
*/
USE EcommerceAnalytics;
GO

SELECT
    YEAR(InvoiceDate) AS SalesYear,
    MONTH(InvoiceDate) AS SalesMonth,
    COUNT(DISTINCT InvoiceNo) AS NumberOfInvoices,
    SUM(Quantity) AS UnitsSold,
    CAST(SUM(LineRevenue) AS DECIMAL(18, 2)) AS Revenue
FROM analytics.CleanSales
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY SalesYear, SalesMonth;
