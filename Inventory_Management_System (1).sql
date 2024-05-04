-- Create the database if it doesn't exist and use it
CREATE DATABASE IF NOT EXISTS Inventory_Management_System;
USE Inventory_Management_System;

-- Create Brands table
CREATE TABLE brands (bid INT(5),bname VARCHAR(20),PRIMARY KEY (bid));
desc brands;

-- Insert data into Brands table
INSERT INTO brands VALUES (1, 'Apple');
INSERT INTO brands VALUES (2, 'Samsung');
-- Insert more data as needed
select * from brands;


-- Create Inventory User table
CREATE TABLE inv_user (
    user_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(20),
    password VARCHAR(20),
    last_login TIMESTAMP,
    user_type VARCHAR(10)
);
desc inv_user;
-- Insert data into Inventory User table
INSERT INTO inv_user VALUES ('vidit@gmail.com', 'vidit', '1234', '2018-10-31 12:40:00', 'admin');
INSERT INTO inv_user VALUES ('harsh@gmail.com', 'Harsh Khanelwal', '1111', '2018-10-30 10:20:00', 'Manager');
-- Insert more data as needed
select * from inv_user;


-- Create Categories table
CREATE TABLE categories (
    cid INT(5),
    category_name VARCHAR(20),
    PRIMARY KEY (cid)
);

desc categories;
-- Insert data into Categories table
INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO categories VALUES (2, 'Clothing');
-- Insert more data as needed
select * from categories;


-- Create Stores table
CREATE TABLE stores (
    sid INT(5) PRIMARY KEY,
    sname VARCHAR(20),
    address VARCHAR(20),
    mobno VARCHAR(20) -- Useig  VARCHAR for phone numbers
);
desc stores;

-- Insert data into Stores table
INSERT INTO stores VALUES (1, 'Ram Kumar', 'Katpadi Vellore', '9999999999');
INSERT INTO stores VALUES (2, 'Rakesh Kumar', 'Chennai', '8888555541');
-- Insert more data as needed
select * from stores;


-- Create Product table
CREATE TABLE product (
    pid INT(5) PRIMARY KEY,
    cid INT(5) REFERENCES categories(cid),
    bid INT(5) REFERENCES brands(bid),
    sid INT(5) REFERENCES stores(sid),
    pname VARCHAR(20),
    p_stock INT(5),
    price INT(5),
    added_date DATE
);
desc product;
-- Insert data into Product table
INSERT INTO product (pid, cid, bid, sid, pname, p_stock, price, added_date)
VALUES
(1, 1, 1, 1, 'IPHONE', 4, 45000, '2018-10-31'),
(2, 1, 1, 1, 'Airpods', 3, 19000, '2018-10-27'),
(3, 1, 1, 1, 'Smart Watch', 3, 19000, '2018-10-27'),
(4, 2, 3, 2, 'Air Max', 6, 7000, '2018-10-27'),
(5, 3, 4, 3, 'REFINED OIL', 6, 750, '2018-10-25');
-- Insert more data as needed
select * from product;

-- Create Provides table
CREATE TABLE provides (
    bid INT(5) REFERENCES brands(bid),
    sid INT(5) REFERENCES stores(sid),
    discount INT(5)
);
desc provides;
-- Insert data into Provides table
INSERT INTO provides (bid, sid, discount)
VALUES
(1, 1, 12),
(2, 2, 7),
(3, 3, 15),
(1, 2, 7),
(4, 2, 19),
(4, 3, 20);
-- Insert more data as needed
select * from provides;

-- Create Customer Cart table
CREATE TABLE customer_cart (
    cust_id INT(5) PRIMARY KEY,
    name VARCHAR(20),
    mobno VARCHAR(20) -- Use VARCHAR for phone numbers
);
desc customer_cart;

-- Insert data into Customer Cart table
INSERT INTO customer_cart (cust_id, name, mobno)
VALUES
(1, 'Ram', '9876543210'),
(2, 'Shyam', '7777777777'),
(3, 'Mohan', '7777777775');
-- Insert more data as needed
select * from customer_cart;

-- Create Select Product table
CREATE TABLE select_product (
    cust_id INT(5) REFERENCES customer_cart(cust_id),
    pid INT(5) REFERENCES product(pid),
    quantity INT(4)
);
desc  select_product;
-- Insert data into Select Product table
INSERT INTO select_product (cust_id, pid, quantity)
VALUES
(1, 2, 2),
(1, 3, 1),
(2, 3, 3),
(3, 2, 1);
-- Insert more data as needed
select * from  select_product;

-- Create Transaction table
CREATE TABLE `transaction` (
    id INT(5) PRIMARY KEY,
    total_amount INT(5),
    paid INT(5),
    due INT(5),
    gst INT(3),
    discount INT(5),
    payment_method VARCHAR(10),
    cart_id INT(5) REFERENCES customer_cart(cust_id)
);
desc transaction;

-- Insert data into Transaction table
INSERT INTO `transaction` (id, total_amount, paid, due, gst, discount, payment_method, cart_id)
VALUES
(1, 57000, 20000, 5000, 350, 350, 'card', 1),
(2, 57000, 57000, 0, 570, 570, 'cash', 2),
(3, 19000, 17000, 2000, 190, 190, 'cash', 3);
select * from transaction;

-- Create Invoice table
CREATE TABLE invoice (
    item_no INT(5),
    product_name VARCHAR(20),
    quantity INT(5),
    net_price INT(5),
    transaction_id INT(5) REFERENCES `transaction`(id)
);
desc invoice;
-- Insert data into Invoice table
INSERT INTO invoice (item_no, product_name, quantity, net_price, transaction_id)
VALUES
(1, 'Product A', 10, 50, 101),
(2, 'Product B', 5, 20, 102),
(3, 'Product C', 3, 30, 103);
select * from invoice;

-- Stored Procedure to get cart
DELIMITER //
CREATE PROCEDURE get_cart(IN c_id INT)
BEGIN
    DECLARE due1 INT;
    DECLARE cart_id1 INT;
    
    SET cart_id1 = c_id;
    
    SELECT due INTO due1 FROM `transaction` WHERE cart_id = cart_id1;
    
    SELECT due1;
END//
DELIMITER ;
-- Call the get_cart procedure
CALL get_cart(1);


-- Stored Procedure to display products
DELIMITER //
CREATE PROCEDURE display_products()
BEGIN
    DECLARE p_id INT;
    DECLARE p_name VARCHAR(20);
    DECLARE p_stock INT;
    DECLARE done BOOLEAN DEFAULT FALSE;
    -- Declare a cursor to select products
    DECLARE p_product CURSOR FOR
        SELECT pid, pname, p_stock FROM product;
    -- Declare a handler for when no more rows are found
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    -- Create a temporary table to store product information
    CREATE TEMPORARY TABLE temp_product_info (
        product_info VARCHAR(100)
    );
    OPEN p_product;
    -- Loop through each product and store its information
    product_loop: LOOP
        FETCH p_product INTO p_id, p_name, p_stock;
        IF done THEN
            LEAVE product_loop;
        END IF;
        -- Store product information in the temporary table
        INSERT INTO temp_product_info (product_info) VALUES (CONCAT(p_id, ' ', p_name, ' ', p_stock));
    END LOOP;
    CLOSE p_product;
    -- Select and display product information from the temporary table
    SELECT * FROM temp_product_info;
    -- Drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_product_info;
END//

DELIMITER ;
-- Call the display_products procedure
CALL display_products();

-- Stored Procedure to check stock
DELIMITER //
CREATE PROCEDURE check_stock(IN x INT)
BEGIN
    IF x < 2 THEN
        SELECT 'Stock is Less';
    ELSE
        SELECT 'Enough Stock';
    END IF;
END//
DELIMITER ;

-- Call the check_stock procedure
CALL check_stock(2);

-- You can use a join to display product information along with their respective categories.
 SELECT p.pid, p.pname, p.p_stock, c.category_name
FROM product p
INNER JOIN categories c ON p.cid = c.cid;

-- To count the total stock of goods belonging to each category (e.g., electronics, clothing), you can use the SUM() 
-- function to calculate the total stock quantity for each category. Here's how you can do it
SELECT
    c.category_name,
    SUM(p.p_stock) AS total_stock,SUM(p.price) as total_price,COUNT(*) AS total_goods_by_name_type
FROM
    product p
INNER JOIN
    categories c ON p.cid = c.cid 
GROUP BY
    c.category_name
    order by category_name;


-- to get to know hoe much price is ther for perticular brand in total
SELECT 
    b.bname AS brand_name, 
    SUM(p.p_stock) AS total_stock,SUM(p.price) as total_price
FROM 
    product p
left JOIN 
    brands b ON p.bid = b.bid
GROUP BY 
    b.bname;





