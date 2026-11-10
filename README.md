# E-Commerce Analytics: SQL Server & Python

An end-to-end e-commerce analytics project using **Microsoft SQL Server** and **Python** to investigate transactional data, evaluate data quality, analyze sales performance, and understand customer behavior.

The project uses the [UCI Online Retail dataset](https://archive.ics.uci.edu/dataset/352/online+retail) and combines relational database analysis with Python-based statistical analysis and visualization.

## Project Objectives

- Design and populate a SQL Server database for transactional retail data.
- Profile data quality and investigate duplicates, missing values, cancellations, and extreme transactions.
- Build a cleaned analytical sales table using documented business rules.
- Analyze sales performance across time, products, countries, orders, and customers.
- Segment customers using Recency, Frequency, and Monetary (RFM) analysis.
- Evaluate customer retention using cohort analysis.
- Measure customer revenue concentration and inequality.
- Assess how analytical conclusions change under alternative data-exclusion scenarios.
- Communicate findings through reproducible SQL queries, Python scripts, CSV outputs, and visualizations.

## Tech Stack

- **Database:** Microsoft SQL Server
- **Query Language:** T-SQL
- **Programming:** Python 3.11
- **Data Analysis:** pandas, NumPy (where applicable)
- **Visualization:** Matplotlib
- **Database Connectivity:** pyodbc
- **Excel Import:** openpyxl

## Dataset

**Source:** [UCI Online Retail Dataset](https://archive.ics.uci.edu/dataset/352/online+retail)

The dataset contains 541,909 transaction records from December 1, 2010, through December 9, 2011.

The original workbook is not included in this repository. Download it separately and place it in the local project directory as required by the import script.

## Project Structure

```text
EcommerceAnalytics/
├── docs/
│   └── analysis_notes.md
├── figures/
│   └── Generated analytical charts
├── python/
│   └── Data import, analysis, and visualization scripts
├── results/
│   └── Exported analytical CSV files
├── sql/
│   ├── 01_setup/
│   ├── 02_data_quality/
│   ├── 03_cleaning/
│   ├── 04_analysis/
│   └── 05_investigations/
├── .gitignore
├── requirements.txt
└── README.md
```

## Data Preparation

The raw dataset is stored in `raw.OnlineRetail`.

The analytical table `analytics.CleanSales` applies the following initial filtering rules:

- Excludes invoices whose invoice number starts with `C`.
- Excludes rows with non-positive quantities.
- Excludes rows with negative unit prices.
- Retains zero-price transactions.
- Retains missing customer IDs and product descriptions.
- Retains possible duplicate records rather than automatically assuming they are invalid.

The resulting table contains **531,283 rows**, with approximately **£10.67 million** in recorded line revenue.

These rules define a provisional analytical dataset rather than an audited accounting ledger.

## Analytical Work

### Sales Performance
- Monthly revenue, order volume, and sales trends.
- Product and country performance.
- Top customers by recorded revenue.
- Average Order Value (AOV).
- Mean versus median order value.
- Order value percentile analysis.

### Customer Analytics
- Customer revenue concentration.
- Lorenz curve and Gini coefficient.
- RFM scoring and customer segmentation.
- Customer migration between baseline and adjusted segments.
- Customer-level impact analysis.

### Cohort Analysis
- Monthly customer acquisition cohorts.
- Monthly customer retention rates.
- Comparison of baseline and adjusted retention patterns.

### Data Quality and Sensitivity Analysis
- Duplicate record investigation and revenue impact.
- Extreme transaction investigation.
- Non-merchandise transaction analysis.
- Comparison of four RFM scenarios:
  1. Base
  2. Extreme transactions excluded
  3. Non-merchandise items excluded
  4. Both exclusions applied

## Key Findings

### Dataset and Revenue
- Raw records: **541,909**
- CleanSales records: **531,283**
- CleanSales recorded line revenue: **£10,666,684.54**
- Customer-level baseline revenue: **£8,911,407.90**

The two revenue figures have different populations: the first includes all qualifying sales-table rows, while the second includes only transactions associated with valid customer IDs.

### Transaction Sensitivity
Two unusually large transactions were identified:

- Invoice `581483`: £168,469.60
- Invoice `541431`: £77,183.60

Together, they account for **£245,653.20** in recorded revenue.

The adjusted customer-analysis scenario also excludes selected non-merchandise stock codes. The combined exclusions reduce customer-level recorded revenue by **£397,029.45**.

### Customer Segmentation
The baseline RFM analysis identifies Champions as the largest revenue-generating segment.

After applying the combined exclusions and recalculating RFM scores:
- Champions' absolute revenue decreases.
- Champions' share of adjusted customer revenue increases.
- Some customers change segments because their RFM metrics are recalculated.

### Cohort Retention
The baseline and adjusted cohort analyses show very similar retention patterns. The largest observed absolute difference is approximately **0.59 percentage points**.

December 2011 is incomplete because the dataset ends on December 9, 2011. Later cohorts also have shorter observation windows.

### Revenue Concentration
Customer-level revenue concentration is examined using cumulative revenue shares, a Lorenz curve, and the Gini coefficient.

The baseline customer-level Gini coefficient is **0.7152**, calculated across 4,339 customers with valid CustomerIDs.

After excluding the two identified extreme invoices (`541431` and `581483`), the Gini coefficient decreases to **0.7079** across 4,338 customers.

The change of **−0.0073** indicates that these extreme transactions have a limited effect on overall customer revenue inequality. Revenue remains substantially concentrated among a subset of customers.

This comparison excludes extreme invoices only; it does not apply the additional non-merchandise exclusions used in the combined RFM sensitivity scenario.

## Reproducibility

### Requirements

- Python 3.11
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- ODBC Driver for SQL Server
- The original UCI Online Retail Excel workbook

Install Python dependencies:

```bash
pip install -r requirements.txt
```

### Execution Workflow

1. Download the Online Retail workbook from the UCI dataset page.
2. Configure the SQL Server connection and create the `EcommerceAnalytics` database.
3. Import the workbook into `raw.OnlineRetail`.
4. Run the SQL scripts in the appropriate order, starting with database setup and data profiling.
5. Build and validate `analytics.CleanSales`.
6. Execute the analytical and investigation queries.
7. Export the required SQL results into the `results/` directory.
8. Run the Python analysis and visualization scripts from the project environment.

Database connection settings may need to be adapted to the local SQL Server installation.

## Limitations

- Recorded revenue is calculated as `Quantity × UnitPrice`; it does not represent profit.
- The cleaning rules are analytical choices and may affect reported results.
- Possible duplicate rows are investigated but are not automatically removed from the primary analytical table.
- Zero-price rows remain in the cleaned table.
- Transactions without a customer ID are excluded from customer-level analyses.
- RFM segment definitions are heuristic and have not been validated against actual marketing campaign outcomes.
- Cohort retention measures monthly repeat purchasing, not continuous customer activity.
- The dataset covers a limited historical period and does not support conclusions about current retail behavior.
- Extreme transactions and non-merchandise exclusions are sensitivity-analysis scenarios, not definitive corrections to the source data.

## Documentation

Detailed methodology, assumptions, SQL analysis notes, and findings are available in [`docs/analysis_notes.md`](docs/analysis_notes.md).

## Data Attribution

The dataset is provided by the UCI Machine Learning Repository. Refer to the [official dataset page](https://archive.ics.uci.edu/dataset/352/online+retail) for licensing and attribution requirements.