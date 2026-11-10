USE EcommerceAnalytics;
GO

SELECT
    COUNT(*) AS TotalRows,

    SUM(CASE
        WHEN InvoiceNo LIKE 'C%' THEN 1
        ELSE 0
    END) AS CancellationRows,

    SUM(CASE
        WHEN Quantity <= 0 THEN 1
        ELSE 0
    END) AS InvalidQuantityRows,

    SUM(CASE
        WHEN UnitPrice < 0 THEN 1
        ELSE 0
    END) AS NegativePriceRows,

    SUM(CASE
        WHEN UnitPrice = 0 THEN 1
        ELSE 0
    END) AS ZeroPriceRows,

    SUM(CASE
        WHEN CustomerID IS NULL THEN 1
        ELSE 0
    END) AS MissingCustomerIDs

FROM analytics.CleanSales;