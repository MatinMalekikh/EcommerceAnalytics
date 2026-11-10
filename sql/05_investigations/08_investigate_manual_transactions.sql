USE EcommerceAnalytics;
GO

SELECT TOP 50
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

WHERE StockCode = 'M'

ORDER BY LineRevenue DESC;