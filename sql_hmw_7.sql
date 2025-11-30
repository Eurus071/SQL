DROP TABLE IF EXISTS Customers;
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);
DROP TABLE IF EXISTS Products;
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50)
);

DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE
);

DROP TABLE IF EXISTS OrderDetails;
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10,2),

    CONSTRAINT FK_OrderDetails_Orders 
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),

    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

--TASK1

SELECT 
    c.CustomerID,
    c.CustomerName,
    o.OrderID,
    o.OrderDate
FROM Customers AS c
LEFT JOIN Orders AS o ON c.CustomerID = o.CustomerID;

--TASK2

SELECT 
    c.CustomerID,
    c.CustomerName
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;
--TASK3

SELECT 
    o.OrderID,
    o.OrderDate,
    p.ProductName,
    od.Quantity
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
ORDER BY o.OrderID;

--TASK4

SELECT 
    c.CustomerID,
    c.CustomerName,
    COUNT(o.OrderID) AS OrderCount
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName
HAVING COUNT(o.OrderID) > 1;

--TASK5

WITH RankedProducts AS (
    SELECT 
        od.OrderID,
        p.ProductName,
        od.Price,
        ROW_NUMBER() OVER (PARTITION BY od.OrderID ORDER BY od.Price DESC) as rn
    FROM OrderDetails od
    JOIN Products p ON od.ProductID = p.ProductID
)
SELECT 
    OrderID,
    ProductName,
    Price
FROM RankedProducts
WHERE rn = 1;

--TASK6

WITH LatestOrders AS (
    SELECT 
        CustomerID,
        OrderID,
        OrderDate,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC) as rn
    FROM Orders
)
SELECT 
    c.CustomerName,
    lo.OrderID,
    lo.OrderDate
FROM LatestOrders lo
JOIN Customers c ON lo.CustomerID = c.CustomerID
WHERE lo.rn = 1;

--TASK7

SELECT 
    c.CustomerID,
    c.CustomerName
FROM Customers c
WHERE c.CustomerID IN (
    SELECT o.CustomerID
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE p.Category = 'Electronics'
)
AND c.CustomerID NOT IN (
    SELECT o.CustomerID
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    WHERE p.Category != 'Electronics'
);

--TASK8

SELECT DISTINCT
    c.CustomerID,
    c.CustomerName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE p.Category = 'Stationery';

--TASK9

SELECT 
    c.CustomerID,
    c.CustomerName,
    COALESCE(SUM(od.Quantity * od.Price), 0) AS TotalSpent
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY TotalSpent DESC;

