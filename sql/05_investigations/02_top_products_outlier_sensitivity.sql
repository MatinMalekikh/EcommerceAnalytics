/*
Purpose: Compare top-product revenue with and without the single specified record.
Caution: The exclusion is for sensitivity analysis only. It does not establish that the
record is invalid. The comparison retains the original product ranking.
*/
USE EcommerceAnalytics;
GO

WITH ProductRevenue AS (
    SELECT
        StockCode,
        MAX(Description) AS ProductName,
        SUM(Quantity) AS UnitsSold,
        COUNT(DISTINCT InvoiceNo) AS NumberOfInvoices,
        SUM(LineRevenue) AS RevenueOriginal
    FROM analytics.CleanSales
    GROUP BY StockCode
),
ProductRevenueWithoutOutlier AS (
    SELECT
        StockCode,
        SUM(LineRevenue) AS RevenueWithoutOutlier
    FROM analytics.CleanSales
    WHERE NOT (InvoiceNo = '581483' AND StockCode = '23843')
    GROUP BY StockCode
)
SELECT TOP (10)
    p.StockCode,
    p.ProductName,
    p.UnitsSold,
    p.NumberOfInvoices,
    CAST(p.RevenueOriginal AS DECIMAL(18, 2)) AS RevenueOriginal,
    CAST(COALESCE(o.RevenueWithoutOutlier, 0) AS DECIMAL(18, 2)) AS RevenueWithoutOutlier
FROM ProductRevenue AS p
LEFT JOIN ProductRevenueWithoutOutlier AS o
    ON p.StockCode = o.StockCode
ORDER BY p.RevenueOriginal DESC;
