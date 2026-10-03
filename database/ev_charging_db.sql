-- ============================================================================
-- EV Charging Station Management System
-- Database Schema: ev_charging_db (Stage 2 Dynamic Architecture)
-- Normalized relational tables with foreign keys and academic seed records
-- ============================================================================

DROP DATABASE IF EXISTS ev_charging_db;
CREATE DATABASE ev_charging_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ev_charging_db;

-- ----------------------------------------------------------------------------
-- 1. Table: users
-- ----------------------------------------------------------------------------
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('ADMIN', 'STATION_MANAGER', 'TECHNICIAN', 'CUSTOMER') NOT NULL DEFAULT 'CUSTOMER',
    phone VARCHAR(20) NOT NULL,
    status ENUM('Active', 'Suspended', 'Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. Table: stations
-- ----------------------------------------------------------------------------
CREATE TABLE stations (
    station_id INT AUTO_INCREMENT PRIMARY KEY,
    station_code VARCHAR(30) NOT NULL UNIQUE,
    station_name VARCHAR(150) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(80) NOT NULL,
    latitude DECIMAL(10, 6) DEFAULT NULL,
    longitude DECIMAL(10, 6) DEFAULT NULL,
    contact_number VARCHAR(25) NOT NULL,
    operating_hours VARCHAR(100) DEFAULT '24/7 Open',
    status ENUM('Operational', 'Busy', 'Partially Available', 'Maintenance', 'Offline') DEFAULT 'Operational',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 3. Table: pricing
-- ----------------------------------------------------------------------------
CREATE TABLE pricing (
    pricing_id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL,
    price_per_kwh DECIMAL(8, 2) NOT NULL DEFAULT 15.00,
    service_fee DECIMAL(8, 2) NOT NULL DEFAULT 20.00,
    tax_percentage DECIMAL(5, 2) NOT NULL DEFAULT 9.00,
    effective_from DATE NOT NULL,
    FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 4. Table: chargers
-- ----------------------------------------------------------------------------
CREATE TABLE chargers (
    charger_id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL,
    charger_code VARCHAR(30) NOT NULL UNIQUE,
    connector_type ENUM('CCS2', 'Type 2', 'CHAdeMO', 'GB/T') NOT NULL,
    charging_power DECIMAL(6, 2) NOT NULL, -- e.g. 7.4, 22.0, 60.0, 120.0, 150.0 kW
    status ENUM('Available', 'Charging', 'Reserved', 'Maintenance', 'Offline') DEFAULT 'Available',
    installed_date DATE NOT NULL,
    total_hours_used DECIMAL(8, 2) DEFAULT 0.00,
    FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 5. Table: vehicles
-- ----------------------------------------------------------------------------
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    vehicle_number VARCHAR(30) NOT NULL UNIQUE,
    vehicle_model VARCHAR(100) NOT NULL,
    battery_capacity DECIMAL(6, 2) NOT NULL, -- in kWh
    current_battery_pct INT DEFAULT 30,
    connector_type ENUM('CCS2', 'Type 2', 'CHAdeMO', 'GB/T') NOT NULL,
    max_charging_power DECIMAL(6, 2) NOT NULL, -- in kW
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 6. Table: reservations
-- ----------------------------------------------------------------------------
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_code VARCHAR(40) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    station_id INT NOT NULL,
    charger_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    start_time TIME NOT NULL,
    duration_minutes INT NOT NULL DEFAULT 45,
    status ENUM('Upcoming', 'Active', 'Completed', 'Cancelled') DEFAULT 'Upcoming',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE RESTRICT,
    FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE RESTRICT,
    FOREIGN KEY (charger_id) REFERENCES chargers(charger_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 7. Table: charging_sessions
-- ----------------------------------------------------------------------------
CREATE TABLE charging_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    session_code VARCHAR(40) NOT NULL UNIQUE,
    reservation_id INT DEFAULT NULL,
    user_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    station_id INT NOT NULL,
    charger_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME DEFAULT NULL,
    energy_consumed DECIMAL(8, 2) DEFAULT 0.00, -- in kWh
    duration_minutes INT DEFAULT 0,
    energy_cost DECIMAL(10, 2) DEFAULT 0.00,
    service_fee DECIMAL(8, 2) DEFAULT 20.00,
    tax_amount DECIMAL(8, 2) DEFAULT 0.00,
    total_cost DECIMAL(10, 2) DEFAULT 0.00,
    status ENUM('Scheduled', 'Active', 'Completed', 'Cancelled') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE RESTRICT,
    FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE RESTRICT,
    FOREIGN KEY (charger_id) REFERENCES chargers(charger_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 8. Table: payments
-- ----------------------------------------------------------------------------
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('UPI', 'Card', 'RFID_Wallet', 'Fleet_Billing') NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Paid', 'Failed', 'Refunded') DEFAULT 'Paid',
    transaction_reference VARCHAR(80) NOT NULL UNIQUE,
    FOREIGN KEY (session_id) REFERENCES charging_sessions(session_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 9. Table: maintenance
-- ----------------------------------------------------------------------------
CREATE TABLE maintenance (
    maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
    maintenance_code VARCHAR(40) NOT NULL UNIQUE,
    charger_id INT NOT NULL,
    technician_id INT NOT NULL,
    issue TEXT NOT NULL,
    priority ENUM('Low', 'Medium', 'High', 'Critical') DEFAULT 'Medium',
    reported_date DATE NOT NULL,
    start_date DATE DEFAULT NULL,
    completion_date DATE DEFAULT NULL,
    status ENUM('Reported', 'Assigned', 'In Progress', 'Completed') DEFAULT 'Reported',
    remarks TEXT DEFAULT NULL,
    FOREIGN KEY (charger_id) REFERENCES chargers(charger_id) ON DELETE CASCADE,
    FOREIGN KEY (technician_id) REFERENCES users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 10. Table: notifications
-- ----------------------------------------------------------------------------
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'warning', 'success', 'danger') DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================================
-- SAMPLE SEED DATA INSERTION
-- ============================================================================

-- Users (BCrypt hashed password representations)
INSERT INTO users (name, email, password_hash, role, phone) VALUES
('Rajesh Sharma', 'admin@evcharge.com', '$2y$10$abcdefghijklmnopqrstuvwxADMINHASH1234567890', 'ADMIN', '+91 98450 12345'),
('Kavitha Raman', 'manager@evcharge.com', '$2y$10$abcdefghijklmnopqrstuvwxMGRHASH1234567890', 'STATION_MANAGER', '+91 98450 67890'),
('Arun Kumar', 'tech@evcharge.com', '$2y$10$abcdefghijklmnopqrstuvwxTECHHASH1234567890', 'TECHNICIAN', '+91 98450 54321'),
('Priya Sundaram', 'customer@evcharge.com', '$2y$10$abcdefghijklmnopqrstuvwxCUSTHASH1234567890', 'CUSTOMER', '+91 98450 99887');

-- Stations (Comprehensive 20 Coimbatore Hubs + Regional Express Corridors)
INSERT INTO stations (station_code, station_name, address, city, latitude, longitude, contact_number, operating_hours, status) VALUES
('STN-001', 'Coimbatore Central EV Hub', 'Avinashi Road, Near Collectorate', 'Coimbatore', 11.0018, 76.9629, '+91 422 2301980', '24/7 Open', 'Operational'),
('STN-002', 'Avinashi Road EV Station', 'Near PSG Tech, Peelamedu', 'Coimbatore', 11.0264, 77.0089, '+91 422 2572177', '06:00 AM - 11:00 PM', 'Operational'),
('STN-003', 'Gandhipuram Charging Point', 'Cross Cut Road, Gandhipuram', 'Coimbatore', 11.0168, 76.9682, '+91 422 2490123', '24/7 Open', 'Busy'),
('STN-004', 'RS Puram EV Hub', 'DB Road, RS Puram West', 'Coimbatore', 11.0089, 76.9486, '+91 422 2541188', '06:00 AM - 10:00 PM', 'Operational'),
('STN-005', 'Peelamedu Express Station', 'Aerodrome Post, Near CIT', 'Coimbatore', 11.0298, 77.0321, '+91 422 2605555', '24/7 Open', 'Partially Available'),
('STN-006', 'Saravanampatti IT Park EV Station', 'CHIL SEZ IT Park, Keeranatham Road', 'Coimbatore', 11.0825, 76.9945, '+91 422 2668100', '24/7 Open', 'Operational'),
('STN-007', 'Singanallur Junction Charging Hub', 'Near Bus Stand, Trichy Road', 'Coimbatore', 11.0012, 77.0210, '+91 422 2591234', '24/7 Open', 'Operational'),
('STN-008', 'Ukkadam Lakeview EV Hub', 'Near Ukkadam Bus Stand, Pollachi Road', 'Coimbatore', 10.9880, 76.9602, '+91 422 2390888', '05:00 AM - 11:30 PM', 'Operational'),
('STN-009', 'Ganapathy Sathy Road EV Station', 'Near Ganapathy Bus Stand, Sathy Road', 'Coimbatore', 11.0375, 76.9782, '+91 422 2534567', '06:00 AM - 11:00 PM', 'Operational'),
('STN-010', 'Prozone Mall EV Charging Plaza', 'Sathy Road, Saravanampatti', 'Coimbatore', 11.0545, 76.9930, '+91 422 6628000', '10:00 AM - 11:00 PM', 'Operational'),
('STN-011', 'Brookefields Mall EV Hub', 'Dr. Krishnasamy Mudaliar Road', 'Coimbatore', 11.0092, 76.9575, '+91 422 2255555', '09:30 AM - 11:00 PM', 'Operational'),
('STN-012', 'Coimbatore Airport Fast-Charge Hub', 'Civil Aerodrome Post, Peelamedu', 'Coimbatore', 11.0290, 77.0434, '+91 422 2571941', '24/7 Open', 'Operational'),
('STN-013', 'Kuniyamuthur EV Junction', 'Palakkad Main Road, Kuniyamuthur', 'Coimbatore', 10.9602, 76.9450, '+91 422 2673344', '06:00 AM - 10:30 PM', 'Operational'),
('STN-014', 'Thudiyalur Express Charging Hub', 'Mettupalayam Road, Near Thudiyalur Junction', 'Coimbatore', 11.0780, 76.9410, '+91 422 2642111', '24/7 Open', 'Operational'),
('STN-015', 'Eachanari Industrial EV Station', 'Pollachi Main Road, Near Eachanari Temple', 'Coimbatore', 10.9255, 76.9695, '+91 422 2611000', '24/7 Open', 'Operational'),
('STN-016', 'Vadavalli EV Charging Point', 'Marudhamalai Main Road, Vadavalli', 'Coimbatore', 11.0280, 76.9020, '+91 422 2423322', '06:00 AM - 10:00 PM', 'Operational'),
('STN-017', 'Kovaipudur Green Mobility Hub', 'Kovaipudur Main Road, Near Krishna College', 'Coimbatore', 10.9380, 76.9320, '+91 422 2607890', '06:00 AM - 10:00 PM', 'Operational'),
('STN-018', 'Hope College EV Fast Charging Bay', 'Avinashi Road, Near Fun Republic Mall', 'Coimbatore', 11.0315, 77.0185, '+91 422 2510200', '24/7 Open', 'Operational'),
('STN-019', 'Saibaba Colony EV Hub', 'NSR Road, Saibaba Colony', 'Coimbatore', 11.0250, 76.9450, '+91 422 2445566', '06:00 AM - 11:00 PM', 'Operational'),
('STN-020', 'Sundarapuram Industrial EV Bay', 'Pollachi Road, SIDCO Industrial Estate', 'Coimbatore', 10.9510, 76.9750, '+91 422 2672345', '24/7 Open', 'Operational'),
('STN-021', 'Tiruppur Cotton City Supercharger', 'Avinashi-Tiruppur Bypass Road', 'Tiruppur', 11.1085, 77.3411, '+91 421 2233445', '24/7 Open', 'Operational'),
('STN-022', 'Salem Highway NH544 EV Plaza', 'NH 544 Express Highway Corridor', 'Salem', 11.6643, 78.1460, '+91 427 2441122', '24/7 Open', 'Operational'),
('STN-023', 'Chennai OMR Tech Supercharger', 'Rajiv Gandhi Salai, Sholinganallur', 'Chennai', 12.9010, 80.2279, '+91 44 24501234', '24/7 Open', 'Operational'),
('STN-024', 'Bengaluru Koramangala Green Hub', '80 Feet Road, 4th Block, Koramangala', 'Bengaluru', 12.9352, 77.6245, '+91 80 25531234', '24/7 Open', 'Operational');

-- Pricing
INSERT INTO pricing (station_id, price_per_kwh, service_fee, tax_percentage, effective_from) VALUES
(1, 15.00, 20.00, 9.00, '2026-01-01'),
(2, 14.50, 20.00, 9.00, '2026-01-01'),
(3, 15.50, 20.00, 9.00, '2026-01-01'),
(4, 15.00, 20.00, 9.00, '2026-01-01'),
(5, 16.00, 20.00, 9.00, '2026-01-01'),
(6, 15.50, 20.00, 9.00, '2026-01-01'),
(10, 16.50, 25.00, 9.00, '2026-01-01'),
(11, 16.50, 25.00, 9.00, '2026-01-01'),
(12, 17.00, 25.00, 9.00, '2026-01-01'),
(23, 16.50, 25.00, 9.00, '2026-01-01'),
(24, 16.00, 20.00, 9.00, '2026-01-01');

-- Chargers
INSERT INTO chargers (station_id, charger_code, connector_type, charging_power, status, installed_date, total_hours_used) VALUES
(1, 'CH-001', 'CCS2', 60.00, 'Available', '2025-01-10', 18.50),
(1, 'CH-002', 'CCS2', 120.00, 'Charging', '2025-01-10', 21.00),
(1, 'CH-003', 'Type 2', 22.00, 'Available', '2025-02-15', 14.20),
(1, 'CH-004', 'CCS2', 150.00, 'Maintenance', '2025-03-01', 9.00),
(1, 'CH-005', 'CHAdeMO', 50.00, 'Available', '2025-03-10', 11.50),
(1, 'CH-006', 'GB/T', 30.00, 'Reserved', '2025-03-12', 8.00),

(2, 'CH-007', 'CCS2', 60.00, 'Available', '2025-01-20', 16.40),
(2, 'CH-008', 'CCS2', 120.00, 'Charging', '2025-01-20', 19.80),
(2, 'CH-009', 'Type 2', 7.40, 'Available', '2025-02-01', 7.20),
(2, 'CH-010', 'CCS2', 60.00, 'Available', '2025-02-05', 12.00),
(2, 'CH-011', 'Type 2', 22.00, 'Offline', '2025-02-10', 4.50),

(6, 'CH-024', 'CCS2', 150.00, 'Available', '2025-01-15', 19.50),
(6, 'CH-025', 'CCS2', 120.00, 'Charging', '2025-01-15', 22.00),
(6, 'CH-026', 'CCS2', 60.00, 'Available', '2025-01-15', 14.00),

(10, 'CH-035', 'CCS2', 150.00, 'Available', '2025-02-15', 20.00),
(10, 'CH-036', 'CCS2', 120.00, 'Available', '2025-02-15', 18.00),

(11, 'CH-041', 'CCS2', 150.00, 'Available', '2025-01-25', 23.00),
(11, 'CH-042', 'CCS2', 120.00, 'Charging', '2025-01-25', 21.00),

(12, 'CH-047', 'CCS2', 150.00, 'Available', '2025-01-01', 23.50),
(12, 'CH-048', 'CCS2', 150.00, 'Charging', '2025-01-01', 24.00);

-- Vehicles (Including Luxury Fleet: Porsche, Mercedes, BMW, Audi, Tesla, Volvo, Jaguar)
INSERT INTO vehicles (user_id, vehicle_number, vehicle_model, battery_capacity, current_battery_pct, connector_type, max_charging_power) VALUES
(4, 'TN 38 BZ 4021', 'Tata Nexon EV', 40.50, 25, 'CCS2', 60.00),
(4, 'TN 37 CY 8812', 'MG ZS EV', 50.30, 42, 'CCS2', 80.00),
(1, 'TN 01 AB 9000', 'Hyundai Ioniq 5', 72.60, 60, 'CCS2', 150.00),
(4, 'TN 38 EQ 5500', 'Mercedes-Benz EQS 580', 107.80, 48, 'CCS2', 200.00),
(1, 'TN 38 IX 7700', 'BMW iX xDrive50', 111.50, 55, 'CCS2', 195.00),
(2, 'TN 37 GT 9999', 'Audi e-tron GT', 93.40, 32, 'CCS2', 270.00),
(1, 'TN 01 TY 0001', 'Porsche Taycan 4S', 93.40, 65, 'CCS2', 270.00),
(4, 'TN 38 VR 4488', 'Volvo XC40 Recharge', 78.00, 40, 'CCS2', 150.00),
(2, 'TN 38 IP 3322', 'Jaguar I-PACE', 90.00, 38, 'CCS2', 100.00),
(4, 'TN 37 TS 8800', 'Tesla Model 3 Long Range', 75.00, 52, 'CCS2', 250.00);

-- Reservations
INSERT INTO reservations (reservation_code, user_id, vehicle_id, station_id, charger_id, reservation_date, start_time, duration_minutes, status) VALUES
('RES-2026-001', 4, 4, 1, 6, '2026-10-02', '10:30:00', 45, 'Upcoming'),
('RES-2026-002', 4, 2, 2, 7, '2026-10-01', '16:00:00', 60, 'Completed'),
('RES-2026-003', 1, 7, 12, 19, '2026-10-02', '14:00:00', 30, 'Upcoming');

-- Charging Sessions
INSERT INTO charging_sessions (session_code, reservation_id, user_id, vehicle_id, station_id, charger_id, start_time, end_time, energy_consumed, duration_minutes, energy_cost, service_fee, tax_amount, total_cost, status) VALUES
('SES-2026-0051', 2, 4, 1, 1, 2, '2026-10-01 18:15:00', '2026-10-01 18:53:00', 24.80, 38, 372.00, 20.00, 35.28, 427.28, 'Completed'),
('SES-2026-0052', NULL, 4, 4, 1, 2, '2026-10-01 21:40:00', NULL, 46.20, 28, 693.00, 20.00, 64.17, 777.17, 'Active');

-- Payments
INSERT INTO payments (session_id, amount, payment_method, status, transaction_reference) VALUES
(1, 427.28, 'UPI', 'Paid', 'TXN-8849204812');

-- Maintenance
INSERT INTO maintenance (maintenance_code, charger_id, technician_id, issue, priority, reported_date, start_date, status, remarks) VALUES
('MNT-2026-01', 4, 3, 'High-voltage connector overheating and intermittent latch fault', 'High', '2026-09-29', '2026-09-30', 'In Progress', 'Replacement DC contactor pin ordered from OEM.');
