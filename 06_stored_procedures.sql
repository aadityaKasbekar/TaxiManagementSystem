-- ============================================================================
-- TaxiManagementSystem — Redesigned Data Layer
-- Script 06: Stored Procedures
-- Engine: MySQL 8.0+
-- ============================================================================
-- FIXES APPLIED:
--   • All reference AppUser instead of `User`
--   • DecryptPaymentInfo: NO hardcoded key — key is passed as a parameter
--   • GetUpcomingServiceRequests: fixed the bogus VehicleId = UserID JOIN
--   • GetDriverStatistics: uses proper LEFT JOINs
--   • CalculateCustomerLoyaltyDiscount: unchanged logic, cleaner syntax
-- ============================================================================

USE TaxiManagementSystemV2;

-- ---------------------------------------------------------------------------
-- 6.1  GetDriverStatistics
-- Retrieve aggregate statistics for a specific driver.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS GetDriverStatistics;

DELIMITER //
CREATE PROCEDURE GetDriverStatistics(IN p_DriverId INT)
BEGIN
    SELECT
        d.DriverID,
        CONCAT(u.UserFName, ' ', u.UserLName) AS DriverName,
        COUNT(DISTINCT rr.RequestId)           AS TotalTrips,
        COALESCE(AVG(f.Rating), 0)             AS AverageFeedbackRating,
        MAX(rr.ReqDateTime)                    AS LatestTripDateTime,
        (
            SELECT loc.Address
            FROM RideRequest rr2
            INNER JOIN Location loc ON rr2.DestLocationId = loc.LocationId
            WHERE rr2.DriverID = d.DriverID
            ORDER BY rr2.ReqDateTime DESC
            LIMIT 1
        )                                      AS LatestTripDestination
    FROM
        Driver d
        INNER JOIN AppUser u         ON d.UserID = u.UserID
        LEFT  JOIN RideRequest rr    ON d.DriverID = rr.DriverID
        LEFT  JOIN Feedback f        ON d.DriverID = f.DriverID
    WHERE
        d.DriverID = p_DriverId
    GROUP BY
        d.DriverID, u.UserFName, u.UserLName;
END //
DELIMITER ;

-- ---------------------------------------------------------------------------
-- 6.2  GetUpcomingServiceRequests  (FIXED JOIN)
-- Retrieve service requests with a due date in the future.
-- Old version joined Vehicle.VehicleId = User.UserID (bug).
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS GetUpcomingServiceRequests;

DELIMITER //
CREATE PROCEDURE GetUpcomingServiceRequests()
BEGIN
    SELECT
        sr.SerReqId,
        vt.VehicleTypeName                     AS VehicleType,
        v.LicensePlate,
        CONCAT(u.UserFName, ' ', u.UserLName)  AS DriverName,
        sr.ReqDateTime                          AS RequestDateTime,
        sr.ServiceDueDate                       AS DueDate,
        s.ServiceName,
        s.ServiceCompanyName
    FROM
        ServiceRequest sr
        INNER JOIN Vehicle v              ON sr.VehicleId = v.VehicleId
        INNER JOIN VehicleTypeLookup vt   ON v.VehicleTypeId = vt.VehicleTypeId
        INNER JOIN Service s              ON sr.ServiceId = s.ServiceId
        INNER JOIN Driver d               ON v.VehicleId = d.VehicleID
        INNER JOIN AppUser u              ON d.UserID = u.UserID
    WHERE
        sr.ServiceDueDate > CURDATE()
    ORDER BY
        sr.ServiceDueDate ASC;
END //
DELIMITER ;

-- ---------------------------------------------------------------------------
-- 6.3  CalculateCustomerLoyaltyDiscount
-- Calculate loyalty discount based on rides in the last year.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS CalculateCustomerLoyaltyDiscount;

DELIMITER //
CREATE PROCEDURE CalculateCustomerLoyaltyDiscount(IN p_CustomerId INT)
BEGIN
    DECLARE v_NumRides INT DEFAULT 0;
    DECLARE v_DiscountPercent INT DEFAULT 0;

    -- Count completed rides in the last year
    SELECT COUNT(*) INTO v_NumRides
    FROM RideRequest rr
    INNER JOIN RideStatusLookup rs ON rr.RideStatusId = rs.RideStatusId
    WHERE rr.CustomerID = p_CustomerId
      AND rs.StatusName = 'Completed'
      AND rr.ReqDateTime BETWEEN DATE_SUB(NOW(), INTERVAL 1 YEAR) AND NOW();

    -- Tiered discount
    SET v_DiscountPercent = CASE
        WHEN v_NumRides > 10 THEN 20
        WHEN v_NumRides BETWEEN 5 AND 10 THEN 10
        ELSE 0
    END;

    SELECT
        p_CustomerId   AS CustomerId,
        v_NumRides     AS RidesLastYear,
        v_DiscountPercent AS LoyaltyDiscountPercentage;
END //
DELIMITER ;

-- ---------------------------------------------------------------------------
-- 6.4  DecryptPaymentInfo  (NO HARDCODED KEY)
-- The encryption key MUST be passed as a parameter. The application layer
-- or key vault provides the key at runtime.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS DecryptPaymentInfo;

DELIMITER //
CREATE PROCEDURE DecryptPaymentInfo(
    IN p_CustomerID INT,
    IN p_EncryptionKey VARCHAR(255)
)
BEGIN
    SELECT
        c.CustomerID,
        CONVERT(AES_DECRYPT(c.EncryptedPaymentInfo, p_EncryptionKey) USING utf8mb4)
            AS DecryptedPaymentInfo
    FROM
        Customer c
    WHERE
        c.CustomerID = p_CustomerID;
END //
DELIMITER ;

-- ---------------------------------------------------------------------------
-- 6.5  GetRideHistory  (NEW)
-- Retrieve full ride history for a customer with location details.
-- ---------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS GetRideHistory;

DELIMITER //
CREATE PROCEDURE GetRideHistory(IN p_CustomerId INT)
BEGIN
    SELECT
        rr.RequestId,
        rr.ReqDateTime,
        rt.RequestTypeName  AS RequestType,
        tt.TripTypeName     AS TripType,
        rs.StatusName       AS RideStatus,
        pl.Address          AS PickUpAddress,
        dl.Address          AS DestinationAddress,
        te.Cost             AS EstimatedCost,
        CONCAT(du.UserFName, ' ', du.UserLName) AS DriverName,
        vt.VehicleTypeName  AS VehicleType
    FROM
        RideRequest rr
        INNER JOIN RequestTypeLookup rt  ON rr.RequestTypeId = rt.RequestTypeId
        INNER JOIN TripTypeLookup tt     ON rr.TripTypeId = tt.TripTypeId
        INNER JOIN RideStatusLookup rs   ON rr.RideStatusId = rs.RideStatusId
        INNER JOIN Location pl           ON rr.PickUpLocationId = pl.LocationId
        INNER JOIN Location dl           ON rr.DestLocationId = dl.LocationId
        INNER JOIN TripEstimate te       ON rr.EstimationID = te.EstimationId
        INNER JOIN Driver d              ON rr.DriverID = d.DriverID
        INNER JOIN AppUser du            ON d.UserID = du.UserID
        INNER JOIN Vehicle v             ON rr.VehicleID = v.VehicleId
        INNER JOIN VehicleTypeLookup vt  ON v.VehicleTypeId = vt.VehicleTypeId
    WHERE
        rr.CustomerID = p_CustomerId
    ORDER BY
        rr.ReqDateTime DESC;
END //
DELIMITER ;
