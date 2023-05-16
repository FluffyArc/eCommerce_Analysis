Select * from public.customers_dataset;
Select * from public.orders_dataset;
Select * from public.payments_dataset;

/*Average number of active customer per month every year*/

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
Group by years;


/*Number of new customers*/
Select count(customer_unique_id), years 
from
(
	Select cust.customer_unique_id, 
	Min(Extract(Day from ord.order_purchase_timestamp)) as days,
	Min(Extract(Month from ord.order_purchase_timestamp)) as months,
	Min(Extract(Year from ord.order_purchase_timestamp)) as years, 
	Min(Extract(hour from ord.order_purchase_timestamp)) as hours,
	Min(Extract(minute from ord.order_purchase_timestamp)) as minutes,
	Min(Extract(second from ord.order_purchase_timestamp)) as seconds from 
	public.orders_dataset as ord JOIN
	public.customers_dataset as cust
	ON cust.customer_id = ord.customer_id
	group by 1
	order by 2,3,5
)as ds
group by 2
;

Select order_status from public.orders_dataset
group by order_status


