-- Database schema for the healthcare relational database project
-- Includes DDL statements for creating the database, tables, keys, constraints, and relationships

CREATE DATABASE healthcare_systems;
USE healthcare_systems;

-- CREATING TABLES DDL CREATE TABLE, CREATE DATABASE, ALTER , DROP TAABLE
--  1 user table
CREATE TABLE users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(60) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    status ENUM('Active', 'Inactive', 'Locked') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 1 patients table
CREATE TABLE patients (
    patient_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    sex_at_birth ENUM('Male', 'Female', 'Other') NOT NULL,
    phone VARCHAR(30),
    address_line1 VARCHAR(200),
    address_line2 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3 providers table  - Strong Entity, parent type, referenced table - 
CREATE TABLE providers (
    provider_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    npi VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(120),
    phone VARCHAR(30),
    email VARCHAR(255) NOT NULL UNIQUE,
    status ENUM('Active', 'Inactive') NOT NULL,
    provider_type ENUM('Doctor', 'Nurse', 'Lab Tech', 'Therapist') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- 4 facilities  table  Laboratory
CREATE TABLE facilities (
    facility_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    facility_name VARCHAR(200) NOT NULL,
    facility_type ENUM('Hospital', 'Clinic', 'Laboratory', 'Urgent Care') NOT NULL,
    phone VARCHAR(30),
    address_line1 VARCHAR(200),
    address_line2 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- 5 appointments  table 
CREATE TABLE appointments (
    appointment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    provider_id BIGINT NOT NULL,
    facility_id BIGINT NOT NULL,
    scheduled_start DATETIME NOT NULL,
    scheduled_end DATETIME NOT NULL,
    status ENUM('Scheduled', 'Completed', 'Cancelled', 'No Show') NOT NULL,
    reason VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id)
        REFERENCES patients (patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (provider_id)
        REFERENCES providers (provider_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (facility_id)
        REFERENCES facilities (facility_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (scheduled_end > scheduled_start)
);

-- 6 visit  table 
CREATE TABLE visits (
    visit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    appointment_id BIGINT NOT NULL UNIQUE,
    patient_id BIGINT NOT NULL,
    provider_id BIGINT NOT NULL,
    facility_id BIGINT NOT NULL,
    visit_start DATETIME NOT NULL,
    visit_end DATETIME,
    visit_type ENUM('In-Person', 'Virtual', 'Emergency'),
    status ENUM('Completed', 'Cancelled', 'In Progress') NOT NULL,
    chief_complaint VARCHAR(255),
    diagnosis_code VARCHAR(20),
    diagnosis_tex VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id)
        REFERENCES appointments (appointment_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (patient_id)
        REFERENCES patients (patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (provider_id)
        REFERENCES providers (provider_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (facility_id)
        REFERENCES facilities (facility_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (visit_end IS NULL
        OR visit_end >= visit_start)
);


-- 7 visit_notes  table 
CREATE TABLE visit_notes (
    note_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    author_provider_id BIGINT NOT NULL,
    note_type ENUM('Diagnosis', 'Observation', 'Prescription', 'General') NOT NULL,
    note_text TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (visit_id)
        REFERENCES visits (visit_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (author_provider_id)
        REFERENCES providers (provider_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);


-- Part 3: lab_orders + lab_results

-- 8 lab_orders  table 
CREATE TABLE lab_orders (
    lab_order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT NOT NULL,
    ordered_by_provider_id BIGINT NOT NULL,
    facility_id BIGINT NOT NULL,
    order_name VARCHAR(200) NOT NULL,
    status ENUM('Ordered', 'Collected', 'In Progress', 'Completed', 'Cancelled') NOT NULL,
    ordered_at DATETIME NOT NULL,
    collected_at DATETIME NULL,
    resulted_at DATETIME NULL,
    FOREIGN KEY (visit_id)
        REFERENCES visits (visit_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ordered_by_provider_id)
        REFERENCES providers (provider_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (facility_id)
        REFERENCES facilities (facility_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);


-- 9 lab_results  table 
CREATE TABLE lab_results (
    lab_result_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    lab_order_id BIGINT NOT NULL,
    test_name VARCHAR(200) NOT NULL,
    value_text VARCHAR(100),
    value_numeric DECIMAL(12 , 4 ),
    unit VARCHAR(50),
    reference_range VARCHAR(100),
    abnormal_flag ENUM('Normal', 'Abnormal'),
    result_date DATETIME NOT NULL,
    FOREIGN KEY (lab_order_id)
        REFERENCES lab_orders (lab_order_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- Part 4: invoices + invoice_items + payments
-- 10 invoices table 
CREATE TABLE invoices (
    invoice_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    visit_id BIGINT NOT NULL UNIQUE,
    status ENUM('Pending', 'Partially Paid', 'Paid', 'Cancelled') NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id)
        REFERENCES patients (patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (visit_id)
        REFERENCES visits (visit_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
ALTER TABLE invoices 
MODIFY status ENUM('Issued', 'Pending', 'Partially Paid', 'Paid', 'Cancelled') NOT NULL;


-- 11 invoice_items table 
CREATE TABLE invoice_items (
    invoice_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_id BIGINT NOT NULL,
    item_type ENUM('Consultation', 'Lab Test', 'Procedure', 'Medication', 'Other') NOT NULL,
    description VARCHAR(255) NOT NULL,
    cpt_code VARCHAR(20),
    quantity INT NOT NULL,
    unit_price DECIMAL(10 , 2 ) NOT NULL,
    FOREIGN KEY (invoice_id)
        REFERENCES invoices (invoice_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (quantity > 0),
    CHECK (unit_price >= 0)
);


-- 12 payments table 
CREATE TABLE payments (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_id BIGINT NOT NULL,
    amount DECIMAL(10 , 2 ) NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Insurance', 'Online') NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') NOT NULL,
    paid_at DATETIME NULL,
    reference_no VARCHAR(100) UNIQUE,
    FOREIGN KEY (invoice_id)
        REFERENCES invoices (invoice_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (amount > 0)
);



-- Part 5: record_shares + access_audit

--  13 record_shares table 
-- access control / permission table

CREATE TABLE record_shares (
    record_share_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    grantee_provider_id BIGINT NOT NULL,
    scope ENUM('Read', 'Write', 'Full') NOT NULL,
    status ENUM('Active', 'Revoked', 'Expired') NOT NULL,
    start_at DATETIME NOT NULL,
    end_at DATETIME NULL,
    FOREIGN KEY (patient_id)
        REFERENCES patients (patient_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (grantee_provider_id)
        REFERENCES providers (provider_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (patient_id , grantee_provider_id),
    CHECK (end_at IS NULL OR end_at >= start_at)
);

ALTER TABLE record_shares
ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP
AFTER end_at;




-- 14 access_audit table 
CREATE TABLE access_audit (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    provider_id BIGINT NULL,
    action ENUM('View', 'Update', 'Delete', 'Create') NOT NULL,
    accessed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    purpose VARCHAR(255),
    FOREIGN KEY (patient_id)
        REFERENCES patients (patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (provider_id)
        REFERENCES providers (provider_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);



