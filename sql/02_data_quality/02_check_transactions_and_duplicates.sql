/*
Purpose: Audit cancellation rows, quantity values, prices, and exact duplicate rows.
Note: Exact duplicates are grouped across the eight source columns used in this dataset.
*/
USE EcommerceAnalytics;
GO

SELECT
    COUNT_BIG(*) AS TotalRows,
    SUM(CASE WHEN InvoiceNo LIKE 'C%' THEN 1 ELSE 0 END) AS CancellationRows,
    SUM(CASE WHEN Quantity < 0 THEN 1 ELSE 0 END) AS NegativeQuantityRows,
    SUM(CASE WHEN Quantity = 0 THEN 1 ELSE 0 END) AS ZeroQuantityRows,
    SUM(CASE WHEN InvoiceNo LIKE 'C%' AND Quantity < 0 THEN 1 ELSE 0 END) AS CancellationAndNegativeQuantityRows,
    SUM(CASE WHEN UnitPrice < 0 THEN 1 ELSE 0 END) AS NegativePriceRows,
    SUM(CASE WHEN UnitPrice = 0 THEN 1 ELSE 0 END) AS ZeroPriceRows
FROM raw.OnlineRetail;

SELECT
    CASE
        WHEN Quantity < 0 THEN 'Negative'
        WHEN Quantity = 0 THEN 'Zero'
        ELSE 'Positive'
    END AS QuantityType,
    COUNT_BIG(*) AS TotalRows
FROM raw.OnlineRetail
GROUP BY CASE
        WHEN Quantity < 0 THEN 'Negative'
        WHEN Quantity = 0 THEN 'Zero'
        ELSE 'Positive'
    END
ORDER BY QuantityType;

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
    SUM(Copies) AS RowsInDuplicateGroups,
    SUM(Copies - 1) AS ExtraDuplicateRows
FROM DuplicateGroups;

SELECT TOP (20)
    InvoiceNo, StockCode, Description, Quantity, InvoiceDate,
    UnitPrice, CustomerID, Country
FROM raw.OnlineRetail
WHERE UnitPrice <= 0
ORDER BY UnitPrice, InvoiceNo;
