/* Data Cleaning
1. Check for NULL values */
SELECT
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN weekofyear IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN weekday IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN is_weekend IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN is_holiday IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN temperature IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN rain_mm IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN channel IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN latitude IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN sku_id IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN sku_name IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN subcategory IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN brand IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN units_sold IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN list_price IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN promo_flag IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN gross_sales IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN net_sales IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN stock_on_hand IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN stock_out_flag IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN lead_time_days IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN supplier_id IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN purchase_cost IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN margin_pct IS NULL THEN 1 ELSE 0 END) AS date_nulls
FROM fmcg_sales;
--2. Add new column in datetime for date
alter table fmcg_sales
add column date_dt DATE;

update fmcg_sales
set date_dt = TO_DATE(date, 'YYYY-MM-DD');

select 
	COUNT(*) as total_rows
	COUNT(date_dt) as converted_row
from fmcg_sales
where date_dt is not null;
/* Feature Engineering 
 * 1. month_name
 */
alter table fmcg_sales
add column month_name varchar(20);

update fmcg_sales 
set month_name = monthname(date);
--2. day_name
alter table fmcg_sales 
add column day_name varchar(20);

update  fmcg_sales 
set day_name = dayname(date);
--3. is_holiday, is_weekend
select
	distinct is_holiday
from fmcg_sales;

select
	distinct is_weekend
from fmcg_sales;

alter table fmcg_sales 
	alter column is_holiday drop default, 
	alter column is_holiday set data type boolean 
		using 
		case is_holiday when 1 then true else false end,
	alter column is_holiday set default false;

alter table fmcg_sales 
	alter column is_weekend drop default,
	alter column is_weekend set data type boolean 
		using
		case is_weekend when 1 then true else false end,
	alter column is_weekend set default false;
--4. promo_flag
select
	distinct promo_flag
from fmcg_sales;

alter table fmcg_sales
	alter column promo_flag drop default,
	alter column promo_flag set data type boolean
		using
		case promo_flag when 1 then true else false end, 
	alter column promo_flag set default false;
--5. stock_out_flag
select
	distinct stock_out_flag
from fmcg_sales;

alter table fmcg_sales
	alter column stock_out_flag drop default,
	alter column stock_out_flag set data type boolean
		using
		case stock_out_flag when 1 then true else false end, 
	alter column stock_out_flag set default false;

/* Exploratory Data Analysis
Purpose: Understand market dynamics and identify drivers of demand
*/
-- Total annual sales by country --
select
	distinct country,
	sum(gross_sales) as total_gross_sales,
	sum(net_sales) as total_net_sales,
	year
from fmcg_sales
group by country, year
order by country, year;

-- Top 10 SKUs in each category by revenue in 2023 --
select
	sku_id,
	sku_name,
	category,
	total_net_sales
from (select 
		distinct sku_id, 
		sku_name,
		category,
		sum(net_sales) as total_net_sales, 
		rank() over (
			partition by category
			order by sum(net_sales) desc) as rank
	from fmcg_sales
	where year = 2023
	group by sku_id, sku_name, category
)
where rank <= 10
order by category, rank;

/* Which subcategory contribute the majority of total revenue, and how concentrated 
 * is revenue across the product portfolio?
 */
create or replace view subcategory_sales as
with sub_net_sales as (
	select 
		distinct subcategory,
		sum(net_sales) as sub_net_sales,
		year
	from fmcg_sales
	group by subcategory, year
	order by subcategory, year
),
total_net_sales as (
	select
		distinct sum(net_sales) over (
			partition by year) as total_sales,
		year
	from fmcg_sales
)
select 
	u.subcategory,
	u.sub_net_sales,
	u.sub_net_sales / t.total_sales as sales_pct,
	u.year
from sub_net_sales u
left join total_net_sales t
on u.year = t.year
order by year, subcategory;

/* Which subcategory and category exhibit stable vs highly volatile sales patterns 
 * over time? (measured by standard deviation of sales volume)
 */
create or replace view v_sales_volatility as
with std_volume as (
	select
		distinct subcategory, 
		category,
		stddev_samp(units_sold) over (
			partition by subcategory) as std_monthly_volume
	from fmcg_sales
)
select *
from std_volume
order by std_monthly_volume;

/* How does promotional activity impact sales volume and revenue compared to
 * non-promotional periods at the SKU level? */
create create or replace view v_promo_uplift as 
with avg_sales as (
	select
		sku_name, 
		promo_flag,
		avg(units_sold) as avg_units_sold, 
		avg(net_sales) as avg_net_sales
	from fmcg_sales
	group by sku_name, promo_flag
	order by sku_name
)
select 
	a1.sku_name,
	a1. promo_flag,
	a1.avg_units_sold - a2.avg_units_sold as diff_units_sold,
	a1.avg_net_sales - a2.avg_net_sales as diff_sales
from avg_sales a1
inner join avg_sales a2
on a1.sku_name = a2.sku_name
where a1.promo_flag != a2.promo_flag and a1.promo_flag = true
order by sku_name;
/* Which SKUs show potential inventory risk based on low on-hand inventory relative
 * to recent sales velocity? */
create or replace view v_inventory_risk as
select 
	sku_id,
	sku_name, 
	avg(units_sold) as avg_units_sold, 
	avg(stock_on_hand) as stock_on_hand, 
	avg(stock_on_hand)/NULLIF(AVG(units_sold), 0) as inventory_to_sales_ratio
from fmcg_sales
group by sku_id, sku_name
order by inventory_to_sales_ratio;

/* How have sales revenue and volum evolved YoY across product categories? 
 */
create or replace view v_category_yoy_performance as
with yearly_category_sales as (
	select
		category,
		cast(sum(net_sales) as numeric) as total_net_sales, 
		cast(sum(units_sold) as numeric) as total_units,
		year
	from fmcg_sales
	group by category, year
)
select 
	category, 
	total_net_sales,
	round((total_net_sales - lag(total_net_sales) over (
		partition by category order by year)) * 100
	/ nullif(lag(total_net_sales) over (
		partition by category order by year), 0), 5) as net_sales_yoy_pct,
	total_units,
	round((total_units - lag(total_units) over (
		partition by category order by year)) * 100
	/ nullif(lag(total_units) over ( 
		partition by category order by year), 0), 5) as units_yoy_pct,
	year
from yearly_category_sales 
order by category, year;


