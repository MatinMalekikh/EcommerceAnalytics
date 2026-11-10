
USE EcommerceAnalytics;
GO

DECLARE @ReferenceDate DATE;

SELECT
    @ReferenceDate = MAX(CAST(InvoiceDate AS DATE))
FROM analytics.CleanSales;

WITH AnalysisData AS (

    SELECT
        'Base Case' AS AnalysisCase,
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL

    UNION ALL

    SELECT
        'Adjusted Case' AS AnalysisCase,
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL
      AND InvoiceNo NOT IN ('541431', '581483')
      AND StockCode NOT IN ('DOT', 'POST', 'M', 'C2', '23444')
),

CustomerRFM AS (
    SELECT
        AnalysisCase,
        CustomerID,

        DATEDIFF(
            DAY,
            MAX(CAST(InvoiceDate AS DATE)),
            @ReferenceDate
        ) AS Recency,

        COUNT(DISTINCT InvoiceNo) AS Frequency,

        SUM(LineRevenue) AS Monetary

    FROM AnalysisData
    GROUP BY
        AnalysisCase,
        CustomerID
),

RFMScoring AS (
    SELECT
        AnalysisCase,
        CustomerID,
        Recency,
        Frequency,
        Monetary,

        6 - NTILE(5) OVER (
            PARTITION BY AnalysisCase
            ORDER BY Recency ASC, CustomerID
        ) AS R_Score,

        NTILE(5) OVER (
            PARTITION BY AnalysisCase
            ORDER BY Frequency ASC, CustomerID
        ) AS F_Score,

        NTILE(5) OVER (
            PARTITION BY AnalysisCase
            ORDER BY Monetary ASC, CustomerID
        ) AS M_Score

    FROM CustomerRFM
),

CustomerSegments AS (
    SELECT
        AnalysisCase,
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

MigrationStatus AS (
    SELECT
        CustomerID,

        MAX(CASE
            WHEN AnalysisCase = 'Base Case'
            THEN CustomerSegment
        END) AS BaseSegment,

        MAX(CASE
            WHEN AnalysisCase = 'Adjusted Case'
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

CustomerMetrics AS (
    SELECT
        AnalysisCase,
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS TotalOrders,
        SUM(LineRevenue) AS TotalRevenue

    FROM AnalysisData
    GROUP BY
        AnalysisCase,
        CustomerID
),

CustomerImpact AS (
    SELECT
        CG.MigrationGroup,
        CG.CustomerID,

        COALESCE(B.TotalOrders, 0) AS BaseOrders,
        COALESCE(A.TotalOrders, 0) AS AdjustedOrders,

        COALESCE(B.TotalRevenue, 0) AS BaseRevenue,
        COALESCE(A.TotalRevenue, 0) AS AdjustedRevenue

    FROM CustomerGroups AS CG

    LEFT JOIN CustomerMetrics AS B
        ON CG.CustomerID = B.CustomerID
       AND B.AnalysisCase = 'Base Case'

    LEFT JOIN CustomerMetrics AS A
        ON CG.CustomerID = A.CustomerID
       AND A.AnalysisCase = 'Adjusted Case'
)

SELECT
    MigrationGroup,

    COUNT(*) AS CustomerCount,

    SUM(BaseOrders) AS BaseTotalOrders,
    SUM(AdjustedOrders) AS AdjustedTotalOrders,

    SUM(BaseRevenue) AS BaseTotalRevenue,
    SUM(AdjustedRevenue) AS AdjustedTotalRevenue,

    SUM(BaseRevenue - AdjustedRevenue) AS RevenueReduction,

    AVG(CAST(BaseRevenue AS FLOAT)) AS AverageBaseRevenuePerCustomer,

    AVG(CAST(AdjustedRevenue AS FLOAT)) AS AverageAdjustedRevenuePerCustomer

FROM CustomerImpact

GROUP BY MigrationGroup

ORDER BY
    CASE MigrationGroup
        WHEN 'Retained' THEN 1
        WHEN 'Migrated' THEN 2
        WHEN 'Removed' THEN 3
    END;
