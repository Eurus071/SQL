DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    name VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10,2),
    HireDate DATE
);
--TASK1

SELECT EmployeeID, name, Salary, 
RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
FROM Employees;

--Task2

WITH SalaryRanks AS (
    SELECT EmployeeID, name, Salary,
    RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM Employees
)
SELECT EmployeeID, name, Salary, SalaryRank
FROM SalaryRanks
WHERE SalaryRank IN (
    SELECT SalaryRank 
    FROM SalaryRanks 
    GROUP BY SalaryRank 
    HAVING COUNT(*) > 1
);

--TASK3

WITH DepartmentSalaries AS (
    SELECT EmployeeID, name, Department, Salary,
    DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DeptSalaryRank
    FROM Employees
)
SELECT EmployeeID, name, Department, Salary
FROM DepartmentSalaries
WHERE DeptSalaryRank <= 2;

--TASK4

WITH DepartmentMin AS (
    SELECT EmployeeID, name, Department, Salary,
    ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary ASC) AS RowNum
    FROM Employees
)
SELECT EmployeeID, name, Department, Salary
FROM DepartmentMin
WHERE RowNum = 1;

--TASK5

SELECT EmployeeID, name, Department, Salary,
    SUM(Salary) OVER (
        PARTITION BY Department 
        ORDER BY EmployeeID
        ROWS UNBOUNDED PRECEDING
    ) AS RunningTotal
FROM Employees;

--TASK6

SELECT DISTINCT Department,
SUM(Salary) OVER (PARTITION BY Department) AS TotalSalary
FROM Employees
ORDER BY TotalSalary DESC;

--TASK7

SELECT DISTINCT Department,
AVG(Salary) OVER (PARTITION BY Department) AS AvgSalary,
COUNT(*) OVER (PARTITION BY Department) AS EmployeeCount
FROM Employees
ORDER BY AvgSalary DESC;

--TASK8

SELECT EmployeeID, name, Department, Salary,
AVG(Salary) OVER (PARTITION BY Department) AS DeptAvgSalary,
Salary - AVG(Salary) OVER (PARTITION BY Department) AS DifferenceFromAvg
FROM Employees;

--TASK9

SELECT EmployeeID, name, Salary,
AVG(Salary) OVER (
    ORDER BY EmployeeID
     ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
     ) AS MovingAvg3
FROM Employees;

--TASK10

WITH LastHired AS (
    SELECT EmployeeID, name, HireDate, Salary,
      ROW_NUMBER() OVER (ORDER BY HireDate DESC) AS HireRank
    FROM Employees
)
SELECT SUM(Salary) AS Last3HiredSalarySum
FROM LastHired
WHERE HireRank <= 3;

--TASK11

SELECT EmployeeID, name, Salary,
    AVG(Salary) OVER (
        ORDER BY EmployeeID
        ROWS UNBOUNDED PRECEDING
    ) AS RunningAvg
FROM Employees;

--TASK12

SELECT EmployeeID, name, Salary,
    MAX(Salary) OVER (
        ORDER BY EmployeeID
        ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
    ) AS MaxIn5EmployeeWindow
FROM Employees;

--TASK13

SELECT EmployeeID, name, Department, Salary,
    SUM(Salary) OVER (PARTITION BY Department) AS DeptTotalSalary,
    ROUND((Salary * 100.0 / SUM(Salary) OVER (PARTITION BY Department)), 2) AS PercentageContribution
FROM Employees
ORDER BY Department, PercentageContribution DESC;
