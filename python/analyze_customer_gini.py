
import pyodbc
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
import numpy as np


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


# 3. Calculate total revenue per customer
def calculate_customer_revenue(data):

    return (
        data.groupby("CustomerID")
        .agg(TotalRevenue=("LineRevenue", "sum"))
        .reset_index()
    )


original_customers = calculate_customer_revenue(df)

adjusted_df = df[
    ~df["InvoiceNo"].isin(extreme_invoices)
]

adjusted_customers = calculate_customer_revenue(adjusted_df)


# 4. Calculate Gini coefficient
def calculate_gini(values):

    values = np.sort(np.asarray(values, dtype=float))

    if np.any(values < 0):
        raise ValueError("Gini calculation requires non-negative values.")

    total = values.sum()
    n = len(values)

    if n == 0 or total == 0:
        return np.nan

    indexes = np.arange(1, n + 1)

    gini = (
        np.sum((2 * indexes - n - 1) * values)
        / (n * total)
    )

    return gini


# 5. Calculate Lorenz curve
def calculate_lorenz(values):

    values = np.sort(np.asarray(values, dtype=float))

    total = values.sum()

    if len(values) == 0 or total == 0:
        return np.array([0, 1]), np.array([0, 1])

    cumulative_revenue = np.cumsum(values) / total

    cumulative_population = (
        np.arange(1, len(values) + 1) / len(values)
    )

    # Add the origin point
    lorenz_x = np.insert(cumulative_population, 0, 0)
    lorenz_y = np.insert(cumulative_revenue, 0, 0)

    return lorenz_x, lorenz_y


# 6. Calculate Gini for both scenarios
original_gini = calculate_gini(
    original_customers["TotalRevenue"]
)

adjusted_gini = calculate_gini(
    adjusted_customers["TotalRevenue"]
)


# 7. Display results
print("=" * 75)
print("CUSTOMER REVENUE INEQUALITY ANALYSIS")
print("=" * 75)

print("\nOriginal Scenario:")
print("Customers:", len(original_customers))
print("Total Revenue:",
      round(original_customers["TotalRevenue"].sum(), 2))
print("Gini Coefficient:", round(original_gini, 4))

print("\nAdjusted Scenario:")
print("Customers:", len(adjusted_customers))
print("Total Revenue:",
      round(adjusted_customers["TotalRevenue"].sum(), 2))
print("Gini Coefficient:", round(adjusted_gini, 4))

print("\nGini Change (Adjusted - Original):",
      round(adjusted_gini - original_gini, 4))


# 8. Prepare Lorenz curve data
original_x, original_y = calculate_lorenz(
    original_customers["TotalRevenue"]
)

adjusted_x, adjusted_y = calculate_lorenz(
    adjusted_customers["TotalRevenue"]
)


# 9. Plot Lorenz curves
plt.figure(figsize=(9, 7))

plt.plot(
    original_x,
    original_y,
    label=f"Original (Gini = {original_gini:.4f})"
)

plt.plot(
    adjusted_x,
    adjusted_y,
    label=f"Adjusted (Gini = {adjusted_gini:.4f})"
)

plt.plot(
    [0, 1],
    [0, 1],
    linestyle="--",
    label="Line of Perfect Equality"
)

plt.title("Customer Revenue Lorenz Curve")
plt.xlabel("Cumulative Share of Customers")
plt.ylabel("Cumulative Share of Revenue")
plt.legend()
plt.grid(alpha=0.3)
plt.tight_layout()


# 10. Save chart and results
project_dir = Path(__file__).resolve().parent.parent

figures_dir = project_dir / "figures"
results_dir = project_dir / "results"

figures_dir.mkdir(exist_ok=True)
results_dir.mkdir(exist_ok=True)

chart_path = figures_dir / "customer_revenue_lorenz_curve.png"

plt.savefig(chart_path, dpi=300)
plt.close()


summary = pd.DataFrame({
    "Scenario": ["Original", "Adjusted"],
    "Customer_Count": [
        len(original_customers),
        len(adjusted_customers)
    ],
    "Total_Revenue": [
        original_customers["TotalRevenue"].sum(),
        adjusted_customers["TotalRevenue"].sum()
    ],
    "Gini_Coefficient": [
        original_gini,
        adjusted_gini
    ]
})

summary_path = results_dir / "customer_gini_summary.csv"

summary.to_csv(summary_path, index=False)

print("\nChart saved to:", chart_path)
print("Summary saved to:", summary_path)
