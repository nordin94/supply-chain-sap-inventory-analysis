# SAP MB51 inventory analysis: Excel + SQL

A weekly inventory review for one plant, built the way a supply chain analyst does it in practice: take the raw SAP export, clean it, analyse the stock movements, check the numbers reconcile, and report what needs action.

The same analysis is done twice, in **Excel** and in **SQL**, and both give identical results.

## The question

> What happened to the stock in plant NL01 during the week of 3–9 November 2026, and is there anything that needs action?

## Data

| File | What it is |
|---|---|
| `data/mb51_export_nl01.csv` | Material document list (SAP transaction **MB51**), 14 movements, exactly as exported |
| `data/material_master.csv` | Material master: description and unit price |
| `data/movement_types.csv` | The SAP movement types used, and how each one affects stock |

The data is synthetic, but it reproduces the format and the problems of a real MB51 export. The materials, quantities and prices are made up.

### Data problems in the raw export

| Problem | Example | Why it matters |
|---|---|---|
| Material numbers padded to 18 characters | `000000000001000123` | Does not match the material master (`1000123`) |
| Hidden spaces in 3 material numbers | `000000000001000456 ` | Lookups and joins silently fail |
| Negative quantities with a trailing minus | `50-` | Stored as text, so `SUM` ignores them **without any error**: the total shows 1,700 instead of 1,103 |
| Dates as text with dots | `03.11.2026` | Cannot be sorted or filtered by date |
| Storage location with leading zeros | `0001` | Must stay text, or `0001` becomes `1` and filters stop working |

## Process

1. **Understand**: what each MB51 column and movement type means (`excel/` → *Data dictionary* sheet).
2. **Clean**: fix the five problems above.
3. **Enrich**: add the movement description, material name, unit price, value in EUR and in/out flag.
4. **Analyse**: receipts, issues, scrap, stock change by storage location.
5. **Reconcile**: storage location 0001 + 0002 must equal the plant total.
6. **Report**: five lines a manager can act on.

### Key cleaning steps

| Step | Excel | SQL |
|---|---|---|
| 7-digit material | `=RIGHT(TRIM(A5);7)` | `RIGHT(TRIM(material), 7)` |
| `50-` → `-50` | `=IF(RIGHT(H5;1)="-";-VALUE(LEFT(H5;LEN(H5)-1));VALUE(H5))` | `CASE WHEN RIGHT(quantity,1)='-' THEN -CAST(LEFT(quantity, LENGTH(quantity)-1) AS INTEGER) ELSE CAST(quantity AS INTEGER) END` |
| Text → date | `=DATE(VALUE(RIGHT(G5;4));VALUE(MID(G5;4;2));VALUE(LEFT(G5;2)))` | `TO_DATE(posting_date, 'DD.MM.YYYY')` |
| Price lookup | `=VLOOKUP(K5;$W$5:$Y$7;3;FALSE)` | `JOIN material_master ON ...` |

## Results

The week, grouped by what each movement really does to stock:

| Bucket | Movement types | Units |
|---|---|---|
| Real goods receipts | 101 − 102 | **+1,550** |
| Real issues | 261 (production) + 601 (customer) + 551 (scrap) | **−447** |
| Internal transfers | 311 | **0** (50 units moved from 0001 to 0002) |
| **Net stock change** | | **+1,103** |

Reconciliation: storage location 0001 (+1,053) + 0002 (+50) = **1,103** ✔

## Findings

1. **Probable defective batch of hi-vis vests.** 12 of the 150 vests received on 5 Nov were scrapped two days later, before any were used. That is 8 % of the delivery and 83 % of the week's scrap value (96 € of 116 €). A defect found this soon after receipt points to the supplier, not to storage.
2. **A goods receipt posted by mistake.** 100 gloves were received (101) and reversed (102) on the same day. If this happens often, system stock cannot be trusted.
3. **Possible overstock of safety helmets.** 1,200 helmets arrived and only 380 left, which leaves 820 units (9,840 €) of new stock.

## Recommendations

- **Quality**: inspect the vest batch and claim 96 € from the supplier.
- **Warehouse**: find out why the glove receipt was posted and reversed.
- **Purchasing**: confirm whether the 1,200-helmet order matched demand.

## Repository structure

```
data/    raw SAP export, material master, movement types
excel/   cleaning + analysis workbook, with the written report
sql/     01 create tables · 02 cleaning view · 03 analysis queries
```

The SQL is written for PostgreSQL. `RIGHT` and `LEFT` also work in SQL Server and MySQL; SQLite and Oracle use `SUBSTR` instead. The workbook was built in Google Sheets with Spanish regional settings, so formulas use `;` as the separator.

## Skills shown

SAP MM inventory (MB51, movement types 101/102/261/311/551/601) · data cleaning · Excel (`SUMIFS`, `COUNTIFS`, `VLOOKUP`, `IF`/`AND`, text functions) · SQL (`CASE`, `GROUP BY`, `JOIN`, views) · reconciliation · business reporting

## Author

**Nordin Khloufi**: data analyst with a background in warehouse and outbound logistics.
