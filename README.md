# 🛒 Superstore Sales & Profitability Analysis — SQL

**Dataset:** Sample Superstore (Kaggle) | Multi-year US Retail Sales Data  
**Tool:** Microsoft SQL Server  
**Skills:** DDL, Joins, Aggregations, Subqueries, CTEs, Window Functions, Data Transformation

---

## 📌 Project Overview

Analyzed a real-world retail dataset to uncover profit drivers, loss-making products, and discount impact across regions and customer segments. Structured across 7 SQL tasks covering 100 marks total.

---

## 🗂️ Database Schema

4 normalized tables with primary & foreign key relationships:
```
Customers → Orders → Sales ← Products
```

- **Customers** — CustomerID, Name, Segment, Region, City, State
- **Orders** — OrderID, OrderDate, ShipDate, ShipMode, CustomerID
- **Products** — ProductID, Category, SubCategory, ProductName
- **Sales** — RowID, OrderID, ProductID, Sales, Quantity, Discount, Profit

---

## ✅ Tasks Completed

| Task | Topic | Marks |
|------|-------|-------|
| 1 | Database & Table Creation | 10 |
| 2 | Basic Queries | 10 |
| 3 | Aggregate Functions | 15 |
| 4 | Joins | 20 |
| 5 | Subqueries & CTEs | 20 |
| 6 | Window Functions | 15 |
| 7 | Data Transformation | 10 |
| 8 | Business Insights | 10 |

---

## 💡 Key Insights

| # | Insight | Recommendation |
|---|---------|----------------|
| 1 | Technology has ~17% profit margin — highest of all categories | Increase investment, bundle with Office Supplies |
| 2 | Furniture Tables & Bookcases generate negative profit | Reduce heavy discounting or discontinue |
| 3 | Discounts above 40% always cause losses | Cap max discount at 30% |
| 4 | Central region underperforms despite decent sales | Audit pricing and logistics costs |
| 5 | Consumer segment drives maximum revenue | Invest in loyalty programs |

---

## 📁 Files

| File | Description |
|------|-------------|
| `Assignment.sql` | All SQL queries across 7 tasks, clearly labeled |
| `Assignment.docx` | Key insights & recommendations document |
| `Sample_-_Superstore.csv` | Raw dataset used for analysis |

---

## 🛠️ How to Run

1. Open **SQL Server Management Studio (SSMS)**
2. Import `Sample_-_Superstore.csv` as `SuperstoreRaw`
3. Run `Assignment.sql` top to bottom
