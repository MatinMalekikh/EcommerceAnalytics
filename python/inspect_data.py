
from pathlib import Path
import pandas as pd

# File path
file_path = Path(r"D:\EcommerceAnalytics\Online Retail.xlsx")

# Check that the file exists
if not file_path.exists():
    raise FileNotFoundError(f"File not found: {file_path}")

# Load the Excel dataset
df = pd.read_excel(file_path)

# 1. Dataset dimensions
print("\n--- 1. Dataset Shape ---")
print(f"Rows: {df.shape[0]:,}")
print(f"Columns: {df.shape[1]}")

# 2. Column names
print("\n--- 2. Column Names ---")
print(df.columns.tolist())

# 3. Data types and non-null values
print("\n--- 3. Dataset Information ---")
df.info()

# 4. Missing values
print("\n--- 4. Missing Values ---")
print(df.isnull().sum())

# 5. Duplicate rows
print("\n--- 5. Duplicate Rows ---")
print(df.duplicated().sum())

# 6. First five rows
print("\n--- 6. First Five Rows ---")
print(df.head().to_string(index=False))

# 7. Basic statistics
print("\n--- 7. Numerical Statistics ---")
print(df.describe().to_string())

# 8. Cancellation and negative-value checks
print("\n--- 8. Data Quality Checks ---")
print("Invoices starting with C:",
      df["InvoiceNo"].astype(str).str.startswith("C").sum())

print("Rows with Quantity <= 0:",
      (df["Quantity"] <= 0).sum())

print("Rows with UnitPrice < 0:",
      (df["UnitPrice"] < 0).sum())
