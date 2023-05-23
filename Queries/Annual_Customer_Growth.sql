Select * from public.customers_dataset;
Select * from public.orders_dataset;
Select * from public.payments_dataset;

/*Average number of active customer per month every year*/
Select Round(AVG(Distinct(num_custs)), 2) as avg_num_custs, years
from (
	Select count(Distinct(cust.customer_unique_id)) as num_custs, 
	Extract(Year from ord.order_purchase_timestamp) as  years from 
	public.orders_dataset as ord JOIN
	public.customers_dataset as cust
	ON cust.customer_id = ord.customer_id
	group by 
	Extract(month from ord.order_purchase_timestamp),
	Extract(year from ord.order_purchase_timestamp)
) as ds
Group by years;


/*Number of new customers*/
Select count(customer_unique_id) as new_customer, years 
from
(
	Select cust.customer_unique_id, 
	Min(Extract(Year from ord.order_purchase_timestamp)) as years 
	from public.orders_dataset as ord JOIN
	public.customers_dataset as cust
	ON cust.customer_id = ord.customer_id
	group by 1
)as ds
group by 2
order by 2;

/*Loyal Customers*/
Select count(num_cust) as loyal_customer, years from 
(
	Select 
		cust.customer_unique_id as num_cust,
		Extract(Year from ord.order_purchase_timestamp) as years
	from public.orders_dataset as ord JOIN
	public.customers_dataset as cust
	ON cust.customer_id = ord.customer_id
	group by 1,2
	having count(cust.customer_unique_id) > 1
) as ds
group by 2
order by 2

/*Average Order Number*/
Select Round(AVG(num_ord),3) avg_order, years from
(
	Select 
		cust.customer_unique_id, 
		count(ord.order_id) as num_ord,
		Extract(Year from order_purchase_timestamp) as years
	from
	public.customers_dataset as cust JOIN
	public.orders_dataset as ord
	ON cust.customer_id = ord.customer_id
	group by 1,3
) as ds
group by 2
order by 2


WITH MAU as(
	Select Round(AVG(Distinct(num_custs)), 2) as avg_num_custs, years
	from (
		Select count(Distinct(cust.customer_unique_id)) as num_custs, 
		/*Extract(Month from ord.order_purchase_timestamp) as months,*/
		Extract(Year from ord.order_purchase_timestamp) as  years from 
		public.orders_dataset as ord JOIN
		public.customers_dataset as cust
		ON cust.customer_id = ord.customer_id
		group by 
		Extract(month from ord.order_purchase_timestamp),
		Extract(year from ord.order_purchase_timestamp)
	) as ds
	Group by years
),
new_custs as(
	Select count(customer_unique_id) as num_new_custs, years 
	from
	(
		Select cust.customer_unique_id, 
		Min(Extract(Year from ord.order_purchase_timestamp)) as years 
		from public.orders_dataset as ord JOIN
		public.customers_dataset as cust
		ON cust.customer_id = ord.customer_id
		group by 1
	)as ds
	group by 2
	order by 2
),
repeat_ord as(
	Select count(num_cust) as num_repear_ord, years from 
	(	
		Select 
			cust.customer_unique_id as num_cust,
			Extract(Year from ord.order_purchase_timestamp) as years
		from public.orders_dataset as ord JOIN
		public.customers_dataset as cust
		ON cust.customer_id = ord.customer_id
		group by 1,2
		having count(cust.customer_unique_id) > 1
	) as ds
	group by 2
	order by 2
),
avg_ord as(
	Select Round(AVG(num_ord),3) as avg_num_ord, years from
	(
		Select 
			cust.customer_unique_id, 
			count(ord.order_id) as num_ord,
			Extract(Year from order_purchase_timestamp) as years
		from
		public.customers_dataset as cust JOIN
		public.orders_dataset as ord
		ON cust.customer_id = ord.customer_id
		group by 1,3
	) as ds
	group by 2
	order by 2
)
Select 
	a.years,
	a.avg_num_custs, 
	b.num_new_custs, 
	c.num_repear_ord, 
	d.avg_num_ord 
From 
MAU a 
LEFT JOIN new_custs b on a.years = b.years
LEFT JOIN repeat_ord c on a.years = c.years
LEFT JOIN avg_ord d on a.years = d.years
order by 1;



