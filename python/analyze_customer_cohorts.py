
import pyodbc
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# Project paths
BASE_DIR = Path(__file__).resolve().parent.parent
RESULTS_DIR = BASE_DIR / "results"
FIGURES_DIR = BASE_DIR / "figures"

RESULTS_DIR.mkdir(exist_ok=True)
FIGURES_DIR.mkdir(exist_ok=True)

# Connect to SQL Server
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=EcommerceAnalytics;"
    "Trusted_Connection=yes;"
)

# Load customer transactions
query = """
SELECT
    CustomerID,
    InvoiceNo,
    InvoiceDate
FROM analytics.CleanSales
WHERE CustomerID IS NOT NULL;
"""

df = pd.read_sql(query, conn)
conn.close()

# Convert dates
df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"])

# Assign transaction month
df["InvoiceMonth"] = df["InvoiceDate"].dt.to_period("M")

# Find each customer's first purchase month
df["CohortMonth"] = (
    df.groupby("CustomerID")["InvoiceMonth"]
    .transform("min")
)

# Calculate cohort index (0 = first purchase month)
df["CohortIndex"] = (
    (df["InvoiceMonth"].dt.year - df["CohortMonth"].dt.year) * 12
    + (df["InvoiceMonth"].dt.month - df["CohortMonth"].dt.month)
)

# Count unique active customers per cohort and month
cohort_data = (
    df.groupby(["CohortMonth", "CohortIndex"])["CustomerID"]
    .nunique()
    .reset_index(name="ActiveCustomers")
)

# Build cohort customer count matrix
cohort_counts = cohort_data.pivot(
    index="CohortMonth",
    columns="CohortIndex",
    values="ActiveCustomers"
)

# Calculate cohort sizes
cohort_sizes = cohort_counts[0]

# Calculate retention percentages
retention = cohort_counts.divide(cohort_sizes, axis=0) * 100

# Save results
cohort_counts.to_csv(
    RESULTS_DIR / "cohort_customer_counts.csv"
)

retention.to_csv(
    RESULTS_DIR / "cohort_retention.csv"
)

# Plot retention heatmap
plt.figure(figsize=(14, 8))

plt.imshow(
    retention,
    aspect="auto",
    cmap="YlGnBu",
    vmin=0,
    vmax=100
)

plt.colorbar(label="Customer Retention (%)")

plt.xticks(
    range(len(retention.columns)),
    retention.columns
)

plt.yticks(
    range(len(retention.index)),
    retention.index.astype(str)
)

plt.xlabel("Months Since First Purchase")
plt.ylabel("Customer Acquisition Cohort")
plt.title("Customer Cohort Retention Analysis")

# Add percentage labels
for i in range(len(retention.index)):
    for j in range(len(retention.columns)):
        value = retention.iloc[i, j]

        if pd.notna(value):
            plt.text(
                j, i,
                f"{value:.0f}%",
                ha="center",
                va="center",
                fontsize=8
            )

plt.tight_layout()

plt.savefig(
    FIGURES_DIR / "customer_cohort_retention.png",
    dpi=300
)

plt.show()

print("\nCohort Customer Counts:")
print(cohort_counts)

print("\nCohort Retention (%):")
print(retention.round(2))

print("\nFiles saved successfully.")
