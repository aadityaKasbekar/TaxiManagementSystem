use TaxiManagementSystem
go

-- View to get Customer Ride History
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

CREATE VIEW CustomerAndVehicleView AS
SELECT
    C.CustomerId,
    U.UserFName+' '+U.UserLName CustomerName,
    V.VehicleId,
    V.VehicleType,
    V.ServiceInfo AS VehicleServiceInfo
FROM
    Customer C
JOIN
    [User] U ON C.UserID = U.UserID
JOIN
    Vehicle V ON C.CustomerId = V.VehicleId;

select * from CustomerAndVehicleView;

--- view for vehicle stats
CREATE VIEW  VehicleRequestedView AS
SELECT v.VehicleType, count(nrr.VehicleID) "Count of Vehicle Requested"
FROM Vehicle v LEFT JOIN (SELECT r.* FROM RideRequest r WHERE r.TripCompletionFlag = 1) nrr on v.VehicleId = nrr.VehicleID
GROUP BY v.VehicleType;

select * from VehicleRequestedView;