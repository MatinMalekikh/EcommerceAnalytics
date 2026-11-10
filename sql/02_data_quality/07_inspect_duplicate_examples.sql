
USE EcommerceAnalytics;
GO

SELECT TOP 20
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    COUNT(*) AS DuplicateCount,
    SUM(LineRevenue) AS TotalGroupRevenue
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
ORDER BY DuplicateCount DESC;
