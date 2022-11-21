--Question 1: What is the total amount each customer spent at the restaurant?

SELECT customer_id, SUM(price) AS total_amount
FROM sales
INNER JOIN menu
ON sales.product_id = menu.product_id
GROUP BY 1
ORDER BY 2 DESC


--Question 2: How many days has each customer visited the restaurant?

SELECT customer_id,COUNT(DISTINCT(order_date)) AS visited_days
FROM sales
GROUP BY 1


--Question 3: What was the first item from the menu purchased by each customer?

WITH order_info AS (
SELECT customer_id, order_date,product_name,
	DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY order_date) AS item_rank
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
)

SELECT customer_id, product_name
FROM order_info
WHERE item_rank=1
GROUP BY 1,2


--Question 4: What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name, COUNT(sales.product_id) AS total_orders
FROM sales
INNER JOIN menu
ON  sales.product_id = menu.product_id
GROUP BY 1
LIMIT 1 

--Question 5: Which item was the most popular for each customer?

WITH orders AS (
SELECT product_name,
	customer_id,
	COUNT(product_name) as order_count,
	RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(product_name))
	AS rank_id
FROM menu
INNER JOIN sales
ON menu.product_id = sales.product_id
GROUP BY customer_id,product_name
)
	
SELECT product_name,customer_id,order_count
FROM orders
WHERE rank_id=1


--Question 6: Which item was purchased first by the customer after they became a member?

WITH order_info AS (
SELECT product_name,
	   sales.customer_id,
	   order_date,
	   join_date,
DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY order_date)
AS first_item
FROM menu
INNER JOIN sales ON menu.product_id = sales.product_id
INNER JOIN members ON sales.customer_id = members.customer_id
WHERE order_date>=join_date
)

SELECT customer_id,
	   product_name,
	   order_date
FROM order_info
WHERE first_item=1


--Question 7: Which item was purchased just before the customer became a member?

WITH order_info AS (
SELECT product_name,
	   sales.customer_id,
	   order_date,
	   join_date,
DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY order_date)
AS item
FROM menu
INNER JOIN sales ON menu.product_id = sales.product_id
INNER JOIN members ON sales.customer_id = members.customer_id
WHERE order_date<join_date
)

SELECT customer_id,
	   product_name,
	   order_date
FROM order_info
WHERE item=1


--Question 8: What is the total items and amount spent for each member before they became a member? 

SELECT sales.customer_id,
	   COUNT(product_name) AS total_items,
	   SUM(price) AS total_amount_spent
FROM menu
INNER JOIN sales ON menu.product_id = sales.product_id
INNER JOIN members ON sales.customer_id = members.customer_id
WHERE order_date<join_date
GROUP BY 1


--Question 9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
-- How many points would each customer have?

SELECT sales.customer_id,
	SUM(CASE WHEN product_name='sushi' THEN price*20
	ELSE price*10 END) AS customer_points
FROM sales
INNER JOIN menu ON sales.product_id = menu.product_id
GROUP BY 1
ORDER BY customer_points DESC


--Question 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all
-- items, not just sushi 
-- how many points do customer A and B have at the end of January

WITH dates_cte AS 
(
 SELECT *, 
  DATEADD(DAY, 6, join_date) AS valid_date, 
  EOMONTH('2021-01-31') AS last_date
 FROM members AS m
)
SELECT d.customer_id, s.order_date, d.join_date, 
 d.valid_date, d.last_date, m.product_name, m.price,
 SUM(CASE
  WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
  WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
  ELSE 10 * m.price
  END) AS points
FROM dates_cte AS d
JOIN sales AS s
 ON d.customer_id = s.customer_id
JOIN menu AS m
 ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY d.customer_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price