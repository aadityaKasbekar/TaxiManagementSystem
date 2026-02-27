# TaxiManagementSystem V2 — Redesigned Data Layer

## Overview

This is a **ground-up rewrite** of the TaxiManagementSystem database layer, addressing all **17 issues** found during the architecture audit of the original `P4/DDL` code. No original files were modified.

**Database Engine:** MySQL 8.0+

---

## Script Execution Order

Run scripts in numbered order against a MySQL 8.0+ instance:

```bash
mysql -u root -p < 01_create_database.sql
mysql -u root -p TaxiManagementSystemV2 < 02_lookup_tables.sql
mysql -u root -p TaxiManagementSystemV2 < 03_core_tables.sql
mysql -u root -p TaxiManagementSystemV2 < 04_indexes.sql
mysql -u root -p TaxiManagementSystemV2 < 05_views.sql
mysql -u root -p TaxiManagementSystemV2 < 06_stored_procedures.sql
mysql -u root -p TaxiManagementSystemV2 < 07_user_defined_functions.sql
mysql -u root -p TaxiManagementSystemV2 < 08_triggers.sql
mysql -u root -p TaxiManagementSystemV2 < 09_seed_data.sql
mysql -u root -p TaxiManagementSystemV2 < 10_validation.sql
```

---

## Schema (18 tables)

### Lookup Tables (5)
| Table | Purpose |
|---|---|
| `VehicleTypeLookup` | Sedan, SUV, Hatchback, etc. |
| `TripTypeLookup` | City Cab, Out Station Cab |
| `RequestTypeLookup` | Immediate, Scheduled, Recurring |
| `RideStatusLookup` | Requested → Accepted → InProgress → Completed / Cancelled / NoShow |
| `UserTypeLookup` | Driver, Customer |

### Core Entity Tables (13)
| Table | Purpose |
|---|---|
| `Location` | Normalized lat/lng + address (replaces redundant columns in RideRequest) |
| `Service` | Vehicle maintenance service providers |
| `Insurance` | Insurance policy definitions |
| `Vehicle` | Fleet vehicles with FK to VehicleTypeLookup |
| `AppUser` | Base user entity (renamed from reserved word `User`) |
| `Customer` | Extends AppUser for ride customers |
| `PaymentMethod` | Tokenised payment instruments (replaces PK-less PaymentInformation) |
| `Driver` | Extends AppUser for drivers |
| `InsuranceLogs` | Vehicle ↔ Insurance junction (now has proper PK + date check) |
| `Feedback` | Customer feedback with DECIMAL rating (was FLOAT) |
| `TripEstimate` | Ride cost estimates |
| `RideRequest` | Ride requests with FK to all lookups + Location |
| `ServiceRequest` | Vehicle service scheduling |

---

## Issues Fixed

| # | Severity | Issue | Fix |
|---|---|---|---|
| 1 | 🔴 Critical | Hardcoded AES key `'AmeySatwe23'` | Key passed as parameter; managed externally |
| 2 | 🔴 Critical | 3 tables missing PKs | All tables have `AUTO_INCREMENT` PKs |
| 3 | 🔴 Critical | Orphan `Temp` table | Dropped entirely |
| 4 | 🔴 Critical | Plaintext `BankAccInfo` | Column removed from `AppUser` |
| 5 | 🔴 Critical | No UNIQUE on Email/Phone | UNIQUE constraints added |
| 6 | 🟠 High | Inconsistent PK strategy | All tables use `AUTO_INCREMENT` |
| 7 | 🟠 High | Nullable FK columns | Mandatory FKs are `NOT NULL` |
| 8 | 🟠 High | No audit trail | `created_at` / `updated_at` on every table |
| 9 | 🟠 High | `FLOAT` for Rating | Changed to `DECIMAL(2,1)` |
| 10 | 🟠 High | Redundant location data | Normalized `Location` table |
| 11 | 🟠 High | CustomerAndVehicleView bug | Fixed JOIN (was `CustomerId = VehicleId`) |
| 12 | 🟡 Medium | Reserved word `User` | Renamed to `AppUser` |
| 13 | 🟡 Medium | Missing indexes | 20+ indexes added |
| 14 | 🟡 Medium | No lookup tables | 5 lookup tables created |
| 15 | 🟡 Medium | No cascade rules | `ON DELETE CASCADE` / `RESTRICT` added |
| 16 | 🟡 Medium | Dual-platform scripts | Single MySQL 8.0+ dialect |
| 17 | 🟡 Medium | UDF argument order bug | `ServiceDueinDays` fixed |

---

## New Features

- **6 Views** (4 fixed originals + 2 new: `DriverPerformanceView`, `ActiveInsuranceView`)  
- **5 Stored Procedures** (4 fixed + 1 new: `GetRideHistory`)
- **3 UDFs** (2 fixed + 1 new: `CalculateEstimatedArrival` with Haversine)
- **3 Triggers** (default ride status, insurance date validation, feedback guard)
- **Comprehensive validation script** with 11 automated check categories
