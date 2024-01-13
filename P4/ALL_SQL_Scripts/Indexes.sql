use TaxiManagementSystem
go

CREATE INDEX idx_CustomerID ON RideRequest(CustomerID);

CREATE INDEX idx_DriverID ON RideRequest(DriverID);

CREATE INDEX idx_DriverID_Feedback ON Feedback(DriverID);

CREATE INDEX idx_VehicleID_ServiceRequest ON ServiceRequest(VehicleID);

CREATE INDEX idx_InsuranceId_InsuranceLogs ON InsuranceLogs(InsuranceId);