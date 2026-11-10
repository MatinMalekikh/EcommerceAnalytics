USE EcommerceAnalytics;
GO

WITH CustomerRevenue AS (
    SELECT
        CustomerID,
        SUM(LineRevenue) AS TotalRevenue
    FROM analytics.CleanSales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
RankedCustomers AS (
    SELECT
        CustomerID,
        TotalRevenue,

        ROW_NUMBER() OVER (
            ORDER BY TotalRevenue DESC
        ) AS CustomerRank,

        SUM(TotalRevenue) OVER () AS TotalCustomerRevenue,

        SUM(TotalRevenue) OVER (
            ORDER BY TotalRevenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS CumulativeRevenue

    FROM CustomerRevenue
)
SELECT TOP 20
    CustomerRank,
    CustomerID,
    TotalRevenue,
    TotalCustomerRevenue,
    CumulativeRevenue,
    100.0 * TotalRevenue / TotalCustomerRevenue
        AS RevenueContributionPercent,
    100.0 * CumulativeRevenue / TotalCustomerRevenue
        AS CumulativeRevenuePercent
FROM RankedCustomers
ORDER BY CustomerRank;