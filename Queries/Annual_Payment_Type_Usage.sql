Select * from public.payments_dataset
Select * from public.orders_dataset

/*Number of Favourite Payment Type*/
Select 
	count(payment_type) as num_payment_type,
	payment_type 
from public.payments_dataset
group by payment_type
order by num_payment_type desc

/*Payment Type Details*/
Select
	pay.payment_type,
	count(case when Extract(year from ord.order_purchase_timestamp) = 2016 then pay.payment_type end) as "2016",
	count(case when Extract(year from ord.order_purchase_timestamp) = 2017 then pay.payment_type end) as "2017",
	count(case when Extract(year from ord.order_purchase_timestamp) = 2018 then pay.payment_type end) as "2018",
	count(payment_type) as total_payment_type
from public.payments_dataset as pay
JOIN public.orders_dataset as ord
ON pay.order_id = ord.order_id
group by 1
order by 5 desc
