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

WHERE
    Description IS NULL
    AND StockCode IN ('DOT', 'POST')

ORDER BY
    StockCode,
    InvoiceDate;