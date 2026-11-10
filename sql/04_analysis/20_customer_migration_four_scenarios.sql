
DECLARE @ReferenceDate DATE;

SELECT @ReferenceDate = MAX(CAST(InvoiceDate AS DATE))
FROM analytics.CleanSales;

WITH CustomerUniverse AS
(
    SELECT DISTINCT CustomerID
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL
),

ScenarioList AS
(
    SELECT Scenario
    FROM (VALUES
        ('Base'),
        ('Extreme Only'),
        ('Non-Merchandise Only'),
        ('Combined')
    ) AS S(Scenario)
),

ScenarioSales AS
(
    -- Base: تمام تراکنش‌های معتبر جدول CleanSales
    SELECT
        'Base' AS Scenario,
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        LineRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL

    UNION ALL

    -- Extreme Only: حذف دو فاکتور پرت
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

    -- Non-Merchandise Only: حذف کدهای غیرکالایی
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

    -- Combined: حذف هم‌زمان فاکتورهای پرت و کدهای غیرکالایی
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

CustomerRFM AS
(
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
    FROM ScenarioSales
    GROUP BY Scenario, CustomerID
),

RFMScoring AS
(
    SELECT
        Scenario,
        CustomerID,
        Recency,
        Frequency,
        Monetary,

        6 - NTILE(5) OVER (
            PARTITION BY Scenario
            ORDER BY Recency ASC, CustomerID ASC
        ) AS RScore,

        NTILE(5) OVER (
            PARTITION BY Scenario
            ORDER BY Frequency ASC, CustomerID ASC
        ) AS FScore,

        NTILE(5) OVER (
            PARTITION BY Scenario
            ORDER BY Monetary ASC, CustomerID ASC
        ) AS MScore

    FROM CustomerRFM
),

CustomerSegmentation AS
(
    SELECT
        Scenario,
        CustomerID,
        Recency,
        Frequency,
        Monetary,
        RScore,
        FScore,
        MScore,

        CASE
            WHEN RScore >= 4 AND FScore >= 4 AND MScore >= 4
                THEN 'Champions'

            WHEN RScore >= 3 AND FScore >= 4
                THEN 'Loyal Customers'

            WHEN MScore >= 4
                THEN 'Big Spenders'

            WHEN RScore >= 4 AND FScore IN (2, 3)
                THEN 'Potential Loyalists'

            WHEN RScore >= 4 AND FScore = 1
                THEN 'Recent Customers'

            WHEN RScore <= 2 AND FScore >= 3
                THEN 'At Risk'

            WHEN RScore <= 2 AND FScore <= 2
                THEN 'Hibernating'

            ELSE 'Needs Attention'
        END AS Segment

    FROM RFMScoring
),

CustomerScenarioGrid AS
(
    SELECT
        U.CustomerID,
        S.Scenario
    FROM CustomerUniverse U
    CROSS JOIN ScenarioList S
),

CustomerWide AS
(
    SELECT
        G.CustomerID,

        MAX(CASE WHEN G.Scenario = 'Base'
            THEN COALESCE(C.Segment, 'Removed') END) AS BaseSegment,

        MAX(CASE WHEN G.Scenario = 'Extreme Only'
            THEN COALESCE(C.Segment, 'Removed') END) AS ExtremeOnlySegment,

        MAX(CASE WHEN G.Scenario = 'Non-Merchandise Only'
            THEN COALESCE(C.Segment, 'Removed') END) AS NonMerchandiseOnlySegment,

        MAX(CASE WHEN G.Scenario = 'Combined'
            THEN COALESCE(C.Segment, 'Removed') END) AS CombinedSegment,

        MAX(CASE WHEN G.Scenario = 'Base'
            THEN COALESCE(C.Monetary, 0) END) AS BaseRevenue,

        MAX(CASE WHEN G.Scenario = 'Combined'
            THEN COALESCE(C.Monetary, 0) END) AS CombinedRevenue

    FROM CustomerScenarioGrid G
    LEFT JOIN CustomerSegmentation C
        ON G.CustomerID = C.CustomerID
       AND G.Scenario = C.Scenario

    GROUP BY G.CustomerID
)

SELECT
    BaseSegment,
    ExtremeOnlySegment,
    NonMerchandiseOnlySegment,
    CombinedSegment,

    COUNT(*) AS CustomerCount,

    SUM(BaseRevenue) AS BaseRevenue,
    SUM(CombinedRevenue) AS CombinedRevenue,

    SUM(BaseRevenue - CombinedRevenue) AS RevenueReduction

FROM CustomerWide

GROUP BY
    BaseSegment,
    ExtremeOnlySegment,
    NonMerchandiseOnlySegment,
    CombinedSegment

ORDER BY
    CustomerCount DESC;
