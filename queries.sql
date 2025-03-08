
-- Find customers who placed two or more orders within a 7-day period 
-- And the earliest date of such an occurrence.


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


-- Find customers who placed two or more orders within a 7-day period.
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






























