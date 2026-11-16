-- Step 2: clean the export once and keep the result as a view.

CREATE VIEW mb51_clean AS
SELECT
    -- 18-char SAP material -> 7-digit code. TRIM first, or a trailing space breaks RIGHT.
    RIGHT(TRIM(material), 7)                                        AS material,
    storage_loc,
    movement_type,
    material_doc,
    -- '03.11.2026' -> real date
    TO_DATE(posting_date, 'DD.MM.YYYY')                             AS posting_date,
    -- '50-' -> -50 (SAP puts the minus sign at the end)
    CASE WHEN RIGHT(quantity, 1) = '-'
         THEN -CAST(LEFT(quantity, LENGTH(quantity) - 1) AS INTEGER)
         ELSE CAST(quantity AS INTEGER)
    END                                                             AS quantity
FROM mb51_raw;

-- Data quality check: every SAP material should be 18 characters long.
-- Rows returned here contain hidden spaces.
SELECT material, LENGTH(material) AS length
FROM mb51_raw
WHERE LENGTH(material) <> 18;
