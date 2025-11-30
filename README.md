# Netflix Data Analysis & End-to-End Data Pipeline Project

## Overview

This project is an **end-to-end data engineering and analytics pipeline** built using **Python** and **MySQL**.
It demonstrates how raw CSV data can be:

* Ingested
* Cleaned
* Transformed
* Normalized
* Stored
* Analyzed

The goal is to convert the unstructured Netflix dataset into a fully modeled relational database suitable for analytical workloads.

---

## Objectives

* Ingest raw Netflix data from a CSV file using **Python + Pandas**
* Load cleaned data into **MySQL** using **SQLAlchemy**
* Perform data cleaning, formatting, and standardization
* Normalize multi-valued fields (genre, director, cast, country)
* Build a MySQL **staging layer**
* Create **fully normalized relational tables**
* Prepare final database for analytics and reporting

---

## Dataset Description

The dataset used is **`netflix_titles.csv`**, containing metadata of Netflix Movies & TV Shows.

### Key Columns:

* `show_id`
* `type` (Movie / TV Show)
* `title`
* `director`
* `cast`
* `country`
* `date_added`
* `release_year`
* `rating`
* `duration`
* `listed_in` (Genres)
* `description`

---

## Architecture

The project follows a structured pipeline:

```
Raw CSV → Python ETL → MySQL Raw Table → MySQL Staging Table
→ Normalized Tables (Genre, Director, Cast, Country)
→ Analytics Layer
```

### Steps:

1. **Raw Data Ingestion** – Read CSV using Python
2. **Preprocessing & Validation** – Pandas transformations
3. **Load to MySQL** – SQLAlchemy
4. **Staging Layer Creation**
5. **Normalization using SQL + Recursive CTEs**
6. **Final Analytics Layer**

---

## Technologies Used

* **Python**
* **Pandas**
* **SQLAlchemy**
* **MySQL**
* **Recursive CTEs**
* **Relational Data Modeling**

---

## Python ETL Summary

* Read raw CSV file
* Clean and standardize data
* Convert datatypes (date, duration, nulls)
* Connect to MySQL using SQLAlchemy
* Load cleaned data into **MySQL raw table**

---

## MySQL Data Processing Summary

* Create raw and staging tables
* Convert inconsistent date formats
* Standardize duration (movies: minutes, TV shows: seasons)
* Handle missing values
* Normalize multi-value columns:

  * Genre
  * Director
  * Cast
  * Country
* Create separate normalized tables:

  * `netflix_genre`
  * `netflix_directors`
  * `netflix_cast`
  * `netflix_country`

---

## Normalized Tables

The following relational tables are created:

| Table Name            | Purpose                      |
| --------------------- | ---------------------------- |
| **netflix_stg**       | Clean staging table          |
| **netflix_directors** | Normalized list of directors |
| **netflix_country**   | Country normalization        |
| **netflix_cast**      | Cast normalization           |
| **netflix_genre**     | Genre normalization          |

These support **many-to-many relationships** and **analytical queries**.

---

## Folder Structure

```
Netflix-Data-Pipeline/
│
├── data/
│   └── netflix_titles.csv
│
├── notebooks/
│   └── data_load.ipynb
│
├── sql/
│   ├── create_tables.sql
│   ├── normalize_data.sql
│   ├── analysis_queries.sql
│
└── README.md
```

---

## How to Run

### 1️Install Python Packages

```bash
pip install pandas sqlalchemy pyodbc
```

### Configure MySQL

Create a database and set your DSN/connection string.

### Run Python ETL Script

Loads raw → cleaned → MySQL.

### Execute SQL Scripts in Order

1. `create_tables.sql`
2. `normalize_data.sql`
3. `analysis_queries.sql`

---

## Outcome

By the end of this project:

* Raw unorganized Netflix data becomes a **clean, structured, normalized database**
* Supports **efficient analytics & BI reporting**
* Demonstrates:

  * ETL workflows
  * SQL data modeling
  * Recursive CTE usage
  * Relational database design
* Suitable for **Data Engineering & Data Analytics portfolios**
