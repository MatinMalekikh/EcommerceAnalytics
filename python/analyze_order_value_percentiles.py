
import pyodbc
import pandas as pd
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


# 2. Calculate invoice-level revenue
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


# 4. Define percentiles
percentiles = [0.25, 0.50, 0.75, 0.90, 0.95, 0.99]


def calculate_percentiles(data):
    return data["OrderValue"].quantile(percentiles)


# 5. Calculate original and adjusted percentiles
original_percentiles = calculate_percentiles(orders)
adjusted_percentiles = calculate_percentiles(adjusted_orders)

comparison = pd.DataFrame({
    "Original": original_percentiles,
    "Adjusted": adjusted_percentiles
})

comparison.index = [
    "P25",
    "P50 (Median)",
    "P75",
    "P90",
    "P95",
    "P99"
]

comparison["Difference"] = (
    comparison["Original"] - comparison["Adjusted"]
)

comparison["Change_Percent"] = (
    (comparison["Adjusted"] - comparison["Original"])
    / comparison["Original"] * 100
)


# 6. Display results
print("=" * 75)
print("OVERALL ORDER VALUE PERCENTILE ANALYSIS")
print("=" * 75)

print("\nNumber of orders:")
print("Original:", len(orders))
print("Adjusted:", len(adjusted_orders))

print("\nPercentile comparison (£):")
print(comparison.round(2).to_string())


# 7. Save results
project_dir = Path(__file__).resolve().parent.parent
results_dir = project_dir / "results"
results_dir.mkdir(exist_ok=True)

output_path = results_dir / "order_value_percentiles.csv"

comparison.to_csv(output_path, index=True)

print("\nResults saved to:", output_path)
