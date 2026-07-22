Database Programming group Assignment                      
University of lays Adventists of Kigali                
Nyanza campus                    
Faculity of cis                             
All departments                                         
Course: database programming                        
Lecturer :  Eric MANIRAGUHA                                      

Group members:                   
		-33341/2025        
		-32884/2025            
		-31388/2025              
		-31234/2025                

________________________________________
Sales Management System
Course: Database Programming
Assignment: Advanced SQL Programming – Common Table Expressions (CTEs) and Window Functions
ALPHA MALT MIS
________________________________________
creation of tables

DECLARE
 message varchar2(100):= 'group assignment on sales mis using pl/sql'; 
BEGIN 
 dbms_output.put_line(message); 

creation of tables

 SET SERVEROUTPUT ON;
 
 CREATE TABLE employees (
   employee_id NUMBER PRIMARY KEY,  --primay key--
   employee_name VARCHAR2(100) NOT NULL,
   
 );
 
 CREATE TABLE customers (
   customer_id NUMBER PRIMARY KEY,--primay key--
   customer_name VARCHAR2(100) NOT NULL,
   city VARCHAR2(50),
   segment VARCHAR2(30)
 );
 
 CREATE TABLE orders (
   order_id NUMBER PRIMARY KEY, --primay key--
   customer_id NUMBER NOT NULL,
   employee_id NUMBER NOT NULL,
   order_date DATE NOT NULL,
   status VARCHAR2(20),
   CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),    --forign key--
   CONSTRAINT fk_orders_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id)     --forign key--
 );
 
 CREATE TABLE order_items (
   order_item_id NUMBER PRIMARY KEY,     --primay key--
   order_id NUMBER NOT NULL,
   product_name VARCHAR2(100) NOT NULL,
   category VARCHAR2(50),
   quantity NUMBER NOT NULL,
   unit_price NUMBER(10,2) NOT NULL,
   CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id) --forign key--
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
 
 PART A: CTEs 
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
   SELECT e.employee_id, e.employee_name, e.manager_id, oc.lvl   1
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
 SELECT category, category_total,
        ROUND(100 * category_total / SUM(category_total) OVER (), 2) AS pct_of_total
 FROM category_sales
 ORDER BY category_total DESC;
 
 
 -- 5) CTE with JOIN
 WITH pending_orders AS (
   SELECT order_id, customer_id, employee_id, order_date
   FROM orders
   WHERE status = 'Pending'
 )
 SELECT p.order_id, c.customer_name, e.employee_name, p.order_date
 FROM pending_orders p
 JOIN customers c ON p.customer_id = c.customer_id
 JOIN employees e ON p.employee_id = e.employee_id;
 
 
 
  PART B: Window Functions 
 
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
 
________________________________________





**outputs:**
CUSTOMER_NAME
--------------------------------------------------------------------------------
TOTAL_SALES
-----------
Alpha Mart
       2095

Bright Store
	960

Central Cafe
	750


CUSTOMER_NAME
--------------------------------------------------------------------------------
TOTAL_SALES
-----------
Delta Clinic
	720


EMPLOYEE_NAME
--------------------------------------------------------------------------------
TOTAL_SALES
-----------
Brian Lee
       2485

Dinesh Patel
       1020

Carla Gomez
       1020

   SELECT e.employee_id, e.employee_name, e.manager_id, oc.lvl	 1
                                                                 *
ERROR at line 6:
ORA-00923: FROM keyword not found where expected



CATEGORY					   CATEGORY_TOTAL PCT_OF_TOTAL
-------------------------------------------------- -------------- ------------
Electronics						     2660	 58.78
Furniture						     1470	 32.49
Accessories						      395	  8.73

  ORDER_ID
----------
CUSTOMER_NAME
--------------------------------------------------------------------------------
EMPLOYEE_NAME
--------------------------------------------------------------------------------
ORDER_DATE
------------------
      1004
Delta Clinic
Dinesh Patel
15-JAN-24

===== PART B: Window Functions =====

CUSTOMER_NAME
--------------------------------------------------------------------------------
TOTAL_SALES    ROW_NUM
----------- ----------
Alpha Mart
       2095	     1

Bright Store
	960	     2

Central Cafe
	750	     3


CUSTOMER_NAME
--------------------------------------------------------------------------------
TOTAL_SALES    ROW_NUM
----------- ----------
Delta Clinic
	720	     4


EMPLOYEE_NAME
--------------------------------------------------------------------------------
TOTAL_SALES   RANK_NUM
----------- ----------
Brian Lee
       2485	     1

Dinesh Patel
       1020	     2

Carla Gomez
       1020	     2


CITY						   TOTAL_SALES DENSE_RANK_NUM
-------------------------------------------------- ----------- --------------
New York						  2095		    1
Chicago 						   960		    2
Dallas							   750		    3
Miami							   720		    4

CATEGORY					   TOTAL_SALES PERCENT_RANK_VAL
-------------------------------------------------- ----------- ----------------
Accessories						   395		      0
Furniture						  1470		     .5
Electronics						  2660		      1

  ORDER_ID ORDER_DATE	      ORDER_TOTAL RUNNING_TOTAL
---------- ------------------ ----------- -------------
      1001 05-JAN-24		     1825	   1825
      1002 10-JAN-24		      660	   2485
      1003 12-JAN-24		      750	   3235
      1004 15-JAN-24		      720	   3955
      1005 18-JAN-24		      270	   4225
      1006 20-JAN-24		      300	   4525

  ORDER_ID ORDER_TOTAL AVG_ORDER_VALUE
---------- ----------- ---------------
      1001	  1825	    754.166667
      1002	   660	    754.166667
      1003	   750	    754.166667
      1004	   720	    754.166667
      1005	   270	    754.166667
      1006	   300	    754.166667

CUSTOMER_NAME
--------------------------------------------------------------------------------
TOTAL_SALES  MIN_SALES
----------- ----------
Alpha Mart
       2095	   720

Bright Store
	960	   720

Central Cafe
	750	   720


CUSTOMER_NAME
--------------------------------------------------------------------------------
TOTAL_SALES  MIN_SALES
----------- ----------
Delta Clinic
	720	   720


CUSTOMER_NAME
--------------------------------------------------------------------------------
TOTAL_SALES  MAX_SALES
----------- ----------
Alpha Mart
       2095	  2095

Bright Store
	960	  2095

Central Cafe
	750	  2095


CUSTOMER_NAME
--------------------------------------------------------------------------------
TOTAL_SALES  MAX_SALES
----------- ----------
Delta Clinic
	720	  2095


  ORDER_ID ORDER_DATE	      ORDER_TOTAL PREVIOUS_ORDER_TOTAL
---------- ------------------ ----------- --------------------
      1001 05-JAN-24		     1825
      1002 10-JAN-24		      660		  1825
      1003 12-JAN-24		      750		   660
      1004 15-JAN-24		      720		   750
      1005 18-JAN-24		      270		   720
      1006 20-JAN-24		      300		   270

  ORDER_ID ORDER_DATE	      ORDER_TOTAL NEXT_ORDER_TOTAL
---------- ------------------ ----------- ----------------
      1001 05-JAN-24		     1825	       660
      1002 10-JAN-24		      660	       750
      1003 12-JAN-24		      750	       720
      1004 15-JAN-24		      720	       270
      1005 18-JAN-24		      270	       300
      1006 20-JAN-24		      300

CUSTOMER_NAME
--------------------------------------------------------------------------------
TOTAL_SALES SALES_QUARTILE
----------- --------------
Alpha Mart
       2095		 1

Bright Store
	960		 2

Central Cafe
	750		 3


CUSTOMER_NAME
--------------------------------------------------------------------------------
TOTAL_SALES SALES_QUARTILE
----------- --------------
Delta Clinic
	720		 4


EMPLOYEE_NAME
--------------------------------------------------------------------------------
TOTAL_SALES CUMULATIVE_DISTRIBUTION
----------- -----------------------
Carla Gomez
       1020		 .666666667

Dinesh Patel
       1020		 .666666667

Brian Lee
       2485			  1


________________________________________

**description of values**


Part A: CTE Business Value
1) Simple CTE
Business value:
This query summarizes total sales by customer in a readable way. It helps the sales team quickly identify top customers and focus on high-value accounts.

2) Multiple CTEs
Business value:
This query calculates order totals first and then aggregates them by employee. It supports performance analysis and helps management evaluate employee contribution to sales.

3) Recursive CTE
Business value:
This query displays the employee hierarchy, showing managers and their reporting staff. It is useful for organizational analysis and workforce planning.

4) CTE with Aggregation
Business value:
This query shows sales by product category and the percentage contribution of each category. It helps management understand which product groups generate the most revenue.

5) CTE with JOIN
Business value:
This query lists pending orders with customer and employee details. It helps track unfinished business and improves order follow-up and customer service.

Part B: Window Function Interpretations
1) ROW_NUMBER()
Interpretation:
Assigns a unique sequential number to each customer based on total sales. It is useful for ranking without duplicate numbers.

2) RANK()
Interpretation:
Ranks employees by sales, but ties receive the same rank and the next rank is skipped. This is useful when equal performance should be treated equally.

3) DENSE_RANK()
Interpretation:
Ranks cities by sales with no skipped numbers between ties. It is useful for compact ranking reports.

4) PERCENT_RANK()
Interpretation:
Shows the relative position of each category compared to the others. It helps compare performance as a percentage scale.

5) SUM() OVER()
Interpretation:
Calculates running total sales by order date. This is useful for trend analysis and monitoring cumulative revenue.

6) AVG() OVER()
Interpretation:
Displays the average order value across all orders. It helps measure typical sales performance.

7) MIN() OVER()
Interpretation:
Finds the smallest customer sales value while showing all rows. It is useful for identifying the lowest-performing customer.

8) MAX() OVER()
Interpretation:
Finds the highest customer sales value while showing all rows. It helps identify the best-performing customer.

9) LAG()
Interpretation:
Shows the previous order’s total beside the current order. It is useful for comparing changes over time.

10) LEAD()
Interpretation:
Shows the next order’s total beside the current order. It helps forecast upcoming values and compare future movement.

11) NTILE()
Interpretation:
Divides customers into quartiles based on sales. It helps segment customers into performance groups.

12) CUME_DIST()
Interpretation:
Shows the cumulative distribution of employee sales. It helps understand how each employee compares to the overall group
________________________________________
**an erd and screenshots**

<img width="6888" height="2039" alt="an erd" src="https://github.com/user-attachments/assets/2fe2c4b3-604b-4840-8a4b-d540813613ff" />





<img width="1512" height="834" alt="io screnshot" src="https://github.com/user-attachments/assets/0bef83c6-ac92-4815-81e2-9c35582bc098" />



_________________________________________________________________________________________
**Business Scenario Insights: Sales Management System**

1) Descriptive Analysis — What happened?
Alpha Mart generated the highest customer sales at 2095, making it the top customer.
Brian Lee was the top-performing employee with total sales of 2485.
Electronics was the best-performing product category with total sales of 2660.
Delta Clinic had the lowest customer sales at 720.
The pending order was Order 1004 for Delta Clinic, handled by Dinesh Patel.
Running totals show that sales increased steadily across the order timeline, ending at 4525.
2) Diagnostic Analysis — Why did it happen?
Alpha Mart ranked highest because it placed higher-value orders, including large purchases like laptops and keyboard-related sales.
Brian Lee performed best because he handled orders with strong revenue contributions, especially from Alpha Mart and Bright Store.
Electronics led sales because its items had high unit prices and generated larger total revenue than furniture or accessories.
Delta Clinic ranked lowest because it had only one relatively small pending order in the dataset.
The sales distribution suggests that revenue is concentrated in a few high-value customers and categories rather than evenly spread.
3) Prescriptive Analysis — What actions should be taken?
Focus sales efforts on high-value customers like Alpha Mart to increase repeat business.
Follow up immediately on pending orders, especially Order 1004, to improve cash flow and customer satisfaction.
Encourage employees like Dinesh Patel to improve conversion of pending deals into completed orders.
Increase promotion of electronics products, since they are the most profitable category.
Develop strategies to grow low-performing customers such as Delta Clinic through discounts, bundled offers, or account management.
Use employee ranking reports to reward top performers and support lower performers with coaching.

________________________________________
References
1.	Oracle SQL Documentation
2.	Microsoft SQL Server Documentation
3.	MySQL Documentation
4.	W3Schools SQL Tutorial
5.	Silberschatz, Korth & Sudarshan – Database System Concepts
6.	canva visuals
7.	one compiler.com(pl/sql online editor and compiler)
________________________________________
Academic Integrity Statement
I declare that this assignment is my own original work. All external resources used have been properly acknowledged. I understand and agree to comply with the university's academic integrity policy. Any similarities with existing work are purely coincidental or appropriately referenced.
________________________________________
Conclusion
This project successfully demonstrates the practical application of Advanced SQL Programming techniques using Common Table Expressions (CTEs) and SQL Window Functions. The implemented database provides meaningful analytical reports that support better business decision-making and illustrates how SQL can transform raw transactional data into valuable business insights.

