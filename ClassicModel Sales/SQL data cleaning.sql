/*sales net profit from 2004*/
SELECT t1.orderDate,t1.orderNumber,quantityOrdered,priceEach,productName,productLine,buyPrice,city,country 
FROM orders t1
inner join orderdetails t2
on t1.orderNumber = t2.orderNumber
inner join products t3
on t2.productCode = t3.productCode
inner join customers t4
on t1.customerNumber = t4.customerNumber
where year(orderDate) = 2004;

/* product purchased together */
with prod_sales as (
select orderNumber,t1.productCode,productLine
from orderdetails t1
inner join products t2
on t1.productCode = t2.productCode
)

select distinct t1.orderNumber, t1.productLine as Product1, t2.productLine as Product2
from prod_sales t1
left join prod_sales t2
on t1.orderNumber = t2.orderNumber and t1.productLine <> t2.productLine;

/* CUSTOMERS' SALES BY CREDIT LIMIT*/
WITH SALES AS (
SELECT T1.orderNumber,T3.customerNumber, productCode,quantityOrdered,priceEach, priceEach*quantityOrdered AS SALES_VALUE, creditLimit
FROM orders T1
INNER JOIN orderdetails T2
ON T1.orderNumber = T2.orderNumber
INNER JOIN customers T3
ON T1.customerNumber = T3.customerNumber
)
select orderNumber, customerNumber, 
case when creditLimit < 75000 then 'a: less than 75k'
when creditLimit between 75000 and 100000 then 'b: 75k to 100k'
when creditLimit between 100000 and 150000 then 'c: 100k to 150k'
when creditLimit > 150000 then 'd: more than 150k'
else 'other'
end as creditLimit_group, 
sum(SALES_VALUE) AS SALES_VALUE
from SALES
GROUP BY orderNumber, CustomerNumber, creditLimit_group;

/*sales vale change from previous order */
with main_fun as (
select orderNumber, orderdate, customernumber, sum(sales_Value) as sales_value
from
(select t1.orderNumber, orderDate, customerNumber,productCode, quantityOrdered * priceEach as sales_value
from orders t1
inner join orderdetails t2
on t1.orderNumber = t2.orderNumber) main
group by orderNumber, orderdate, customernumber
),
sales_query as (
select t1.*, customerName, row_number() over (partition by customername order by orderdate) as purchase_number,
lag(sales_value) over (partition by customername order by orderdate) as previous_sales
from main_fun t1
inner join customers t2
on t1.customernumber = t2.customernumber)

select * , sales_value - previous_sales as price_value_change
from sales_query
where previous_sales is not null;

/*customers of each office location*/
with main_cte as(
select t1.orderNumber, t2.productCode,t2.quantityOrdered, t2.priceEach,
quantityOrdered * priceEach as sales_value,t3.city as customer_city,t3.country as customer_country, t4.productLine, 
t6.city as office_city, t6.country as office_country
from orders t1
inner join orderdetails t2
on t1.orderNumber = t2.orderNumber
inner join customers t3
on t3.customerNumber = t1.customerNumber
inner join products t4
on t2.productCode = t4.productCode
inner join employees t5
on t3.salesRepEmployeeNumber = t5.employeeNumber
inner join offices t6
on t5.officeCode = t6.officeCode)

select ordernumber, customer_country, customer_city, productline, office_city, office_country, sum(sales_value) as sales_value
from main_cte
group by ordernumber, customer_country, customer_city, productline, office_city, office_country;

/*delayed shipment by 3 days. how many would be affected*/
with main_cte as(
select orderNumber,orderDate,requiredDate,shippedDate,customerNumber,
date_add(shippedDate, interval 3 day) as latest_arrival,
case when date_add(shippedDate, interval 3 day) > requiredDate then "Late"
else "Not affected" end late_flag
from orders)

select * from main_cte
where late_flag = "Late";

/*breakdown of each customers by sales, money owed and check if they are over limit*/
with cte_sales as(
select orderDate, t1.orderNumber, customerName, t1.customerNumber, productCode, creditLimit, 
quantityOrdered * priceEach as sales_value
from orders t1
inner join orderdetails t2
on t1.orderNumber = t2.orderNumber
inner join customers t3
on t1.customerNumber = t3.customerNumber),

cte_running_total as 
(select *, lead (orderdate) over (partition by customernumber order by orderdate) as next_order_date
from (
select orderDate, ordernumber, customernumber, customername, creditlimit,
sum(sales_value) as sales_value  
from cte_sales
group by orderDate, ordernumber, customernumber, customername, creditlimit) subquery ),

cte_payments as (
select *
from payments),

main_cte as(
select t1.*,
sum(sales_value) over (partition by t1.customernumber order by ordernumber) as running_total_sales,
sum(amount) over (partition by t1.customerNumber order by orderdate) as running_total_payments
from cte_running_total t1
left join cte_payments t2 
on t1.customernumber = t2.customernumber and t2.paymentdate between t1.orderdate and case when t1.next_order_date is null then current_date else t1.next_order_date end
)

select *, running_total_sales - running_total_payments as money_owed, 
creditlimit - (running_total_sales - running_total_payments) as difference
from main_cte

