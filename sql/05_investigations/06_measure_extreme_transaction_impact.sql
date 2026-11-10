USE EcommerceAnalytics;
GO

SELECT
    SUM(LineRevenue) AS OriginalRevenue,

    SUM(
        CASE
            WHEN InvoiceNo NOT IN ('541431', '581483')
            THEN LineRevenue
            ELSE 0
        END
    ) AS RevenueWithoutExtremeTransactions,

    SUM(
        CASE
            WHEN InvoiceNo IN ('541431', '581483')
            THEN LineRevenue
            ELSE 0
        END
    ) AS ExtremeTransactionsRevenue,

    COUNT(DISTINCT InvoiceNo) AS TotalInvoices,

    COUNT(DISTINCT
        CASE
            WHEN InvoiceNo IN ('541431', '581483')
            THEN InvoiceNo
        END
    ) AS ExtremeInvoices

FROM analytics.CleanSales;