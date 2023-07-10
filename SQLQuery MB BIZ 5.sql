Question 1 -- Provide the top 10 customers (full name) by revenue, the country they shipped to, the cities and 
-- their revenue (orderqty * unitprice).
-- This insight will help you understand where your top spending customers are coming from. You can 
-- market better, get more capable customer service rep, have more stock and build partnerships in these
-- countries and cities.

select top (10) concat(c.FirstName,' ',c.LastName) as 'Full name',
a.CountryRegion as 'Country',
a.City as 'City',
sum(sod.OrderQty *UnitPrice) as 'Revenue'
from SalesLT.Customer c
join SalesLT.SalesOrderHeader soh on c.CustomerID = soh.CustomerID
join SalesLT.CustomerAddress ca on c.CustomerID = ca.CustomerID
join SalesLT.[Address] a on ca.AddressID = a.AddressID
join SalesLT.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
group by c.FirstName, c.LastName, a.CountryRegion, a.City
order by Revenue DESC;

-- Question 2 -- Create 4 distinct Customer segments using the total Revenue (orderqty * unitprice) by customer. 
-- List the customer details (ID, Company Name), Revenue and the segment the customer belongs to. 
-- This analysis can use to create a loyalty program, mmarket customers with discount or leave customers as-is.
/*Question 2:
Create 4 distinct Customer segments using the total Revenue (orderqty * unitprice) by customer. 
List the customer details (ID, Company Name), Revenue, and the segment the customer belongs to.
*/
--select * from SalesLT.SalesOrderDetail
 --Total Revenue , 
 --customerId, Company Name  -- Customer Table - c
 --Revenue ---- SalesOrderDetail table --sod
 --SalesLT.SalesOrderHeader ---soh

 Select c.CustomerID, c.CompanyName, sum(sod.OrderQty * sod.UnitPrice) as 'Total_Revenue',
	case
		when sum (sod.OrderQty * sod.UnitPrice) >= 50000 then 'High Patronage'
		when sum (sod.OrderQty * sod.UnitPrice) >= 50000 then 'Medium Patronage'
		when sum (sod.OrderQty * sod.UnitPrice) >= 50000 then 'Low Patronage'
		when sum (sod.OrderQty * sod.UnitPrice) >= 50000 then 'Extremely Low Patronage'
		else 'low revenue'
	end as CustomerSegment
from SalesLT.Customer c
JOIN SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN SalesLT.SalesOrderDetail sod on sod.SalesOrderID = soh.SalesOrderID 
GROUP BY c.CustomerID, c.CompanyName
ORDER BY 'Total_Revenue' DESC;

-- Question 3 -- What products with their respective categories did our customers buy on our last day of business?
-- List the CustomerID, Product ID, Product Name, Category Name and Order Date.
-- This insight will help understand the latest products and categories that your customers bought from. This will help
-- you do near-real-time marketing and stockpiling for these products.
/*Question 3:
What products with their respective categories did our customers buy on our last day of business? 
List the CustomerID, Product ID, Product Name, Category Name, and Order Date.*/
--customerID --SalesOrderHeader table --soh
--ProductId --SalesOderDetails table --sod
--ProductName --product table --p
--Category Name --ProductCategory table --pc
--Order Date --SalesOrderHeader --soh
--relationship --salesorderID
--relationship --productID
--relationship --ProductCategoryID 

select soh.CustomerID, sod.ProductID, p.[Name], pc.[Name] as CategoryName, soh.OrderDate
from SalesLT.SalesOrderHeader soh
join SalesLT.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
join SalesLT.Product p on sod.ProductID = p.ProductID 
join SalesLT.ProductCategory pc on pc.ProductCategoryID = p.ProductCategoryID
where soh.OrderDate = (select MAX(OrderDate) from SalesLT.SalesOrderHeader)

-- Question 4 -- Create a View called customersegment that stores the details (id, name, revenue) for customers
-- and their segment? i.e. build a view for Question 2.
-- You can connect this view to Tableau and get insights without needing to write the same query every time.
Create a View called customer segments that stores the details (id, name, revenue) for customers 
and their segment (from Question 2).*/

create view customersegment as
select c.customerid, c.CompanyName, sum(sod.OrderQty * sod.UnitPrice) as 'Revenue',
	case
		when sum(sod.OrderQty * UnitPrice) >= 10000 then 'High Revenue'
		when sum(sod.OrderQty * UnitPrice) >= 5000 then 'Medium Revenue'
		when sum(sod.OrderQty * UnitPrice) >= 2000 then 'Low Revenue'
		else 'very low revenue'
	end as CustomerSegment
from SalesLT.Customer c
join SalesLT.SalesOrderHeader soh on c.CustomerID = soh.CustomerID
join SalesLT.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
group by c.customerID, c.CompanyName;

-- Question 5 -- What are the top 3 selling product (include productname) in each category (include categoryname)
-- by revenue? Tip: Use ranknum
-- This analysis will ensure you can keep track of your top selling products in each category. The output is very
-- powerful because you don't have to write multiple queries to be able to see your top selling products in each category.
-- This analysis will inform your marketing, your supply chain, your partnerships, position of products on your website, etc.
-- NB: This question is asked a lot in interviews!

---Productname ---Product Category table -- pc
--Category Name --product table -- p
select Productname, categoryName, revenue
from (
	select pc.[Name] as CategoryName, p.[Name] as ProductName,
	sum(sod.OrderQty * sod.UnitPrice) as 'Revenue',
	rank() over (partition by pc.[Name] order by sum(sod.OrderQty * sod.UnitPrice) desc) as Ranknum
from SalesLT.SalesOrderDetail sod
join SalesLT.Product p on sod.ProductID = P.ProductID
join SalesLT.ProductCategory pc on p.ProductCategoryID =pc.ProductCategoryID
group by pc.[Name], p.[Name]
) ranked 
where Ranknum <= 3;


