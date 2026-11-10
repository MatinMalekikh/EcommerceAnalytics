
USE EcommerceAnalytics;
GO

SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
FROM raw.OnlineRetail
WHERE InvoiceNo = '555524'
ORDER BY StockCode;
