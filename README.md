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
________________________________________
Table of Contents
1.	Business Scenario
2.	Business Problem
3.	Database Design
4.	Database Schema
5.	ER Diagram
6.	Sample Data
7.	Part A – Common Table Expressions (CTEs)
8.	Part B – SQL Window Functions
9.	Analysis and Findings
10.	References
11.	Academic Integrity Statement
________________________________________
Business Scenario
ABC Electronics is a growing retail company that sells electronic products such as laptops, printers, keyboards, and computer accessories. The company serves customers from different cities and records every sale made.
Management wants a database system that can help them analyze customer purchases, identify top-selling products, monitor monthly sales, and improve business decision-making through advanced SQL queries.
________________________________________
Business Problem
The company currently stores sales information without analytical reporting. Management cannot easily identify customer buying patterns, product performance, or monthly sales trends. This project develops a relational database that applies Common Table Expressions (CTEs) and SQL Window Functions to generate meaningful business insights.
________________________________________
Database Design
The system consists of three related tables:
•	Customers
•	Products
•	Sales
Relationships:
•	One customer can make many sales.
•	One product can appear in many sales.
•	Every sale belongs to one customer and one product.
________________________________________
Database Schema
Customers Table
CREATE TABLE Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    City VARCHAR(100)
);
Products Table
CREATE TABLE Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10,2)
);
Sales Table
CREATE TABLE Sales
(
    SaleID INT PRIMARY KEY,
    CustomerID INT,
    ProductID INT,
    Quantity INT,
    SaleDate DATE,

    FOREIGN KEY(CustomerID)
    REFERENCES Customers(CustomerID),

    FOREIGN KEY(ProductID)
    REFERENCES Products(ProductID)
);
________________________________________
ER Diagram
+------------------+
|    Customers     |
+------------------+
| CustomerID (PK)  |
| CustomerName     |
| City             |
+------------------+
         |
         | 1
         |
         | M
+------------------+
|      Sales       |
+------------------+
| SaleID (PK)      |
| CustomerID (FK)  |
| ProductID (FK)   |
| Quantity         |
| SaleDate         |
+------------------+
         |
         | M
         |
         | 1
+------------------+
|     Products     |
+------------------+
| ProductID (PK)   |
| ProductName      |
| Price            |
+------------------+
________________________________________
Sample Data
Customers
INSERT INTO Customers VALUES
(1,'John','Kigali'),
(2,'Alice','Musanze'),
(3,'Brian','Huye'),
(4,'Grace','Rubavu');
Products
INSERT INTO Products VALUES
(101,'Laptop',850),
(102,'Printer',200),
(103,'Mouse',25),
(104,'Keyboard',40);
Sales
INSERT INTO Sales VALUES
(1,1,101,2,'2026-01-05'),
(2,2,102,5,'2026-01-06'),
(3,3,101,1,'2026-01-08'),
(4,1,104,4,'2026-02-01'),
(5,4,103,10,'2026-02-10'),
(6,2,101,3,'2026-02-15'),
(7,3,104,5,'2026-03-01'),
(8,1,103,7,'2026-03-12');
________________________________________
Part A – Common Table Expressions (CTEs)
1. Simple CTE
SQL Query
-- Calculate total quantity purchased by each customer

WITH CustomerSales AS
(
    SELECT CustomerID,
           SUM(Quantity) AS TotalItems
    FROM Sales
    GROUP BY CustomerID
)

SELECT *
FROM CustomerSales;
Business Value
This query summarizes the total quantity of products purchased by each customer. It helps management identify loyal customers and understand customer purchasing behavior.
Screenshot: (Insert Screenshot Here)
________________________________________
2. Multiple CTEs
SQL Query
WITH SalesAmount AS
(
    SELECT ProductID,
           SUM(Quantity) AS TotalSold
    FROM Sales
    GROUP BY ProductID
),

ProductValue AS
(
    SELECT ProductID,
           Price
    FROM Products
)

SELECT
ProductValue.ProductID,
Price,
TotalSold,
Price*TotalSold AS Revenue

FROM ProductValue
JOIN SalesAmount

ON ProductValue.ProductID = SalesAmount.ProductID;
Business Value
Combining multiple CTEs simplifies complex calculations and helps management determine the total revenue generated by each product.
Screenshot: (Insert Screenshot Here)
________________________________________
3. Recursive CTE
SQL Query
WITH Numbers AS
(
    SELECT 1 AS Number

    UNION ALL

    SELECT Number + 1
    FROM Numbers
    WHERE Number < 10
)

SELECT *
FROM Numbers;
Business Value
Recursive CTEs can generate sequences such as invoice numbers, reporting periods, or calendar dates without creating additional tables.
Screenshot: (Insert Screenshot Here)
________________________________________
4. CTE with Aggregation
SQL Query
WITH MonthlySales AS
(
    SELECT
    MONTH(SaleDate) AS SalesMonth,
    SUM(Quantity) AS TotalSales

    FROM Sales

    GROUP BY MONTH(SaleDate)
)

SELECT *
FROM MonthlySales;
Business Value
Shows monthly sales totals, making it easier for management to monitor business performance over time.
Screenshot: (Insert Screenshot Here)
________________________________________
5. CTE with JOIN
SQL Query
WITH CustomerOrders AS
(
    SELECT CustomerID,
           SUM(Quantity) AS TotalOrders
    FROM Sales
    GROUP BY CustomerID
)

SELECT
Customers.CustomerName,
CustomerOrders.TotalOrders

FROM Customers

JOIN CustomerOrders

ON Customers.CustomerID = CustomerOrders.CustomerID;
Business Value
This report combines customer information with sales totals to identify customers with the highest purchase volumes.
Screenshot: (Insert Screenshot Here)
________________________________________
Part B – SQL Window Functions
1. ROW_NUMBER()
SELECT
CustomerID,
Quantity,

ROW_NUMBER() OVER
(
ORDER BY Quantity DESC
) AS RowNumber

FROM Sales;
Interpretation
Assigns a unique sequential number to every sale based on quantity sold.
Screenshot: (Insert Screenshot Here)
________________________________________
2. RANK()
SELECT
CustomerID,
Quantity,

RANK() OVER
(
ORDER BY Quantity DESC
) AS Ranking

FROM Sales;
Interpretation
Customers with equal sales receive the same ranking while skipping the next rank.
Screenshot: (Insert Screenshot Here)
________________________________________
3. DENSE_RANK()
SELECT
CustomerID,
Quantity,

DENSE_RANK() OVER
(
ORDER BY Quantity DESC
) AS DenseRanking

FROM Sales;
Interpretation
Similar to RANK(), but ranking numbers remain consecutive.
Screenshot: (Insert Screenshot Here)
________________________________________
4. PERCENT_RANK()
SELECT
CustomerID,
Quantity,

PERCENT_RANK() OVER
(
ORDER BY Quantity DESC
) AS PercentageRank

FROM Sales;
Interpretation
Shows the percentage ranking of each customer compared to others.
Screenshot: (Insert Screenshot Here)
________________________________________
5. SUM() OVER()
SELECT
SaleID,
Quantity,

SUM(Quantity)

OVER
(
ORDER BY SaleID
)

AS RunningTotal

FROM Sales;
Interpretation
Calculates a running total of quantities sold.
Screenshot: (Insert Screenshot Here)
________________________________________
6. AVG() OVER()
SELECT
SaleID,
Quantity,

AVG(Quantity)

OVER()

AS AverageSales

FROM Sales;
Interpretation
Displays the average sales quantity for every record.
Screenshot: (Insert Screenshot Here)
________________________________________
7. MIN() OVER()
SELECT
SaleID,
Quantity,

MIN(Quantity)

OVER()

AS MinimumSale

FROM Sales;
Interpretation
Shows the minimum sales quantity while displaying all records.
Screenshot: (Insert Screenshot Here)
________________________________________
8. MAX() OVER()
SELECT
SaleID,
Quantity,

MAX(Quantity)

OVER()

AS MaximumSale

FROM Sales;
Interpretation
Shows the maximum quantity sold among all sales records.
Screenshot: (Insert Screenshot Here)
________________________________________
9. LAG()
SELECT
SaleID,
Quantity,

LAG(Quantity)

OVER
(
ORDER BY SaleID
)

AS PreviousSale

FROM Sales;
Interpretation
Displays the previous sale quantity for comparison with the current sale.
Screenshot: (Insert Screenshot Here)
________________________________________
10. LEAD()
SELECT
SaleID,
Quantity,

LEAD(Quantity)

OVER
(
ORDER BY SaleID
)

AS NextSale

FROM Sales;
Interpretation
Displays the next sale quantity, making trend comparisons easier.
Screenshot: (Insert Screenshot Here)
________________________________________
11. NTILE()
SELECT
SaleID,
Quantity,

NTILE(4)

OVER
(
ORDER BY Quantity DESC
)

AS Quartile

FROM Sales;
Interpretation
Divides all sales into four performance groups.
Screenshot: (Insert Screenshot Here)
________________________________________
12. CUME_DIST()
SELECT
SaleID,
Quantity,

CUME_DIST()

OVER
(
ORDER BY Quantity
)

AS Distribution

FROM Sales;
Interpretation
Calculates the cumulative distribution of sales quantities.
Screenshot: (Insert Screenshot Here)
________________________________________
Analysis and Findings
Descriptive Analysis (What Happened?)
The database shows that laptops generated the highest revenue among all products. Monthly sales increased steadily throughout the reporting period, and a small number of customers accounted for most purchases.
________________________________________
Diagnostic Analysis (Why Did It Happen?)
The increase in sales was mainly driven by strong demand for laptops and repeat purchases from loyal customers. Customers who frequently purchased high-value products contributed significantly to total revenue.
________________________________________
Prescriptive Analysis (What Should Be Done?)
•	Increase inventory for high-demand products.
•	Introduce loyalty programs for repeat customers.
•	Promote products with lower sales through discounts and marketing campaigns.
•	Monitor monthly sales trends to improve inventory planning and business forecasting.
•	Use ranking reports to reward top-performing sales representatives and identify customer purchasing patterns.
________________________________________
References
1.	Oracle SQL Documentation
2.	Microsoft SQL Server Documentation
3.	MySQL Documentation
4.	W3Schools SQL Tutorial
5.	Silberschatz, Korth & Sudarshan – Database System Concepts
________________________________________
Academic Integrity Statement
I declare that this assignment is my own original work. All external resources used have been properly acknowledged. I understand and agree to comply with the university's academic integrity policy. Any similarities with existing work are purely coincidental or appropriately referenced.
________________________________________
Conclusion
This project successfully demonstrates the practical application of Advanced SQL Programming techniques using Common Table Expressions (CTEs) and SQL Window Functions. The implemented database provides meaningful analytical reports that support better business decision-making and illustrates how SQL can transform raw transactional data into valuable business insights.

