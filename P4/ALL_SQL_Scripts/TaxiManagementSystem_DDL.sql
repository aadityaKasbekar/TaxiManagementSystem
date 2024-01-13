-- Check if the database 'TaxiManagementSystem' exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'TaxiManagementSystem')
BEGIN
    -- Drop (delete) the database 'TaxiManagementSystem' if it exists
    DROP DATABASE TaxiManagementSystem;
END
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

-- User Table
DROP TABLE IF EXISTS [User];
GO

-- Vehicle Table
DROP TABLE IF EXISTS Vehicle;
GO

-- Customer Table
DROP TABLE IF EXISTS Customer;
GO

-- Insurance Table
DROP TABLE IF EXISTS Insurance;
GO

-- Service Table
DROP TABLE IF EXISTS Service;
GO

-- InsuranceLogs Table
DROP TABLE IF EXISTS InsuranceLogs;
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

-- Vehicle Table
CREATE TABLE Vehicle (
    VehicleId INT PRIMARY KEY,                                      -- Unique identifier for each vehicle
    VehicleType VARCHAR(50),                                        -- Type or model of the vehicle
    ServiceInfo VARCHAR(255),                                       -- Information about the vehicle's service history
    InsuranceInfo CHAR(1) CHECK (InsuranceInfo IN ('Y', 'N'))       -- Check constraint for InsuranceInfo (Y for present, N for not present)
);
GO

-- User Table
CREATE TABLE [User] (
    UserID INT PRIMARY KEY,                                         -- Unique identifier for each user
    UserFName VARCHAR(50) NOT NULL,                                 -- User's first name
    UserLName VARCHAR(50) NOT NULL,                                 -- User's last name
    PhoneNumber VARCHAR(15) NOT NULL,                               -- User's phone number
    EmailId VARCHAR(255) NOT NULL,                                  -- User's email address
    DOB DATE NOT NULL,                                              -- User's date of birth
    BankAccInfo VARCHAR(255) NOT NULL,                              -- User's bank account information
    UserType CHAR(1) NOT NULL CHECK (UserType IN ('D', 'C')),       -- Type of user (D for driver, C for customer)
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

-- Create a master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'AmeySatwe23';

-- Create a certificate to protect the master key
CREATE CERTIFICATE MyCertificate
   WITH SUBJECT = 'My Column Encryption Certificate';

-- Create a symmetric key
CREATE SYMMETRIC KEY MySymmetricKey
   WITH ALGORITHM = AES_256
   ENCRYPTION BY CERTIFICATE MyCertificate;

-- Create an AFTER INSERT trigger
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
    Message VARCHAR(255) NOT NULL,                                   -- Feedback message
    Rating Float CHECK(Rating BETWEEN 0.0 AND 5.0) DEFAULT 0.0
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

-- RideRequest Table
CREATE TABLE RideRequest (
    RequestId INT PRIMARY KEY NOT NULL,                                                 -- Unique identifier for each ride request
    EstimationID INT FOREIGN KEY REFERENCES TripEstimate(EstimationId),                 -- Foreign key referencing TripEstimate table
    VehicleID INT FOREIGN KEY REFERENCES Vehicle(VehicleID),                            -- Foreign key referencing Vehicle table
    DriverID INT FOREIGN KEY REFERENCES Driver(DriverID),
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
    RequestType VARCHAR(50) NOT NULL,                                                   -- Type of the ride request
    ReqDateTime DATETIME NOT NULL,                                                      -- Timestamp of the ride request
    PickUpLocationLatitude DECIMAL(10, 6) NOT NULL,                                     -- Latitude of the pickup location
    PickUpLocationLongitude DECIMAL(10, 6) NOT NULL,                                    -- Longitude of the pickup location
    DestinationLocationLatitude DECIMAL(10, 6) NOT NULL,                                -- Latitude of the destination location
    DestinationLocationLongitude DECIMAL(10, 6) NOT NULL,                               -- Longitude of the destination location
    TripType VARCHAR(50) NOT NULL CHECK (TripType IN ('City Cab', 'Out Station Cab')),  -- Type of the trip
    TripCompletionFlag BIT NOT NULL,                                                    -- Flag indicating trip completion status
    PickUpLocation VARCHAR(50) NOT NULL,                                                -- Textual description of the pickup location
    DestinationLocation VARCHAR(50) NOT NULL                                            -- Textual description of the destination location
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