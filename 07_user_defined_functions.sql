-- ============================================================================
-- TaxiManagementSystem — Redesigned Data Layer
-- Script 07: User-Defined Functions
-- Engine: MySQL 8.0+
-- ============================================================================
-- FIXES APPLIED:
--   • ServiceDueinDays: DATEDIFF argument order fixed (was reversed,
--     returning negative days). Now returns positive days until due.
--   • CustomerCategory: references AppUser instead of `User`; uses
--     proper JOIN condition.
--   • Both functions use DETERMINISTIC / READS SQL DATA correctly.
-- ============================================================================

USE TaxiManagementSystemV2;

-- ---------------------------------------------------------------------------
-- 7.1  ServiceDueinDays
-- Returns the number of days remaining until a service is due.
-- Positive = days remaining, Negative = overdue.
-- FIX: Original had DATEDIFF(ReqDateTime, ServiceDueDate) which gives
--      a negative number when the due date is in the future.
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS ServiceDueinDays;

DELIMITER //
CREATE FUNCTION ServiceDueinDays(
    p_ServiceDueDate DATE,
    p_ReqDateTime    DATE
)
RETURNS INT
DETERMINISTIC
BEGIN
    -- ServiceDueDate - ReqDateTime = days remaining
    RETURN DATEDIFF(p_ServiceDueDate, p_ReqDateTime);
END //
DELIMITER ;

-- ---------------------------------------------------------------------------
-- 7.2  CustomerCategory
-- Categorises a customer by age group based on their date of birth.
-- FIX: References AppUser; proper JOIN condition using Customer.UserID.
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS CustomerCategory;

DELIMITER //
CREATE FUNCTION CustomerCategory(
    p_CustomerID INT
)
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE v_AgeInYears INT;
    DECLARE v_Category   VARCHAR(20);
    DECLARE v_DOB        DATE;

    -- Retrieve DOB from AppUser via Customer
    SELECT u.DOB INTO v_DOB
    FROM AppUser u
    INNER JOIN Customer c ON u.UserID = c.UserID
    WHERE c.CustomerID = p_CustomerID;

    IF v_DOB IS NULL THEN
        RETURN 'Unknown';
    END IF;

    SET v_AgeInYears = TIMESTAMPDIFF(YEAR, v_DOB, CURDATE());

    SET v_Category = CASE
        WHEN v_AgeInYears < 18               THEN 'Under 18'
        WHEN v_AgeInYears BETWEEN 18 AND 25  THEN 'Young Adult'
        WHEN v_AgeInYears BETWEEN 26 AND 40  THEN 'Adult'
        WHEN v_AgeInYears BETWEEN 41 AND 60  THEN 'Middle Aged'
        ELSE 'Senior Citizen'
    END;

    RETURN v_Category;
END //
DELIMITER ;

-- ---------------------------------------------------------------------------
-- 7.3  CalculateEstimatedArrival  (NEW)
-- Estimates arrival time in minutes based on distance (Haversine) and
-- an average speed assumption.
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS CalculateEstimatedArrival;

DELIMITER //
CREATE FUNCTION CalculateEstimatedArrival(
    p_PickupLat   DECIMAL(10, 6),
    p_PickupLng   DECIMAL(10, 6),
    p_DestLat     DECIMAL(10, 6),
    p_DestLng     DECIMAL(10, 6),
    p_AvgSpeedKmh DECIMAL(5, 1)
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_DistanceKm DECIMAL(10, 2);
    DECLARE v_Minutes    INT;

    -- Haversine formula
    SET v_DistanceKm = 6371 * ACOS(
        LEAST(1.0,
            COS(RADIANS(p_PickupLat)) * COS(RADIANS(p_DestLat)) *
            COS(RADIANS(p_DestLng) - RADIANS(p_PickupLng)) +
            SIN(RADIANS(p_PickupLat)) * SIN(RADIANS(p_DestLat))
        )
    );

    IF p_AvgSpeedKmh <= 0 THEN
        SET p_AvgSpeedKmh = 30.0;  -- sensible default
    END IF;

    SET v_Minutes = CEIL((v_DistanceKm / p_AvgSpeedKmh) * 60);

    RETURN v_Minutes;
END //
DELIMITER ;
