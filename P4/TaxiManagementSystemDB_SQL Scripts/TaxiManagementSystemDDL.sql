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
