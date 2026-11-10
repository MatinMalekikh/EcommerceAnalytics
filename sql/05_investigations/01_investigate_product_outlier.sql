/*
Purpose: Investigate the unusual StockCode 23843 / InvoiceNo 581483 record.
This is a diagnostic query, not a deletion instruction.
*/
USE EcommerceAnalytics;
GO

SELECT
    InvoiceNo, InvoiceDate, StockCode, Description, Quantity,
    UnitPrice, CustomerID, Country, LineRevenue
FROM analytics.CleanSales
WHERE StockCode = '23843'
ORDER BY Quantity DESC;

SELECT
    InvoiceNo, InvoiceDate, StockCode, Description, Quantity,
    UnitPrice, LineRevenue
FROM analytics.CleanSales
WHERE InvoiceNo = '581483'
ORDER BY LineRevenue DESC;

SELECT
    InvoiceNo, StockCode, Description, Quantity, UnitPrice,
    CustomerID, Country
FROM raw.OnlineRetail
WHERE InvoiceNo = '581483'
  AND StockCode = '23843';

SELECT
    InvoiceNo, StockCode, Quantity, UnitPrice,
    COUNT_BIG(*) AS RecordCount
FROM raw.OnlineRetail
WHERE InvoiceNo = '581483'
  AND StockCode = '23843'
GROUP BY InvoiceNo, StockCode, Quantity, UnitPrice;
