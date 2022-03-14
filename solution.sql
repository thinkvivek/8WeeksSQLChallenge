
--1
SELECT customer_id, SUM(price) AS TotalAmount 
FROM sales s INNER JOIN menu m ON s.product_id = m.product_id 
GROUP BY customer_id

--2
SELECT customer_id, COUNT(DISTINCT order_date) AS DaysCount
FROM sales
GROUP BY customer_id

--3
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

--4
SELECT TOP 1 s.product_id,
           m.product_name,
           COUNT(*) AS ProductCount
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY s.product_id,
         m.product_name
ORDER BY ProductCount DESC

--5
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

--6
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

--7
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

--8
SELECT s.customer_id,
       COUNT(s.product_id) TotalItems,
       SUM(mn.price) AS AmountSpent
FROM sales s
INNER JOIN members m ON s.order_date < m.join_date
INNER JOIN menu mn ON s.product_id = mn.product_id
WHERE s.customer_id = m.customer_id
GROUP BY s.customer_id

--9
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

--10
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
