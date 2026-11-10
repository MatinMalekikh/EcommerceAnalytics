
USE EcommerceAnalytics;
GO

WITH DuplicateGroups AS (
    SELECT
        InvoiceNo,
        StockCode,
        Description,
        Quantity,
        InvoiceDate,
        UnitPrice,
        CustomerID,
        Country,
        COUNT(*) AS DuplicateCount,
        MAX(LineRevenue) AS LineRevenue
    FROM analytics.CleanSales
    GROUP BY
        InvoiceNo,
        StockCode,
        Description,
        Quantity,
        InvoiceDate,
        UnitPrice,
        CustomerID,
        Country
)
SELECT
    (SELECT SUM(LineRevenue)
     FROM analytics.CleanSales) AS OriginalRevenue,

    SUM(LineRevenue) AS RevenueAfterDeduplication,

    SUM((DuplicateCount - 1) * LineRevenue)
        AS RevenueFromExtraDuplicates

FROM DuplicateGroups;
