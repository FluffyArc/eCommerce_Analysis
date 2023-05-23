Select * from public.payments_dataset

Select * from public.orders_dataset
where order_status = 'canceled'

Select count(*), order_status from public.orders_dataset
group by order_status

Select count(a.*), b.order_status from 
public.order_items_dataset as a join
public.orders_dataset as b
ON a.order_id = b.order_id
group by 2

/*Annual Revenue*/
Select Round(Cast (SUM(price + freight_value) as numeric), 2) as revenue, years from
(
	Select 
		a.order_id, 
		a.price, 
		a.freight_value,
		b.order_status,
		Extract(year from b.order_purchase_timestamp) as years
	from 
	public.order_items_dataset as a join
	public.orders_dataset as b
	ON 
	a.order_id = b.order_id and
	b.order_status like 'delivered'
) as ds
Where years is not NULL
group by 2

/*Cancelled Order*/
Select count(order_id) as cancelled, years from
(
	Select order_id,
	Extract(year from order_purchase_timestamp) as years
	from public.orders_dataset
	where order_status = 'canceled'
) as ds
Where years is not NULL
group by 2


/*Top Purchased Product*/
Select
	product_category_name,
	revenue,
	years
from
(
	Select 
		Round(cast(SUM(a.price+a.freight_value) as numeric), 2) as revenue,
		Extract(year from b.order_purchase_timestamp) as years,
		c.product_category_name,
		Rank() over
		(
			Partition by Extract(year from b.order_purchase_timestamp)
			Order by SUM(a.price+a.freight_value) desc
		) as ranks
	from 
	public.order_items_dataset as a 
	join public.orders_dataset as b	ON a.order_id = b.order_id
	join public.products_dataset as c ON a.product_id = c.product_id
	Where b.order_status like 'delivered'
	group by 2,3
	order by ranks
) as ds
Where ranks = 1

/*Top Cancelled Product*/
Select 
	product_category_name,
	num_order as num_of_cancelation,
	years
from
(
	Select 
		count(a.order_id) as num_order,
		Extract(year from b.order_purchase_timestamp) as years,
		c.product_category_name,
		Rank() over
		(
			Partition by Extract(year from b.order_purchase_timestamp)
			Order by count(a.order_id) desc
		) as ranks
	from 
	public.order_items_dataset as a 
	join public.orders_dataset as b	ON a.order_id = b.order_id
	join public.products_dataset as c ON a.product_id = c.product_id
	Where b.order_status like 'canceled'
	group by 2,3
	order by ranks
) ds
where ranks = 1

/*Summary Table*/
	With annual_revenue as
	(
		Select Round(Cast (SUM(price + freight_value) as numeric), 2) as revenue, years from
		(
			Select 
				a.order_id, 
				a.price, 
				a.freight_value,
				b.order_status,
				Extract(year from b.order_purchase_timestamp) as years
			from 
			public.order_items_dataset as a join
			public.orders_dataset as b
			ON 
			a.order_id = b.order_id and
			b.order_status like 'delivered'
		) as ds
		Where years is not NULL
		group by 2
	),
	cancelled_order as
	(
		Select count(order_id) as cancelled, years from
		(
			Select order_id,
			Extract(year from order_purchase_timestamp) as years
			from public.orders_dataset
			where order_status = 'canceled'
		) as ds
		Where years is not NULL
		group by 2
	),
	top_purchased_product as
	(
		Select
			product_category_name,
			revenue,
			years
		from
		(
			Select 
				Round(cast(SUM(a.price+a.freight_value) as numeric), 2) as revenue,
				Extract(year from b.order_purchase_timestamp) as years,
				c.product_category_name,
				Rank() over
				(
					Partition by Extract(year from b.order_purchase_timestamp)
					Order by SUM(a.price+a.freight_value) desc
				) as ranks
			from 
			public.order_items_dataset as a 
			join public.orders_dataset as b	ON a.order_id = b.order_id
			join public.products_dataset as c ON a.product_id = c.product_id
			Where b.order_status like 'delivered'
			group by 2,3
			order by ranks
		) as ds
		Where ranks = 1
	),
	top_cancelled_product as
	(
		Select 
			product_category_name,
			num_order as num_of_cancelation,
			years
		from
		(
			Select 
				count(a.order_id) as num_order,
				Extract(year from b.order_purchase_timestamp) as years,
				c.product_category_name,
				Rank() over
				(
					Partition by Extract(year from b.order_purchase_timestamp)
					Order by count(a.order_id) desc
				) as ranks
			from 
			public.order_items_dataset as a 
			join public.orders_dataset as b	ON a.order_id = b.order_id
			join public.products_dataset as c ON a.product_id = c.product_id
			Where b.order_status like 'canceled'
			group by 2,3
			order by ranks
		) ds
		where ranks = 1
	)
	Select
		a.years,
		a.revenue as total_revenue,
		b.cancelled as total_cancelation,
		c.product_category_name as top_purchased_products,
		c.revenue as total_revenue_top_products,
		d.product_category_name as top_cancelled_products,
		d.num_of_cancelation as total_cancelled_products
	from annual_revenue a
	JOIN cancelled_order b on a.years = b.years
	JOIN top_purchased_product c on a.years = c.years
	JOIN top_cancelled_product d on a.years = d.years