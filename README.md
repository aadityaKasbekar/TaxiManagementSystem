# 🚕 TaxiManagementSystem

> A production grade MySQL database schema for a ride hailing platform — designed from scratch to solve every normalization, security, and integrity flaw of other systems.

[![MySQL 8.0+](https://img.shields.io/badge/MySQL-8.0%2B-4479A1?logo=mysql&logoColor=white)](https://dev.mysql.com/doc/refman/8.0/en/)
[![License](https://img.shields.io/badge/license-MIT-green)](#license)

---

## ⚡ Quick Start

**Prerequisites:** MySQL 8.0+ installed and running.

```bash
# 1. Clone the repository
git clone https://github.com/aadityaKasbekar/TaxiManagementSystem.git
cd TaxiManagementSystem

# 2. Run every script in order (creates DB, schema, seed data, and validates)
for script in 0*.sql 1*.sql; do
  mysql -u root -p < "$script"
done

# 3. Verify everything worked
mysql -u root -p TaxiManagementSystemV2 < 10_validation.sql
```

Or run each script individually:

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

## ✨ Key Features

| Category | Highlights |
|---|---|
| **18 Tables** | 5 lookup tables + 13 core entity tables, all with `AUTO_INCREMENT` PKs |
| **Normalized Locations** | Dedicated `Location` table eliminates redundant lat/lng + address columns |
| **Security-First Design** | No plaintext sensitive data; encryption keys are externally managed |
| **6 Views** | Customer ride history, driver performance, active insurance, vehicle popularity, and more |
| **5 Stored Procedures** | Driver stats, upcoming services, loyalty discounts, ride history, payment decryption |
| **3 UDFs** | Service days remaining, customer age categorization, Haversine ETA calculation |
| **3 Triggers** | Auto-default ride status, insurance date validation, completed-ride feedback guard |
| **Full Audit Trail** | `created_at` / `updated_at` on every table |
| **20+ Indexes** | Composite and covering indexes optimized for common query patterns |
| **Validation Suite** | 11 automated checks verify schema, constraints, seed data, views, procedures, and functions |

---

## 🏗️ Tech Stack

| Component | Technology |
|---|---|
| **Database Engine** | MySQL 8.0+ |
| **Character Set** | `utf8mb4` with `utf8mb4_unicode_ci` collation |
| **Storage Engine** | InnoDB (transactional, FK support) |
| **Encryption** | AES-256 (application-layer key management) |
| **Payment Security** | Tokenized via `VARBINARY` — no raw card data stored |

---

## 📁 Project Structure

```
TaxiManagementSystem/
├── 01_create_database.sql          # Database creation with UTF-8 support
├── 02_lookup_tables.sql            # 5 reference/lookup tables + seed data
├── 03_core_tables.sql              # 13 core entity tables with FKs & constraints
├── 04_indexes.sql                  # Additional composite & covering indexes
├── 05_views.sql                    # 6 views for reporting & analytics
├── 06_stored_procedures.sql        # 5 stored procedures for business logic
├── 07_user_defined_functions.sql   # 3 UDFs (service days, age category, ETA)
├── 08_triggers.sql                 # 3 triggers for data integrity
├── 09_seed_data.sql                # Realistic sample data for testing
├── 10_validation.sql               # 11-category schema validation suite
├── ERD.pdf                         # Entity Relationship Diagram
├── EERD.pdf                        # Enhanced Entity Relationship Diagram
└── README.md                       # You are here
```

---

## 📊 Database Schema

### Lookup Tables (5)

| Table | Replaces | Example Values |
|---|---|---|
| `VehicleTypeLookup` | `Vehicle.VehicleType VARCHAR` | Sedan, SUV, Hatchback, Minivan, Luxury, Electric |
| `TripTypeLookup` | `RideRequest.TripType VARCHAR` | City Cab, Out Station Cab |
| `RequestTypeLookup` | `RideRequest.RequestType VARCHAR` | Immediate, Scheduled, Recurring |
| `RideStatusLookup` | `RideRequest.TripCompletionFlag TINYINT` | Requested → Accepted → InProgress → Completed / Cancelled / NoShow |
| `UserTypeLookup` | `User.UserType CHAR(1)` | Driver (D), Customer (C) |

### Core Entity Tables (13)

| Table | Purpose |
|---|---|
| `Location` | Normalized lat/lng + address (eliminates redundant RideRequest columns) |
| `Service` | Vehicle maintenance service providers |
| `Insurance` | Insurance policy definitions with premium & deductible |
| `Vehicle` | Fleet vehicles linked to `VehicleTypeLookup` |
| `AppUser` | Base user entity (renamed from reserved word `User`) |
| `Customer` | Extends `AppUser` — loyalty points, encrypted payment info |
| `PaymentMethod` | Tokenized payment instruments per customer |
| `Driver` | Extends `AppUser` — linked to vehicle and license |
| `InsuranceLogs` | Vehicle ↔ Insurance junction with date validation |
| `Feedback` | Customer feedback with `DECIMAL(2,1)` rating (0.0–5.0) |
| `TripEstimate` | Ride cost estimates per vehicle |
| `RideRequest` | Core ride entity with FKs to all lookups + locations |
| `ServiceRequest` | Vehicle maintenance scheduling |

### Entity Relationship

```
AppUser ──┬── Customer ──── PaymentMethod
          │       │
          │       ├── RideRequest ──┬── Location (pickup)
          │       │       │         └── Location (dest)
          │       │       │
          │       └── Feedback ─────── Driver
          │                              │
          └── Driver ─── Vehicle ──┬── InsuranceLogs ── Insurance
                                   ├── TripEstimate
                                   ├── ServiceRequest ── Service
                                   └── VehicleTypeLookup
```

---

## 🔧 Views & Business Logic

### Views

| View | Description |
|---|---|
| `CustomerRideHistoryView` | Total rides, total spend, and avg cost per customer |
| `ServiceRequestDetailsView` | Vehicle service requests with provider info |
| `CustomerAndVehicleView` | Which vehicle each customer's driver uses |
| `VehicleRequestedView` | Completed ride count by vehicle type |
| `DriverPerformanceView` | Total trips, avg rating, and last trip per driver |
| `ActiveInsuranceView` | Vehicles with currently valid insurance |

### Stored Procedures

| Procedure | Parameters | Description |
|---|---|---|
| `GetDriverStatistics` | `p_DriverId INT` | Aggregated driver stats with latest trip destination |
| `GetUpcomingServiceRequests` | *(none)* | All future-dated service requests |
| `CalculateCustomerLoyaltyDiscount` | `p_CustomerId INT` | Tiered discount (0%/10%/20%) based on yearly rides |
| `DecryptPaymentInfo` | `p_CustomerID INT, p_EncryptionKey VARCHAR` | Secure decryption — key is **never** hardcoded |
| `GetRideHistory` | `p_CustomerId INT` | Full ride history with locations, driver, and vehicle |

### User-Defined Functions

| Function | Returns | Description |
|---|---|---|
| `ServiceDueinDays(DueDate, ReqDate)` | `INT` | Days until service is due (negative = overdue) |
| `CustomerCategory(CustomerID)` | `VARCHAR(20)` | Age-based category: Under 18, Young Adult, Adult, Middle Aged, Senior Citizen |
| `CalculateEstimatedArrival(...)` | `INT` | ETA in minutes using Haversine distance formula |

### Triggers

| Trigger | Event | Purpose |
|---|---|---|
| `trg_riderequest_default_status` | `BEFORE INSERT` on `RideRequest` | Auto-sets status to "Requested" |
| `trg_insurancelogs_validate_dates` | `BEFORE INSERT` on `InsuranceLogs` | Ensures end date > start date |
| `trg_feedback_validate_ridecompleted` | `BEFORE INSERT` on `Feedback` | Blocks feedback unless a completed ride exists |

---

## ✅ Validation

Script `10_validation.sql` runs **11 automated check categories**:

1. ✓ All 18 expected tables exist
2. ✓ Every table has a primary key
3. ✓ UNIQUE constraints on critical columns
4. ✓ Audit columns (`created_at`, `updated_at`) present on all tables
5. ✓ Index count per table
6. ✓ Foreign key relationships verified
7. ✓ NOT NULL enforcement on mandatory FK columns
8. ✓ Seed data row counts confirmed
9. ✓ All 6 views return results (smoke test)
10. ✓ All stored procedures execute without errors
11. ✓ All UDFs return expected values

---

## 🌱 Sample Data

The seed script (`09_seed_data.sql`) loads realistic test data:

| Entity | Records |
|---|---|
| Locations | 10 (Boston area) |
| Vehicles | 10 (mixed types) |
| Drivers | 5 |
| Customers | 5 |
| Ride Requests | 8 |
| Feedback | 6 |
| Service Requests | 5 |
| Insurance Logs | 5 |
| Payment Methods | 5 (tokenized) |
| Services | 8 |
| Insurance Providers | 5 |

---

## 📋 Prerequisites

- **MySQL 8.0+** — [Download](https://dev.mysql.com/downloads/mysql/) or use Docker:
  ```bash
  docker run --name mysql8 -e MYSQL_ROOT_PASSWORD=yourpassword -p 3306:3306 -d mysql:8.0
  ```
- **MySQL CLI** (`mysql` command) or any MySQL client (MySQL Workbench, DBeaver, DataGrip)

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is available under the [MIT License](LICENSE).

---

<p align="center">
  <i>Built with RDBMS concepts for better data integrity.</i>
</p>
