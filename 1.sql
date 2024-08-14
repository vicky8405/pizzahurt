-- Retrieve the total number of orders placed.

select count(order_id) as total_order
from order_;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    SUM(p.price * ot.quantity) AS total_sales
FROM
    pizzas AS p
        JOIN
    order_detail AS ot ON p.pizza_id = ot.pizza_id;


-- Identify the highest-priced pizza.

with my_cte as(
select pt.name as  pizza_name_,max( p.price) as max_price
from pizzas as p
join pizza_types as pt
on pt.pizza_type_id = p.pizza_type_id
group by pt.name
)
select pizza_name, max(max_price)
from my_cte;



-- Identify the most common pizza size ordered.

select p.size,count(ot.order_detail_id) as comman_size
from pizzas as p
join order_detail as ot
on p.pizza_id = ot.pizza_id
group by p.size;


-- List the top 5 most ordered pizza types along with their quantities.

use pizzahurt;
 
SELECT 
    p.pizza_type_id, SUM(ot.quantity) AS top_5
FROM
    pizzas AS p
        JOIN
    order_detail AS ot ON p.pizza_id = ot.pizza_id
GROUP BY p.pizza_type_id
ORDER BY top_5 DESC
LIMIT 5;



-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(ot.quantity)
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_detail AS ot ON ot.pizza_id = p.pizza_id
GROUP BY pt.category


-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(time_), COUNT(order_id) AS order_count
FROM
    order_
GROUP BY HOUR(time_);



-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;



-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        o.date_, SUM(ot.quantity) AS quantity
    FROM
        order_ AS o
    JOIN order_detail AS ot ON o.order_id = ot.order_id
    GROUP BY o.date_) AS order_quantity;



    -- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, SUM(ot.quantity * p.price) AS total_revenue
FROM
    pizzas AS p
        JOIN
    order_detail AS ot ON p.pizza_id = ot.pizza_id
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;



-- Calculate the percentage contribution of each pizza type to total revenue.

use pizzahurt;

select  pt.category, (sum(ot.quantity * p.price ) /( SELECT 
   round( SUM(p.price * ot.quantity),2 )AS total_sales
FROM
    pizzas AS p
        JOIN
    order_detail AS ot ON p.pizza_id = ot.pizza_id))*100  as total_revenue
from pizzas as p
join order_detail as ot 
on p.pizza_id = ot.pizza_id
join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.category order by total_revenue desc ;



-- Analyze the cumulative revenue generated over time.


SELECT date_, 
       SUM(total) OVER (ORDER BY date_) AS cum_revenue
FROM (
    SELECT o.date_, 
           SUM(ot.quantity * p.price) AS total
    FROM order_ AS o
    JOIN order_detail AS ot
    ON o.order_id = ot.order_id
    JOIN pizzas AS p
    ON p.pizza_id = ot.pizza_id
    GROUP BY o.date_
) AS total_revenue;



-- Determine the top 3 most ordered pizza types
-- based on revenue for each pizza category.

select name,revenue from 

(select category,name ,revenue,
rank() over (partition by category order by revenue desc) as rn
from
  (select pt.category ,pt.name ,sum(ot.quantity * p.price) as revenue
  from pizzas as p
  join pizza_types as pt
  on p.pizza_type_id = pt.pizza_type_id
  join order_detail as ot
  on ot.pizza_id = p.pizza_id
  group by pt.category ,pt.name) as a ) as b
  where rn <=3;
  