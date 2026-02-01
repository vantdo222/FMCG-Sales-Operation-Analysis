📊 **FMCG Sales & Operations Analysis**

Tableau | SQL | FMCG Analytics | Sales & Operations

This project features an end-to-end FMCG analytics solution combining SQL-based data exploration with a Tableau dashboard. Using three years of transactional sales data (~1M rows), the project analyzes forecast accuracy, promotions, inventory risk, service levels, and regional performance.

---

🧠 **Overview**

This dashboard provides operations leaders and planners with a clear, data-driven view of FMCG performance across demand and supply. SQL was used to explore, validate, and structure the data, while Tableau was used to visualize KPIs that support Sales & Operations Planning (S&OP) decisions.

---

🔧 **Tools & Techniques**

**SQL** 
- Designed reusable SQL views to answer executive and S&OP business questions
- Applied advanced SQL techniques including CTEs, window functions (ROW_NUMBER, LAG), GROUP BY, HAVING, and CASE logic
- Built analytics for ABC revenue concentration and XYZ sales volatility (proxy-based) segmentation
- Implemented promo uplift analysis comparing promotional vs non-promotional performance
- Created heuristic inventory risk metrics using inventory-to-sales ratios
- Calculated year-over-year (YoY) revenue and volume growth by product category
- Performed data quality checks, data type standardization, and NULL auditing
- Optimized queries with proper aggregation logic and safe division (NULLIF, casting)

**Tableau:**
- Service level KPIs (fill rate, availability)
- Geographic sales mapping using latitude and longitude
- Subcategory Analysis
- TOP 5 suppliers by lead time
- Sales distribution by brand

---

🗂 **Data Model / Schema**

The project uses a transaction-level fact table enriched with product, time, and geographic attributes. Data was explored and validated in SQL before being visualized in Tableau.

**Core Fact Table:**
- Transaction date
- SKU / product identifier
- Quantity sold
- Revenue
- Promotion flag
- Inventory status
- Lead time

**Dimension Attributes:**
- Product: category, brand
- Time: year, month
- Geography: country, city, latitude, longitude

The schema supports SKU-level, regional, and time-based analysis, enabling flexible aggregation for S&OP and operational reporting.

---

📈 **Use Cases**

- Identify high-impact SKUs driving the majority of revenue for portfolio focus
- Segment products by sales stability vs volatility to inform planning and inventory strategy
- Evaluate promotional effectiveness to optimize trade spend and campaign targeting
- Flag potential inventory risk based on low coverage relative to recent sales velocity
- Track year-over-year category performance to support strategic investment decisions
- Assess revenue dependency risk across SKUs, categories, and suppliers to improve business resilience

---

💡 **Key Insights**

- High-revenue SKUs with volatile demand represent significant planning risk
- Not all promotions generate positive uplift, indicating margin leakage
- Regional growth is sometimes offset by service level underperformance
- Lead time variability is a key driver of stockouts and overstock
- Inventory optimization can improve service levels without increasing stock
