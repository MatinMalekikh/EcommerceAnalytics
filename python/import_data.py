
from pathlib import Path

import pandas as pd
import pyodbc

# --------------------------------------------------
# 1. Configuration
# --------------------------------------------------

file_path = Path(r"D:\EcommerceAnalytics\Online Retail.xlsx")

connection_string = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=EcommerceAnalytics;"
    "Trusted_Connection=yes;"
)

# --------------------------------------------------
# 2. Load the original dataset
# --------------------------------------------------

print("Loading Excel file...")

df = pd.read_excel(file_path)

print(f"Rows loaded from Excel: {len(df):,}")

# --------------------------------------------------
# 3. Connect to SQL Server
# --------------------------------------------------

connection = pyodbc.connect(connection_string)
cursor = connection.cursor()

try:
    # Create schema if it does not exist.
    cursor.execute("""
        IF SCHEMA_ID('raw') IS NULL
            EXEC('CREATE SCHEMA raw');
    """)

    # Create the raw table if it does not exist.
    cursor.execute("""
        IF OBJECT_ID('raw.OnlineRetail', 'U') IS NULL
        BEGIN
            CREATE TABLE raw.OnlineRetail (
                InvoiceNo   VARCHAR(20) NOT NULL,
                StockCode   VARCHAR(30) NOT NULL,
                Description NVARCHAR(255) NULL,
                Quantity    INT NOT NULL,
                InvoiceDate DATETIME2 NOT NULL,
                UnitPrice   DECIMAL(12, 4) NOT NULL,
                CustomerID  INT NULL,
                Country     NVARCHAR(100) NOT NULL
            );
        END
    """)

    # Prevent accidentally importing duplicate data on reruns.
    cursor.execute("""
        SELECT COUNT_BIG(*)
        FROM raw.OnlineRetail;
    """)

    existing_rows = cursor.fetchone()[0]

    if existing_rows > 0:
        raise RuntimeError(
            f"The target table already contains "
            f"{existing_rows:,} rows. "
            "Import stopped to prevent duplicate records."
        )

    connection.commit()

    # --------------------------------------------------
    # 4. Prepare rows for insertion
    # --------------------------------------------------

    columns = [
        "InvoiceNo",
        "StockCode",
        "Description",
        "Quantity",
        "InvoiceDate",
        "UnitPrice",
        "CustomerID",
        "Country",
    ]

    insert_sql = """
        INSERT INTO raw.OnlineRetail (
            InvoiceNo, StockCode, Description, Quantity,
            InvoiceDate, UnitPrice, CustomerID, Country
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    """

    cursor.fast_executemany = True

    batch_size = 2000
    total_rows = len(df)

    # --------------------------------------------------
    # 5. Insert rows in batches
    # --------------------------------------------------

    for start in range(0, total_rows, batch_size):
        batch_df = df.iloc[start:start + batch_size]
        records = []

        for row in batch_df[columns].itertuples(
            index=False, name=None
        ):
            values = []

            for column, value in zip(columns, row):
                if pd.isna(value):
                    value = None

                elif column == "CustomerID":
                    value = int(value)

                elif column == "Quantity":
                    value = int(value)

                elif column == "InvoiceDate":
                    value = pd.Timestamp(value).to_pydatetime()

                elif column == "UnitPrice":
                    value = float(value)

                values.append(value)

            records.append(tuple(values))

        cursor.executemany(insert_sql, records)
        connection.commit()

        imported = min(start + len(records), total_rows)
        print(f"Imported {imported:,} / {total_rows:,} rows")

    # --------------------------------------------------
    # 6. Verify the import
    # --------------------------------------------------

    cursor.execute("""
        SELECT COUNT_BIG(*)
        FROM raw.OnlineRetail;
    """)

    sql_rows = cursor.fetchone()[0]

    print("\nImport completed successfully!")
    print(f"Excel rows: {total_rows:,}")
    print(f"SQL rows:   {sql_rows:,}")

    if sql_rows != total_rows:
        print("WARNING: The row counts do not match.")

except Exception:
    connection.rollback()
    raise

finally:
    cursor.close()
    connection.close()
