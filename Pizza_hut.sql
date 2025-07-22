create database Pizzahut;
use pizzahut;
show tables;
create table orders(
order_id int primary key not null,
order_date date not null,
oder_time time not null
);

create table order_details(
order_details_id int primary key not null,
order_id int not null,
pizza_id text not null,
quantity int not null
);
select * from order_details;
select * from orders;
select * from pizzas;

-- Retrieve the total number of orders placed.
select count(Order_id) as Total_placed_orders from orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    SUM(od.quantity * p.price) AS total_Revenue
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza.

SELECT 
    Pt.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types Pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1; 	
 							
-- Identify the 2nd highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1 OFFSET 1; 		

-- Identify the lowest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.Pizza_type_id = pt.pizza_type_id
ORDER BY price
LIMIT 1; 						
-- Identify the pizza stock by size.

SELECT 
    SUBSTRING_INDEX(pizza_id, '_', - 1) AS pizza_size,
    SUM(quantity) AS total_quantity
FROM
    order_details
GROUP BY pizza_size
ORDER BY total_quantity;


-- Identify the most common pizza size ordered.
SELECT 
    SUBSTRING_INDEX(pizza_id, '_', - 1) AS pizza_size,
    SUM(quantity) AS total_quantity
FROM
    order_details
GROUP BY pizza_size
ORDER BY total_quantity DESC
LIMIT 1;

-- Identify the less common pizza size ordered.
SELECT 
    SUBSTRING_INDEX(pizza_id, '_', - 1) AS Pizza_size,
    SUM(quantity) AS total_quantity
FROM
    order_details
GROUP BY pizza_size
ORDER BY total_quantity
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name AS pizza_type, SUM(od.quantity) AS total_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.

 select category,count(name)from pizza_types group by category;
 
-- Determine the distribution of orders by Hour Of the day.
SELECT 
    HOUR(oder_time) Hours, COUNT(order_id) Order_count
FROM
    orders
GROUP BY HOUR(oder_time)
ORDER BY Hours;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(Quantity), 0) as Avg_Pizza_Order_Per_Day
FROM
    (SELECT 
        o.order_date AS Date, SUM(od.quantity) AS Quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS Order_Quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, SUM(od.quantity * p.price) AS Revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    CONCAT(
        ROUND(
            (SUM(od.quantity * p.price) / 
             (SELECT SUM(od2.quantity * p2.price)
              FROM order_details od2
              JOIN pizzas p2 ON p2.pizza_id = od2.pizza_id)
        ) * 100, 2
    ), '%') AS revenue_percentage
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue_percentage DESC;


-- Analyze the cumulative revenue generated over time.

select order_date,round(sum(revenue) over (order by order_date),2) as cumulative_revenue from
(SELECT 
    o.order_date, SUM(od.quantity * p.price) AS revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    orders o ON o.order_id = od.order_id
GROUP BY o.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue from
(Select category,name,revenue,rank() over (partition by category order by revenue desc) as rn from (SELECT 
    pt.category, pt.name, SUM(od.quantity * p.price) AS Revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category , pt.name) as A) as B where rn<=3;

