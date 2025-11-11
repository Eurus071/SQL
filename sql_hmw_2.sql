-- Task1
CREATE TABLE test_identity (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50),
    value INT
);

INSERT INTO test_identity (name, value) VALUES 
('Row1', 100),
('Row2', 101),
('Row3', 102),
('Row4', 103),
('Row5', 104);

SELECT * FROM test_identity;

DELETE FROM test_identity WHERE id IN (2, 4);
SELECT * FROM test_identity; 


INSERT INTO test_identity (name, value) VALUES ('Row6', 600);
SELECT * FROM test_identity; 

DROP TABLE test_identity;

CREATE TABLE test_identity (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50),
    value INT
);

INSERT INTO test_identity (name, value) VALUES 
('Row1', 100), ('Row2', 200), ('Row3', 300), ('Row4', 400), ('Row5', 500);

SELECT * FROM test_identity;

TRUNCATE TABLE test_identity;

INSERT INTO test_identity (name, value) VALUES ('NewRow1', 100);
SELECT * FROM test_identity; 

DROP TABLE test_identity;


--Task2

CREATE TABLE data_types_demo (
    -- Exact numerics
    id INT PRIMARY KEY IDENTITY(1,1),
    small_num SMALLINT,
    big_num BIGINT,
    decimal_num DECIMAL(10,2),
    numeric_num NUMERIC(8,3),
    
    -- Approximate numerics
    float_num FLOAT,
    
    -- Character strings
    char_col CHAR(10),
    varchar_col VARCHAR(50),
    text_col TEXT,
    
    -- Unicode strings
    nchar_col NCHAR(10),
    nvarchar_col NVARCHAR(50),
    ntext_col NTEXT,
    
    -- Binary data
    binary_col BINARY(10),
    varbinary_col VARBINARY(MAX),
    image_col IMAGE,
    
    -- Date and time
    date_col DATE,
    time_col TIME,

    -- Other types
    bit_col BIT,
    uniqueidentifier_col UNIQUEIDENTIFIER,

);


INSERT INTO data_types_demo (
    small_num, big_num, decimal_num, numeric_num,
    float_num,
    char_col, varchar_col, text_col,
    nchar_col, nvarchar_col, ntext_col,
    binary_col, varbinary_col, image_col,
    date_col, time_col,
    bit_col, uniqueidentifier_col
) VALUES (
    123, 123456789, 1234.56, 789.123,
    123.456,
    'Char', 'Varchar text', 'This is a longer text field',
    N'NChar', N'Unicode текст', N'Unicode longer текст',
    0x123456, 0x789ABC, 0xDEF123,
    '2024-01-15', '14:30:25', 
    1, NEWID()
);


SELECT * FROM data_types_demo;


--Task3

CREATE TABLE photos (
    id INT PRIMARY KEY IDENTITY(1,1),
    photo_name VARCHAR(100),
    photo_data VARBINARY(MAX)
);


INSERT INTO photos (photo_name, photo_data)
SELECT 'ielts_sertifikat.jpg', BulkColumn 
FROM OPENROWSET(BULK 'https://drive.google.com/file/d/1URLuAKU7Ha9WuAbhSzUC8suH3NQ0FPBi/view?usp=sharing', SINGLE_BLOB) AS image;


SELECT id, photo_name, DATALENGTH(photo_data) as photo_size FROM photos;


--Task4
DROP TABLE if exists student;
CREATE TABLE student (
    student_id INT PRIMARY KEY IDENTITY(1,1),
    student_name VARCHAR(50),
    classes INT,
    tuition_per_class DECIMAL(10,2),
    total_tuition AS (classes * tuition_per_class) PERSISTED
);


INSERT INTO student (student_name, classes, tuition_per_class) VALUES
('John Smith', 5, 100.00),
('Maria Garcia', 3, 120.50),
('David Johnson', 4, 95.75);


SELECT * FROM student;




--Task5

CREATE TABLE worker (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);


BULK INSERT worker
FROM 'D:\database\auto_dataset.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 
);

SELECT * FROM worker;



