-- ============================================================================
-- TaxiManagementSystem — Redesigned Data Layer
-- Script 04: Comprehensive Indexing Strategy
-- Engine: MySQL 8.0+
-- ============================================================================
-- NOTE: Many indexes are already defined inline in 03_core_tables.sql.
-- This script adds any additional composite or covering indexes that aid
-- the views, stored procedures, and common query patterns.
-- ============================================================================

USE TaxiManagementSystemV2;

-- ---------------------------------------------------------------------------
-- Composite indexes for multi-column query patterns
-- ---------------------------------------------------------------------------

-- RideRequest: driver history filtered by status
CREATE INDEX idx_ride_driver_status
    ON RideRequest (DriverID, RideStatusId);

-- RideRequest: customer history filtered by status
CREATE INDEX idx_ride_customer_status
    ON RideRequest (CustomerID, RideStatusId);

-- RideRequest: estimation lookups (used by views joining TripEstimate)
CREATE INDEX idx_ride_estimation
    ON RideRequest (EstimationID);

-- ServiceRequest: upcoming services sorted by due date per vehicle
CREATE INDEX idx_serreq_vehicle_due
    ON ServiceRequest (VehicleId, ServiceDueDate);

-- InsuranceLogs: active insurance lookup per vehicle
CREATE INDEX idx_insurancelog_vehicle_dates
    ON InsuranceLogs (VehicleID, InsuranceStartDate, InsuranceEndDate);

-- Feedback: average rating lookups per driver
CREATE INDEX idx_feedback_driver_rating
    ON Feedback (DriverID, Rating);

-- AppUser: lookup by email for authentication
-- (Already covered by UNIQUE KEY uk_appuser_email, but explicit for clarity)

-- TripEstimate: cost-based queries
CREATE INDEX idx_tripest_cost
    ON TripEstimate (Cost);
