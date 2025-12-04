CREATE DATABASE hmw9;
DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees
(
    EmployeeID  INTEGER PRIMARY KEY,
    ManagerID   INTEGER NULL,
    JobTitle    VARCHAR(100) NOT NULL
);

INSERT INTO Employees (EmployeeID, ManagerID, JobTitle) 
VALUES
    (1001, NULL, 'President'),
    (2002, 1001, 'Director'),
    (3003, 1001, 'Office Manager'),
    (4004, 2002, 'Engineer'),
    (5005, 2002, 'Engineer'),
    (6006, 2002, 'Engineer');


WITH EmployeeHierarchy AS (
   
    SELECT 
        EmployeeID,
        ManagerID,
        JobTitle,
        0 AS Depth
    FROM Employees
    WHERE ManagerID IS NULL  
    
    UNION ALL
   
    SELECT 
        e.EmployeeID,
        e.ManagerID,
        e.JobTitle,
        eh.Depth + 1 AS Depth
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT 
    EmployeeID,
    ManagerID,
    JobTitle,
    Depth
FROM EmployeeHierarchy
ORDER BY Depth, EmployeeID;
R BY Depth, EmployeeID;


--TASK2

-- Solution using Recursive CTE
DECLARE @N INT = 10;  -- Change this value for different N

WITH FactorialCTE AS (
    -- Anchor member: 0! = 1 (starting point)
    SELECT 
        0 AS Num,
        CAST(1 AS BIGINT) AS Factorial
    
    UNION ALL
    
    -- Recursive member: n! = n * (n-1)!
    SELECT 
        Num + 1,
        (Num + 1) * Factorial
    FROM FactorialCTE
    WHERE Num < @N
)
SELECT 
    Num AS [Num],
    Factorial
FROM FactorialCTE
WHERE Num > 0  -- Start from 1
ORDER BY Num;

-- Alternative solution using WHILE loop
DECLARE @Counter INT = 1;
DECLARE @FactorialTable TABLE (
    Num INT,
    Factorial BIGINT
);
DECLARE @Result BIGINT = 1;

WHILE @Counter <= @N
BEGIN
    SET @Result = @Result * @Counter;
    INSERT INTO @FactorialTable VALUES (@Counter, @Result);
    SET @Counter = @Counter + 1;
END

SELECT * FROM @FactorialTable ORDER BY Num;

-- Solution using CROSS JOIN for numbers generation
DECLARE @Numbers TABLE (Num INT);
INSERT INTO @Numbers VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10);

SELECT 
    n.Num,
    EXP(SUM(LOG(n2.Num))) AS Factorial
FROM @Numbers n
CROSS APPLY (
    SELECT Num FROM @Numbers n2 WHERE n2.Num <= n.Num
) n2
GROUP BY n.Num
ORDER BY n.Num;

-- Solution using Recursive CTE
DECLARE @N INT = 10;  -- Change this value for different N

WITH FibonacciCTE AS (
    -- Anchor members: F(1) = 1, F(2) = 1
    SELECT 
        1 AS n,
        CAST(1 AS BIGINT) AS Fibonacci_Number
    
    UNION ALL
    
    SELECT 
        2 AS n,
        CAST(1 AS BIGINT) AS Fibonacci_Number
    
    UNION ALL
    
    -- Recursive member: F(n) = F(n-1) + F(n-2)
    SELECT 
        f1.n + 1,
        f1.Fibonacci_Number + f2.Fibonacci_Number
    FROM FibonacciCTE f1
    JOIN FibonacciCTE f2 ON f1.n = f2.n + 1
    WHERE f1.n < @N
)
SELECT 
    n,
    Fibonacci_Number
FROM FibonacciCTE
WHERE n <= @N
ORDER BY n;

-- Alternative solution using WHILE loop
DECLARE @i INT = 3;
DECLARE @Prev1 BIGINT = 1;
DECLARE @Prev2 BIGINT = 1;
DECLARE @Current BIGINT;
DECLARE @FibonacciTable TABLE (
    n INT,
    Fibonacci_Number BIGINT
);

INSERT INTO @FibonacciTable VALUES (1, 1);
INSERT INTO @FibonacciTable VALUES (2, 1);

WHILE @i <= @N
BEGIN
    SET @Current = @Prev1 + @Prev2;
    INSERT INTO @FibonacciTable VALUES (@i, @Current);
    
    SET @Prev2 = @Prev1;
    SET @Prev1 = @Current;
    SET @i = @i + 1;
END

SELECT * FROM @FibonacciTable ORDER BY n;

-- Complete script with all tasks
PRINT '=== TASK 1: Employee Depth Hierarchy ===';

-- Task 1: Employee Depth
WITH EmployeeHierarchy AS (
    SELECT 
        EmployeeID,
        ManagerID,
        JobTitle,
        0 AS Depth
    FROM Employees
    WHERE ManagerID IS NULL
    
    UNION ALL
    
    SELECT 
        e.EmployeeID,
        e.ManagerID,
        e.JobTitle,
        eh.Depth + 1 AS Depth
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT 
    EmployeeID,
    ManagerID,
    JobTitle,
    Depth
FROM EmployeeHierarchy
ORDER BY Depth, EmployeeID;

PRINT '=== TASK 2: Factorials up to 10 ===';

-- Task 2: Factorials (N=10)
WITH Numbers AS (
    SELECT 1 AS Num
    UNION ALL
    SELECT Num + 1 FROM Numbers WHERE Num < 10
),
FactorialCTE AS (
    SELECT 
        1 AS Num,
        CAST(1 AS BIGINT) AS Factorial
    UNION ALL
    SELECT 
        n.Num,
        n.Num * f.Factorial
    FROM Numbers n
    INNER JOIN FactorialCTE f ON n.Num = f.Num + 1
    WHERE n.Num <= 10
)
SELECT Num, Factorial FROM FactorialCTE ORDER BY Num;

PRINT '=== TASK 3: Fibonacci Numbers up to 10 ===';

-- Task 3: Fibonacci Numbers (N=10)
WITH FibonacciCTE AS (
    SELECT 
        1 AS n,
        CAST(1 AS BIGINT) AS Fibonacci_Number
    UNION ALL
    SELECT 
        2 AS n,
        CAST(1 AS BIGINT) AS Fibonacci_Number
    UNION ALL
    SELECT 
        f1.n + 1,
        f1.Fibonacci_Number + f2.Fibonacci_Number
    FROM FibonacciCTE f1
    JOIN FibonacciCTE f2 ON f1.n = f2.n + 1
    WHERE f1.n < 10
)
SELECT 
    n,
    Fibonacci_Number
FROM FibonacciCTE
WHERE n <= 10
ORDER BY n;




