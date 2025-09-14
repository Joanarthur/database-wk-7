--Question 1
USE salesdb;

SELECT 
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Product, ',', n), ',', -1)) AS Product
FROM ProductDetail
JOIN (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) numbers
    ON CHAR_LENGTH(Product) - CHAR_LENGTH(REPLACE(Product, ',', '')) >= n - 1
ORDER BY OrderID, n;

--Question 2
-- Create Orderss table with order and customer information
CREATE TABLE Orderss (
    orderNumber INT PRIMARY KEY,
    customerNumber INT,
    customerName VARCHAR(50),
    -- Include other order-specific fields if needed from orders table
    FOREIGN KEY (customerNumber) REFERENCES customers(customerNumber)
);

-- Populate Orderss table with order and customer data
INSERT INTO Orderss (orderNumber, customerNumber, customerName)
SELECT DISTINCT o.orderNumber, o.customerNumber, c.customerName
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber;

-- Create OrderItems table (this is already in 2NF from your existing orderdetails)
CREATE TABLE OrderItems (
    orderNumber INT,
    productCode VARCHAR(15),
    quantityOrdered INT,
    priceEach DECIMAL(10,2),
    orderLineNumber SMALLINT,
    PRIMARY KEY (orderNumber, productCode),
    FOREIGN KEY (orderNumber) REFERENCES Orderss(orderNumber)
);

-- Copy data from existing orderdetails (which is already properly normalized)
INSERT INTO OrderItems (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber)
SELECT orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber
FROM orderdetails;

-- Check Orderss table
SELECT * FROM Orderss ORDER BY orderNumber LIMIT 10;

-- Check OrderItems table
SELECT * FROM OrderItems ORDER BY orderNumber, productCode LIMIT 10;

-- Verify 2NF: Show that customer information depends only on orderNumber
SELECT orderNumber, customerNumber, customerName 
FROM Orderss 
GROUP BY orderNumber 
HAVING COUNT(DISTINCT customerName) > 1;
-- This should return 0 rows (no partial dependencies)
