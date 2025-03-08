
-------------------------------------------------------------------------------------------------------------------------------------------
*                                                                                                                                          *
*                                                 -- Handling Missing Values in Sales Data--                                               *
*                                                                                                                                          *
-------------------------------------------------------------------------------------------------------------------------------------------


-- Challenge 1: Replace missing product categories with 'Unknown' and group total revenue by category

Creating Sales Table
CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    product_category VARCHAR(50),
    revenue DECIMAL(10,2)
);

-- Inserting values
INSERT INTO Sales (sale_id, product_category, revenue) VALUES
(1, 'Electronics', 500),
(2, NULL, 300),
(3, 'Clothing', 200),
(4, NULL, 150);

--Creating Index
CREATE INDEX idx_product_category ON Sales(product_category);

-- Solution
SELECT 
    COALESCE(product_category, 'Unknown') AS product_category, 
    SUM(revenue) AS total_revenue
FROM Sales
GROUP BY product_category;

-------------------------------------------------------------------------------------------------------------------------------------------
*                                                                                                                                          *
*                                                 --First Purchase of High-Value Customers--                                               *
*                                                                                                                                          *
-------------------------------------------------------------------------------------------------------------------------------------------


-- Challenge 2: Find the first product purchased by customers who have spent more than $500

--Creating Transactions Table
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    product VARCHAR(100),
    amount DECIMAL(10,2),
    transaction_date DATE
);

--Inserting Values
INSERT INTO Transactions (transaction_id, customer_id, product, amount, transaction_date) VALUES
(1, 1, 'Laptop', 400, '2024-03-01'),
(2, 1, 'Mouse', 150, '2024-03-05'),
(3, 2, 'Keyboard', 100, '2024-03-10'),
(4, 2, 'Monitor', 450, '2024-03-15');


-- Creating Index
CREATE INDEX idx_customer_id ON Transactions(customer_id);

--Solution
WITH HighValueCustomer AS (
    SELECT customer_id FROM Transactions 
    GROUP BY customer_id
    HAVING SUM(amount) > 500
)
SELECT t.customer_id, t.product
FROM Transactions t
JOIN HighValueCustomer hc ON t.customer_id = hc.customer_id
WHERE t.transaction_date = (
    SELECT MIN(transaction_date)
    FROM Transactions
    WHERE customer_id = t.customer_id
);


-------------------------------------------------------------------------------------------------------------------------------------------
*                                                                                                                                          *
*                                                       --Consecutive Logins--                                                             *
*                                                                                                                                          *
-------------------------------------------------------------------------------------------------------------------------------------------


-- Challenge 3: Identify users who logged in at least 3 consecutive days in a row

-- Creating Table Login
CREATE TABLE Logins (
    user_id INT,
    login_date DATE,
    PRIMARY KEY (user_id, login_date)
);

-- Inserting Values
INSERT INTO Logins (user_id, login_date) VALUES
(1, '2024-03-01'),
(1, '2024-03-02'),
(1, '2024-03-03'),
(2, '2024-03-01'),
(2, '2024-03-03'),
(2, '2024-03-04');


-- Creating Index
CREATE INDEX idx_user_id ON Logins(user_id);

--Approach using Window function And Date function
WITH ConsecutiveLogins AS (
    SELECT 
        user_id, 
        login_date,
        LAG(login_date, 1) OVER (PARTITION BY user_id ORDER BY login_date) AS prev_date1,
        LAG(login_date, 2) OVER (PARTITION BY user_id ORDER BY login_date) AS prev_date2
    FROM Logins
)
SELECT DISTINCT user_id
FROM ConsecutiveLogins
WHERE login_date = DATE_ADD(prev_date1, INTERVAL 1 DAY)
AND prev_date_1 = DATE_ADD(prev_date2, INTERVAL 1 DAY);

-------------------------------------------------------------------------------------------------------------------------------------------
*                                                                                                                                          *
*                                                       --Orders Within 7 Days--                                                           *
*                                                                                                                                          *
-------------------------------------------------------------------------------------------------------------------------------------------

-- Challenge 4: Find customers who placed two or more orders within a 7-day period and the earliest date of such an occurrence


-- Creating the Customers Table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);

-- Creating Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Creating Payments Table
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Adding Indexes
CREATE INDEX idx_customer_id ON Orders(customer_id);
CREATE INDEX idx_order_date ON Orders(order_date);
CREATE INDEX idx_order_id ON Payments(order_id);


-- Insert values into the respective tables
INSERT INTO Customers (customer_id, customer_name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'David');

-- Insert Orders
INSERT INTO Orders (order_id, customer_id, order_date, amount) VALUES
(101, 1, '2024-03-01', 150.00),
(102, 1, '2024-03-05', 200.00),
(103, 1, '2024-03-10', 50.00),
(104, 2, '2024-03-02', 300.00),
(105, 2, '2024-03-06', 120.00),
(106, 3, '2024-03-10', 500.00),
(107, 3, '2024-03-12', 450.00),
(108, 4, '2024-03-15', 600.00);

-- Insert Payments
INSERT INTO Payments (payment_id, order_id, payment_date, amount) VALUES
(201, 101, '2024-03-02', 150.00),
(202, 102, '2024-03-06', 200.00),
(203, 103, '2024-03-11', 50.00),
(204, 104, '2024-03-03', 300.00),
(205, 105, '2024-03-07', 120.00),
(206, 106, '2024-03-11', 500.00),
(207, 107, '2024-03-13', 450.00),
(208, 108, '2024-03-16', 600.00);


-- Select the data to check the values
Select * from Orders;

-- Approach using Window function And Date function

With CombinedOrders As (
Select customer_id,
      order_id,
      order_date,
      Lead(order_date) Over(Partition by customer_id order by order_date) as next_purchase_date
From Orders)

Select Distinct customer_id,
      Min(order_date) as first_repeat_orderdate
From CombinedOrders
Where next_purchase_date IS NOT NULL 
And DATEDIFF(next_purchase_date, order_date) <= 7
Group by customer_id;
