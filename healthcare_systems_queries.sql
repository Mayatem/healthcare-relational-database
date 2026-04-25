-- Validation and analysis queries for the healthcare relational database.
-- These queries test relationships, clinical workflows, access control, and billing logic.

USE healthcare_systems;

-- How many appointments does each patient have?
SELECT * FROM appointments;
SELECT p.first_name, p.last_name, COUNT(a.appointment_id) AS total_appointments
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
Group BY p.patient_id;

-- How many visits has each patient completed?
/*This query calculates the total number of completed visits per patient. 
Unlike appointments, visits represent actual encounters,
 making this metric more meaningful for analyzing patient activity.*/
SELECT p.first_name, p.last_name, COUNT(v.visit_id) AS total_visit
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
Group BY p.patient_id;

-- Which provider has seen the most patients?
/*This query identifies which provider has seen the highest number of unique patients 
by counting distinct patient IDs from the visits table.*/
SELECT * FROM providers;
SELECT p.provider_id, p.first_name, p.last_name, COUNT(DISTINCT v.patient_id) AS total_patients
FROM providers p
JOIN visits v 
ON p.provider_id = v.provider_id
GROUP BY p.provider_id
ORDER BY total_patients;


-- 1. Clinical Data & Visit Validation
-- What are the clinical notes and the presiding provider for all visits made by 'John Doe'?
/*This query joins patients, visits, and visit_notes to verify that clinical documentation is 
correctly linked to the right patient and visit. It also identifies which provider authored the note.*/
SELECT 
    p.first_name, 
    p.last_name, 
    v.visit_start, 
    vn.note_type, 
    vn.note_text, 
    pr.last_name AS provider_name
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
JOIN visit_notes vn ON v.visit_id = vn.visit_id
JOIN providers pr ON vn.author_provider_id = pr.provider_id
WHERE p.first_name = 'John' AND p.last_name = 'Doe';


-- Query: Track Lab Results from Order to Completion
-- Which lab orders are still 'Pending' and which have 'Abnormal' results?
/*This validates the relationship between lab_orders and lab_results. 
It tests the abnormal_flag ENUM to ensure the system can flag critical values.*/
SELECT lo.order_name, lo.status AS order_status, 
    lr.test_name, lr.value_numeric, lr.unit, lr.abnormal_flag
FROM lab_orders lo
LEFT JOIN lab_results lr ON lo.lab_order_id = lr.lab_order_id
WHERE lr.abnormal_flag = 'Abnormal' OR lo.status != 'Completed';

/*2. Administrative & Facility Validation
These queries verify that the logistics of the healthcare platform (where and when) are intact.
Query: Facility Utilization Report
Question: How many appointments are scheduled at each facility, and what is the facility type?
Explanation: This confirms the link between appointments and facilities. 
It helps administrators see which locations (e.g., 'Clinic' vs 'Laboratory') are the busiest.*/
SELECT f.facility_name, f.facility_type, COUNT(a.appointment_id) AS scheduled_appointments
FROM facilities f
LEFT JOIN appointments a ON f.facility_id = a.facility_id
GROUP BY f.facility_id;

-- 3. Security & Access Control Validation
/*Query: Active Data Sharing Permissions
Question: Which providers currently have 'Active' access to patient records, 
and what is their level of access (Scope)?
Explanation: This validates the record_shares table logic, 
specifically checking for the 'Active' status and the scope (Read/Write/Full).*/
SELECT 
    p.first_name AS patient_first, 
    p.last_name AS patient_last, 
    pr.first_name AS provider_first, 
    pr.last_name AS provider_last, 
    rs.scope, 
    rs.end_at
FROM record_shares rs
JOIN patients p ON rs.patient_id = p.patient_id
JOIN providers pr ON rs.grantee_provider_id = pr.provider_id
WHERE rs.status = 'Active';

/*Query: Audit Trail for Sensitive Access
Question: List the last 4 access logs, showing which provider 
accessed which patient record and for what purpose.
Explanation: This tests the access_audit table to ensure 
the system is recording the "Purpose" of every data view, 
which is a key requirement for healthcare compliance.*/
SELECT 
    aa.accessed_at, 
    pr.last_name AS provider_name, 
    pa.last_name AS patient_name, 
    aa.action, 
    aa.purpose
FROM access_audit aa
JOIN providers pr ON aa.provider_id = pr.provider_id
JOIN patients pa ON aa.patient_id = pa.patient_id
ORDER BY aa.accessed_at DESC
LIMIT 4;


/*4. Financial & Billing Validation
Ensures that the money trail from visit to invoice to payment is accurate.
Query: Outstanding Balance per Invoice
Question: For all 'Pending' or 'Partially Paid' invoices, what is the remaining balance due?
Explanation: This is a complex validation that joins invoices, invoice_items, and payments. 
It calculates the total cost of items and subtracts the total amount paid to find the debt.*/
SELECT i.invoice_id, 
    p.last_name AS patient_name,
    SUM(ii.quantity * ii.unit_price) AS total_charge,
    IFNULL(SUM(pay.amount), 0) AS total_paid,
    (SUM(ii.quantity * ii.unit_price) - IFNULL(SUM(pay.amount), 0)) AS balance_due
FROM invoices i
JOIN patients p ON i.patient_id = p.patient_id
JOIN invoice_items ii ON i.invoice_id = ii.invoice_id
LEFT JOIN payments pay ON i.invoice_id = pay.invoice_id
WHERE i.status != 'Paid'
GROUP BY i.invoice_id;



/*Query: Invoice Financial Summary and Outstanding Balances
Question: What is the total billed amount, the total amount paid, 
and the remaining balance for each invoice in the system?
Explanation: This query calculates the financial status of every invoice 
by joining the invoices table with invoice_items (to find the sum of all charges) 
and payments (to find the sum of all credits). 
It uses IFNULL to ensure that invoices with no payments yet are treated as 
$0$ rather than NULL, allowing for an accurate calculation of the remaining balance.*/
SELECT 
    i.invoice_id,
    SUM(ii.quantity * ii.unit_price) AS total_amount,
    IFNULL(SUM(p.amount), 0) AS paid_amount,
    SUM(ii.quantity * ii.unit_price) - IFNULL(SUM(p.amount), 0) AS balance
FROM invoices i
JOIN invoice_items ii ON i.invoice_id = ii.invoice_id
LEFT JOIN payments p ON i.invoice_id = p.invoice_id
GROUP BY i.invoice_id;



SELECT * FROM visits;

/*Query: Detailed Billing Calculation per Invoice
Question: What is the total calculated value for each invoice based on its individual line items?
Explanation: This query performs a fundamental financial validation by aggregating data from the 
invoice_items table. It multiplies the quantity of each service or lab test by its unit_price and 
then uses the SUM function grouped by invoice_id. This is a critical step in ensuring that the sum 
of parts correctly reflects the total amount the patient is expected to pay.*/
SELECT invoice_id, SUM(quantity * unit_price) AS total_amount
FROM invoice_items
GROUP BY invoice_id;

/*Query: Aggregated Patient Billing and Payment History
Question: What is the total cumulative amount billed to and paid 
by each patient across all their medical encounters?
Explanation: This query provides a "lifetime value" or comprehensive 
financial snapshot for every patient. By joining the patients table through 
invoices to both invoice_items and payments, it aggregates every individual 
charge and every successful payment linked to that patient's ID. This is a vital 
administrative metric for identifying which patients have high medical costs and 
ensuring that their payment history is accurately tracked against those costs.*/
SELECT p.patient_id, p.first_name, p.last_name,
    SUM(ii.quantity * ii.unit_price) AS total_billed,
    SUM(pay.amount) AS total_paid
FROM patients p
JOIN invoices i ON p.patient_id = i.patient_id
JOIN invoice_items ii ON i.invoice_id = ii.invoice_id
LEFT JOIN payments pay ON i.invoice_id = pay.invoice_id
GROUP BY p.patient_id;



SELECT p.first_name, p.last_name, COUNT(a.appointment_id) AS total_appointments
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id;