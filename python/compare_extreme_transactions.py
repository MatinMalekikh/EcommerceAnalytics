
import pyodbc
import pandas as pd
import matplotlib.pyplot as plt
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

# 3. Create monthly revenue for both scenarios
df["Month"] = df["InvoiceDate"].dt.to_period("M")

df["Revenue_Without_Extremes"] = df["LineRevenue"].where(
    ~df["InvoiceNo"].isin(extreme_invoices),
    0
)

monthly = (
    df.groupby("Month")
    .agg(
        Revenue_All=("LineRevenue", "sum"),
        Revenue_Without_Extremes=("Revenue_Without_Extremes", "sum")
    )
    .reset_index()
)

monthly["Month"] = monthly["Month"].astype(str)

monthly["Removed_Revenue"] = (
    monthly["Revenue_All"] - monthly["Revenue_Without_Extremes"]
)

monthly["Impact_Percent"] = (
    monthly["Removed_Revenue"] / monthly["Revenue_All"] * 100
)


# 4. Print comparison table
print("=" * 65)
print("MONTHLY REVENUE: ALL TRANSACTIONS VS EXCLUDING EXTREME INVOICES")
print("=" * 65)

print(
    monthly.round(2).to_string(index=False)
)


# 5. Create comparison chart
fig, ax = plt.subplots(figsize=(13, 6))

ax.plot(
    monthly["Month"],
    monthly["Revenue_All"],
    marker="o",
    label="All Transactions"
)

ax.plot(
    monthly["Month"],
    monthly["Revenue_Without_Extremes"],
    marker="o",
    label="Excluding Extreme Invoices"
)

ax.set_title("Monthly Revenue: Before and After Excluding Extreme Invoices")
ax.set_xlabel("Month")
ax.set_ylabel("Revenue (£)")
ax.tick_params(axis="x", rotation=45)
ax.grid(alpha=0.3)
ax.legend()

plt.tight_layout()

# 6. Save chart
project_dir = Path(__file__).resolve().parent.parent
figures_dir = project_dir / "figures"
figures_dir.mkdir(exist_ok=True)

output_path = figures_dir / "monthly_revenue_extreme_comparison.png"

plt.savefig(output_path, dpi=300)
plt.close()

print("\nChart saved to:", output_path)
