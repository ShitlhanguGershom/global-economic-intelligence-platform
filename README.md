# Global Economic Intelligence Platform

An end-to-end data platform for collecting, transforming, analysing and forecasting global economic indicators.

## Project Overview

Economic data is often distributed across multiple providers, formats and reporting frequencies. This makes it difficult to compare indicators consistently across countries and produce reliable, repeatable analysis.

The Global Economic Intelligence Platform aims to create a structured workflow that collects public economic data from APIs, applies data-quality checks, transforms the results into analysis-ready datasets, stores them in a relational database and presents insights through forecasting models and interactive dashboards.

## Planned Data Indicators

The initial version of the platform will focus on selected indicators such as:

-Gross domestic product
-GDP growth
-Inflation
-Population
-Unemployment
-Trade
-Gross value added

The indicator scope may expand as the project develops.

## Planned Architecture


Public APIs
    |
    v
Python Extraction
    |
    v
Raw Data Storage
    |
    v
Validation and Transformation
    |
    v
SQL Database
    |
    +-------------------+
    |                   |
    v                   v
Forecasting          Power BI