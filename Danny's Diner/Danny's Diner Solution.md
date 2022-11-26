'''sql
SELECT customer_id,
       CONCAT('$', sum(price)) AS total_sales
FROM dannys_diner.menu
INNER JOIN dannys_diner.sales ON menu.product_id = sales.product_id
GROUP BY customer_id
ORDER BY customer_id;
'''
