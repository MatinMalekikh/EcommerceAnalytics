
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
        COUNT(*) AS DuplicateCount
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
    HAVING COUNT(*) > 1
)
SELECT
    COUNT(*) AS DuplicateGroups,
    SUM(DuplicateCount) AS RowsInDuplicateGroups,
    SUM(DuplicateCount - 1) AS ExtraDuplicateRows,
    MAX(DuplicateCount) AS MaximumRepetitions
FROM DuplicateGroups;
