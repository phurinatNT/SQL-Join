-- 1. รหัสใบสั่งซื้อ, ชื่อบริษัทลูกค้า, ชื่อและนามสกุลพนักงาน, วันที่สั่งซื้อ, ชื่อบริษัทขนส่ง, เมือง, ประเทศ, ยอดเงินที่ต้องรับ
SELECT o.OrderID, c.CompanyName, e.FirstName + ' ' + e.LastName AS EmployeeName, o.OrderDate,
       s.CompanyName AS Shipper, o.ShipCity, o.ShipCountry,
       SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalAmount
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Employees e ON o.EmployeeID = e.EmployeeID
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Shippers s ON o.ShipVia = s.ShipperID
GROUP BY o.OrderID, c.CompanyName, e.FirstName, e.LastName, o.OrderDate, s.CompanyName, o.ShipCity, o.ShipCountry

-- 2. ข้อมูลบริษัทลูกค้า, ผู้ติดต่อ, เมือง, ประเทศ, จำนวนใบสั่งซื้อ, ยอดการสั่งซื้อ (ม.ค.-มี.ค. 1997)
SELECT c.CompanyName, c.ContactName, c.City, c.Country,
       COUNT(o.OrderID) AS OrderCount,
       SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalAmount
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE o.OrderDate BETWEEN '1997-01-01' AND '1997-03-31'
GROUP BY c.CompanyName, c.ContactName, c.City, c.Country

-- 3. ชื่อเต็มพนักงาน, ตำแหน่ง, เบอร์โทร, จำนวนใบสั่งซื้อ, ยอดการสั่งซื้อ (พ.ย.-ธ.ค. 2539, ส่งไป USA/Canada/Mexico)
SELECT e.FirstName + ' ' + e.LastName AS EmployeeName, e.Title, e.HomePhone,
       COUNT(o.OrderID) AS OrderCount,
       SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalAmount
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE o.OrderDate BETWEEN '1996-11-01' AND '1996-12-31'
  AND o.ShipCountry IN ('USA', 'Canada', 'Mexico')
GROUP BY e.FirstName, e.LastName, e.Title, e.HomePhone

-- 4. รหัสสินค้า, ชื่อสินค้า, ราคาต่อหน่วย, จำนวนที่ขายได้ (มิ.ย. 2540)
SELECT p.ProductID, p.ProductName, p.UnitPrice,
       SUM(od.Quantity) AS TotalQuantity
FROM Products p
JOIN [Order Details] od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.OrderDate BETWEEN '1997-06-01' AND '1997-06-30'
GROUP BY p.ProductID, p.ProductName, p.UnitPrice

-- 5. รหัสสินค้า, ชื่อสินค้า, ราคาต่อหน่วย, ยอดเงินที่ขายได้ (ม.ค. 2540, ทศนิยม 2 ตำแหน่ง)
SELECT p.ProductID, p.ProductName, p.UnitPrice,
       ROUND(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 2) AS TotalAmount
FROM Products p
JOIN [Order Details] od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.OrderDate BETWEEN '1997-01-01' AND '1997-01-31'
GROUP BY p.ProductID, p.ProductName, p.UnitPrice

-- 6. บริษัทตัวแทนจำหน่าย, ผู้ติดต่อ, เบอร์โทร, Fax, รหัสสินค้า, ชื่อสินค้า, ราคา, จำนวนรวมที่จำหน่าย (ปี 1996)
SELECT s.CompanyName, s.ContactName, s.Phone, s.Fax,
       p.ProductID, p.ProductName, p.UnitPrice,
       SUM(od.Quantity) AS TotalQuantity
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
JOIN [Order Details] od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = 1996
GROUP BY s.CompanyName, s.ContactName, s.Phone, s.Fax, p.ProductID, p.ProductName, p.UnitPrice

-- 7. รหัสสินค้า, ชื่อสินค้า, ราคาต่อหน่วย, จำนวนที่ขายได้ (Seafood, ส่งไป USA, ปี 1997)
SELECT p.ProductID, p.ProductName, p.UnitPrice,
       SUM(od.Quantity) AS TotalQuantity
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
JOIN [Order Details] od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE c.CategoryName = 'Seafood'
  AND o.ShipCountry = 'USA'
  AND YEAR(o.OrderDate) = 1997
GROUP BY p.ProductID, p.ProductName, p.UnitPrice

-- 8. ชื่อเต็มพนักงาน Sale Representative, อายุงาน(ปี), จำนวนใบสั่งซื้อ (ปี 1998)
SELECT e.FirstName + ' ' + e.LastName AS EmployeeName, e.Title,
       DATEDIFF(YEAR, e.HireDate, '1998-12-31') AS YearsOfService,
       COUNT(o.OrderID) AS OrderCount
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
WHERE e.Title = 'Sales Representative'
  AND YEAR(o.OrderDate) = 1998
GROUP BY e.FirstName, e.LastName, e.Title, e.HireDate

-- 9. ชื่อเต็มพนักงาน, ตำแหน่ง, ขายสินค้าให้ Frankenversand (ปี 1996)
SELECT DISTINCT e.FirstName + ' ' + e.LastName AS EmployeeName, e.Title
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.CompanyName = 'Frankenversand'
  AND YEAR(o.OrderDate) = 1996

-- 10. ชื่อสกุลพนักงาน, ยอดขายสินค้าประเภท Beverage ที่แต่ละคนขายได้ (ปี 1996)
SELECT e.FirstName + ' ' + e.LastName AS EmployeeName,
       SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS BeverageSales
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Beverages'
  AND YEAR(o.OrderDate) = 1996
GROUP BY e.FirstName, e.LastName

-- 11. ชื่อประเภทสินค้า, รหัสสินค้า, ชื่อสินค้า, ยอดเงินที่ขายได้(หักส่วนลด) (ม.ค.-มี.ค. 2540, Nancy)
SELECT c.CategoryName, p.ProductID, p.ProductName,
       SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalAmount
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE e.FirstName = 'Nancy'
  AND o.OrderDate BETWEEN '1997-01-01' AND '1997-03-31'
GROUP BY c.CategoryName, p.ProductID, p.ProductName

-- 12. ชื่อบริษัทลูกค้าที่ซื้อสินค้าประเภท Seafood ในปี 1997
SELECT DISTINCT c.CompanyName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories ca ON p.CategoryID = ca.CategoryID
WHERE ca.CategoryName = 'Seafood'
  AND YEAR(o.OrderDate) = 1997

-- 13. บริษัทขนส่งที่ส่งสินค้าให้ลูกค้าที่อยู่ถนน Johnstown Road พร้อมวันที่ส่ง (รูปแบบ 106)
SELECT DISTINCT s.CompanyName, o.ShippedDate
FROM Orders o
JOIN Shippers s ON o.ShipVia = s.ShipperID
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.Address LIKE '%Johnstown Road%'

-- 14. รหัสประเภทสินค้า, ชื่อประเภท, จำนวนสินค้า, ยอดรวมที่ขายได้ (ทศนิยม 4 ตำแหน่ง, หักส่วนลด)
SELECT c.CategoryID, c.CategoryName,
       COUNT(p.ProductID) AS ProductCount,
       ROUND(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 4) AS TotalSales
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY c.CategoryID, c.CategoryName

-- 15. บริษัทลูกค้าใน London, Cowes ที่สั่งซื้อ Seafood จากตัวแทนจำหน่ายในญี่ปุ่น รวมมูลค่า
SELECT c.CompanyName, SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalAmount
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories ca ON p.CategoryID = ca.CategoryID
JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE ca.CategoryName = 'Seafood'
  AND c.City IN ('London', 'Cowes')
  AND s.Country = 'Japan'
GROUP BY c.CompanyName

-- 16. รหัสบริษัทขนส่ง, ชื่อบริษัทขนส่ง, จำนวน orders, ค่าขนส่งทั้งหมด (เฉพาะที่ส่งไป USA)
SELECT s.ShipperID, s.CompanyName,
       COUNT(o.OrderID) AS OrderCount,
       SUM(o.Freight) AS TotalFreight
FROM Shippers s
JOIN Orders o ON s.ShipperID = o.ShipVia
WHERE o.ShipCountry = 'USA'
GROUP BY s.ShipperID, s.CompanyName

-- 17. พนักงานอายุมากกว่า 60 ปี, บริษัทลูกค้า, ผู้ติดต่อ, เบอร์โทร, Fax, ยอดรวม Condiment (ทศนิยม 4 ตำแหน่ง, ลูกค้ามีเบอร์แฟกซ์)
SELECT e.FirstName + ' ' + e.LastName AS EmployeeName,
       c.CompanyName, c.ContactName, c.Phone, c.Fax,
       ROUND(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 4) AS CondimentTotal
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories ca ON p.CategoryID = ca.CategoryID
WHERE ca.CategoryName = 'Condiments'
  AND DATEDIFF(YEAR, e.BirthDate, GETDATE()) > 60
  AND c.Fax IS NOT NULL
GROUP BY e.FirstName, e.LastName, c.CompanyName, c.ContactName, c.Phone, c.Fax

-- 18. วันที่ 3 มิ.ย. 2541 พนักงานแต่ละคนขายได้เท่าใด (แสดงคนที่ไม่ได้ขายด้วย)
SELECT e.FirstName + ' ' + e.LastName AS EmployeeName,
       ISNULL(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 0) AS TotalSales
FROM Employees e
LEFT JOIN Orders o ON e.EmployeeID = o.EmployeeID AND o.OrderDate = '1998-06-03'
LEFT JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY e.FirstName, e.LastName

-- 19. รหัสรายการสั่งซื้อ, ชื่อพนักงาน, บริษัทลูกค้า, เบอร์โทร, วันที่ต้องการสินค้า, มากาเร็ต, ยอดเงินรวม (ทศนิยม 2 ตำแหน่ง)
SELECT o.OrderID, e.FirstName + ' ' + e.LastName AS EmployeeName,
       c.CompanyName, c.Phone, o.RequiredDate,
       ROUND(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 2) AS TotalAmount
FROM Orders o
JOIN Employees e ON o.EmployeeID = e.EmployeeID
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE e.FirstName = 'Margaret'
GROUP BY o.OrderID, e.FirstName, e.LastName, c.CompanyName, c.Phone, o.RequiredDate

-- 20. ชื่อเต็มพนักงาน, อายุงาน(ปี/เดือน), ยอดขายรวม, ลูกค้าใน USA/Canada/Mexico, ไตรมาสแรกปี 2541
SELECT e.FirstName + ' ' + e.LastName AS EmployeeName,
       DATEDIFF(YEAR, e.HireDate, o.OrderDate) AS YearsOfService,
       DATEDIFF(MONTH, e.HireDate, o.OrderDate) AS MonthsOfService,
       SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalSales
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.Country IN ('USA', 'Canada', 'Mexico')
  AND o.OrderDate BETWEEN '1998-01-01' AND '1998-03-31'
GROUP BY e.FirstName, e.LastName, e.HireDate, o.OrderDate
