
import pyodbc
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# --------------------------------------------------
# 1. Project paths
# --------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent
RESULTS_DIR = BASE_DIR / "results"
FIGURES_DIR = BASE_DIR / "figures"

RESULTS_DIR.mkdir(exist_ok=True)
FIGURES_DIR.mkdir(exist_ok=True)

# --------------------------------------------------
# 2. Connect to SQL Server
# --------------------------------------------------

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
    StockCode,
    InvoiceDate
FROM analytics.CleanSales
WHERE CustomerID IS NOT NULL;
"""

df = pd.read_sql(query, conn)
conn.close()

df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"])
df["InvoiceNo"] = df["InvoiceNo"].astype(str)
df["StockCode"] = df["StockCode"].astype(str).str.strip()

# --------------------------------------------------
# 3. Define scenarios
# --------------------------------------------------

extreme_invoices = ["541431", "581483"]

non_merchandise_codes = [
    "DOT", "POST", "M", "C2", "23444"
]

base_df = df.copy()

adjusted_df = df[
    (~df["InvoiceNo"].isin(extreme_invoices))
    & (~df["StockCode"].isin(non_merchandise_codes))
].copy()

# --------------------------------------------------
# 4. Cohort analysis function
# --------------------------------------------------

def calculate_cohort_retention(data):

    data = data.copy()

    data["InvoiceMonth"] = (
        data["InvoiceDate"].dt.to_period("M")
    )

    # Find first purchase month for each customer
    data["CohortMonth"] = (
        data.groupby("CustomerID")["InvoiceMonth"]
        .transform("min")
    )

    # Calculate months since first purchase
    data["CohortIndex"] = (
        (data["InvoiceMonth"].dt.year - data["CohortMonth"].dt.year) * 12
        + (data["InvoiceMonth"].dt.month - data["CohortMonth"].dt.month)
    )

    # Count unique active customers
    cohort_data = (
        data.groupby(["CohortMonth", "CohortIndex"])["CustomerID"]
        .nunique()
        .reset_index(name="ActiveCustomers")
    )

    counts = cohort_data.pivot(
        index="CohortMonth",
        columns="CohortIndex",
        values="ActiveCustomers"
    )

    # Cohort sizes
    cohort_sizes = counts[0]

    # Retention percentages
    retention = counts.divide(cohort_sizes, axis=0) * 100

    return counts, retention


# --------------------------------------------------
# 5. Calculate both scenarios
# --------------------------------------------------

base_counts, base_retention = calculate_cohort_retention(base_df)

adjusted_counts, adjusted_retention = calculate_cohort_retention(
    adjusted_df
)

# --------------------------------------------------
# 6. Align matrices for comparison
# --------------------------------------------------

all_cohorts = base_retention.index.union(
    adjusted_retention.index
)

all_periods = base_retention.columns.union(
    adjusted_retention.columns
)

base_aligned = base_retention.reindex(
    index=all_cohorts,
    columns=all_periods
)

adjusted_aligned = adjusted_retention.reindex(
    index=all_cohorts,
    columns=all_periods
)

# Difference in percentage points
retention_difference = adjusted_aligned - base_aligned

# --------------------------------------------------
# 7. Save CSV files
# --------------------------------------------------

base_counts.to_csv(
    RESULTS_DIR / "cohort_counts_base.csv"
)

adjusted_counts.to_csv(
    RESULTS_DIR / "cohort_counts_adjusted.csv"
)

base_retention.to_csv(
    RESULTS_DIR / "cohort_retention_base.csv"
)

adjusted_retention.to_csv(
    RESULTS_DIR / "cohort_retention_adjusted.csv"
)

retention_difference.to_csv(
    RESULTS_DIR / "cohort_retention_difference.csv"
)

# --------------------------------------------------
# 8. Plot comparison heatmaps
# --------------------------------------------------

fig, axes = plt.subplots(
    1, 3,
    figsize=(24, 9)
)

datasets = [
    (base_retention, "Base Retention (%)", 0, 100),
    (adjusted_retention, "Adjusted Retention (%)", 0, 100),
    (retention_difference, "Adjusted - Base (pp)", None, None)
]

for ax, (matrix, title, vmin, vmax) in zip(axes, datasets):

    values = matrix.to_numpy(dtype=float)

    if vmin is None:
        image = ax.imshow(
            values,
            aspect="auto",
            cmap="RdYlGn",
        )
    else:
        image = ax.imshow(
            values,
            aspect="auto",
            cmap="YlGnBu",
            vmin=vmin,
            vmax=vmax
        )

    fig.colorbar(image, ax=ax)

    ax.set_title(title)
    ax.set_xlabel("Months Since First Purchase")
    ax.set_ylabel("Customer Acquisition Cohort")

    ax.set_xticks(range(len(matrix.columns)))
    ax.set_xticklabels(matrix.columns)

    ax.set_yticks(range(len(matrix.index)))
    ax.set_yticklabels(matrix.index.astype(str))

    # Add cell labels
    for i in range(len(matrix.index)):
        for j in range(len(matrix.columns)):

            value = matrix.iloc[i, j]

            if pd.notna(value):
                ax.text(
                    j, i,
                    f"{value:.1f}",
                    ha="center",
                    va="center",
                    fontsize=7
                )

plt.suptitle(
    "Customer Cohort Retention: Base vs Adjusted",
    fontsize=16
)

plt.tight_layout()

plt.savefig(
    FIGURES_DIR / "cohort_retention_sensitivity.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()

# --------------------------------------------------
# 9. Print summary
# --------------------------------------------------

print("\nScenario Summary:")

print(f"Base rows: {len(base_df):,}")
print(f"Adjusted rows: {len(adjusted_df):,}")

print(
    "Base customers:",
    base_df["CustomerID"].nunique()
)

print(
    "Adjusted customers:",
    adjusted_df["CustomerID"].nunique()
)

print("\nBase Cohort Sizes:")
print(base_counts[0])

print("\nAdjusted Cohort Sizes:")
print(adjusted_counts[0])

print("\nBase Retention:")
print(base_retention.round(2))

print("\nAdjusted Retention:")
print(adjusted_retention.round(2))

print("\nRetention Difference (Adjusted - Base):")
print(retention_difference.round(2))

print("\nAll results saved successfully.")
