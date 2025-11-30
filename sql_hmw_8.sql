CREATE DATABASE hmw8;

SET NOCOUNT ON;

PRINT '=== TASK 1: Consecutive Status Values ===';

-- Task 1: Create and populate Groupings table
IF OBJECT_ID('Groupings', 'U') IS NOT NULL
    DROP TABLE Groupings;

CREATE TABLE Groupings (
    StepNumber INT PRIMARY KEY,
    Status VARCHAR(20)
);

INSERT INTO Groupings (StepNumber, Status) VALUES
(1, 'Passed'), (2, 'Passed'), (3, 'Passed'), (4, 'Passed'),
(5, 'Failed'), (6, 'Failed'), (7, 'Failed'), (8, 'Failed'),
(9, 'Failed'), (10, 'Passed'), (11, 'Passed'), (12, 'Passed');


WITH GroupedData AS (
    SELECT 
        StepNumber,
        Status,
        StepNumber - ROW_NUMBER() OVER (PARTITION BY Status ORDER BY StepNumber) AS GroupIdentifier
    FROM Groupings
)
SELECT 
    MIN(StepNumber) AS MinStepNumber,
    MAX(StepNumber) AS MaxStepNumber,
    Status,
    COUNT(*) AS ConsecutiveCount
FROM GroupedData
GROUP BY Status, GroupIdentifier
ORDER BY MinStepNumber;

PRINT '=== TASK 2: Hiring Year Gaps ===';

-- Task 2: Create and populate EMPLOYEES_N table
IF OBJECT_ID('EMPLOYEES_N', 'U') IS NOT NULL
    DROP TABLE EMPLOYEES_N;

CREATE TABLE [dbo].[EMPLOYEES_N] (
    [EMPLOYEE_ID] [int] NOT NULL,
    [FIRST_NAME] [varchar](20) NULL,
    [HIRE_DATE] [date] NOT NULL
);

INSERT INTO EMPLOYEES_N VALUES 
(1, 'John', '1975-01-15'),
(2, 'Jane', '1976-03-20'),
(3, 'Bob', '1977-08-10'),
(4, 'Alice', '1979-02-14'),
(5, 'Charlie', '1980-11-30'),
(6, 'David', '1982-04-05'),
(7, 'Eva', '1983-07-19'),
(8, 'Frank', '1984-12-25'),
(9, 'Grace', '1985-09-08'),
(10, 'Henry', '1990-06-15'),
(11, 'Ivy', '1997-03-22');


DECLARE @CurrentYear INT = YEAR(GETDATE());

WITH 
AllYears AS (
    SELECT number AS year_value
    FROM master..spt_values
    WHERE type = 'P' 
    AND number BETWEEN 1975 AND @CurrentYear
),
HiringYears AS (
    SELECT DISTINCT YEAR(HIRE_DATE) AS hire_year
    FROM EMPLOYEES_N
    WHERE YEAR(HIRE_DATE) BETWEEN 1975 AND @CurrentYear
),
MissingYears AS (
    SELECT 
        ay.year_value,
        ay.year_value - ROW_NUMBER() OVER (ORDER BY ay.year_value) AS gap_group
    FROM AllYears ay
    LEFT JOIN HiringYears hy ON ay.year_value = hy.hire_year
    WHERE hy.hire_year IS NULL
)
SELECT 
    CAST(MIN(year_value) AS VARCHAR) + ' - ' + CAST(MAX(year_value) AS VARCHAR) AS Years
FROM MissingYears
GROUP BY gap_group
ORDER BY MIN(year_value);