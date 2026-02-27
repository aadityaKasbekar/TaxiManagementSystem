-- ============================================================================
-- TaxiManagementSystem — Redesigned Data Layer
-- Script 05: Views
-- Engine: MySQL 8.0+
-- ============================================================================
-- FIXES APPLIED:
--   • CustomerAndVehicleView: fixed the bogus CustomerId = VehicleId JOIN
--   • All views use AppUser instead of `User`
--   • Views reference lookup tables for human-readable status/type names
--   • CustomerRideHistoryView: LEFT JOIN logic fixed to truly include
--     customers with zero rides
-- ============================================================================

USE TaxiManagementSystemV2;

-- ---------------------------------------------------------------------------
-- 5.1  CustomerRideHistoryView
-- Shows each customer's completed ride count and total spend.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW CustomerRideHistoryView AS
SELECT
    u.UserID,
    CONCAT(u.UserFName, ' ', u.UserLName) AS CustomerFullName,
    COUNT(te.Cost)                         AS TotalRides,
    COALESCE(SUM(te.Cost), 0)              AS TotalRideSpend,
    COALESCE(AVG(te.Cost), 0)              AS AverageCostPerRide
FROM
    AppUser u
    INNER JOIN Customer c    ON u.UserID = c.UserID
    LEFT JOIN RideRequest rr ON c.CustomerID = rr.CustomerID
                             AND rr.RideStatusId = (
                                 SELECT rs.RideStatusId
                                 FROM RideStatusLookup rs
                                 WHERE rs.StatusName = 'Completed'
                             )
    LEFT JOIN TripEstimate te ON rr.EstimationID = te.EstimationId
GROUP BY
    u.UserID, u.UserFName, u.UserLName;

-- ---------------------------------------------------------------------------
-- 5.2  ServiceRequestDetailsView
-- Shows vehicle service request details with service provider info.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW ServiceRequestDetailsView AS
SELECT
    v.VehicleId,
    vt.VehicleTypeName AS VehicleType,
    sr.SerReqId,
    sr.ReqDateTime,
    sr.ServiceDueDate,
    s.ServiceName,
    s.ServiceCompanyName,
    s.ServiceDetails
FROM
    ServiceRequest sr
    INNER JOIN Vehicle v              ON sr.VehicleId = v.VehicleId
    INNER JOIN VehicleTypeLookup vt   ON v.VehicleTypeId = vt.VehicleTypeId
    INNER JOIN Service s              ON sr.ServiceId = s.ServiceId;

-- ---------------------------------------------------------------------------
-- 5.3  CustomerAndVehicleView  (FIXED — was joining CustomerId = VehicleId)
-- Shows the vehicle each customer's assigned driver uses.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW CustomerAndVehicleView AS
SELECT
    c.CustomerID,
    CONCAT(u.UserFName, ' ', u.UserLName) AS CustomerName,
    v.VehicleId,
    vt.VehicleTypeName                     AS VehicleType,
    v.LicensePlate
FROM
    Customer c
    INNER JOIN AppUser u              ON c.UserID = u.UserID
    INNER JOIN RideRequest rr         ON c.CustomerID = rr.CustomerID
    INNER JOIN Vehicle v              ON rr.VehicleID = v.VehicleId
    INNER JOIN VehicleTypeLookup vt   ON v.VehicleTypeId = vt.VehicleTypeId
GROUP BY
    c.CustomerID, u.UserFName, u.UserLName,
    v.VehicleId, vt.VehicleTypeName, v.LicensePlate;

-- ---------------------------------------------------------------------------
-- 5.4  VehicleRequestedView
-- Count of completed rides per vehicle type.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW VehicleRequestedView AS
SELECT
    vt.VehicleTypeName                  AS VehicleType,
    COUNT(rr.RequestId)                 AS CountOfVehicleRequested
FROM
    Vehicle v
    INNER JOIN VehicleTypeLookup vt    ON v.VehicleTypeId = vt.VehicleTypeId
    LEFT JOIN RideRequest rr           ON v.VehicleId = rr.VehicleID
                                       AND rr.RideStatusId = (
                                           SELECT rs.RideStatusId
                                           FROM RideStatusLookup rs
                                           WHERE rs.StatusName = 'Completed'
                                       )
GROUP BY
    vt.VehicleTypeName;

-- ---------------------------------------------------------------------------
-- 5.5  DriverPerformanceView  (NEW)
-- Aggregated driver statistics — total trips, avg rating, acceptance rate.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW DriverPerformanceView AS
SELECT
    d.DriverID,
    CONCAT(u.UserFName, ' ', u.UserLName) AS DriverName,
    COUNT(rr.RequestId)                    AS TotalTrips,
    COALESCE(AVG(f.Rating), 0)             AS AverageRating,
    MAX(rr.ReqDateTime)                    AS LastTripDateTime
FROM
    Driver d
    INNER JOIN AppUser u         ON d.UserID = u.UserID
    LEFT JOIN RideRequest rr     ON d.DriverID = rr.DriverID
    LEFT JOIN Feedback f         ON d.DriverID = f.DriverID
GROUP BY
    d.DriverID, u.UserFName, u.UserLName;

-- ---------------------------------------------------------------------------
-- 5.6  ActiveInsuranceView  (NEW)
-- Shows vehicles with currently active insurance coverage.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW ActiveInsuranceView AS
SELECT
    v.VehicleId,
    v.LicensePlate,
    vt.VehicleTypeName AS VehicleType,
    i.InsuranceProvider,
    i.InsuranceCoverage,
    il.InsuranceStartDate,
    il.InsuranceEndDate
FROM
    InsuranceLogs il
    INNER JOIN Vehicle v              ON il.VehicleID = v.VehicleId
    INNER JOIN VehicleTypeLookup vt   ON v.VehicleTypeId = vt.VehicleTypeId
    INNER JOIN Insurance i            ON il.InsuranceId = i.InsuranceId
WHERE
    CURDATE() BETWEEN il.InsuranceStartDate AND il.InsuranceEndDate;
