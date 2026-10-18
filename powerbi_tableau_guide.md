# Build Guide: Power BI and Tableau Dashboards

Use `data/clean_sales.csv` as the data source in both tools.

## Power BI Desktop (Windows)
1. Home > Get data > Text/CSV > select `clean_sales.csv` > Transform Data. Check that `order_date` is Date and `sales`, `profit` are Decimal. Close & Apply.
2. Create measures (Modeling > New measure):
   - `Total Sales = SUM(clean_sales[sales])`
   - `Total Profit = SUM(clean_sales[profit])`
   - `Profit Margin % = DIVIDE([Total Profit], [Total Sales]) * 100`
   - `Orders = DISTINCTCOUNT(clean_sales[order_id])`
3. Add visuals: 4 KPI cards, line chart (month vs Total Sales), clustered bar (category vs Sales and Profit), map or bar (region vs Sales), donut (segment).
4. Add slicers for `year`, `region` and `category`.
5. Take a screenshot, save it to `images/powerbi_dashboard.png`.

## Tableau Public (free)
1. Connect > Text file > `clean_sales.csv`.
2. Make sheets: Sales by Month (line), Sales and Profit by Category (bar), Profit by Region (bar), Segment share (pie), Discount band vs Margin.
3. Combine them in a Dashboard and add filters for region and year.
4. File > Save to Tableau Public. Copy the public link into the README.

## Tips
- Only describe in your resume what you actually built and can explain.
- Be ready to explain each KPI, one SQL query and one insight in an interview.
