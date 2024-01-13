-- Check if the database 'TaxiManagementSystem' exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'TaxiManagementSystem')
BEGIN
     -- Drop (delete) the database 'TaxiManagementSystem' if it exists
     DROP DATABASE TaxiManagementSystem;
END
GO

-- Use the master database
USE master;
GO

-- Set the TaxiManagementSystem database to single-user mode with immediate rollback
ALTER DATABASE TaxiManagementSystem
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Drop the TaxiManagementSystem database
DROP DATABASE [TaxiManagementSystem];
GO

-- Create a new database named 'TaxiManagementSystem'
CREATE DATABASE TaxiManagementSystem;
GO

-- Switch to the 'TaxiManagementSystem' database
USE TaxiManagementSystem;
GO

-- Switch to the 'sample' database
USE [sample];
GO

-- Drop table statements

-- ServiceRequest Table
DROP TABLE IF EXISTS ServiceRequest;
GO

-- RideRequest Table
DROP TABLE IF EXISTS RideRequest;
GO

-- Trip Estimate Table
DROP TABLE IF EXISTS TripEstimate;
GO

-- Feedback Table
DROP TABLE IF EXISTS Feedback;
GO

-- Driver Table
DROP TABLE IF EXISTS Driver;
GO

-- Customer Table
DROP TABLE IF EXISTS Customer;
GO

-- User Table
DROP TABLE IF EXISTS [User];
GO

-- InsuranceLogs Table
DROP TABLE IF EXISTS InsuranceLogs;
GO

-- Vehicle Table
DROP TABLE IF EXISTS Vehicle;
GO

-- Insurance Table
DROP TABLE IF EXISTS Insurance;
GO

-- Service Table
DROP TABLE IF EXISTS Service;
GO

-- Service Table
CREATE TABLE Service (
    ServiceId INT PRIMARY KEY,          -- Unique identifier for each service
    ServiceCompanyName VARCHAR(50),     -- Name of the company providing the service
    ServiceName VARCHAR(50),            -- Name of the service
    ServiceDetails VARCHAR(255)         -- Additional details or description of the service
);
GO

-- Insurance Table
CREATE TABLE Insurance (
    InsuranceId INT PRIMARY KEY,            -- Unique identifier for each insurance record
    InsuranceProvider VARCHAR(50),          -- Name of the insurance provider
    InsuranceCoverage VARCHAR(255),         -- Details of insurance coverage
    InsurancePremium DECIMAL(10, 2),        -- Cost of the insurance premium (monetary value with two decimal places)
    InsuranceDeductible DECIMAL(10, 2)      -- Deductible amount for the insurance (monetary value with two decimal places)
);
GO

-- Vehicle Table with Table-level CHECK Constraint for InsuranceInfo
CREATE TABLE Vehicle (
    VehicleId INT PRIMARY KEY,              -- Unique identifier for each vehicle
    VehicleType VARCHAR(50),                -- Type or model of the vehicle
    ServiceInfo VARCHAR(255),               -- Information about the vehicle's service history
    InsuranceInfo CHAR(1),                  -- Insurance information (Y for present, N for not present)
    CONSTRAINT CK_InsuranceInfo CHECK (InsuranceInfo IN ('Y', 'N'))  -- Table-level CHECK constraint
);
GO

-- User Table with Table-level CHECK Constraint for UserType
CREATE TABLE [User] (
    UserID INT PRIMARY KEY,                          -- Unique identifier for each user
    UserFName VARCHAR(50) NOT NULL,                  -- User's first name
    UserLName VARCHAR(50) NOT NULL,                  -- User's last name
    PhoneNumber VARCHAR(15) NOT NULL,                -- User's phone number
    EmailId VARCHAR(255) NOT NULL,                   -- User's email address
    DOB DATE,                                        -- User's date of birth
    BankAccInfo VARCHAR(255) NOT NULL,               -- User's bank account information
    UserType CHAR(1) NOT NULL,                        -- Type of user (D for driver, C for customer)
    CONSTRAINT CK_UserType CHECK (UserType IN ('D', 'C'))  -- Table-level CHECK constraint for UserType
);
GO

-- Customer Table
-- This table stores information about customers who use the service.
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,                             -- Unique identifier for each customer
    UserID INT FOREIGN KEY REFERENCES [User](UserID),       -- Foreign key referencing the User table to link with user information
    EncryptedPaymentInfo VARBINARY(MAX)                    -- Encrypted payment information for the customer
);
GO

-- Driver Table
-- This table stores information about drivers who provide services using vehicles.

CREATE TABLE Driver (
    DriverID INT PRIMARY KEY NOT NULL,                               -- Unique identifier for each driver
    UserID INT FOREIGN KEY REFERENCES [User](UserID),                -- Foreign key referencing the User table to link with user information
    VehicleID INT FOREIGN KEY REFERENCES Vehicle(VehicleID),         -- Foreign key referencing the Vehicle table to link with vehicle information
    LicenseInfo VARCHAR(255) NOT NULL,                               -- Driver's license information
);
GO

-- Feedback Table
CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY NOT NULL,                            -- Unique identifier for each feedback record
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerId),     -- Foreign key referencing Customer table
    DriverID INT FOREIGN KEY REFERENCES Driver(DriverID),           -- Foreign key referencing Driver table
    Message VARCHAR(1000) NOT NULL,                                   -- Feedback message
    Rating Float CHECK(Rating BETWEEN 0.0 AND 5.0) DEFAULT 0.0      -- Rating with a check constraint and default value
);
GO

-- Trip Estimate Table
CREATE TABLE TripEstimate (
    EstimationId INT PRIMARY KEY NOT NULL,                          -- Unique identifier for each trip estimate
    VehicleID INT FOREIGN KEY REFERENCES Vehicle(VehicleID),        -- Foreign key referencing Vehicle table
    CurrentTime DATETIME NOT NULL,                                  -- Timestamp of the trip estimate
    Cost DECIMAL(10, 2) NOT NULL                                    -- Estimated cost of the trip
);
GO

-- RideRequest Table with Table-level CHECK Constraint for TripType
CREATE TABLE RideRequest (
    RequestId INT PRIMARY KEY NOT NULL,                                                 -- Unique identifier for each ride request
    EstimationID INT FOREIGN KEY REFERENCES TripEstimate(EstimationId),                 -- Foreign key referencing TripEstimate table
    VehicleID INT FOREIGN KEY REFERENCES Vehicle(VehicleID),                            -- Foreign key referencing Vehicle table
    DriverID INT FOREIGN KEY REFERENCES Driver(DriverID),                               -- Foreign key referencing Driver table
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),                         -- Foreign key referencing Customer table
    RequestType VARCHAR(50) NOT NULL,                                                   -- Type of the ride request
    ReqDateTime DATETIME NOT NULL,                                                      -- Timestamp of the ride request
    PickUpLocationLatitude DECIMAL(10, 6) NOT NULL,                                     -- Latitude of the pickup location
    PickUpLocationLongitude DECIMAL(10, 6) NOT NULL,                                    -- Longitude of the pickup location
    DestinationLocationLatitude DECIMAL(10, 6) NOT NULL,                                -- Latitude of the destination location
    DestinationLocationLongitude DECIMAL(10, 6) NOT NULL,                               -- Longitude of the destination location
    TripType VARCHAR(50) NOT NULL,                                                       -- Type of the trip
    TripCompletionFlag BIT NOT NULL,                                                    -- Flag indicating trip completion status
    PickUpLocation VARCHAR(50) NOT NULL,                                                -- Textual description of the pickup location
    DestinationLocation VARCHAR(50) NOT NULL,                                           -- Textual description of the destination location
    CONSTRAINT CK_TripType CHECK (TripType IN ('City Cab', 'Out Station Cab'))          -- Table-level CHECK constraint for TripType
);
GO

-- ServiceRequest Table
CREATE TABLE ServiceRequest (
    SerReqId INT PRIMARY KEY NOT NULL,                             -- Unique identifier for each service request
    VehicleId INT FOREIGN KEY REFERENCES Vehicle(VehicleID),       -- Foreign key referencing Vehicle table
    ServiceId INT FOREIGN KEY REFERENCES Service(ServiceID),       -- Foreign key referencing Service table
    ReqDateTime DATETIME NOT NULL,                                 -- Timestamp of the service request
    ServiceDueDate DATE NOT NULL,                                  -- Due date for the requested service
    PreviousServiceDate DATE NOT NULL                              -- Date of the previous service for the vehicle
);
GO

-- InsuranceLogs Table
CREATE TABLE InsuranceLogs (
    VehicleID INT FOREIGN KEY REFERENCES Vehicle(VehicleID),            -- Foreign key referencing Vehicle table
    InsuranceId INT FOREIGN KEY REFERENCES Insurance(InsuranceId),      -- Foreign key referencing Insurance table
    InsuranceStartDate DATE NOT NULL,                                   -- Start date of the insurance coverage
    InsuranceEndDate DATE NOT NULL                                      -- End date of the insurance coverage
);
GO

-- Create an AFTER INSERT Trigger (Details to be specified based on use case)
-- This trigger will be executed automatically after an INSERT operation on a specific table.
-- It can be customized to perform specific actions or validations.
-- GO is used to terminate the batch and execute the statements.

-- Example Trigger Structure:
-- CREATE TRIGGER [TriggerName]
-- ON [TableName]
-- AFTER INSERT
-- AS
-- BEGIN
--     -- Trigger Logic Here
-- END;
-- GO

-- Indexes
-- Create an index on RideRequest table for faster retrieval of records based on CustomerID
CREATE INDEX idx_CustomerID ON RideRequest(CustomerID);

-- Create an index on RideRequest table for faster retrieval of records based on DriverID
CREATE INDEX idx_DriverID ON RideRequest(DriverID);

-- Create an index on Feedback table for faster retrieval of records based on DriverID
CREATE INDEX idx_DriverID_Feedback ON Feedback(DriverID);

-- Create an index on ServiceRequest table for faster retrieval of records based on VehicleID
CREATE INDEX idx_VehicleID_ServiceRequest ON ServiceRequest(VehicleID);

-- Create an index on InsuranceLogs table for faster retrieval of records based on InsuranceId
CREATE INDEX idx_InsuranceId_InsuranceLogs ON InsuranceLogs(InsuranceId);

-- Create a Master Key for Encryption
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'AmeySatwe23';

-- Create a Certificate to Protect the Master Key
CREATE CERTIFICATE MyCertificate
   WITH SUBJECT = 'My Column Encryption Certificate';

-- Create a Symmetric Key for Column Encryption
CREATE SYMMETRIC KEY MySymmetricKey
   WITH ALGORITHM = AES_256
   ENCRYPTION BY CERTIFICATE MyCertificate;
GO

-- Create a trigger named EncryptPaymentInfo
CREATE TRIGGER EncryptPaymentInfo
ON Customer
AFTER INSERT
AS
BEGIN
    -- Open the symmetric key for decryption using the specified certificate
    OPEN SYMMETRIC KEY MySymmetricKey DECRYPTION BY CERTIFICATE MyCertificate;

    -- Update the EncryptedPaymentInfo column with encrypted values
    UPDATE Customer
    SET EncryptedPaymentInfo = ENCRYPTBYKEY(KEY_GUID('MySymmetricKey'), i.EncryptedPaymentInfo)
    FROM Customer c
    INNER JOIN inserted i ON c.CustomerID = i.CustomerID;

    -- Close the symmetric key
    CLOSE SYMMETRIC KEY MySymmetricKey;
END;

-- Stored procedure GetDriverStatistics
-- The stored procedure is used to retrieve statistics for a specific driver
CREATE PROCEDURE GetDriverStatistics
    @DriverId INT
AS
BEGIN
    -- Selecting driver details, total trips, average feedback, and latest trip details
    SELECT 
        D.DriverID,                                             -- Driver's unique identifier
        U.UserFName + ' ' + U.UserLName AS DriverName,          -- Concatenating first and last name for a complete name
        COUNT(RR.RequestId) AS TotalTrips,                      -- Count of total trips made by the driver
        AVG(F.Rating) AS AverageFeedbackRating,                 -- Average feedback rating received by the driver (commenting out for now)
        MAX(RR.ReqDateTime) AS LatestTripDateTime,              -- Date and time of the latest trip made by the driver
        MAX(RR.DestinationLocation) AS LatestTripDestination    -- Destination of the latest trip made by the driver
    FROM Driver D
        -- Joining with the User table to get driver's name
        JOIN [User] U ON D.UserID = U.UserID
        -- Left joining with RideRequest to include drivers with no trips
        LEFT JOIN RideRequest RR ON D.DriverID = RR.DriverID
        -- Left joining with Feedback to include drivers with no feedback
        LEFT JOIN Feedback F ON D.DriverID = F.DriverID
    WHERE D.DriverID = @DriverId
    -- Grouping results by driver for aggregate functions
    GROUP BY D.DriverID, U.UserFName, U.UserLName;
END;

-- Execute the GetDriverStatistics stored procedure to retrieve statistics for a specific driver with DriverID = 1
EXEC GetDriverStatistics 1;

-- Stored procedure GetUpcomingServiceRequests
-- The stored procedure is used to retrieve upcoming service requests
CREATE PROCEDURE GetUpcomingServiceRequests
AS
BEGIN
    -- Selecting details for upcoming service requests
    SELECT 
        SR.SerReqId,                                        -- Unique identifier for the service request
        V.VehicleType,                                      -- Type or model of the vehicle
        U.UserFName + ' ' + U.UserLName AS CustomerName,    -- Concatenating first and last name for a complete customer name
        SR.ReqDateTime AS RequestDateTime,                  -- Date and time when the service request was made
        SR.ServiceDueDate AS DueDate,                       -- Due date for the upcoming service
        SR.PreviousServiceDate AS LastServiceDate           -- Date of the previous service for the vehicle
    FROM ServiceRequest SR
        -- Joining with Vehicle table to get vehicle details
        JOIN Vehicle V ON SR.VehicleId = V.VehicleId
        -- Joining with User table to get customer details
        JOIN [User] U ON V.VehicleId = U.UserID
    -- Filtering only upcoming service requests    
    WHERE SR.ServiceDueDate > GETDATE();
END;

-- Execute the GetUpcomingServiceRequests stored procedure to retrieve details for upcoming service requests
EXEC GetUpcomingServiceRequests;

-- Stored procedure spCalculateCustomerLoyaltyDiscount
-- The stored procedure is used to calculate loyalty discount for a customer based on the number of rides in the last year
CREATE PROCEDURE spCalculateCustomerLoyaltyDiscount 
    @CustomerId INT
AS
BEGIN
    -- Declare variables to store the number of rides and the calculated discount percentage
    DECLARE @NumRides INT
    DECLARE @DiscountPercent INT 
    
    -- Count the number of rides for the specified customer in the last year
    SELECT @NumRides = COUNT(*)
    FROM RideRequest r
    INNER JOIN Customer c ON r.CustomerID = c.CustomerID
    WHERE c.CustomerID = @CustomerId
        AND r.ReqDateTime BETWEEN DATEADD(YEAR, -1, GETDATE()) AND GETDATE()
            
    -- Calculate the loyalty discount percentage based on the number of rides
    SET @DiscountPercent = 
        CASE 
            WHEN @NumRides > 10 THEN 20
            WHEN @NumRides BETWEEN 5 AND 10 THEN 10
            ELSE 0
        END
        
    -- Select the customer ID and the calculated loyalty discount percentage
    SELECT @CustomerId AS CustomerId, @DiscountPercent AS LoyaltyDiscountPercentage  
END;

-- Execute the spCalculateCustomerLoyaltyDiscount stored procedure to calculate loyalty discount for a specific customer (CustomerID = 1)
EXEC spCalculateCustomerLoyaltyDiscount 1;

-- Stored procedure DecryptPaymentInfo
-- The stored procedure is used to decrypt payment information for a specific customer
CREATE PROCEDURE DecryptPaymentInfo
    @CustomerID INT   -- Unique identifier for the customer
AS
BEGIN
    -- Open the symmetric key for decryption using the specified certificate
    OPEN SYMMETRIC KEY MySymmetricKey DECRYPTION BY CERTIFICATE MyCertificate;

    -- Select the customer ID and decrypted payment information
    SELECT 
        CustomerID,
        CONVERT(VARCHAR(MAX), DECRYPTBYKEY(EncryptedPaymentInfo)) AS DecryptedPaymentInfo
    FROM 
        Customer
    WHERE 
        CustomerID = @CustomerID;

    -- Close the symmetric key after use
    CLOSE SYMMETRIC KEY MySymmetricKey;
END;

-- Execute the DecryptPaymentInfo stored procedure for CustomerID 1
EXEC DecryptPaymentInfo 1;

-- UDF ServiceDueinDays
-- The user-defined function to calculate the number of days remaining until a service is due
CREATE FUNCTION ServiceDueinDays
(
    @ReqDateTime DATETIME,    -- Date and time of the service request
    @ServiceDueDate DATETIME   -- Due date for the requested service
)
RETURNS INT
AS
BEGIN
    -- Declare a variable to store the number of days remaining
    DECLARE @NoOfDays INT

    -- Calculate the number of days remaining until the service is due
    SET @NoOfDays = DATEDIFF(DAY, @ServiceDueDate, @ReqDateTime)

    -- Return the calculated number of days
    RETURN @NoOfDays;
END;

-- Add a computed column named ServiceDueIn to the ServiceRequest table using UDF
-- The ServiceDueIn column is computed using the dbo.ServiceDueinDays UDF based on ServiceDueDate and ReqDateTime
ALTER TABLE ServiceRequest 
ADD ServiceDueIn AS dbo.ServiceDueinDays(ServiceDueDate, ReqDateTime);

-- UDF CustomerCategory
-- The user-defined function to categorize customers based on their age groups
CREATE FUNCTION CustomerCategory
(
    @USERID INT   -- Date of birth of the customer
)
RETURNS VARCHAR(20)
AS
BEGIN
    -- Declare variables to store the age in years and the customer category
    DECLARE @AgeInYears INT
    DECLARE @Category VARCHAR(20);
    DECLARE @DateOfBirth DATE;

    -- Calculate the age of the customer in years
    SELECT @DateOfBirth = DOB from [User] u join Customer c on u.UserID = @USERID
    SET @AgeInYears = DATEDIFF(YEAR, @DateOfBirth, GETDATE());

    -- Categorize the customer based on age
    SELECT @Category = 
        CASE 
            WHEN @AgeInYears < 18 THEN 'Under 18'
            WHEN @AgeInYears BETWEEN 18 AND 25 THEN 'Young Adult'
            WHEN @AgeInYears BETWEEN 26 AND 40 THEN 'Adult'
            WHEN @AgeInYears BETWEEN 41 AND 60 THEN 'Middle Aged'
            ELSE 'Senior Citizen'
        END;

    -- Return the calculated customer category
    RETURN @Category;
END;

-- Add a computed column named Category to the Customer table using UDF
-- The Category column is computed using the dbo.CustomerCategory UDF based on CustomerID
ALTER TABLE Customer
ADD Category AS dbo.CustomerCategory(CustomerID);

-- View to get CustomerRideHistoryView
CREATE VIEW CustomerRideHistoryView AS
    SELECT
        -- Concatenate the user's first name and last name to form the full name
        users.UserFName + ' ' + users.UserLName AS "Customer Full Name",
        
        -- Count the total number of rides for each customer
        COUNT(trip.Cost) AS "Total Rides",
        
        -- Sum the total cost spent on rides for each customer
        SUM(trip.Cost) AS "Total Ride Spend"
        
        -- AVG(trip.Cost) AS "Average Cost per Ride" -- Commented out as not currently used
    FROM
        -- Join the User table to get customer information
        [User] users
        JOIN Customer cust ON users.UserID = cust.CustomerID
        
        -- Left join to include customers who may not have made any ride requests
        LEFT JOIN RideRequest ride ON cust.CustomerID = ride.CustomerID
        
        -- Join the TripEstimate table to get information about each ride
        JOIN TripEstimate trip ON ride.EstimationID = trip.EstimationId
    WHERE
        -- Filter for completed trips (TripCompletionFlag = 1)
        ride.TripCompletionFlag = 1
    GROUP BY
        -- Group the results by customer full name to aggregate information for each customer
        users.UserFName + ' ' + users.UserLName;

-- Retrieve data from the CustomerRideHistoryView
SELECT *
FROM CustomerRideHistoryView
ORDER BY "Total Ride Spend" DESC;

-- View to get ServiceRequest Details
CREATE VIEW ServiceRequestDetailsView AS
    -- Selecting columns from Vehicle, ServiceRequest, and Service tables
    SELECT
        v.VehicleId,
        v.VehicleType,
        s.ServiceDetails,
        s.ServiceName,
        s.ServiceCompanyName
    FROM
        -- Using RIGHT JOIN to include Vehicle records even if there are no matching ServiceRequest records
        Vehicle v
    RIGHT JOIN ServiceRequest sr ON sr.VehicleId = v.VehicleId
    JOIN [Service] s ON sr.ServiceId = s.ServiceId;

-- Retrieve data from the ServiceRequestDetailsView
SELECT *
FROM ServiceRequestDetailsView;

-- View to get CustomerAndVehicle Details
-- Create a view to combine customer and vehicle information for easy retrieval
CREATE VIEW CustomerAndVehicleView AS
SELECT
    C.CustomerId,                                -- Unique identifier for each customer
    U.UserFName+' '+U.UserLName AS CustomerName, -- Concatenating first and last name for the customer's full name
    V.VehicleId,                                 -- Unique identifier for each vehicle
    V.VehicleType,                               -- Type or model of the vehicle
    V.ServiceInfo AS VehicleServiceInfo          -- Information about the vehicle's service history
FROM
    Customer C
JOIN
    [User] U ON C.UserID = U.UserID              -- Joining with the User table to get customer details
JOIN
    Vehicle V ON C.CustomerId = V.VehicleId;     -- Joining with the Vehicle table to get vehicle details

-- Retrieve data from the CREATE VIEW CustomerAndVehicleView
SELECT *
FROM CustomerAndVehicleView;

-- View to get VehicleRequested Details
-- Create a view to display vehicle statistics, specifically the count of requested vehicles
CREATE VIEW VehicleRequestedView AS
SELECT 
    v.VehicleType,                                -- Type or model of the vehicle
    COUNT(nrr.VehicleID) AS "Count of Vehicle Requested"  -- Count of vehicles requested (completed trips)
FROM 
    Vehicle v
LEFT JOIN 
    (SELECT r.* FROM RideRequest r WHERE r.TripCompletionFlag = 1) nrr 
    ON v.VehicleId = nrr.VehicleID
GROUP BY 
    v.VehicleType;

-- Retrieve data from the CREATE VIEW VehicleRequestedView
SELECT *
FROM VehicleRequestedView;

/* Delete all the data from all the tables */
-- Delete all data from the RideRequest table
DELETE FROM RideRequest;

-- Delete all data from the Feedback table
DELETE FROM Feedback;

-- Delete all data from the Driver table
DELETE FROM Driver;

-- Delete all data from the ServiceRequest table
DELETE FROM ServiceRequest;

-- Delete all data from the InsuranceLogs table
DELETE FROM InsuranceLogs;

-- Delete all data from the TripEstimate table
DELETE FROM TripEstimate;

-- Delete all data from the Customer table
DELETE FROM Customer;

-- Delete all data from the [User] table
DELETE FROM [User];

-- Delete all data from the Vehicle table
DELETE FROM Vehicle;

-- Delete all data from the Insurance table
DELETE FROM Insurance;

-- Delete all data from the Service table
DELETE FROM Service;


/* INSERT STATEMENTS */

-- Inserting Data in Service Table
INSERT INTO Service (ServiceId, ServiceCompanyName, ServiceName, ServiceDetails)
VALUES
    (1, 'ABC Service Company', 'Regular Maintenance', 'Detailed inspection of brake system'),
    (2, 'ABC Service Company', 'Coolant Flush', 'Deep cleaning of the vehicle interior'),
    (3, 'QuickOil', 'Oil Change', 'Fast and efficient oil change service'),
    (4, 'QuickOil', 'Transmission Check', 'Fast and efficient oil change service'),
    (5, 'Sparkle Wash', 'Car Wash', 'Detailed inspection of brake system'),
    (6, 'XYZ Repairs', 'Transmission Check', 'Professional coolant system flushing'),
    (7, 'Brake Master', 'Express Oil Change', 'Fast and efficient oil change service'),
    (8, 'Electro Tune', 'Express Oil Change', 'Exterior and interior cleaning services'),
    (9, 'Coolant Experts', 'Brake Replacement', 'Quick oil change with minimal waiting time'),
    (10, 'QuickOil', 'Coolant Flush', 'Deep cleaning of the vehicle interior'),
    (11, 'Sparkle Wash', 'Regular Maintenance', 'Exterior and interior cleaning services'),
    (12, 'Brake Master', 'Car Wash', 'Quick oil change with minimal waiting time'),
    (13, 'Coolant Experts', 'Car Wash', 'Thorough inspection of transmission components'),
    (14, 'Speedy Repairs', 'Electrical System Check', 'Detailed inspection of brake system'),
    (15, 'Electro Tune', 'Brake Replacement', 'Thorough inspection of transmission components'),
    (16, 'Electro Tune', 'Coolant Flush', 'Detailed inspection of brake system'),
    (17, 'QuickOil', 'Brake Replacement', 'Check and repair electrical components'),
    (18, 'QuickOil', 'Electrical System Check', 'Detailed inspection of brake system'),
    (19, 'Speedy Repairs', 'Car Wash', 'Replacement of worn-out brake components'),
    (20, 'QuickOil', 'Express Oil Change', 'Check and repair electrical components'),
    (21, 'Electro Tune', 'Electrical System Check', 'Replacement of worn-out brake components'),
    (22, 'Express Oil Change', 'Car Wash', 'Check and repair electrical components'),
    (23, 'ABC Service Company', 'Transmission Check', 'Detailed inspection of brake system'),
    (24, 'Electro Tune', 'Express Oil Change', 'Exterior and interior cleaning services'),
    (25, 'Sparkle Wash', 'Coolant Flush', 'Professional coolant system flushing'),
    (26, 'Sunshine Detailing', 'Interior Detailing', 'Thorough inspection of transmission components'),
    (27, 'QuickOil', 'Interior Detailing', 'Scheduled maintenance and inspection'),
    (28, 'Coolant Experts', 'Oil Change', 'Deep cleaning of the vehicle interior'),
    (29, 'XYZ Repairs', 'Transmission Check', 'Professional coolant system flushing'),
    (30, 'Sunshine Detailing', 'Express Oil Change', 'Detailed inspection of brake system'),
    (31, 'Sparkle Wash', 'Interior Detailing', 'Fast and efficient oil change service'),
    (32, 'Coolant Experts', 'Brake Inspection', 'Check and repair electrical components'),
    (33, 'Sunshine Detailing', 'Express Oil Change', 'Replacement of worn-out brake components'),
    (34, 'QuickOil', 'Car Wash', 'Exterior and interior cleaning services'),
    (35, 'Brake Master', 'Express Oil Change', 'Detailed inspection of brake system'),
    (36, 'ABC Service Company', 'Interior Detailing', 'Replacement of worn-out brake components'),
    (37, 'Express Oil Change', 'Brake Inspection', 'Scheduled maintenance and inspection'),
    (38, 'Speedy Repairs', 'Brake Inspection', 'Scheduled maintenance and inspection'),
    (39, 'Express Oil Change', 'Brake Replacement', 'Thorough inspection of transmission components'),
    (40, 'Brake Master', 'Brake Replacement', 'Professional coolant system flushing'),
    (41, 'Speedy Repairs', 'Regular Maintenance', 'Exterior and interior cleaning services'),
    (42, 'Speedy Repairs', 'Car Wash', 'Detailed inspection of brake system'),
    (43, 'XYZ Repairs', 'Interior Detailing', 'Thorough inspection of transmission components'),
    (44, 'Brake Master', 'Transmission Check', 'Thorough inspection of transmission components'),
    (45, 'Sunshine Detailing', 'Brake Inspection', 'Detailed inspection of brake system'),
    (46, 'Sparkle Wash', 'Brake Replacement', 'Fast and efficient oil change service'),
    (47, 'ABC Service Company', 'Transmission Check', 'Deep cleaning of the vehicle interior'),
    (48, 'Speedy Repairs', 'Car Wash', 'Exterior and interior cleaning services'),
    (49, 'Sparkle Wash', 'Express Oil Change', 'Replacement of worn-out brake components'),
    (50, 'XYZ Repairs', 'Express Oil Change', 'Quick oil change with minimal waiting time'),
    (51, 'Electro Tune', 'Electrical System Check', 'Quick oil change with minimal waiting time'),
    (52, 'QuickOil', 'Regular Maintenance', 'Quick oil change with minimal waiting time'),
    (53, 'ABC Service Company', 'Coolant Flush', 'Deep cleaning of the vehicle interior'),
    (54, 'QuickOil', 'Express Oil Change', 'Check and repair electrical components'),
    (55, 'Coolant Experts', 'Brake Replacement', 'Replacement of worn-out brake components'),
    (56, 'Speedy Repairs', 'Interior Detailing', 'Detailed inspection of brake system'),
    (57, 'QuickOil', 'Regular Maintenance', 'Check and repair electrical components'),
    (58, 'XYZ Repairs', 'Express Oil Change', 'Exterior and interior cleaning services'),
    (59, 'Speedy Repairs', 'Oil Change', 'Thorough inspection of transmission components'),
    (60, 'Coolant Experts', 'Electrical System Check', 'Professional coolant system flushing'),
    (61, 'Speedy Repairs', 'Car Wash', 'Fast and efficient oil change service'),
    (62, 'Speedy Repairs', 'Regular Maintenance', 'Scheduled maintenance and inspection'),
    (63, 'ABC Service Company', 'Oil Change', 'Professional coolant system flushing'),
    (64, 'Brake Master', 'Brake Inspection', 'Thorough inspection of transmission components'),
    (65, 'XYZ Repairs', 'Interior Detailing', 'Professional coolant system flushing'),
    (66, 'Coolant Experts', 'Interior Detailing', 'Professional coolant system flushing'),
    (67, 'Coolant Experts', 'Regular Maintenance', 'Exterior and interior cleaning services'),
    (68, 'Brake Master', 'Car Wash', 'Fast and efficient oil change service'),
    (69, 'Electro Tune', 'Electrical System Check', 'Scheduled maintenance and inspection'),
    (70, 'XYZ Repairs', 'Interior Detailing', 'Deep cleaning of the vehicle interior'),
    (71, 'Speedy Repairs', 'Brake Replacement', 'Detailed inspection of brake system'),
    (72, 'Express Oil Change', 'Interior Detailing', 'Scheduled maintenance and inspection'),
    (73, 'XYZ Repairs', 'Oil Change', 'Check and repair electrical components'),
    (74, 'Sparkle Wash', 'Express Oil Change', 'Thorough inspection of transmission components'),
    (75, 'Sunshine Detailing', 'Coolant Flush', 'Deep cleaning of the vehicle interior'),
    (76, 'Express Oil Change', 'Electrical System Check', 'Exterior and interior cleaning services'),
    (77, 'ABC Service Company', 'Electrical System Check', 'Thorough inspection of transmission components'),
    (78, 'ABC Service Company', 'Oil Change', 'Quick oil change with minimal waiting time'),
    (79, 'Sunshine Detailing', 'Oil Change', 'Fast and efficient oil change service'),
    (80, 'Speedy Repairs', 'Express Oil Change', 'Quick oil change with minimal waiting time'),
    (81, 'Sunshine Detailing', 'Electrical System Check', 'Exterior and interior cleaning services'),
    (82, 'Brake Master', 'Transmission Check', 'Detailed inspection of brake system'),
    (83, 'Speedy Repairs', 'Car Wash', 'Quick oil change with minimal waiting time'),
    (84, 'Express Oil Change', 'Electrical System Check', 'Detailed inspection of brake system'),
    (85, 'ABC Service Company', 'Regular Maintenance', 'Replacement of worn-out brake components'),
    (86, 'QuickOil', 'Coolant Flush', 'Thorough inspection of transmission components'),
    (87, 'Express Oil Change', 'Car Wash', 'Check and repair electrical components'),
    (88, 'Sparkle Wash', 'Transmission Check', 'Scheduled maintenance and inspection'),
    (89, 'QuickOil', 'Express Oil Change', 'Exterior and interior cleaning services'),
    (90, 'Sparkle Wash', 'Transmission Check', 'Detailed inspection of brake system'),
    (91, 'Sunshine Detailing', 'Brake Replacement', 'Replacement of worn-out brake components'),
    (92, 'Brake Master', 'Coolant Flush', 'Fast and efficient oil change service'),
    (93, 'XYZ Repairs', 'Car Wash', 'Detailed inspection of brake system'),
    (94, 'Sparkle Wash', 'Coolant Flush', 'Deep cleaning of the vehicle interior'),
    (95, 'Sparkle Wash', 'Car Wash', 'Deep cleaning of the vehicle interior'),
    (96, 'ABC Service Company', 'Express Oil Change', 'Thorough inspection of transmission components'),
    (97, 'ABC Service Company', 'Transmission Check', 'Thorough inspection of transmission components'),
    (98, 'Brake Master', 'Coolant Flush', 'Exterior and interior cleaning services'),
    (99, 'Brake Master', 'Car Wash', 'Fast and efficient oil change service'),
    (100, 'Sparkle Wash', 'Coolant Flush', 'Detailed inspection of brake system');

-- Inserting Data in Insurance Table
INSERT INTO Insurance (InsuranceId, InsuranceProvider, InsuranceCoverage, InsurancePremium, InsuranceDeductible)
VALUES
    (1, 'SureSafety Insurance', 'Comprehensive Coverage', 564, 88),
    (2, 'FastCover Insurance', 'Comprehensive Coverage', 414, 27),
    (3, 'Guardian Insurers', 'Liability Coverage', 906, 67),
    (4, 'XYZ Insurance', 'Full Coverage', 369, 38),
    (5, 'FastCover Insurance', 'Medical Payments Coverage', 457, 29),
    (6, 'Swift Assurance', 'Personal Injury Protection', 915, 100),
    (7, 'Shield Protect', 'Full Coverage', 184, 30),
    (8, 'SureSafety Insurance', 'Rental Car Coverage', 667, 55),
    (9, 'Guardian Insurers', 'Medical Payments Coverage', 329, 19),
    (10, 'SureSafety Insurance', 'Personal Injury Protection', 982, 33),
    (11, 'Guardian Shield', 'Uninsured Motorist Coverage', 432, 41),
    (12, 'SureSafety Insurance', 'Roadside Assistance', 180, 74),
    (13, 'SecureRide Insurance', 'Uninsured Motorist Coverage', 632, 79),
    (14, 'SafeDrive Assurance', 'Comprehensive Coverage', 209, 20),
    (15, 'SafeDrive Assurance', 'Rental Car Coverage', 797, 55),
    (16, 'SafeDrive Assurance', 'Full Coverage', 857, 70),
    (17, 'SecureRide Insurance', 'Underinsured Motorist Coverage', 190, 17),
    (18, 'Shield Protect', 'Full Coverage', 908, 17),
    (19, 'SecureRide Insurance', 'Full Coverage', 773, 71),
    (20, 'TotalProtect Insurers', 'Personal Injury Protection', 945, 21),
    (21, 'Swift Assurance', 'Underinsured Motorist Coverage', 827, 24),
    (22, 'Guardian Shield', 'Underinsured Motorist Coverage', 349, 26),
    (23, 'SureSafety Insurance', 'Uninsured Motorist Coverage', 805, 57),
    (24, 'Guardian Insurers', 'Collision Coverage', 503, 15),
    (25, 'SafeDrive Assurance', 'Liability Coverage', 870, 26),
    (26, 'SafeDrive Assurance', 'Collision Coverage', 736, 33),
    (27, 'SecureRide Insurance', 'Full Coverage', 956, 81),
    (28, 'Swift Assurance', 'Roadside Assistance', 144, 10),
    (29, 'SafeDrive Assurance', 'Rental Car Coverage', 853, 100),
    (30, 'TotalProtect Insurers', 'Uninsured Motorist Coverage', 554, 46),
    (31, 'Guardian Insurers', 'Rental Car Coverage', 345, 78),
    (32, 'XYZ Insurance', 'Underinsured Motorist Coverage', 395, 13),
    (33, 'SafeDrive Assurance', 'Comprehensive Coverage', 552, 11),
    (34, 'SureSafety Insurance', 'Underinsured Motorist Coverage', 454, 92),
    (35, 'Shield Protect', 'Full Coverage', 401, 25),
    (36, 'FastCover Insurance', 'Underinsured Motorist Coverage', 559, 13),
    (37, 'Guardian Insurers', 'Comprehensive Coverage', 624, 31),
    (38, 'TotalProtect Insurers', 'Liability Coverage', 617, 38),
    (39, 'Guardian Insurers', 'Liability Coverage', 935, 55),
    (40, 'Guardian Insurers', 'Rental Car Coverage', 833, 64),
    (41, 'TotalProtect Insurers', 'Rental Car Coverage', 906, 13),
    (42, 'XYZ Insurance', 'Uninsured Motorist Coverage', 577, 18),
    (43, 'XYZ Insurance', 'Full Coverage', 219, 21),
    (44, 'Guardian Shield', 'Underinsured Motorist Coverage', 242, 16),
    (45, 'FastCover Insurance', 'Roadside Assistance', 918, 80),
    (46, 'Shield Protect', 'Rental Car Coverage', 447, 84),
    (47, 'SafeDrive Assurance', 'Underinsured Motorist Coverage', 874, 71),
    (48, 'Shield Protect', 'Medical Payments Coverage', 280, 14),
    (49, 'XYZ Insurance', 'Collision Coverage', 405, 70),
    (50, 'SafeDrive Assurance', 'Underinsured Motorist Coverage', 396, 81),
    (51, 'XYZ Insurance', 'Rental Car Coverage', 627, 86),
    (52, 'FastCover Insurance', 'Liability Coverage', 290, 21),
    (53, 'SafeDrive Assurance', 'Full Coverage', 385, 38),
    (54, 'XYZ Insurance', 'Full Coverage', 357, 34),
    (55, 'SureSafety Insurance', 'Uninsured Motorist Coverage', 196, 54),
    (56, 'Guardian Insurers', 'Collision Coverage', 538, 33),
    (57, 'Guardian Shield', 'Liability Coverage', 302, 94),
    (58, 'Guardian Shield', 'Rental Car Coverage', 353, 47),
    (59, 'Guardian Shield', 'Liability Coverage', 342, 69),
    (60, 'Guardian Shield', 'Comprehensive Coverage', 705, 80),
    (61, 'SureSafety Insurance', 'Personal Injury Protection', 240, 93),
    (62, 'TotalProtect Insurers', 'Uninsured Motorist Coverage', 242, 14),
    (63, 'XYZ Insurance', 'Comprehensive Coverage', 874, 65),
    (64, 'Swift Assurance', 'Full Coverage', 945, 26),
    (65, 'Swift Assurance', 'Collision Coverage', 781, 98),
    (66, 'Swift Assurance', 'Rental Car Coverage', 457, 38),
    (67, 'Shield Protect', 'Medical Payments Coverage', 568, 39),
    (68, 'Guardian Shield', 'Roadside Assistance', 763, 47),
    (69, 'Guardian Insurers', 'Personal Injury Protection', 250, 36),
    (70, 'SafeDrive Assurance', 'Full Coverage', 758, 85),
    (71, 'TotalProtect Insurers', 'Liability Coverage', 474, 49),
    (72, 'XYZ Insurance', 'Full Coverage', 465, 13),
    (73, 'Shield Protect', 'Liability Coverage', 542, 93),
    (74, 'XYZ Insurance', 'Full Coverage', 235, 61),
    (75, 'SafeDrive Assurance', 'Liability Coverage', 814, 98),
    (76, 'Swift Assurance', 'Underinsured Motorist Coverage', 724, 27),
    (77, 'Guardian Insurers', 'Roadside Assistance', 505, 37),
    (78, 'TotalProtect Insurers', 'Liability Coverage', 629, 24),
    (79, 'SureSafety Insurance', 'Rental Car Coverage', 693, 64),
    (80, 'SureSafety Insurance', 'Rental Car Coverage', 667, 72),
    (81, 'Guardian Insurers', 'Roadside Assistance', 317, 45),
    (82, 'SureSafety Insurance', 'Personal Injury Protection', 548, 80),
    (83, 'FastCover Insurance', 'Roadside Assistance', 977, 30),
    (84, 'FastCover Insurance', 'Collision Coverage', 539, 55),
    (85, 'Shield Protect', 'Rental Car Coverage', 470, 69),
    (86, 'SureSafety Insurance', 'Full Coverage', 207, 84),
    (87, 'Shield Protect', 'Comprehensive Coverage', 684, 15),
    (88, 'XYZ Insurance', 'Medical Payments Coverage', 360, 24),
    (89, 'Swift Assurance', 'Medical Payments Coverage', 899, 53),
    (90, 'Guardian Shield', 'Medical Payments Coverage', 807, 27),
    (91, 'SecureRide Insurance', 'Uninsured Motorist Coverage', 529, 66),
    (92, 'Shield Protect', 'Collision Coverage', 480, 21),
    (93, 'SecureRide Insurance', 'Personal Injury Protection', 743, 72),
    (94, 'Guardian Shield', 'Uninsured Motorist Coverage', 665, 20),
    (95, 'Swift Assurance', 'Underinsured Motorist Coverage', 201, 21),
    (96, 'SureSafety Insurance', 'Roadside Assistance', 803, 48),
    (97, 'SecureRide Insurance', 'Uninsured Motorist Coverage', 734, 60),
    (98, 'SafeDrive Assurance', 'Underinsured Motorist Coverage', 980, 54),
    (99, 'SecureRide Insurance', 'Underinsured Motorist Coverage', 677, 53),
    (100, 'FastCover Insurance', 'Personal Injury Protection', 202, 35);

-- Inserting Data in Vehicle Table
INSERT INTO Vehicle (VehicleId, VehicleType, ServiceInfo, InsuranceInfo)
VALUES
    (1, 'Sedan', 'Monthly check-ups', 'Y'),
    (2, 'Minivan', 'Fuel-efficient model', 'N'),
    (3, 'Compact', 'Regularly serviced', 'N'),
    (4, 'Truck', 'Family-friendly model', 'N'),
    (5, 'Electric Car', 'Monthly check-ups', 'N'),
    (6, 'Sedan', 'Luxury vehicle maintenance', 'N'),
    (7, 'SUV', 'Heavy-duty maintenance', 'Y'),
    (8, 'Motorcycle', 'Luxury vehicle maintenance', 'Y'),
    (9, 'Compact', 'Family-friendly model', 'Y'),
    (10, 'Electric Car', 'Heavy-duty maintenance', 'N'),
    (11, 'Electric Car', 'Fuel-efficient model', 'Y'),
    (12, 'SUV', 'Specialized care', 'N'),
    (13, 'Electric Car', 'Heavy-duty maintenance', 'N'),
    (14, 'Convertible', 'Fuel-efficient model', 'N'),
    (15, 'Limousine', 'Battery system inspection', 'N'),
    (16, 'Electric Car', 'Fuel-efficient model', 'N'),
    (17, 'Sedan', 'Battery system inspection', 'N'),
    (18, 'Electric Car', 'Fuel-efficient model', 'Y'),
    (19, 'Motorcycle', 'Heavy-duty maintenance', 'N'),
    (20, 'Convertible', 'Specialized care', 'N'),
    (21, 'Truck', 'Battery system inspection', 'Y'),
    (22, 'Electric Car', 'Specialized care', 'Y'),
    (23, 'Hatchback', 'Battery system inspection', 'Y'),
    (24, 'Compact', 'Luxury vehicle maintenance', 'N'),
    (25, 'Limousine', 'Regularly serviced', 'N'),
    (26, 'SUV', 'Fuel-efficient model', 'Y'),
    (27, 'Minivan', 'Heavy-duty maintenance', 'Y'),
    (28, 'Minivan', 'Battery system inspection', 'Y'),
    (29, 'Sedan', 'Regularly serviced', 'Y'),
    (30, 'Compact', 'Specialized care', 'N'),
    (31, 'Motorcycle', 'Specialized care', 'Y'),
    (32, 'Electric Car', 'Regularly serviced', 'Y'),
    (33, 'Motorcycle', 'Specialized care', 'N'),
    (34, 'Compact', 'Battery system inspection', 'N'),
    (35, 'SUV', 'Heavy-duty maintenance', 'Y'),
    (36, 'Compact', 'Luxury vehicle maintenance', 'Y'),
    (37, 'Sedan', 'Family-friendly model', 'N'),
    (38, 'Sedan', 'Monthly check-ups', 'Y'),
    (39, 'Limousine', 'Monthly check-ups', 'Y'),
    (40, 'Hatchback', 'Battery system inspection', 'N'),
    (41, 'SUV', 'Regularly serviced', 'Y'),
    (42, 'Sedan', 'Monthly check-ups', 'N'),
    (43, 'Compact', 'Heavy-duty maintenance', 'Y'),
    (44, 'Limousine', 'Monthly check-ups', 'Y'),
    (45, 'Compact', 'Specialized care', 'N'),
    (46, 'Convertible', 'Specialized care', 'N'),
    (47, 'Sedan', 'Heavy-duty maintenance', 'N'),
    (48, 'Motorcycle', 'Specialized care', 'N'),
    (49, 'SUV', 'Monthly check-ups', 'Y'),
    (50, 'SUV', 'Heavy-duty maintenance', 'Y'),
    (51, 'Motorcycle', 'Specialized care', 'Y'),
    (52, 'Motorcycle', 'Bi-annual check-ups', 'N'),
    (53, 'Electric Car', 'Luxury vehicle maintenance', 'Y'),
    (54, 'Minivan', 'Bi-annual check-ups', 'Y'),
    (55, 'SUV', 'Monthly check-ups', 'N'),
    (56, 'Minivan', 'Heavy-duty maintenance', 'N'),
    (57, 'Hatchback', 'Specialized care', 'N'),
    (58, 'Limousine', 'Monthly check-ups', 'N'),
    (59, 'Truck', 'Monthly check-ups', 'Y'),
    (60, 'Hatchback', 'Monthly check-ups', 'Y'),
    (61, 'Electric Car', 'Monthly check-ups', 'N'),
    (62, 'SUV', 'Specialized care', 'Y'),
    (63, 'Hatchback', 'Heavy-duty maintenance', 'Y'),
    (64, 'Truck', 'Bi-annual check-ups', 'N'),
    (65, 'Sedan', 'Specialized care', 'N'),
    (66, 'Electric Car', 'Battery system inspection', 'N'),
    (67, 'Sedan', 'Bi-annual check-ups', 'N'),
    (68, 'Compact', 'Battery system inspection', 'N'),
    (69, 'Minivan', 'Battery system inspection', 'Y'),
    (70, 'Convertible', 'Heavy-duty maintenance', 'N'),
    (71, 'Truck', 'Fuel-efficient model', 'N'),
    (72, 'Minivan', 'Heavy-duty maintenance', 'Y'),
    (73, 'SUV', 'Regularly serviced', 'N'),
    (74, 'Convertible', 'Monthly check-ups', 'N'),
    (75, 'Sedan', 'Bi-annual check-ups', 'N'),
    (76, 'Sedan', 'Specialized care', 'Y'),
    (77, 'Convertible', 'Bi-annual check-ups', 'Y'),
    (78, 'Limousine', 'Family-friendly model', 'N'),
    (79, 'Compact', 'Regularly serviced', 'N'),
    (80, 'Sedan', 'Battery system inspection', 'Y'),
    (81, 'Sedan', 'Bi-annual check-ups', 'N'),
    (82, 'SUV', 'Family-friendly model', 'N'),
    (83, 'Compact', 'Specialized care', 'Y'),
    (84, 'Convertible', 'Regularly serviced', 'Y'),
    (85, 'Compact', 'Luxury vehicle maintenance', 'N'),
    (86, 'Electric Car', 'Specialized care', 'Y'),
    (87, 'Sedan', 'Family-friendly model', 'N'),
    (88, 'Minivan', 'Luxury vehicle maintenance', 'Y'),
    (89, 'Compact', 'Luxury vehicle maintenance', 'N'),
    (90, 'Compact', 'Specialized care', 'Y'),
    (91, 'SUV', 'Specialized care', 'Y'),
    (92, 'Hatchback', 'Fuel-efficient model', 'N'),
    (93, 'Minivan', 'Specialized care', 'N'),
    (94, 'Motorcycle', 'Fuel-efficient model', 'N'),
    (95, 'Electric Car', 'Regularly serviced', 'Y'),
    (96, 'Minivan', 'Battery system inspection', 'N'),
    (97, 'Limousine', 'Luxury vehicle maintenance', 'Y'),
    (98, 'Limousine', 'Family-friendly model', 'Y'),
    (99, 'Electric Car', 'Specialized care', 'N'),
    (100, 'Compact', 'Specialized care', 'N');

-- Inserting Data in [User] Table
INSERT INTO [User] (UserID, UserFName, UserLName, PhoneNumber, EmailId, DOB, BankAccInfo, UserType)
VALUES
    (1, 'Tiena', 'Welsby', '291-574-9014', 'twelsby0@squarespace.com', '4/11/2002', 'Bank IIII-2345-6789', 'C'),
    (2, 'Israel', 'Hearle', '802-803-0969', 'ihearle1@amazonaws.com', null, 'Bank ABCD-1234-5678', 'C'),
    (3, 'Teena', 'Fearon', '579-120-7519', 'tfearon2@wikia.com', null, 'Bank ZZZZ-ZZZZ-ZZZZ', 'C'),
    (4, 'Maurice', 'Raleston', '619-829-2038', 'mraleston3@usnews.com', '11/7/2004', 'Bank HHHH-3456-7890', 'C'),
    (5, 'Hyacintha', 'Randales', '809-365-4942', 'hrandales4@prweb.com', '10/13/2003', 'Bank GGGG-9876-5432', 'C'),
    (6, 'Freeman', 'Cohr', '892-938-6681', 'fcohr5@w3.org', '7/28/2010', 'Bank IIII-2345-6789', 'C'),
    (7, 'Gusti', 'Grayland', '687-806-4295', 'ggrayland6@narod.ru', '8/17/2019', 'Bank ZZZZ-ZZZZ-ZZZZ', 'D'),
    (8, 'Quill', 'MacFaul', '808-112-9658', 'qmacfaul7@theatlantic.com', '4/18/2014', 'Bank FFFF-1234-5678', 'D'),
    (9, 'Arly', 'Shiel', '527-620-4570', 'ashiel8@reuters.com', '8/4/2016', 'Bank IIII-2345-6789', 'D'),
    (10, 'Merrill', 'Farnan', '744-107-7542', 'mfarnan9@hexun.com', '9/12/2001', 'Bank WXYZ-5678-9012', 'C'),
    (11, 'Maurise', 'Perris', '755-569-1032', 'mperrisa@usatoday.com', null, 'Bank FFFF-1234-5678', 'D'),
    (12, 'Bart', 'Lantaph', '949-948-4414', 'blantaphb@nymag.com', '7/28/2023', 'Bank YYYY-YYYY-YYYY', 'D'),
    (13, 'Dean', 'Cornu', '964-243-9215', 'dcornuc@springer.com', '6/9/2013', 'Bank ZZZZ-ZZZZ-ZZZZ', 'D'),
    (14, 'El', 'Priestnall', '838-864-6639', 'epriestnalld@icio.us', '1/1/2012', 'Bank XXXX-XXXX-XXXX', 'D'),
    (15, 'Humbert', 'Korpolak', '234-465-9584', 'hkorpolake@unc.edu', null, 'Bank HHHH-3456-7890', 'D'),
    (16, 'Elsbeth', 'Iscowitz', '572-811-4729', 'eiscowitzf@sbwire.com', '5/1/2002', 'Bank IIII-2345-6789', 'C'),
    (17, 'Shanda', 'Keers', '138-828-7778', 'skeersg@etsy.com', '6/9/2002', 'Bank IIII-2345-6789', 'C'),
    (18, 'Percy', 'Windeatt', '137-971-0698', 'pwindeatth@tamu.edu', '7/6/2002', 'Bank EEEE-5678-9012', 'C'),
    (19, 'Alaric', 'Sleite', '462-508-0135', 'asleitei@scientificamerican.com', '7/18/2021', 'Bank ABCD-1234-5678', 'D'),
    (20, 'Cherida', 'Main', '999-499-1553', 'cmainj@usda.gov', '10/10/2001', 'Bank WXYZ-5678-9012', 'D'),
    (21, 'Andrey', 'Wincer', '666-442-2393', 'awincerk@mtv.com', '9/26/2016', 'Bank EEEE-5678-9012', 'C'),
    (22, 'Terese', 'Kinlock', '751-294-9403', 'tkinlockl@moonfruit.com', '12/24/2011', 'Bank HHHH-3456-7890', 'C'),
    (23, 'Baxter', 'Scraney', '235-245-5594', 'bscraneym@ca.gov', '7/6/2001', 'Bank EEEE-5678-9012', 'D'),
    (24, 'Gracie', 'Adderley', '852-641-7945', 'gadderleyn@mozilla.com', '6/17/2001', 'Bank FFFF-1234-5678', 'C'),
    (25, 'Katharyn', 'Graeber', '147-844-1930', 'kgraebero@dagondesign.com', '3/10/2019', 'Bank YYYY-YYYY-YYYY', 'C'),
    (26, 'Ozzy', 'Heazel', '389-770-2370', 'oheazelp@cdc.gov', '3/27/2000', 'Bank IIII-2345-6789', 'C'),
    (27, 'Morgan', 'McLemon', '700-268-1063', 'mmclemonq@php.net', '3/9/2001', 'Bank ABCD-1234-5678', 'C'),
    (28, 'Scottie', 'Packer', '225-144-0632', 'spackerr@wired.com', '1/3/2011', 'Bank ABCD-1234-5678', 'C'),
    (29, 'Shelley', 'Bartlomiej', '852-742-4446', 'sbartlomiejs@newyorker.com', '5/4/2005', 'Bank GGGG-9876-5432', 'C'),
    (30, 'Johna', 'Capineer', '529-998-7297', 'jcapineert@sakura.ne.jp', '6/24/2009', 'Bank YYYY-YYYY-YYYY', 'D'),
    (31, 'Dalton', 'Browell', '591-181-4096', 'dbrowellu@accuweather.com', '11/15/2006', 'Bank HHHH-3456-7890', 'D'),
    (32, 'Jordan', 'Heyfield', '320-283-8440', 'jheyfieldv@netvibes.com', null, 'Bank HHHH-3456-7890', 'C'),
    (33, 'Denys', 'Rickeard', '686-205-1361', 'drickeardw@geocities.com', '9/13/2015', 'Bank ZZZZ-ZZZZ-ZZZZ', 'D'),
    (34, 'Cherie', 'Tooke', '986-667-7172', 'ctookex@meetup.com', '3/19/2019', 'Bank ZZZZ-ZZZZ-ZZZZ', 'D'),
    (35, 'Allyn', 'Darke', '304-492-8643', 'adarkey@deviantart.com', null, 'Bank IIII-2345-6789', 'D'),
    (36, 'Emmi', 'Teague', '371-429-2048', 'eteaguez@google.co.uk', '8/16/2022', 'Bank EEEE-5678-9012', 'C'),
    (37, 'Reina', 'Wikey', '771-328-2298', 'rwikey10@cornell.edu', '2/22/2017', 'Bank WXYZ-5678-9012', 'C'),
    (38, 'Augustine', 'Lawfull', '517-745-9657', 'alawfull11@forbes.com', null, 'Bank FFFF-1234-5678', 'C'),
    (39, 'Devland', 'Keri', '319-875-3598', 'dkeri12@ucsd.edu', '10/2/2019', 'Bank WXYZ-5678-9012', 'D'),
    (40, 'Ashlen', 'Strangeways', '939-779-5915', 'astrangeways13@home.pl', '1/14/2009', 'Bank WXYZ-5678-9012', 'D'),
    (41, 'Maurice', 'Selwyne', '792-862-2941', 'mselwyne14@samsung.com', null, 'Bank YYYY-YYYY-YYYY', 'D'),
    (42, 'Cherlyn', 'Rhodus', '143-128-7428', 'crhodus15@netlog.com', '3/16/2002', 'Bank YYYY-YYYY-YYYY', 'C'),
    (43, 'Armin', 'Danelutti', '442-695-7986', 'adanelutti16@jiathis.com', null, 'Bank ABCD-1234-5678', 'C'),
    (44, 'Cchaddie', 'Mahoney', '543-770-9406', 'cmahoney17@businesswire.com', null, 'Bank HHHH-3456-7890', 'C'),
    (45, 'Lanita', 'Cadwaladr', '272-947-0288', 'lcadwaladr18@netscape.com', '1/2/2002', 'Bank ZZZZ-ZZZZ-ZZZZ', 'C'),
    (46, 'Luella', 'Flasby', '887-552-5850', 'lflasby19@ehow.com', '5/7/2020', 'Bank WXYZ-5678-9012', 'D'),
    (47, 'Nolly', 'Saby', '788-460-8432', 'nsaby1a@blinklist.com', null, 'Bank GGGG-9876-5432', 'C'),
    (48, 'Janet', 'Alfonsini', '333-128-3151', 'jalfonsini1b@rambler.ru', '2/8/2019', 'Bank WXYZ-5678-9012', 'D'),
    (49, 'Crawford', 'Lambourne', '336-548-8259', 'clambourne1c@51.la', '5/17/2014', 'Bank XXXX-XXXX-XXXX', 'D'),
    (50, 'Tabbie', 'Hacker', '609-257-3328', 'thacker1d@google.co.jp', '3/18/2003', 'Bank WXYZ-5678-9012', 'C'),
    (51, 'Mireielle', 'Bulger', '293-155-4331', 'mbulger1e@weather.com', '12/30/2015', 'Bank XXXX-XXXX-XXXX', 'D'),
    (52, 'Verna', 'Gray', '902-575-9719', 'vgray1f@cisco.com', null, 'Bank GGGG-9876-5432', 'D'),
    (53, 'Dayna', 'Showl', '547-994-8695', 'dshowl1g@taobao.com', '11/15/2001', 'Bank GGGG-9876-5432', 'C'),
    (54, 'Garvey', 'Alexsandrov', '725-629-2606', 'galexsandrov1h@nytimes.com', '5/23/2000', 'Bank GGGG-9876-5432', 'D'),
    (55, 'Nevins', 'Bartlet', '477-746-0912', 'nbartlet1i@ibm.com', '10/6/2007', 'Bank FFFF-1234-5678', 'D'),
    (56, 'Edlin', 'Berringer', '554-923-6928', 'eberringer1j@cdc.gov', '4/1/2003', 'Bank YYYY-YYYY-YYYY', 'C'),
    (57, 'Gherardo', 'Ferrario', '864-834-0958', 'gferrario1k@prnewswire.com', '8/29/2002', 'Bank XXXX-XXXX-XXXX', 'D'),
    (58, 'Audi', 'Paschke', '855-989-2418', 'apaschke1l@surveymonkey.com', '7/5/2002', 'Bank IIII-2345-6789', 'D'),
    (59, 'Rickie', 'Benini', '760-698-5796', 'rbenini1m@ovh.net', '4/11/2009', 'Bank FFFF-1234-5678', 'D'),
    (60, 'Peyter', 'Opy', '931-448-4271', 'popy1n@pinterest.com', '5/28/2000', 'Bank EEEE-5678-9012', 'D'),
    (61, 'Roarke', 'Buggs', '768-976-8725', 'rbuggs1o@go.com', '7/17/2023', 'Bank IIII-2345-6789', 'C'),
    (62, 'Calhoun', 'Levins', '924-479-7474', 'clevins1p@umn.edu', '2/20/2018', 'Bank ABCD-1234-5678', 'D'),
    (63, 'Tiff', 'Lerohan', '404-182-2905', 'tlerohan1q@hhs.gov', '1/23/2005', 'Bank ZZZZ-ZZZZ-ZZZZ', 'D'),
    (64, 'Miquela', 'Berzin', '497-978-2308', 'mberzin1r@pen.io', '4/18/2010', 'Bank HHHH-3456-7890', 'D'),
    (65, 'Chrisse', 'Newbury', '894-369-8661', 'cnewbury1s@kickstarter.com', '8/9/2015', 'Bank WXYZ-5678-9012', 'D'),
    (66, 'Myrwyn', 'Fullard', '663-822-1936', 'mfullard1t@51.la', null, 'Bank YYYY-YYYY-YYYY', 'C'),
    (67, 'Pauletta', 'Salt', '758-273-8133', 'psalt1u@topsy.com', null, 'Bank WXYZ-5678-9012', 'D'),
    (68, 'Chet', 'Giggie', '153-160-1940', 'cgiggie1v@slashdot.org', '9/27/2023', 'Bank EEEE-5678-9012', 'C'),
    (69, 'Cordelie', 'Kenan', '417-238-9168', 'ckenan1w@parallels.com', '3/13/2020', 'Bank EEEE-5678-9012', 'C'),
    (70, 'Culley', 'Dann', '212-331-8509', 'cdann1x@biglobe.ne.jp', '8/2/2021', 'Bank XXXX-XXXX-XXXX', 'D'),
    (71, 'Rube', 'Jiggins', '996-423-1436', 'rjiggins1y@nasa.gov', '1/22/2020', 'Bank FFFF-1234-5678', 'C'),
    (72, 'Nikolia', 'Corradino', '720-435-8749', 'ncorradino1z@youtube.com', null, 'Bank ABCD-1234-5678', 'D'),
    (73, 'Judon', 'Bengtson', '502-184-8417', 'jbengtson20@tinypic.com', '4/12/2011', 'Bank EEEE-5678-9012', 'C'),
    (74, 'Sacha', 'Spybey', '841-386-8455', 'sspybey21@nature.com', null, 'Bank IIII-2345-6789', 'C'),
    (75, 'Hilarius', 'Caught', '937-247-5221', 'hcaught22@techcrunch.com', '3/2/2010', 'Bank GGGG-9876-5432', 'C'),
    (76, 'Stacey', 'Baseley', '849-178-0908', 'sbaseley23@marketwatch.com', null, 'Bank EEEE-5678-9012', 'C'),
    (77, 'Benjamin', 'Artis', '590-843-0518', 'bartis24@imdb.com', '5/6/2021', 'Bank ABCD-1234-5678', 'C'),
    (78, 'Julius', 'Stain', '596-687-9435', 'jstain25@ca.gov', '7/13/2014', 'Bank FFFF-1234-5678', 'C'),
    (79, 'Jemimah', 'O'' Kelleher', '857-113-4875', 'jokelleher26@kickstarter.com', '2/15/2022', 'Bank EEEE-5678-9012', 'D'),
    (80, 'Flinn', 'Shovell', '719-913-1879', 'fshovell27@princeton.edu', '7/14/2018', 'Bank YYYY-YYYY-YYYY', 'C'),
    (81, 'Tonie', 'Tolmie', '445-935-5631', 'ttolmie28@patch.com', '11/3/2008', 'Bank ABCD-1234-5678', 'D'),
    (82, 'Collin', 'Dungate', '207-443-3302', 'cdungate29@rakuten.co.jp', '10/27/2013', 'Bank HHHH-3456-7890', 'D'),
    (83, 'Kiah', 'Vinton', '986-234-6332', 'kvinton2a@elegantthemes.com', null, 'Bank XXXX-XXXX-XXXX', 'C'),
    (84, 'Art', 'Shah', '707-459-0250', 'ashah2b@dmoz.org', '11/25/2001', 'Bank WXYZ-5678-9012', 'C'),
    (85, 'Jerrie', 'Cathery', '814-201-6603', 'jcathery2c@smh.com.au', null, 'Bank ZZZZ-ZZZZ-ZZZZ', 'D'),
    (86, 'Kendrick', 'Gersam', '556-544-4305', 'kgersam2d@trellian.com', '5/6/2023', 'Bank ZZZZ-ZZZZ-ZZZZ', 'C'),
    (87, 'Jacquenette', 'Dutnell', '335-887-9208', 'jdutnell2e@tripod.com', '7/31/2006', 'Bank HHHH-3456-7890', 'D'),
    (88, 'Lind', 'Hallmark', '302-821-0544', 'lhallmark2f@netscape.com', '8/5/2001', 'Bank FFFF-1234-5678', 'D'),
    (89, 'Tadeo', 'Kellogg', '353-601-5844', 'tkellogg2g@ca.gov', '6/15/2010', 'Bank FFFF-1234-5678', 'D'),
    (90, 'Leontine', 'Derry', '454-700-9407', 'lderry2h@independent.co.uk', null, 'Bank GGGG-9876-5432', 'C'),
    (91, 'Merna', 'Possel', '774-392-3639', 'mpossel2i@ftc.gov', '1/27/2017', 'Bank HHHH-3456-7890', 'C'),
    (92, 'Dionisio', 'Honeyghan', '820-895-0939', 'dhoneyghan2j@merriam-webster.com', null, 'Bank YYYY-YYYY-YYYY', 'C'),
    (93, 'Candy', 'Hegarty', '881-839-0961', 'chegarty2k@github.com', '5/30/2001', 'Bank EEEE-5678-9012', 'D'),
    (94, 'Melantha', 'Castellet', '482-116-1110', 'mcastellet2l@berkeley.edu', '1/15/2011', 'Bank IIII-2345-6789', 'C'),
    (95, 'Kim', 'Harbord', '373-988-4108', 'kharbord2m@omniture.com', '5/3/2013', 'Bank WXYZ-5678-9012', 'D'),
    (96, 'Sorcha', 'Ilott', '689-137-5669', 'silott2n@chronoengine.com', '1/20/2002', 'Bank WXYZ-5678-9012', 'D'),
    (97, 'Sumner', 'Rounce', '852-753-2362', 'srounce2o@trellian.com', '8/10/2005', 'Bank IIII-2345-6789', 'D'),
    (98, 'Harris', 'Budding', '667-963-5828', 'hbudding2p@fda.gov', '11/17/2001', 'Bank WXYZ-5678-9012', 'D'),
    (99, 'Loretta', 'Dabling', '941-149-4691', 'ldabling2q@artisteer.com', '8/25/2002', 'Bank HHHH-3456-7890', 'D'),
    (100, 'Babbette', 'Arnault', '482-271-5817', 'barnault2r@state.gov', '3/20/2022', 'Bank WXYZ-5678-9012', 'D');

-- Inserting Data in Customer Table
INSERT INTO Customer (CustomerId, UserID, EncryptedPaymentInfo)
VALUES
    (1, 86,CONVERT(varbinary(MAX), 'Credit Card - XXXX-XXXX-XXXX-XXXX')),
    (2, 20,CONVERT(varbinary(MAX), 'PayPal - user@example.com')),
    (3, 54,CONVERT(varbinary(MAX), 'Debit Card - YYYY-YYYY-YYYY-YYYY')),
    (4, 33,CONVERT(varbinary(MAX), 'Bank Transfer - Account: XXXXXXXX')),
    (5, 86,CONVERT(varbinary(MAX), 'Routing: YYYYYYYY')),
    (6, 14,CONVERT(varbinary(MAX), 'Cash on Delivery')),
    (7, 1,CONVERT(varbinary(MAX), 'Credit Card - ZZZZ-ZZZZ-ZZZZ-ZZZZ')),
    (8, 14,CONVERT(varbinary(MAX), 'Debit Card - KKKK-KKKK-KKKK-KKKK')),
    (9, 3,CONVERT(varbinary(MAX), 'PayPal - user2@example.com')),
    (10, 65,CONVERT(varbinary(MAX), 'Bank Transfer - Account: QQQQ-QQQQ-QQQQ')),
    (11, 75,CONVERT(varbinary(MAX), 'Routing: WWWW-WWWW-WWWW')),
    (12, 16,CONVERT(varbinary(MAX), 'Cash on Delivery')),
    (13, 50,CONVERT(varbinary(MAX), 'Credit Card - XXXX-XXXX-XXXX-XXXX')),
    (14, 30,CONVERT(varbinary(MAX), 'PayPal - user@example.com')),
    (15, 79,CONVERT(varbinary(MAX), 'Debit Card - YYYY-YYYY-YYYY-YYYY')),
    (16, 90,CONVERT(varbinary(MAX), 'Bank Transfer - Account: XXXXXXXX')),
    (17, 47,CONVERT(varbinary(MAX), 'Routing: YYYYYYYY')),
    (18, 10,CONVERT(varbinary(MAX), 'Cash on Delivery')),
    (19, 90,CONVERT(varbinary(MAX), 'Credit Card - ZZZZ-ZZZZ-ZZZZ-ZZZZ')),
    (20, 16,CONVERT(varbinary(MAX), 'Debit Card - KKKK-KKKK-KKKK-KKKK')),
    (21, 1,CONVERT(varbinary(MAX), 'PayPal - user2@example.com')),
    (22, 78,CONVERT(varbinary(MAX), 'Bank Transfer - Account: QQQQ-QQQQ-QQQQ')),
    (23, 26,CONVERT(varbinary(MAX), 'Routing: WWWW-WWWW-WWWW')),
    (24, 19,CONVERT(varbinary(MAX), 'Cash on Delivery')),
    (25, 5,CONVERT(varbinary(MAX), 'Credit Card - XXXX-XXXX-XXXX-XXXX')),
    (26, 89,CONVERT(varbinary(MAX), 'PayPal - user@example.com')),
    (27, 13,CONVERT(varbinary(MAX), 'Debit Card - YYYY-YYYY-YYYY-YYYY')),
    (28, 35,CONVERT(varbinary(MAX), 'Bank Transfer - Account: XXXXXXXX')),
    (29, 4,CONVERT(varbinary(MAX), 'Routing: YYYYYYYY')),
    (30, 84,CONVERT(varbinary(MAX), 'Cash on Delivery')),
    (31, 65,CONVERT(varbinary(MAX), 'Credit Card - ZZZZ-ZZZZ-ZZZZ-ZZZZ')),
    (32, 84,CONVERT(varbinary(MAX), 'Debit Card - KKKK-KKKK-KKKK-KKKK')),
    (33, 6,CONVERT(varbinary(MAX), 'PayPal - user2@example.com')),
    (34, 33,CONVERT(varbinary(MAX), 'Bank Transfer - Account: QQQQ-QQQQ-QQQQ')),
    (35, 76,CONVERT(varbinary(MAX), 'Routing: WWWW-WWWW-WWWW')),
    (36, 48,CONVERT(varbinary(MAX), 'Cash on Delivery')),
    (37, 66,CONVERT(varbinary(MAX), 'Credit Card - XXXX-XXXX-XXXX-XXXX')),
    (38, 68,CONVERT(varbinary(MAX), 'PayPal - user@example.com')),
    (39, 36,CONVERT(varbinary(MAX), 'Debit Card - YYYY-YYYY-YYYY-YYYY')),
    (40, 61,CONVERT(varbinary(MAX), 'Bank Transfer - Account: XXXXXXXX')),
    (41, 95,CONVERT(varbinary(MAX), 'Routing: YYYYYYYY')),
    (42, 9,CONVERT(varbinary(MAX), 'Cash on Delivery')),
    (43, 68,CONVERT(varbinary(MAX), 'Credit Card - ZZZZ-ZZZZ-ZZZZ-ZZZZ')),
    (44, 2,CONVERT(varbinary(MAX), 'Debit Card - KKKK-KKKK-KKKK-KKKK')),
    (45, 55,CONVERT(varbinary(MAX), 'PayPal - user2@example.com')),
    (46, 2,CONVERT(varbinary(MAX), 'Bank Transfer - Account: QQQQ-QQQQ-QQQQ')),
    (47, 49,CONVERT(varbinary(MAX), 'Routing: WWWW-WWWW-WWWW')),
    (48, 97,CONVERT(varbinary(MAX), 'Cash on Delivery')),
    (49, 63,CONVERT(varbinary(MAX), 'Credit Card - XXXX-XXXX-XXXX-XXXX')),
    (50, 15,CONVERT(varbinary(MAX), 'PayPal - user@example.com')),
    (51, 87,CONVERT(varbinary(MAX), 'Debit Card - YYYY-YYYY-YYYY-YYYY')),
    (52, 33,CONVERT(varbinary(MAX), 'Bank Transfer - Account: XXXXXXXX')),
    (53, 20,CONVERT(varbinary(MAX), 'Routing: YYYYYYYY')),
    (54, 4,CONVERT(varbinary(MAX), 'Cash on Delivery')),
    (55, 52,CONVERT(varbinary(MAX), 'Credit Card - ZZZZ-ZZZZ-ZZZZ-ZZZZ')),
    (56, 59,CONVERT(varbinary(MAX), 'Debit Card - KKKK-KKKK-KKKK-KKKK')),
    (57, 34,CONVERT(varbinary(MAX), 'PayPal - user2@example.com')),
    (58, 26,CONVERT(varbinary(MAX), 'Bank Transfer - Account: QQQQ-QQQQ-QQQQ')),
    (59, 35,CONVERT(varbinary(MAX), 'Routing: WWWW-WWWW-WWWW')),
    (60, 59,CONVERT(varbinary(MAX), 'Cash on Delivery'));

-- Inserting Data in Driver Table
INSERT INTO Driver (DriverID, UserID, VehicleID, LicenseInfo)
VALUES
    (1, 98, 54, 'DL5N8S4'),
    (2, 1, 22, 'DL9W1N8'),
    (3, 96, 34, 'DL5K7Y3'),
    (4, 67, 14, 'DL5A4G8'),
    (5, 1, 26, 'DL6Y3S5'),
    (6, 24, 40, 'DL3X6P7'),
    (7, 82, 35, 'DL5A4G8'),
    (8, 40, 76, 'DL6Y3S5'),
    (9, 7, 24, 'DL6Y3S5'),
    (10, 17, 61, 'DL4B8L3'),
    (11, 57, 66, 'DL5U8B4'),
    (12, 11, 61, 'DL4P7B3'),
    (13, 81, 91, 'DL4R2L5'),
    (14, 76, 6, 'DL4R2L5'),
    (15, 13, 16, 'DL8F6V2'),
    (16, 41, 13, 'DL9N2R8'),
    (17, 76, 90, 'DL1V4T9'),
    (18, 94, 28, 'DL5A4G8'),
    (19, 99, 68, 'DL4Q1S8'),
    (20, 25, 48, 'DL2L7V9'),
    (21, 78, 58, 'DL2B8J7'),
    (22, 44, 88, 'DL1J6C9'),
    (23, 88, 19, 'DL4H6V2'),
    (24, 12, 92, 'DL3X6P7'),
    (25, 55, 90, 'DL4F3V6'),
    (26, 24, 91, 'DL5N8S4'),
    (27, 42, 38, 'DL7Z3P8'),
    (28, 29, 55, 'DL2X1W5'),
    (29, 39, 44, 'DL1P8J6'),
    (30, 85, 15, 'DL4Q6Z1'),
    (31, 65, 96, 'DL9W1N8'),
    (32, 62, 81, 'DL5K7Y3'),
    (33, 5, 51, 'DL6W4U9'),
    (34, 61, 41, 'DL7H6T1'),
    (35, 68, 99, 'DL8F6V2'),
    (36, 38, 84, 'DL9G5R1'),
    (37, 97, 18, 'DL2B7J4'),
    (38, 31, 31, 'DL9T3E2'),
    (39, 73, 76, 'DL9B8J2'),
    (40, 83, 89, 'DL8P6X4');

-- Inserting Data in Feedback Table
INSERT INTO Feedback (FeedbackID, CustomerID, DriverID, Message,Rating)
VALUES
    (1, 2, 10, 'Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis.', 0.5),
    (2, 44, 37, 'Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum.', 3.0),
    (3, 53, 11, 'Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', 2.2),
    (4, 19, 14, 'Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Duis faucibus accumsan odio. Curabitur convallis.', 4.4),
    (5, 5, 13, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl.', 3.6),
    (6, 4, 23, 'Aliquam erat volutpat. In congue. Etiam justo.', 0.6),
    (7, 28, 11, 'Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.', 0.9),
    (8, 37, 15, 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', 3.7),
    (9, 42, 10, 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus.', 1.0),
    (10, 56, 10, 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 4.1),
    (11, 34, 25, 'Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', 4.5),
    (12, 41, 11, 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.', 4.8),
    (13, 42, 35, 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.', 0.1),
    (14, 49, 16, 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', 0.8),
    (15, 8, 27, 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.', 0.3),
    (16, 16, 9, 'Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Mauris viverra diam vitae quam.', 3.8),
    (17, 22, 40, 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', 2.1),
    (18, 39, 30, 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', 0.2),
    (19, 47, 30, 'Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.', 0.8),
    (20, 7, 5, 'Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.', 3.7),
    (21, 26, 30, 'Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', 4.0),
    (22, 22, 9, 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', 1.1),
    (23, 40, 25, 'Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 1.0),
    (24, 2, 35, 'Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Duis faucibus accumsan odio.', 2.9),
    (25, 10, 2, 'Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.', 0.3),
    (26, 35, 25, 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 4.9),
    (27, 15, 3, 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', 3.0),
    (28, 51, 9, 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.', 3.5),
    (29, 11, 36, 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', 1.9),
    (30, 10, 38, 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 4.1),
    (31, 35, 33, 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 1.4),
    (32, 22, 15, 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', 4.7),
    (33, 33, 20, 'Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 1.9),
    (34, 24, 31, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 4.3),
    (35, 34, 7, 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 0.2),
    (36, 40, 37, 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', 1.6),
    (37, 27, 28, 'Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Duis faucibus accumsan odio.', 4.3),
    (38, 29, 38, 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst.', 0.9),
    (39, 28, 12, 'Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl.', 2.0),
    (40, 54, 13, 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', 2.8),
    (41, 49, 30, 'Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam.', 1.2),
    (42, 57, 15, 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', 0.1),
    (43, 3, 15, 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 4.5),
    (44, 30, 18, 'Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', 1.5),
    (45, 3, 4, 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', 0.3),
    (46, 48, 6, 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', 3.5),
    (47, 2, 4, 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', 4.7),
    (48, 1, 28, 'Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien.', 3.2),
    (49, 36, 11, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', 4.5),
    (50, 4, 8, 'In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', 1.7),
    (51, 4, 29, 'Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus.', 2.3),
    (52, 56, 35, 'Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam. Nam tristique tortor eu pede.', 3.1),
    (53, 60, 36, 'Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', 0.9),
    (54, 16, 30, 'Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst.', 2.9),
    (55, 18, 5, 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis.', 1.5),
    (56, 19, 27, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.', 1.5),
    (57, 60, 28, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.', 1.5),
    (58, 36, 40, 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus.', 4.9),
    (59, 26, 3, 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', 1.1),
    (60, 26, 5, 'In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.', 4.8),
    (61, 9, 17, 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', 1.8),
    (62, 56, 29, 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum.', 1.3),
    (63, 39, 1, 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.', 3.9),
    (64, 39, 23, 'Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor.', 1.8),
    (65, 6, 21, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', 2.6),
    (66, 23, 27, 'Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.', 0.4),
    (67, 50, 34, 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', 0.4),
    (68, 23, 32, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', 0.9),
    (69, 19, 7, 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', 3.7),
    (70, 13, 15, 'Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', 0.1),
    (71, 48, 15, 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.', 0.8),
    (72, 32, 1, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 4.5),
    (73, 59, 10, 'Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', 4.0),
    (74, 55, 40, 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', 2.8),
    (75, 18, 8, 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', 3.7),
    (76, 58, 39, 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', 3.9),
    (77, 43, 10, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.', 2.5),
    (78, 52, 14, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', 0.0),
    (79, 48, 7, 'Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui.', 4.1),
    (80, 58, 15, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.', 3.8),
    (81, 29, 8, 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 2.6),
    (82, 40, 24, 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', 1.1),
    (83, 51, 36, 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', 2.2),
    (84, 12, 31, 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Duis faucibus accumsan odio. Curabitur convallis.', 2.5),
    (85, 15, 33, 'In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem.', 3.3),
    (86, 59, 5, 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', 0.7),
    (87, 51, 3, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat.', 0.9),
    (88, 31, 1, 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 5.0),
    (89, 39, 24, 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.', 4.3),
    (90, 44, 28, 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', 2.7),
    (91, 25, 8, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', 4.1),
    (92, 1, 5, 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Mauris viverra diam vitae quam.', 3.8),
    (93, 26, 33, 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', 1.8),
    (94, 16, 40, 'Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', 1.0),
    (95, 33, 11, 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.', 1.2),
    (96, 24, 25, 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 4.3),
    (97, 50, 15, 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus.', 3.3),
    (98, 13, 30, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', 1.6),
    (99, 58, 20, 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 2.8),
    (100, 19, 28, 'Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.', 0.8);

-- Inserting Data in TripEstimate Table
INSERT INTO TripEstimate (EstimationId, VehicleID, CurrentTime, Cost)
VALUES
    (1, 59, '2023-06-16 18:00:57', 145.72),
    (2, 63, '2023-12-17 19:56:27', 69.63),
    (3, 52, '2023-12-18 16:34:09', 80.67),
    (4, 64, '2023-12-22 16:16:17', 214.70),
    (5, 96, '2023-02-11 05:14:46', 105.25),
    (6, 56, '2023-08-29 04:33:52', 178.10),
    (7, 100, '2023-11-01 10:52:41', 92.30),
    (8, 54, '2023-10-02 00:17:28', 96.26),
    (9, 100, '2023-10-30 22:37:25', 185.74),
    (10, 70, '2023-11-22 17:17:52', 157.42),
    (11, 17, '2023-04-28 10:43:57', 79.82),
    (12, 79, '2023-02-24 23:35:44', 13.98),
    (13, 73, '2023-10-23 16:31:15', 142.31),
    (14, 32, '2023-08-08 22:15:59', 61.05),
    (15, 14, '2023-06-15 10:39:21', 188.13),
    (16, 10, '2023-12-07 09:15:57', 177.53),
    (17, 6, '2023-12-07 15:54:17', 48.34),
    (18, 19, '2023-12-24 18:51:08', 90.60),
    (19, 19, '2022-12-31 02:17:37', 189.65),
    (20, 76, '2023-11-09 18:04:42', 91.55),
    (21, 59, '2023-01-01 09:00:31', 161.85),
    (22, 72, '2023-09-18 22:02:33', 192.53),
    (23, 73, '2023-05-23 00:49:57', 89.77),
    (24, 90, '2023-09-14 02:40:29', 161.10),
    (25, 14, '2023-10-17 08:06:19', 105.35),
    (26, 26, '2023-10-15 07:22:16', 61.43),
    (27, 59, '2023-12-12 20:36:23', 50.64),
    (28, 6, '2023-06-27 18:56:47', 225.19),
    (29, 84, '2023-10-10 16:03:27', 222.31),
    (30, 12, '2023-04-21 23:19:23', 213.05);

-- Inserting Data in RideRequest Table
INSERT INTO RideRequest (RequestId, EstimationID, VehicleID,DriverID, CustomerID,RequestType, ReqDateTime, 
    PickUpLocationLatitude, PickUpLocationLongitude, DestinationLocationLatitude, 
    DestinationLocationLongitude, TripType, TripCompletionFlag, PickUpLocation, DestinationLocation)
VALUES
    (1, 28, 69, 16, 14, 'Out Station Cab', '2023-04-09 20:08:17', -7.5849174, 111.8784707, -6.7515973, 107.9287898, 'Out Station Cab', 1, '415 Scofield Alley', '873 Jackson Way'),
    (2, 14, 52, 14, 43, 'City Cab', '2023-10-25 12:17:31', 22.948016, 113.366904, 37.4882943, 71.5901986, 'Out Station Cab', 1, '678 Bonner Parkway', '5904 Gina Way'),
    (3, 8, 67, 39, 29, 'Out Station Cab', '2023-06-02 01:40:19', 44.6208353, 21.1842054, 34.9588458, 33.466379, 'Out Station Cab', 0, '2342 Rockefeller Junction', '488 Milwaukee Way'),
    (4, 28, 1, 29, 39, 'City Cab', '2023-02-27 04:05:59', 12.5641479, -16.2639825, 3.095417, -76.1435915, 'City Cab', 1, '8177 Kensington Place', '59 Troy Way'),
    (5, 30, 88, 10, 60, 'Out Station Cab', '2023-01-06 23:57:38', 5.032145, -74.884455, 40.0115285, -119.6962677, 'Out Station Cab', 1, '5768 Eliot Hill', '0937 Monica Center'),
    (6, 30, 23, 22, 19, 'Out Station Cab', '2023-12-06 07:00:53', 36.077544, 120.008307, -31.4311903, -62.0729285, 'City Cab', 0, '970 Elka Court', '767 Becker Pass'),
    (7, 13, 37, 32, 51, 'Out Station Cab', '2023-07-04 03:23:37', 10.1592286, -69.0087365, 24.781681, 118.552365, 'Out Station Cab', 1, '00226 Summer Ridge Way', '47567 Oriole Alley'),
    (8, 28, 17, 10, 11, 'City Cab', '2023-08-07 04:55:58', 28.1904306, 112.9857433, 6.5163966, 14.2919273, 'Out Station Cab', 0, '74 Coleman Parkway', '459 Comanche Way'),
    (9, 18, 25, 27, 60, 'City Cab', '2023-06-06 11:32:00', 25.2898918, 32.5522304, 38.8062871, 139.9346659, 'City Cab', 1, '931 Barnett Trail', '33824 Transport Lane'),
    (10, 6, 61, 6, 31, 'Out Station Cab', '2023-02-10 16:10:28', 50.8290137, 15.6741931, 29.483315, 119.872545, 'Out Station Cab', 1, '82573 Miller Drive', '31864 Holy Cross Street'),
    (11, 30, 26, 30, 59, 'Out Station Cab', '2023-04-09 23:11:39', 6.7911741, -77.5504779, 9.49858, 50.8105261, 'City Cab', 0, '989 Maple Alley', '1995 Union Place'),
    (12, 14, 2, 29, 36, 'Out Station Cab', '2023-01-11 07:37:05', 50.5332417, 23.7255557, 32.5538633, 51.5097515, 'Out Station Cab', 1, '6459 Hanover Street', '353 Merchant Crossing'),
    (13, 27, 15, 24, 24, 'Out Station Cab', '2023-03-09 20:36:12', 33.504555, 113.913911, 48.9095, 25.33926, 'City Cab', 1, '08 Bashford Center', '68 Clarendon Court'),
    (14, 19, 46, 38, 44, 'Out Station Cab', '2023-10-10 14:50:15', 26.6646381, 87.271781, 35.4335808, 139.5718014, 'Out Station Cab', 0, '1 Arrowood Lane', '0866 Vidon Trail'),
    (15, 5, 20, 35, 19, 'City Cab', '2023-10-20 12:16:20', 14.5346437, 121.0133007, 39.109563, 117.223371, 'City Cab', 0, '6 Buell Lane', '59 Daystar Avenue'),
    (16, 1, 6, 4, 22, 'Out Station Cab', '2023-01-19 15:09:14', 32.5777123, 59.7977761, 17.057356, -89.151003, 'Out Station Cab', 1, '067 Carey Court', '203 Chinook Drive'),
    (17, 17, 62, 35, 23, 'City Cab', '2023-01-03 17:54:22', 52.4293273, 19.4619176, 23.0594685, 113.8146974, 'City Cab', 0, '7 Schmedeman Terrace', '6347 Memorial Plaza'),
    (18, 5, 48, 2, 59, 'Out Station Cab', '2023-01-30 19:17:54', -31.3582685, -64.2371705, 39.9721425, 69.8597406, 'Out Station Cab', 1, '14259 Russell Circle', '90995 Arizona Point'),
    (19, 3, 72, 38, 31, 'Out Station Cab', '2023-05-05 06:39:33', -6.4237489, 20.7956878, 53.3004898, -6.2634596, 'City Cab', 1, '56662 Vera Parkway', '597 Fremont Center'),
    (20, 10, 62, 31, 37, 'City Cab', '2023-01-20 06:35:55', 19.4102526, -99.0073673, 38.3208398, 23.7900853, 'City Cab', 1, '3384 Havey Pass', '45 Ridgeway Junction'),
    (21, 3, 73, 9, 60, 'Out Station Cab', '2023-06-24 07:46:50', 1.0725136, 121.499885, 14.5699334, 121.0204582, 'City Cab', 0, '8466 Nova Circle', '40 Milwaukee Parkway'),
    (22, 17, 88, 9, 44, 'Out Station Cab', '2023-02-15 07:09:35', -6.8013457, 111.4126837, -7.6411786, 112.6377432, 'City Cab', 1, '72 Charing Cross Drive', '08598 Lillian Point'),
    (23, 18, 21, 22, 26, 'City Cab', '2023-03-27 15:17:37', -18.0292038, -63.4021544, 53.1501463, 24.8029784, 'Out Station Cab', 0, '81 Lukken Trail', '547 Eastlawn Road'),
    (24, 27, 6, 14, 27, 'Out Station Cab', '2023-01-13 23:22:18', 25.7784224, -103.2605763, 49.1169513, 101.449837, 'City Cab', 1, '4993 Comanche Plaza', '3 Harper Plaza'),
    (25, 26, 47, 27, 31, 'Out Station Cab', '2023-11-07 22:08:27', 42.4576548, -2.4407498, 50.71966, 16.345569, 'Out Station Cab', 0, '505 Division Park', '55281 6th Junction'),
    (26, 5, 11, 26, 48, 'City Cab', '2023-05-17 12:40:06', 6.027632, -75.431596, 29.2031708, 25.5195451, 'City Cab', 0, '8 Village Road', '3 Oak Alley'),
    (27, 23, 21, 34, 54, 'City Cab', '2023-10-06 21:59:14', 56.232836, 43.8367278, -6.8546403, 107.4293388, 'City Cab', 0, '054 Annamark Junction', '0 South Junction'),
    (28, 13, 57, 31, 56, 'City Cab', '2023-06-08 14:18:20', -34.4402062, -55.9600098, 16.3274859, 120.3660634, 'City Cab', 1, '72159 Steensland Park', '979 Blue Bill Park Plaza'),
    (29, 14, 86, 37, 26, 'City Cab', '2023-09-06 04:55:48', 41.1266172, 23.3819761, 12.573631, 102.1041583, 'City Cab', 1, '53 Menomonie Alley', '602 Sage Alley'),
    (30, 15, 60, 4, 38, 'Out Station Cab', '2023-10-09 03:41:45', -22.3734081, -48.3860575, 29.099294, 119.692696, 'Out Station Cab', 0, '2259 Summer Ridge Pass', '38 Lotheville Hill');


-- Inserting Data in ServiceRequest Table
INSERT INTO ServiceRequest (SerReqId, VehicleId, ServiceId, ReqDateTime, ServiceDueDate, PreviousServiceDate)
VALUES
    (1, 71, 79, '10/31/2023', '3/18/2023', '2/22/2022'),
    (2, 94, 70, '2/22/2023', '4/30/2023', '4/12/2022'),
    (3, 83, 62, '4/5/2023', '12/5/2023', '10/5/2022'),
    (4, 91, 16, '7/19/2023', '7/12/2023', '7/14/2022'),
    (5, 47, 92, '3/8/2023', '6/15/2023', '9/1/2022'),
    (6, 45, 81, '7/18/2023', '7/10/2023', '5/28/2022'),
    (7, 37, 1, '6/23/2023', '1/25/2023', '7/2/2022'),
    (8, 82, 13, '7/3/2023', '6/26/2023', '4/6/2022'),
    (9, 88, 82, '5/16/2023', '3/28/2023', '4/27/2022'),
    (10, 20, 93, '4/20/2023', '3/10/2023', '7/13/2022'),
    (11, 14, 17, '5/6/2023', '1/15/2023', '6/1/2022'),
    (12, 24, 39, '5/21/2023', '1/21/2023', '2/13/2022'),
    (13, 12, 3, '11/2/2023', '10/27/2023', '10/4/2022'),
    (14, 6, 11, '10/2/2023', '4/21/2023', '2/20/2022'),
    (15, 47, 27, '9/27/2023', '10/1/2023', '2/17/2022'),
    (16, 43, 9, '1/26/2023', '10/9/2023', '12/21/2022'),
    (17, 19, 22, '10/10/2023', '7/14/2023', '6/22/2022'),
    (18, 76, 68, '4/27/2023', '9/3/2023', '8/25/2022'),
    (19, 27, 76, '2/20/2023', '4/1/2023', '6/7/2022'),
    (20, 86, 17, '6/3/2023', '1/17/2023', '10/2/2022'),
    (21, 17, 65, '5/5/2023', '12/20/2023', '9/11/2022'),
    (22, 58, 87, '6/4/2023', '9/13/2023', '4/9/2022'),
    (23, 17, 49, '2/9/2023', '6/24/2023', '12/21/2022'),
    (24, 58, 48, '4/11/2023', '10/11/2023', '7/29/2022'),
    (25, 74, 11, '7/13/2023', '9/28/2023', '12/6/2022'),
    (26, 55, 46, '12/26/2022', '4/27/2023', '11/16/2022'),
    (27, 10, 85, '9/4/2023', '8/25/2023', '5/26/2022'),
    (28, 76, 78, '1/26/2023', '1/17/2023', '2/6/2022'),
    (29, 99, 27, '3/26/2023', '2/21/2023', '2/5/2022'),
    (30, 28, 83, '5/21/2023', '4/12/2023', '10/18/2022'),
    (31, 79, 60, '3/18/2023', '12/11/2023', '4/24/2022'),
    (32, 36, 84, '3/15/2023', '10/24/2023', '9/21/2022'),
    (33, 97, 85, '12/8/2022', '1/18/2023', '7/2/2022'),
    (34, 79, 26, '6/3/2023', '8/4/2023', '9/13/2022'),
    (35, 71, 90, '12/23/2022', '5/4/2023', '11/30/2022'),
    (36, 38, 51, '5/15/2023', '5/13/2023', '4/10/2022'),
    (37, 83, 55, '4/23/2023', '10/1/2023', '11/10/2022'),
    (38, 86, 16, '8/13/2023', '1/27/2023', '7/6/2022'),
    (39, 59, 61, '3/24/2023', '6/30/2023', '6/11/2022'),
    (40, 43, 92, '3/8/2023', '3/13/2023', '7/12/2022'),
    (41, 7, 37, '6/11/2023', '12/8/2023', '1/26/2022'),
    (42, 70, 8, '7/28/2023', '12/9/2023', '7/13/2022'),
    (43, 12, 36, '12/24/2022', '3/29/2023', '2/22/2022'),
    (44, 18, 99, '12/6/2022', '3/27/2023', '10/29/2022'),
    (45, 31, 87, '12/12/2022', '10/5/2023', '10/17/2022'),
    (46, 32, 94, '1/9/2023', '11/14/2023', '3/12/2022'),
    (47, 83, 79, '10/14/2023', '3/4/2023', '12/21/2022'),
    (48, 85, 43, '8/31/2023', '9/18/2023', '8/9/2022'),
    (49, 38, 35, '3/9/2023', '5/29/2023', '5/11/2022'),
    (50, 68, 48, '2/19/2023', '9/4/2023', '7/19/2022'),
    (51, 27, 47, '9/8/2023', '6/10/2023', '1/15/2022'),
    (52, 93, 96, '3/8/2023', '2/7/2023', '1/30/2022'),
    (53, 6, 84, '9/2/2023', '7/15/2023', '4/18/2022'),
    (54, 91, 15, '4/22/2023', '8/7/2023', '10/29/2022'),
    (55, 66, 64, '9/17/2023', '12/5/2023', '4/26/2022'),
    (56, 37, 68, '1/25/2023', '12/15/2023', '4/2/2022'),
    (57, 55, 77, '11/1/2023', '10/30/2023', '11/11/2022'),
    (58, 19, 96, '5/30/2023', '1/2/2023', '8/3/2022'),
    (59, 59, 67, '10/20/2023', '6/19/2023', '5/19/2022'),
    (60, 95, 84, '3/30/2023', '11/1/2023', '8/6/2022'),
    (61, 51, 61, '6/2/2023', '10/1/2023', '12/14/2022'),
    (62, 84, 85, '3/10/2023', '9/10/2023', '12/21/2022'),
    (63, 37, 24, '7/31/2023', '12/8/2023', '1/3/2022'),
    (64, 79, 5, '10/10/2023', '8/31/2023', '2/28/2022'),
    (65, 69, 98, '7/28/2023', '1/15/2023', '6/25/2022'),
    (66, 70, 84, '12/31/2022', '6/15/2023', '8/18/2022'),
    (67, 86, 48, '9/2/2023', '11/10/2023', '4/2/2022'),
    (68, 70, 70, '10/24/2023', '9/12/2023', '3/10/2022'),
    (69, 76, 97, '5/27/2023', '10/3/2023', '7/15/2022'),
    (70, 91, 29, '3/5/2023', '2/8/2023', '4/4/2022'),
    (71, 93, 100, '11/10/2023', '2/9/2023', '12/1/2022'),
    (72, 100, 73, '12/26/2022', '8/9/2023', '11/22/2022'),
    (73, 1, 56, '12/24/2022', '1/7/2023', '9/26/2022'),
    (74, 36, 42, '7/18/2023', '3/20/2023', '10/5/2022'),
    (75, 86, 36, '1/29/2023', '5/28/2023', '12/30/2021'),
    (76, 61, 96, '11/22/2023', '5/27/2023', '5/17/2022'),
    (77, 75, 97, '4/28/2023', '12/10/2023', '9/14/2022'),
    (78, 29, 75, '7/11/2023', '9/18/2023', '11/7/2022'),
    (79, 37, 6, '7/17/2023', '8/31/2023', '12/30/2022'),
    (80, 24, 4, '5/19/2023', '8/13/2023', '12/4/2022'),
    (81, 40, 46, '8/18/2023', '12/16/2023', '7/30/2022'),
    (82, 79, 33, '9/13/2023', '11/3/2023', '4/23/2022'),
    (83, 38, 61, '11/4/2023', '11/17/2023', '3/21/2022'),
    (84, 43, 79, '6/2/2023', '8/9/2023', '12/13/2022'),
    (85, 99, 93, '11/12/2023', '11/15/2023', '4/24/2022'),
    (86, 22, 86, '12/29/2022', '8/31/2023', '11/13/2022'),
    (87, 37, 17, '3/16/2023', '12/30/2022', '12/13/2022'),
    (88, 55, 32, '2/7/2023', '12/11/2023', '3/7/2022'),
    (89, 19, 93, '11/29/2022', '9/18/2023', '5/11/2022'),
    (90, 98, 96, '9/26/2023', '2/27/2023', '6/8/2022'),
    (91, 7, 32, '3/1/2023', '7/14/2023', '7/12/2022'),
    (92, 35, 80, '3/14/2023', '2/4/2023', '3/12/2022'),
    (93, 18, 79, '1/13/2023', '7/15/2023', '1/4/2022'),
    (94, 87, 63, '8/7/2023', '4/22/2023', '6/9/2022'),
    (95, 61, 45, '10/14/2023', '6/25/2023', '7/14/2022'),
    (96, 31, 62, '8/17/2023', '4/22/2023', '12/29/2022'),
    (97, 1, 88, '8/31/2023', '9/9/2023', '5/20/2022'),
    (98, 56, 94, '11/16/2023', '2/14/2023', '8/2/2022'),
    (99, 10, 54, '9/3/2023', '6/30/2023', '5/23/2022'),
    (100, 36, 55, '8/25/2023', '8/5/2023', '4/4/2022');

-- Inserting Data in InsuranceLogs Table
INSERT INTO InsuranceLogs (VehicleID, InsuranceId, InsuranceStartDate, InsuranceEndDate)
VALUES
    (46, 67, '3/20/2023', '11/19/2024'),
    (72, 74, '11/22/2023', '10/5/2024'),
    (43, 16, '12/26/2023', '10/28/2024'),
    (21, 65, '4/5/2023', '5/12/2024'),
    (59, 68, '8/19/2023', '11/8/2024'),
    (18, 96, '10/19/2023', '12/3/2024'),
    (94, 11, '1/12/2023', '1/1/2024'),
    (86, 51, '2/18/2023', '9/23/2024'),
    (41, 75, '8/9/2023', '12/15/2024'),
    (56, 62, '8/24/2023', '2/8/2024'),
    (62, 46, '3/3/2023', '6/13/2024'),
    (28, 76, '1/31/2023', '6/14/2024'),
    (28, 95, '3/12/2023', '8/29/2024'),
    (54, 8, '2/16/2023', '8/31/2024'),
    (82, 97, '11/29/2023', '5/11/2024'),
    (9, 27, '1/12/2023', '6/10/2024'),
    (24, 50, '8/10/2023', '5/16/2024'),
    (12, 68, '3/10/2023', '4/4/2024'),
    (90, 56, '11/2/2023', '1/30/2024'),
    (12, 17, '6/5/2023', '1/3/2024'),
    (1, 20, '4/20/2023', '7/2/2024'),
    (60, 52, '5/17/2023', '5/23/2024'),
    (60, 63, '1/26/2023', '1/15/2024'),
    (28, 67, '5/28/2023', '10/15/2024'),
    (61, 2, '1/3/2023', '1/6/2024'),
    (14, 43, '3/12/2023', '11/13/2024'),
    (66, 9, '5/20/2023', '9/25/2024'),
    (94, 41, '5/19/2023', '7/6/2024'),
    (36, 95, '5/17/2023', '1/8/2024'),
    (86, 95, '5/12/2023', '3/11/2024'),
    (54, 100, '3/10/2023', '4/6/2024'),
    (27, 47, '3/26/2023', '7/8/2024'),
    (93, 75, '10/7/2023', '2/8/2024'),
    (77, 9, '11/13/2023', '1/9/2024'),
    (76, 30, '1/27/2023', '9/23/2024'),
    (49, 71, '2/16/2023', '3/9/2024'),
    (54, 91, '7/28/2023', '6/24/2024'),
    (33, 92, '2/24/2023', '6/9/2024'),
    (44, 14, '7/19/2023', '2/16/2024'),
    (70, 42, '7/21/2023', '6/16/2024'),
    (23, 81, '4/5/2023', '12/24/2024'),
    (18, 88, '11/8/2023', '3/17/2024'),
    (39, 40, '8/31/2023', '9/9/2024'),
    (6, 80, '3/7/2023', '9/27/2024'),
    (86, 22, '6/22/2023', '9/1/2024'),
    (9, 59, '6/16/2023', '8/4/2024'),
    (27, 46, '9/1/2023', '10/22/2024'),
    (47, 100, '7/18/2023', '11/17/2024'),
    (32, 42, '6/14/2023', '6/23/2024'),
    (87, 61, '5/19/2023', '2/15/2024'),
    (30, 57, '7/25/2023', '5/16/2024'),
    (88, 84, '1/17/2023', '12/22/2024'),
    (53, 88, '4/18/2023', '1/22/2024'),
    (43, 44, '12/7/2023', '6/29/2024'),
    (4, 42, '10/21/2023', '1/27/2024'),
    (2, 2, '1/10/2023', '7/30/2024'),
    (58, 9, '9/15/2023', '2/20/2024'),
    (50, 87, '11/9/2023', '12/5/2024'),
    (21, 38, '10/14/2023', '12/17/2024'),
    (84, 40, '6/15/2023', '7/21/2024'),
    (31, 58, '10/13/2023', '6/19/2024'),
    (54, 28, '11/4/2023', '5/29/2024'),
    (44, 31, '2/28/2023', '2/1/2024'),
    (57, 1, '9/18/2023', '1/25/2024'),
    (82, 78, '6/28/2023', '7/31/2024'),
    (94, 64, '2/11/2023', '7/3/2024'),
    (61, 63, '5/20/2023', '3/3/2024'),
    (40, 11, '3/9/2023', '7/6/2024'),
    (98, 81, '11/21/2023', '2/27/2024'),
    (44, 63, '10/5/2023', '3/9/2024'),
    (93, 9, '8/4/2023', '9/21/2024'),
    (21, 12, '1/1/2023', '8/30/2024'),
    (43, 61, '1/5/2023', '8/30/2024'),
    (95, 25, '12/23/2023', '2/3/2024'),
    (71, 63, '10/23/2023', '4/28/2024'),
    (91, 85, '6/6/2023', '5/4/2024'),
    (77, 74, '1/26/2023', '6/22/2024'),
    (65, 26, '6/10/2023', '1/16/2024'),
    (54, 64, '1/29/2023', '11/12/2024'),
    (41, 93, '10/6/2023', '9/9/2024'),
    (34, 32, '4/12/2023', '12/8/2024'),
    (64, 44, '5/24/2023', '8/20/2024'),
    (75, 56, '2/20/2023', '3/18/2024'),
    (90, 78, '3/27/2023', '6/13/2024'),
    (5, 23, '2/5/2023', '7/15/2024'),
    (11, 64, '4/20/2023', '2/22/2024'),
    (47, 99, '4/16/2023', '9/21/2024'),
    (62, 94, '1/18/2023', '6/7/2024'),
    (52, 12, '2/24/2023', '10/31/2024'),
    (27, 17, '2/15/2023', '8/27/2024'),
    (36, 26, '5/3/2023', '11/7/2024'),
    (98, 56, '8/14/2023', '4/24/2024'),
    (1, 1, '6/9/2023', '5/15/2024'),
    (44, 68, '4/12/2023', '8/22/2024'),
    (53, 68, '5/22/2023', '7/13/2024'),
    (43, 74, '4/30/2023', '1/29/2024'),
    (89, 28, '4/29/2023', '1/17/2024'),
    (74, 90, '10/22/2023', '7/29/2024'),
    (87, 50, '6/13/2023', '11/14/2024'),
    (95, 33, '11/28/2023', '12/26/2024');

/* DISPLAY STATEMENTS */
-- Displaying Data from Service Table
SELECT * FROM Service;

-- Displaying Data from Insurance Table
SELECT * FROM Insurance;

-- Displaying Data from Vehicle Table
SELECT * FROM Vehicle;

-- Displaying Data from [User] Table
SELECT * FROM [User];

-- Displaying Data from Customer Table
SELECT * FROM Customer;

-- Displaying Data from Driver Table
SELECT * FROM Driver;

-- Displaying Data from Feedback Table
SELECT * FROM Feedback;

-- Displaying Data from TripEstimate Table
SELECT * FROM TripEstimate;

-- Displaying Data from RideRequest Table
SELECT * FROM RideRequest;

-- Displaying Data from ServiceRequest Table
SELECT * FROM ServiceRequest;

-- Displaying Data from InsuranceLogs Table
SELECT * FROM InsuranceLogs;