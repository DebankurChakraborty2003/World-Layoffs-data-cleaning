# 🌍 Global Tech Layoffs Data Cleaning & Standardization (SQL)

![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/Language-SQL-CC2927?style=for-the-badge&logo=databricks&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-2EA44F?style=for-the-badge)

## 📌 Project Overview
This project focuses on end-to-end **data cleaning, deduplication, standardization, and schema normalization** of a global layoffs dataset (`2020–2023`) using **MySQL**. Starting with **2,361 raw records**, the pipeline transforms messy, inconsistent real-world records into an analysis-ready dataset of **1,995 clean records** across **1,633 companies**, **30 industries**, and **51 countries**.

The SQL workflow follows industry best practices by isolating raw data in staging tables (`layoffs_staging` and `layoffs_staging2`) so the original source table remains untouched and reproducible.

---

## 📂 Repository Structure

```text
├── layoffs.csv                        # Raw, uncleaned global layoffs dataset (2,361 rows)
├── World Layoff Script.sql            # Complete MySQL data cleaning & transformation script
├── World Layoff Cleaned dataset.csv   # Final cleaned & standardized dataset (1,995 rows)
└── README.md                          # Project documentation
```

---

## 🗂️ Dataset Schema

Both the raw and cleaned datasets share a 9-column structure:

| Column Name | Raw Type | Cleaned Type | Description |
| :--- | :--- | :--- | :--- |
| `company` | `TEXT` | `TEXT` | Name of the company conducting layoffs |
| `location` | `TEXT` | `TEXT` | City or metropolitan hub of the affected office |
| `industry` | `TEXT` | `TEXT` | Business sector/industry vertical |
| `total_laid_off` | `INT` | `INT` | Total number of employees laid off |
| `percentage_laid_off` | `TEXT` | `TEXT` / `FLOAT` | Proportion of workforce laid off (`0.0` to `1.0`, where `1` = 100%) |
| `date` | `TEXT` | `DATE` | Date the layoff was announced (`YYYY-MM-DD`) |
| `stage` | `TEXT` | `TEXT` | Funding or corporate stage (e.g., `Seed`, `Series A–E`, `Post-IPO`) |
| `country` | `TEXT` | `TEXT` | Country where the company/office is located |
| `funds_raised_millions` | `INT` | `INT` | Total capital raised by the company (in USD millions) |

---

## 🛠️ Data Cleaning Workflow

The transformation pipeline in `World Layoff Script.sql` is structured into six systematic stages:

### 1. Staging Environment Setup
* Created `layoffs_staging` as an exact structural and data replica of the raw `layoffs` table to preserve data integrity and allow safe rollback.

### 2. Duplicate Detection & Removal
* Used a **Common Table Expression (CTE)** with the `ROW_NUMBER()` window function partitioned across all 9 columns (`company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`) to flag exact duplicate entries (`ROW_NUM > 1`).
* Materialized the indexed records into `layoffs_staging2` and deleted all duplicate rows.

### 3. Data Standardization & Whitespace Trimming
* **Company Names:** Removed leading and trailing whitespace using `TRIM(company)`.
* **Industry Labels:** Consolidated fragmented cryptocurrency labels (`Crypto`, `Crypto Currency`, `CryptoCurrency`) into a single unified **`Crypto`** category.
* **Country Names:** Fixed trailing punctuation anomalies (e.g., `"United States."` $\rightarrow$ **`"United States"`**) using wildcard matching (`LIKE 'United States%'`).
* **Location Audit:** Verified `location` string lengths against trimmed values to ensure formatting consistency.

### 4. Data Type Conversion
* Converted the `date` column from raw `TEXT` (`MM/DD/YYYY` format) to MySQL's native **`DATE`** format using ``STR_TO_DATE(`date`, '%m/%d/%Y')`` followed by `ALTER TABLE ... MODIFY COLUMN`.

### 5. Null & Blank Value Handling
* Converted empty string (`''`) entries in `industry` into proper SQL `NULL` values.
* Performed a **self-join** on `layoffs_staging2` matching on `company` to impute missing `industry` values from other complete records of the same company (e.g., populating missing industry fields for *Airbnb* and *Carvana*).
* Removed **unusable records** where both `total_laid_off` and `percentage_laid_off` were `NULL`, as those rows provide no quantifiable layoff metrics for downstream analysis.

### 6. Schema Finalization
* Dropped the temporary helper column `ROW_NUM` via `ALTER TABLE layoffs_staging2 DROP COLUMN ROW_NUM` to deliver a clean final table.

---

## 📊 Cleaning Impact & Key Dataset Highlights

| Metric | Raw Dataset (`layoffs.csv`) | Cleaned Dataset (`World Layoff Cleaned dataset.csv`) | Net Change |
| :--- | :---: | :---: | :---: |
| **Total Records** | 2,361 | 1,995 | `-366 rows` (-15.5%) |
| **Missing `total_laid_off`** | 740 | 378 | `-362 nulls` |
| **Missing `percentage_laid_off`** | 785 | 423 | `-362 nulls` |
| **Missing `industry`** | 4 | 1 | `-3 nulls` |
| **Date Range** | `3/11/2020` – `3/6/2023` (Text) | `2020-03-11` – `2023-03-06` (`DATE`) | Standardized |

### Summary Statistics (Cleaned Data)
* **Total Employees Laid Off:** `383,659`
* **Coverage:** `1,633` unique companies across `30` industries and `51` countries
* **Top 5 Most Impacted Companies:** Amazon (`18,150`), Google (`12,000`), Meta (`11,000`), Salesforce (`10,090`), Microsoft (`10,000`)
* **Top 5 Most Impacted Industries:** Consumer (`45,182`), Retail (`43,613`), Other (`36,289`), Transportation (`33,748`), Finance (`28,344`)
* **Top 5 Most Impacted Countries:** United States (`256,559`), India (`35,993`), Netherlands (`17,220`), Sweden (`11,264`), Brazil (`10,391`)

---

## 🚀 How to Run This Project

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/](https://github.com/)<your-username>/<your-repo-name>.git
   cd <your-repo-name>
   ```
2. **Create the database and import raw data:**
   * Open **MySQL Workbench** (or any MySQL 8.0+ client).
   * Create the schema:
     ```sql
     CREATE DATABASE IF NOT EXISTS world_layoffs;
     ```
   * Import `layoffs.csv` into a table named `layoffs` inside `world_layoffs` using the Table Data Import Wizard.
3. **Execute the cleaning script:**
   * Open `World Layoff Script.sql` and execute the statements sequentially to generate the cleaned `layoffs_staging2` table.
4. **Export (Optional):**
   * Export `layoffs_staging2` to CSV to reproduce `World Layoff Cleaned dataset.csv`.

---

## 🔮 Future Scope
* **Exploratory Data Analysis (EDA):** Build a companion SQL script analyzing rolling monthly layoff totals, year-over-year trends, and company rankings by year using `DENSE_RANK()`.
* **Interactive Dashboard:** Connect `World Layoff Cleaned dataset.csv` to **Power BI** or **Tableau** to visualize geographic and sector-level layoff distributions.
