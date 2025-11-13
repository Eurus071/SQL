--TASK1

CREATE TABLE [dbo].[TestMultipleZero]
(
    [A] [int] NULL,
    [B] [int] NULL,
    [C] [int] NULL,
    [D] [int] NULL
);
GO

INSERT INTO [dbo].[TestMultipleZero](A,B,C,D)
VALUES 
    (0,0,0,1),
    (0,0,1,0),
    (0,1,0,0),
    (1,0,0,0),
    (0,0,0,0),
    (1,1,1,0);

SELECT A, B, C, D
FROM [dbo].[TestMultipleZero]
WHERE A + B + C + D <> 0;

--TASK2
CREATE TABLE TestMax
(
    Year1 INT
    ,Max1 INT
    ,Max2 INT
    ,Max3 INT
);
GO
 
INSERT INTO TestMax 
VALUES
    (2001,10,101,87)
    ,(2002,103,19,88)
    ,(2003,21,23,89)
    ,(2004,27,28,91);

SELECT 
    Year1, Max1, Max2, Max3,
    CASE 
        WHEN Max1 >= Max2 AND Max1 >= Max3 THEN Max1
        WHEN Max2 >= Max1 AND Max2 >= Max3 THEN Max2
        ELSE Max3
    END AS OverallMax
FROM TestMax;

--TASK3
CREATE TABLE EmpBirth
(
    EmpId INT  IDENTITY(1,1) 
    ,EmpName VARCHAR(50) 
    ,BirthDate DATETIME 
);
 
INSERT INTO EmpBirth(EmpName,BirthDate)
SELECT 'Pawan' , '12/04/1983'
UNION ALL
SELECT 'Zuzu' , '11/28/1986'
UNION ALL
SELECT 'Parveen', '05/07/1977'
UNION ALL
SELECT 'Mahesh', '01/13/1983'
UNION ALL
SELECT'Ramesh', '05/09/1983';

SELECT 
    EmpId, EmpName, BirthDate,
    DATENAME(MONTH, BirthDate) + ' ' + CAST(DAY(BirthDate) AS VARCHAR(2)) AS BirthDay
FROM EmpBirth
WHERE 
    (MONTH(BirthDate) = 5 AND DAY(BirthDate) BETWEEN 7 AND 15)
    OR 
    --February 29
    (MONTH(BirthDate) = 2 AND DAY(BirthDate) = 29 AND 
     MONTH(DATEADD(DAY, 1, BirthDate)) = 3);

--TASK4
create table letters
(letter char(1));

insert into letters
values ('a'), ('a'), ('a'), 
  ('b'), ('c'), ('d'), ('e'), ('f');
--beginning
SELECT letter 
FROM letters ORDER BY CASE WHEN letter = 'b' THEN 1 ELSE 2 END, letter;

--ending
SELECT letter 
FROM letters ORDER BY CASE WHEN letter = 'b' THEN 2 ELSE 1 END, letter;

--3rd place
SELECT letter 
FROM (
    SELECT TOP 2 letter, 1 as sort_order 
	FROM letters 
	WHERE letter <> 'b' ORDER BY letter
    UNION ALL
    SELECT 'b' as letter, 2 as sort_order
    UNION ALL
    SELECT letter, 3 as sort_order 
	FROM letters 
	WHERE letter <> 'b' AND letter NOT IN (
        SELECT TOP 2 letter 
		FROM letters 
		WHERE letter <> 'b' ORDER BY letter
    )
) AS OrderedLetters
ORDER BY sort_order, letter;