CREATE TABLE CustomerData (
    CustomerID INT PRIMARY KEY,
    Age INT,
    Gender VARCHAR(10),
    ItemPurchased VARCHAR(100),
    Category VARCHAR(100),
    PurchaseAmount DECIMAL(10, 2),
    Location VARCHAR(100),
    Size VARCHAR(10),
    Color VARCHAR(50),
    Season VARCHAR(50),
    ReviewRating DECIMAL(3, 1),
    SubscriptionStatus VARCHAR(10),
    ShippingType VARCHAR(50),
    DiscountApplied VARCHAR(10),
    PromoCodeUsed VARCHAR(10),
    PreviousPurchases INT,
    PaymentMethod VARCHAR(50),
    FrequencyOfPurchases VARCHAR(50),
    DateOfPurchase DATETIME,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Email VARCHAR(100),
    PhoneNumber VARCHAR(20),
    TransactionID INT,
    InteractionID INT,
    AgentName VARCHAR(50)
);
BULK INSERT CustomerData
FROM 'C:\Users\Aya Elsheshtawy\Desktop\DEPI\TRY_3\Customer Data.csv'
WITH (FORMAT = 'CSV'
     , FIRSTROW=2
      , FIELDTERMINATOR = ','
      , ROWTERMINATOR = '0x0a');
--______________________________________________________________________________________________________________________________________________________
CREATE TABLE CustomerInformation (
    CustomerID INT PRIMARY KEY,
	FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Age INT,
    Gender VARCHAR(10),
    Email VARCHAR(100),
    PhoneNumber VARCHAR(20),
    Location VARCHAR(255),
    SubscriptionStatus VARCHAR(50),
);
INSERT INTO CustomerInformation (CustomerID,FirstName, LastName,Email,PhoneNumber, Age, Gender, Location, SubscriptionStatus)
SELECT CustomerID,FirstName, LastName,Email,PhoneNumber, Age, Gender, Location, SubscriptionStatus
FROM CustomerData;
--______________________________________________________________________________________________________________________________________________________
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,  
    CustomerID INT,
    ItemPurchased nvarchar(255),
    Category nvarchar(255),
    PurchaseAmount int,
    Size VARCHAR(50),
    Color VARCHAR(50),
    Season VARCHAR(50),
	PaymentMethod VARCHAR(50),
	DateOfPurchase DATETIME,
    DiscountApplied nvarchar(255),
    PromoCodeUsed nvarchar(50),
    ShippingType VARCHAR(50),
	AgentName VARCHAR(50),
    PreviousPurchases tinyint,
    FOREIGN KEY (CustomerID) REFERENCES CustomerInformation(CustomerID)
);
INSERT INTO Transactions (AgentName,TransactionID,CustomerID, ItemPurchased, Category, PurchaseAmount, Size, Color, Season, DiscountApplied, PromoCodeUsed, ShippingType, PreviousPurchases,PaymentMethod, DateOfPurchase)
SELECT  AgentName,TransactionID,CustomerID, ItemPurchased, Category, PurchaseAmount, Size, Color,Season, DiscountApplied, PromoCodeUsed, ShippingType, PreviousPurchases,PaymentMethod,DateOfPurchase
FROM CustomerData;
--______________________________________________________________________________________________________________________________________________________
CREATE TABLE Interactions (
    InteractionID INT PRIMARY KEY,
    CustomerID int,
    ReviewRating float,
    FrequencyOfPurchases varchar(50),
    FOREIGN KEY (CustomerID) REFERENCES CustomerInformation(CustomerID)
);
INSERT INTO Interactions (CustomerID,InteractionID, ReviewRating, FrequencyOfPurchases)
SELECT 
    CustomerID,
	InteractionID,
    ReviewRating,
    CASE 
        WHEN FrequencyOfPurchases = 'Weekly' THEN 52
        WHEN FrequencyOfPurchases = 'Fortnightly' THEN 26
        WHEN FrequencyOfPurchases = 'Monthly' THEN 12  -- Add if applicable
        WHEN FrequencyOfPurchases = 'Quarterly' THEN 4
        WHEN FrequencyOfPurchases = 'Annually' THEN 1
	    WHEN FrequencyOfPurchases = 'Bi-Weekly' THEN 26
		WHEN FrequencyOfPurchases = 'Every 3 Months' THEN 4
        ELSE NULL  -- Handle any unexpected values
    END AS FrequencyOfPurchases
FROM CustomerData
WHERE TRY_CAST(ReviewRating AS INT) BETWEEN 1 AND 5;  -- Ensure ratings are valid
--______________________________________________________________________________________________________________________________________________________
SELECT count(CustomerID) FROM CustomerInformation WHERE Age > 30;
--______________________________________________________________________________________________________________________________________________________
SELECT AVG(PurchaseAmount) AS "Median"
FROM
(
   SELECT PurchaseAmount,
      ROW_NUMBER() OVER (ORDER BY PurchaseAmount ASC, TransactionID ASC) AS RowAsc,
      ROW_NUMBER() OVER (ORDER BY PurchaseAmount DESC, TransactionID DESC) AS RowDesc
   FROM Transactions
) data
WHERE
   RowAsc IN (RowDesc, RowDesc - 1, RowDesc + 1)
--______________________________________________________________________________________________________________________________________________________
WITH CombinedAmounts AS (
    SELECT (PurchaseAmount ) AS TotalAmount,
           ROW_NUMBER() OVER (ORDER BY (PurchaseAmount) ASC, TransactionID ASC) AS RowAsc,
           ROW_NUMBER() OVER (ORDER BY (PurchaseAmount ) DESC, TransactionID DESC) AS RowDesc
    FROM Transactions
    WHERE PurchaseAmount IS NOT NULL AND PreviousPurchases IS NOT NULL  -- Filter out NULL values
)
SELECT 
    CustomerID,
    CASE 
        WHEN SUM(PurchaseAmount)+sum(PreviousPurchases) >(SELECT AVG(PurchaseAmount) AS "Median"
FROM
(
   SELECT PurchaseAmount,
      ROW_NUMBER() OVER (ORDER BY PurchaseAmount ASC, TransactionID ASC) AS RowAsc,
      ROW_NUMBER() OVER (ORDER BY PurchaseAmount DESC, TransactionID DESC) AS RowDesc
   FROM Transactions
) data
WHERE
   RowAsc IN (RowDesc, RowDesc - 1, RowDesc + 1)) THEN 'High-Value Customer'
        ELSE 'Low-Value Customer'
    END AS CustomerSegment
FROM Transactions
GROUP BY CustomerID;
--______________________________________________________________________________________________________________________________________________________
SELECT AVG(PurchaseAmount) AS MeanAmount
FROM Transactions;
--______________________________________________________________________________________________________________________________________________________
SELECT distinct(ItemPurchased)
FROM Transactions
--______________________________________________________________________________________________________________________________________________________
SELECT 
    ItemPurchased, 
    COUNT(*) AS PurchaseCount
FROM Transactions
GROUP BY ItemPurchased
ORDER BY PurchaseCount DESC;
--______________________________________________________________________________________________________________________________________________________
SELECT 
    AgentName, 
    COUNT(*) AS TransactionCount
FROM 
    Transactions
GROUP BY 
    AgentName
ORDER BY 
    TransactionCount DESC; 
--______________________________________________________________________________________________________________________________________________________
