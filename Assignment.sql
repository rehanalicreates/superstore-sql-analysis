CREATE DATABASE superstore;

CREATE TABLE Customers(CustomerID VARCHAR(20) PRIMARY KEY, CustomerName VARCHAR(100), Segment VARCHAR(50), Country VARCHAR(50),
City VARCHAR(100), State VARCHAR(100), PostalCode VARCHAR(10), Region VARCHAR(50))

CREATE TABLE Products(ProductID VARCHAR(30) PRIMARY KEY, Category VARCHAR(50), SubCategory VARCHAR(50), ProductName VARCHAR(255))

CREATE TABLE Orders(OrderID VARCHAR(20) PRIMARY KEY, OrderDate DATE, ShipDate DATE, ShipMode VARCHAR(50),
CustomerID VARCHAR(20) REFERENCES Customers(CustomerID))

CREATE TABLE Sales(RowID INT PRIMARY KEY, OrderID VARCHAR(20) REFERENCES Orders(OrderID),
ProductID VARCHAR(30) REFERENCES Products(ProductID), Sales DECIMAL(10,4), Quantity INT, Discount DECIMAL(4,2), Profit DECIMAL(10,4))

INSERT INTO Customers (CustomerID, CustomerName, Segment, Country, City, State, PostalCode, Region)
SELECT [Customer_ID], MAX([Customer_Name]), MAX(Segment), MAX(Country), MAX(City), MAX(State), MAX([Postal_Code]), MAX(Region)
FROM SuperstoreRaw GROUP BY [Customer_ID]

INSERT INTO Products (ProductID, Category, SubCategory, ProductName)
SELECT [Product_ID], MAX(Category), MAX([Sub_Category]), MAX([Product_Name])
FROM SuperstoreRaw GROUP BY [Product_ID]

INSERT INTO Orders (OrderID, OrderDate, ShipDate, ShipMode, CustomerID)
SELECT DISTINCT [Order_ID], CAST([Order_Date] AS DATE), CAST([Ship_Date] AS DATE), [Ship_Mode], [Customer_ID]
FROM SuperstoreRaw

INSERT INTO Sales (RowID, OrderID, ProductID, Sales, Quantity, Discount, Profit)
SELECT [Row_ID], [Order_ID], [Product_ID], Sales, Quantity, Discount, Profit
FROM SuperstoreRaw

SELECT COUNT(*) FROM Customers
SELECT COUNT(*) FROM Products
SELECT COUNT(*) FROM Orders
SELECT COUNT(*) FROM Sales


--Task 1 — Basic Queries:
-- 1. List all customers from the West region
SELECT CustomerID, CustomerName, Segment, City, State
FROM Customers WHERE Region = 'West' ORDER BY CustomerName

-- 2. Retrieve all orders placed in 2023
SELECT o.OrderID, o.OrderDate, o.ShipDate, o.ShipMode, c.CustomerName FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID WHERE YEAR(o.OrderDate) = 2023 ORDER BY o.OrderDate

-- 3. Top 10 products by total sales
SELECT TOP 10 p.ProductID, p.ProductName, p.Category, ROUND(SUM(s.Sales), 2) AS TotalSales
FROM Sales s JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category ORDER BY TotalSales DESC

--Task 2 — Aggregate Functions:
-- 1. Total sales, profit and average discount per Region
SELECT c.Region, ROUND(SUM(s.Sales), 2) AS TotalSales,
ROUND(SUM(s.Profit), 2) AS TotalProfit, ROUND(AVG(s.Discount), 4) AS AvgDiscount
FROM Sales s JOIN Orders o ON s.OrderID = o.OrderID JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Region ORDER BY TotalSales DESC

-- 2. Total sales and profit per Customer Segment
SELECT c.Segment, ROUND(SUM(s.Sales), 2) AS TotalSales, ROUND(SUM(s.Profit), 2) AS TotalProfit
FROM Sales s JOIN Orders o ON s.OrderID = o.OrderID JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Segment ORDER BY TotalSales DESC

-- 3. Products/categories generating negative profit
SELECT p.Category, p.SubCategory, p.ProductName,
ROUND(SUM(s.Profit), 2) AS TotalProfit FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.ProductID, p.Category, p.SubCategory, p.ProductName
HAVING SUM(s.Profit) < 0 ORDER BY TotalProfit ASC

-- Task 3: Joins
-- 1. Customer Name, Order ID, Sales, Profit
SELECT c.CustomerName, o.OrderID, ROUND(SUM(s.Sales), 2) AS TotalSales,
ROUND(SUM(s.Profit), 2) AS TotalProfit
FROM Orders o JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Sales s ON o.OrderID = s.OrderID
GROUP BY c.CustomerName, o.OrderID ORDER BY c.CustomerName

-- 2. Product Name, Category, Sales, Profit
SELECT p.ProductName, p.Category, p.SubCategory,
ROUND(SUM(s.Sales), 2) AS TotalSales,
ROUND(SUM(s.Profit), 2) AS TotalProfit FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category, p.SubCategory ORDER BY TotalSales DESC

-- 3. Top 5 customers by total sales with segment and region
SELECT TOP 5 c.CustomerName, c.Segment, c.Region, ROUND(SUM(s.Sales), 2) AS TotalSales
FROM Sales s JOIN Orders o ON s.OrderID = o.OrderID JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.Segment, c.Region ORDER BY TotalSales DESC

-- Task 4: Subqueries & CTEs
-- 1. Customers whose total sales exceed average sales of all customers
SELECT CustomerName, Segment, Region, TotalSales
FROM(SELECT c.CustomerName, c.Segment, c.Region, ROUND(SUM(s.Sales), 2) AS TotalSales
FROM Sales s JOIN Orders o ON s.OrderID = o.OrderID JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.Segment, c.Region
) AS CustomerSales WHERE TotalSales > (SELECT AVG(CustTotal) FROM (SELECT SUM(s2.Sales) AS CustTotal FROM Sales s2
JOIN Orders o2 ON s2.OrderID = o2.OrderID GROUP BY o2.CustomerID) AS AvgCalc) ORDER BY TotalSales DESC

-- 2. CTE for Top 10 products by total profit
WITH TopProducts AS (SELECT p.ProductName, p.Category, p.SubCategory,
ROUND(SUM(s.Profit), 2) AS TotalProfit,
RANK() OVER (ORDER BY SUM(s.Profit) DESC) AS ProfitRank
FROM Sales s JOIN Products p ON s.ProductID = p.ProductID GROUP BY p.ProductID, p.ProductName, p.Category, p.SubCategory)
SELECT ProfitRank, ProductName, Category, SubCategory, TotalProfit
FROM TopProducts WHERE ProfitRank <= 10 ORDER BY ProfitRank

-- 3. Orders where profit < 0 and discount > 0.2
SELECT o.OrderID, o.OrderDate, c.CustomerName, p.ProductName, ROUND(s.Sales, 2) AS Sales, s.Discount, ROUND(s.Profit, 2) AS Profit
FROM Sales s JOIN Orders o ON s.OrderID = o.OrderID JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON s.ProductID = p.ProductID WHERE s.Profit < 0 AND s.Discount > 0.2 ORDER BY s.Profit ASC

-- Task 5: Window Functions
-- 1. Rank customers by total profit using ROW_NUMBER()
SELECT ROW_NUMBER() OVER (ORDER BY TotalProfit DESC) AS RowNum, CustomerName, Segment, Region, TotalProfit
FROM (SELECT c.CustomerName, c.Segment, c.Region, ROUND(SUM(s.Profit), 2) AS TotalProfit
FROM Sales s JOIN Orders o ON s.OrderID = o.OrderID JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.Segment, c.Region) AS CustomerProfits ORDER BY RowNum

-- 2. Top 3 products per category by sales using RANK()
SELECT Category, ProductName, TotalSales, SalesRank
FROM (SELECT p.Category, p.ProductName, ROUND(SUM(s.Sales), 2) AS TotalSales,
RANK() OVER (PARTITION BY p.Category ORDER BY SUM(s.Sales) DESC) AS SalesRank
FROM Sales s JOIN Products p ON s.ProductID = p.ProductID GROUP BY p.ProductID, p.Category, p.ProductName
) AS Ranked WHERE SalesRank <= 3 ORDER BY Category, SalesRank

-- 3. Divide customers into quartiles using NTILE(4)
SELECT CustomerName, Segment, Region, TotalProfit,
NTILE(4) OVER (ORDER BY TotalProfit DESC) AS ProfitQuartile
FROM (SELECT c.CustomerName, c.Segment, c.Region,ROUND(SUM(s.Profit), 2) AS TotalProfit
FROM Sales s JOIN Orders o ON s.OrderID = o.OrderID JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.Segment, c.Region) AS CustomerProfits ORDER BY ProfitQuartile, TotalProfit DESC

-- Task 6: Data Transformation
-- 1. Calculate shipping delay for all orders
SELECT o.OrderID, c.CustomerName, o.OrderDate, o.ShipDate, o.ShipMode, DATEDIFF(day, o.OrderDate, o.ShipDate) AS ShippingDelayDays
FROM Orders o JOIN Customers c ON o.CustomerID = c.CustomerID ORDER BY ShippingDelayDays DESC

-- 2. Combine ProductID and ProductName using CONCAT
SELECT ProductID, ProductName, Category,
CONCAT(ProductID, ' - ', ProductName) AS ProductFullLabel FROM Products ORDER BY Category, ProductName

-- 3. Orders shipped more than 7 days after order date
SELECT o.OrderID, c.CustomerName, o.OrderDate, o.ShipDate, o.ShipMode, DATEDIFF(day, o.OrderDate, o.ShipDate) AS ShippingDelayDays
FROM Orders o JOIN Customers c ON o.CustomerID = c.CustomerID WHERE DATEDIFF(day, o.OrderDate, o.ShipDate) > 7
ORDER BY ShippingDelayDays DESC

-- Task 7: Business Insights
-- Insight 1: Technology is the most profitable category
SELECT p.Category, ROUND(SUM(s.Sales), 2) AS TotalSales, ROUND(SUM(s.Profit), 2) AS TotalProfit
FROM Sales s JOIN Products p ON s.ProductID = p.ProductID GROUP BY p.Category ORDER BY TotalProfit DESC

-- Insight 2: Furniture sub-categories generate losses
SELECT p.Category, p.SubCategory, ROUND(SUM(s.Profit), 2) AS TotalProfit
FROM Sales s JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.Category, p.SubCategory ORDER BY TotalProfit ASC

-- Insight 3: High discounts cause negative profit
SELECT CASE WHEN s.Discount = 0 THEN 'No Discount'
WHEN s.Discount <= 0.2 THEN '1-20%'
WHEN s.Discount <= 0.4 THEN '21-40%'
ELSE 'Over 40%'
END AS DiscountBand,
COUNT(*) AS NumTransactions, ROUND(AVG(s.Profit), 2) AS AvgProfit
FROM Sales s GROUP BY
CASE WHEN s.Discount = 0 THEN 'No Discount'
WHEN s.Discount <= 0.2 THEN '1-20%'
WHEN s.Discount <= 0.4 THEN '21-40%'
ELSE 'Over 40%'
END ORDER BY AvgProfit DESC

-- Insight 4: West and East regions are most profitable
SELECT c.Region, ROUND(SUM(s.Sales), 2) AS TotalSales,
 ROUND(SUM(s.Profit), 2) AS TotalProfit FROM Sales s
JOIN Orders o ON s.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Region ORDER BY TotalProfit DESC

-- Insight 5: Consumer segment drives maximum revenue
SELECT c.Segment, COUNT(DISTINCT c.CustomerID) AS UniqueCustomers,
ROUND(SUM(s.Sales), 2) AS TotalSales, ROUND(SUM(s.Profit), 2) AS TotalProfit
FROM Sales s JOIN Orders o ON s.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Segment ORDER BY TotalSales DESC