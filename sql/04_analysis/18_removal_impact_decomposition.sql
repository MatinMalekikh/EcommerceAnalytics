
USE EcommerceAnalytics;
GO

DECLARE @ReferenceDate DATE;

SELECT
    @ReferenceDate = MAX(CAST(InvoiceDate AS DATE))
FROM analytics.CleanSales;

-- 1. Build four analytical scenarios
WITH ScenarioData AS (

    -- Base Case
    SELECT
        'Base Case' AS Scenario,
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        StockCode,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL

    UNION ALL

    -- Remove only extreme invoices
    SELECT
        'Extreme Only',
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        StockCode,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT IN ('541431', '581483')

    UNION ALL

    -- Remove only non-merchandise records
    SELECT
        'Non-Merchandise Only',
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        StockCode,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL
      AND StockCode NOT IN ('DOT', 'POST', 'M', 'C2', '23444')

    UNION ALL

    -- Remove both types
    SELECT
        'Combined',
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        StockCode,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT IN ('541431', '581483')
      AND StockCode NOT IN ('DOT', 'POST', 'M', 'C2', '23444')
),

-- 2. Calculate RFM only for Base and Combined
CustomerRFM AS (
    SELECT
        Scenario,
        CustomerID,

        DATEDIFF(
            DAY,
            MAX(CAST(InvoiceDate AS DATE)),
            @ReferenceDate
        ) AS Recency,

        COUNT(DISTINCT InvoiceNo) AS Frequency,

        SUM(LineRevenue) AS Monetary

    FROM ScenarioData
    WHERE Scenario IN ('Base Case', 'Combined')
    GROUP BY
        Scenario,
        CustomerID
),

-- 3. Calculate RFM scores
RFMScoring AS (
    SELECT
        Scenario,
        CustomerID,
        Recency,
        Frequency,
        Monetary,

        6 - NTILE(5) OVER (
            PARTITION BY Scenario
            ORDER BY Recency ASC, CustomerID
        ) AS R_Score,

        NTILE(5) OVER (
            PARTITION BY Scenario
            ORDER BY Frequency ASC, CustomerID
        ) AS F_Score,

        NTILE(5) OVER (
            PARTITION BY Scenario
            ORDER BY Monetary ASC, CustomerID
        ) AS M_Score

    FROM CustomerRFM
),

-- 4. Assign customer segments
CustomerSegments AS (
    SELECT
        Scenario,
        CustomerID,

        CASE
            WHEN R_Score >= 4
             AND F_Score >= 4
             AND M_Score >= 4
                THEN 'Champions'

            WHEN R_Score >= 3
             AND F_Score >= 4
                THEN 'Loyal Customers'

            WHEN M_Score >= 4
                THEN 'Big Spenders'

            WHEN R_Score >= 4
             AND F_Score IN (2, 3)
                THEN 'Potential Loyalists'

            WHEN R_Score >= 4
             AND F_Score = 1
                THEN 'Recent Customers'

            WHEN R_Score <= 2
             AND F_Score >= 3
                THEN 'At Risk'

            WHEN R_Score <= 2
             AND F_Score <= 2
                THEN 'Hibernating'

            ELSE 'Needs Attention'
        END AS CustomerSegment

    FROM RFMScoring
),

-- 5. Identify migration groups using Base vs Combined
MigrationStatus AS (
    SELECT
        CustomerID,

        MAX(CASE
            WHEN Scenario = 'Base Case'
            THEN CustomerSegment
        END) AS BaseSegment,

        MAX(CASE
            WHEN Scenario = 'Combined'
            THEN CustomerSegment
        END) AS AdjustedSegment

    FROM CustomerSegments
    GROUP BY CustomerID
),

CustomerGroups AS (
    SELECT
        CustomerID,

        CASE
            WHEN AdjustedSegment IS NULL
                THEN 'Removed'

            WHEN BaseSegment = AdjustedSegment
                THEN 'Retained'

            ELSE 'Migrated'
        END AS MigrationGroup

    FROM MigrationStatus
),

-- 6. Calculate orders and revenue per customer in each scenario
CustomerScenarioMetrics AS (
    SELECT
        Scenario,
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS TotalOrders,
        SUM(LineRevenue) AS TotalRevenue

    FROM ScenarioData
    GROUP BY
        Scenario,
        CustomerID
),

-- 7. Connect customer groups to all four scenarios
CustomerImpact AS (
    SELECT
        CG.MigrationGroup,
        CG.CustomerID,
        M.Scenario,
        M.TotalOrders,
        M.TotalRevenue

    FROM CustomerGroups AS CG

    LEFT JOIN CustomerScenarioMetrics AS M
        ON CG.CustomerID = M.CustomerID
),

-- 8. Compare scenarios for each migration group
GroupComparison AS (
    SELECT
        MigrationGroup,

        COUNT(DISTINCT CASE
            WHEN Scenario = 'Base Case'
            THEN CustomerID
        END) AS BaseCustomers,

        COUNT(DISTINCT CASE
            WHEN Scenario = 'Extreme Only'
            THEN CustomerID
        END) AS ExtremeOnlyCustomers,

        COUNT(DISTINCT CASE
            WHEN Scenario = 'Non-Merchandise Only'
            THEN CustomerID
        END) AS NonMerchandiseOnlyCustomers,

        COUNT(DISTINCT CASE
            WHEN Scenario = 'Combined'
            THEN CustomerID
        END) AS CombinedCustomers,

        SUM(CASE
            WHEN Scenario = 'Base Case'
            THEN TotalOrders ELSE 0
        END) AS BaseOrders,

        SUM(CASE
            WHEN Scenario = 'Extreme Only'
            THEN TotalOrders ELSE 0
        END) AS ExtremeOnlyOrders,

        SUM(CASE
            WHEN Scenario = 'Non-Merchandise Only'
            THEN TotalOrders ELSE 0
        END) AS NonMerchandiseOnlyOrders,

        SUM(CASE
            WHEN Scenario = 'Combined'
            THEN TotalOrders ELSE 0
        END) AS CombinedOrders,

        SUM(CASE
            WHEN Scenario = 'Base Case'
            THEN TotalRevenue ELSE 0
        END) AS BaseRevenue,

        SUM(CASE
            WHEN Scenario = 'Extreme Only'
            THEN TotalRevenue ELSE 0
        END) AS ExtremeOnlyRevenue,

        SUM(CASE
            WHEN Scenario = 'Non-Merchandise Only'
            THEN TotalRevenue ELSE 0
        END) AS NonMerchandiseOnlyRevenue,

        SUM(CASE
            WHEN Scenario = 'Combined'
            THEN TotalRevenue ELSE 0
        END) AS CombinedRevenue

    FROM CustomerImpact
    GROUP BY MigrationGroup
)

SELECT
    MigrationGroup,

    BaseCustomers,
    ExtremeOnlyCustomers,
    NonMerchandiseOnlyCustomers,
    CombinedCustomers,

    BaseOrders,
    ExtremeOnlyOrders,
    NonMerchandiseOnlyOrders,
    CombinedOrders,

    BaseRevenue,
    ExtremeOnlyRevenue,
    NonMerchandiseOnlyRevenue,
    CombinedRevenue,

    BaseRevenue - ExtremeOnlyRevenue
        AS ExtremeRevenueReduction,

    BaseRevenue - NonMerchandiseOnlyRevenue
        AS NonMerchandiseRevenueReduction,

    BaseRevenue - CombinedRevenue
        AS CombinedRevenueReduction

FROM GroupComparison

ORDER BY
    CASE MigrationGroup
        WHEN 'Retained' THEN 1
        WHEN 'Migrated' THEN 2
        WHEN 'Removed' THEN 3
    END;
