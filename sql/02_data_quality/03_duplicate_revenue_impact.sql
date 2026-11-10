/*
Purpose: Estimate the number and calculated value of extra rows in exact-duplicate groups.
Caution: This measures potential impact; it does not decide automatically that duplicates
should be deleted. Confirm the dataset's business rules before deduplicating transactions.
*/
USE EcommerceAnalytics;
GO

WITH DuplicateGroups AS (
    SELECT
        InvoiceNo, StockCode, Description, Quantity, InvoiceDate,
        UnitPrice, CustomerID, Country,
        COUNT_BIG(*) AS Copies
    FROM raw.OnlineRetail
    GROUP BY
        InvoiceNo, StockCode, Description, Quantity, InvoiceDate,
        UnitPrice, CustomerID, Country
    HAVING COUNT_BIG(*) > 1
)
SELECT
    COUNT_BIG(*) AS DuplicateGroups,
    SUM(Copies - 1) AS ExtraDuplicateRows,
    SUM(CAST(Copies - 1 AS DECIMAL(18, 4))
        * Quantity * UnitPrice) AS ExtraCalculatedRevenue,
    SUM(CASE WHEN InvoiceNo LIKE 'C%' THEN Copies - 1 ELSE 0 END)
        AS ExtraCancellationRows
FROM DuplicateGroups;
