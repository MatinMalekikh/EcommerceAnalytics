
import pyodbc

connection_string = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=EcommerceAnalytics;"
    "Trusted_Connection=yes;"
)

try:
    connection = pyodbc.connect(connection_string)
    cursor = connection.cursor()

    cursor.execute("SELECT DB_NAME()")

    print("Connection successful!")
    print("Connected database:", cursor.fetchone()[0])

    cursor.close()
    connection.close()

except pyodbc.Error as error:
    print("Connection failed:")
    print(error)
