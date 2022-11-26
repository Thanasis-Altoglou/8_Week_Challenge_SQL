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
1. What is the total amount each customer spent at the restaurant?

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
