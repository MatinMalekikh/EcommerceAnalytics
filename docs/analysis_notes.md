# Analysis notes and assumptions

## Provisional sales table
`analytics.CleanSales` was created from `raw.OnlineRetail` with:
- `InvoiceNo NOT LIKE 'C%'`
- `Quantity > 0`
- `UnitPrice >= 0`

Observed:
- Rows: 531,283
- Calculated revenue: £10,666,684.544 before rounding
- Missing `CustomerID`: 133,359

## Known data-quality issues
- Raw exact duplicate rows: 5,268 extra rows (10,147 rows are in duplicate groups).
- Cancellation invoices starting with `C`: 9,288 rows.
- Rows with `Quantity <= 0`: 10,624.
- Negative unit prices: 2 rows, including a `B` / `Adjust bad debt` adjustment.
- Zero unit prices: 2,515 rows.
- `PAPER CRAFT, LITTLE BIRDIE` (`23843`) has one raw record for quantity 80,995 at £2.08, totaling £168,469.60. It is not an exact duplicate, but its business validity is unresolved.
- December 2011 is partial; data ends on December 9, 2011.

## Interpretation rules
- Do not delete unusual rows only because they are extreme.
- Revenue is calculated transaction value, not profit or audited net sales.
- Keep raw data unchanged and document analytical exclusions.
- Compare results under different assumptions when useful.


## Data Cleaning Decisions

### 1. Cleaning Rules

The `analytics.CleanSales` table was created from `raw.OnlineRetail` using the following rules:

- Exclude cancellation invoices where `InvoiceNo` starts with `C`.
- Exclude records where `Quantity <= 0`.
- Exclude records where `UnitPrice < 0`.
- Retain records with zero unit prices.
- Retain records with missing `CustomerID` or `Description`.
- Retain duplicate records in the Base Case.

After applying these rules, the resulting table contained **531,283 rows**, with calculated revenue of **£10,666,684.544** and **133,359 records with missing CustomerID**.

### 2. Duplicate Records

The raw dataset contained **5,268 extra rows** belonging to exact duplicate groups.

These records were retained in the Base Case because their presence alone does not establish that they are data-entry errors. Removing them would reduce calculated revenue by approximately **£24,573.74**.

### 3. Extreme Transactions

Two unusually large transactions were identified:

| Invoice | StockCode | Quantity | Unit Price | Line Revenue |
|---|---|---:|---:|---:|
| 581483 | 23843 | 80,995 | £2.08 | £168,469.60 |
| 541431 | 23166 | 74,215 | £1.04 | £77,183.60 |

Their combined revenue was **£245,653.20**.

Both transactions were retained in the Base Case because their business validity could not be conclusively determined. Their impact was evaluated separately through sensitivity analysis.

### 4. Non-Merchandise Transactions

The following stock codes were excluded from the adjusted merchandise analysis:

- `DOT` – DOTCOM POSTAGE
- `POST` – POSTAGE
- `M` – Manual
- `C2` – CARRIAGE
- `23444` – Next Day Carriage

These records were retained in the original cleaned dataset but excluded in the adjusted scenario to focus the analysis on merchandise transactions.

The exclusion reduced identified-customer revenue by **£151,376.25**.

### 5. Missing Values and Zero-Price Records

Records with missing `CustomerID` were retained for overall sales analysis. However, they were excluded from customer-level RFM analysis because individual customer behavior cannot be reliably calculated without a customer identifier.

Zero-price records were also retained because a zero unit price does not necessarily indicate an invalid transaction.

### 6. Cleaning Strategy

The project uses a scenario-based approach rather than applying every possible exclusion directly to the main dataset.

The Base Case preserves unusual but potentially valid records. Adjusted scenarios then evaluate the impact of excluding extreme transactions and non-merchandise stock codes.

This approach makes the assumptions explicit and allows the stability of the analytical results to be evaluated.


## Monthly Sales Analysis

Monthly sales performance was analyzed using the number of invoices, total recorded quantity, and calculated transaction revenue.

### Key Findings

- November 2011 recorded the highest monthly revenue at **£1,509,496.33**, with **2,884 invoices**.
- September and October 2011 also showed strong sales performance, generating **£1,058,590.17** and **£1,154,979.30**, respectively.
- February 2011 recorded the lowest monthly revenue at **£523,631.89**.
- December 2011 had the highest calculated Average Order Value (AOV), at **£761.37**.

The monthly analysis uses three main metrics:

- **Number of Invoices:** Count of distinct invoice numbers.
- **Total Recorded Units:** Sum of the `Quantity` column across all records in each month.
- **Revenue:** Sum of `LineRevenue` for all records in each month.

Since the cleaned dataset retains certain non-merchandise transactions, Total Recorded Units should not be interpreted strictly as the number of physical products sold.

### Average Order Value

Average Order Value was calculated as:

`AOV = Monthly Revenue / Number of Invoices`

### Data Limitation

The dataset ends on **December 9, 2011**. Therefore, December 2011 represents a partial month. Its revenue and AOV should not be directly compared with those of complete months.

### Interpretation

The monthly results show a strong increase in revenue during the final quarter of 2011, with November representing the peak month in the observed period.

Revenue represents calculated transaction value and should not be interpreted as profit.

## Country Sales Analysis

Country-level sales performance was analyzed using the number of orders, identified customers, total recorded quantity, calculated revenue, and Average Order Value (AOV).

### Key Findings

- The United Kingdom was the dominant market, generating £9,025,222.08 in revenue, approximately 84.61% of total recorded revenue.
- The Netherlands and EIRE were the second- and third-largest markets by revenue, generating £285,446.34 and £283,453.96, respectively.
- Germany and France followed, with revenues of £228,867.14 and £209,715.11.
- The five largest markets by revenue accounted for the vast majority of total revenue, indicating a strong concentration of sales in a small number of countries.
- Singapore had the highest AOV at approximately £3,039.90, followed by the Netherlands at £3,004.70. However, these markets recorded only 7 and 95 orders, respectively, so their high AOV values should be interpreted cautiously.

### Metric Definitions

- **Total Orders:** Number of distinct invoices recorded for each country.
- **Total Customers:** Number of distinct non-null CustomerID values associated with each country.
- **Total Recorded Quantity:** Sum of the Quantity column across all records for each country.
- **Total Revenue:** Sum of LineRevenue for each country.
- **Average Order Value (AOV):** Total Revenue divided by Total Orders.

### Data Considerations

- Customer counts include only records with a non-null CustomerID. For example, Hong Kong has 11 orders but zero identified customers.
- Total Recorded Quantity includes all records retained in the cleaned dataset, including certain non-merchandise transactions. Therefore, it should not be interpreted strictly as the quantity of physical products sold.
- Revenue represents calculated transaction value rather than profit.
- Country-level AOV can be heavily influenced by a small number of orders, particularly in countries with low order counts.

### Interpretation

The results show that sales were highly concentrated in the United Kingdom, which contributed approximately 84.61% of total revenue. Other European markets, particularly the Netherlands, EIRE, Germany, and France, represented the next largest contributors.

Some countries recorded relatively high AOV despite having few orders. These results may indicate larger individual transactions, but additional data would be needed to determine whether such patterns represent consistent customer behavior.

## Product Sales Analysis

The top 10 revenue-generating items were identified by aggregating recorded quantity, distinct invoice count, and calculated revenue for each stock code.

### Key Findings

- `DOT` (DOTCOM POSTAGE) ranked first with £206,248.77 in revenue. However, it represents a postage-related charge rather than a physical product.
- `REGENCY CAKESTAND 3 TIER` was the highest-revenue physical product in the reported top 10, generating £174,484.74 across 1,989 invoices.
- `PAPER CRAFT, LITTLE BIRDIE` generated £168,469.60 from a single invoice containing 80,995 units. This is an extreme transaction that was flagged during data-quality analysis.
- `MEDIUM CERAMIC TOP STORAGE JAR` also had unusually high recorded quantity, partly due to the previously identified extreme transaction.
- `Manual` and `POSTAGE` are non-standard transaction items and should not be interpreted as ordinary physical products.

### Interpretation and Data Considerations

The ranking is based on recorded transaction revenue and includes postage, manual entries, and unusual transactions. Therefore, it represents the highest-revenue stock codes in the dataset rather than a clean ranking of physical products.

For a more meaningful product-performance assessment, non-merchandise stock codes and extreme transactions should be examined separately. The distinction between physical merchandise and other transaction types is important when interpreting product revenue and quantity.

## Top Product Performance Analysis

The top 20 revenue-generating stock codes were examined using total recorded quantity, sales-line count, distinct order count, and calculated revenue.

### Key Findings

- `REGENCY CAKESTAND 3 TIER` was the highest-revenue physical product in this ranking, generating £174,484.74 across 1,989 orders.
- `PAPER CRAFT, LITTLE BIRDIE` generated £168,469.60 from a single sales line and one order. This result is driven by the previously identified unusual transaction involving 80,995 recorded units.
- `WHITE HANGING HEART T-LIGHT HOLDER` generated £106,292.77 across 2,260 orders, making it one of the most consistently purchased products in the ranking.
- `JUMBO BAG RED RETROSPOT` had the highest recorded quantity among the regular merchandise items shown, with 48,478 units and £94,340.05 in revenue.
- Postage and manual transaction codes (`DOT`, `POST`, and `M`) also appeared in the ranking and should be treated separately from physical merchandise.

### Metric Definitions

- **Total Recorded Quantity:** Sum of the Quantity values for each stock code.
- **Total Sales Lines:** Number of transaction rows associated with each stock code.
- **Total Orders:** Number of distinct invoices containing the stock code.
- **Total Revenue:** Sum of calculated line revenue for each stock code.

Sales lines and orders measure different things. A single order can contain multiple sales lines for the same stock code.

### Interpretation and Data Considerations

High recorded quantity does not necessarily imply high revenue. Revenue also depends on unit price and transaction characteristics.

The ranking includes unusual transactions and non-merchandise items. Therefore, it should be interpreted as a ranking of stock codes by recorded revenue, not as a definitive ranking of ordinary physical products.

A discrepancy was observed between the recorded quantities for `DOT` and `POST` in this analysis and the earlier top-products query, although their revenue values were unchanged. The underlying query definitions should be reviewed before comparing these quantity figures.

## Product Performance After Excluding Extreme Transactions

The top 20 revenue-generating stock codes were recalculated after excluding the two previously identified extreme transactions.

### Key Findings

- `PAPER CRAFT, LITTLE BIRDIE` disappeared from the ranking because its only recorded sales line belonged to an extreme transaction.
- `REGENCY CAKESTAND 3 TIER` became the highest-revenue physical product, maintaining revenue of £174,484.74 across 1,989 orders.
- `WHITE HANGING HEART T-LIGHT HOLDER` ranked next among physical products, generating £106,292.77 across 2,260 orders.
- `PARTY BUNTING` generated £99,504.33 across 1,686 orders.
- The removal of extreme transactions changed the composition of the top 20 ranking, allowing other products to enter the list.

### Interpretation and Limitations

Excluding the two extreme transactions provides a more representative view of product performance by reducing the influence of unusually large recorded quantities.

However, this analysis still includes non-merchandise stock codes such as `DOT`, `POST`, and `M`. Consequently, it should be interpreted as product-code performance after extreme-transaction exclusion, rather than a ranking limited exclusively to physical merchandise.

The results demonstrate why product rankings should be evaluated under different data-cleaning assumptions before drawing business conclusions.

## Identification of Non-Merchandise Items

A stock-code investigation was conducted to distinguish physical merchandise from postage, manual adjustments, and other service-related transaction entries.

### Identified Non-Merchandise Stock Codes

The following five stock codes were classified as non-merchandise items for the adjusted merchandise analysis:

| Stock Code | Description | Total Revenue |
|---|---|---:|
| DOT | DOTCOM POSTAGE | £206,248.77 |
| M | Manual | £78,112.82 |
| POST | POSTAGE | £78,101.88 |
| C2 | CARRIAGE | £7,051.00 |
| 23444 | Next Day Carriage | £1,200.00 |
| **Total** | | **£370,714.47** |

### Important Classification Considerations

- `DOT`, `POST`, and `C2` represent postage or carriage-related charges.
- `M` represents manual transaction entries.
- `23444` represents a next-day carriage charge.
- The classification was based on specific stock codes rather than broad text matching.
- Products such as `FRENCH CARRIAGE LANTERN` (`23099`) and `BLACK BAROQUE CARRIAGE CLOCK` (`85168B`) were retained because they are physical products despite containing the word "CARRIAGE" in their descriptions.

### Records with Missing Descriptions

Some `DOT` and `POST` records had null descriptions and zero revenue:
- `DOT`: 1 sales line, 1,000 recorded units, £0 revenue.
- `POST`: 4 sales lines, 3,350 recorded units, £0 revenue.

These records affect recorded quantity but do not contribute to calculated revenue.

### Interpretation

The investigation established a specific and reproducible list of non-merchandise stock codes for adjusted merchandise analysis. Using explicit stock-code classification avoids accidentally excluding legitimate products based on broad description matching.

The combined revenue of these five codes is £370,714.47 across the full cleaned dataset. This figure should be distinguished from the revenue impact measured in customer-level analyses, which excludes transactions without an identified CustomerID.

## Top Customer Revenue Analysis

The top 20 customers were ranked by their total calculated revenue. The analysis also considered order frequency, total recorded quantity purchased, country, and Average Order Value (AOV).

### Key Findings

- Customer `14646` from the Netherlands ranked first, generating £280,206.02 across 74 orders.
- Customer `18102` from the United Kingdom ranked second, with £259,657.30 across 60 orders.
- Customer `17450` from the United Kingdom ranked third, generating £194,550.79 across 46 orders.
- Customer `14911` from EIRE recorded 201 orders and generated £143,825.06, demonstrating that high order frequency can contribute substantially to customer revenue.
- Customer `12415` from Australia generated £124,914.53 across 21 orders, showing that relatively high revenue can also come from a lower number of orders.

### Impact of Extreme Transactions

Two customers in the ranking were significantly affected by previously identified extreme transactions:

- Customer `16446` generated £168,472.50 across two orders. This amount includes the unusual £168,469.60 transaction associated with StockCode `23843`.
- Customer `12346` generated £77,183.60 from one order, entirely associated with the previously identified extreme transaction involving StockCode `23166`.

These customers' revenue and AOV figures should therefore be interpreted cautiously. Their rankings may change substantially when extreme transactions are excluded.

### Interpretation

Customer revenue and order frequency measure different aspects of customer value. For example, customer `14911` placed substantially more orders than customer `12415`, while both generated comparable total revenue.

AOV provides additional context by measuring average revenue per order. However, it can be distorted by unusually large transactions, as demonstrated by customer `16446`.

This analysis is based on customers with an identified CustomerID. It measures calculated transaction revenue, not customer profitability.

## Customer Revenue Concentration Analysis

A cumulative revenue analysis was performed to examine how much of the total identified-customer revenue is generated by the highest-revenue customers.

### Key Findings

- Total revenue from customers with an identified CustomerID was £8,911,407.90.
- The top 3 customers contributed approximately 8.24% of identified-customer revenue.
- The top 5 customers contributed approximately 11.75%.
- The top 10 customers contributed approximately 17.26%.
- The top 20 customers contributed approximately 23.86%.
- Customer `14646` was the largest individual contributor, accounting for approximately 3.14% of total identified-customer revenue.

### Interpretation

The results indicate that the highest-revenue customers make a meaningful contribution to overall customer revenue. However, the top 20 customers account for less than one-quarter of the total.

The analysis provides an initial view of customer revenue concentration. A definitive assessment of the Pareto principle requires the cumulative revenue distribution across the full customer population, rather than only the top 20 customers.

### Data Considerations

Two customers in the top 10, `16446` and `12346`, have revenue figures heavily influenced by previously identified extreme transactions. These transactions may distort the apparent concentration of customer revenue.

The denominator used in this analysis includes only customers with a non-null CustomerID. It does not represent total revenue across all records in the cleaned dataset.


## RFM Analysis

### 1. Objective

RFM analysis was conducted to evaluate customer behavior using three dimensions: Recency, Frequency, and Monetary Value. The purpose was to summarize each customer's purchasing activity and provide a behavioral foundation for customer segmentation.

The analysis was performed using the `analytics.CleanSales` table and included only records with a non-null `CustomerID`.

### 2. Reference Date

The reference date was dynamically determined as the maximum transaction date available in `analytics.CleanSales`.

**Reference Date: December 9, 2011**

Using a common reference date ensures that Recency is calculated consistently across all customers.

### 3. RFM Metrics

**Recency (R)**

Recency measures the number of days between a customer's most recent purchase and the reference date.

- A lower Recency value indicates a more recent purchase.
- A higher value indicates that more time has passed since the customer's last purchase.

**Frequency (F)**

Frequency represents the number of distinct invoices associated with each customer.

`COUNT(DISTINCT InvoiceNo)` was used instead of counting transaction rows because a single invoice may contain multiple product lines.

**Monetary (M)**

Monetary represents the total calculated transaction value associated with each customer.

It was calculated as the sum of `LineRevenue` across the customer's transactions.

This metric represents recorded purchase value rather than net profit or audited net sales.

### 4. Customer-Level Aggregation

The raw RFM query groups records by `CustomerID`, producing one row per identified customer.

The resulting dataset contains:

- `CustomerID`
- `LastPurchaseDate`
- `Recency`
- `Frequency`
- `Monetary`

Customers with missing identifiers were excluded because their transactions could not be reliably attributed to individual customers.

### 5. Initial Observations

The initial RFM results showed substantial differences in customer purchasing behavior.

For example:

- Customer 14646 had a Recency of 1 day, a Frequency of 74 invoices, and Monetary value of £280,206.02.
- Customer 18102 had a Recency of 0 days, a Frequency of 60 invoices, and Monetary value of £259,657.30.
- Customer 12346 had only one invoice and a Recency of 325 days, while its Monetary value was £77,183.60.
- Customer 16446 had two invoices and a Monetary value of £168,472.50, heavily influenced by an extreme transaction.

These examples illustrate why customer value should be evaluated across all three RFM dimensions rather than Monetary value alone.

### 6. Analytical Considerations and Limitations

- Frequency measures distinct invoices, not unique shopping days or customer visits.
- Monetary represents calculated transaction value and does not account for product costs, operating expenses, or profit margins.
- Extreme transactions and non-merchandise items can influence Monetary values and customer rankings.
- The reference date is based on the latest date in the available dataset. Since the dataset ends on December 9, 2011, the analysis reflects customer behavior up to that date.
- Only customers with non-null identifiers are included.

To assess the sensitivity of customer scores and segments to data-cleaning decisions, subsequent analyses compare multiple scenarios that exclude extreme transactions and selected non-merchandise items.



### 7. RFM Scoring Methodology

After calculating the raw RFM metrics, each customer was assigned three scores ranging from 1 to 5.

The scoring process used SQL Server's `NTILE(5)` window function to divide customers into five approximately equal-sized groups for each metric.

**Recency Scoring**

Recency was sorted in ascending order because a lower Recency value indicates a more recent purchase.

The score was reversed using:

`R_Score = 6 - NTILE(5)`

This ensures that customers with more recent purchases receive higher scores.

**Frequency Scoring**

Frequency was sorted in ascending order using `NTILE(5)`. Customers with more distinct invoices received higher scores.

**Monetary Scoring**

Monetary was also sorted in ascending order using `NTILE(5)`. Customers with higher recorded purchase values received higher scores.

### 8. RFM Segment Code and Total Score

The three individual scores were combined into a three-digit RFM code:

`RFM_Segment_Code = CONCAT(R_Score, F_Score, M_Score)`

For example:

- `555`: High scores across all three dimensions.
- `543`: High Recency and Frequency scores, with a moderate Monetary score.
- `111`: Low scores across all three dimensions.

An additional metric, `RFM_Total_Score`, was calculated by summing the three individual scores.

The total score ranges from 3 to 15.

However, the total score does not preserve the individual RFM dimensions. Different RFM combinations can produce the same total score. Therefore, the three-digit RFM code is more informative when interpreting customer behavior.

### 9. Scoring Considerations and Limitations

- `NTILE(5)` creates relative customer groups rather than applying fixed business thresholds.
- The five groups are approximately equal in size; exact equality is not guaranteed when the customer count is not divisible by five.
- Customers with identical raw metric values may receive different scores when they fall on different group boundaries.
- The original scoring query does not specify a secondary sorting column for ties. Consequently, exact assignments among tied customers may be nondeterministic.
- RFM scores are population-dependent. Removing transactions or customers can change the group boundaries and therefore affect customer scores, even when an individual customer's remaining transaction history is unchanged.

These considerations are important when comparing RFM results across different data-cleaning scenarios.


### 10. RFM Score Distribution Analysis

After assigning RFM scores, the customer population was grouped by the combination of `R_Score`, `F_Score`, and `M_Score`.

The purpose of this analysis was to examine how customers were distributed across the possible three-dimensional RFM score combinations.

The query used `GROUP BY` on the three score columns and `COUNT(*)` to calculate the number of customers in each combination.

**Key Findings**

- The analysis covered 4,339 identified customers.
- Each individual RFM score was distributed across five approximately equal-sized groups, as expected from the `NTILE(5)` scoring method.
- The Recency score groups contained 867 or 868 customers each.
- The `555` combination contained 348 customers, representing customers in the highest scoring group across all three RFM dimensions.
- Some possible RFM combinations did not appear in the results because no customers received those combinations.

**Interpretation**

The score distribution provides an overview of the customer population and helps identify common and less frequent behavioral profiles.

However, approximately equal group sizes are a structural consequence of `NTILE(5)` and should not be interpreted as evidence that the scoring model is inherently accurate or effective.

The three-dimensional score combinations provide more behavioral detail than the total RFM score alone because different combinations can have the same sum while representing different purchasing patterns.

**Methodological Consideration**

The distribution depends on the underlying customer population and the ordering rules used by `NTILE(5)`. Customers with identical metric values may be assigned to different score groups when they fall across group boundaries. A deterministic secondary ordering, such as `CustomerID`, is useful for reproducible comparisons across scenarios.


### 11. Customer RFM Segmentation

#### Objective

The RFM scores were converted into eight behavioral customer segments using a rule-based classification approach.

The purpose was to translate numerical customer scores into interpretable groups that can support customer relationship management and marketing decisions.

#### Segmentation Rules

The following rules were applied in the SQL `CASE` expression:

| Segment | Conditions |
|---|---|
| Champions | R >= 4, F >= 4, M >= 4 |
| Loyal Customers | R >= 3, F >= 4 |
| Big Spenders | M >= 4 |
| Potential Loyalists | R >= 4, F IN (2, 3) |
| Recent Customers | R >= 4, F = 1 |
| At Risk | R <= 2, F >= 3 |
| Hibernating | R <= 2, F <= 2 |
| Needs Attention | All remaining customers |

The order of the `CASE` conditions is important. SQL evaluates the conditions sequentially and assigns each customer to the first matching segment.

For example, a customer with scores of `555` satisfies the conditions for Champions, Loyal Customers, and Big Spenders. However, the customer is assigned to Champions because that condition appears first.

Consequently, Big Spenders represents customers with high Monetary scores who were not assigned to one of the preceding segments.

#### Base Scenario Results

The initial segmentation included 4,339 identified customers.

| Segment | Customers | Total Revenue |
|---|---:|---:|
| Hibernating | 992 | £299,344.72 |
| Champions | 946 | £5,759,478.91 |
| Big Spenders | 548 | £1,363,110.96 |
| Loyal Customers | 499 | £916,738.34 |
| Needs Attention | 451 | £173,888.68 |
| At Risk | 397 | £199,441.04 |
| Potential Loyalists | 371 | £161,082.11 |
| Recent Customers | 135 | £38,323.14 |
| **Total** | **4,339** | **£8,911,407.90** |

#### Key Findings

- Champions represented approximately 21.8% of identified customers but contributed 64.63% of identified-customer revenue.
- Hibernating was the largest segment by customer count, representing approximately 22.86% of customers but only 3.36% of revenue.
- Big Spenders represented approximately 12.63% of customers and contributed 15.30% of revenue.
- The Champions segment had the highest average customer revenue, while Hibernating customers had substantially lower average purchasing value.

These findings indicate that customer count and revenue contribution are distributed differently across segments.

#### Business Interpretation

Potential strategies based on the segments include:

- **Champions:** Retention programs, VIP benefits, and personalized offers.
- **Loyal Customers:** Loyalty rewards, cross-selling, and complementary product recommendations.
- **Big Spenders:** Personalized high-value offers and initiatives to encourage repeat purchases.
- **Potential Loyalists:** Incentives to encourage additional purchases and strengthen engagement.
- **Recent Customers:** Onboarding campaigns and strategies to encourage a second purchase.
- **At Risk:** Win-back campaigns and targeted incentives to reactivate previously active customers.
- **Hibernating:** Cost-conscious reactivation campaigns, prioritizing customers with potential future value.
- **Needs Attention:** Further behavioral analysis and targeted engagement based on individual customer characteristics.

These strategies are recommendations inferred from the RFM profiles, not experimentally validated campaign outcomes.

#### Methodological Limitations

- The segmentation rules are heuristic business rules rather than universally established customer classifications.
- The `CASE` condition order affects segment membership because customers are assigned to the first matching condition.
- Segment sizes and customer scores depend on the underlying population and the relative `NTILE(5)` scoring method.
- Monetary values include the effects of extreme transactions and selected non-merchandise items in the Base scenario.
- Revenue contribution is calculated using identified-customer revenue, excluding transactions that cannot be attributed to a known customer.

For these reasons, the segmentation results were subsequently evaluated under alternative data-cleaning scenarios to assess their sensitivity to extreme transactions and non-merchandise items.


## RFM Segmentation Sensitivity Analysis

### Objective
This analysis evaluates how excluding extreme transactions and non-merchandise items affects customer RFM segmentation and segment-level performance.

### Scenario Definitions
- **Base Case:** Includes all qualifying customer transactions in `analytics.CleanSales`.
- **Adjusted Case:** Excludes invoices `541431` and `581483`, as well as non-merchandise stock codes `DOT`, `POST`, `M`, `C2`, and `23444`.

Both scenarios use the same reference date, December 9, 2011. RFM metrics and scores are recalculated independently for each scenario.

### Key Results

The Base Case contains 4,339 identified customers and £8,911,407.904 in revenue. The Adjusted Case contains 4,335 customers and £8,514,378.454 in revenue.

The total revenue reduction is £397,029.45, equivalent to approximately 4.46% of Base Case identified-customer revenue. Four customers have no qualifying transactions remaining in the Adjusted Case.

Big Spenders experienced the largest segment-level revenue reduction, decreasing from £1,363,110.961 to £1,090,951.601, a reduction of £272,159.36. This represents approximately 68.5% of the total revenue reduction.

Champions remained the largest revenue-generating segment. Its revenue decreased from £5,759,478.91 to £5,670,915.58, while its share of total identified-customer revenue increased from approximately 64.63% to 66.60%.

Potential Loyalists experienced a revenue increase from £161,082.11 to £162,586.53. This does not indicate new revenue generation; it reflects customer reclassification after RFM scores were recalculated.

### Interpretation

The results indicate that customer segments differ in their sensitivity to data exclusions. Big Spenders are particularly sensitive in terms of absolute revenue, while Champions remain comparatively stable as the dominant revenue-generating segment.

The increase in Champions' revenue share should be interpreted carefully. Its absolute revenue declined, but its proportion of total revenue increased because the overall revenue denominator decreased by a larger proportion.

### Limitations

RFM scores are recalculated independently within each scenario using `NTILE(5)`. Therefore, segment-level revenue changes combine two effects:

1. Revenue removed through transaction exclusions.
2. Customer migration between segments caused by recalculated RFM scores.

Consequently, the revenue reduction of a segment cannot be interpreted solely as the value of excluded transactions originally associated with that segment.

The segment definitions are heuristic business rules and have not been validated against actual marketing campaign outcomes.




## Extreme Transaction Impact on Monthly Revenue

Two unusually large transactions were examined to assess their influence on monthly revenue:

- Invoice 541431, recorded in January 2011, contributed £77,183.60.
- Invoice 581483, recorded in December 2011, contributed £168,469.60.

Together, these transactions accounted for £245,653.20 in recorded revenue.

Their impact varied across months:

- January 2011 revenue decreased by 11.16% after excluding the extreme transaction.
- December 2011 revenue decreased by 26.37%.
- Revenue from September through November 2011 remained unchanged.

**Key finding:** The observed revenue growth from September to November was not driven by these two extreme transactions. The upward trend remained unchanged after their exclusion.

December 2011 covers only the first nine days of the month, so its revenue should not be directly compared with full months.


## Average Order Value (AOV) Analysis

Average Order Value (AOV) was calculated as total monthly revenue divided by the number of unique invoices.

Two scenarios were compared: the original dataset and an adjusted dataset excluding invoices 541431 and 581483.

**Key findings:**

- January 2011 AOV decreased from £617.29 to £548.87 after excluding invoice 541431, an 11.08% reduction.
- December 2011 AOV decreased from £761.37 to £561.24 after excluding invoice 581483, a 26.29% reduction.
- AOV remained unchanged in all other months.
- From September to November 2011, revenue increased by approximately 42.6%, while order volume increased by approximately 52.1%.
- Over the same period, AOV decreased from £558.33 to £523.40, a reduction of approximately 6.3%.

**Interpretation:** The revenue growth observed between September and November was primarily associated with an increase in the number of orders rather than an increase in average order value.

December 2011 includes only the first nine days of the month and should therefore be interpreted separately from complete months.

The mean AOV is sensitive to unusually large orders. Further analysis of median order value can provide a more robust view of typical transaction size.


## Mean vs. Median Order Value Analysis

To better understand the distribution of order values, monthly mean and median order values were calculated using invoice-level revenue. The analysis was performed under both the original and adjusted scenarios, with the adjusted scenario excluding invoices 541431 and 581483.

### Key Findings

- The monthly mean order value exceeded the median in every month, indicating a right-skewed distribution of order values.
- In November 2011, the mean order value was £523.40, while the median was £289.57. This substantial gap suggests that relatively large orders increased the average.
- Between September and November 2011, the median order value decreased from £318.48 to £289.57, while the number of orders increased from 1,896 to 2,884.
- Removing the two extreme invoices had a substantial effect on the mean order value in January and December 2011, but almost no effect on the median.
- In January, the mean decreased from £617.29 to £548.87, while the median remained £304.02.
- In December, the mean decreased from £761.37 to £561.24, while the median changed only slightly, from £287.90 to £287.35.

### Interpretation

The consistent difference between mean and median indicates that monthly order values are positively skewed. A relatively small number of high-value orders can substantially influence the mean, making the median a more robust indicator of a typical order.

The September–November period also suggests that revenue growth coincided with an increase in order volume rather than an increase in typical order value.

### Limitations

- The dataset covers December 2010 through December 2011.
- December 2011 contains data only through December 9 and should not be compared directly with complete months.
- The analysis measures recorded order revenue, not profit.
- The median describes the middle order value and does not capture the full distribution of order sizes.

### Conclusion

Using both mean and median order values provides a more complete understanding of sales behavior. The mean captures the influence of high-value orders, while the median provides a more robust measure of typical order value.


## Order Value Percentile Analysis

To examine the distribution of order values beyond the mean and median, percentile analysis was conducted using invoice-level revenue. The 25th, 50th, 75th, 90th, 95th, and 99th percentiles were calculated under the original and adjusted scenarios.

### Key Findings

In the original scenario, the percentile values were:

| Percentile | Order Value |
|---|---:|
| P25 | £138.24 |
| P50 (Median) | £298.88 |
| P75 | £481.70 |
| P90 | £913.33 |
| P95 | £1,542.91 |
| P99 | £4,688.54 |

The gap between the 75th and 99th percentiles indicates a long upper tail in the order value distribution. While 75% of orders were valued at £481.70 or less, the top 1% exceeded £4,688.54.

### Sensitivity to Extreme Transactions

The adjusted scenario excluded invoices 541431 and 581483. The overall order count decreased from 20,726 to 20,724.

The percentile values changed only slightly. For example, P50 decreased from £298.88 to £298.86, while P99 decreased from £4,688.54 to £4,665.46, a reduction of approximately 0.49%.

This suggests that the two identified extreme transactions had a limited effect on the overall percentile distribution, despite their substantial impact on monthly mean order values.

### Interpretation

The distribution of order values is strongly right-skewed, with a relatively small proportion of high-value orders extending the upper tail. The median and lower percentiles provide a more representative view of typical orders, while the upper percentiles help identify high-value purchasing behavior.

### Limitations

- Percentiles were calculated across all invoices, including orders without an identified CustomerID.
- The analysis measures recorded order revenue rather than profit.
- Percentile values describe the distribution of orders and do not directly measure customer-level purchasing behavior.

### Conclusion

Percentile analysis complements mean and median order value metrics by showing how order values are distributed across the dataset. The findings confirm a long upper tail and demonstrate that the two identified extreme invoices have limited influence on the overall percentile thresholds.



## Revenue Concentration Analysis at Order Level

This analysis examines how recorded revenue is distributed across orders by ranking invoices according to their total order value. Revenue concentration was calculated for the top 1%, 5%, 10%, and 20% of orders under the original and adjusted scenarios.

### Key Findings

In the original scenario:

| Order Group | Number of Orders | Revenue Share |
|---|---:|---:|
| Top 1% | 208 | 19.69% |
| Top 5% | 1,037 | 38.76% |
| Top 10% | 2,073 | 50.10% |
| Top 20% | 4,146 | 63.89% |

The results indicate substantial revenue concentration. The top 10% of orders generated approximately 50.10% of total recorded revenue, while the top 20% generated 63.89%.

### Sensitivity to Extreme Transactions

After excluding invoices 541431 and 581483, the concentration levels were:

| Order Group | Adjusted Revenue Share |
|---|---:|
| Top 1% | 17.88% |
| Top 5% | 37.34% |
| Top 10% | 48.94% |
| Top 20% | 63.04% |

The largest change occurred in the top 1% group, whose revenue share decreased from 19.69% to 17.88%. However, substantial concentration remained across all groups.

This indicates that the observed concentration is not solely driven by the two identified extreme transactions.

### Interpretation

A relatively small proportion of orders accounts for a substantial share of recorded revenue. This pattern suggests that high-value orders play an important role in the store's sales performance.

The persistence of concentration in the adjusted scenario provides evidence that the pattern extends beyond the two extreme invoices.

### Limitations

- The analysis measures concentration at the order level, not the customer level.
- A single customer may contribute multiple orders to the top groups.
- Revenue represents recorded transaction value, not profit.
- The number of orders in each group is rounded upward when calculating percentage-based groups.

### Conclusion

Order-level revenue concentration analysis reveals that a relatively small share of orders generates a substantial proportion of total recorded revenue. Further customer-level concentration analysis would be necessary to determine whether revenue is similarly dependent on a small number of customers.

## Customer-Level Revenue Concentration Analysis

This analysis examines how revenue is distributed across identifiable customers. Unlike order-level concentration analysis, revenue from all orders belonging to the same customer was aggregated before ranking customers by total revenue.

Customers with missing CustomerID values were excluded because their purchases could not be reliably attributed to individual customers.

### Key Findings

In the original scenario, customer revenue concentration was as follows:

| Customer Group | Number of Customers | Revenue Share |
|---|---:|---:|
| Top 1% | 44 | 32.00% |
| Top 5% | 217 | 50.38% |
| Top 10% | 434 | 61.38% |
| Top 20% | 868 | 74.62% |

The results reveal substantial customer-level revenue concentration. The top 10% of identifiable customers generated approximately 61.38% of their total recorded revenue.

### Sensitivity to Extreme Transactions

After excluding invoices 541431 and 581483, the number of identifiable customers decreased from 4,339 to 4,338.

| Customer Group | Original Revenue Share | Adjusted Revenue Share |
|---|---:|---:|
| Top 1% | 32.00% | 30.52% |
| Top 5% | 50.38% | 49.11% |
| Top 10% | 61.38% | 60.36% |
| Top 20% | 74.62% | 73.95% |

Although the exclusion of extreme transactions reduced concentration, the overall pattern remained substantial. In the adjusted scenario, the top 10% of customers still accounted for approximately 60.36% of identifiable customer revenue.

### Interpretation

The results suggest that a relatively small group of customers contributes a substantial proportion of the store's recorded revenue.

This finding highlights the potential importance of customer retention and relationship management. However, revenue concentration alone does not establish customer profitability or future purchasing behavior.

### Limitations

- Customers with missing CustomerID values were excluded.
- The analysis measures recorded revenue, not profit.
- A high revenue contribution does not necessarily imply high customer profitability.
- Direct comparison with order-level concentration percentages requires caution because the two analyses use different populations and revenue denominators.

### Conclusion

Customer-level revenue concentration is substantial. Even after excluding the two identified extreme transactions, the top 10% of identifiable customers generated approximately 60.36% of customer-attributed revenue. This indicates that a relatively small group of customers plays an important role in the store's recorded sales performance.


## Customer Revenue Inequality: Lorenz Curve and Gini Coefficient

To quantify customer-level revenue inequality, the Lorenz curve and Gini coefficient were calculated using total revenue per identifiable customer.

Customer revenue was aggregated across all invoices before calculating the inequality metrics. The analysis was performed under the original and adjusted scenarios, with the adjusted scenario excluding invoices 541431 and 581483.

### Results

| Scenario | Customer Count | Total Revenue | Gini Coefficient |
|---|---:|---:|---:|
| Original | 4,339 | £8,911,407.90 | 0.7152 |
| Adjusted | 4,338 | £8,665,754.70 | 0.7079 |

### Key Findings

The original scenario produced a Gini coefficient of 0.7152, indicating substantial inequality in the distribution of recorded revenue across identifiable customers.

After excluding the two extreme invoices, the Gini coefficient decreased to 0.7079, representing an absolute reduction of 0.0073.

Although the exclusion reduced measured inequality, the adjusted Gini remained relatively close to the original value. This suggests that the observed customer revenue concentration is not explained solely by the two identified extreme transactions.

### Interpretation

The Lorenz curve provides a visual representation of cumulative customer revenue inequality. Greater deviation from the line of perfect equality indicates a more unequal revenue distribution.

The Gini coefficient summarizes this inequality in a single value. The results reinforce the earlier customer-level concentration findings: a relatively small group of customers accounts for a substantial share of recorded revenue.

### Limitations

- Customers with missing CustomerID values were excluded.
- The metric measures recorded revenue, not profit.
- Gini does not explain why revenue inequality exists or predict future customer behavior.
- Comparisons should be interpreted within the context of this dataset and its customer population.

### Conclusion

The customer-level Gini analysis confirms substantial revenue inequality. Although excluding the two extreme invoices reduced the Gini coefficient from 0.7152 to 0.7079, the overall inequality pattern remained. This provides additional evidence that customer revenue concentration is a persistent characteristic of the analyzed dataset.


## Customer Cohort Retention Sensitivity Analysis

### Objective

This analysis evaluates whether the customer cohort retention results are sensitive to the data-cleaning decisions applied in the project. Two scenarios are compared:

- **Base:** All records in `analytics.CleanSales` with a non-null `CustomerID`.
- **Adjusted:** Excludes the two extreme invoices (`541431` and `581483`) and non-merchandise stock codes (`DOT`, `POST`, `M`, `C2`, and `23444`).

For each scenario, customer acquisition cohorts and monthly retention rates were recalculated independently. A customer's cohort is defined by the calendar month of their first qualifying purchase. Monthly retention represents the percentage of customers in a cohort who made at least one purchase in a given subsequent month.

### Cohort Size Comparison

The Base scenario contains 4,339 identifiable customers, while the Adjusted scenario contains 4,335. Only four customers are excluded entirely after applying the adjusted filters.

Most cohort sizes remain unchanged. The differences are concentrated in three acquisition cohorts:

| Cohort | Base Customers | Adjusted Customers | Difference |
|---|---:|---:|---:|
| 2011-01 | 417 | 415 | -2 |
| 2011-07 | 188 | 187 | -1 |
| 2011-10 | 358 | 357 | -1 |

All other cohort sizes remain unchanged.

The number of transaction rows decreases from 397,924 to 396,305. This reduction is substantially larger than the change in customer count because the filters remove transaction records, while most affected customers still have other qualifying purchases.

### Retention Rate Comparison

The retention matrices show very similar patterns across the two scenarios.

Most differences between Adjusted and Base retention rates are small. The largest absolute difference observed is approximately **0.59 percentage points**, occurring in the August 2011 cohort:

- Month 1: 20.71% in Base versus 20.12% in Adjusted.
- Month 2: 24.85% in Base versus 24.26% in Adjusted.

Other examples include:

- July 2011 cohort, Month 1: 18.09% versus 17.65%.
-