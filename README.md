# RPA Project

This repository contains an invoice-processing RPA workflow built with **UiPath** and **Robot Framework**.

The project processes sample invoice PDFs, extracts both invoice-level and product-level data, validates the extracted values, and stores the results in a MySQL database.

---

## Overview

The automation is split into two stages:

1. **UiPath extraction stage**
   - Reads invoice PDF files from the `uipath/invoices/` folder.
   - Extracts key invoice data such as:
     - total amount
     - reference number
     - IBAN
     - invoice date
     - invoice number
   - Extracts line items such as:
     - description
     - quantity
     - unit
     - unit price
     - VAT
     - total price
   - Writes the extracted data into CSV files.

2. **Robot Framework validation and export stage**
   - Reads the generated CSV files.
   - Validates invoice data using simple business rules.
   - Verifies product price calculations.
   - Inserts validated data into a MySQL database.

---

## Workflow

```text
PDF invoices -> UiPath extraction -> temp.csv / tempProds.csv
           -> Robot Framework validation -> MySQL database
```

---

## Features

- PDF invoice text extraction with UiPath
- Support for multiple invoice samples
- Basic handling of Finnish invoice labels such as `Päiväys` and `Viitenumero`
- Extraction of invoice summary fields and individual product rows
- CSV export for intermediate processing
- Validation of invoice values in Robot Framework
- MySQL export for both invoices and products
- Generated Robot Framework execution reports included in the repo

---

## Repository Structure

```text
rpa-project/
├── robotframework/
│   ├── invoice_verification.robot
│   ├── log.html
│   ├── output.xml
│   └── report.html
├── uipath/
│   ├── Main.xaml
│   ├── project.json
│   ├── invoices/
│   │   ├── Invoice1.pdf
│   │   ├── Invoice2.pdf
│   │   └── Invoice3.pdf
│   ├── csvresults/
│   ├── projspecs/
│   ├── Invoice1.pdf.txt
│   ├── Invoice2.pdf.txt
│   └── Invoice3.pdf.txt
├── heh.sql
├── temp.csv
├── tempProds.csv
├── temptest.csv
├── log.html
├── output.xml
└── report.html
```

---

## Technologies Used

- **UiPath Studio**
- **Robot Framework**
- **RPA Framework libraries for Robot Framework**
- **MySQL**
- **CSV-based intermediate data exchange**

UiPath dependencies are defined in `uipath/project.json`.

---

## Validation Rules

The Robot Framework workflow currently applies these checks:

### Invoice-level validation
- **Amount** must be greater than `0`
- **Reference number** must:
  - be between 3 and 20 digits
  - not start with `0`
- **IBAN** must:
  - start with `FI`
  - contain exactly 16 digits after `FI`
  - have a total length of 18 characters after spaces are removed
- **Date** must match `MM/DD/YYYY`, then it is converted to `YYYY-MM-DD` for database insertion

### Product-level validation
- Product total is verified using:

```text
quantity * unit price * ((VAT % / 100) + 1)
```

---

## Prerequisites

Before running the project, make sure you have:

- **UiPath Studio** installed
- **Python** installed
- **Robot Framework** installed
- Required Robot Framework libraries available
- **MySQL** server running locally or accessible from your environment

The Robot Framework script is configured by default to use:

- host: `127.0.0.1`
- port: `3306`
- database: `RPAdb`
- user: `root`
- password: `root`

You should change these values before using the project in any real environment.

---

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/julius-ingeli/rpa-project.git
cd rpa-project
```

### 2. Open the UiPath project

Open the `uipath/` folder in **UiPath Studio**.

UiPath should restore the project dependencies automatically from `project.json`.

### 3. Prepare the database

The repository includes a SQL dump file named `heh.sql`, but it does **not fully match** the current Robot Framework inserts.

At minimum, your database should contain tables for both invoices and products. A practical schema could look like this:

```sql
CREATE DATABASE IF NOT EXISTS RPAdb;
USE RPAdb;

CREATE TABLE IF NOT EXISTS invoices (
    invoicenr INT,
    amount DECIMAL(10,2),
    refnum BIGINT,
    iban VARCHAR(50),
    date DATETIME
);

CREATE TABLE IF NOT EXISTS products (
    invoiceNr INT,
    description VARCHAR(255),
    quantity INT,
    unit VARCHAR(50),
    unitprice DECIMAL(10,2),
    vatPerc DECIMAL(5,2),
    varTot DECIMAL(10,2),
    priceTot DECIMAL(10,2)
);
```

Note that the `products` table above uses `varTot` because that is the column name used in the current Robot Framework insert statement.

### 4. Check file paths in `Main.xaml`

The UiPath workflow currently uses absolute Windows paths. You will likely need to update them to match your machine before running the process.

Typical paths to review:
- invoice input folder
- generated CSV files
- any local project directories

### 5. Run the UiPath workflow

Run `Main.xaml` to:
- read the invoice PDFs
- extract invoice data
- generate `temp.csv`
- generate `tempProds.csv`

### 6. Run the Robot Framework workflow

After the CSV files are generated, execute:

```bash
robot robotframework/invoice_verification.robot
```

This will:
- validate invoice-level data
- validate product totals
- insert records into MySQL
- generate Robot Framework result files

---

## Input and Output Files

### Input
- `uipath/invoices/*.pdf` – sample invoice PDFs

### Intermediate output
- `temp.csv` – extracted invoice summary data
- `tempProds.csv` – extracted product-level data
- `uipath/Invoice*.pdf.txt` – extracted plain-text invoice content used for inspection/debugging

### Execution output
- `log.html`
- `report.html`
- `output.xml`

---

## Notes and Limitations

This repository looks like a school or demo project rather than a production-ready automation. A few practical limitations are worth noting:

- The UiPath workflow appears to depend on absolute local Windows paths.
- Database credentials are hardcoded in the Robot Framework file.
- The provided SQL dump is incomplete relative to the current Robot Framework insert logic.
- Temporary CSV files and generated execution artifacts are committed into the repository.
- The workflow is tailored to the included sample invoice formats and will likely need changes for other invoice layouts.

---

## Suggested Improvements

- Replace hardcoded paths with relative paths or configuration files
- Move database credentials into environment variables or a secure config file
- Align the SQL schema with the current insert statements
- Add proper primary keys and foreign keys
- Add error handling and duplicate detection
- Separate source files from generated outputs
- Add screenshots or an architecture diagram to document the process visually

---

## Running the Project End-to-End

1. Open the UiPath project
2. Verify local paths and dependencies
3. Prepare the MySQL database
4. Run `Main.xaml`
5. Confirm that `temp.csv` and `tempProds.csv` were generated
6. Run the Robot Framework test
7. Review database contents and generated reports

---

## Purpose

This project demonstrates how different automation tools can be combined in a single workflow:

- **UiPath** for document extraction and structured data preparation
- **Robot Framework** for validation and database export

It is a useful example of a hybrid RPA pipeline for invoice processing and structured data handling.
