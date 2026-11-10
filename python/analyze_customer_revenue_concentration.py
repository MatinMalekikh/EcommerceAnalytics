
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
    CustomerID,
    InvoiceNo,
    LineRevenue
FROM analytics.CleanSales
WHERE CustomerID IS NOT NULL;
"""

try:
    df = pd.read_sql(query, conn)
finally:
    conn.close()


# 2. Define extreme invoices
extreme_invoices = ["541431", "581483"]


# 3. Calculate revenue per customer
def calculate_customer_revenue(data):

    customer_revenue = (
        data.groupby("CustomerID")
        .agg(
            TotalRevenue=("LineRevenue", "sum"),
            OrderCount=("InvoiceNo", "nunique")
        )
        .reset_index()
    )

    return customer_revenue


original_customers = calculate_customer_revenue(df)

adjusted_df = df[
    ~df["InvoiceNo"].isin(extreme_invoices)
]

adjusted_customers = calculate_customer_revenue(adjusted_df)


# 4. Calculate customer revenue concentration
def calculate_concentration(data):

    sorted_customers = data.sort_values(
        "TotalRevenue",
        ascending=False
    ).reset_index(drop=True)

    total_revenue = sorted_customers["TotalRevenue"].sum()
    total_customers = len(sorted_customers)

    results = []

    for percentage in [1, 5, 10, 20]:

        top_n = math.ceil(
            total_customers * percentage / 100
        )

        top_revenue = (
            sorted_customers.head(top_n)["TotalRevenue"].sum()
        )

        revenue_share = (
            top_revenue / total_revenue * 100
        )

        results.append({
            "Top_Percentage": percentage,
            "Customer_Count": top_n,
            "Total_Customers": total_customers,
            "Top_Revenue": top_revenue,
            "Total_Revenue": total_revenue,
            "Revenue_Share_Percent": revenue_share
        })

    return pd.DataFrame(results)


# 5. Compare scenarios
original_results = calculate_concentration(original_customers)
adjusted_results = calculate_concentration(adjusted_customers)

original_results["Scenario"] = "Original"
adjusted_results["Scenario"] = "Adjusted"

comparison = pd.concat(
    [original_results, adjusted_results],
    ignore_index=True
)


# 6. Display results
print("=" * 85)
print("CUSTOMER-LEVEL REVENUE CONCENTRATION ANALYSIS")
print("=" * 85)

print("\nCustomer counts:")
print("Original:", len(original_customers))
print("Adjusted:", len(adjusted_customers))

print("\nRevenue concentration:\n")

print(
    comparison[
        [
            "Scenario",
            "Top_Percentage",
            "Customer_Count",
            "Total_Customers",
            "Top_Revenue",
            "Revenue_Share_Percent"
        ]
    ].round(2).to_string(index=False)
)


# 7. Save results
project_dir = Path(__file__).resolve().parent.parent
results_dir = project_dir / "results"
results_dir.mkdir(exist_ok=True)

output_path = (
    results_dir / "customer_revenue_concentration.csv"
)

comparison.to_csv(output_path, index=False)

print("\nResults saved to:", output_path)
