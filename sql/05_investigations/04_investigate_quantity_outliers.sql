
USE EcommerceAnalytics;
GO

SELECT TOP 20
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    UnitPrice,
    LineRevenue,
    InvoiceDate,
    CustomerID,
    Country
FROM analytics.CleanSales
ORDER BY Quantity DESC;
