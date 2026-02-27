-- ============================================================================
-- TaxiManagementSystem — Redesigned Data Layer
-- Script 03: Core Entity Tables
-- Engine: MySQL 8.0+
-- ============================================================================
-- FIXES APPLIED:
--   • Every table has an AUTO_INCREMENT surrogate PK
--   • Reserved word "User" renamed to "AppUser"
--   • All mandatory FK columns are NOT NULL
--   • UNIQUE constraints on natural keys (Email, Phone)
--   • FLOAT → DECIMAL for Rating
--   • Plaintext BankAccInfo removed; encrypted column added
--   • Redundant lat/lng + text locations → normalized Location table
--   • Orphan "Temp" table dropped entirely
--   • PaymentInformation and InsuranceLogs now have proper PKs
--   • created_at / updated_at audit columns on every table
--   • InsuranceInfo CHAR(1) flag replaced by nullable FK to InsuranceLogs
-- ============================================================================

USE TaxiManagementSystemV2;

-- ---------------------------------------------------------------------------
-- 3.1  Location
-- Normalized location entity; eliminates redundant lat/lng + text in
-- RideRequest.
-- ---------------------------------------------------------------------------
CREATE TABLE Location (
    LocationId  INT             AUTO_INCREMENT PRIMARY KEY,
    Latitude    DECIMAL(10, 6)  NOT NULL,
    Longitude   DECIMAL(10, 6)  NOT NULL,
    Address     VARCHAR(255)    NOT NULL,
    City        VARCHAR(100)    NULL,
    State       VARCHAR(100)    NULL,
    ZipCode     VARCHAR(20)     NULL,
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_location_city (City),
    INDEX idx_location_coords (Latitude, Longitude)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 3.2  Service
-- Vehicle maintenance service providers.
-- ---------------------------------------------------------------------------
CREATE TABLE Service (
    ServiceId          INT           AUTO_INCREMENT PRIMARY KEY,
    ServiceCompanyName VARCHAR(100)  NOT NULL,
    ServiceName        VARCHAR(100)  NOT NULL,
    ServiceDetails     VARCHAR(500)  NULL,
    IsActive           TINYINT(1)    NOT NULL DEFAULT 1,
    created_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_service_name_company (ServiceName, ServiceCompanyName)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 3.3  Insurance
-- Insurance policies available for vehicles.
-- ---------------------------------------------------------------------------
CREATE TABLE Insurance (
    InsuranceId         INT            AUTO_INCREMENT PRIMARY KEY,
    InsuranceProvider   VARCHAR(100)   NOT NULL,
    InsuranceCoverage   VARCHAR(500)   NOT NULL,
    InsurancePremium    DECIMAL(10, 2) NOT NULL,
    InsuranceDeductible DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    IsActive            TINYINT(1)     NOT NULL DEFAULT 1,
    created_at          DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_insurance_provider (InsuranceProvider),
    CONSTRAINT chk_premium_positive CHECK (InsurancePremium >= 0),
    CONSTRAINT chk_deductible_positive CHECK (InsuranceDeductible >= 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 3.4  Vehicle
-- Fleet vehicles.  VehicleTypeId references the lookup table instead of a
-- free-form VARCHAR.  The old CHAR(1) InsuranceInfo flag is replaced by
-- the InsuranceLogs junction table (see below).
-- ---------------------------------------------------------------------------
CREATE TABLE Vehicle (
    VehicleId       INT           AUTO_INCREMENT PRIMARY KEY,
    VehicleTypeId   INT           NOT NULL,
    LicensePlate    VARCHAR(20)   NOT NULL,
    Make            VARCHAR(50)   NULL,
    Model           VARCHAR(50)   NULL,
    Year            SMALLINT      NULL,
    Color           VARCHAR(30)   NULL,
    IsActive        TINYINT(1)    NOT NULL DEFAULT 1,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_vehicle_license (LicensePlate),
    FOREIGN KEY (VehicleTypeId) REFERENCES VehicleTypeLookup(VehicleTypeId)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_vehicle_type (VehicleTypeId)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 3.5  AppUser  (renamed from "User" to avoid reserved-word issues)
-- Base user entity for both Customers and Drivers.
-- BankAccInfo removed — sensitive data should never be stored as plaintext.
-- ---------------------------------------------------------------------------
CREATE TABLE AppUser (
    UserID       INT           AUTO_INCREMENT PRIMARY KEY,
    UserFName    VARCHAR(50)   NOT NULL,
    UserLName    VARCHAR(50)   NOT NULL,
    PhoneNumber  VARCHAR(15)   NOT NULL,
    EmailId      VARCHAR(255)  NOT NULL,
    DOB          DATE          NULL,
    UserTypeId   INT           NOT NULL,
    IsActive     TINYINT(1)    NOT NULL DEFAULT 1,
    created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_appuser_email (EmailId),
    UNIQUE KEY uk_appuser_phone (PhoneNumber),
    FOREIGN KEY (UserTypeId) REFERENCES UserTypeLookup(UserTypeId)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_appuser_type (UserTypeId),
    INDEX idx_appuser_name (UserLName, UserFName)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 3.6  Customer
-- Extends AppUser for ride-requesting users.
-- Encrypted payment info stored as VARBINARY; encryption key is NOT
-- hardcoded — it must be supplied by the application layer or a key vault.
-- ---------------------------------------------------------------------------
CREATE TABLE Customer (
    CustomerID           INT          AUTO_INCREMENT PRIMARY KEY,
    UserID               INT          NOT NULL,
    EncryptedPaymentInfo VARBINARY(512) NULL COMMENT 'AES-256 encrypted; key managed externally',
    LoyaltyPoints        INT          NOT NULL DEFAULT 0,
    created_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_customer_user (UserID),
    FOREIGN KEY (UserID) REFERENCES AppUser(UserID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_loyalty_nonneg CHECK (LoyaltyPoints >= 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 3.7  PaymentMethod  (renamed from PaymentInformation; now has a PK)
-- Stores tokenised / encrypted payment instruments per customer.
-- ---------------------------------------------------------------------------
CREATE TABLE PaymentMethod (
    PaymentMethodId       INT            AUTO_INCREMENT PRIMARY KEY,
    CustomerID            INT            NOT NULL,
    MethodType            VARCHAR(30)    NOT NULL COMMENT 'e.g. CreditCard, DebitCard, UPI, Wallet',
    EncryptedPaymentToken VARBINARY(512) NOT NULL COMMENT 'Tokenised by payment gateway',
    IsDefault             TINYINT(1)     NOT NULL DEFAULT 0,
    IsActive              TINYINT(1)     NOT NULL DEFAULT 1,
    created_at            DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_payment_customer (CustomerID)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 3.8  Driver
-- Extends AppUser for driving users.
-- ---------------------------------------------------------------------------
CREATE TABLE Driver (
    DriverID    INT           AUTO_INCREMENT PRIMARY KEY,
    UserID      INT           NOT NULL,
    VehicleID   INT           NOT NULL,
    LicenseInfo VARCHAR(255)  NOT NULL,
    IsActive    TINYINT(1)    NOT NULL DEFAULT 1,
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_driver_user (UserID),
    UNIQUE KEY uk_driver_license (LicenseInfo),
    FOREIGN KEY (UserID) REFERENCES AppUser(UserID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleId)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_driver_vehicle (VehicleID)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 3.9  InsuranceLogs  (now has a proper PK + date constraint)
-- Junction between Vehicle and Insurance with validity period.
-- ---------------------------------------------------------------------------
CREATE TABLE InsuranceLogs (
    InsuranceLogId     INT     AUTO_INCREMENT PRIMARY KEY,
    VehicleID          INT     NOT NULL,
    InsuranceId        INT     NOT NULL,
    InsuranceStartDate DATE    NOT NULL,
    InsuranceEndDate   DATE    NOT NULL,
    created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleId)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (InsuranceId) REFERENCES Insurance(InsuranceId)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_insurancelog_vehicle (VehicleID),
    INDEX idx_insurancelog_insurance (InsuranceId),
    CONSTRAINT chk_insurance_dates CHECK (InsuranceEndDate > InsuranceStartDate)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 3.10  Feedback  (FLOAT → DECIMAL; added timestamp)
-- ---------------------------------------------------------------------------
CREATE TABLE Feedback (
    FeedbackID  INT            AUTO_INCREMENT PRIMARY KEY,
    CustomerID  INT            NOT NULL,
    DriverID    INT            NOT NULL,
    Message     VARCHAR(2000)  NOT NULL,
    Rating      DECIMAL(2, 1)  NOT NULL DEFAULT 0.0,
    created_at  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_feedback_customer (CustomerID),
    INDEX idx_feedback_driver (DriverID),
    CONSTRAINT chk_rating_range CHECK (Rating BETWEEN 0.0 AND 5.0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 3.11  TripEstimate
-- CurrentTime renamed to EstimatedAt to avoid reserved-word clash.
-- ---------------------------------------------------------------------------
CREATE TABLE TripEstimate (
    EstimationId INT            AUTO_INCREMENT PRIMARY KEY,
    VehicleID    INT            NOT NULL,
    EstimatedAt  DATETIME       NOT NULL,
    Cost         DECIMAL(10, 2) NOT NULL,
    created_at   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleId)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_tripest_vehicle (VehicleID),
    CONSTRAINT chk_cost_positive CHECK (Cost >= 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 3.12  RideRequest
-- KEY CHANGES:
--   • Lat/lng + text → FK to Location (PickUpLocationId, DestLocationId)
--   • TripType VARCHAR → FK to TripTypeLookup
--   • RequestType VARCHAR → FK to RequestTypeLookup
--   • TripCompletionFlag TINYINT → FK to RideStatusLookup
--   • All FKs are NOT NULL
-- ---------------------------------------------------------------------------
CREATE TABLE RideRequest (
    RequestId          INT      AUTO_INCREMENT PRIMARY KEY,
    EstimationID       INT      NOT NULL,
    VehicleID          INT      NOT NULL,
    DriverID           INT      NOT NULL,
    CustomerID         INT      NOT NULL,
    RequestTypeId      INT      NOT NULL,
    TripTypeId         INT      NOT NULL,
    RideStatusId       INT      NOT NULL,
    PickUpLocationId   INT      NOT NULL,
    DestLocationId     INT      NOT NULL,
    ReqDateTime        DATETIME NOT NULL,
    created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (EstimationID) REFERENCES TripEstimate(EstimationId)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleId)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (RequestTypeId) REFERENCES RequestTypeLookup(RequestTypeId)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (TripTypeId) REFERENCES TripTypeLookup(TripTypeId)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (RideStatusId) REFERENCES RideStatusLookup(RideStatusId)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (PickUpLocationId) REFERENCES Location(LocationId)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (DestLocationId) REFERENCES Location(LocationId)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_ride_customer (CustomerID),
    INDEX idx_ride_driver (DriverID),
    INDEX idx_ride_datetime (ReqDateTime),
    INDEX idx_ride_status (RideStatusId),
    INDEX idx_ride_customer_date (CustomerID, ReqDateTime),
    INDEX idx_ride_driver_date (DriverID, ReqDateTime)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 3.13  ServiceRequest
-- PreviousServiceDate removed — this is derivable from past records.
-- ---------------------------------------------------------------------------
CREATE TABLE ServiceRequest (
    SerReqId       INT      AUTO_INCREMENT PRIMARY KEY,
    VehicleId      INT      NOT NULL,
    ServiceId      INT      NOT NULL,
    ReqDateTime    DATETIME NOT NULL,
    ServiceDueDate DATE     NOT NULL,
    Notes          VARCHAR(500) NULL,
    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (VehicleId) REFERENCES Vehicle(VehicleId)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (ServiceId) REFERENCES Service(ServiceId)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_serreq_vehicle (VehicleId),
    INDEX idx_serreq_service (ServiceId),
    INDEX idx_serreq_duedate (ServiceDueDate)
) ENGINE=InnoDB;
