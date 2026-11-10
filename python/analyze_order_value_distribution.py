
import pyodbc
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# 1. Database connection
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=EcommerceAnalytics;"
    "Trusted_Connection=yes;"
)

query = """
SELECT
    InvoiceNo,
    InvoiceDate,
    LineRevenue
FROM analytics.CleanSales;
"""

try:
    df = pd.read_sql(query, conn)
finally:
    conn.close()


# 2. Define extreme invoices
extreme_invoices = ["541431", "581483"]

# 3. Calculate total value of each order
orders = (
    df.groupby("InvoiceNo")
    .agg(
        OrderDate=("InvoiceDate", "min"),
        OrderValue=("LineRevenue", "sum")
    )
    .reset_index()
)

# 4. Extract month
orders["Month"] = orders["OrderDate"].dt.to_period("M")


# 5. Original monthly order value distribution
original = (
    orders.groupby("Month")
    .agg(
        OrderCount=("InvoiceNo", "nunique"),
        MeanOrderValue=("OrderValue", "mean"),
        MedianOrderValue=("OrderValue", "median")
    )
)


# 6. Adjusted scenario
adjusted_orders = orders[
    ~orders["InvoiceNo"].isin(extreme_invoices)
]

adjusted = (
    adjusted_orders.groupby("Month")
    .agg(
        OrderCount=("InvoiceNo", "nunique"),
        MeanOrderValue=("OrderValue", "mean"),
        MedianOrderValue=("OrderValue", "median")
    )
)


# 7. Combine results
comparison = pd.DataFrame(index=original.index)

comparison["Orders_Original"] = original["OrderCount"]
comparison["Mean_Original"] = original["MeanOrderValue"]
comparison["Median_Original"] = original["MedianOrderValue"]

comparison["Orders_Adjusted"] = adjusted["OrderCount"]
comparison["Mean_Adjusted"] = adjusted["MeanOrderValue"]
comparison["Median_Adjusted"] = adjusted["MedianOrderValue"]

comparison.index = comparison.index.astype(str)


# 8. Display results
print("=" * 90)
print("MONTHLY ORDER VALUE DISTRIBUTION")
print("=" * 90)

print(comparison.round(2).to_string())


# 9. Plot original mean vs median
plt.figure(figsize=(13, 6))

plt.plot(
    comparison.index,
    comparison["Mean_Original"],
    marker="o",
    label="Mean Order Value"
)

plt.plot(
    comparison.index,
    comparison["Median_Original"],
    marker="o",
    label="Median Order Value"
)

plt.title("Monthly Mean vs Median Order Value")
plt.xlabel("Month")
plt.ylabel("Order Value (£)")
plt.xticks(rotation=45)
plt.grid(alpha=0.3)
plt.legend()
plt.tight_layout()

# 10. Save chart
project_dir = Path(__file__).resolve().parent.parent
figures_dir = project_dir / "figures"
figures_dir.mkdir(exist_ok=True)

output_path = figures_dir / "monthly_mean_vs_median_order_value.png"

plt.savefig(output_path, dpi=300)
plt.close()

print("\nChart saved to:", output_path)
