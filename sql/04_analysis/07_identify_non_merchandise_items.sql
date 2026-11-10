USE EcommerceAnalytics;
GO

SELECT
    StockCode,
    Description,

    COUNT(*) AS TotalSalesLines,

    SUM(Quantity) AS TotalUnitsSold,

    SUM(LineRevenue) AS TotalRevenue

FROM analytics.CleanSales

WHERE
    StockCode IN ('DOT', 'POST', 'M')
    OR Description LIKE '%POSTAGE%'
    OR Description LIKE '%CARRIAGE%'
    OR Description LIKE '%MANUAL%'

GROUP BY
    StockCode,
    Description

ORDER BY
    TotalRevenue DESC;