
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
    Quantity,
    Country,
    LineRevenue
FROM analytics.CleanSales;
"""

try:
    df = pd.read_sql(query, conn)
finally:
    conn.close()


# 2. Create output directory
project_dir = Path(__file__).resolve().parent.parent
figures_dir = project_dir / "figures"
figures_dir.mkdir(exist_ok=True)


# 3. Monthly analysis
df["Month"] = df["InvoiceDate"].dt.to_period("M")

monthly = (
    df.groupby("Month")
    .agg(
        Revenue=("LineRevenue", "sum"),
        Orders=("InvoiceNo", "nunique")
    )
    .reset_index()
)

monthly["Month"] = monthly["Month"].astype(str)


# 4. Monthly revenue chart
plt.figure(figsize=(12, 6))
plt.plot(
    monthly["Month"],
    monthly["Revenue"],
    marker="o"
)
plt.title("Monthly Revenue")
plt.xlabel("Month")
plt.ylabel("Revenue (£)")
plt.xticks(rotation=45)
plt.grid(alpha=0.3)
plt.tight_layout()

plt.savefig(figures_dir / "monthly_revenue.png", dpi=300)
plt.close()


# 5. Monthly orders chart
plt.figure(figsize=(12, 6))
plt.plot(
    monthly["Month"],
    monthly["Orders"],
    marker="o"
)
plt.title("Monthly Orders")
plt.xlabel("Month")
plt.ylabel("Number of Orders")
plt.xticks(rotation=45)
plt.grid(alpha=0.3)
plt.tight_layout()

plt.savefig(figures_dir / "monthly_orders.png", dpi=300)
plt.close()


# 6. Country revenue analysis
country_revenue = (
    df.groupby("Country")["LineRevenue"]
    .sum()
    .sort_values(ascending=False)
)

top_10 = country_revenue.head(10)

plt.figure(figsize=(12, 6))
top_10.sort_values().plot(kind="barh")
plt.title("Top 10 Countries by Revenue")
plt.xlabel("Revenue (£)")
plt.ylabel("Country")
plt.tight_layout()

plt.savefig(figures_dir / "top_10_countries.png", dpi=300)
plt.close()


# 7. Country comparison excluding the UK
top_10_without_uk = (
    country_revenue.drop("United Kingdom")
    .head(10)
)

plt.figure(figsize=(12, 6))
top_10_without_uk.sort_values().plot(kind="barh")
plt.title("Top 10 Countries by Revenue (Excluding UK)")
plt.xlabel("Revenue (£)")
plt.ylabel("Country")
plt.tight_layout()

plt.savefig(
    figures_dir / "top_10_countries_without_uk.png",
    dpi=300
)
plt.close()


print("All charts were generated successfully.")
print("Output directory:", figures_dir)
print("\nMonthly summary:")
print(monthly.to_string(index=False))
