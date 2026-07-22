-- Sales Management System for CTEs and Window Functions

SET SERVEROUTPUT ON

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE order_items';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE orders';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE customers';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE employees';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE employees (
  employee_id NUMBER PRIMARY KEY,
  employee_name VARCHAR2(100) NOT NULL,
  manager_id NUMBER,
  CONSTRAINT fk_emp_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

CREATE TABLE customers (
  customer_id NUMBER PRIMARY KEY,
  customer_name VARCHAR2(100) NOT NULL,
  city VARCHAR2(50),
  segment VARCHAR2(30)
);

CREATE TABLE orders (
  order_id NUMBER PRIMARY KEY,
  customer_id NUMBER NOT NULL,
  employee_id NUMBER NOT NULL,
  order_date DATE NOT NULL,
  status VARCHAR2(20),
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT fk_orders_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE order_items (
  order_item_id NUMBER PRIMARY KEY,
  order_id NUMBER NOT NULL,
  product_name VARCHAR2(100) NOT NULL,
  category VARCHAR2(50),
  quantity NUMBER NOT NULL,
  unit_price NUMBER(10,2) NOT NULL,
  CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

INSERT INTO employees VALUES (1, 'Asha Khan', NULL);
INSERT INTO employees VALUES (2, 'Brian Lee', 1);
INSERT INTO employees VALUES (3, 'Carla Gomez', 1);
INSERT INTO employees VALUES (4, 'Dinesh Patel', 2);

INSERT INTO customers VALUES (101, 'Alpha Mart', 'New York', 'Retail');
INSERT INTO customers VALUES (102, 'Bright Store', 'Chicago', 'Retail');
INSERT INTO customers VALUES (103, 'Central Cafe', 'Dallas', 'Hospitality');
INSERT INTO customers VALUES (104, 'Delta Clinic', 'Miami', 'Healthcare');

INSERT INTO orders VALUES (1001, 101, 2, DATE '2024-01-05', 'Completed');
INSERT INTO orders VALUES (1002, 102, 2, DATE '2024-01-10', 'Completed');
INSERT INTO orders VALUES (1003, 103, 3, DATE '2024-01-12', 'Completed');
INSERT INTO orders VALUES (1004, 104, 4, DATE '2024-01-15', 'Pending');
INSERT INTO orders VALUES (1005, 101, 3, DATE '2024-01-18', 'Completed');
INSERT INTO orders VALUES (1006, 102, 4, DATE '2024-01-20', 'Completed');

INSERT INTO order_items VALUES (1, 1001, 'Laptop', 'Electronics', 2, 850);
INSERT INTO order_items VALUES (2, 1001, 'Mouse', 'Accessories', 5, 25);
INSERT INTO order_items VALUES (3, 1002, 'Monitor', 'Electronics', 3, 220);
INSERT INTO order_items VALUES (4, 1003, 'Chair', 'Furniture', 10, 75);
INSERT INTO order_items VALUES (5, 1004, 'Desk', 'Furniture', 4, 180);
INSERT INTO order_items VALUES (6, 1005, 'Keyboard', 'Accessories', 6, 45);
INSERT INTO order_items VALUES (7, 1006, 'Printer', 'Electronics', 1, 300);

COMMIT;

PROMPT ===== PART A: CTEs =====

-- 1) Simple CTE
WITH customer_sales AS (
  SELECT c.customer_name, SUM(oi.quantity * oi.unit_price) AS total_sales
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY c.customer_name
)
SELECT * FROM customer_sales
ORDER BY total_sales DESC;

-- 2) Multiple CTEs
WITH order_totals AS (
  SELECT o.order_id, o.employee_id, SUM(oi.quantity * oi.unit_price) AS order_total
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY o.order_id, o.employee_id
),
employee_sales AS (
  SELECT e.employee_name, SUM(ot.order_total) AS total_sales
  FROM employees e
  JOIN order_totals ot ON e.employee_id = ot.employee_id
  GROUP BY e.employee_name
)
SELECT * FROM employee_sales
ORDER BY total_sales DESC;

-- 3) Recursive CTE
WITH org_chart (employee_id, employee_name, manager_id, lvl) AS (
  SELECT employee_id, employee_name, manager_id, 1
  FROM employees
  WHERE manager_id IS NULL
  UNION ALL
  SELECT e.employee_id, e.employee_name, e.manager_id, oc.lvl + 1
  FROM employees e
  JOIN org_chart oc ON e.manager_id = oc.employee_id
)
SELECT * FROM org_chart
ORDER BY lvl, employee_id;

-- 4) CTE with Aggregation
WITH category_sales AS (
  SELECT oi.category, SUM(oi.quantity * oi.unit_price) AS category_total
  FROM order_items oi
  GROUP BY oi.category
)
SELECT category,
       category_total,
       ROUND(100 * category_total / SUM(category_total) OVER (), 2) AS pct_of_total
FROM category_sales
ORDER BY category_total DESC;

-- 5) CTE combined with JOIN
WITH pending_orders AS (
  SELECT order_id, customer_id, employee_id, order_date
  FROM orders
  WHERE status = 'Pending'
)
SELECT p.order_id, c.customer_name, e.employee_name, p.order_date
FROM pending_orders p
JOIN customers c ON p.customer_id = c.customer_id
JOIN employees e ON p.employee_id = e.employee_id;

PROMPT ===== PART B: WINDOW FUNCTIONS =====

-- 1) ROW_NUMBER()
SELECT c.customer_name,
       SUM(oi.quantity * oi.unit_price) AS total_sales,
       ROW_NUMBER() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS row_num
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_name
ORDER BY total_sales DESC;

-- 2) RANK()
SELECT e.employee_name,
       SUM(oi.quantity * oi.unit_price) AS total_sales,
       RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS rank_num
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY e.employee_name
ORDER BY total_sales DESC;

-- 3) DENSE_RANK()
SELECT c.city,
       SUM(oi.quantity * oi.unit_price) AS total_sales,
       DENSE_RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS dense_rank_num
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.city
ORDER BY total_sales DESC;

-- 4) PERCENT_RANK()
SELECT oi.category,
       SUM(oi.quantity * oi.unit_price) AS total_sales,
       PERCENT_RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price)) AS percent_rank_val
FROM order_items oi
GROUP BY oi.category
ORDER BY total_sales;

-- 5) SUM() OVER()
SELECT o.order_id,
       o.order_date,
       SUM(oi.quantity * oi.unit_price) AS order_total,
       SUM(SUM(oi.quantity * oi.unit_price)) OVER (ORDER BY o.order_date) AS running_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date
ORDER BY o.order_date;

-- 6) AVG() OVER()
SELECT o.order_id,
       SUM(oi.quantity * oi.unit_price) AS order_total,
       AVG(SUM(oi.quantity * oi.unit_price)) OVER () AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY o.order_id;

-- 7) MIN() OVER()
SELECT c.customer_name,
       SUM(oi.quantity * oi.unit_price) AS total_sales,
       MIN(SUM(oi.quantity * oi.unit_price)) OVER () AS min_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_name
ORDER BY total_sales DESC;

-- 8) MAX() OVER()
SELECT c.customer_name,
       SUM(oi.quantity * oi.unit_price) AS total_sales,
       MAX(SUM(oi.quantity * oi.unit_price)) OVER () AS max_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_name
ORDER BY total_sales DESC;

-- 9) LAG()
SELECT o.order_id,
       o.order_date,
       SUM(oi.quantity * oi.unit_price) AS order_total,
       LAG(SUM(oi.quantity * oi.unit_price)) OVER (ORDER BY o.order_date) AS previous_order_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date
ORDER BY o.order_date;

-- 10) LEAD()
SELECT o.order_id,
       o.order_date,
       SUM(oi.quantity * oi.unit_price) AS order_total,
       LEAD(SUM(oi.quantity * oi.unit_price)) OVER (ORDER BY o.order_date) AS next_order_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date
ORDER BY o.order_date;

-- 11) NTILE()
SELECT c.customer_name,
       SUM(oi.quantity * oi.unit_price) AS total_sales,
       NTILE(4) OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS sales_quartile
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_name
ORDER BY total_sales DESC;

-- 12) CUME_DIST()
SELECT e.employee_name,
       SUM(oi.quantity * oi.unit_price) AS total_sales,
       CUME_DIST() OVER (ORDER BY SUM(oi.quantity * oi.unit_price)) AS cumulative_distribution
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY e.employee_name
ORDER BY total_sales;

BEGIN
  DBMS_OUTPUT.PUT_LINE('Sales Management System schema created successfully.');
END;
/