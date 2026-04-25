-- Sample data for the healthcare relational database project.
-- All names, emails, phone numbers, and addresses are fictional.

-- 1 users table

INSERT INTO users (email, password_hash, status)
VALUES
('john.doe@email.com', 'hashed_pw_1', 'Active'),
('jane.smith@email.com', 'hashed_pw_2', 'Active'),
('alice.brown@email.com', 'hashed_pw_3', 'Inactive'),
('bob.johnson@email.com', 'hashed_pw_4', 'Active');

SELECT * FROM users;

--  patients table

INSERT INTO patients 
(user_id, first_name, last_name, date_of_birth, sex_at_birth, phone, address_line1, city, state, postal_code)
VALUES
(1, 'John', 'Doe', '1985-06-15', 'Male', '615-555-1001', '123 Main St', 'Nashville', 'TN', '37201'),
(2, 'Jane', 'Smith', '1990-09-22', 'Female', '615-555-1002', '456 Oak Ave', 'Nashville', 'TN', '37202'),
(3, 'Alice', 'Brown', '1978-03-10', 'Female', '615-555-1003', '789 Pine Rd', 'Franklin', 'TN', '37064'),
(4, 'Bob', 'Johnson', '1982-12-05', 'Male', '615-555-1004', '321 Cedar Ln', 'Murfreesboro', 'TN', '37130');

SELECT * FROM patients;


-- 3 providers table

INSERT INTO providers 
(npi, first_name, last_name, specialty, phone, email, status, provider_type)
VALUES
('NPI1001', 'Emily', 'Clark', 'Cardiology', '615-555-2001', 'emily.clark@hospital.com', 'Active', 'Doctor'),
('NPI1002', 'Michael', 'Lee', 'General Practice', '615-555-2002', 'michael.lee@hospital.com', 'Active', 'Doctor'),
('NPI1003', 'Sarah', 'Wilson', 'Nursing', '615-555-2003', 'sarah.wilson@hospital.com', 'Active', 'Nurse'),
('NPI1004', 'David', 'Kim', 'Laboratory', '615-555-2004', 'david.kim@hospital.com', 'Active', 'Lab Tech');

SELECT * FROM providers;

-- 4 facilities table
INSERT INTO facilities
(facility_name, facility_type, phone, address_line1, city, state, postal_code)
VALUES
('Nashville General Hospital', 'Clinic', '615-555-3001', '100 Health St', 'Nashville', 'TN', '37203'),
('Franklin Medical Center', 'Clinic', '615-555-3002', '200 Care Ave', 'Franklin', 'TN', '37064'),
('Tennessee Lab Services', 'Laboratory', '615-555-3003', '300 Lab Rd', 'Nashville', 'TN', '37204');

DELETE FROM facilities
WHERE facility_id IN (10, 11, 12);

SELECT * FROM facilities;


-- 5 appointments table

INSERT INTO appointments
(patient_id, provider_id, facility_id, scheduled_start, scheduled_end, status, reason)
VALUES
(1, 1, 7, '2026-04-10 09:00:00', '2026-04-10 09:30:00', 'Scheduled', 'Routine check-up'),
(2, 2, 7, '2026-04-10 10:00:00', '2026-04-10 10:30:00', 'Scheduled', 'Flu symptoms'),
(3, 1, 8, '2026-04-11 11:00:00', '2026-04-11 11:30:00', 'Scheduled', 'Blood pressure follow-up'),
(4, 2, 8, '2026-04-11 13:00:00', '2026-04-11 13:30:00', 'Cancelled', 'General consultation');

SELECT * FROM appointments;


-- 6 visits table

INSERT INTO visits
(appointment_id, patient_id, provider_id, facility_id, visit_start, visit_end, visit_type, status, chief_complaint, diagnosis_code, diagnosis_text)
VALUES
(1, 1, 1, 7, '2026-04-10 09:05:00', '2026-04-10 09:25:00', 'In-Person', 'Completed', 'Annual wellness check', 'Z00.00', 'General adult medical examination'),
(2, 2, 2, 7, '2026-04-10 10:10:00', '2026-04-10 10:28:00', 'In-Person', 'Completed', 'Fever and cough', 'J11.1', 'Influenza with respiratory symptoms'),
(3, 3, 1, 8, '2026-04-11 11:05:00', '2026-04-11 11:32:00', 'In-Person', 'Completed', 'High blood pressure follow-up', 'I10', 'Essential hypertension');

SELECT * FROM visits;

-- 7 visit_notes table

INSERT INTO visit_notes
(visit_id, author_provider_id, note_type, note_text)
VALUES
(1, 1, 'General', 'Patient presented for annual wellness exam. No acute concerns reported.'),
(1, 1, 'Prescription', 'Advised routine preventive care and annual follow-up.'),
(2, 2, 'General', 'Patient reported fever and cough for three days. Influenza symptoms discussed.'),
(3, 1, 'Observation', 'Blood pressure remains elevated. Lifestyle modifications reinforced.');

SELECT * FROM visit_notes;

-- 8 lab_orders table

INSERT INTO lab_orders
(visit_id, ordered_by_provider_id, facility_id, order_name, status, ordered_at, collected_at, resulted_at)
VALUES
(2, 2, 9, 'Influenza A/B Test', 'Completed', '2026-04-10 10:20:00', '2026-04-10 10:30:00', '2026-04-10 14:00:00'),
(3, 1, 9, 'Basic Metabolic Panel', 'Completed', '2026-04-11 11:20:00', '2026-04-11 11:35:00', '2026-04-11 15:30:00');

SELECT * FROM lab_orders;

-- 9 lab_results table
/*For each `lab_order`, there may be one or more results.
1 result for `lab_order_id` = 1
2 results for `lab_order_id` = 2*/
INSERT INTO lab_results
(lab_order_id, test_name, value_text, value_numeric, unit, reference_range, abnormal_flag, result_date)
VALUES
(1, 'Influenza A/B Result', 'Positive', NULL, NULL, 'Negative', 'Abnormal', '2026-04-10 14:00:00'),
(2, 'Glucose', NULL, 102.5, 'mg/dL', '70-99', 'Abnormal', '2026-04-11 15:30:00'),
(2, 'Calcium', NULL, 9.4, 'mg/dL', '8.6-10.2', 'Normal', '2026-04-11 15:30:00');

SELECT * FROM lab_results;


-- 10 invoices table
INSERT INTO invoices
(patient_id, visit_id, status, invoice_date, due_date)
VALUES
(1, 1, 'Pending', '2026-04-10', '2026-04-25'),
(2, 2, 'Paid', '2026-04-10', '2026-04-18'),
(3, 3, 'Partially Paid', '2026-04-11', '2026-04-26');

SELECT * FROM invoices;


-- 11 invoice_items table

INSERT INTO invoice_items
(invoice_id, item_type, description, cpt_code, quantity, unit_price)
VALUES
(1, 'Consultation', 'General wellness visit', '99213', 1, 120.00),
(2, 'Consultation', 'Flu visit consultation', '99214', 1, 150.00),
(2, 'Lab Test', 'Influenza A/B Test', '87502', 1, 80.00),
(3, 'Lab Test', 'Basic Metabolic Panel', '80048', 1, 95.00);

SELECT * FROM invoice_items;

-- 12 payments table
INSERT INTO payments
(invoice_id, amount, payment_method, payment_status, paid_at, reference_no)
VALUES
(2, 230.00, 'Credit Card', 'Completed', '2026-04-13 10:00:00', 'PAY123456'),
(3, 50.00, 'Insurance', 'Pending', NULL, 'INS789101');

SELECT * FROM payments;

-- 13 record_shares table
INSERT INTO record_shares
(patient_id, grantee_provider_id, scope, status, start_at, end_at, created_at)
VALUES
(1, 2, 'Read', 'Active', '2026-04-10 08:00:00', '2026-05-10 23:59:59', '2026-04-10 08:00:00'),
(2, 1, 'Full', 'Active', '2026-04-10 09:00:00', NULL, '2026-04-10 09:00:00'),
(3, 2, 'Write', 'Revoked', '2026-04-11 10:00:00', '2026-04-15 17:00:00', '2026-04-11 10:00:00');
SELECT * FROM record_shares;

-- 14 access_audit table
INSERT INTO access_audit
(patient_id, provider_id, action, accessed_at, purpose)
VALUES
(1, 2, 'View', '2026-04-10 10:15:00', 'Second opinion review'),
(2, 1, 'Update', '2026-04-10 11:00:00', 'Updated treatment plan'),
(3, 2, 'View', '2026-04-11 12:30:00', 'Reviewed blood pressure follow-up'),
(2, 2, 'Create', '2026-04-10 10:20:00', 'Created consultation note');

SELECT * FROM access_audit;