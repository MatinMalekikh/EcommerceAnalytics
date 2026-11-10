USE EcommerceAnalytics;
GO

SELECT
    StockCode,
    COUNT(DISTINCT Description) AS DescriptionCount,
    COUNT(*) AS TotalRows,
    SUM(Quantity) AS TotalQuantity,
    SUM(LineRevenue) AS TotalRevenue
FROM analytics.CleanSales
WHERE StockCode IN ('DOT', 'POST')
GROUP BY StockCode;
GO

SELECT
    StockCode,
    Description,
    COUNT(*) AS SalesLines,
    SUM(Quantity) AS TotalQuantity,
    SUM(LineRevenue) AS TotalRevenue
FROM analytics.CleanSales
WHERE StockCode IN ('DOT', 'POST')
GROUP BY
    StockCode,
    Description
ORDER BY
    StockCode,
    Description;
GO