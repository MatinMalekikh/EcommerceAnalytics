USE EcommerceAnalytics;
GO

SELECT
    SUM(LineRevenue) AS BaseRevenue,

    SUM(CASE
        WHEN InvoiceNo IN ('541431', '581483')
        THEN LineRevenue ELSE 0
    END) AS ExtremeRevenue,

    SUM(CASE
        WHEN StockCode IN ('DOT', 'POST', 'M', 'C2', '23444')
        THEN LineRevenue ELSE 0
    END) AS NonMerchandiseRevenue,

    SUM(CASE
        WHEN InvoiceNo IN ('541431', '581483')
          OR StockCode IN ('DOT', 'POST', 'M', 'C2', '23444')
        THEN LineRevenue ELSE 0
    END) AS CombinedExcludedRevenue

FROM analytics.CleanSales
WHERE CustomerID IS NOT NULL;