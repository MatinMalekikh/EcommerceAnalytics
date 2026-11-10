USE EcommerceAnalytics;
GO

WITH RemovedCustomers AS (

    SELECT DISTINCT
        CS.CustomerID

    FROM analytics.CleanSales AS CS

    WHERE CS.CustomerID IS NOT NULL

      AND NOT EXISTS (

          SELECT 1
          FROM analytics.CleanSales AS A

          WHERE A.CustomerID = CS.CustomerID
            AND A.InvoiceNo NOT IN ('541431', '581483')
            AND A.StockCode NOT IN (
                'DOT', 'POST', 'M', 'C2', '23444'
            )
      )
)

SELECT
    CS.CustomerID,
    CS.InvoiceNo,
    CS.StockCode,
    CS.Description,
    CS.InvoiceDate,
    CS.Quantity,
    CS.UnitPrice,
    CS.LineRevenue

FROM analytics.CleanSales AS CS

INNER JOIN RemovedCustomers AS RC
    ON CS.CustomerID = RC.CustomerID

ORDER BY
    CS.CustomerID,
    CS.InvoiceDate;