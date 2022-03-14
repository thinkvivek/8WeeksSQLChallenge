# 8 Weeks SQL Challenge
8 Week SQL Challenge - Week 1

Problem Statement can be found at
https://8weeksqlchallenge.com/case-study-1/

Danny wants to use the data to answer a few simple questions about his customers, 

1. Visiting patterns, 
2. How much money they’ve spent and 
3. Which menu items are their favourite.

Restaurant database has 3 tables as shown below

1. Sales
2. Members
3. Menu

Case Study Questions:

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

The data is provided for Postgre SQL, so I converted it to MS SQL

``` sql

CREATE TABLE sales 
(  
  customer_id VARCHAR(1),  
  order_date DATE,  
  product_id INT
);   
  
INSERT INTO sales
(
  customer_id, order_date, product_id
)
VALUES  
('A', '2021-01-01', 1),  
('A', '2021-01-01', 2),  
('A', '2021-01-07', 2),  
('A', '2021-01-10', 3),  
('A', '2021-01-11', 3),  
('A', '2021-01-11', 3),  
('B', '2021-01-01', 2),  
('B', '2021-01-02', 2),  
('B', '2021-01-04', 1),  
('B', '2021-01-11', 1),  
('B', '2021-01-16', 3),  
('B', '2021-02-01', 3),  
('C', '2021-01-01', 3),  
('C', '2021-01-01', 3),  
('C', '2021-01-07', 3);  

CREATE TABLE menu 
(
  product_id INT,  
  product_name VARCHAR(5),  
  price INT
); 

INSERT INTO menu  
(
  product_id, product_name, price
)
VALUES  
(1, 'sushi', 10),  
(2, 'curry', 15),  
(3, 'ramen', 12);   

CREATE TABLE members 
(
  customer_id VARCHAR(1),  
  join_date DATE
); 

INSERT INTO members  
(
  customer_id, join_date
)
VALUES  
('A', '2021-01-07'),  
('B', '2021-01-09');

```

# Solutions

1.
``` sql

SELECT customer_id, SUM(price) AS TotalAmount 
FROM sales s INNER JOIN menu m ON s.product_id = m.product_id 
GROUP BY customer_id

```
2.
``` sql

SELECT customer_id, COUNT(DISTINCT order_date) AS DaysCount
FROM sales
GROUP BY customer_id

```
3.
``` sql

SELECT DISTINCT s.customer_id,
                m.product_name
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
INNER JOIN
  (SELECT customer_id,
          MIN(order_date) AS MinDate
   FROM sales
   GROUP BY customer_id) o ON s.customer_id = o.customer_id
WHERE s.order_date = o.MinDate

```
