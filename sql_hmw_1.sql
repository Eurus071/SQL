create database sql_lesson_1
-- Task1
CREATE TABLE student(
    id INT,
    name VARCHAR(50),
    age INT
);

ALTER TABLE student ALTER COLUMN id INT NOT NULL;

--Task2
CREATE TABLE product (
    product_id INT,
    product_name VARCHAR(50),
    price DECIMAL(10,2)
);

ALTER TABLE product ADD CONSTRAINT UC_product_id UNIQUE (product_id);
ALTER TABLE product DROP CONSTRAINT UC_product_id;
ALTER TABLE product ADD CONSTRAINT UC_product_id UNIQUE (product_id);

-- Add composite unique constraint with explicit name
ALTER TABLE product ADD CONSTRAINT UC_product_composite UNIQUE (product_id, product_name);

--Task3

CREATE TABLE orders (
    order_id INT,
    customer_name VARCHAR(50),
    order_date DATE
);

ALTER TABLE orders ADD CONSTRAINT PK_orders_order_id PRIMARY KEY (order_id);
ALTER TABLE orders DROP CONSTRAINT PK_orders_order_id;
ALTER TABLE orders ADD CONSTRAINT PK_orders_order_id PRIMARY KEY (order_id);
ALTER TABLE orders ADD CONSTRAINT PK_orders_order_id PRIMARY KEY (order_id);

-- Task4
CREATE TABLE category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE item (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(50),
    category_id INT
);

ALTER TABLE item ADD CONSTRAINT FK_item_category_id FOREIGN KEY (category_id) REFERENCES category(category_id);
ALTER TABLE item DROP CONSTRAINT FK_item_category_id;
ALTER TABLE item ADD CONSTRAINT FK_item_category_id FOREIGN KEY (category_id) REFERENCES category(category_id);

-- Task5
CREATE TABLE account (
    account_id INT PRIMARY KEY,
    balance DECIMAL(10,2),
    account_type VARCHAR(20)
);

ALTER TABLE account ADD CONSTRAINT CK_account_balance CHECK (balance >= 0);
ALTER TABLE account ADD CONSTRAINT CK_account_type CHECK (account_type IN ('Saving', 'Checking'));
ALTER TABLE account DROP CONSTRAINT CK_account_balance;
ALTER TABLE account DROP CONSTRAINT CK_account_type;
ALTER TABLE account ADD CONSTRAINT CK_account_balance CHECK (balance >= 0);
ALTER TABLE account ADD CONSTRAINT CK_account_type CHECK (account_type IN ('Saving', 'Checking'));

-- Task6
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50)
);

ALTER TABLE customer ADD CONSTRAINT DF_customer_city DEFAULT 'Unknown' FOR city;
ALTER TABLE customer DROP CONSTRAINT DF_customer_city;
ALTER TABLE customer ADD CONSTRAINT DF_customer_city DEFAULT 'Unknown' FOR city;

-- Task7
CREATE TABLE invoice (
    invoice_id INT IDENTITY(1,1) PRIMARY KEY,
    amount DECIMAL(10,2)
);

INSERT INTO invoice (amount) VALUES (100.00), (200.50), (300.75), (400.25), (500.00);

SET IDENTITY_INSERT invoice ON;
INSERT INTO invoice (invoice_id, amount) VALUES (100, 600.50);
SET IDENTITY_INSERT invoice OFF;

-- Task8
CREATE TABLE books (
    book_id INT IDENTITY(1,1),
    title VARCHAR(100),
    price DECIMAL(10,2),
    genre VARCHAR(50)
);


ALTER TABLE books ADD CONSTRAINT PK_books_id PRIMARY KEY (book_id);
ALTER TABLE books ALTER COLUMN title VARCHAR(100) NOT NULL;
ALTER TABLE books ADD CONSTRAINT CK_books_title CHECK (LEN(title) > 0);
ALTER TABLE books ADD CONSTRAINT CK_books_price CHECK (price > 0);
ALTER TABLE books ADD CONSTRAINT DF_books_genre DEFAULT 'Unknown' FOR genre;

-- Test inserts
INSERT INTO books (title, price, genre) VALUES ('Database Design', 29.99, 'Education');
INSERT INTO books (title, price) VALUES ('SQL Basics', 19.99);

-- Task9
CREATE TABLE Book (
    book_id INT IDENTITY(1,1) PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL,
    published_year INT
);

ALTER TABLE Book ADD CONSTRAINT CK_Book_published_year 
CHECK (published_year > 1500 AND published_year <= YEAR(GETDATE()));

CREATE TABLE Member (
    member_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone_number VARCHAR(20)
);

ALTER TABLE Member ADD CONSTRAINT UC_Member_email UNIQUE (email);

CREATE TABLE Loan (
    loan_id INT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL DEFAULT GETDATE(),
    return_date DATE NULL
);

ALTER TABLE Loan ADD CONSTRAINT FK_Loan_Book 
FOREIGN KEY (book_id) REFERENCES Book(book_id);

ALTER TABLE Loan ADD CONSTRAINT FK_Loan_Member 
FOREIGN KEY (member_id) REFERENCES Member(member_id);

ALTER TABLE Loan ADD CONSTRAINT CK_Loan_dates 
CHECK (return_date IS NULL OR return_date >= loan_date);

-- Insert sample data
INSERT INTO Book (title, author, published_year) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 1945),
('To Kill a Mockingbird', 'Harper Lee', 1980);

INSERT INTO Member (name, email, phone_number) VALUES
('John Smith', 'john.smith@email.com', '254544534'),
('Maria Garcia', 'maria.garcia@email.com', '54658435');

INSERT INTO Loan (book_id, member_id, loan_date, return_date) VALUES
(1, 1, '2024-01-15', '2024-02-01'),
(2, 2, '2024-01-20', NULL);

-- Show current loans
SELECT 
    b.title, 
    b.author, 
    m.name AS member_name, 
    l.loan_date
FROM Loan l
JOIN Book b ON l.book_id = b.book_id
JOIN Member m ON l.member_id = m.member_id
WHERE l.return_date IS NULL;

