Netflix data analysis & end-to-end data pipeline project

Overview

This project is an end-to-end data engineering and analytics pipeline built using Python and MySQL. It demonstrates how raw CSV data can be ingested, cleaned, transformed, normalized, stored, and analyzed using a structured workflow. The primary objective is to convert the unstructured Netflix dataset into a fully organized relational database and prepare it for analytical use.

Objectives

Ingest raw Netflix data from a CSV file using Python and Pandas.

Load the cleaned dataset into MySQL using SQLAlchemy.

Perform data cleaning, formatting, and standardization.

Normalize multi-valued fields such as genre, director, cast, and country into separate relational tables.

Build a MySQL staging layer for clean, uniform data.

Prepare the database for analytical queries and business insights.

Dataset Description

The dataset used for this project is netflix_titles.csv, which contains metadata of movies and TV shows available on Netflix.
Key columns include:

show_id

type (Movie / TV Show)

title

director

cast

country

date_added

release_year

rating

duration

listed_in (Genres)

description

Architecture

The project follows a structured data pipeline:

Raw data ingestion through Python.

Preprocessing and validation using Pandas.

Writing processed data into a MySQL database.

Creating staging tables for cleaned and standardized values.

Normalizing multi-valued fields into separate tables (Genre, Cast, Country, Director).

Preparing final structured datasets for analytics.

Raw CSV → Python ETL → MySQL Staging → Normalized Tables → Analytics Layer

Technologies Used

Python

Pandas

SQLAlchemy

MySQL

Recursive CTEs for normalization

Data modeling and relational design principles

Python ETL Summary

Read the raw CSV file.

Convert data types and clean inconsistent records.

Establish a connection with MySQL using SQLAlchemy.

Load the entire cleaned dataset into a MySQL raw table.

MySQL Data Processing Summary

Creation of raw and staging tables.

Conversion of date formats.

Standardization of duration and missing values.

Normalization of multi-value columns using recursive CTE logic.

Creation of separate tables for directors, country, cast, and genre.

Normalized Tables

The following relational tables were created:

netflix_stg (clean staging table)

netflix_directors

netflix_country

netflix_cast

netflix_genre

These tables help support advanced analytical queries by enabling many-to-many relationships.

Folder Structure
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

How to Run

Install required Python packages:
pip install pandas sqlalchemy pyodbc

Configure MySQL DSN and create the target database.

Run the Python ETL script to load the dataset into MySQL.

Execute SQL scripts in the following order:

create_tables.sql

normalize_data.sql

analysis_queries.sql

Outcome

At the end of this project, the raw Netflix dataset is transformed into a fully structured, normalized database that supports efficient analysis and reporting. The project provides a clear demonstration of ETL pipelines, SQL data modeling, and relational table design suitable for data engineering and analytics portfolios.
