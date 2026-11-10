
USE EcommerceAnalytics;
GO

SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    UnitPrice,
    LineRevenue,
    CustomerID,
    InvoiceDate,
    Country
FROM analytics.CleanSales
WHERE InvoiceNo IN ('581483', '541431')
ORDER BY InvoiceNo, StockCode;
