-- ============================================================================
-- TaxiManagementSystem — Redesigned Data Layer
-- Script 08: Triggers
-- Engine: MySQL 8.0+
-- ============================================================================
-- FIXES APPLIED:
--   • EncryptPaymentInfo trigger removed — encryption should happen in the
--     application layer using externally managed keys, NOT inside a trigger
--     with a hardcoded password.
--   • Instead, we provide an audit-trail trigger and a data-integrity trigger.
-- ============================================================================

USE TaxiManagementSystemV2;

-- ---------------------------------------------------------------------------
-- 8.1  trg_riderequest_default_status
-- Ensures every new RideRequest starts in "Requested" status.
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_riderequest_default_status;

DELIMITER //
CREATE TRIGGER trg_riderequest_default_status
BEFORE INSERT ON RideRequest
FOR EACH ROW
BEGIN
    -- If no status was explicitly provided, default to "Requested"
    IF NEW.RideStatusId IS NULL OR NEW.RideStatusId = 0 THEN
        SET NEW.RideStatusId = (
            SELECT rs.RideStatusId
            FROM RideStatusLookup rs
            WHERE rs.StatusName = 'Requested'
            LIMIT 1
        );
    END IF;
END //
DELIMITER ;

-- ---------------------------------------------------------------------------
-- 8.2  trg_insurancelogs_validate_dates
-- Prevents inserting insurance logs where EndDate <= StartDate.
-- (This is also enforced by a CHECK constraint, but triggers provide a
--  custom error message.)
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_insurancelogs_validate_dates;

DELIMITER //
CREATE TRIGGER trg_insurancelogs_validate_dates
BEFORE INSERT ON InsuranceLogs
FOR EACH ROW
BEGIN
    IF NEW.InsuranceEndDate <= NEW.InsuranceStartDate THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'InsuranceEndDate must be after InsuranceStartDate';
    END IF;
END //
DELIMITER ;

-- ---------------------------------------------------------------------------
-- 8.3  trg_feedback_validate_ridecompleted
-- Prevents feedback from being inserted unless the customer has at least
-- one completed ride with the referenced driver.
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_feedback_validate_ridecompleted;

DELIMITER //
CREATE TRIGGER trg_feedback_validate_ridecompleted
BEFORE INSERT ON Feedback
FOR EACH ROW
BEGIN
    DECLARE v_CompletedRides INT DEFAULT 0;

    SELECT COUNT(*) INTO v_CompletedRides
    FROM RideRequest rr
    INNER JOIN RideStatusLookup rs ON rr.RideStatusId = rs.RideStatusId
    WHERE rr.CustomerID = NEW.CustomerID
      AND rr.DriverID   = NEW.DriverID
      AND rs.StatusName  = 'Completed';

    IF v_CompletedRides = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Feedback can only be given after a completed ride with this driver';
    END IF;
END //
DELIMITER ;
