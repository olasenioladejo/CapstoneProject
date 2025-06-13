USE AdventureWorks2019;

-- PART A - JOINS

-- 1. List employees with their department names
-- This query joins three tables to show each employee’s department. Employee records are linked through their department history, which then connects to the department name.

Select * FROM HumanResources.Employee;
Select * FROM HumanResources.EmployeeDepartmentHistory;
Select * FROM HumanResources.Department;

SELECT e.BusinessEntityID, e.JobTitle, d.Name AS Department
FROM HumanResources.Employee AS e
JOIN HumanResources.EmployeeDepartmentHistory AS dh ON e.BusinessEntityID = dh.BusinessEntityID
JOIN HumanResources.Department AS d ON dh.DepartmentID = d.DepartmentID;

--2. Show product names with subcategory and category. Products are linked to subcategories, which in turn are linked to categories.

Select * FROM Production.Product;
Select * FROM Production.ProductSubcategory;
Select * FROM Production.ProductCategory;

SELECT p.Name AS Product, sc.Name AS Subcategory, c.Name AS Category
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory AS c ON sc.ProductCategoryID = c.ProductCategoryID;

-- 3. Customers with their billing address and city

Select * FROM Sales.Customer;
Select * FROM Person.Person;
Select * FROM Person.BusinessEntityAddress;
Select * FROM Person.Address;
SELECT * FROM Person.StateProvince;

SELECT p.FirstName, p.LastName, a.AddressLine1, a.City, sp.Name AS StateProvince
FROM Sales.Customer AS c
JOIN Person.Person As p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress AS bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address AS a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
WHERE c.PersonID IS NOT NULL;

-- 4. Purchase orders with vendor names. This shows each purchase order and the vendor who supplied it.

SELECT * FROM Purchasing.PurchaseOrderHeader;
SELECT * FROM Purchasing.Vendor;

SELECT poh.PurchaseOrderID, v.Name AS Vendor
FROM Purchasing.PurchaseOrderHeader AS poh
JOIN Purchasing.Vendor AS v ON poh.VendorID = v.BusinessEntityID;

-- 5. Sales orders with product names and quantity. This gets the products sold on each sales order and the quantity ordered.

SELECT * FROM Sales.SalesOrderHeader;
SELECT * FROM Sales.SalesOrderDetail;
SELECT * FROM Production.Product;

SELECT soh.SalesOrderID, p.Name AS Product, sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail As sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS p ON sod.ProductID = p.ProductID;

-- 6. List all products along with their vendor names and standard prices

SELECT * FROM Purchasing.ProductVendor;
SELECT * FROM Production.Product;
SELECT * FROM Purchasing.Vendor;

SELECT p.Name AS Product_Name, v.Name AS Vendor_Name, pv.StandardPrice
FROM Purchasing.ProductVendor AS pv
JOIN Production.Product AS p ON pv.ProductID = p.ProductID
JOIN Purchasing.Vendor AS v ON pv.BusinessEntityID = v.BusinessEntityID;

-- 7. List of employees with their assigned shift

SELECT * FROM HumanResources.Employee;
SELECT * FROM HumanResources.EmployeeDepartmentHistory;
SELECT * FROM HumanResources.Shift;

SELECT e.BusinessEntityID, e.JobTitle, s.Name AS Shift
FROM HumanResources.Employee AS e
JOIN HumanResources.EmployeeDepartmentHistory AS dh ON e.BusinessEntityID = dh.BusinessEntityID
JOIN HumanResources.Shift AS s ON dh.ShiftID = s.ShiftID;

-- 8. List of vendors and the products they supply

SELECT * FROM Purchasing.ProductVendor;
SELECT * FROM Production.Product;
SELECT * FROM Purchasing.Vendor;

SELECT v.Name AS Vendor, p.Name AS Product
FROM Purchasing.ProductVendor AS pv
JOIN Purchasing.Vendor AS v ON pv.BusinessEntityID = v.BusinessEntityID
JOIN Production.Product AS p ON pv.ProductID = p.ProductID;

-- 9. List of inventory by product and location. Joins the inventory table with products and storage locations.

SELECT * FROM Production.Product;
SELECT * FROM Production.ProductInventory;
SELECT * FROM Production.Location;

SELECT p.Name AS Product, pi.Quantity, l.Name AS Location
FROM Production.Product AS p
JOIN Production.ProductInventory AS pi ON p.ProductID = pi.ProductID
JOIN Production.Location As l ON pi.LocationID = l.LocationID;

-- PART B - Subquery-Based Queries

--10. Compares each employee’s hire date to the overall average hire date

SELECT * FROM HumanResources.Employee;

SELECT BusinessEntityID, JobTitle, HireDate
FROM HumanResources.Employee
WHERE HireDate > (SELECT DATEADD(DAY, AVG(DATEDIFF(DAY, '19000101', HireDate)), '19000101')
FROM HumanResources.Employee);

-- 11. Finds products whose price is higher than the average list price (excluding zeroes).

SELECT * FROM Production.Product;

SELECT Name, ListPrice
FROM Production.Product
WHERE ListPrice > (SELECT AVG(ListPrice)
FROM Production.Product WHERE ListPrice > 0);

-- 12. List of Customers with more than 10 orders

SELECT * FROM Sales.SalesOrderHeader;

SELECT CustomerID, COUNT(CustomerID) AS Number_Orders
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(CustomerID) > 10;

-- 13. List of employees in the Sales department

SELECT * FROM Person.Person;
SELECT * FROM HumanResources.Employee;
SELECT * FROM HumanResources.EmployeeDepartmentHistory;
SELECT * FROM HumanResources.Department;

SELECT p.FirstName, p.LastName
FROM Person.Person AS p
WHERE BusinessEntityID IN (SELECT e.BusinessEntityID
FROM HumanResources.Employee AS e
JOIN HumanResources.EmployeeDepartmentHistory AS dh ON e.BusinessEntityID = dh.BusinessEntityID
JOIN HumanResources.Department AS d ON dh.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales');

-- 14. List of products that never sold

SELECT * FROM Production.Product;
SELECT * FROM Sales.SalesOrderDetail;

SELECT ProductID, Name
FROM Production.Product
WHERE ProductID NOT IN (SELECT DISTINCT ProductID
FROM Sales.SalesOrderDetail);

-- 15. List of employees earning above their own average rate. For each employee, checks if their current rate is above their own historical average.

SELECT * FROM HumanResources.Employee;
SELECT * FROM HumanResources.EmployeePayHistory;

SELECT e.BusinessEntityID, e.JobTitle, ep.Rate
FROM HumanResources.Employee AS e
JOIN HumanResources.EmployeePayHistory AS ep ON e.BusinessEntityID = ep.BusinessEntityID
WHERE ep.Rate > (SELECT AVG(ep2.Rate)
FROM HumanResources.EmployeePayHistory AS ep2
WHERE ep2.BusinessEntityID = e.BusinessEntityID);

