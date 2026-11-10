
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

# 3. Extract month
df["Month"] = df["InvoiceDate"].dt.to_period("M")

# 4. Calculate original monthly metrics
original = (
    df.groupby("Month")
    .agg(
        Revenue=("LineRevenue", "sum"),
        Orders=("InvoiceNo", "nunique")
    )
)

original["AOV"] = original["Revenue"] / original["Orders"]


# 5. Exclude extreme invoices
adjusted_df = df[
    ~df["InvoiceNo"].isin(extreme_invoices)
]

adjusted = (
    adjusted_df.groupby("Month")
    .agg(
        Revenue=("LineRevenue", "sum"),
        Orders=("InvoiceNo", "nunique")
    )
)

adjusted["AOV"] = adjusted["Revenue"] / adjusted["Orders"]


# 6. Combine both scenarios
comparison = pd.DataFrame(index=original.index)

comparison["Revenue_Original"] = original["Revenue"]
comparison["Orders_Original"] = original["Orders"]
comparison["AOV_Original"] = original["AOV"]

comparison["Revenue_Adjusted"] = adjusted["Revenue"]
comparison["Orders_Adjusted"] = adjusted["Orders"]
comparison["AOV_Adjusted"] = adjusted["AOV"]

comparison["AOV_Change_Percent"] = (
    (comparison["AOV_Adjusted"] - comparison["AOV_Original"])
    / comparison["AOV_Original"] * 100
)

comparison.index = comparison.index.astype(str)


# 7. Display results
print("=" * 75)
print("MONTHLY AVERAGE ORDER VALUE (AOV)")
print("=" * 75)

print(comparison.round(2).to_string())


# 8. Create AOV comparison chart
plt.figure(figsize=(13, 6))

plt.plot(
    comparison.index,
    comparison["AOV_Original"],
    marker="o",
    label="Original AOV"
)

plt.plot(
    comparison.index,
    comparison["AOV_Adjusted"],
    marker="o",
    label="Adjusted AOV"
)

plt.title("Monthly Average Order Value: Original vs Adjusted")
plt.xlabel("Month")
plt.ylabel("Average Order Value (£)")
plt.xticks(rotation=45)
plt.grid(alpha=0.3)
plt.legend()
plt.tight_layout()


# 9. Save chart
project_dir = Path(__file__).resolve().parent.parent
figures_dir = project_dir / "figures"
figures_dir.mkdir(exist_ok=True)

output_path = figures_dir / "monthly_aov_comparison.png"

plt.savefig(output_path, dpi=300)
plt.close()

print("\nChart saved to:", output_path)
