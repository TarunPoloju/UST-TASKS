CREATE DATABASE sample;
USE sample;


CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT,
    hire_date DATE
);
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50)
);
CREATE TABLE salaries (
    employee_id INT,
    salary INT,
    bonus INT,
    PRIMARY KEY (employee_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);



INSERT INTO employees (employee_id, first_name, last_name, department_id, hire_date)
VALUES (101, 'John', 'Doe', 1, '2020-01-01'),
       (102, 'Jane', 'Smith', 2, '2019-03-15'),
       (103, 'Robert', 'Brown', 3, '2018-06-20'),
       (104, 'Emily', 'Davis', 1, '2021-11-05'),
       (105, 'Michael', 'Johnson', 4, '2017-09-10');

INSERT INTO departments (department_id, department_name)
VALUES (1, 'Sales'), (2, 'HR'), (3, 'IT'), (4, 'Finance');
 
INSERT INTO salaries (employee_id, salary, bonus)
VALUES (101, 60000, 5000),
       (102, 55000, 4000),
       (103, 70000, 6000),
       (104, 62000, 4500),
       (105, 80000, 7000);

 drop table salaries;
 drop table employees;
 drop table departments;
 
 

 
select e.first_name,e.last_name, d.department_name
from employees e
inner join departments d on e.department_id= d.department_id;
 
select e.first_name,e.last_name, d.department_name
from employees e
left join departments d on e.department_id= d.department_id;
 
select e.first_name,e.last_name, d.department_name
from employees e
right  join departments d on e.department_id= d.department_id;
 
select e1.first_name as employee1,e2.first_name as employee2, e1.department_id
from employees e1
join employees e2 on e1.department_id=e2.department_id and e1.employee_id != e2.employee_id;
 
select e1.first_name as employee1,e2.first_name as employee2, e1.department_id
from employees e1
join employees e2 on 
e1.department_id=e2.department_id and 
e1.employee_id < e2.employee_id;

-- Find the employees with salaries above the average salary of all employees.
SELECT first_name, last_name
FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM salaries
    WHERE salary > (SELECT AVG(salary) FROM salaries)
);

-- Find the employees who earn more than the average salary in their respective department.
SELECT e.first_name, e.last_name
FROM employees e
WHERE (SELECT AVG(s.salary) 
       FROM salaries s 
       JOIN employees em ON s.employee_id = em.employee_id
       WHERE em.department_id = e.department_id) > 
      (SELECT AVG(salary) FROM salaries);

-- Rank employees based on their salary in descending order.
SELECT employee_id, salary, 
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM salaries;

-- Calculate total salary expenditure by department.
SELECT e.department_id, 
       SUM(s.salary) OVER (PARTITION BY e.department_id) AS total_salary
FROM employees e
JOIN salaries s ON e.employee_id = s.employee_id;


-- Find all employees whose first names start with a vowel and whose last names end with a consonant.

SELECT *
FROM employees
WHERE first_name REGEXP '^[AEIOUaeiou]'
  AND last_name REGEXP '[^AEIOUaeiou]$'; 


-- For each department, display the total salary expenditure, the average salary, and the highest salary.

SELECT d.department_name,s.salary,
    SUM(s.salary) OVER (PARTITION BY d.department_id) AS total_expenditure,
    AVG(s.salary) OVER (PARTITION BY d.department_id) AS average_salary,
    MAX(s.salary) OVER (PARTITION BY d.department_id) AS highest_salary
FROM 
    departments d
JOIN 
    employees e ON d.department_id = e.department_id
JOIN 
    salaries s ON e.employee_id = s.employee_id;


-- Fetch all employees, their department name,  their manager’s name (if they have one), and their salary.

ALTER TABLE employees ADD COLUMN manager_id INT;

-- Sample data for manager_id
UPDATE employees
SET manager_id = NULL WHERE employee_id = 101; 
UPDATE employees
SET manager_id = 101 WHERE employee_id IN (102, 103, 104, 105); 

-- Final query to fetch employees, department, salary, and manager's name
SELECT 
    e.employee_id,
    e.first_name AS employee_first_name,
    e.last_name AS employee_last_name,
    d.department_name,
    s.salary,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM 
    employees e
JOIN 
    departments d ON e.department_id = d.department_id
JOIN 
    salaries s ON e.employee_id = s.employee_id
LEFT JOIN 
    employees m ON e.manager_id = m.employee_id;


-- Create a query using a recursive CTE to list all employees 
-- and their respective reporting chains (managers up to the top).

WITH RECURSIVE Reporting AS (
    SELECT 
        employee_id,first_name,last_name,manager_id,
        CONCAT(first_name, ' ', last_name) AS full_chain 
    FROM 
        employees
    WHERE 
        manager_id IS NULL 

    UNION ALL

    SELECT e.employee_id,e.first_name,e.last_name,e.manager_id,
        CONCAT(rc.full_chain, ' -> ', e.first_name, ' ', e.last_name) AS full_chain -- Append the employee's name to the chain
    FROM 
        employees e
    JOIN 
        Reporting rc ON e.manager_id = rc.employee_id 
)

SELECT 
    employee_id,first_name,last_name,full_chain
FROM 
    Reporting
ORDER BY 
    employee_id;


-- Fetch the details of employees earning above a certain salary threshold.

SELECT e.employee_id,e.first_name,e.last_name,s.salary,d.department_name
FROM employees e
JOIN salaries s ON e.employee_id = s.employee_id
JOIN departments d ON e.department_id = d.department_id
WHERE s.salary > 70000;


-- Q6
CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    salesperson_id INT,
    customer_id INT,
    sale_amount DECIMAL(10, 2),
    sale_date DATE
);
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    product_category VARCHAR(100),
    price DECIMAL(10, 2)
);
CREATE TABLE salespersons (
    salesperson_id INT PRIMARY KEY AUTO_INCREMENT,
    salesperson_name VARCHAR(100),
    hire_date DATE,
    region VARCHAR(100)
);
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone_number VARCHAR(15),
    address VARCHAR(255)
);


INSERT INTO sales (product_id, salesperson_id, customer_id, sale_amount, sale_date)
VALUES
    (1, 1, 1, 5000.00, '2024-01-01'),
    (1, 2, 2, 7000.00, '2024-01-02'),
    (1, 3, 3, 3000.00, '2024-01-03'),
    (2, 1, 4, 4000.00, '2024-02-01'),
    (2, 2, 5, 8000.00, '2024-02-02'),
    (3, 1, 6, 6000.00, '2024-03-01'),
    (3, 3, 7, 12000.00, '2024-03-05'),
    (3, 2, 8, 3000.00, '2024-03-10'),
    (2, 3, 9, 5000.00, '2024-04-01'),
    (1, 1, 10, 4000.00, '2024-04-10');

INSERT INTO products (product_name, product_category, price)
VALUES
    ('Product A', 'Electronics', 5000.00),
    ('Product B', 'Furniture', 4000.00),
    ('Product C', 'Appliances', 6000.00);
    
INSERT INTO salespersons (salesperson_name, hire_date, region)
VALUES
    ('John Doe', '2020-01-15', 'North'),
    ('Jane Smith', '2019-05-20', 'East'),
    ('Michael Brown', '2018-07-11', 'West');

INSERT INTO customers (customer_name, email, phone_number, address)
VALUES
    ('Alice Johnson', 'alice.johnson@example.com', '123-456-7890', '123 Maple Street'),
    ('Bob Williams', 'bob.williams@example.com', '987-654-3210', '456 Oak Avenue'),
    ('Charlie Davis', 'charlie.davis@example.com', '555-123-4567', '789 Pine Road'),
    ('David Smith', 'david.smith@example.com', '444-567-8910', '101 Cedar Blvd'),
    ('Eva Brown', 'eva.brown@example.com', '333-789-0123', '202 Birch Lane');


drop table sales;
drop table products;
drop table salespersons;
drop table customers;
drop table temp_sales_report;



CREATE TEMPORARY TABLE temp_sales_report(
    product_id INT,
    product_name VARCHAR(100),
    total_sales DECIMAL(10, 2),
    avg_sales_per_customer DECIMAL(10, 2),
    top_salesperson VARCHAR(100)
);

INSERT INTO temp_sales_report(product_id, product_name, total_sales, avg_sales_per_customer, top_salesperson)
SELECT
    p.product_id,
    p.product_name,
    SUM(s.sale_amount) AS total_sales, 
    AVG(s.sale_amount) AS avg_sales_per_customer, 
    (SELECT sp.salesperson_name
     FROM sales s1
     JOIN salespersons sp ON s1.salesperson_id = sp.salesperson_id
     WHERE s1.product_id = p.product_id
     GROUP BY s1.salesperson_id
     ORDER BY SUM(s1.sale_amount) DESC
     LIMIT 1) AS top_salesperson 
FROM
    sales s
JOIN
    products p ON s.product_id = p.product_id
JOIN
    salespersons sp ON s.salesperson_id = sp.salesperson_id
JOIN
    customers c ON s.customer_id = c.customer_id
GROUP BY
    p.product_id, p.product_name;


SELECT * FROM temp_sales_report;



