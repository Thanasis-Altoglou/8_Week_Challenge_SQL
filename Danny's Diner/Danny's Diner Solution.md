# 🍜 🍛 🍣 Case Study #1: Danny's Diner

## Case Study Questions
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
---

### Solutions and Insights 
### 1. What is the total amount each customer spent at the restaurant?

``` sql
SELECT customer_id, SUM(price) AS total_amount
FROM sales
INNER JOIN menu
ON sales.product_id = menu.product_id
GROUP BY 1
ORDER BY 2 DESC
```
Result:

![Screenshot (218)](https://user-images.githubusercontent.com/102918064/204088278-b32c6f3c-2fed-4dd4-8a30-2b51edcf59a0.png)
---
### 2. How many days has each customer visited the restaurant?
``` sql

SELECT customer_id,COUNT(DISTINCT(order_date)) AS visited_days
FROM sales
GROUP BY 1
```
Result:

![Screenshot (210)](https://user-images.githubusercontent.com/102918064/204088686-66961334-7f88-4709-ac75-2fb360e38743.png)
---
### 3. What was the first item from the menu purchased by each customer?
``` sql
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
```
Result:

![Screenshot (211)](https://user-images.githubusercontent.com/102918064/204088723-5dcdbf19-3fbb-43d9-83cd-6c504317d136.png)
--- 
### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
``` sql
SELECT product_name, COUNT(sales.product_id) AS total_orders
FROM sales
INNER JOIN menu
ON  sales.product_id = menu.product_id
GROUP BY 1
LIMIT 1 
```
Result:

![Screenshot (212)](https://user-images.githubusercontent.com/102918064/204088833-205ae01b-7b43-42a3-9e23-2572bd8adf9b.png)
---
### 5. Which item was the most popular for each customer?
``` sql
WITH order_info AS
  (SELECT product_name,
          customer_id,
          count(product_name) AS order_count,
          rank() over(PARTITION BY customer_id
                      ORDER BY count(product_name) DESC) AS rank_num
   FROM menu
   INNER JOIN sales ON menu.product_id = sales.product_id
   GROUP BY customer_id,
            product_name)
SELECT customer_id,
       product_name,
       order_count
FROM order_info
WHERE rank_num =1;
```
Result: 

![Screenshot (220)](https://user-images.githubusercontent.com/102918064/206169788-812e9cb2-0584-4aa4-ba61-748a67a11245.png)
---
### 6. Which item was purchased first by the customer after they became a member?
``` sql
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
```
Result:

![Screenshot (214)](https://user-images.githubusercontent.com/102918064/204088942-7a0492d2-9983-48c6-a698-3ecdb5f05ca2.png)
---

### 7. Which item was purchased just before the customer became a member?
``` sql
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
```
Result:

![Screenshot (215)](https://user-images.githubusercontent.com/102918064/204088979-9c0ab5b6-3053-44af-9028-56a36792f5d3.png)
--- 
### 8. What is the total items and amount spent for each member before they became a member?
``` sql
SELECT sales.customer_id,
	   COUNT(product_name) AS total_items,
	   SUM(price) AS total_amount_spent
FROM menu
INNER JOIN sales ON menu.product_id = sales.product_id
INNER JOIN members ON sales.customer_id = members.customer_id
WHERE order_date<join_date
GROUP BY 1
```
Result:

![Screenshot (216)](https://user-images.githubusercontent.com/102918064/204089011-c643f836-6fe9-470a-a79c-d80c7e027735.png)
---
### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
``` sql
SELECT sales.customer_id,
	SUM(CASE WHEN product_name='sushi' THEN price*20
	ELSE price*10 END) AS customer_points
FROM sales
INNER JOIN menu ON sales.product_id = menu.product_id
GROUP BY 1
ORDER BY customer_points DESC
```
Result:

![Screenshot (217)](https://user-images.githubusercontent.com/102918064/204089039-450c4e47-fbfb-482f-8cf4-be0a9730c6fa.png)

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
``` sql
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
```
Result:
