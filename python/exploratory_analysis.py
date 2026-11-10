
import pyodbc
import pandas as pd

# 1. Database connection
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=EcommerceAnalytics;"
    "Trusted_Connection=yes;"
)

# 2. Load cleaned sales data
query = """
SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    LineRevenue
FROM analytics.CleanSales;
"""

try:
    df = pd.read_sql(query, conn)
finally:
    conn.close()


# 3. Dataset overview
print("=" * 50)
print("DATASET OVERVIEW")
print("=" * 50)

print("Rows and Columns:", df.shape)
print("Date Range:", df["InvoiceDate"].min(), "to", df["InvoiceDate"].max())
print("Unique Invoices:", df["InvoiceNo"].nunique())
print("Unique Customers:", df["CustomerID"].nunique())
print("Unique Products:", df["StockCode"].nunique())
print("Unique Countries:", df["Country"].nunique())


# 4. Missing values
print("\n" + "=" * 50)
print("MISSING VALUES")
print("=" * 50)

print(df.isnull().sum())


# 5. Duplicate records
print("\n" + "=" * 50)
print("DUPLICATE ANALYSIS")
print("=" * 50)

print("Exact Duplicate Rows:", df.duplicated().sum())


# 6. Data quality checks
print("\n" + "=" * 50)
print("DATA QUALITY CHECKS")
print("=" * 50)

print("Non-positive Quantity:", (df["Quantity"] <= 0).sum())
print("Negative UnitPrice:", (df["UnitPrice"] < 0).sum())
print("Zero UnitPrice:", (df["UnitPrice"] == 0).sum())
print("Zero Revenue:", (df["LineRevenue"] == 0).sum())


# 7. Numerical statistics
print("\n" + "=" * 50)
print("NUMERICAL STATISTICS")
print("=" * 50)

numeric_columns = [
    "Quantity",
    "UnitPrice",
    "LineRevenue"
]

print(df[numeric_columns].describe())


# 8. Top 10 countries by revenue
print("\n" + "=" * 50)
print("TOP 10 COUNTRIES BY REVENUE")
print("=" * 50)

country_analysis = (
    df.groupby("Country")
    .agg(
        Orders=("InvoiceNo", "nunique"),
        Customers=("CustomerID", "nunique"),
        UnitsSold=("Quantity", "sum"),
        Revenue=("LineRevenue", "sum")
    )
    .sort_values("Revenue", ascending=False)
    .head(10)
)

print(country_analysis.round(2))
