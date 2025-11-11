CREATE DATABASE hmw3;

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10,2),
    HireDate DATE
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    OrderDate DATE,
    TotalAmount DECIMAL(10,2),
    Status VARCHAR(20) CHECK (Status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled'))
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    Stock INT
);
--TASK1
WITH RankedEmployees AS (
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        Department,
        Salary,
        PERCENT_RANK() OVER (ORDER BY Salary DESC) AS PercentRank
    FROM Employees
),
TopEmployees AS (
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        Department,
        Salary,
        CASE 
            WHEN Salary > 80000 THEN 'High'
            WHEN Salary BETWEEN 50000 AND 80000 THEN 'Medium'
            ELSE 'Low'
        END AS SalaryCategory
    FROM RankedEmployees
    WHERE PercentRank <= 0.1  -- Top 10%
),
DepartmentStats AS (
    SELECT 
        Department,
        AVG(Salary) AS AverageSalary,
        COUNT(*) AS EmployeeCount
    FROM TopEmployees
    GROUP BY Department
)
SELECT 
    Department,
    AverageSalary,
    EmployeeCount
FROM DepartmentStats
ORDER BY AverageSalary DESC
OFFSET 2 ROWS FETCH NEXT 5 ROWS ONLY;

--TASK2
WITH OrderCategorized AS (
    SELECT 
        CustomerName,
        TotalAmount,
        CASE 
            WHEN Status IN ('Shipped', 'Delivered') THEN 'Completed'
            WHEN Status = 'Pending' THEN 'Pending'
            WHEN Status = 'Cancelled' THEN 'Cancelled'
        END AS OrderStatus
    FROM Orders
    WHERE OrderDate BETWEEN '2023-01-01' AND '2023-12-31'
),
StatusSummary AS (
    SELECT 
        OrderStatus,
        COUNT(*) AS TotalOrders,
        SUM(TotalAmount) AS TotalRevenue
    FROM OrderCategorized
    GROUP BY OrderStatus
)
SELECT 
    OrderStatus,
    TotalOrders,
    TotalRevenue
FROM StatusSummary
WHERE TotalRevenue > 5000
ORDER BY TotalRevenue DESC;

--TASK3
WITH CategoryMaxPrice AS (
    SELECT 
        Category,
        MAX(Price) AS MaxPrice
    FROM Products
    GROUP BY Category
),
MostExpensiveProducts AS (
    SELECT DISTINCT
        p.Category,
        p.ProductName,
        p.Price,
        p.Stock,
        IIF(p.Stock = 0, 'Out of Stock',
            IIF(p.Stock BETWEEN 1 AND 10, 'Low Stock', 'In Stock')
        ) AS InventoryStatus
    FROM Products p
    INNER JOIN CategoryMaxPrice cmp ON p.Category = cmp.Category AND p.Price = cmp.MaxPrice
)
SELECT 
    Category,
    ProductName,
    Price,
    Stock,
    InventoryStatus
FROM MostExpensiveProducts
ORDER BY Price DESC
OFFSET 5 ROWS;
