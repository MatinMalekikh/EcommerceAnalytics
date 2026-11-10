USE EcommerceAnalytics;
GO

DECLARE @ReferenceDate DATE;

SELECT
    @ReferenceDate = MAX(CAST(InvoiceDate AS DATE))
FROM analytics.CleanSales;

SELECT
    CustomerID,

    MAX(CAST(InvoiceDate AS DATE)) AS LastPurchaseDate,

    DATEDIFF(
        DAY,
        MAX(CAST(InvoiceDate AS DATE)),
        @ReferenceDate
    ) AS Recency,

    COUNT(DISTINCT InvoiceNo) AS Frequency,

    SUM(LineRevenue) AS Monetary

FROM analytics.CleanSales

WHERE CustomerID IS NOT NULL

GROUP BY CustomerID

ORDER BY Monetary DESC;