-- ============================================================================
-- TaxiManagementSystem — Redesigned Data Layer
-- Script 10: Schema Validation
-- Engine: MySQL 8.0+
-- ============================================================================
-- Run this script after executing scripts 01–09 to verify that the schema
-- was created correctly. Each query should return expected results.
-- ============================================================================

USE TaxiManagementSystemV2;

-- ---------------------------------------------------------------------------
-- 10.1  Verify all expected tables exist
-- ---------------------------------------------------------------------------
SELECT
    'TABLE CHECK' AS CheckType,
    TABLE_NAME,
    CASE
        WHEN TABLE_NAME IS NOT NULL THEN '✓  EXISTS'
        ELSE '✗  MISSING'
    END AS Status
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'TaxiManagementSystemV2'
  AND TABLE_NAME IN (
      'VehicleTypeLookup', 'TripTypeLookup', 'RequestTypeLookup',
      'RideStatusLookup', 'UserTypeLookup',
      'Location', 'Service', 'Insurance', 'Vehicle', 'AppUser',
      'Customer', 'PaymentMethod', 'Driver', 'InsuranceLogs',
      'Feedback', 'TripEstimate', 'RideRequest', 'ServiceRequest'
  )
ORDER BY TABLE_NAME;

-- ---------------------------------------------------------------------------
-- 10.2  Verify every table has a PRIMARY KEY
-- ---------------------------------------------------------------------------
SELECT
    'PK CHECK' AS CheckType,
    t.TABLE_NAME,
    CASE
        WHEN kcu.COLUMN_NAME IS NOT NULL THEN CONCAT('✓  PK = ', kcu.COLUMN_NAME)
        ELSE '✗  NO PRIMARY KEY'
    END AS Status
FROM INFORMATION_SCHEMA.TABLES t
LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    ON t.TABLE_NAME = tc.TABLE_NAME
    AND t.TABLE_SCHEMA = tc.TABLE_SCHEMA
    AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
    AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA
    AND tc.TABLE_NAME = kcu.TABLE_NAME
WHERE t.TABLE_SCHEMA = 'TaxiManagementSystemV2'
  AND t.TABLE_TYPE = 'BASE TABLE'
ORDER BY t.TABLE_NAME;

-- ---------------------------------------------------------------------------
-- 10.3  Verify UNIQUE constraints exist on critical columns
-- ---------------------------------------------------------------------------
SELECT
    'UNIQUE CHECK' AS CheckType,
    tc.TABLE_NAME,
    GROUP_CONCAT(kcu.COLUMN_NAME ORDER BY kcu.ORDINAL_POSITION) AS UniqueColumns
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
    AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA
WHERE tc.TABLE_SCHEMA = 'TaxiManagementSystemV2'
  AND tc.CONSTRAINT_TYPE = 'UNIQUE'
GROUP BY tc.TABLE_NAME, tc.CONSTRAINT_NAME
ORDER BY tc.TABLE_NAME;

-- ---------------------------------------------------------------------------
-- 10.4  Verify all tables have audit columns (created_at, updated_at)
-- ---------------------------------------------------------------------------
SELECT
    'AUDIT COLS CHECK' AS CheckType,
    t.TABLE_NAME,
    CASE
        WHEN SUM(c.COLUMN_NAME = 'created_at') > 0
         AND SUM(c.COLUMN_NAME = 'updated_at') > 0
        THEN '✓  Both present'
        WHEN SUM(c.COLUMN_NAME = 'created_at') > 0
        THEN '⚠  Only created_at'
        WHEN SUM(c.COLUMN_NAME = 'updated_at') > 0
        THEN '⚠  Only updated_at'
        ELSE '✗  Missing audit columns'
    END AS Status
FROM INFORMATION_SCHEMA.TABLES t
LEFT JOIN INFORMATION_SCHEMA.COLUMNS c
    ON t.TABLE_NAME = c.TABLE_NAME
    AND t.TABLE_SCHEMA = c.TABLE_SCHEMA
    AND c.COLUMN_NAME IN ('created_at', 'updated_at')
WHERE t.TABLE_SCHEMA = 'TaxiManagementSystemV2'
  AND t.TABLE_TYPE = 'BASE TABLE'
GROUP BY t.TABLE_NAME
ORDER BY t.TABLE_NAME;

-- ---------------------------------------------------------------------------
-- 10.5  Count indexes per table
-- ---------------------------------------------------------------------------
SELECT
    'INDEX COUNT' AS CheckType,
    TABLE_NAME,
    COUNT(DISTINCT INDEX_NAME) AS IndexCount
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'TaxiManagementSystemV2'
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME;

-- ---------------------------------------------------------------------------
-- 10.6  Verify foreign key relationships
-- ---------------------------------------------------------------------------
SELECT
    'FK CHECK' AS CheckType,
    kcu.TABLE_NAME     AS ChildTable,
    kcu.COLUMN_NAME    AS FKColumn,
    kcu.REFERENCED_TABLE_NAME  AS ParentTable,
    kcu.REFERENCED_COLUMN_NAME AS ParentColumn
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
WHERE kcu.TABLE_SCHEMA = 'TaxiManagementSystemV2'
  AND kcu.REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY kcu.TABLE_NAME, kcu.COLUMN_NAME;

-- ---------------------------------------------------------------------------
-- 10.7  Verify NOT NULL constraints on mandatory FK columns
-- ---------------------------------------------------------------------------
SELECT
    'NOT NULL FK CHECK' AS CheckType,
    c.TABLE_NAME,
    c.COLUMN_NAME,
    c.IS_NULLABLE,
    CASE
        WHEN c.IS_NULLABLE = 'NO' THEN '✓  NOT NULL'
        ELSE '⚠  NULLABLE FK'
    END AS Status
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
JOIN INFORMATION_SCHEMA.COLUMNS c
    ON kcu.TABLE_NAME = c.TABLE_NAME
    AND kcu.COLUMN_NAME = c.COLUMN_NAME
    AND kcu.TABLE_SCHEMA = c.TABLE_SCHEMA
WHERE kcu.TABLE_SCHEMA = 'TaxiManagementSystemV2'
  AND kcu.REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY c.TABLE_NAME, c.COLUMN_NAME;

-- ---------------------------------------------------------------------------
-- 10.8  Verify seed data was loaded
-- ---------------------------------------------------------------------------
SELECT 'SEED DATA CHECK' AS CheckType, 'VehicleTypeLookup'  AS TableName, COUNT(*) AS RowCount FROM VehicleTypeLookup
UNION ALL SELECT '', 'TripTypeLookup',    COUNT(*) FROM TripTypeLookup
UNION ALL SELECT '', 'RequestTypeLookup', COUNT(*) FROM RequestTypeLookup
UNION ALL SELECT '', 'RideStatusLookup',  COUNT(*) FROM RideStatusLookup
UNION ALL SELECT '', 'UserTypeLookup',    COUNT(*) FROM UserTypeLookup
UNION ALL SELECT '', 'Location',          COUNT(*) FROM Location
UNION ALL SELECT '', 'Service',           COUNT(*) FROM Service
UNION ALL SELECT '', 'Insurance',         COUNT(*) FROM Insurance
UNION ALL SELECT '', 'Vehicle',           COUNT(*) FROM Vehicle
UNION ALL SELECT '', 'AppUser',           COUNT(*) FROM AppUser
UNION ALL SELECT '', 'Customer',          COUNT(*) FROM Customer
UNION ALL SELECT '', 'Driver',            COUNT(*) FROM Driver
UNION ALL SELECT '', 'InsuranceLogs',     COUNT(*) FROM InsuranceLogs
UNION ALL SELECT '', 'TripEstimate',      COUNT(*) FROM TripEstimate
UNION ALL SELECT '', 'RideRequest',       COUNT(*) FROM RideRequest
UNION ALL SELECT '', 'Feedback',          COUNT(*) FROM Feedback
UNION ALL SELECT '', 'ServiceRequest',    COUNT(*) FROM ServiceRequest
UNION ALL SELECT '', 'PaymentMethod',     COUNT(*) FROM PaymentMethod;

-- ---------------------------------------------------------------------------
-- 10.9  Smoke-test the views
-- ---------------------------------------------------------------------------
SELECT 'VIEW SMOKE TEST' AS CheckType, 'CustomerRideHistoryView' AS ViewName;
SELECT * FROM CustomerRideHistoryView ORDER BY TotalRideSpend DESC LIMIT 5;

SELECT 'VIEW SMOKE TEST' AS CheckType, 'ServiceRequestDetailsView' AS ViewName;
SELECT * FROM ServiceRequestDetailsView LIMIT 5;

SELECT 'VIEW SMOKE TEST' AS CheckType, 'VehicleRequestedView' AS ViewName;
SELECT * FROM VehicleRequestedView;

SELECT 'VIEW SMOKE TEST' AS CheckType, 'DriverPerformanceView' AS ViewName;
SELECT * FROM DriverPerformanceView ORDER BY AverageRating DESC;

SELECT 'VIEW SMOKE TEST' AS CheckType, 'ActiveInsuranceView' AS ViewName;
SELECT * FROM ActiveInsuranceView;

-- ---------------------------------------------------------------------------
-- 10.10  Smoke-test the stored procedures
-- ---------------------------------------------------------------------------
CALL GetDriverStatistics(1);
CALL GetUpcomingServiceRequests();
CALL CalculateCustomerLoyaltyDiscount(1);
CALL GetRideHistory(1);

-- ---------------------------------------------------------------------------
-- 10.11  Smoke-test the UDFs
-- ---------------------------------------------------------------------------
SELECT 'UDF TEST' AS CheckType, 'ServiceDueinDays' AS FunctionName,
       ServiceDueinDays('2026-06-01', '2025-12-01') AS DaysRemaining;

SELECT 'UDF TEST' AS CheckType, 'CustomerCategory' AS FunctionName,
       CustomerCategory(1) AS Category;

SELECT 'UDF TEST' AS CheckType, 'CalculateEstimatedArrival' AS FunctionName,
       CalculateEstimatedArrival(42.3601, -71.0589, 42.3554, -71.0655, 30.0) AS EstimatedMinutes;
