# Healthcare Relational Database System

This project presents the design and implementation of a relational database system for a simplified healthcare management platform. The database models core healthcare workflows, including patient records, provider interactions, appointments, clinical visits, laboratory processing, billing, record sharing, and access auditing.

The project was implemented using MySQL and focuses on relational schema design, data integrity, normalization, sample data population, and validation through SQL queries.

## Project Overview

Healthcare systems depend on structured and reliable data to support clinical care, administrative operations, financial workflows, and secure information access. In this project, I designed a relational database that connects multiple healthcare domains into a single normalized schema.

The system supports two main perspectives:

- **Patients**, who can have appointments, visits, invoices, payments, and record-sharing permissions.
- **Providers**, who can manage visits, document notes, order lab tests, and access shared patient records.

## Database Features

The database includes support for:

- patient and provider management
- healthcare facilities
- appointment scheduling
- clinical visits and visit notes
- lab orders and lab results
- invoices, invoice items, and payments
- patient-provider record sharing
- access audit logging
- primary key and foreign key constraints
- controlled values using `ENUM`
- data validation using constraints

## Entity-Relationship Design

The ER diagram shows the main entities and relationships in the healthcare database system.

Key relationships include:

- one patient can have multiple appointments
- one patient can have multiple visits
- one visit can have multiple notes
- one lab order can have multiple lab results
- one invoice can have multiple invoice items
- one invoice can have multiple payments
- patients can share records with providers through a many-to-many relationship
- access events are tracked through an audit table

## Repository Structure

```text
healthcare-relational-database/
│
├── README.md
├── report/
│   └── healthcare_relational_database_report.pdf
│
├── sql/
│   ├── schema.sql
│   ├── sample_data.sql
│   └── validation_queries.sql
│
└── images/
    └── er_diagram.png
```

## How to Run

Run the SQL scripts in this order:

1. `sql/schema.sql` — creates the database and tables
2. `sql/sample_data.sql` — inserts fictional sample data
3. `sql/validation_queries.sql` — runs validation and analysis queries

You can run the files in MySQL Workbench or from the MySQL command line.

## Validation Queries

The validation queries test the database across several areas:

- patient appointment history
- completed visits by patient
- provider activity
- facility usage
- clinical notes and lab results
- active record-sharing permissions
- access audit logs
- invoice balances and patient financial summaries

## Key Skills Demonstrated

- relational database design
- ER modeling
- normalization
- SQL DDL and DML
- primary and foreign key constraints
- joins and aggregation queries
- access control modeling
- healthcare data modeling
- billing workflow modeling
