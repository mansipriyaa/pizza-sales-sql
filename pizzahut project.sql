CREATE DATABASE pizzahut;

USE pizzahut;

CREATE TABLE Orderss(
order_id int not null PRIMARY KEY,
order_date date not null,
order_time time not null
);

CREATE TABLE Orders_details(
order_details_id int not null PRIMARY KEY,
order_id int not null,
pizza_id text not null,
quantity int not null
);


-- BASIC Questions Set

-- Q1: Retrieve the total number of orders placed.

SELECT count(order_id) AS Total_orders FROM Orderss;

-- Q2: Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(p.price * o.quantity), 2) AS Total_revenue
FROM
    pizzas AS p
        JOIN
    orders_details AS o ON p.pizza_id = o.pizza_id;

-- Q3: Identify the highest-priced pizza.

  SELECT 
    pt.name, MAX(p.price) AS highest
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY highest DESC
LIMIT 1;

-- Without using Aggregate Function MAX

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Q4: Identify the most common pizza size ordered. 

  SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- Q5: List the top 5 most ordered pizza types along with their quantities.
    
  SELECT 
    pizza_types.name, SUM(quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantity DESC
LIMIT 5;
  
  -- INTERMEDIATE Questions Set
  
  -- Q6: Join the necessary tables to find the total quantity of each pizza category ordered. 

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantity DESC;

-- Q7: Determine the distribution of orders by hour of the day. 

SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS order_count
FROM
    Orderss
GROUP BY hours;

-- Q8: Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, count(name) FROM pizza_types
GROUP BY category;

-- Q9: Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        order_date, SUM(orders_details.quantity) AS Quantity
    FROM
        orderss
    JOIN orders_details ON orders_details.order_id = orderss.order_id
    GROUP BY order_date) AS order_quantity;

-- Q10: Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;


-- INTERMEDIATE Questions Set

-- Q11: Calculate the percentage contribution of each pizza type to total revenue.

SELECT pizza_types.category, (SUM(orders_details.quantity * pizzas.price) / (SELECT 
    ROUND(SUM(pizzas.price * orders_details.quantity), 2) AS Total_sales
FROM
    orders_details 
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id) ) * 100 AS Revenue
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;

-- Q12: Analyze the cumulative revenue generated over time.

SELECT order_date, 
SUM(revenue) over(order by order_date) AS cum_revenue
FROM
(SELECT orderss.order_date, 
sum(orders_details.quantity * pizzas.price) as revenue
FROM orders_details JOIN pizzas
ON orders_details.pizza_id = pizzas.pizza_id
JOIN Orderss
ON orderss.order_id = orders_details.order_id
GROUP BY orderss.order_date) AS sales;

-- Q13: Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, revenue FROM 
(SELECT category, name, revenue, 
rank() over(partition by category order by revenue DESC) AS rn
FROM
(SELECT pizza_types.category, pizza_types.name,
SUM((orders_details.quantity) * pizzas.price) AS revenue
FROM pizza_types join pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id = pizzaS.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS a) AS b
WHERE rn<=3;