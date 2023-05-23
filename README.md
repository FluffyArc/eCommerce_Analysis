# **Analyzing E-Commerce Business Performance with SQL**

**Tool:** PostgreSQL<br>
**Visualization:** Tableau<br>
**Dataset:** Rakamin Academy

**Table of Contents:**

- [**Analyzing E-Commerce Business Performance with SQL**](#analyzing-e-commerce-business-performance-with-sql)
- [**Stage 0: Problem Statement**](#stage-0-problem-statement)
  - [Overview](#overview)
  - [Objective](#objective)
- [**Stage 1: Data Preparation**](#stage-1-data-preparation)
  - [Table and ERD Creation](#table-and-erd-creation)
- [**Stage 2: Data Analysis**](#stage-2-data-analysis)
  - [Annual Customer Activity Growth](#annual-customer-activity-growth)
  - [Annual Product Category Quality Analysis](#annual-product-category-quality-analysis)
  - [Annual Payment Type Usage](#annual-payment-type-usage)
- [**Stage 3: Summary**](#stage-3-summary)

---

# **Stage 0: Problem Statement**

---

## Overview

Measuring business performance is crucial for an e-commerce company. This will help unify and assess the success or failure of various business processes.

Business performance measurement can be done by considering several business metrics. In this project, an analysis of the business performance of an e-commerce company will be carried out using business metrics, namely customer growth, product quality, and payment types, based on historical data for three years.

## Objective

Visualize the insight of three primary metrics:

1. Annual Customer Activity Growth
2. Annual Product Category Quality
3. Annual Payment Type Usage

---

# **Stage 1: Data Preparation**

---
The used dataset is from Brazil's e-commerce, with 99.441 records of transactions for three consecutive years from 2016 to 2018.

## Table and ERD Creation

The used dataset is from Brazil's e-commerce, with 99.441 records of transactions for three consecutive years from 2016 to 2018.

There are four primary steps conducted in this phase:

1. Create a database workspace on pgAdmin and create tables using ```CREATE TABLE``` statement.
2. Import the CSV files into the database.
3. Altering the Primary and Foreign Key on the table using ```ALTER TABLE``` statement.
4. Generating an ERD Diagram through the pgAdmin feature.

<details>
<summary>Click here to show the Queries.</summary>

```sql
CREATE TABLE IF NOT EXISTS public.order_items_dataset
(
    order_id text COLLATE pg_catalog."default",
    order_item_id integer,
    product_id text COLLATE pg_catalog."default",
    seller_id text COLLATE pg_catalog."default",
    shipping_limit_date timestamp without time zone,
    price double precision,
    freight_value double precision,
        CONSTRAINT "FK_orderitems_orders" FOREIGN KEY (order_id)
            REFERENCES public.orders_dataset (order_id) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE
            NOT VALID,
        CONSTRAINT "FK_orderitems_products" FOREIGN KEY (product_id)
            REFERENCES public.products_dataset (product_id) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE
            NOT VALID,
        CONSTRAINT "FK_orderitems_sellers" FOREIGN KEY (seller_id)
            REFERENCES public.sellers_dataset (seller_id) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE
            NOT VALID
)
CREATE TABLE IF NOT EXISTS public.sellers_dataset
(
    seller_id text COLLATE pg_catalog."default" NOT NULL,
    seller_zip_code_prefix integer,
    seller_city text COLLATE pg_catalog."default",
    seller_state text COLLATE pg_catalog."default",
        CONSTRAINT sellers_dataset_pkey PRIMARY KEY (seller_id),
        CONSTRAINT "FK_sellers_geolocations" FOREIGN KEY (seller_zip_code_prefix)
            REFERENCES public.geolocations_dataset (geolocation_zip_code_prefix) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE
            NOT VALID
)
CREATE TABLE IF NOT EXISTS public.customers_dataset
(
    customer_id text COLLATE pg_catalog."default" NOT NULL,
    customer_unique_id text COLLATE pg_catalog."default",
    customer_zip_code_prefix integer,
    customer_city text COLLATE pg_catalog."default",
    customer_state text COLLATE pg_catalog."default",
        CONSTRAINT customers_dataset_pkey PRIMARY KEY (customer_id),
        CONSTRAINT "FK_customers_geolocations" FOREIGN KEY (customer_zip_code_prefix)
            REFERENCES public.geolocations_dataset (geolocation_zip_code_prefix) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE
            NOT VALID
)
CREATE TABLE IF NOT EXISTS public.orders_dataset
(
    order_id text COLLATE pg_catalog."default" NOT NULL,
    customer_id text COLLATE pg_catalog."default",
    order_status text COLLATE pg_catalog."default",
    order_purchase_timestamp timestamp without time zone,
    order_approved_at timestamp without time zone,
    order_delivered_carrier_date timestamp without time zone,
    order_delivered_customer_date timestamp without time zone,
    order_estimated_delivery_date timestamp without time zone,
        CONSTRAINT orders_dataset_pkey PRIMARY KEY (order_id),
        CONSTRAINT "FK_orders_customers" FOREIGN KEY (customer_id)
            REFERENCES public.customers_dataset (customer_id) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE
            NOT VALID
)
CREATE TABLE IF NOT EXISTS public.reviews_dataset
(
    review_id text COLLATE pg_catalog."default",
    order_id text COLLATE pg_catalog."default",
    review_score integer,
    review_comment_title text COLLATE pg_catalog."default",
    review_comment_message text COLLATE pg_catalog."default",
    review_creation_date timestamp without time zone,
    review_answer_timestamp timestamp without time zone,
        CONSTRAINT "FK_reviews_orders" FOREIGN KEY (order_id)
            REFERENCES public.orders_dataset (order_id) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE
        NOT VALID
)
CREATE TABLE IF NOT EXISTS public.payments_dataset
(
    order_id text COLLATE pg_catalog."default",
    payment_sequential integer,
    payment_type text COLLATE pg_catalog."default",
    payment_installments integer,
    payment_value double precision,
        CONSTRAINT "FK_payments_orders" FOREIGN KEY (order_id)
            REFERENCES public.orders_dataset (order_id) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE CASCADE
            NOT VALID
)
CREATE TABLE IF NOT EXISTS public.geolocations_dataset
(
    geolocation_zip_code_prefix integer NOT NULL,
    geolocation_lat double precision,
    geolocation_lng double precision,
    geolocation_city text COLLATE pg_catalog."default",
    geolocation_state text COLLATE pg_catalog."default",
        CONSTRAINT geolocations_dataset_pkey PRIMARY KEY (geolocation_zip_code_prefix)
)
CREATE TABLE IF NOT EXISTS public.products_dataset
    (
        product_id text COLLATE pg_catalog."default" NOT NULL,
        product_category_name text COLLATE pg_catalog."default",
        product_name_lenght integer,
        product_description_lenght integer,
        product_photos_qty integer,
        product_weight_g integer,
        product_length_cm integer,
        product_height_cm integer,
        product_width_cm integer,
            CONSTRAINT product_pkey PRIMARY KEY (product_id)
)
``` 
</details>

As the tables are created with both Primary Key and Foreign Key, the ERD Diagram can be automatically generated with pgAdmin.

![ERD_Diagram](https://github.com/FluffyArc/eCommerce_Analysis/assets/40890491/69461601-db0d-4a38-9200-7a530c9e5e80)

---

# **Stage 2: Data Analysis**

---

## Annual Customer Activity Growth

**Objectives:**<br>
Gain some insights for the following information:

1. The average monthly active users for every year.
2. Total number of new customers for every year.
3. Number of loyal customers who purchased the products more than one time
4. The average total order for every customer every year

<details>
<summary>Click here to show the Queries.</summary>

```sql
WITH MAU as(
    Select Round(AVG(Distinct(num_custs)), 2) as avg_num_custs, years
    from 
    (
        Select count(Distinct(cust.customer_unique_id)) as num_custs, 
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
```

</details>

The result of the following query above is shown in the figure below.
![TASK2_Summary](https://github.com/FluffyArc/eCommerce_Analysis/assets/40890491/e189edc0-2e62-4927-be62-35b624fd6ae9)

![Task2_Dashboard](https://github.com/FluffyArc/eCommerce_Analysis/assets/40890491/b0b53b8a-2fa4-4888-8543-0a4b52d16490)

It can be seen on the MAU chart that every year, the number of monthly active users shows a sharp increase from 109 users to 3.695 users in only one year. In contrast, the average number of orders shows that in the given year, most customers only purchased from the marketplace once.

The comparison graph of the number of new customers and the loyal customers provides support information from the previous insight.
It shows that the number of new and loyal customers experienced significant growth in 2017. While the number of new customers remained increased the next year, the number of loyal customers decreased slightly in 2018.

## Annual Product Category Quality Analysis

**Objectives:**<br>
Gain some insights for the following information:

1. The total of the company's revenue every year.
2. The total of cancelation requests every year.
3. Top product that brings the highest revenue every year.
4. Top product that has the most cancelation request every year.

<details>
<summary>Click here to show the Queries.</summary>

```sql
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
        Select 
            order_id,
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
        join public.orders_dataset as b ON a.order_id = b.order_id
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
        join public.orders_dataset as b ON a.order_id = b.order_id
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
```
</details>

![Task3 - Summary](https://github.com/FluffyArc/eCommerce_Analysis/assets/40890491/f8f476a0-35cf-44d4-b357-4a85445352fa)

![Task3_Dashboard](https://github.com/FluffyArc/eCommerce_Analysis/assets/40890491/21d08a8a-cd5e-4adc-9199-74c083b59294)

Based on the line figure, both annual revenue and cancellation have the same uptrend line. The total revenue and cancellation requests **spiked greatly** in the second year (2017). The highest revenue for the eCommerce company accounted for **$8.451.585** in 2018, while the number of cancellation requests stood at **334** in 2018.

As the top profitable product in the given years, the graph shows that the number of profits from the top product increased significantly, where the highest profit was gained from the **health beauty** category in 2018, which stood at **$866.810**.

Furthermore, despite the yearly uptrend in cancelation requests, the category product with the highest requests also comes from the **health beauty** category, which accounted for **27 cancelation requests** in 2018.

## Annual Payment Type Usage
**Objectives:**<br>
Gain some insights for the following information:

1. The total number of every payment type used every year.

<details>
<summary>Click here to show the Queries.</summary>

```sql
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
```
</details>

![Task 4 - Summary](https://github.com/FluffyArc/eCommerce_Analysis/assets/40890491/88f292dc-36e1-4510-911e-7e065cdbd577)

![Task4_Dashboard](https://github.com/FluffyArc/eCommerce_Analysis/assets/40890491/86ca0a86-70cf-419c-8150-43c09ca432b1)

Based on the given figure, it can be seen that most of the customers prefer using credit cards to pay their cart. The usage of credit cards also **spiked greatly** in 2017, from **258 to 35.568** in only one year. In contrast, paying using debit cards is the most less-preferred among the given payment type.

---
# **Stage 3: Summary**
---

Based on the analysis conducted in the previous stage, there are some key points to take:
1. The company needs to build a business strategy to **increase not only the new customers' metrics but also the customer retention metrics** (such as providing more shopping experiences, applying more promos, customer engagement, etc.).
2. The company needs to focus more on **health and beauty** products and conduct product research since the category simultaneously gives the highest revenue and cancelation requests.
3. **Credit card is the preferred payment type among customers**. The company can use this as one of the strategies to retain customers (applying more credit card promos)