-- ============================================================================
-- TaxiManagementSystem — Redesigned Data Layer
-- Script 09: Seed Data (Sample INSERT Statements)
-- Engine: MySQL 8.0+
-- ============================================================================
-- NOTE: Lookup table seeds are in 02_lookup_tables.sql.
--       This script provides sample entity data for testing.
--       Encryption keys are NOT included — use application-layer encryption.
-- ============================================================================

USE TaxiManagementSystemV2;

-- ---------------------------------------------------------------------------
-- Locations
-- ---------------------------------------------------------------------------
INSERT INTO Location (Latitude, Longitude, Address, City, State, ZipCode) VALUES
    (42.3601, -71.0589, '100 Federal St',       'Boston',     'MA', '02110'),
    (42.3554, -71.0655, '700 Boylston St',      'Boston',     'MA', '02116'),
    (42.3662, -71.0621, '1 Beacon St',          'Boston',     'MA', '02108'),
    (42.3736, -71.1097, '300 Western Ave',      'Allston',    'MA', '02134'),
    (42.3496, -71.0783, '360 Huntington Ave',   'Boston',     'MA', '02115'),
    (42.3467, -71.0972, '1175 Tremont St',      'Boston',     'MA', '02120'),
    (42.3519, -71.0552, '1 Congress St',        'Boston',     'MA', '02114'),
    (42.3384, -71.0885, '75 Francis St',        'Boston',     'MA', '02115'),
    (42.3600, -71.0580, '250 Newbury St',       'Boston',     'MA', '02116'),
    (42.3350, -71.1040, '750 Washington St',    'Brookline',  'MA', '02446');

-- ---------------------------------------------------------------------------
-- Services
-- ---------------------------------------------------------------------------
INSERT INTO Service (ServiceCompanyName, ServiceName, ServiceDetails) VALUES
    ('AutoCare Plus',      'Oil Change',          'Full synthetic oil change with filter replacement'),
    ('AutoCare Plus',      'Tire Rotation',       'Rotate all four tires and check pressure'),
    ('QuickFix Garage',    'Brake Inspection',    'Inspect brake pads, rotors, and fluid'),
    ('QuickFix Garage',    'Battery Check',       'Test battery charge and terminal condition'),
    ('PremiumAuto Service','Full Inspection',      'Comprehensive 50-point vehicle inspection'),
    ('PremiumAuto Service','AC Service',           'Refrigerant recharge and system check'),
    ('SpeedyLube',         'Transmission Service', 'Fluid flush and filter replacement'),
    ('SpeedyLube',         'Wheel Alignment',      'Four-wheel alignment calibration');

-- ---------------------------------------------------------------------------
-- Insurance Providers
-- ---------------------------------------------------------------------------
INSERT INTO Insurance (InsuranceProvider, InsuranceCoverage, InsurancePremium, InsuranceDeductible) VALUES
    ('Geico',           'Comprehensive + Collision',      450.00, 500.00),
    ('Progressive',     'Liability Only',                 250.00, 1000.00),
    ('State Farm',      'Comprehensive + Collision + Gap', 600.00, 250.00),
    ('Allstate',        'Full Coverage',                  550.00, 500.00),
    ('USAA',            'Full Coverage + Roadside',       500.00, 300.00);

-- ---------------------------------------------------------------------------
-- Vehicles
-- ---------------------------------------------------------------------------
INSERT INTO Vehicle (VehicleTypeId, LicensePlate, Make, Model, Year, Color) VALUES
    (1, 'MA-1234', 'Toyota',  'Camry',    2022, 'White'),
    (2, 'MA-5678', 'Ford',    'Explorer', 2023, 'Black'),
    (3, 'MA-9012', 'Honda',   'Civic',    2021, 'Silver'),
    (1, 'MA-3456', 'Hyundai', 'Sonata',   2023, 'Blue'),
    (4, 'MA-7890', 'Chrysler','Pacifica',  2022, 'Gray'),
    (5, 'MA-2345', 'BMW',     '5 Series', 2024, 'Black'),
    (6, 'MA-6789', 'Tesla',   'Model 3',  2024, 'White'),
    (1, 'MA-0123', 'Nissan',  'Altima',   2021, 'Red'),
    (2, 'MA-4567', 'Chevy',   'Tahoe',    2023, 'White'),
    (3, 'MA-8901', 'Mazda',   'Mazda3',   2022, 'Gray');

-- ---------------------------------------------------------------------------
-- AppUser (Drivers)
-- ---------------------------------------------------------------------------
INSERT INTO AppUser (UserFName, UserLName, PhoneNumber, EmailId, DOB, UserTypeId) VALUES
    ('John',     'Smith',     '617-555-0101', 'john.smith@email.com',     '1990-03-15', (SELECT UserTypeId FROM UserTypeLookup WHERE UserTypeCode = 'D')),
    ('Sarah',    'Johnson',   '617-555-0102', 'sarah.johnson@email.com',  '1985-07-22', (SELECT UserTypeId FROM UserTypeLookup WHERE UserTypeCode = 'D')),
    ('Michael',  'Williams',  '617-555-0103', 'michael.w@email.com',      '1992-11-08', (SELECT UserTypeId FROM UserTypeLookup WHERE UserTypeCode = 'D')),
    ('Emily',    'Brown',     '617-555-0104', 'emily.brown@email.com',    '1988-01-30', (SELECT UserTypeId FROM UserTypeLookup WHERE UserTypeCode = 'D')),
    ('David',    'Davis',     '617-555-0105', 'david.davis@email.com',    '1995-05-12', (SELECT UserTypeId FROM UserTypeLookup WHERE UserTypeCode = 'D'));

-- ---------------------------------------------------------------------------
-- AppUser (Customers)
-- ---------------------------------------------------------------------------
INSERT INTO AppUser (UserFName, UserLName, PhoneNumber, EmailId, DOB, UserTypeId) VALUES
    ('Alice',    'Martinez',  '617-555-0201', 'alice.m@email.com',        '1998-09-05', (SELECT UserTypeId FROM UserTypeLookup WHERE UserTypeCode = 'C')),
    ('Bob',      'Garcia',    '617-555-0202', 'bob.garcia@email.com',     '1975-12-20', (SELECT UserTypeId FROM UserTypeLookup WHERE UserTypeCode = 'C')),
    ('Carol',    'Anderson',  '617-555-0203', 'carol.anderson@email.com', '2000-04-18', (SELECT UserTypeId FROM UserTypeLookup WHERE UserTypeCode = 'C')),
    ('Dan',      'Thomas',    '617-555-0204', 'dan.thomas@email.com',     '1960-08-25', (SELECT UserTypeId FROM UserTypeLookup WHERE UserTypeCode = 'C')),
    ('Eve',      'Jackson',   '617-555-0205', 'eve.jackson@email.com',    '1993-02-14', (SELECT UserTypeId FROM UserTypeLookup WHERE UserTypeCode = 'C'));

-- ---------------------------------------------------------------------------
-- Customers (linking to AppUser)
-- ---------------------------------------------------------------------------
INSERT INTO Customer (UserID) VALUES
    (6), (7), (8), (9), (10);

-- ---------------------------------------------------------------------------
-- Drivers (linking to AppUser + Vehicle)
-- ---------------------------------------------------------------------------
INSERT INTO Driver (UserID, VehicleID, LicenseInfo) VALUES
    (1, 1, 'DL-MA-100001'),
    (2, 2, 'DL-MA-100002'),
    (3, 3, 'DL-MA-100003'),
    (4, 4, 'DL-MA-100004'),
    (5, 5, 'DL-MA-100005');

-- ---------------------------------------------------------------------------
-- Insurance Logs
-- ---------------------------------------------------------------------------
INSERT INTO InsuranceLogs (VehicleID, InsuranceId, InsuranceStartDate, InsuranceEndDate) VALUES
    (1, 1, '2025-01-01', '2026-01-01'),
    (2, 3, '2025-03-15', '2026-03-15'),
    (3, 2, '2025-06-01', '2026-06-01'),
    (4, 4, '2025-02-01', '2026-02-01'),
    (5, 5, '2025-04-01', '2026-04-01');

-- ---------------------------------------------------------------------------
-- Trip Estimates
-- ---------------------------------------------------------------------------
INSERT INTO TripEstimate (VehicleID, EstimatedAt, Cost) VALUES
    (1, '2025-12-01 08:30:00', 15.50),
    (2, '2025-12-01 09:00:00', 22.75),
    (3, '2025-12-02 14:15:00', 18.00),
    (4, '2025-12-03 07:45:00', 30.25),
    (5, '2025-12-03 16:30:00', 12.00),
    (1, '2025-12-04 10:00:00', 45.00),
    (2, '2025-12-05 11:30:00', 28.50),
    (3, '2025-12-06 08:00:00', 16.75);

-- ---------------------------------------------------------------------------
-- Ride Requests
-- ---------------------------------------------------------------------------
INSERT INTO RideRequest (EstimationID, VehicleID, DriverID, CustomerID, RequestTypeId, TripTypeId, RideStatusId, PickUpLocationId, DestLocationId, ReqDateTime) VALUES
    (1, 1, 1, 1, 1, 1, 4, 1, 2, '2025-12-01 08:35:00'),
    (2, 2, 2, 2, 1, 1, 4, 3, 4, '2025-12-01 09:05:00'),
    (3, 3, 3, 3, 2, 1, 4, 5, 6, '2025-12-02 14:20:00'),
    (4, 4, 4, 4, 1, 2, 4, 7, 8, '2025-12-03 07:50:00'),
    (5, 5, 5, 5, 1, 1, 5, 9, 10,'2025-12-03 16:35:00'),
    (6, 1, 1, 1, 1, 1, 4, 2, 5, '2025-12-04 10:05:00'),
    (7, 2, 2, 3, 2, 2, 3, 4, 7, '2025-12-05 11:35:00'),
    (8, 3, 3, 2, 1, 1, 4, 6, 1, '2025-12-06 08:05:00');

-- ---------------------------------------------------------------------------
-- Feedback (only for completed rides)
-- ---------------------------------------------------------------------------
INSERT INTO Feedback (CustomerID, DriverID, Message, Rating) VALUES
    (1, 1, 'Great ride, very professional driver!',       4.5),
    (2, 2, 'Arrived on time, clean vehicle.',             4.0),
    (3, 3, 'Smooth ride, though took a longer route.',    3.5),
    (4, 4, 'Excellent service for the outstation trip.',  5.0),
    (1, 1, 'Second ride was equally good.',               4.0),
    (2, 3, 'Good experience, would ride again.',          4.5);

-- ---------------------------------------------------------------------------
-- Service Requests
-- ---------------------------------------------------------------------------
INSERT INTO ServiceRequest (VehicleId, ServiceId, ReqDateTime, ServiceDueDate, Notes) VALUES
    (1, 1, '2025-11-15 10:00:00', '2026-03-15', 'Regular oil change'),
    (2, 3, '2025-11-20 11:00:00', '2026-04-20', 'Annual brake inspection'),
    (3, 5, '2025-12-01 09:00:00', '2026-06-01', 'Full 50-point inspection'),
    (4, 2, '2025-12-05 14:00:00', '2026-03-05', 'Tire rotation due'),
    (5, 4, '2025-12-10 08:00:00', '2026-06-10', 'Battery check before summer');

-- ---------------------------------------------------------------------------
-- Payment Methods (tokens only, no raw card data)
-- ---------------------------------------------------------------------------
INSERT INTO PaymentMethod (CustomerID, MethodType, EncryptedPaymentToken, IsDefault) VALUES
    (1, 'CreditCard', UNHEX(SHA2('tok_visa_4242_alice',    256)), 1),
    (2, 'DebitCard',  UNHEX(SHA2('tok_debit_1234_bob',     256)), 1),
    (3, 'UPI',        UNHEX(SHA2('tok_upi_carol@bank',     256)), 1),
    (4, 'Wallet',     UNHEX(SHA2('tok_wallet_dan_xyz',     256)), 1),
    (5, 'CreditCard', UNHEX(SHA2('tok_visa_5678_eve',      256)), 1);
