-- ============================================================================
-- TaxiManagementSystem — Redesigned Data Layer
-- Script 01: Database Creation
-- Engine: MySQL 8.0+
-- ============================================================================

-- Drop the database if it exists (for clean re-runs)
DROP DATABASE IF EXISTS TaxiManagementSystemV2;

-- Create the database with UTF-8 support
CREATE DATABASE TaxiManagementSystemV2
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- Switch to the new database
USE TaxiManagementSystemV2;
