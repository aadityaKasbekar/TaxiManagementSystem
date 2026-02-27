-- ============================================================================
-- TaxiManagementSystem — Redesigned Data Layer
-- Script 02: Lookup / Reference Tables
-- Engine: MySQL 8.0+
-- ============================================================================
-- These small tables replace free-form VARCHAR columns with referential
-- integrity. They should be loaded first because core tables reference them.
-- ============================================================================

USE TaxiManagementSystemV2;

-- ---------------------------------------------------------------------------
-- 2.1  Vehicle Type Lookup
-- Replaces: Vehicle.VehicleType VARCHAR(50)
-- ---------------------------------------------------------------------------
CREATE TABLE VehicleTypeLookup (
    VehicleTypeId   INT           AUTO_INCREMENT PRIMARY KEY,
    VehicleTypeName VARCHAR(50)   NOT NULL UNIQUE,
    Description     VARCHAR(255)  NULL,
    IsActive        TINYINT(1)    NOT NULL DEFAULT 1,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 2.2  Trip Type Lookup
-- Replaces: RideRequest.TripType VARCHAR(50) CHECK (...)
-- ---------------------------------------------------------------------------
CREATE TABLE TripTypeLookup (
    TripTypeId   INT           AUTO_INCREMENT PRIMARY KEY,
    TripTypeName VARCHAR(50)   NOT NULL UNIQUE,
    Description  VARCHAR(255)  NULL,
    IsActive     TINYINT(1)    NOT NULL DEFAULT 1,
    created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 2.3  Request Type Lookup
-- Replaces: RideRequest.RequestType VARCHAR(50)
-- ---------------------------------------------------------------------------
CREATE TABLE RequestTypeLookup (
    RequestTypeId   INT           AUTO_INCREMENT PRIMARY KEY,
    RequestTypeName VARCHAR(50)   NOT NULL UNIQUE,
    Description     VARCHAR(255)  NULL,
    IsActive        TINYINT(1)    NOT NULL DEFAULT 1,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 2.4  Ride Status Lookup
-- Replaces: RideRequest.TripCompletionFlag TINYINT(1)
-- Provides meaningful lifecycle states instead of 0/1.
-- ---------------------------------------------------------------------------
CREATE TABLE RideStatusLookup (
    RideStatusId   INT           AUTO_INCREMENT PRIMARY KEY,
    StatusName     VARCHAR(30)   NOT NULL UNIQUE,
    Description    VARCHAR(255)  NULL,
    DisplayOrder   INT           NOT NULL DEFAULT 0,
    IsActive       TINYINT(1)    NOT NULL DEFAULT 1,
    created_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------------
-- 2.5  User Type Lookup
-- Replaces: User.UserType CHAR(1) CHECK (...)
-- ---------------------------------------------------------------------------
CREATE TABLE UserTypeLookup (
    UserTypeId   INT           AUTO_INCREMENT PRIMARY KEY,
    UserTypeCode CHAR(1)       NOT NULL UNIQUE,
    UserTypeName VARCHAR(30)   NOT NULL UNIQUE,
    Description  VARCHAR(255)  NULL,
    IsActive     TINYINT(1)    NOT NULL DEFAULT 1,
    created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================================
-- Seed the lookup tables with initial reference data
-- ============================================================================

INSERT INTO VehicleTypeLookup (VehicleTypeName, Description) VALUES
    ('Sedan',       'Standard 4-door sedan'),
    ('SUV',         'Sport Utility Vehicle'),
    ('Hatchback',   'Compact hatchback'),
    ('Minivan',     'Passenger minivan'),
    ('Luxury',      'Premium luxury vehicle'),
    ('Electric',    'Electric / hybrid vehicle');

INSERT INTO TripTypeLookup (TripTypeName, Description) VALUES
    ('City Cab',        'Intra-city ride'),
    ('Out Station Cab', 'Inter-city / outstation ride');

INSERT INTO RequestTypeLookup (RequestTypeName, Description) VALUES
    ('Immediate',  'On-demand ride request'),
    ('Scheduled',  'Pre-scheduled ride request'),
    ('Recurring',  'Recurring / subscription ride');

INSERT INTO RideStatusLookup (StatusName, Description, DisplayOrder) VALUES
    ('Requested',   'Ride requested by customer',            1),
    ('Accepted',    'Ride accepted by a driver',             2),
    ('InProgress',  'Ride is currently in progress',         3),
    ('Completed',   'Ride completed successfully',           4),
    ('Cancelled',   'Ride cancelled by customer or driver',  5),
    ('NoShow',      'Customer did not show up',              6);

INSERT INTO UserTypeLookup (UserTypeCode, UserTypeName, Description) VALUES
    ('D', 'Driver',   'A user who drives vehicles'),
    ('C', 'Customer', 'A user who requests rides');
