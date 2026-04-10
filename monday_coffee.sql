select * from city;
select * from products;
select * from customers;
select * from sales;


--reports and data analysis
-- coffee consume count
--1) how many people in each city are estimated to consume coffee , giving that 25% of the population does?

select city_name,
round((population *0.25)/1000000,2) as coffee_consumer_in_millions,
city_rank from city
order by 2 desc;

--2)Total revenue from coffee sales
--what is the total revenu generated from coffee sales  across all cities  in the last quater of 2023

select 
	ci.city_name,
	sum(s.total)as total_revenu
	from sales as s
	join customers as c
	on s.customer_id = c.customer_id
	join city as ci
	on ci.city_id= c.city_id	
where 
extract(year from s.sale_date) =2023
and
extract(quarter from s.sale_date) = 4
group by 1
order by 2 desc



--3)sales count for each product
---how many units of each coffee product have been sold?


select p.product_name, count(s.sale_id) as total_orders
 from products as p
left join sales as s
on p.product_id= s.product_id
group by p.product_name
order by total_orders desc

--4) Average sales amount per city
--what is the average sales amount per customer in each city?

select cu.customer_name, avg(total)as asv_sales_amount_per_customer 
from sales as s
join customers as cu
on s.customer_id = cu.customer_id
group by cu.customer_name

select 
	ci.city_name,
	sum(s.total)as total_revenu,
	count(Distinct s.customer_id) as total_customer,
	round(sum(s.total)::numeric/count(Distinct s.customer_id)::numeric,2 )as avg_sales_per_customer
	from sales as s
	join customers as c
	on s.customer_id = c.customer_id
	join city as ci
	on ci.city_id= c.city_id	
group by 1
order by 2 desc

--5)city population and coffe consumers(25%)
--provide  a list of cities along with their population and estimated coffe consumer.
--return cit name, total current customer, estimated coffee consumer(25%)


with city_table as
(
select 
	city_name,
	round((population * 0.25)/1000000,2) as coffee_consumer_per_city

from city
),
customer_table
as

(select c.city_name,
count(distinct cu.customer_id) as unique_customer
from sales as s
join customers as cu
on cu.customer_id= s.customer_id
join city as c
on c.city_id=cu.city_id
group by c.city_name
)

select ct.city_name,
ct.coffee_consumer_per_city,
cit.unique_customer
from city_table as ct
join customer_table cit
on ct.city_name=cit.city_name



select * from city;
select * from products;
select * from customers;
select * from sales;

--6) Top selling product by city
--what are the top 3 selling product in each city based on sales volume


select * from
(select ci.city_name,
		p.product_name,
		count(s.sale_id) as total_orders,
		dense_rank()over(partition by ci.city_name order by count(s.sale_id)desc) as rank
 from products as p
join sales as s
on p.product_id = s.product_id
join customers as cu
on cu.customer_id = s.customer_id
join city as ci
on ci.city_id = cu.city_id
group by ci.city_name,p.product_name
)as t1
where rank<=3


select * from city;
select * from products;
select * from customers;
select * from sales;


--7) customer segmentation by city
--how many unique customer are there in each city who have purchase coffee product

select Distinct(customer_name )
from customers;

select ci.city_name,
count(distinct cu.customer_id) as unique_customer
from city as ci
left join customers as cu
on ci.city_id = cu.city_id
join sales as s
on cu.customer_id= s.customer_id
group by ci.city_name



select * from city;
select * from products;
select * from customers;
select * from sales;
--8)avg sale vs rent
-- find each city and their avg sales per customer and avg rent per customer


select ct.city_name,
		round(sum(s.total)::numeric/count(distinct s.customer_id)::numeric,2) "Total Sales/customer",
        round(avg(ct.estimated_rent)::numeric/count(distinct s.customer_id)::numeric,2) "Rent/customer"
from customers as c
join city as ct
on c.city_id = ct.city_id
join sales s
on c.customer_id = s.customer_id
group by ct.city_name
order by 2 desc

--9)monthly sales growth
--sales growth rate: calculate the percentage growth in sales over different time period(monthly)

/*select
     ci.city_name,
     extract(month from sale_date) as month,
     extract(year from sale_date) as year,
sum(s.total) as total_sales,
lag(total_sales,1) over(partition by city_name order by year,month )as last_month_sale
from sales s
join customers as cu
on s.customer_id = cu.customer_id
join city as ci
on ci.city_id = cu.city_id
group by ci.city_name,month,year
order by ci.city_name,year ,month asc */


--10)market potential analysis
--identify top 3 city 	based on highest sales , return city name,total sales ,total rent, total customer
--estimated coffee consumer





WITH city_table
AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) as total_revenue,
		COUNT(DISTINCT s.customer_id) as total_cx,
		ROUND(
				SUM(s.total)::numeric/
					COUNT(DISTINCT s.customer_id)::numeric
				,2) as avg_sale_pr_cx
		
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS
(
	SELECT 
		city_name, 
		estimated_rent,
		ROUND((population * 0.25)/1000000, 3) as estimated_coffee_consumer_in_millions
	FROM city
)
SELECT 
	cr.city_name,
	total_revenue,
	cr.estimated_rent as total_rent,
	ct.total_cx,
	estimated_coffee_consumer_in_millions,
	ct.avg_sale_pr_cx,
	ROUND(
		cr.estimated_rent::numeric/
									ct.total_cx::numeric
		, 2) as avg_rent_per_cx
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 2 DESC



/*
-- Recomendation
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k



