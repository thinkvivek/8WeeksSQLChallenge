# 8 Weeks SQL Challenge
8 Week SQL Challenge - Week 1

Case Study #1 - Danny's Diner

Problem Statement can be found at
https://8weeksqlchallenge.com/case-study-1/

Danny wants to use the data to answer a few simple questions about his customers, 

1. Visiting patterns, 
2. How much money they’ve spent and 
3. Which menu items are their favourite.

Restaurant database has 3 tables as shown below

1. sales
2. menu
3. members

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

The database schema was given for Postgre SQL, so I converted it to MS SQL

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

4.
``` sql

SELECT TOP 1 s.product_id,
           m.product_name,
           COUNT(*) AS ProductCount
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY s.product_id,
         m.product_name
ORDER BY ProductCount DESC

```
5.
``` sql

WITH CTE AS
  (SELECT s.customer_id,
          m.product_name,
          COUNT(s.product_id) AS ProductCount,
          DENSE_RANK() OVER (PARTITION BY s.customer_id
                             ORDER BY COUNT(s.product_id) DESC) AS ProductRank
   FROM sales s
   INNER JOIN menu m ON s.product_id = m.product_id
   GROUP BY s.customer_id,
            m.product_name)
SELECT customer_id,
       product_name,
       ProductCount
FROM CTE
WHERE ProductRank = 1
ORDER BY customer_id,
         product_name

```
6.
``` sql

WITH CTE AS
  (SELECT s.customer_id,
          mn.product_name,
          COUNT(s.product_id) AS ProductCount,
          DENSE_RANK() OVER (PARTITION BY s.customer_id
                             ORDER BY s.order_date) AS ProductRank
   FROM sales s
   INNER JOIN members m ON s.customer_id = m.customer_id
   INNER JOIN menu mn ON s.product_id = mn.product_id
   WHERE s.order_date >= m.join_date
   GROUP BY s.customer_id,
            mn.product_name,
            s.order_date)
SELECT customer_id,
       product_name,
       ProductRank
FROM CTE
WHERE ProductRank = 1

```
7.
``` sql

WITH CTE AS
  (SELECT s.customer_id,
          mn.product_name,
          COUNT(s.product_id) AS ProductCount,
          DENSE_RANK() OVER (PARTITION BY s.customer_id
                             ORDER BY s.order_date DESC) AS ProductRank
   FROM sales s
   INNER JOIN members m ON s.customer_id = m.customer_id
   INNER JOIN menu mn ON s.product_id = mn.product_id
   WHERE s.order_date < m.join_date
   GROUP BY s.customer_id,
            mn.product_name,
            s.order_date)
SELECT customer_id,
       product_name,
       ProductRank
FROM CTE
WHERE ProductRank = 1

```
8.
``` sql

SELECT s.customer_id,
       COUNT(s.product_id) TotalItems,
       SUM(mn.price) AS AmountSpent
FROM sales s
INNER JOIN members m ON s.order_date < m.join_date
INNER JOIN menu mn ON s.product_id = mn.product_id
WHERE s.customer_id = m.customer_id
GROUP BY s.customer_id

```
9.
``` sql

WITH CTE AS
  (SELECT s.customer_id,
          m.product_name,
          CASE
              WHEN m.product_name = 'sushi' THEN SUM(m.price) * 20
              ELSE SUM(m.price) * 10
          END AS Points
   FROM sales s
   INNER JOIN menu m ON s.product_id = m.product_id
   GROUP BY s.customer_id,
            m.product_name)
SELECT customer_id,
       SUM(Points) AS TotalPoints
FROM CTE
GROUP BY customer_id

```
10.
``` sql

WITH CTE AS
  (SELECT o.customer_id,
          product_name,
          (CASE
               WHEN product_name = 'sushi'
                    OR (OrderJoinDateDiff > -1
                        AND OrderJoinDateDiff < 8) THEN price * 20
               ELSE price * 10
           END) AS Points
   FROM
     (SELECT s.customer_id,
             s.product_id,
             mn.product_name,
             mn.price,
             DATEDIFF(DAY, join_date, order_date) AS OrderJoinDateDiff
      FROM sales s
      INNER JOIN members m ON s.customer_id = m.customer_id
      INNER JOIN menu mn ON s.product_id = mn.product_id
      WHERE order_date <= '01/31/2021') o)
SELECT customer_id,
       SUM(Points) AS TotalPoints
FROM CTE
GROUP BY customer_id

```
