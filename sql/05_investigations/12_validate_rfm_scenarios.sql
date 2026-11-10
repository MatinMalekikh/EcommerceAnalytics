USE EcommerceAnalytics;
GO

WITH ScenarioData AS (

    -- Base Case
    SELECT
        'Base Case' AS Scenario,
        CustomerID,
        InvoiceNo,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL

    UNION ALL

    -- Extreme Only
    SELECT
        'Extreme Only',
        CustomerID,
        InvoiceNo,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT IN ('541431', '581483')

    UNION ALL

    -- Non-Merchandise Only
    SELECT
        'Non-Merchandise Only',
        CustomerID,
        InvoiceNo,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL
      AND StockCode NOT IN ('DOT', 'POST', 'M', 'C2', '23444')

    UNION ALL

    -- Combined
    SELECT
        'Combined',
        CustomerID,
        InvoiceNo,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT IN ('541431', '581483')
      AND StockCode NOT IN ('DOT', 'POST', 'M', 'C2', '23444')
)

SELECT
    Scenario,
    COUNT(DISTINCT CustomerID) AS CustomerCount,
    COUNT(DISTINCT InvoiceNo) AS OrderCount,
    SUM(LineRevenue) AS TotalRevenue
FROM ScenarioData
GROUP BY Scenario
ORDER BY
    CASE Scenario
        WHEN 'Base Case' THEN 1
        WHEN 'Extreme Only' THEN 2
        WHEN 'Non-Merchandise Only' THEN 3
        WHEN 'Combined' THEN 4
    END;