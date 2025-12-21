CREATE DATABASE hmw11;
USE hmw11;

-- 1. 
DROP TABLE IF EXISTS Employees;

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(50),
    Department VARCHAR(20),
    Salary INT
);
INSERT INTO Employees VALUES
(1, 'Alice', 'HR', 5000),
(2, 'Bob', 'IT', 7000),
(3, 'Charlie', 'Sales', 6000),
(4, 'David', 'HR', 5500),
(5, 'Emma', 'IT', 7200);

CREATE TABLE #EmployeeTransfers (
    EmployeeID INT,
    Name NVARCHAR(50),
    Department NVARCHAR(50),
    Salary DECIMAL(10, 2)
);


INSERT INTO #EmployeeTransfers (EmployeeID, Name, Department, Salary)
SELECT 
    EmployeeID,
    Name,
    CASE Department
        WHEN 'HR' THEN 'IT'
        WHEN 'IT' THEN 'Sales'
        WHEN 'Sales' THEN 'HR'
        ELSE Department 
    END AS NewDepartment,
    Salary
FROM Employees;

SELECT * FROM #EmployeeTransfers;


-- 2.

DROP TABLE IF EXISTS Orders_DB1;
DROP TABLE IF EXISTS Orders_DB2;

CREATE TABLE Orders_DB1 (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(50),
    Product VARCHAR(50),
    Quantity INT
);

CREATE TABLE Orders_DB2 (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(50),
    Product VARCHAR(50),
    Quantity INT
);

INSERT INTO Orders_DB1 VALUES
(101, 'Alice', 'Laptop', 1),
(102, 'Bob', 'Phone', 2),
(103, 'Charlie', 'Tablet', 1),
(104, 'David', 'Monitor', 1);

INSERT INTO Orders_DB2 VALUES
(101, 'Alice', 'Laptop', 1),
(103, 'Charlie', 'Tablet', 1);
DECLARE @MissingOrders TABLE (
    OrderID INT,
    CustomerName NVARCHAR(50),
    Product NVARCHAR(50),
    Quantity INT
);


INSERT INTO @MissingOrders (OrderID, CustomerName, Product, Quantity)
SELECT 
    o1.OrderID,
    o1.CustomerName,
    o1.Product,
    o1.Quantity
FROM Orders_DB1 o1
LEFT JOIN Orders_DB2 o2 ON o1.OrderID = o2.OrderID
WHERE o2.OrderID IS NULL; 

SELECT * FROM @MissingOrders;


-- 3.

DROP TABLE IF EXISTS WorkLog;

CREATE TABLE WorkLog (
    EmployeeID INT,
    EmployeeName VARCHAR(50),
    Department VARCHAR(20),
    WorkDate DATE,
    HoursWorked INT
);
INSERT INTO WorkLog VALUES
(1, 'Alice', 'HR', '2024-03-01', 8),
(2, 'Bob', 'IT', '2024-03-01', 9),
(3, 'Charlie', 'Sales', '2024-03-02', 7),
(1, 'Alice', 'HR', '2024-03-03', 6),
(2, 'Bob', 'IT', '2024-03-03', 8),
(3, 'Charlie', 'Sales', '2024-03-04', 9);

DROP VIEW IF EXISTS vw_MonthlyWorkSummary;
GO  

CREATE VIEW vw_MonthlyWorkSummary AS
SELECT
    EmployeeID,
    EmployeeName,
    Department,
    SUM(HoursWorked) OVER (PARTITION BY EmployeeID) AS TotalHoursWorked,
    SUM(HoursWorked) OVER (PARTITION BY Department) AS TotalHoursDepartment,
    AVG(HoursWorked) OVER (PARTITION BY Department) AS AvgHoursDepartment
FROM WorkLog;

