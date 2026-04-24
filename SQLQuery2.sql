
-- 1. DIMENSION: CHANNEL 
-- Step 1 — Create DimChannel 
CREATE TABLE DimChannel ( 
Channel_ID INT IDENTITY(1,1) PRIMARY KEY, 
Channel VARCHAR(100) 
); 

-- Step 2 — Populate DimChannel 
INSERT INTO DimChannel (Channel) 
SELECT DISTINCT Channel 
FROM [pharma-data_RawData] 
WHERE Channel IS NOT NULL AND Channel <> ''; 

---------------------------------------------------------------
--  2. DIMENSION: SUB‑CHANNEL 
-- Step 1 — Create DimSubChannel 
CREATE TABLE DimSubChannel ( 
SubChannel_ID INT IDENTITY(1,1) PRIMARY KEY, 
SubChannel NVARCHAR(255), 
Channel_ID INT 
); 

-- Step 2 — Populate DimSubChannel 
INSERT INTO DimSubChannel (SubChannel, Channel_ID) 
SELECT DISTINCT p.Sub_Channel, c.Channel_ID 
FROM [dbo].[pharma-data_RawData] p 
INNER JOIN DimChannel c ON p.Channel = c.Channel 
WHERE p.Sub_Channel IS NOT NULL AND p.Sub_Channel <> ''; 

-- Step 3 — Add SubChannel_ID to Fact Table 
ALTER TABLE [dbo].[pharma-data_RawData] ADD SubChannel_ID INT NULL; 

-- Step 4 — Update Fact Table 
UPDATE p 
SET p.SubChannel_ID = sc.SubChannel_ID 
FROM [dbo].[pharma-data_RawData] p 
INNER JOIN DimSubChannel sc ON p.Sub_Channel = sc.SubChannel; 
---------------------------------------------------------------------------
-- 3. DIMENSION: DISTRIBUTOR 
-- Step 1 — Create Distributor Dimension 
CREATE TABLE DimDistributor ( 
Distributor_ID INT IDENTITY(1,1) PRIMARY KEY, 
Distributor VARCHAR(200) 
); 

-- Step 2 — Populate Distributor Dimension 
INSERT INTO DimDistributor (Distributor) 
SELECT DISTINCT Distributor 
FROM [pharma-data_RawData] 
WHERE Distributor IS NOT NULL AND Distributor <> ''; 

-- Step 3 — Add Distributor_ID to Fact Table 
ALTER TABLE [pharma-data_RawData] ADD Distributor_ID INT; 

-- Step 4 — Update Fact Table 
UPDATE pd 
SET pd.Distributor_ID = dd.Distributor_ID 
FROM [pharma-data_RawData] pd 
INNER JOIN DimDistributor dd 
ON pd.Distributor = dd.Distributor; 

-------------------------------------------------------------------
-- 4. DIMENSION: COUNTRY 
-- Step 1 — Create DimCountry 
CREATE TABLE DimCountry ( 
CountryID INT IDENTITY(1,1) PRIMARY KEY, 
CountryName VARCHAR(100) 
); 

-- Step 2 — Populate Countries 
INSERT INTO DimCountry (CountryName) 
SELECT DISTINCT Country 
FROM [pharma-data_RawData] 
WHERE Country IS NOT NULL AND Country <> ''; 
--------------------------------------------------------------------

-- 5. DIMENSION: CITY 
-- Step 1 — Create DimCity 
SELECT DISTINCT City, Latitude, Longitude 
INTO DimCity 
FROM [dbo].[pharma-data_RawData] 
WHERE City IS NOT NULL; 

-- Step 2 — Add Primary Key 
ALTER TABLE DimCity ADD City_ID INT IDENTITY(1,1) PRIMARY KEY; 

-- Step 3 — Add Country_ID 
ALTER TABLE DimCity ADD Country_ID INT; 

-- Step 4 — Populate Country_ID 
UPDATE dc 
SET dc.Country_ID = dco.CountryID 
FROM DimCity dc 
INNER JOIN [dbo].[pharma-data_RawData] pd ON dc.City = pd.City 
INNER JOIN DimCountry dco ON pd.Country = dco.CountryName; 

-- Step 5 — Add City_ID to Fact Table 
ALTER TABLE [dbo].[pharma-data_RawData] ADD City_ID INT NULL; 

-- Step 6 — Update City_ID in Fact Table 
UPDATE p 
SET p.City_ID = c.City_ID 
FROM [dbo].[pharma-data_RawData] p 
INNER JOIN DimCity c ON p.City = c.City; 
--------------------------------------------------------------------
-- 6. DIMENSION: CUSTOMER 
-- Step 1 — Build DimCustomer 
SELECT DISTINCT Customer_Name, City, City_ID 
INTO DimCustomer 
FROM [dbo].[pharma-data_RawData] 
WHERE Customer_Name IS NOT NULL; 

-- Step 2 — Add Customer_ID 
ALTER TABLE DimCustomer ADD Customer_ID INT IDENTITY(1,1); 

-- Step 3 — Add Primary Key 
ALTER TABLE DimCustomer 
ADD CONSTRAINT PK_DimCustomer PRIMARY KEY (Customer_ID); 

-- Step 4 — Add Column in Fact Table 
ALTER TABLE [dbo].[pharma-data_RawData] ADD Customer_ID INT NULL; 

-- Step 5 — Update Fact Table 
UPDATE p 
SET p.Customer_ID = c.Customer_ID 
FROM [dbo].[pharma-data_RawData] p 
INNER JOIN DimCustomer c 
ON p.Customer_Name = c.Customer_Name 
AND p.City = c.City; 

------------------------------------------------------------------------
-- 7. DIMENSION: SALES TEAM 

-- Step 1 — Create DimSalesTeam 
CREATE TABLE DimSalesTeam ( 
SalesTeam_ID INT IDENTITY(1,1) PRIMARY KEY, 
Manager NVARCHAR(255), 
SalesTeam NVARCHAR(255) 
); 

-- Step 2 — Insert Data 
INSERT INTO DimSalesTeam (Manager, SalesTeam) 
SELECT DISTINCT Manager, Sales_Team 
FROM [dbo].[pharma-data_RawData] 
WHERE Sales_Team IS NOT NULL; 

------------------------------------------------------------------------
--  8. DIMENSION: SALES REP 

-- Step 1 — Create DimSalesRep 
CREATE TABLE DimSalesRep ( 
SalesRep_ID INT IDENTITY(1,1) PRIMARY KEY, 
SalesRep NVARCHAR(255), 
SalesTeam_ID INT 
); 

-- Step 2 — Populate Data 
INSERT INTO DimSalesRep (SalesRep, SalesTeam_ID) 
SELECT DISTINCT p.Name_of_Sales_Rep, s.SalesTeam_ID 
FROM [dbo].[pharma-data_RawData] p 
INNER JOIN DimSalesTeam s 
ON p.Manager = s.Manager 
AND p.Sales_Team = s.SalesTeam 
WHERE p.Name_of_Sales_Rep IS NOT NULL; 

-- Step 3 — Add Column to Fact Table 
ALTER TABLE [dbo].[pharma-data_RawData] ADD SalesRep_ID INT NULL; 

-- Step 4 — Update Fact Table 
UPDATE p 
SET p.SalesRep_ID = s.SalesRep_ID 
FROM [dbo].[pharma-data_RawData] p 
INNER JOIN DimSalesRep s 
ON p.Name_of_Sales_Rep = s.SalesRep; 

---------------------------------------------------------------------------
--  9. DIMENSION: PRODUCT 

-- Step 1 — Create DimProduct 
CREATE TABLE DimProduct ( 
Product_ID INT IDENTITY(1,1) PRIMARY KEY, 
ProductClass NVARCHAR(255), 
ProductName NVARCHAR(255) 
); 

-- Step 2 — Populate Product Dimension 
INSERT INTO DimProduct (ProductClass, ProductName) 
SELECT DISTINCT Product_Class, Product_Name 
FROM [dbo].[pharma-data_RawData] 
WHERE Product_Name IS NOT NULL; 

-- Step 3 — Add Product_ID to Fact Table 
ALTER TABLE [dbo].[pharma-data_RawData] ADD Product_ID INT NULL; 

-- Step 4 — Update Fact Table 
UPDATE p 
SET p.Product_ID = pr.Product_ID 
FROM [dbo].[pharma-data_RawData] p 
INNER JOIN DimProduct pr 
ON p.Product_Class = pr.ProductClass 
AND p.Product_Name = pr.ProductName; 

--------------------------------------------------------------------------
-- 10. DIMENSION: MONTH 

--  Step 1 — Create DimMonth 
CREATE TABLE DimMonth ( 
Month_ID INT PRIMARY KEY, 
MonthName NVARCHAR(50) 
); 

-- Step 2 — Populate Month Dimension 
INSERT INTO DimMonth (Month_ID, MonthName) 
VALUES 
(1,'January'),(2,'February'),(3,'March'),(4,'April'), 
(5,'May'),(6,'June'),(7,'July'),(8,'August'), 
(9,'September'),(10,'October'),(11,'November'),(12,'December'); 

-- Step 3 — Add Month_ID to Fact Table 
ALTER TABLE [dbo].[pharma-data_RawData] ADD Month_ID INT NULL; 

-- Step 4 — Update Fact Table 
UPDATE p 
SET p.Month_ID = m.Month_ID 
FROM [dbo].[pharma-data_RawData] p 
INNER JOIN DimMonth m ON p.Month = m.MonthName; 
------------------------------------------------------------------



