USE EcommerceAnalytics;
GO

DECLARE @ReferenceDate DATE;

SELECT
    @ReferenceDate = MAX(CAST(InvoiceDate AS DATE))
FROM analytics.CleanSales;

WITH AnalysisData AS (

    -- Base Case
    SELECT
        'Base Case' AS AnalysisCase,
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        Quantity,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL

    UNION ALL

    -- Adjusted Case
    SELECT
        'Adjusted Case' AS AnalysisCase,
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        Quantity,
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
        *,
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
)

SELECT
    AnalysisCase,
    CustomerSegment,
    COUNT(*) AS CustomerCount,
    AVG(CAST(Recency AS FLOAT)) AS AverageRecency,
    AVG(CAST(Frequency AS FLOAT)) AS AverageFrequency,
    SUM(Monetary) AS TotalRevenue,
    AVG(Monetary) AS AverageCustomerRevenue

FROM CustomerSegments

GROUP BY
    AnalysisCase,
    CustomerSegment

ORDER BY
    AnalysisCase,
    CustomerCount DESC;