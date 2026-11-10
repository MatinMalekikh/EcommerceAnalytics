
USE EcommerceAnalytics;
GO

DECLARE @ReferenceDate DATE;

SELECT
    @ReferenceDate = MAX(CAST(InvoiceDate AS DATE))
FROM analytics.CleanSales;

-- 1. Create four scenarios
WITH ScenarioData AS (

    SELECT
        'Base Case' AS Scenario,
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL

    UNION ALL

    SELECT
        'Extreme Only',
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT IN ('541431', '581483')

    UNION ALL

    SELECT
        'Non-Merchandise Only',
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL
      AND StockCode NOT IN ('DOT', 'POST', 'M', 'C2', '23444')

    UNION ALL

    SELECT
        'Combined',
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT IN ('541431', '581483')
      AND StockCode NOT IN ('DOT', 'POST', 'M', 'C2', '23444')
),

-- 2. Calculate RFM for each scenario
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
    GROUP BY
        Scenario,
        CustomerID
),

-- 3. Calculate RFM scores independently per scenario
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
        Recency,
        Frequency,
        Monetary,
        R_Score,
        F_Score,
        M_Score,

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

-- 5. Aggregate results by scenario and segment
SegmentSummary AS (
    SELECT
        Scenario,
        CustomerSegment,

        COUNT(*) AS CustomerCount,

        AVG(CAST(Recency AS FLOAT)) AS AverageRecency,

        AVG(CAST(Frequency AS FLOAT)) AS AverageFrequency,

        SUM(Monetary) AS TotalRevenue,

        AVG(Monetary) AS AverageCustomerRevenue

    FROM CustomerSegments
    GROUP BY
        Scenario,
        CustomerSegment
)

-- 6. Calculate customer and revenue shares
SELECT
    Scenario,
    CustomerSegment,
    CustomerCount,

    CAST(
        CustomerCount * 100.0 /
        SUM(CustomerCount) OVER (
            PARTITION BY Scenario
        )
        AS DECIMAL(6,2)
    ) AS CustomerSharePercent,

    AverageRecency,
    AverageFrequency,
    TotalRevenue,

    CAST(
        TotalRevenue * 100.0 /
        SUM(TotalRevenue) OVER (
            PARTITION BY Scenario
        )
        AS DECIMAL(6,2)
    ) AS RevenueSharePercent,

    AverageCustomerRevenue

FROM SegmentSummary

ORDER BY
    CASE Scenario
        WHEN 'Base Case' THEN 1
        WHEN 'Extreme Only' THEN 2
        WHEN 'Non-Merchandise Only' THEN 3
        WHEN 'Combined' THEN 4
    END,

    CustomerCount DESC;
