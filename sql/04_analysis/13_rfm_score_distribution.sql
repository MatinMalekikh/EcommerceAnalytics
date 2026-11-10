USE EcommerceAnalytics;
GO

DECLARE @ReferenceDate DATE;

SELECT
    @ReferenceDate = MAX(CAST(InvoiceDate AS DATE))
FROM analytics.CleanSales;

WITH CustomerRFM AS (
    SELECT
        CustomerID,

        DATEDIFF(
            DAY,
            MAX(CAST(InvoiceDate AS DATE)),
            @ReferenceDate
        ) AS Recency,

        COUNT(DISTINCT InvoiceNo) AS Frequency,

        SUM(LineRevenue) AS Monetary

    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
RFMScoring AS (
    SELECT
        CustomerID,

        6 - NTILE(5) OVER (
            ORDER BY Recency ASC
        ) AS R_Score,

        NTILE(5) OVER (
            ORDER BY Frequency ASC
        ) AS F_Score,

        NTILE(5) OVER (
            ORDER BY Monetary ASC
        ) AS M_Score

    FROM CustomerRFM
)
SELECT
    R_Score,
    F_Score,
    M_Score,
    COUNT(*) AS CustomerCount
FROM RFMScoring
GROUP BY
    R_Score,
    F_Score,
    M_Score
ORDER BY
    R_Score DESC,
    F_Score DESC,
    M_Score DESC;