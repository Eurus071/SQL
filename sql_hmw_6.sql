CREATE DATABASE hmw6;
DROP TABLE IF EXISTS  Departments;
CREATE TABLE Departments(
DepartmentID INT PRIMARY KEY,
DepartmentName VARCHAR(50) NOT NULL
);

INSERT INTO Departments(DepartmentID, DepartmentName) VALUES
(101, 'IT'),
(102, 'HR'),
(103, 'Finance'),
(104, 'Marketing');

DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees(
EmployeeID int PRIMARY KEY,
name VARCHAR(50) NOT NULL,
DepartmentID INT,
Salary INT NOT NULL,
FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID) 
);

INSERT INTO Employees(EmployeeID, name, DepartmentID, Salary) VALUES
(1, 'Alice', 101, 60000),
(2, 'Bob', 102, 70000),
(3, 'Charlie', 101, 65000),
(4, 'David', 103, 72000),
(5, 'Eva', NULL, 68000);



DROP TABLE IF EXISTS Projects;
CREATE TABLE Projects(
ProjectID INT PRIMARY KEY,
ProjectName VARCHAR(50) NOT NULL,
EmployeeID INT,
FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

INSERT INTO Projects(ProjectID, ProjectName, EmployeeID) VALUES
(1, 'Alpha', 1),
(2, 'Beta', 2),
(3, 'Gamma', 1),
(4, 'Delta', 4),
(5, 'Omega', NULL);

--TASK1 //INNER JOIN

SELECT E.EmployeeID, E.name, D.DepartmentName
FROM Employees AS E
JOIN Departments AS D
ON E.DepartmentID=D.DepartmentID


--TASK2 //LEFT JOIN

SELECT E.EmployeeID, E.name, D.DepartmentName
FROM Employees AS E
LEFT JOIN Departments AS D
ON E.DepartmentID=D.DepartmentID;

--TASK3 //RIGHT JOIN

SELECT D.DepartmentName, E.EmployeeID, E.name
FROM Employees AS E
RIGHT JOIN Departments AS D
ON E.DepartmentID=D.DepartmentID;

--TASK4 // FULL OUTER JOIN

SELECT E.EmployeeID, E.name, D.DepartmentID, D.DepartmentName
FROM Employees AS E
FULL OUTER JOIN Departments AS D
ON E.DepartmentID=D.DepartmentID;

--TASK5 // JOIN with Aggregation

SELECT D.DepartmentID, D.DepartmentName, SUM(E.Salary) AS TotalSalary
FROM Departments AS D
JOIN Employees AS E
ON D.DepartmentID=E.DepartmentID
GROUP BY D.DepartmentID, D.DepartmentName;

--TASK6 //CROSS JOIN

SELECT D.DepartmentID, D.DepartmentName, P.ProjectID, P.ProjectName
FROM Projects AS P
CROSS JOIN Departments AS D


--TASK7 //MULTIPLE JOINS

SELECT E.EmployeeID, E.Name, D.DepartmentID, D.DepartmentName, P.Projectname
FROM Employees AS E
LEFT JOIN Departments AS D
ON E.DepartmentID=D.DepartmentID
LEFT JOIN Projects AS P
ON E.EmployeeID= P.EmployeeID;