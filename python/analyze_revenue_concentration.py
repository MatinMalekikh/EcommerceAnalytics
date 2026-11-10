
import pyodbc
import pandas as pd
import math
from pathlib import Path

# 1. Connect to SQL Server
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=EcommerceAnalytics;"
    "Trusted_Connection=yes;"
)

query = """
SELECT
    InvoiceNo,
    LineRevenue
FROM analytics.CleanSales;
"""

try:
    df = pd.read_sql(query, conn)
finally:
    conn.close()


# 2. Calculate total revenue per order
orders = (
    df.groupby("InvoiceNo")
    .agg(OrderValue=("LineRevenue", "sum"))
    .reset_index()
)

# 3. Define extreme invoices
extreme_invoices = ["541431", "581483"]

adjusted_orders = orders[
    ~orders["InvoiceNo"].isin(extreme_invoices)
]


# 4. Calculate revenue concentration
def calculate_concentration(data):

    # Sort orders from highest to lowest value
    sorted_orders = data.sort_values(
        "OrderValue",
        ascending=False
    ).reset_index(drop=True)

    total_revenue = sorted_orders["OrderValue"].sum()
    total_orders = len(sorted_orders)

    results = []

    for percentage in [1, 5, 10, 20]:

        # Number of orders included in the top percentage
        top_n = math.ceil(total_orders * percentage / 100)

        top_revenue = sorted_orders.head(top_n)["OrderValue"].sum()

        revenue_share = (
            top_revenue / total_revenue * 100
        )

        results.append({
            "Top_Percentage": percentage,
            "Order_Count": top_n,
            "Total_Orders": total_orders,
            "Top_Revenue": top_revenue,
            "Total_Revenue": total_revenue,
            "Revenue_Share_Percent": revenue_share
        })

    return pd.DataFrame(results)


# 5. Calculate both scenarios
original_results = calculate_concentration(orders)
adjusted_results = calculate_concentration(adjusted_orders)

original_results["Scenario"] = "Original"
adjusted_results["Scenario"] = "Adjusted"

comparison = pd.concat(
    [original_results, adjusted_results],
    ignore_index=True
)

# 6. Display results
print("=" * 85)
print("REVENUE CONCENTRATION ANALYSIS")
print("=" * 85)

print("\nOriginal and Adjusted Scenarios:\n")

print(
    comparison[
        [
            "Scenario",
            "Top_Percentage",
            "Order_Count",
            "Total_Orders",
            "Top_Revenue",
            "Revenue_Share_Percent"
        ]
    ].round(2).to_string(index=False)
)


# 7. Save results
project_dir = Path(__file__).resolve().parent.parent
results_dir = project_dir / "results"
results_dir.mkdir(exist_ok=True)

output_path = results_dir / "revenue_concentration_by_order.csv"

comparison.to_csv(output_path, index=False)

print("\nResults saved to:", output_path)
