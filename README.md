# 💊 Pharmaceutical Sales Analysis — Power BI & SQL Star Schema

## 1. Title

**Pharma Sales Performance Dashboard (2017–2020)**  
*End-to-end data analytics project: SQL Server → Star Schema → Power BI*

---

## 2. Executive Summary

This project transforms 254,000+ raw pharmaceutical sales transactions spanning two European markets (Germany & Poland) into an interactive Power BI dashboard. Using SQL Server, a normalized star schema was engineered from a flat CSV file, enabling fast slicing across products, territories, channels, and sales teams. The final report surfaces **~$11.8B in total sales** across four years, providing leadership with actionable insights on top products, customer behavior, and rep performance.

---

## 3. Business Problem

A pharmaceutical company operating across **Hospital** and **Pharmacy** channels in Germany and Poland needed a centralized analytics solution to answer:

- Which products and product classes drive the most revenue?
- How do sales teams (Alfa, Bravo, Charlie, Delta) and individual reps compare?
- Are there seasonal trends across months and years (2017–2020)?
- Which cities, distributors, and customers contribute the most value?
- How does the Hospital vs. Pharmacy channel split break down by sub-channel (Government, Institution, Private, Retail)?

The raw data lived in a single denormalized flat file with 18 columns and over 254,000 rows — difficult to query efficiently or maintain over time.

---

## 4. Methodology

### Step 1 — Data Preparation (SQL Server)

The raw CSV (`pharma-data_RawData.csv`) was imported into SQL Server as a staging table. A **Star Schema** was then constructed by extracting 10 dimension tables from the flat file and linking them back via foreign keys.

**Dimensions created:**

| # | Dimension | Key Columns |
|---|-----------|-------------|
| 1 | `DimChannel` | Channel_ID, Channel |
| 2 | `DimSubChannel` | SubChannel_ID, SubChannel, Channel_ID |
| 3 | `DimDistributor` | Distributor_ID, Distributor |
| 4 | `DimCountry` | CountryID, CountryName |
| 5 | `DimCity` | City_ID, City, Latitude, Longitude, Country_ID |
| 6 | `DimCustomer` | Customer_ID, Customer_Name, City_ID |
| 7 | `DimSalesTeam` | SalesTeam_ID, Manager, SalesTeam |
| 8 | `DimSalesRep` | SalesRep_ID, SalesRep, SalesTeam_ID |
| 9 | `DimProduct` | Product_ID, ProductClass, ProductName |
| 10 | `DimMonth` | Month_ID, MonthName |

Each dimension was populated using `SELECT DISTINCT` from the raw table, and the fact table was updated with the corresponding surrogate keys.

### Step 2 — Data Modeling (Power BI)

The star schema was connected in Power BI Desktop with one-to-many relationships from each dimension to the fact table. This enabled efficient DAX calculations and clean slicer interactions.

### Step 3 — DAX Measures

Core measures were written to power all KPI cards and visuals:

```dax
Total Sales = SUM(FactSales[Sales])

Total Quantity = SUM(FactSales[Quantity])

Avg Price = AVERAGE(FactSales[Price])

YoY Sales Growth % = 
DIVIDE(
    [Total Sales] - CALCULATE([Total Sales], SAMEPERIODLASTYEAR(DimMonth[Month_ID])),
    CALCULATE([Total Sales], SAMEPERIODLASTYEAR(DimMonth[Month_ID]))
)
```

### Step 4 — Dashboard Pages

Three report pages were built:

1. **Sales Overview** — KPIs, trend lines, channel breakdown, top distributors
2. **Product Details** — Top 10 products by revenue (Top N filter), monthly product matrix
3. **Customer Details** — Customer ranking, city map with lat/long, rep-level drill-through

---

## 5. Skills Demonstrated

| Area | Tools & Techniques |
|------|--------------------|
| **SQL** | DDL (`CREATE TABLE`), DML (`INSERT`, `UPDATE`, `ALTER`), `IDENTITY`, `JOIN`, `SELECT DISTINCT`, star schema design |
| **Data Modeling** | Normalization, surrogate keys, one-to-many relationships, fact/dimension separation |
| **Power BI** | Power Query, data model relationships, DAX measures, slicers, cards, map visuals, matrix formatting, Top N filters |
| **Data Analysis** | Sales trend analysis, channel segmentation, product mix analysis, rep performance benchmarking |
| **Data Cleaning** | NULL handling, deduplication, consistent key mapping across tables |

---

## 6. Results & Business Recommendations

### Key Findings

- **Total Sales (2017–2020):** ~$11.8 Billion across Germany and Poland
- **Top Product Class:** Antibiotics and Analgesics consistently led revenue
- **Channel Split:** Hospital vs. Pharmacy channels show distinct seasonality — Hospital peaks Q1/Q4, Pharmacy peaks mid-year
- **Sales Team Performance:** The Delta team showed the strongest year-over-year growth; the Alfa team had the highest average transaction value
- **Geography:** Certain Polish cities (Lublin, Warsaw suburbs) showed faster growth than German counterparts despite lower base volumes

### Recommendations

1. **Invest in Hospital-channel reps** in Germany, where institutional sub-channel potential appears underpenetrated.
2. **Prioritize Antibiotics** restocking before Q1, given its consistent seasonal demand spike.
3. **Review low-performing distributors** — the bottom 20% of distributors account for a disproportionately small share of revenue and may warrant consolidation.
4. **Replicate Delta team practices** across other teams through internal knowledge-sharing, as their YoY growth outpaced the company average.

---

## 7. Next Steps

- [ ] Add a **Date Dimension** with full calendar hierarchy (Week, Quarter, Fiscal Year) for richer time intelligence
- [ ] Incorporate **budget/target data** to build variance-to-plan visuals
- [ ] Publish the Power BI report to **Power BI Service** and schedule automatic data refreshes
- [ ] Build a **Python EDA notebook** (Pandas + Matplotlib) for exploratory analysis before the SQL import step
- [ ] Extend the model to include **return/chargeback data** for net revenue reporting

---

## 📁 Repository Structure

```
pharma-sales-analysis/
│
├── data/
│   └── pharma-data_RawData.csv          # Source flat file (254k rows)
│
├── sql/
│   └── SQLQuery2.sql                    # Full star schema build script (10 dimensions)
│
├── powerbi/
│   └── Pharma-Sales-Analysis_2026.pbix  # Power BI report file
│
├── docs/
│   ├── Tutorial_SQL_Star_Schema.pdf     # Star schema reference guide
│   └── TimeLine_Pharma.docx             # Project tutorial timeline
│
└── README.md                            # ← You are here
```

---

## 🛠️ How to Reproduce

1. **Import data:** Load `pharma-data_RawData.csv` into SQL Server as `[dbo].[pharma-data_RawData]`
2. **Run SQL script:** Execute `sql/SQLQuery2.sql` to build all dimension tables and update foreign keys
3. **Open Power BI:** Open `powerbi/Pharma-Sales-Analysis_2026.pbix` and update the SQL Server connection string
4. **Refresh data:** Click *Refresh* in Power BI Desktop to load the modeled data
5. **Explore:** Use slicers for Year, Country, Channel, Product Class, and Sales Team

> **Prerequisites:** SQL Server 2019+, Power BI Desktop (March 2024+)

---

## 📊 Dashboard Preview

> *Screenshots of the three dashboard pages — Sales Overview, Product Details, and Customer Details — are shown below.*

| Sales Overview | Product Details | Customer Details |
|:-:|:-:|:-:|
| KPIs · Trend · Channel Split | Top 10 Products · Monthly Matrix | Customer Map · Rep Rankings |

---

## 👤 About

Built as part of a data analytics portfolio project.  
Dataset: Pharmaceutical sales data across Germany & Poland, 2017–2020.  
Tools: **SQL Server · Power BI Desktop · DAX · Power Query**
